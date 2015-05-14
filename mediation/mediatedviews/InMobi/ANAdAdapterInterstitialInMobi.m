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
#import "ANLogging.h"

#import "IMInterstitial.h"

@interface ANAdAdapterInterstitialInMobi () <IMInterstitialDelegate>

@property (nonatomic, strong) IMInterstitial *adInterstitial;

@end

@implementation ANAdAdapterInterstitialInMobi

@synthesize delegate = _delegate;

- (void)requestInterstitialAdWithParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)idString
                       targetingParameters:(ANTargetingParameters *)targetingParameters {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (![ANAdAdapterBaseInMobi appId].length) {
        ANLogError(@"InMobi mediation failed. Call [ANAdAdapterBaseInMobi setInMobiAppID:@\"YOUR_PROPERTY_ID\"] to set the InMobi global App Id");
        [self.delegate didFailToLoadAd:ANAdResponseMediatedSDKUnavailable];
        return;
    }
    NSString *appId;
    if (idString.length) {
        appId = idString;
    } else {
        appId = [ANAdAdapterBaseInMobi appId];
    }
    self.adInterstitial = [[IMInterstitial alloc] initWithAppId:appId];
    self.adInterstitial.delegate = self;
    self.adInterstitial.additionaParameters = targetingParameters.customKeywords;
    self.adInterstitial.keywords = [ANAdAdapterBaseInMobi keywordsFromTargetingParameters:targetingParameters];
    [ANAdAdapterBaseInMobi setInMobiTargetingWithTargetingParameters:targetingParameters];
    [self.adInterstitial loadInterstitial];
}

- (BOOL)isReady {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return self.adInterstitial.state == kIMInterstitialStateReady;
}

- (void)presentFromViewController:(UIViewController *)viewController {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (![self isReady]) {
        ANLogDebug(@"InMobi interstitial was unavailable");
        [self.delegate failedToDisplayAd];
        return;
    }
    
    [self.adInterstitial presentInterstitialAnimated:YES];
}

- (void)dealloc {
    [self.adInterstitial stopLoading];
    self.adInterstitial.delegate = nil;
}

#pragma mark - IMInterstitialDelegate

- (void)interstitialDidReceiveAd:(IMInterstitial *)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didLoadInterstitialAd:self];
}

- (void)interstitial:(IMInterstitial *)ad didFailToReceiveAdWithError:(IMError *)error {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ANLogDebug(@"Received InMobi Error: %@", error);
    [self.delegate didFailToLoadAd:[ANAdAdapterBaseInMobi responseCodeFromInMobiError:error]];
}

- (void)interstitialWillPresentScreen:(IMInterstitial *)ad {
    // Do nothing.
}

- (void)interstitialWillDismissScreen:(IMInterstitial *)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willCloseAd];
}

- (void)interstitialDidDismissScreen:(IMInterstitial *)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didCloseAd];
}

- (void)interstitialWillLeaveApplication:(IMInterstitial *)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willLeaveApplication];
}

- (void)interstitialDidInteract:(IMInterstitial *)ad withParams:(NSDictionary *)dictionary {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate adWasClicked];
}

@end