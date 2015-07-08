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

#import "ANAdAdapterInterstitialYahoo.h"
#import "FlurryAdInterstitial.h"
#import "ANLogging.h"
#import "ANAdAdapterBaseYahoo+PrivateMethods.h"

@interface ANAdAdapterInterstitialYahoo () <FlurryAdInterstitialDelegate>

@property (nonatomic, readwrite, strong) FlurryAdInterstitial *adInterstitial;

@end

@implementation ANAdAdapterInterstitialYahoo

@synthesize delegate = _delegate;

- (void)requestInterstitialAdWithParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)idString
                       targetingParameters:(ANTargetingParameters *)targetingParameters {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (!idString.length) {
        ANLogDebug(@"Unable to fetch Flurry interstitial - no space provided or space was empty");
        [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
        return;
    }
    self.adInterstitial = [[FlurryAdInterstitial alloc] initWithSpace:idString];
    self.adInterstitial.adDelegate = self;
    self.adInterstitial.targeting = [ANAdAdapterBaseYahoo adTargetingWithTargetingParameters:targetingParameters];
    [self.adInterstitial fetchAd];
}

- (BOOL)isReady {
    return self.adInterstitial.ready;
}

- (void)presentFromViewController:(UIViewController *)viewController {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (self.isReady) {
        [self.adInterstitial presentWithViewController:viewController];
    } else {
        [self.delegate failedToDisplayAd];
    }
}

- (void)dealloc {
    self.adInterstitial.adDelegate = nil;
}

#pragma mark - FlurryAdInterstitialDelegate

- (void)adInterstitialDidFetchAd:(FlurryAdInterstitial *)interstitialAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didLoadInterstitialAd:self];
}

- (void)adInterstitial:(FlurryAdInterstitial *)interstitialAd
               adError:(FlurryAdError)adError
      errorDescription:(NSError *)errorDescription {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    switch (adError) {
        case FLURRY_AD_ERROR_CLICK_ACTION_FAILED:
        case FLURRY_AD_ERROR_DID_FAIL_TO_RENDER:
            ANLogDebug(@"%@ Ignored Flurry error: %@", NSStringFromSelector(_cmd), errorDescription);
            return;
        case FLURRY_AD_ERROR_DID_FAIL_TO_FETCH_AD:
            ANLogDebug(@"%@ Flurry interstitial load failed with error: %@", NSStringFromSelector(_cmd), errorDescription);
            [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
            break;
        default:
            ANLogDebug(@"%@ Unhandled Flurry error: %@", NSStringFromSelector(_cmd), errorDescription);
            break;
    }
}

- (void)adInterstitialDidRender:(FlurryAdInterstitial *)interstitialAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing.
}

- (void)adInterstitialWillPresent:(FlurryAdInterstitial *)interstitialAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing.
}

- (void)adInterstitialWillLeaveApplication:(FlurryAdInterstitial *)interstitialAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willLeaveApplication];
}

- (void)adInterstitialWillDismiss:(FlurryAdInterstitial *)interstitialAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willCloseAd];
}

- (void)adInterstitialDidDismiss:(FlurryAdInterstitial *)interstitialAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didCloseAd];
}

- (void)adInterstitialDidReceiveClick:(FlurryAdInterstitial *)interstitialAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate adWasClicked];
}

- (void)adInterstitialVideoDidFinish:(FlurryAdInterstitial *)interstitialAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing. Invoked for rewarded video only.
}

@end