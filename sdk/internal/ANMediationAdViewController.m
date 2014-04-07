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

#import "ANBannerAdView.h"
#import "ANGlobal.h"
#import "ANInterstitialAd.h"
#import "ANLogging.h"

@interface ANMediationAdViewController () <ANCustomAdapterBannerDelegate, ANCustomAdapterInterstitialDelegate>

@property (nonatomic, readwrite, strong) id<ANCustomAdapter> currentAdapter;
@property (nonatomic, readwrite, assign) BOOL hasSucceeded;
@property (nonatomic, readwrite, assign) BOOL hasFailed;
@property (nonatomic, readwrite, assign) BOOL timeoutCanceled;
@property (nonatomic, readwrite, weak) ANAdFetcher *fetcher;
@property (nonatomic, readwrite, weak) id<ANAdViewDelegate> adViewDelegate;
@property (nonatomic, readwrite, strong) NSString *resultCBString;
@end

@implementation ANMediationAdViewController

+ (ANMediationAdViewController *)initWithFetcher:fetcher adViewDelegate:(id<ANAdViewDelegate>)adViewDelegate {
    ANMediationAdViewController *controller = [[ANMediationAdViewController alloc] init];
    controller.fetcher = fetcher;
    controller.adViewDelegate = adViewDelegate;
    return controller;
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
    self.resultCBString = nil;
    [self cancelTimeout];
    ANLogInfo(ANErrorString(@"mediation_finish"));
}

- (BOOL)requestAd:(CGSize)size
  serverParameter:(NSString *)parameterString
         adUnitId:(NSString *)idString
           adView:(id<ANAdFetcherDelegate>)adView {
    // create targeting parameters object from adView properties
    ANTargetingParameters *targetingParameters = [ANTargetingParameters new];
    targetingParameters.customKeywords = adView.customKeywords;
    targetingParameters.age = adView.age;
    targetingParameters.gender = adView.gender;
    targetingParameters.location = adView.location;
    targetingParameters.idforadvertising = ANUDID();

    // if the class implements both banner and interstitial protocols, default to banner first
    if ([[self.currentAdapter class] conformsToProtocol:@protocol(ANCustomAdapterBanner)]
        && [self.currentAdapter respondsToSelector:@selector(
            requestBannerAdWithSize:rootViewController:serverParameter:adUnitId:targetingParameters:)]) {
        // make sure the container is a banner view
        if ([adView isKindOfClass:[ANBannerAdView class]]) {
            [self startTimeout];
            ANBannerAdView *banner = (ANBannerAdView *)adView;

            id<ANCustomAdapterBanner> bannerAdapter = (id<ANCustomAdapterBanner>) self.currentAdapter;
            [bannerAdapter requestBannerAdWithSize:size
                                rootViewController:banner.rootViewController
                                   serverParameter:parameterString
                                          adUnitId:idString
                               targetingParameters:targetingParameters];
            return YES;
        }
    } else if ([[self.currentAdapter class] conformsToProtocol:@protocol(ANCustomAdapterInterstitial)]
               && [self.currentAdapter respondsToSelector:@selector(
                   requestInterstitialAdWithParameter:adUnitId:targetingParameters:)]) {
        // make sure the container is an interstitial view
        if ([adView isKindOfClass:[ANInterstitialAd class]]) {
            [self startTimeout];
            id<ANCustomAdapterInterstitial> interstitialAdapter = (id<ANCustomAdapterInterstitial>) self.currentAdapter;
            [interstitialAdapter requestInterstitialAdWithParameter:parameterString
                                                           adUnitId:idString
                                                           targetingParameters:targetingParameters];
            return YES;
        }
    }
    
    ANLogError([NSString stringWithFormat:ANErrorString(@"instance_exception"), @"ANCustomAdapterBanner or ANCustomAdapterInterstitial"]);
    [self clearAdapter];
    return NO;
}

#pragma mark ANCustomAdapterBannerDelegate

- (void)didLoadBannerAd:(UIView *)view {
	[self didReceiveAd:view];
}

#pragma mark ANCustomAdapterInterstitialDelegate

- (void)didLoadInterstitialAd:(id<ANCustomAdapterInterstitial>)adapter {
	[self didReceiveAd:adapter];
}

#pragma mark ANCustomAdapterDelegate

- (void)didFailToLoadAd:(ANAdResponseCode)errorCode {
    [self didFailToReceiveAd:errorCode];
}

- (void)adWasClicked {
    if (self.hasFailed) return;
    [self.adViewDelegate adWasClicked];
}

- (void)willPresentAd {
    if (self.hasFailed) return;
    [self.adViewDelegate adWillPresent];
}

- (void)didPresentAd {
    if (self.hasFailed) return;
    [self.adViewDelegate adDidPresent];
}

- (void)willCloseAd {
    if (self.hasFailed) return;
    [self.adViewDelegate adWillClose];
}

- (void)didCloseAd {
    if (self.hasFailed) return;
    [self.adViewDelegate adDidClose];
}

- (void)willLeaveApplication {
    if (self.hasFailed) return;
    [self.adViewDelegate adWillLeaveApplication];
}

- (void)failedToDisplayAd {
    if (self.hasFailed) return;
    [self.adViewDelegate adFailedToDisplay];
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
        [self didFailToReceiveAd:ANAdResponseInternalError];
        return;
    }
    self.hasSucceeded = YES;
    
    ANLogDebug(@"received an ad from the adapter");
    
    [self.fetcher fireResultCB:self.resultCBString reason:ANAdResponseSuccessful adObject:adObject];
}

- (void)didFailToReceiveAd:(ANAdResponseCode)errorCode {
    if ([self checkIfHasResponded]) return;
    ANAdFetcher *fetcher = self.fetcher;
    NSString *resultCBString = self.resultCBString;
    [self clearAdapter];
    [fetcher fireResultCB:resultCBString reason:errorCode adObject:nil];
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
                       [strongSelf didFailToReceiveAd:ANAdResponseInternalError];
                   });
    
}

- (void)cancelTimeout {
    self.timeoutCanceled = YES;
}

@end