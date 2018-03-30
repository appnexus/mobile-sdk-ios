/*   Copyright 2015 APPNEXUS INC
 
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

#import "ANUniversalAdFetcher.h"
#import "ANLogging.h"
#import "ANUniversalTagRequestBuilder.h"

#import "ANStandardAd.h"
#import "ANRTBVideoAd.h"
#import "ANCSMVideoAd.h"
#import "ANSSMStandardAd.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANNativeStandardAdResponse.h"

#import "ANMRAIDContainerView.h"
#import "ANMediatedAd.h"
#import "ANMediationAdViewController.h"
#import "ANNativeMediatedAdController.h"
#import "ANSSMMediationAdViewController.h"
#import "ANTrackerInfo.h"
#import "ANTrackerManager.h"
#import "NSTimer+ANCategory.h"




@interface ANUniversalAdFetcher () <ANVideoAdProcessorDelegate, ANAdWebViewControllerLoadingDelegate, ANNativeMediationAdControllerDelegate>


@property (nonatomic, readwrite, strong)  NSMutableArray   *ads;
@property (nonatomic, readwrite, strong)  NSString         *noAdUrl;
@property (nonatomic, readwrite, assign)  NSTimeInterval    totalLatencyStart;
@property (nonatomic, readwrite, strong)  id                adObjectHandler;

@property (nonatomic, readwrite, getter=isLoading)  BOOL    loading;


// NB  Protocol type of delegate can be ANUniversalAdFetcherDelegate or ANUniversalNativeAdFetcherDelegate.
//
@property (nonatomic, readwrite, weak)    id  delegate;

@property (nonatomic, readwrite, strong)  ANMRAIDContainerView              *adView;
@property (nonatomic, readwrite, strong)  ANMediationAdViewController       *mediationController;
@property (nonatomic, readwrite, strong)  ANNativeMediatedAdController      *nativeMediationController;
@property (nonatomic, readwrite, strong)  ANSSMMediationAdViewController    *ssmMediationController;

@property (nonatomic, readwrite, strong) NSTimer *autoRefreshTimer;

@end




@implementation ANUniversalAdFetcher

#pragma mark - Lifecycle.

- (instancetype)initWithDelegate: (id)delegate
{
    if (self = [self init]) {
        _delegate = delegate;
        [self setup];
    }
    return self;
}

- (void)setup
{
    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
}

- (void)dealloc {
    [self stopAdLoad];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)clearMediationController {
    /*
     * Ad fetcher gets cleared, in the event the mediation controller lives beyond the ad fetcher.  The controller maintains a weak reference to the
     * ad fetcher delegate so that messages to the delegate can proceed uninterrupted.  Currently, the controller will only live on if it is still
     * displaying inside a banner ad view (in which case it will live on until the individual ad is destroyed).
     */
    self.mediationController.adFetcher = nil;
    self.mediationController = nil;
    
    self.nativeMediationController.adFetcher = nil;
    self.nativeMediationController = nil;
    
    self.ssmMediationController.adFetcher = nil;
    self.ssmMediationController = nil;
}




#pragma mark - Ad Request

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
        
        ANUniversalAdFetcher *__weak weakSelf = self;
    
        NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                      dataTaskWithRequest:request
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                          ANUniversalAdFetcher *__strong strongSelf = weakSelf;
                                          
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

- (void)stopAdLoad
{
    [self stopAutoRefreshTimer];
    self.loading = NO;
    self.ads = nil;
    [self clearMediationController];
}




#pragma mark - Ad Response

- (void)processAdServerResponse:(ANUniversalTagAdServerResponse *)response
{
    BOOL containsAds = (response.ads != nil) && (response.ads.count > 0);
    
    if (!containsAds) {
        ANLogWarn(@"response_no_ads");
        [self finishRequestWithErrorAndRefresh:ANError(@"response_no_ads", ANAdResponseUnableToFill)];
        return;
    }
    
    if (response.noAdUrlString) {
        self.noAdUrl = response.noAdUrlString;
    }
    self.ads = response.ads;
    
    [self clearMediationController];
    [self continueWaterfall];
}

- (void)finishRequestWithErrorAndRefresh:(NSError *)error
{
    self.loading = NO;
    
    NSTimeInterval interval = [self getAutoRefreshFromDelegate];
    if (interval > 0.0) {
        ANLogInfo(@"No ad received. Will request ad in %f seconds. Error: %@", interval, error.localizedDescription);
    } else {
        ANLogInfo(@"No ad received. Error: %@", error.localizedDescription);
    }
    
    ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithError:error];
    [self processFinalResponse:response];
}

- (void)processFinalResponse:(ANAdFetcherResponse *)response
{
    self.ads = nil;
    self.loading = NO;
    
    if ([self.delegate respondsToSelector:@selector(universalAdFetcher:didFinishRequestWithResponse:)]) {
        [self.delegate universalAdFetcher:self didFinishRequestWithResponse:response];
    }

    if ([response.adObject isKindOfClass:[ANMRAIDContainerView class]]) {
        if (((ANMRAIDContainerView *)response.adObject).isBannerVideo) {
            [self stopAutoRefreshTimer];
            return;
        }
    }

    [self startAutoRefreshTimer];
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
        [self finishRequestWithErrorAndRefresh:ANError(@"response_no_ads", ANAdResponseUnableToFill)];
        return;
    }
    
    
    //
    id nextAd = [self.ads firstObject];
    [self.ads removeObjectAtIndex:0];
    
    self.adObjectHandler = nextAd;
    
    
    if ([nextAd isKindOfClass:[ANRTBVideoAd class]]) {
        [self handleRTBVideoAd:nextAd];
        
    } else if([nextAd isKindOfClass:[ANCSMVideoAd class]]){
        [self handleCSMVideoAd:nextAd];
        
    } else if ( [nextAd isKindOfClass:[ANStandardAd class]] ) {
        [self handleStandardAd:nextAd];
        
    } else if ( [nextAd isKindOfClass:[ANMediatedAd class]] ) {
        [self handleCSMSDKMediatedAd:nextAd];
        
    } else if ( [nextAd isKindOfClass:[ANSSMStandardAd class]] ) {
        [self handleSSMMediatedAd:nextAd];
        
    } else if ( [nextAd isKindOfClass:[ANNativeStandardAdResponse class]] ) {
        [self handleNativeStandardAd:nextAd];
        
    } else {
        ANLogError(@"Implementation error: Unknown ad in ads waterfall.  (class=%@)", [nextAd class]);
    }
}




#pragma mark - Auto refresh timer.

- (void) startAutoRefreshTimer
{
ANLogMark();
    if (!self.autoRefreshTimer) {
        ANLogDebug(@"fetcher_stopped");
    } else if ([self.autoRefreshTimer an_isScheduled]) {
        ANLogDebug(@"AutoRefresh timer already scheduled.");
    } else {
        [self.autoRefreshTimer an_scheduleNow];
    }
}

// NB  Invocation of this method MUST ALWAYS be followed by invocation of startAutoRefreshTimer.
//
- (void)restartAutoRefreshTimer
{
ANLogMark();
    // stop old autoRefreshTimer
    [self stopAutoRefreshTimer];

    // setup new autoRefreshTimer if refresh interval positive
    NSTimeInterval interval = [self getAutoRefreshFromDelegate];
    if (interval > 0.0f)
    {
        self.autoRefreshTimer = [NSTimer timerWithTimeInterval:interval
                                                        target:self
                                                      selector:@selector(autoRefreshTimerDidFire:)
                                                      userInfo:nil
                                                       repeats:NO];
    }
}

- (void) stopAutoRefreshTimer
{
ANLogMark();
    [self.autoRefreshTimer invalidate];
    self.autoRefreshTimer = nil;
}

- (void)autoRefreshTimerDidFire:(NSTimer *)timer
{
    [self stopAdLoad];
    [self requestAd];
}

- (NSTimeInterval)getAutoRefreshFromDelegate {
    if ([self.delegate respondsToSelector:@selector(autoRefreshIntervalForAdFetcher:)]) {
        return [self.delegate autoRefreshIntervalForAdFetcher:self];
    }

    return  0.0f;
}




#pragma mark - Ad handlers.

// VAST ad.
//
- (void)handleRTBVideoAd:(ANRTBVideoAd *)videoAd
{
    if (!videoAd.assetURL && !videoAd.content) {
        [self continueWaterfall];
    }
    
    NSString *notifyUrlString = videoAd.notifyUrlString;
    
    if (notifyUrlString.length > 0) {
        ANLogDebug(@"(notify_url, %@)", notifyUrlString);
        [ANTrackerManager fireTrackerURL:notifyUrlString];
    }

    ANVideoAdSubtype  videoAdType  = ANVideoAdSubtypeUnknown;
    if ([self.delegate respondsToSelector:@selector(videoAdTypeForAdFetcher:)]) {
        videoAdType = [self.delegate videoAdTypeForAdFetcher:self];
    }

    if (ANVideoAdSubtypeBannerVideo == videoAdType)
    {
        CGSize  sizeOfWebView  = [self getWebViewSizeForCreativeWidth:videoAd.width andHeight:videoAd.height];

        self.adView = [[ANMRAIDContainerView alloc] initWithSize: sizeOfWebView
                                                        videoXML: videoAd.content ];

        self.adView.loadingDelegate = self;
        // Allow ANJAM events to always be passed to the ANAdView
        self.adView.webViewController.adViewANJAMDelegate = self.delegate;

    } else {
        if (! [[ANVideoAdProcessor alloc] initWithDelegate: self
                                        withAdVideoContent: videoAd ] )
        {
            ANLogError(@"FAILED to create ANVideoAdProcessor object.");
        }
    }
}



// Video ad.
//
-(void) handleCSMVideoAd:(ANCSMVideoAd *) videoAd
{
    if (! [[ANVideoAdProcessor alloc] initWithDelegate:self withAdVideoContent:videoAd])  {
        ANLogError(@"FAILED to create ANVideoAdProcessor object.");
    }
}


- (void)handleStandardAd:(ANStandardAd *)standardAd
{
    CGSize sizeofWebView = [self getWebViewSizeForCreativeWidth:standardAd.width
                                                      andHeight:standardAd.height];
    
    if (self.adView) {
        self.adView.loadingDelegate = nil;
    }
    
    self.adView = [[ANMRAIDContainerView alloc] initWithSize:sizeofWebView
                                                        HTML:standardAd.content
                                              webViewBaseURL:[NSURL URLWithString:[[[ANSDKSettings sharedInstance] baseUrlConfig] webViewBaseUrl]]];
    self.adView.loadingDelegate = self;
    // Allow ANJAM events to always be passed to the ANAdView
    self.adView.webViewController.adViewANJAMDelegate = self.delegate;
    
}


- (void)handleCSMSDKMediatedAd:(ANMediatedAd *)mediatedAd
{
    if (mediatedAd.isAdTypeNative)
    {
        self.nativeMediationController = [ANNativeMediatedAdController initMediatedAd: mediatedAd
                                                                          withFetcher: self
                                                                    adRequestDelegate: self.delegate ];
    } else {
        self.mediationController = [ANMediationAdViewController initMediatedAd: mediatedAd
                                                                   withFetcher: self
                                                                adViewDelegate: self.delegate];
    }
}


- (void)handleSSMMediatedAd:(ANSSMStandardAd *)mediatedAd
{
    self.ssmMediationController = [ANSSMMediationAdViewController initMediatedAd:mediatedAd
                                                                     withFetcher:self
                                                                  adViewDelegate:self.delegate];
}

- (void)handleNativeStandardAd:(ANNativeStandardAdResponse *)nativeStandardAd
{
    
    ANAdFetcherResponse  *fetcherResponse  = [ANAdFetcherResponse responseWithAdObject:nativeStandardAd andAdObjectHandler:nil];
    [self processFinalResponse:fetcherResponse];
}



#pragma mark - ANUniversalAdFetcherDelegate.

- (CGSize) getAdSizeFromDelegate
{
    if ([self.delegate respondsToSelector:@selector(requestedSizeForAdFetcher:)]) {
        return [self.delegate requestedSizeForAdFetcher:self];
    }
    return CGSizeZero;
}




#pragma mark - ANAdWebViewControllerLoadingDelegate.

- (void) didCompleteFirstLoadFromWebViewController:(ANAdWebViewController *)controller
{
    ANAdFetcherResponse  *fetcherResponse  = nil;

    if (self.adView.webViewController == controller)
    {
        fetcherResponse = [ANAdFetcherResponse responseWithAdObject:self.adView andAdObjectHandler:self.adObjectHandler];

    } else {
        NSError  *error  = ANError(@"ANAdWebViewController is UNDEFINED.", ANAdResponseInternalError);
        fetcherResponse = [ANAdFetcherResponse responseWithError:error];
    }

    [self processFinalResponse:fetcherResponse];
}

- (void) immediatelyRestartAutoRefreshTimerFromWebViewController:(ANAdWebViewController *)controller
{
    [self autoRefreshTimerDidFire:nil];

}

- (void) stopAutoRefreshTimerFromWebViewController:(ANAdWebViewController *)controller
{
    [self stopAutoRefreshTimer];
}




#pragma mark - ANVideoAdProcessor delegate

- (void) videoAdProcessor:(ANVideoAdProcessor *)videoProcessor didFinishVideoProcessing: (ANVideoAdPlayer *)adVideo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            ANAdFetcherResponse *adFetcherResponse = [ANAdFetcherResponse responseWithAdObject:adVideo andAdObjectHandler:self.adObjectHandler];
            [self processFinalResponse:adFetcherResponse];
        });
    });
}

- (void) videoAdProcessor:(ANVideoAdProcessor *)videoProcessor didFailVideoProcessing: (NSError *)error
{
    [self continueWaterfall];
}



#pragma mark - Helper methods.

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


// common for Banner / Interstitial RTB and SSM.
-(CGSize)getWebViewSizeForCreativeWidth:(NSString *)width
                              andHeight:(NSString *)height
{
    
    // Compare the size of the received impression with what the requested ad size is. If the two are different, send the ad delegate a message.
    CGSize receivedSize = CGSizeMake([width floatValue], [height floatValue]);
    CGSize requestedSize = [self getAdSizeFromDelegate];
    
    CGRect receivedRect = CGRectMake(CGPointZero.x, CGPointZero.y, receivedSize.width, receivedSize.height);
    CGRect requestedRect = CGRectMake(CGPointZero.x, CGPointZero.y, requestedSize.width, requestedSize.height);
    
    if (!CGRectContainsRect(requestedRect, receivedRect)) {
        ANLogInfo(@"adsize_too_big %d%d%d%d",   (int)receivedRect.size.width,  (int)receivedRect.size.height,
                  (int)requestedRect.size.width, (int)requestedRect.size.height );
    }
    
    CGSize sizeOfCreative = (    (receivedSize.width > 0)
                             && (receivedSize.height > 0)) ? receivedSize : requestedSize;
    
    return sizeOfCreative;
}

@end
