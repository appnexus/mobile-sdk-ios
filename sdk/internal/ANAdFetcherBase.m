/*   Copyright 2019 APPNEXUS INC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "ANAdFetcherBase+PrivateMethods.h"
#import "ANUniversalTagRequestBuilder.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANLogging.h"
#import "ANGlobal.h"
#import "ANStandardAd.h"
#import "ANRTBVideoAd.h"
#import "ANCSMVideoAd.h"
#import "ANSSMStandardAd.h"
#import "ANNativeStandardAdResponse.h"
#import "ANMediatedAd.h"
#import "ANNativeMediatedAdController.h"
#import "ANTrackerInfo.h"
#import "ANTrackerManager.h"
#import "NSTimer+ANCategory.h"

@interface ANAdFetcherBase()


@property (nonatomic, readwrite, assign)  NSTimeInterval                    totalLatencyStart;

@end

@implementation ANAdFetcherBase

- (void)setup{
      [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
}

- (void)requestAd
{
    NSString      *urlString  = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    NSURLRequest  *request    = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:self.delegate baseUrlString:urlString];
    
    
    [self markLatencyStart];
    
    if (!self.isLoading)
    {
        NSString *requestContent = [NSString stringWithFormat:@"%@ /n %@", urlString,[[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding] ];
        
        ANPostNotifications(kANUniversalAdFetcherWillRequestAdNotification, self,
                            @{kANUniversalAdFetcherAdRequestURLKey: requestContent});
        
        ANAdFetcherBase *__weak weakSelf = self;
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                      dataTaskWithRequest:request
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                          ANAdFetcherBase *__strong strongSelf = weakSelf;
                                          
                                          if(!strongSelf){
                                              return;
                                          }
                                          NSInteger statusCode = -1;
                                          [strongSelf restartAutoRefreshTimer];
                                          
                                          if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                              statusCode = [httpResponse statusCode];
                                              
                                          }
                                          
                                          if (statusCode >= 400 || statusCode == -1)  {
                                              strongSelf.loading = NO;
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  NSError *sessionError = ANError(@"ad_request_failed %@", ANAdResponseNetworkError, error.localizedDescription);
                                                  ANLogError(@"%@", sessionError);
                                                  
                                                  ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithError:sessionError];
                                                  [strongSelf processFinalResponse:response];
                                              });
                                              
                                          }else{
                                              strongSelf.loading  = YES;
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  NSString *responseString = [[NSString alloc] initWithData:data
                                                                                                   encoding:NSUTF8StringEncoding];
                                                  ANLogDebug(@"Response JSON %@", responseString);
                                                  ANPostNotifications(kANUniversalAdFetcherDidReceiveResponseNotification, strongSelf,
                                                                      @{kANUniversalAdFetcherAdResponseKey: (responseString ? responseString : @"")});
                                                  
                                                  ANUniversalTagAdServerResponse *adResponse = [ANUniversalTagAdServerResponse responseWithData:data];
                                                  [strongSelf processAdServerResponse:adResponse];
                                                  
                                              });
                                              
                                          }
                                          
                                      }];
        
        [task resume];
    }
}

- (void)cancelRequest{
    
}

#pragma mark - UT ad response processing methods
- (void)processAdServerResponse:(ANUniversalTagAdServerResponse *)response
{
    BOOL containsAds = (response.ads != nil) && (response.ads.count > 0);
    
    if (!containsAds) {
        ANLogWarn(@"response_no_ads");
        [self finishRequestWithError:ANError(@"response_no_ads", ANAdResponseUnableToFill)];
        return;
    }
    
    if (response.noAdUrlString) {
        self.noAdUrl = response.noAdUrlString;
    }
    self.ads = response.ads;
    
    [self clearMediationController];
    [self continueWaterfall];
}


/**
 * Mark the beginning of an ad request for latency recording
 */
- (void)markLatencyStart {
    self.totalLatencyStart = [NSDate timeIntervalSinceReferenceDate];
}

/**
 * RETURN: success  time difference since ad request start
 *         error    -1
 */
- (NSTimeInterval)getTotalLatency:(NSTimeInterval)stopTime
{
    NSTimeInterval  totalLatency  = -1;
    
    if ((self.totalLatencyStart > 0) && (stopTime > 0)) {
        totalLatency = (stopTime - self.totalLatencyStart);
    }
    
    //
    return  totalLatency;
}



#pragma mark - Ad handlers.

- (void)fireResponseURL:(NSString *)urlString
                 reason:(ANAdResponseCode)reason
               adObject:(id)adObject
{
    
    if (urlString) {
        [ANTrackerManager fireTrackerURL:urlString];
    }
    
    if (reason == ANAdResponseSuccessful) {
        ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithAdObject:adObject andAdObjectHandler:self.adObjectHandler];
        [self processFinalResponse:response];
        
    } else {
        ANLogError(@"FAILED with reason=%@.", @(reason));
        
        // mediated ad failed. clear mediation controller
        [self clearMediationController];
        
        // stop waterfall if delegate reference (adview) was lost
        if (!self.delegate) {
            self.loading = NO;
            return;
        }
        
        [self continueWaterfall];
    }
}


@end
