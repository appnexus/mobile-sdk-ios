/*   Copyright 2014 APPNEXUS INC
 
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

#import "ANAdAdapterInterstitialFacebook.h"
#import "ANLogging.h"

@interface ANAdAdapterInterstitialFacebook ()

@property (nonatomic, strong) FBInterstitialAd *fbInterstitialAd;

@end

@implementation ANAdAdapterInterstitialFacebook

@synthesize delegate;

- (void)requestInterstitialAdWithParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)idString
                       targetingParameters:(ANTargetingParameters *)targetingParameters {
    self.fbInterstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:idString];
    self.fbInterstitialAd.delegate = self;
    [self.fbInterstitialAd loadAd];
}

- (void)presentFromViewController:(UIViewController *)viewController {
    if (![self isReady]) {
        ANLogDebug(@"Facebook interstitial was unavailable");
        [self.delegate failedToDisplayAd];
        return;
    }

    [self.fbInterstitialAd showAdFromRootViewController:viewController];
}

- (BOOL)isReady {
    return self.fbInterstitialAd.isAdValid;
}

#pragma mark FBInterstitialAdDelegate methods

- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd {
    [self.delegate didLoadInterstitialAd:self];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    ANAdResponseCode code = ANAdResponseInternalError;
    if (error.code == 1001) {
        code = ANAdResponseUnableToFill;
    }
    [self.delegate didFailToLoadAd:code];
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd {
    [self.delegate adWasClicked];
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd {
    [self.delegate didCloseAd];
}

- (void)interstitialAdWillClose:(FBInterstitialAd *)interstitialAd {
    [self.delegate willCloseAd];
}

- (void)interstitialAdWillLogImpression:(FBInterstitialAd *)interstitialAd {
    ANLogDebug(@"The user sees the add Facebook interstitialAd");
    // Use this function as indication for a user's impression on the ad.
}

@end
