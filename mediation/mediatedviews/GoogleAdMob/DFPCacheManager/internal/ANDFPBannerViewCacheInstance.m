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

#import "ANDFPBannerViewCacheInstance.h"
#import "ANDFPBannerViewIdentifier.h"
#import "ANDFPRootViewController.h"
#import "ANDFPCacheManagerTargeting+Internal.h"
#import "ANAdAdapterBaseDFP.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "ANLogging.h"

@interface ANDFPBannerViewCacheInstance () <GADBannerViewDelegate>

@property (nonatomic) ANDFPBannerViewIdentifier *identifier;

@property (nonatomic) ANDFPBannerViewLoadingState loadingState;
@property (nonatomic) DFPBannerView *bannerView;
@property (nonatomic) GADRequestError *requestError;

@property (nonatomic) ANDFPRootViewController *dummyRootViewController;

@end

@implementation ANDFPBannerViewCacheInstance

- (instancetype)initWithIdentifier:(ANDFPBannerViewIdentifier *)identifier {
    if (self = [super init]) {
        _identifier = identifier;
        _dummyRootViewController = [[ANDFPRootViewController alloc] init];
        _loadingState = ANDFPBannerViewLoadingStatePending;
    }
    return self;
}

- (void)startLoading {
    self.loadingState = ANDFPBannerViewLoadingStatePending;
    GADAdSize adSize;
    switch (self.identifier.orientation) {
        case ANDFPSmartBannerOrientationPortrait:
            adSize = kGADAdSizeSmartBannerPortrait;
            break;
        case ANDFPSmartBannerOrientationLandscape:
            adSize = kGADAdSizeSmartBannerLandscape;
            break;
        default:
            adSize = GADAdSizeFromCGSize(self.identifier.adSize);
            break;
    }
    self.bannerView = [[DFPBannerView alloc] initWithAdSize:adSize];
    self.bannerView.delegate = self;
    self.bannerView.adUnitID = self.identifier.adUnitId;
    self.bannerView.enableManualImpressions = YES;
    self.bannerView.rootViewController = self.dummyRootViewController;
    ANTargetingParameters *targetingParameters = [[ANDFPCacheManagerTargeting sharedTargeting] targetingParameters];
    GADRequest *request = [ANAdAdapterBaseDFP googleAdRequestFromTargetingParameters:targetingParameters];
    [self.bannerView loadRequest:request];
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)view {
    ANLogDebug(@"DFP banner did load");
    self.loadingState = ANDFPBannerViewLoadingStateSucceeded;
    self.bannerView.delegate = nil;
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    ANLogDebug(@"DFP banner failed to load with error: %@", [error localizedDescription]);
    self.loadingState = ANDFPBannerViewLoadingStateFailed;
    self.requestError = error;
    self.bannerView.delegate = nil;
    self.bannerView = nil;
}

- (void)dealloc {
    ANLogDebug(@"DFP banner being destroyed");
    self.bannerView.delegate = nil;
    self.bannerView = nil;
}

@end