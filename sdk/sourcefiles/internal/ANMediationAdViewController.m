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
#import "NSString+ANCategory.h"
#import "ANMediationContainerView.h"
#import "NSObject+ANCategory.h"



@interface ANMediationAdViewController () <ANCustomAdapterBannerDelegate, ANCustomAdapterInterstitialDelegate>

@property (nonatomic, readwrite, strong)  ANMediatedAd                      *mediatedAd;

@property (nonatomic, readwrite, strong)  id<ANCustomAdapter>                currentAdapter;
@property (nonatomic, readwrite, assign)  BOOL                               hasSucceeded;
@property (nonatomic, readwrite, assign)  BOOL                               hasFailed;
@property (nonatomic, readwrite, assign)  BOOL                               timeoutCanceled;

@property (nonatomic, readwrite, weak)    id<ANAdFetcherDelegate>   adViewDelegate;

// variables for measuring latency.
@property (nonatomic, readwrite, assign)  NSTimeInterval  latencyStart;
@property (nonatomic, readwrite, assign)  NSTimeInterval  latencyStop;

@end

@implementation ANMediationAdViewController

#pragma mark - Lifecycle.

+ (ANMediationAdViewController *)initMediatedAd:(ANMediatedAd *)mediatedAd
                                    withFetcher:(ANAdFetcher *)adFetcher
                                 adViewDelegate:(id<ANAdFetcherDelegate>)adViewDelegate
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
    ANAdResponseCode *errorCode = ANAdResponseCode.DEFAULT;
    
    do {
        // check that the ad is non-nil
        if (!ad) {
            errorInfo = @"null mediated ad object";
            errorCode = ANAdResponseCode.UNABLE_TO_FILL;
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
            errorCode = ANAdResponseCode.MEDIATED_SDK_UNAVAILABLE;
            break;
        }
        
        id adInstance = [[adClass alloc] init];
        if (!adInstance
            || ![adInstance respondsToSelector:@selector(setDelegate:)]
            || ![adInstance conformsToProtocol:@protocol(ANCustomAdapter)]) {
            errorInfo = @"InstantiationError";
            errorCode = ANAdResponseCode.MEDIATED_SDK_UNAVAILABLE;
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
            errorCode = ANAdResponseCode.MEDIATED_SDK_UNAVAILABLE;
            break;
        }
        
    } while (false);
    
    
    if (errorCode.code != ANAdResponseCode.DEFAULT.code) {
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
                         errorCode:(ANAdResponseCode *)errorCode
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
           adView:(id<ANAdFetcherDelegate>)adView
{
    ANTargetingParameters *targetingParameters = [[ANTargetingParameters alloc] init];
    
    NSMutableDictionary<NSString *, NSString *>  *customKeywordsAsStrings  = [ANGlobal convertCustomKeywordsAsMapToStrings: adView.customKeywords
                                                                                                       withSeparatorString: @"," ];


    targetingParameters.customKeywords    = customKeywordsAsStrings;
    targetingParameters.age               = adView.age;
    targetingParameters.gender            = adView.gender;
    targetingParameters.location          = adView.location;
    NSString *idfa = ANAdvertisingIdentifier();
    if(idfa){
        targetingParameters.idforadvertising  = idfa;
    }
    
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

- (void)didLoadBannerAd:(nullable UIView *)view {
    [self didReceiveAd:view];
}



#pragma mark - ANCustomAdapterInterstitialDelegate

- (void)didLoadInterstitialAd:(nullable id<ANCustomAdapterInterstitial>)adapter {
    [self didReceiveAd:adapter];
}



#pragma mark - ANCustomAdapterDelegate

- (void)didFailToLoadAd:(ANAdResponseCode *)errorCode {
    [self didFailToReceiveAd:errorCode];
}

- (void)adWasClicked {
    if (self.hasFailed) return;
    [self runInBlock:^(void) {
        [self.adViewDelegate adWasClicked];
    }];
}

- (void)adDidLogImpression {
    if (self.hasFailed) return;
    [self runInBlock:^(void) {
        [self.adViewDelegate adDidLogImpression];
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
        [self didFailToReceiveAd:ANAdResponseCode.INTERNAL_ERROR];
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
    //fire impressionURLS much earlier in the lifecycle
    [self.adFetcher checkifBeginToRenderAndFireImpressionTracker:self.mediatedAd];
    
    [self finish:ANAdResponseCode.SUCCESS withAdObject:adObject];
    
}

- (void)didFailToReceiveAd:(ANAdResponseCode *)errorCode {

    if ([self checkIfHasResponded]) return;
    [self markLatencyStop];
    self.hasFailed = YES;
    [self finish:errorCode withAdObject:nil];
}


- (void)finish: (ANAdResponseCode *)errorCode
  withAdObject: (id)adObject
{

    // use queue to force return
    [self runInBlock:^(void) {
        ANAdFetcher *fetcher = self.adFetcher;
        
        NSString *responseURL = [self.mediatedAd.responseURL an_responseTrackerReasonCode: (int)errorCode
                                                                                  latency: ([self getLatency] * 1000) ];

        // fireResponseURL will clear the adapter if fetcher exists
        if (!fetcher) {
            [self clearAdapter];
        }
        [fetcher fireResponseURL:responseURL reason:errorCode adObject:adObject];
    }];
}




#pragma mark - Timeout handler

- (void)startTimeout {

    if (self.timeoutCanceled) return;
    __weak ANMediationAdViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 self.mediatedAd.networkTimeout * NSEC_PER_MSEC),
                   dispatch_get_main_queue(), ^{
                       ANMediationAdViewController *strongSelf = weakSelf;
                       if (!strongSelf || strongSelf.timeoutCanceled) return;
                       ANLogWarn(@"mediation_timeout");
                       [strongSelf didFailToReceiveAd:ANAdResponseCode.INTERNAL_ERROR];
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


- (void)dealloc {

    [self clearAdapter];
}

@end

