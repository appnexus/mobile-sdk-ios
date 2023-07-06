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

#import "ANAdFetcher.h"
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
#import "ANNativeRenderingViewController.h"
#import "ANRTBNativeAdResponse.h"
#import "ANAdView+PrivateMethods.h"
#import "ANMultiAdRequest+PrivateMethods.h"
#import "ANVideoAdProcessor.h"



@interface ANAdFetcher() <     ANVideoAdProcessorDelegate,
                                        ANAdWebViewControllerLoadingDelegate,
                                        ANNativeRenderingViewControllerLoadingDelegate
                                    >

@property (nonatomic, readwrite, strong)  ANMRAIDContainerView              *adView;
@property (nonatomic, readwrite, strong)  ANNativeRenderingViewController   *nativeAdView;
@property (nonatomic, readwrite, strong)  ANMediationAdViewController       *mediationController;
@property (nonatomic, readwrite, strong)  ANNativeMediatedAdController      *nativeMediationController;
@property (nonatomic, readwrite, strong)  ANSSMMediationAdViewController    *ssmMediationController;

@property (nonatomic, readwrite, strong) NSTimer *autoRefreshTimer;

@end




#pragma mark -

@implementation ANAdFetcher

#pragma mark Lifecycle.

- (nonnull instancetype)initWithDelegate:(nonnull id)delegate
{
    self = [self init];
    if (!self)  { return nil; }

    //
    self.delegate = delegate;

    return  self;
}

- (void)dealloc
{
    [self stopAdLoad];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)clearMediationController
{
    /*
     * Ad fetcher gets cleared, in the event the mediation controller lives beyond the ad fetcher.  The controller maintains a weak reference to the
     * ad fetcher delegate so that messages to the delegate can proceed uninterrupted.  Currently, the controller will only live on if it is still
     * displaying inside a banner ad view (in which case it will live on until the individual ad is destroyed).
     */
    self.mediationController = nil;
    
    self.nativeMediationController = nil;
    
    self.ssmMediationController = nil;
}

#pragma mark - Ad Request

- (void)stopAdLoad
{
    [super stopAdLoad];
    [self clearMediationController];
    [self stopAutoRefreshTimer];
}




#pragma mark - Ad Response

- (void)finishRequestWithError:(NSError *)error andAdResponseInfo:(ANAdResponseInfo *)adResponseInfo
{
    self.isFetcherLoading = NO;
    
    NSTimeInterval interval = [self getAutoRefreshFromDelegate];
    if (interval > 0.0) {
        ANLogInfo(@"No ad received. Will request ad in %f seconds. Error: %@", interval, error.localizedDescription);
    } else {
        ANLogInfo(@"No ad received. Error: %@", error.localizedDescription);
    }
    
    ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithError:error];
    response.adResponseInfo = adResponseInfo;
    [self processFinalResponse:response];
}

- (void)processFinalResponse:(ANAdFetcherResponse *)response
{
    self.ads = nil;
    self.isFetcherLoading = NO;


    // MAR case.
    //
    if (self.fetcherMARManager)
    {
        if (!response.isSuccessful) {
            [self.fetcherMARManager internalMultiAdRequestDidFailWithError:response.error];
        } else {
            ANLogError(@"MultiAdRequest manager SHOULD NEVER CALL processFinalResponse, except on error.");
        }

        return;
    }


    // AdUnit case.
    //
    // Stop auto-refreush timer for video, but start it for everything else,
    //   unless it is the first pass for Lazy AdUnit.
    //
    if ([self.delegate respondsToSelector:@selector(adFetcher:didFinishRequestWithResponse:)]) {
        [self.delegate adFetcher:self didFinishRequestWithResponse:response];
    }

    if (    [response.adObject isKindOfClass:[ANMRAIDContainerView class]]
         && ((ANMRAIDContainerView *)response.adObject).isBannerVideo)
    {
        [self stopAutoRefreshTimer];
        return;
    }

    BOOL  isLazyLoadSecondPass  = [self.delegate respondsToSelector:@selector(valueOfIsLazySecondPassThroughAdUnit)] && [self.delegate valueOfIsLazySecondPassThroughAdUnit];
    if (!response.isLazy && !isLazyLoadSecondPass)
    {
        [self startAutoRefreshTimer];
    }
}

//NB  continueWaterfall is co-functional the ad handler methods.
//    The loop of the waterfall lifecycle is managed by methods calling one another
//      until a valid ad object is found OR when the waterfall runs out.
//
- (void)continueWaterfall:(ANAdResponseCode *)reason
{
    // stop waterfall if delegate reference was lost
    if (!self.delegate) {
        self.isFetcherLoading = NO;
        return;
    }
    
    BOOL adsLeft = (self.ads.count > 0);
    
    if (!adsLeft) {
         if (self.noAdUrl) {
              ANLogDebug(@"(no_ad_url, %@)", self.noAdUrl);
              [ANTrackerManager fireTrackerURL:self.noAdUrl];
          }
         [self finishRequestWithResponseCode:reason];
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
        [self handleNativeAd:nextAd];
        
    } else {
        ANLogError(@"Implementation error: Unknown ad in ads waterfall.  (class=%@)", [nextAd class]);
    }
}


#pragma mark - Auto refresh timer.

- (void)startAutoRefreshTimer
{
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

- (void)stopAutoRefreshTimer
{
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
        [self continueWaterfall:ANAdResponseCode.UNABLE_TO_FILL];
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

        BOOL  returnValue  = [self allocateAndSetWebviewWithSize:sizeOfWebView content:videoAd.content isXMLForVideo:YES];

        if (!returnValue) {
            ANLogError(@"FAILED to allocate self.adView.");
        }

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
    CGSize  sizeOfWebview  = [self getWebViewSizeForCreativeWidth: standardAd.width
                                                        andHeight: standardAd.height];

    
    //
    if ([self.delegate respondsToSelector:@selector(valueOfEnableLazyLoad)] && [self.delegate valueOfEnableLazyLoad])
    {
        ANAdFetcherResponse  *fetcherResponse  = [ANAdFetcherResponse lazyResponseWithAdObject: standardAd
                                                                            andAdObjectHandler: self.adObjectHandler ];
        [self processFinalResponse:fetcherResponse];

        return;
    }


    //
    BOOL  returnValue  = [self allocateAndSetWebviewWithSize:sizeOfWebview content:standardAd.content isXMLForVideo:NO];

    if (!returnValue) {
        ANLogError(@"FAILED to allocate self.adView.");
    }
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

- (void)handleNativeAd:(ANNativeStandardAdResponse *)nativeAd
{
    

    BOOL enableNativeRendering = NO;
    if ([self.delegate respondsToSelector:@selector(enableNativeRendering)]) {
        enableNativeRendering = [self.delegate enableNativeRendering];
        if (([nativeAd.nativeRenderingUrl length] > 0) && enableNativeRendering){
            ANRTBNativeAdResponse *rtnNativeAdResponse = [[ANRTBNativeAdResponse alloc] init];
            rtnNativeAdResponse.nativeAdResponse = nativeAd ;
            [self renderNativeAd:rtnNativeAdResponse];
            return;
        }
    }
    // Traditional native ad instance.
    [self traditionalNativeAd:nativeAd];
 
}

-(void)traditionalNativeAd:(ANNativeStandardAdResponse *)nativeAd{
    ANAdFetcherResponse  *fetcherResponse = [ANAdFetcherResponse responseWithAdObject:nativeAd andAdObjectHandler:nil];
    [self processFinalResponse:fetcherResponse];

}

-(void) renderNativeAd:(ANBaseAdObject *)nativeRenderingElement {
    
    CGSize sizeofWebView = [self getAdSizeFromDelegate];
    
    
    if (self.nativeAdView) {
        self.nativeAdView = nil;
    }
    
    self.nativeAdView = [[ANNativeRenderingViewController alloc] initWithSize:sizeofWebView BaseObject:nativeRenderingElement];
     self.nativeAdView.loadingDelegate = self;
}

- (void) checkifBeginToRenderAndFireImpressionTracker:(ANBaseAdObject *) ad {
    
    NSArray *mediaTypes = [self.delegate adAllowedMediaTypes];
    BOOL isBanner = (![mediaTypes containsObject:@(ANAllowedMediaTypeInterstitial)]);
    //fire the impression tracker earlier in the lifecycle. immediatley after creating the webView if it is Begin to Render
    if (isBanner && ad.impressionType == ANBeginToRender){
            ANLogDebug(@"Impression tracker fired on Begin To Render %@", ad.impressionUrls.firstObject);
            [ANTrackerManager fireTrackerURLArray:ad.impressionUrls withBlock:nil];
            ad.impressionUrls = nil;
        
        }
}


- (void) didFailToLoadNativeWebViewController{
    if ([self.adObjectHandler isKindOfClass:[ANNativeStandardAdResponse class]]) {
        ANNativeStandardAdResponse *nativeStandardAdResponse = (ANNativeStandardAdResponse *)self.adObjectHandler;
        [self traditionalNativeAd:nativeStandardAdResponse];
    }else{
        NSError  *error  = ANError(@"ANAdWebViewController is UNDEFINED.", ANAdResponseCode.INTERNAL_ERROR.code);
        ANAdFetcherResponse  *fetcherResponse = [ANAdFetcherResponse responseWithError:error];
        [self processFinalResponse:fetcherResponse];
    }
}

- (void) didCompleteFirstLoadFromNativeWebViewController:(ANNativeRenderingViewController *)controller{
    ANAdFetcherResponse  *fetcherResponse  = nil;

    if (self.nativeAdView == controller)
    {
        fetcherResponse = [ANAdFetcherResponse responseWithAdObject:controller andAdObjectHandler:self.adObjectHandler];
        [self processFinalResponse:fetcherResponse];
    } else {
        [self didFailToLoadNativeWebViewController];
    }
}


#pragma mark - ANAdFetcherDelegate.

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
        if (controller.videoAdOrientation) {
            if ([self.delegate respondsToSelector:@selector(setVideoAdOrientation:)]) {
                [self.delegate setVideoAdOrientation:controller.videoAdOrientation];
            }
        }
        
        if (controller.videoAdWidth) {
            if ([self.delegate respondsToSelector:@selector(setVideoAdWidth:)]) {
                [self.delegate setVideoAdWidth:controller.videoAdWidth];
            }
        }
        
        if (controller.videoAdHeight) {
            if ([self.delegate respondsToSelector:@selector(setVideoAdHeight:)]) {
                [self.delegate setVideoAdHeight:controller.videoAdHeight];
            }
        }

        fetcherResponse = [ANAdFetcherResponse responseWithAdObject: self.adView
                                                 andAdObjectHandler: self.adObjectHandler ];
         
    } else {
        NSError  *error  = ANError(@"ANAdWebViewController is UNDEFINED.", ANAdResponseCode.INTERNAL_ERROR.code);
        fetcherResponse = [ANAdFetcherResponse responseWithError:error];
    }

    //
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

- (void) videoAdProcessor:(nonnull ANVideoAdProcessor *)videoProcessor didFinishVideoProcessing: (nonnull ANVideoAdPlayer *)adVideo
{
        dispatch_async(dispatch_get_main_queue(), ^{
            ANAdFetcherResponse *adFetcherResponse = [ANAdFetcherResponse responseWithAdObject:adVideo andAdObjectHandler:self.adObjectHandler];
            [self processFinalResponse:adFetcherResponse];
        });
}

- (void) videoAdProcessor:(nonnull ANVideoAdProcessor *)videoAdProcessor didFailVideoProcessing: (nonnull NSError *)error
{
    [self continueWaterfall:ANAdResponseCode.UNABLE_TO_FILL];
}



#pragma mark - Helper methods.
// common for Banner / Interstitial RTB and SSM.
- (CGSize)getWebViewSizeForCreativeWidth:(nonnull NSString *)width
                               andHeight:(nonnull NSString *)height
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

/**
 *  Return: YES on success; otherwise NO.
 */
- (BOOL)allocateAndSetWebviewWithSize: (CGSize)webviewSize
                              content: (nonnull NSString *)webviewContent
                        isXMLForVideo: (BOOL)isContentXMLForVideo
{
    if (self.adView) {
        self.adView.loadingDelegate = nil;
    }

    //
    if (isContentXMLForVideo)
    {
        self.adView = [[ANMRAIDContainerView alloc] initWithSize: webviewSize
                                                        videoXML: webviewContent ];

    } else {
        
        ANStandardAd  *standardAd  = (ANStandardAd *)self.adObjectHandler;

        self.adView = [[ANMRAIDContainerView alloc] initWithSize: webviewSize
                                                            HTML: webviewContent
                                                  webViewBaseURL: [NSURL URLWithString:[[[ANSDKSettings sharedInstance] baseUrlConfig] webViewBaseUrl]] ];
        
        
        //TODO-Kowshick Will this cause trouble for Interstitial Imp Tracking
        [self checkifBeginToRenderAndFireImpressionTracker:standardAd];
        
        
    }

    if (!self.adView)
    {
        NSError  *error  = ANError(@"ANAdWebViewController is UNDEFINED.", ANAdResponseCode.INTERNAL_ERROR.code);
        ANAdFetcherResponse  *fetcherResponse = [ANAdFetcherResponse responseWithError:error];
        [self processFinalResponse:fetcherResponse];

        return  NO;
    }

    //
    self.adView.loadingDelegate = self;

    // Allow ANJAM events to always be passed to the ANAdView
    self.adView.webViewController.adViewANJAMInternalDelegate = self.delegate;

    return  YES;
}

- (BOOL)allocateAndSetWebviewFromCachedAdObjectHandler
{
    ANStandardAd  *lazyStandardAd  = (ANStandardAd *)self.adObjectHandler;

    CGSize         sizeOfWebview   = [self getWebViewSizeForCreativeWidth: lazyStandardAd.width
                                                                andHeight: lazyStandardAd.height];

    // Optimistically restart activated autorefresh timer.
    // Successful load of lazy AdUnit webview will stop autorefresh timer.
    //
    [self restartAutoRefreshTimer];
    [self startAutoRefreshTimer];
    
    
    return  [self allocateAndSetWebviewWithSize: sizeOfWebview
                                        content: lazyStandardAd.content
                                  isXMLForVideo: NO ];
}


@end
