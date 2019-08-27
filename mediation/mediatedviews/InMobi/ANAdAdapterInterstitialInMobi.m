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

#import "ANAdAdapterInterstitialInMobi.h"
#import "ANAdAdapterBaseInMobi.h"
#import "ANAdAdapterBaseInMobi+PrivateMethods.h"



@interface ANAdAdapterInterstitialInMobi () <IMInterstitialDelegate>

@property (nonatomic, strong) IMInterstitial *adInterstitial;
@property (nonatomic) BOOL isInterstitialReady;

@end

@implementation ANAdAdapterInterstitialInMobi

@synthesize delegate = _delegate;

- (void)requestInterstitialAdWithParameter:(nullable NSString *)parameterString
                                  adUnitId:(nullable NSString *)idString
                       targetingParameters:(nullable ANTargetingParameters *)targetingParameters {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (![ANAdAdapterBaseInMobi appId].length) {
        ANLogError(@"InMobi mediation failed. Call [ANAdAdapterBaseInMobi setInMobiAppID:@\"YOUR_PROPERTY_ID\"] to set the InMobi global App Id");
        [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
        return;
    }
    if (!idString.length) {
        ANLogError(@"Unable to load InMobi interstitial due to empty ad unit id");
        [self.delegate didFailToLoadAd:ANAdResponseMediatedSDKUnavailable];
        return;
    }
    self.adInterstitial = [[IMInterstitial alloc] initWithPlacementId:[idString longLongValue]];
    self.adInterstitial.delegate = self;
    self.adInterstitial.extras = targetingParameters.customKeywords;
    self.adInterstitial.keywords = [ANAdAdapterBaseInMobi keywordsFromTargetingParameters:targetingParameters];
    [ANAdAdapterBaseInMobi setInMobiTargetingWithTargetingParameters:targetingParameters];
    [self.adInterstitial load];
    self.isInterstitialReady = false;
}

- (BOOL)isReady {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return self.isInterstitialReady;
}

- (void)presentFromViewController:(UIViewController *)viewController {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.adInterstitial showFromViewController:viewController];
}

- (void)dealloc {
    self.adInterstitial.delegate = nil;
}

#pragma mark - IMInterstitialDelegate

- (void)interstitialDidFinishLoading:(IMInterstitial*)interstitial {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.isInterstitialReady = true;
    [self.delegate didLoadInterstitialAd:self];
}

- (void)interstitial:(IMInterstitial*)interstitial didFailToLoadWithError:(IMRequestStatus*)error  {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ANLogDebug(@"Received InMobi Error: %@", error);
    self.isInterstitialReady = false;
    [self.delegate didFailToLoadAd:[ANAdAdapterBaseInMobi responseCodeFromInMobiRequestStatus:error]];
}

- (void)interstitialDidReceiveAd:(IMInterstitial *)interstitial {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing
}

- (void)interstitialWillPresent:(IMInterstitial*)interstitial {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing
}

- (void)interstitialDidPresent:(IMInterstitial *)interstitial {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing
}

- (void)interstitial:(IMInterstitial*)interstitial didFailToPresentWithError:(IMRequestStatus*)error {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate failedToDisplayAd];
}

- (void)interstitialWillDismiss:(IMInterstitial*)interstitial {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willCloseAd];
}

- (void)interstitialDidDismiss:(IMInterstitial*)interstitial {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didCloseAd];
}

- (void)interstitial:(IMInterstitial*)interstitial didInteractWithParams:(NSDictionary*)params {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate adWasClicked];
}

- (void)interstitial:(IMInterstitial*)interstitial rewardActionCompletedWithRewards:(NSDictionary*)rewards {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing
}

- (void)userWillLeaveApplicationFromInterstitial:(IMInterstitial*)interstitial {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willLeaveApplication];
}

@end
