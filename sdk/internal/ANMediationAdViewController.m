/*   Copyright 2013 APPNEXUS INC
 
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

#import "ANMediationAdViewController.h"
#import "ANAdConstants.h"

#import "ANBannerAdView.h"
#import "ANInterstitialAd.h"
#import "ANLogging.h"
#import "ANMediatedAd.h"
#import "ANPBBuffer.h"
#import "NSString+ANCategory.h"
#import "ANPBContainerView.h"
#import "ANMediationContainerView.h"
#import "NSObject+ANCategory.h"



@interface ANMediationAdViewController () <ANCustomAdapterBannerDelegate, ANCustomAdapterInterstitialDelegate>

@property (nonatomic, readwrite, strong)  ANMediatedAd                      *mediatedAd;

@property (nonatomic, readwrite, strong)  id<ANCustomAdapter>                currentAdapter;
@property (nonatomic, readwrite, assign)  BOOL                               hasSucceeded;
@property (nonatomic, readwrite, assign)  BOOL                               hasFailed;
@property (nonatomic, readwrite, assign)  BOOL                               timeoutCanceled;

@property (nonatomic, readwrite, weak)    id<ANUniversalAdFetcherDelegate>   adViewDelegate;

@property (nonatomic, readwrite, strong)  NSDictionary                      *pitbullAdForDelayedCapture;

// variables for measuring latency.
@property (nonatomic, readwrite, assign)  NSTimeInterval  latencyStart;
@property (nonatomic, readwrite, assign)  NSTimeInterval  latencyStop;

@property (nonatomic, readwrite, assign)  BOOL  isRegisteredForPitbullScreenCaptureNotifications;

@end

@implementation ANMediationAdViewController

#pragma mark - Lifecycle.

+ (ANMediationAdViewController *)initMediatedAd:(ANMediatedAd *)mediatedAd
                                    withFetcher:(ANUniversalAdFetcher *)adFetcher
                                 adViewDelegate:(id<ANUniversalAdFetcherDelegate>)adViewDelegate
{

    ANMediationAdViewController *controller = [[ANMediationAdViewController alloc] init];
    controller.adFetcher = adFetcher;
    controller.adViewDelegate = adViewDelegate;
    
    if ([controller requestForAd:mediatedAd]) {
        return controller;
    } else {
        return nil;
    }
}

- (BOOL)requestForAd:(ANMediatedAd *)ad {

    // variables to pass into the failure handler if necessary
    NSString *className = nil;
    NSString *errorInfo = nil;
    ANAdResponseCode errorCode = ANDefaultCode;
    
    do {
        // check that the ad is non-nil
        if (!ad) {
            errorInfo = @"null mediated ad object";
            errorCode = ANAdResponseUnableToFill;
            break;
        }
        
        self.mediatedAd = ad;
        className = ad.className;
        
        // notify that a mediated class name was received
        ANPostNotifications(kANUniversalAdFetcherWillInstantiateMediatedClassNotification, self,
                            @{kANUniversalAdFetcherMediatedClassKey: className});
        
        ANLogDebug(@"instantiating_class %@", className);
        
        // check to see if an instance of this class exists
        Class adClass = NSClassFromString(className);
        if (!adClass) {
            errorInfo = @"ClassNotFoundError";
            errorCode = ANAdResponseMediatedSDKUnavailable;
            break;
        }
        
        id adInstance = [[adClass alloc] init];
        if (!adInstance
            || ![adInstance respondsToSelector:@selector(setDelegate:)]
            || ![adInstance conformsToProtocol:@protocol(ANCustomAdapter)]) {
            errorInfo = @"InstantiationError";
            errorCode = ANAdResponseMediatedSDKUnavailable;
            break;
        }
        
        // instance valid - request a mediated ad
        id<ANCustomAdapter> adapter = (id<ANCustomAdapter>)adInstance;
        adapter.delegate = self;
        self.currentAdapter = adapter;
        
        // Grab the size of the ad - interstitials will ignore this value
        CGSize sizeOfCreative = CGSizeMake([ad.width floatValue], [ad.height floatValue]);
        
        BOOL requestedSuccessfully = [self requestAd:sizeOfCreative
                                     serverParameter:ad.param
                                            adUnitId:ad.adId
                                              adView:self.adViewDelegate];
        
        if (!requestedSuccessfully) {
            // don't add class to invalid networks list for this failure
            className = nil;
            errorInfo = @"ClassCastError";
            errorCode = ANAdResponseMediatedSDKUnavailable;
            break;
        }
        
    } while (false);
    
    
    if (errorCode != ANDefaultCode) {
        [self handleInstantiationFailure: className
                               errorCode: errorCode
                               errorInfo: errorInfo ];
        return NO;
    }
    
    // otherwise, no error yet
    // wait for a mediation adapter to hit one of our callbacks.
    return YES;
}


- (void)handleInstantiationFailure:(NSString *)className
                         errorCode:(ANAdResponseCode)errorCode
                         errorInfo:(NSString *)errorInfo
{
    if ([errorInfo length] > 0) {
        ANLogError(@"mediation_instantiation_failure %@", errorInfo);
    }

    [self didFailToReceiveAd:errorCode];
}


- (void)setAdapter:adapter {
    self.currentAdapter = adapter;
}


- (void)clearAdapter {
    if (self.currentAdapter) {
        self.currentAdapter.delegate = nil;
    }
    self.currentAdapter = nil;
    self.hasSucceeded = NO;
    self.hasFailed = YES;
    self.adFetcher = nil;
    self.adViewDelegate = nil;
    self.mediatedAd = nil;

    [self cancelTimeout];

    ANLogInfo(@"mediation_finish");
}

- (BOOL)requestAd:(CGSize)size
  serverParameter:(NSString *)parameterString
         adUnitId:(NSString *)idString
           adView:(id<ANUniversalAdFetcherDelegate>)adView
{
    ANTargetingParameters *targetingParameters = [[ANTargetingParameters alloc] init];
    
    NSMutableDictionary<NSString *, NSString *>  *customKeywordsAsStrings  = [ANGlobal convertCustomKeywordsAsMapToStrings: adView.customKeywords
                                                                                                       withSeparatorString: @"," ];


    targetingParameters.customKeywords    = customKeywordsAsStrings;
    targetingParameters.age               = adView.age;
    targetingParameters.externalUid       = adView.externalUid;
    targetingParameters.gender            = adView.gender;
    targetingParameters.location          = adView.location;
    targetingParameters.idforadvertising  = ANUDID();
    
    //
    if ([adView isKindOfClass:[ANBannerAdView class]]) {
        // make sure the container and protocol match
        if (    [[self.currentAdapter class] conformsToProtocol:@protocol(ANCustomAdapterBanner)]
             && [self.currentAdapter respondsToSelector:@selector(requestBannerAdWithSize:rootViewController:serverParameter:adUnitId:targetingParameters:)])
        {
            
            [self markLatencyStart];
            [self startTimeout];
            
            ANBannerAdView *banner = (ANBannerAdView *)adView;
            id<ANCustomAdapterBanner> bannerAdapter = (id<ANCustomAdapterBanner>) self.currentAdapter;
            [bannerAdapter requestBannerAdWithSize:size
                                rootViewController:banner.rootViewController
                                   serverParameter:parameterString
                                          adUnitId:idString
                               targetingParameters:targetingParameters];
            return YES;
        } else {
            ANLogError(@"instance_exception %@", @"CustomAdapterBanner");
        }
        
    } else if ([adView isKindOfClass:[ANInterstitialAd class]]) {
        // make sure the container and protocol match
        if (    [[self.currentAdapter class] conformsToProtocol:@protocol(ANCustomAdapterInterstitial)]
            && [self.currentAdapter respondsToSelector:@selector(requestInterstitialAdWithParameter:adUnitId:targetingParameters:)])
        {
            
            [self markLatencyStart];
            [self startTimeout];
            
            id<ANCustomAdapterInterstitial> interstitialAdapter = (id<ANCustomAdapterInterstitial>) self.currentAdapter;
            [interstitialAdapter requestInterstitialAdWithParameter:parameterString
                                                           adUnitId:idString
                                                targetingParameters:targetingParameters];
            return YES;
        } else {
            ANLogError(@"instance_exception %@", @"CustomAdapterInterstitial");
        }
        
    } else {
        ANLogError(@"UNRECOGNIZED Entry Point classname.  (%@)", [adView class]);
    }
    
    
    // executes iff request was unsuccessful
    return NO;
}



#pragma mark - ANCustomAdapterBannerDelegate

- (void)didLoadBannerAd:(UIView *)view {
    [self didReceiveAd:view];
}



#pragma mark - ANCustomAdapterInterstitialDelegate

- (void)didLoadInterstitialAd:(id<ANCustomAdapterInterstitial>)adapter {
    [self didReceiveAd:adapter];
}



#pragma mark - ANCustomAdapterDelegate

- (void)didFailToLoadAd:(ANAdResponseCode)errorCode {
    [self didFailToReceiveAd:errorCode];
}

- (void)adWasClicked {
    if (self.hasFailed) return;
    [self runInBlock:^(void) {
        [self.adViewDelegate adWasClicked];
    }];
}

- (void)willPresentAd {
    if (self.hasFailed) return;
    [self runInBlock:^(void) {
        [self.adViewDelegate adWillPresent];
    }];
}

- (void)didPresentAd {
    if (self.hasFailed) return;
    [self runInBlock:^(void) {
        [self.adViewDelegate adDidPresent];
    }];
}

- (void)willCloseAd {
    if (self.hasFailed) return;
    [self runInBlock:^(void) {
        [self.adViewDelegate adWillClose];
    }];
}

- (void)didCloseAd {
    if (self.hasFailed) return;
    [self runInBlock:^(void) {
        [self.adViewDelegate adDidClose];
    }];
}

- (void)willLeaveApplication {
    if (self.hasFailed) return;
    [self runInBlock:^(void) {
        [self.adViewDelegate adWillLeaveApplication];
    }];
}

- (void)failedToDisplayAd {
    if (self.hasFailed) return;
    [self runInBlock:^(void) {
        if ([self.adViewDelegate conformsToProtocol:@protocol(ANInterstitialAdViewInternalDelegate)]) {
            id<ANInterstitialAdViewInternalDelegate> interstitialDelegate = (id<ANInterstitialAdViewInternalDelegate>)self.adViewDelegate;
            [interstitialDelegate adFailedToDisplay];
        }
    }];
}



#pragma mark - helper methods

- (BOOL)checkIfHasResponded {
    // we received a callback from mediation adaptor, cancel timeout
    [self cancelTimeout];
    // don't succeed or fail more than once per mediated ad
    return (self.hasSucceeded || self.hasFailed);
}

- (void)didReceiveAd:(id)adObject
{
    if ([self checkIfHasResponded])  { return; }
    
    if (!adObject) {
        [self didFailToReceiveAd:ANAdResponseInternalError];
        return;
    }
    
    //
    self.hasSucceeded = YES;
    [self markLatencyStop];
    
    ANLogDebug(@"received an ad from the adapter");
    
    if ([adObject isKindOfClass:[UIView class]]) {
        UIView *adView = (UIView *)adObject;
        ANMediationContainerView *containerView = [[ANMediationContainerView alloc] initWithMediatedView:adView];
        containerView.controller = self;
        adObject = containerView;
    }
    
    // save auctionInfo for the winning ad
    NSString *auctionID = [ANPBBuffer saveAuctionInfo:self.mediatedAd.auctionInfo];
    
    if (auctionID) {
        [ANPBBuffer addAdditionalInfo:@{kANPBBufferMediatedNetworkNameKey: self.mediatedAd.className,
                                        kANPBBufferMediatedNetworkPlacementIDKey: self.mediatedAd.adId}
                         forAuctionID:auctionID];
        if ([adObject isKindOfClass:[UIView class]]) {
            UIView *adView = (UIView *)adObject;
            [ANPBBuffer addAdditionalInfo:@{kANPBBufferAdWidthKey: @(CGRectGetWidth(adView.frame)),
                                            kANPBBufferAdHeightKey: @(CGRectGetHeight(adView.frame))}
                             forAuctionID:auctionID];
            ANPBContainerView *containerView = [[ANPBContainerView alloc] initWithContentView:adView];
            adObject = containerView;
        }
    }
    
    [self finish:ANAdResponseSuccessful withAdObject:adObject auctionID:auctionID];
    
    // if auctionInfo was present and had an auctionID,
    // screenshot the view. For banners, do it here
    if (auctionID && [adObject isKindOfClass:[UIView class]]) {
        if ([self.adViewDelegate respondsToSelector:@selector(transitionInProgress)]) {
            NSNumber *transitionInProgress = [self.adViewDelegate performSelector:@selector(transitionInProgress)];
            if ([transitionInProgress boolValue] == YES) {
                self.pitbullAdForDelayedCapture = @{auctionID: adObject};
                [self registerForPitbullScreenCaptureNotifications];
            }
        }
        
        if (!self.pitbullAdForDelayedCapture) {
            [ANPBBuffer captureDelayedImage:adObject forAuctionID:auctionID];
        }
    }
}

- (void)didFailToReceiveAd:(ANAdResponseCode)errorCode {

    if ([self checkIfHasResponded]) return;
    [self markLatencyStop];
    self.hasFailed = YES;
    [self finish:errorCode withAdObject:nil auctionID:nil];
}


- (void)finish: (ANAdResponseCode)errorCode
  withAdObject: (id)adObject
     auctionID: (NSString *)auctionID
{

    // use queue to force return
    [self runInBlock:^(void) {
        ANUniversalAdFetcher *fetcher = self.adFetcher;
        
        NSString *responseURL = [self.mediatedAd.responseURL an_responseTrackerReasonCode:errorCode
                                                                                  latency: ([self getLatency] * 1000)
                                                                             totalLatency:([self getTotalLatency] * 1000)];
        
        // fireResponseURL will clear the adapter if fetcher exists
        if (!fetcher) {
            [self clearAdapter];
        }
        [fetcher fireResponseURL:responseURL reason:errorCode adObject:adObject auctionID:auctionID];
    }];
}




#pragma mark - Timeout handler

- (void)startTimeout {

    if (self.timeoutCanceled) return;
    __weak ANMediationAdViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 kAppNexusMediationNetworkTimeoutInterval
                                 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
                       ANMediationAdViewController *strongSelf = weakSelf;
                       if (!strongSelf || strongSelf.timeoutCanceled) return;
                       ANLogWarn(@"mediation_timeout");
                       [strongSelf didFailToReceiveAd:ANAdResponseInternalError];
                   });
    
}

- (void)cancelTimeout {

    self.timeoutCanceled = YES;
}



# pragma mark - Latency Measurement

/**
 * Should be called immediately after mediated SDK returns
 * from `requestAd` call.
 */
- (void)markLatencyStart {

    self.latencyStart = [NSDate timeIntervalSinceReferenceDate];
}

/**
 * Should be called immediately after mediated SDK
 * calls either of `onAdLoaded` or `onAdFailed`.
 */
- (void)markLatencyStop {

    self.latencyStop = [NSDate timeIntervalSinceReferenceDate];
}

/**
 * The latency of the call to the mediated SDK.
 */
- (NSTimeInterval)getLatency {

    if ((self.latencyStart > 0) && (self.latencyStop > 0)) {
        return (self.latencyStop - self.latencyStart);
    }
    // return -1 if invalid.
    return -1;
}

/**
 * The running total latency of the ad call.
 */
- (NSTimeInterval)getTotalLatency {

    if (self.adFetcher && (self.latencyStop > 0)) {
        return [self.adFetcher getTotalLatency:self.latencyStop];
    }
    return -1;
}



#pragma mark - Pitbull Image Capture Transition Adjustments

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.adViewDelegate) {
        NSNumber *transitionInProgress = change[NSKeyValueChangeNewKey];
        if ([transitionInProgress boolValue] == NO) {
            [self unregisterFromPitbullScreenCaptureNotifications];
            [self dispatchPitbullScreenCapture];
        }
    }
}

- (void)registerForPitbullScreenCaptureNotifications {
    if (!self.isRegisteredForPitbullScreenCaptureNotifications) {
        NSObject *object = self.adViewDelegate;
        [object addObserver:self
                 forKeyPath:@"transitionInProgress"
                    options:NSKeyValueObservingOptionNew
                    context:nil];
        self.isRegisteredForPitbullScreenCaptureNotifications = YES;
    }
}

- (void)unregisterFromPitbullScreenCaptureNotifications {
    if (self.isRegisteredForPitbullScreenCaptureNotifications) {
        NSObject *object = self.adViewDelegate;
        @try {
            [object removeObserver:self
                        forKeyPath:@"transitionInProgress"];
        }
        @catch (NSException * __unused exception) {}
        self.isRegisteredForPitbullScreenCaptureNotifications = NO;
    }
}

- (void)dispatchPitbullScreenCapture {
    if (self.pitbullAdForDelayedCapture) {
        [self.pitbullAdForDelayedCapture enumerateKeysAndObjectsUsingBlock:^(NSString *auctionID, UIView *view, BOOL *stop) {
            [ANPBBuffer captureImage:view
                        forAuctionID:auctionID];
        }];
        self.pitbullAdForDelayedCapture = nil;
    }
}

- (void)dealloc {

    [self clearAdapter];
    [self unregisterFromPitbullScreenCaptureNotifications];
}

@end

