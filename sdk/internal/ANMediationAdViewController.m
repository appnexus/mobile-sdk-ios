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

#import "ANBasicConfig.h"
#import "ANMediationAdViewController.h"

#import ANBANNERADVIEWHEADER
#import "ANGlobal.h"
#import ANINTERSTITIALADHEADER
#import "ANLogging.h"
#import "ANMediatedAd.h"
#import "ANPBBuffer.h"
#import "NSString+ANCategory.h"
#import "ANPBContainerView.h"
#import "ANMediationContainerView.h"

@interface ANMediationAdViewController () <ANCUSTOMADAPTERBANNERDELEGATE, ANCUSTOMADAPTERINTERSTITIALDELEGATE>

@property (nonatomic, readwrite, strong) id<ANCUSTOMADAPTER> currentAdapter;
@property (nonatomic, readwrite, assign) BOOL hasSucceeded;
@property (nonatomic, readwrite, assign) BOOL hasFailed;
@property (nonatomic, readwrite, assign) BOOL timeoutCanceled;
@property (nonatomic, readwrite, weak) ANAdFetcher *fetcher;
@property (nonatomic, readwrite, weak) id<ANAdFetcherDelegate> adViewDelegate;
@property (nonatomic, readwrite, strong) ANMediatedAd *mediatedAd;
@property (nonatomic, readwrite, strong) NSDictionary *pitbullAdForDelayedCapture;

// variables for measuring latency.
@property (nonatomic, readwrite, assign) NSTimeInterval latencyStart;
@property (nonatomic, readwrite, assign) NSTimeInterval latencyStop;
@end

@interface ANAdFetcher ()
- (NSTimeInterval)getTotalLatency:(NSTimeInterval)stopTime;
@end

@implementation ANMediationAdViewController

+ (ANMediationAdViewController *)initMediatedAd:(ANMediatedAd *)mediatedAd
                                    withFetcher:(ANAdFetcher *)fetcher
                                 adViewDelegate:(id<ANAdFetcherDelegate>)adViewDelegate {
    ANMediationAdViewController *controller = [[ANMediationAdViewController alloc] init];
    controller.fetcher = fetcher;
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
    ANADRESPONSECODE errorCode = (ANADRESPONSECODE)ANDefaultCode;
    
    do {
        // check that the ad is non-nil
        if (!ad) {
            errorInfo = @"null mediated ad object";
            errorCode = (ANADRESPONSECODE)ANAdResponseUnableToFill;
            break;
        }
        
        self.mediatedAd = ad;
        className = ad.className;
        
        // notify that a mediated class name was received
        ANPostNotifications(kANAdFetcherWillInstantiateMediatedClassNotification, self,
                            @{kANAdFetcherMediatedClassKey: className});
        
        ANLogDebug([NSString stringWithFormat:ANErrorString(@"instantiating_class"), className]);
        
        // check to see if an instance of this class exists
        Class adClass = NSClassFromString(className);
        if (!adClass) {
            errorInfo = @"ClassNotFoundError";
            errorCode = (ANADRESPONSECODE)ANAdResponseMediatedSDKUnavailable;
            break;
        }
        
        id adInstance = [[adClass alloc] init];
        if (!adInstance
            || ![adInstance respondsToSelector:@selector(setDelegate:)]
            || ![adInstance conformsToProtocol:@protocol(ANCUSTOMADAPTER)]) {
            errorInfo = @"InstantiationError";
            errorCode = (ANADRESPONSECODE)ANAdResponseMediatedSDKUnavailable;
            break;
        }
        
        // instance valid - request a mediated ad
        id<ANCUSTOMADAPTER> adapter = (id<ANCUSTOMADAPTER>)adInstance;
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
            errorCode = (ANADRESPONSECODE)ANAdResponseMediatedSDKUnavailable;
            break;
        }
        
    } while (false);
    
    
    if (errorCode != (ANADRESPONSECODE)ANDefaultCode) {
        [self handleInstantiationFailure:className
                               errorCode:errorCode errorInfo:errorInfo];
        return NO;
    }
    
    // otherwise, no error yet
    // wait for a mediation adapter to hit one of our callbacks.
    return YES;
}

- (void)handleInstantiationFailure:(NSString *)className
                         errorCode:(ANADRESPONSECODE)errorCode
                         errorInfo:(NSString *)errorInfo {
    if ([errorInfo length] > 0) {
        ANLogError(ANErrorString(@"mediation_instantiation_failure"), errorInfo);
    }
    if ([className length] > 0) {
        ANLogWarn(ANErrorString(@"mediation_adding_invalid"), className);
        ANAddInvalidNetwork(className);
    }
    
    [self didFailToReceiveAd:errorCode];
}

- (void)setAdapter:adapter {
    self.currentAdapter = adapter;
}

- (void)clearAdapter {
    if (self.currentAdapter)
        self.currentAdapter.delegate = nil;
    self.currentAdapter = nil;
    self.hasSucceeded = NO;
    self.hasFailed = YES;
    self.fetcher = nil;
    self.adViewDelegate = nil;
    self.mediatedAd = nil;
    [self cancelTimeout];
    ANLogInfo(ANErrorString(@"mediation_finish"));
}

- (BOOL)requestAd:(CGSize)size
  serverParameter:(NSString *)parameterString
         adUnitId:(NSString *)idString
           adView:(id<ANAdFetcherDelegate>)adView {
    // create targeting parameters object from adView properties
    ANTARGETINGPARAMETERS *targetingParameters = [ANTARGETINGPARAMETERS new];
    targetingParameters.customKeywords = adView.customKeywords;
    targetingParameters.age = adView.age;
    targetingParameters.gender = adView.gender;
    targetingParameters.location = adView.location;
    targetingParameters.idforadvertising = ANUDID();
    
    if ([adView isKindOfClass:[ANBANNERADVIEW class]]) {
        // make sure the container and protocol match
        if ([[self.currentAdapter class] conformsToProtocol:@protocol(ANCUSTOMADAPTERBANNER)]
            && [self.currentAdapter respondsToSelector:@selector(requestBannerAdWithSize:rootViewController:serverParameter:adUnitId:targetingParameters:)]) {
            
            [self markLatencyStart];
            [self startTimeout];

            ANBANNERADVIEW *banner = (ANBANNERADVIEW *)adView;
            id<ANCUSTOMADAPTERBANNER> bannerAdapter = (id<ANCUSTOMADAPTERBANNER>) self.currentAdapter;
            [bannerAdapter requestBannerAdWithSize:size
                                rootViewController:banner.rootViewController
                                   serverParameter:parameterString
                                          adUnitId:idString
                               targetingParameters:targetingParameters];
            return YES;
        } else {
            ANLogError([NSString stringWithFormat:ANErrorString(@"instance_exception"), @"CustomAdapterBanner"]);
        }
    } else if ([adView isKindOfClass:[ANINTERSTITIALAD class]]) {
        // make sure the container and protocol match
        if ([[self.currentAdapter class] conformsToProtocol:@protocol(ANCUSTOMADAPTERINTERSTITIAL)]
            && [self.currentAdapter respondsToSelector:@selector(requestInterstitialAdWithParameter:adUnitId:targetingParameters:)]) {
            
            [self markLatencyStart];
            [self startTimeout];
            
            id<ANCUSTOMADAPTERINTERSTITIAL> interstitialAdapter = (id<ANCUSTOMADAPTERINTERSTITIAL>) self.currentAdapter;
            [interstitialAdapter requestInterstitialAdWithParameter:parameterString
                                                           adUnitId:idString
                                                targetingParameters:targetingParameters];
            return YES;
        } else {
            ANLogError([NSString stringWithFormat:ANErrorString(@"instance_exception"), @"CustomAdapterInterstitial"]);
        }
    }
    
    // executes iff request was unsuccessful
    return NO;
}

#pragma mark ANCustomAdapterBannerDelegate

- (void)didLoadBannerAd:(UIView *)view {
	[self didReceiveAd:view];
}

#pragma mark ANCustomAdapterInterstitialDelegate

- (void)didLoadInterstitialAd:(id<ANCUSTOMADAPTERINTERSTITIAL>)adapter {
	[self didReceiveAd:adapter];
}

#pragma mark ANCustomAdapterDelegate

- (void)didFailToLoadAd:(ANADRESPONSECODE)errorCode {
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
        [self.adViewDelegate adFailedToDisplay];
    }];
}

#pragma mark helper methods

- (BOOL)checkIfHasResponded {
    // we received a callback from mediation adaptor, cancel timeout
    [self cancelTimeout];
    // don't succeed or fail more than once per mediated ad
    return (self.hasSucceeded || self.hasFailed);
}

- (void)didReceiveAd:(id)adObject {
    if ([self checkIfHasResponded]) return;
    if (!adObject) {
        [self didFailToReceiveAd:(ANADRESPONSECODE)ANAdResponseInternalError];
        return;
    }
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
    
    [self finish:(ANADRESPONSECODE)ANAdResponseSuccessful withAdObject:adObject auctionID:auctionID];

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

- (void)didFailToReceiveAd:(ANADRESPONSECODE)errorCode {
    if ([self checkIfHasResponded]) return;
    [self markLatencyStop];
    
    [self finish:errorCode withAdObject:nil auctionID:nil];
}

- (void)finish:(ANADRESPONSECODE)errorCode withAdObject:(id)adObject
     auctionID:(NSString *)auctionID {
    // use queue to force return
    [self runInBlock:^(void) {
        ANAdFetcher *fetcher = self.fetcher;
        NSString *resultCBString = [self createResultCBRequest:
                                    self.mediatedAd.resultCB reason:errorCode];
        // fireResulCB will clear the adapter if fetcher exists
        if (!fetcher) {
            [self clearAdapter];
        }
        [fetcher fireResultCB:resultCBString reason:errorCode adObject:adObject auctionID:auctionID];
    }];
}

- (void)runInBlock:(void (^)())block {
    // nothing keeps 'block' alive, so we don't have a retain cycle
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

- (NSString *)createResultCBRequest:(NSString *)baseString reason:(int)reasonCode {
    if ([baseString length] < 1) {
        return @"";
    }
    
    // append reason code
    NSString *resultCBString = [baseString
                                stringByAppendingUrlParameter:@"reason"
                                value:[NSString stringWithFormat:@"%d",reasonCode]];
    
    // append idfa
    resultCBString = [resultCBString
                      stringByAppendingUrlParameter:@"idfa"
                      value:ANUDID()];
    
    // append latency measurements
    NSTimeInterval latency = [self getLatency] * 1000; // secs to ms
    NSTimeInterval totalLatency = [self getTotalLatency] * 1000; // secs to ms
    
    if (latency > 0) {
        resultCBString = [resultCBString
                          stringByAppendingUrlParameter:@"latency"
                          value:[NSString stringWithFormat:@"%.0f", latency]];
    }
    if (totalLatency > 0) {
        resultCBString = [resultCBString
                          stringByAppendingUrlParameter:@"total_latency"
                          value:[NSString stringWithFormat:@"%.0f", totalLatency]];
    }
    
    return resultCBString;
}

#pragma mark Timeout handler

- (void)startTimeout {
    if (self.timeoutCanceled) return;
    __weak ANMediationAdViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 kAppNexusMediationNetworkTimeoutInterval
                                 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
                       ANMediationAdViewController *strongSelf = weakSelf;
                       if (!strongSelf || strongSelf.timeoutCanceled) return;
                       ANLogWarn(ANErrorString(@"mediation_timeout"));
                       [strongSelf didFailToReceiveAd:(ANADRESPONSECODE)ANAdResponseInternalError];
                   });
    
}

- (void)cancelTimeout {
    self.timeoutCanceled = YES;
}

# pragma mark Latency Measurement

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
    if (self.fetcher && (self.latencyStop > 0)) {
        return [self.fetcher getTotalLatency:self.latencyStop];
    }
    // return -1 if invalid.
    return -1;
}

#pragma mark - Pitbull Image Capture Transition Adjustments

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.adViewDelegate) {
        NSNumber *transitionInProgress = change[NSKeyValueChangeNewKey];
        if ([transitionInProgress boolValue] == NO) {
            [self unregisterFromPitbullScreenCaptureNotifications];
            [self dispatchPitbullScreenCapture];
        }
    }
}

- (void)registerForPitbullScreenCaptureNotifications {
    NSObject *object = self.adViewDelegate;
    [object addObserver:self
             forKeyPath:@"transitionInProgress"
                options:NSKeyValueObservingOptionNew
                context:nil];
}

- (void)unregisterFromPitbullScreenCaptureNotifications {
    /*
     Removing a non-registered observer results in an exception. There's no way to
     check if you're registered or not. Hence the try-catch.
     */
    NSObject *object = self.adViewDelegate;
    @try {
        [object removeObserver:self
                    forKeyPath:@"transitionInProgress"];
    }
    @catch (NSException * __unused exception) {}
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