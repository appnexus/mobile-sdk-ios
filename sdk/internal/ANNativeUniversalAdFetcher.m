
#import "ANNativeUniversalAdFetcher.h"
#import "ANUniversalTagRequestBuilder.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANLogging.h"

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

@interface ANNativeUniversalAdFetcher()
@property (nonatomic, readwrite, strong)  NSMutableArray                    *ads;
@property (nonatomic, readwrite, strong)  NSString                          *noAdUrl;
@property (nonatomic, readwrite, weak)    id                                delegate;
@property (nonatomic, readwrite, assign)  NSTimeInterval                    totalLatencyStart;
@property (nonatomic, readwrite, getter=isLoading)  BOOL                    loading;
@property (nonatomic, readwrite, strong)  ANNativeMediatedAdController      *nativeMediationController;
@property (nonatomic, readwrite, strong)  id                                adObjectHandler;
@end

@implementation ANNativeUniversalAdFetcher

- (instancetype)initWithDelegate:(id)delegate{
    if (self = [self init]) {
        _delegate = delegate;
        [self setup];
    }
    return self;
}

- (void)setup{
    // TODO: add setup code
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
        
        ANNativeUniversalAdFetcher *__weak weakSelf = self;
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                      dataTaskWithRequest:request
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                          ANNativeUniversalAdFetcher *__strong strongSelf = weakSelf;
                                          
                                          if(!strongSelf){
                                              return;
                                          }
                                          NSInteger statusCode = -1;
                                          
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

- (void)clearMediationController {
    /*
     * Ad fetcher gets cleared, in the event the mediation controller lives beyond the ad fetcher.  The controller maintains a weak reference to the
     * ad fetcher delegate so that messages to the delegate can proceed uninterrupted.  Currently, the controller will only live on if it is still
     * displaying inside a banner ad view (in which case it will live on until the individual ad is destroyed).
     */
    //    self.mediationController.adFetcher = nil;
    //    self.mediationController = nil;
    
    self.nativeMediationController.adFetcher = nil;
    self.nativeMediationController = nil;
    
    //    self.ssmMediationController.adFetcher = nil;
    //    self.ssmMediationController = nil;
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

- (void)finishRequestWithError:(NSError *)error
{
    self.loading = NO;
    ANLogInfo(@"No ad received. Error: %@", error.localizedDescription);
    ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithError:error];
    [self processFinalResponse:response];
}

- (void)processFinalResponse:(ANAdFetcherResponse *)response
{
    self.ads = nil;
    self.loading = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFinishRequestWithResponse:)]) {
        [self.delegate didFinishRequestWithResponse:response];
    }
}

//NB  continueWaterfall is co-functional the ad handler methods.
//    The loop of the waterfall lifecycle is managed by methods calling one another
//      until a valid ad object is found OR when the waterfall runs out.
//
- (void)continueWaterfall
{
    // stop waterfall if delegate reference (adview) was lost
    if (!self.delegate) {
        self.loading = NO;
        return;
    }
    
    BOOL adsLeft = (self.ads.count > 0);
    
    if (!adsLeft) {
        ANLogWarn(@"response_no_ads");
        if (self.noAdUrl) {
            ANLogDebug(@"(no_ad_url, %@)", self.noAdUrl);
            [ANTrackerManager fireTrackerURL:self.noAdUrl];
        }
        [self finishRequestWithError:ANError(@"response_no_ads", ANAdResponseUnableToFill)];
        return;
    }
    
    
    //
    id nextAd = [self.ads firstObject];
    [self.ads removeObjectAtIndex:0];
    
    self.adObjectHandler = nextAd;
    
    
    if ( [nextAd isKindOfClass:[ANMediatedAd class]] ) {
        [self handleCSMSDKMediatedAd:nextAd];
    } else if ( [nextAd isKindOfClass:[ANNativeStandardAdResponse class]] ) {
        [self handleNativeStandardAd:nextAd];
    }else {
        ANLogError(@"Implementation error: Unspported ad in native ads waterfall.  (class=%@)", [nextAd class]);
        [self continueWaterfall]; // skip this ad an jump to next ad
    }
}

#pragma mark - Ad handlers.

- (void)handleCSMSDKMediatedAd:(ANMediatedAd *)mediatedAd
{
    if (mediatedAd.isAdTypeNative)
    {
        self.nativeMediationController = [ANNativeMediatedAdController initMediatedAd: mediatedAd
                                                                          withFetcher: self
                                                                    adRequestDelegate: self.delegate ];
    } else {
        // TODO: should do something here
    }
}

- (void)handleNativeStandardAd:(ANNativeStandardAdResponse *)nativeStandardAd
{
    
    ANAdFetcherResponse  *fetcherResponse  = [ANAdFetcherResponse responseWithAdObject:nativeStandardAd andAdObjectHandler:nil];
    [self processFinalResponse:fetcherResponse];
}

- (void)fireResponseURL:(NSString *)urlString
                 reason:(ANAdResponseCode)reason
               adObject:(id)adObject
              auctionID:(NSString *)auctionID
{
    
    if (urlString) {
        [ANTrackerManager fireTrackerURL:urlString];
    }
    
    if (reason == ANAdResponseSuccessful) {
        ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithAdObject:adObject andAdObjectHandler:self.adObjectHandler];
        
        response.auctionID = auctionID;
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
