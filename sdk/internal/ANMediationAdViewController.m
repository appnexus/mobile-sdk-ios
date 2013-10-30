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
#import "ANLogging.h"
#import "ANGlobal.h"
#import "ANBannerAdView.h"
#import "ANInterstitialAd.h"

@interface ANMediationAdViewController () <ANCustomAdapterBannerDelegate, ANCustomAdapterInterstitialDelegate>

@property (nonatomic, readwrite, strong) id<ANCustomAdapter> currentAdapter;
@property (nonatomic, readwrite, assign) BOOL hasSucceeded;
@property (nonatomic, readwrite, assign) BOOL hasFailed;
@property (nonatomic, readwrite, assign) BOOL timeoutCanceled;
@property (nonatomic, readwrite, strong) ANAdFetcher *fetcher;
@property (nonatomic, readwrite, strong) id<ANAdViewDelegate> adViewDelegate;

@end

@implementation ANMediationAdViewController

+ (ANMediationAdViewController *)initWithFetcher:fetcher adViewDelgate:(id<ANAdViewDelegate>)adViewDelegate {
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
    ANLogWarn(ANErrorString(@"mediation_finish"));
}

- (BOOL)requestAd:(CGSize)size
  serverParameter:(NSString *)parameterString
         adUnitId:(NSString *)idString
         location:(ANLocation *)location
           adView:(id<ANAdFetcherDelegate>)adView {
    // if the class implements both banner and interstitial protocols, default to banner first
    if ([[self.currentAdapter class] conformsToProtocol:@protocol(ANCustomAdapterBanner)]) {
        // make sure the container is a banner view
        if ([adView isMemberOfClass:[ANBannerAdView class]]) {
            id<ANCustomAdapterBanner> bannerAdapter = (id<ANCustomAdapterBanner>) self.currentAdapter;
            [bannerAdapter requestBannerAdWithSize:size
                                   serverParameter:parameterString
                                          adUnitId:idString
                                          location:location];
            return YES;
        }
    } else if ([[self.currentAdapter class] conformsToProtocol:@protocol(ANCustomAdapterInterstitial)]) {
        // make sure the container is an interstitial view
        if ([adView isMemberOfClass:[ANInterstitialAd class]]) {
            id<ANCustomAdapterInterstitial> interstitialAdapter = (id<ANCustomAdapterInterstitial>) self.currentAdapter;
            [interstitialAdapter requestInterstitialAdWithParameter:parameterString
                                                           adUnitId:idString
                                                           location:location];
            return YES;
        }
    }
    
    ANLogError([NSString stringWithFormat:ANErrorString(@"instance_exception"), @"ANCustomAdapterBanner or ANCustomAdapterInterstitial"]);
    self.hasFailed = YES;
    return NO;
}

#pragma mark ANCustomAdapterBannerDelegate

- (void)adapterBanner:(id<ANCustomAdapterBanner>)adapter didReceiveBannerAdView:(UIView *)view {
	[self didReceiveAd:view responseURLString:[adapter responseURLString]];
}

- (void)adapterBanner:(id<ANCustomAdapterBanner>)adapter didFailToReceiveBannerAdView:(ANAdResponseCode)errorCode {
    [self didFailToReceiveAd:[adapter responseURLString] errorCode:errorCode];
}

- (void)adapterBanner:(id<ANCustomAdapterBanner>)adapter willPresent:(UIView *)view {
    if (self.hasFailed) return;
    [self.adViewDelegate adWillPresent];
}

- (void)adapterBanner:(id<ANCustomAdapterBanner>)adapter willClose:(UIView *)view {
    if (self.hasFailed) return;
    [self.adViewDelegate adWillClose];
}

- (void)adapterBanner:(id<ANCustomAdapterBanner>)adapter didClose:(UIView *)view {
    if (self.hasFailed) return;
    [self.adViewDelegate adDidClose];
}

- (void)adapterBanner:(id<ANCustomAdapterBanner>)adapter willLeaveApplication:(UIView *)view {
    if (self.hasFailed) return;
    [self.adViewDelegate adWillLeaveApplication];
}

#pragma mark ANCustomAdapterInterstitialDelegate

- (void)adapterInterstitial:(id<ANCustomAdapterInterstitial>)adapter didLoadInterstitialAd:(id)interstitialAd {
	[self didReceiveAd:adapter responseURLString:[adapter responseURLString]];
}

- (void)adapterInterstitial:(id<ANCustomAdapterInterstitial>)adapter didFailToReceiveInterstitialAd:(ANAdResponseCode)errorCode {
    [self didFailToReceiveAd:[adapter responseURLString] errorCode:errorCode];
}

- (void)adapterInterstitial:(id<ANCustomAdapterInterstitial>)adapter willPresent:(id)interstitialAd {
    if (self.hasFailed) return;
    [self.adViewDelegate adWillPresent];
}

- (void)adapterInterstitial:(id<ANCustomAdapterInterstitial>)adapter willClose:(id)interstitialAd {
    if (self.hasFailed) return;
    [self.adViewDelegate adWillClose];
}

- (void)adapterInterstitial:(id<ANCustomAdapterInterstitial>)adapter didClose:(id)interstitialAd {
    if (self.hasFailed) return;
    [self.adViewDelegate adDidClose];
}

- (void)adapterInterstitial:(id<ANCustomAdapterInterstitial>)adapter willLeaveApplication:(id)interstitialAd {
    if (self.hasFailed) return;
    [self.adViewDelegate adWillLeaveApplication];
}

#pragma mark helper methods

- (BOOL)checkIfHasResponded {
    // don't succeed or fail more than once per mediated ad
    if (self.hasSucceeded || self.hasFailed) {
        return YES;
    }
    [self cancelTimeout];
    return NO;
}

- (void)didReceiveAd:(id)adObject responseURLString:(NSString *)responseURLString {
    if ([self checkIfHasResponded]) return;
    self.hasSucceeded = YES;
    
    ANLogDebug(@"received an ad from the adapter");
    
    [self.fetcher fireResultCB:responseURLString reason:ANAdResponseSuccessful adObject:adObject];
}

- (void)didFailToReceiveAd:(NSString *)responseURLString errorCode:(ANAdResponseCode)errorCode {
    if ([self checkIfHasResponded]) return;
    [self.fetcher fireResultCB:responseURLString reason:errorCode adObject:nil];
    [self clearAdapter];
}

#pragma mark Timeout handler

- (void)startTimeout {
    if ([self checkIfHasResponded]) return;
    self.timeoutCanceled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 kAppNexusMediationNetworkTimeoutInterval
                                 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
                       if (self.timeoutCanceled) return;
                       ANLogWarn(ANErrorString(@"mediation_timeout"));
                       [self didFailToReceiveAd:self.currentAdapter.responseURLString errorCode:ANAdResponseInternalError];
                   });
    
}

- (void)cancelTimeout {
    self.timeoutCanceled = YES;
}

@end