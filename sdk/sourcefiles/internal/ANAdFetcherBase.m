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
#import "ANUniversalTagAdServerResponse.h"
#import "ANAdView+PrivateMethods.h"




#pragma mark -

@interface ANAdFetcherBase()
    //EMPTY
@end




#pragma mark -

@implementation ANAdFetcherBase

#pragma mark Lifecycle.

- (nonnull instancetype)init
{
    self = [super init];
    if (!self)  { return nil; }

    //
    [self setup];

    return  self;
}

- (void)setup
{
    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
}

- (void)requestAd
{
    if (self.isFetcherLoading)  { return; }


    //
    NSString      *urlString  = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    NSURLRequest  *request    = nil;

    if (self.fetcherMARManager) {
        request = [ANUniversalTagRequestBuilder buildRequestWithMultiAdRequestManager:self.fetcherMARManager baseUrlString:urlString];
    } else if (self.adunitMARManager) {
        request = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:self.delegate adunitMultiAdRequestManager:self.adunitMARManager baseUrlString:urlString];
    } else {
        request = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:self.delegate baseUrlString:urlString];
    }

    if (!request)
    {
        if (self.fetcherMARManager) {
            NSError  *sessionError  = ANError(@"multi_ad_request_failed %@", ANAdResponseNetworkError, @"request is nil.");
            ANLogError(@"%@", sessionError);

            ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithError:sessionError];
            [self processFinalResponse:response];
        }

        return;
    }
    

    //
    NSString  *requestContent  = [NSString stringWithFormat:@"%@ /n %@", urlString,[[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding] ];

    NSURLSessionDataTask       *requestAdTask   = nil;
    ANAdFetcherBase *__weak     weakSelf        = self;


    ANPostNotifications(kANUniversalAdFetcherWillRequestAdNotification, self,
                        @{kANUniversalAdFetcherAdRequestURLKey: requestContent});

    requestAdTask = [[NSURLSession sharedSession] dataTaskWithRequest: request
                                                    completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error)
                                    {
                                      ANAdFetcherBase * __strong  strongSelf  = weakSelf;

                                      if (!strongSelf) {
                                          ANLogError(@"FAILED to establish strongSelf.");
                                          return;
                                      }

                                      NSInteger statusCode = -1;

                                      if (!self.fetcherMARManager) {
                                          [strongSelf restartAutoRefreshTimer];
                                      }

                                      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                          statusCode = [httpResponse statusCode];
                                      }

                                      if (statusCode >= 400 || statusCode == -1)
                                      {
                                          strongSelf.isFetcherLoading = NO;

                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              NSError  *sessionError  = nil;

                                              if (strongSelf.fetcherMARManager) {
                                                  sessionError = ANError(@"multi_ad_request_failed %@", ANAdResponseNetworkError, error.localizedDescription);
                                              } else {
                                                  sessionError = ANError(@"ad_request_failed %@", ANAdResponseNetworkError, error.localizedDescription);
                                              }
                                              ANLogError(@"%@", sessionError);

                                              ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithError:sessionError];
                                              [strongSelf processFinalResponse:response];
                                          });

                                      } else {
                                          strongSelf.isFetcherLoading = YES;

                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              NSString *responseString = [[NSString alloc] initWithData:data
                                                                                               encoding:NSUTF8StringEncoding];
                                              if (! strongSelf.fetcherMARManager) {
                                                  ANLogDebug(@"Response JSON (for single tag requests ONLY)... %@", responseString);
                                              }
                                                    //FIX proboem1

                                              ANPostNotifications(kANUniversalAdFetcherDidReceiveResponseNotification, strongSelf,
                                                                  @{kANUniversalAdFetcherAdResponseKey: (responseString ? responseString : @"")});

                                              [strongSelf handleAdServerResponse:data];
                                          });
                                      }   // ENDIF -- statusCode
                                  } ];

    [requestAdTask resume];
}




#pragma mark - Response processing methods.

/**
 * Start with raw data from a UT Response.
 * Transform the data into an array of dictionaries representing UT Response tags.
 *
 * If the fetcher is called by an ad unit, the process the tag with the existing fetcher.
 * If the fetcher is called in Multi-Ad Request Mode, then process each tag with fetcher from the ad unit that generated the tag.
 */
- (void)handleAdServerResponse:(NSData *)data
{
    NSArray<NSDictionary *>  *arrayOfTags  = [ANUniversalTagAdServerResponse generateTagsFromResponseData:data];

    if (!self.fetcherMARManager)
                //FIX -- problem2
    {
        // If the UT Response is for a single adunit only, there should only be one ad object.
        //
        if (arrayOfTags.count > 1) {
            ANLogWarn(@"UT Response contains MORE THAN ONE TAG (%@).  Using FIRST TAG ONLY and ignoring the rest...", @(arrayOfTags.count));
        }

        [self prepareForWaterfallWithAdServerResponseTag:[arrayOfTags firstObject]];

        return;

    } else {
        [self handleAdServerResponseForMultiAdRequest:arrayOfTags];
    }
}


/**
 * Accept a single tag from an UT Response.
 * Divide the tag into ad objects and begin to process them via the waterfall.
 */
- (void)prepareForWaterfallWithAdServerResponseTag: (NSDictionary<NSString *, id> *)tag
{
    if (!tag) {
        ANLogError(@"tag is nil.");
        [self finishRequestWithError:ANError(@"response_no_ads", ANAdResponseUnableToFill) andAdResponseInfo:nil];
        return;
    }

    if (tag[kANUniversalTagAdServerResponseKeyNoBid])
    {
        BOOL  noBid  = [tag[kANUniversalTagAdServerResponseKeyNoBid] boolValue];

        if (noBid) {
            ANLogWarn(@"response_no_ads");

            //
            ANAdResponseInfo *adResponseInfo = [[ANAdResponseInfo alloc] init];

            NSString *placementId  = @"";
            if(tag[kANUniversalTagAdServerResponseKeyAdsTagId] != nil)
            {
                placementId = [NSString stringWithFormat:@"%@",tag[kANUniversalTagAdServerResponseKeyAdsTagId]];
            }

            adResponseInfo.placementId = placementId;

            [self finishRequestWithError:ANError(@"response_no_ads", ANAdResponseUnableToFill) andAdResponseInfo:adResponseInfo];
            return;
        }
    }

    //
    NSMutableArray<id>  *ads            = [ANUniversalTagAdServerResponse generateAdObjectInstanceFromJSONAdServerResponseTag:tag];
    NSString            *noAdURLString  = tag[kANUniversalTagAdServerResponseKeyTagNoAdUrl];

    if (ads.count <= 0)
    {
        ANLogWarn(@"response_no_ads");
        [self finishRequestWithError:ANError(@"response_no_ads", ANAdResponseUnableToFill) andAdResponseInfo:nil];
        return;
    }
    
    if (noAdURLString) {
        self.noAdUrl = noAdURLString;
    }

    //
    [self beginWaterfallWithAdObjects:ads];
}

- (void) beginWaterfallWithAdObjects:(nonnull NSMutableArray<id> *)ads
{
    self.ads = ads;

    [self clearMediationController];
    [self continueWaterfall];
}


- (void)fireResponseURL:(nullable NSString *)urlString
                 reason:(ANAdResponseCode)reason
               adObject:(nonnull id)adObject
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
            self.isFetcherLoading = NO;
            return;
        }

        [self continueWaterfall];
    }
}


@end
