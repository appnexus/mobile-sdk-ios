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

#import "ANAdAdapterInterstitialAmazon.h"
#import "ANAdAdapterBaseAmazon+PrivateMethods.h"


@interface ANAdAdapterInterstitialAmazon ()
@property (nonatomic) AmazonAdInterstitial *amazonInterstitial;
@end

@implementation ANAdAdapterInterstitialAmazon

- (void)requestInterstitialAdWithParameter:(nullable NSString *)parameterString
                                  adUnitId:(nullable NSString *)idString
                       targetingParameters:(nullable ANTargetingParameters *)targetingParameters {
    ANLogDebug(@"Requesting Amazon interstitial");
    AmazonAdInterstitial *amazonInterstitial = [AmazonAdInterstitial amazonAdInterstitial];
    amazonInterstitial.delegate = self;
    [amazonInterstitial load:[self adOptionsForTargetingParameters:targetingParameters]];
    self.amazonInterstitial = amazonInterstitial;
}

- (void)presentFromViewController:(UIViewController *)viewController {
    if (![self isReady]) {
        ANLogDebug(@"Amazon interstitial was unavailable");
        [self.delegate failedToDisplayAd];
        return;
    }

    [self.amazonInterstitial presentFromViewController:viewController];
}

- (BOOL)isReady {
    return self.amazonInterstitial.isReady;
}

- (void)interstitialDidLoad:(AmazonAdInterstitial *)interstitial {
    ANLogDebug(@"Amazon interstitial did load");
    [self.delegate didLoadInterstitialAd:self];
}

- (void)interstitialDidFailToLoad:(AmazonAdInterstitial *)interstitial
                        withError:(AmazonAdError *)error {
    ANLogDebug(@"Amazon interstitial did fail to load");
    [self handleAmazonError:error];
}

- (void)interstitialWillPresent:(AmazonAdInterstitial *)interstitial {
    // Do nothing.
}

- (void)interstitialDidPresent:(AmazonAdInterstitial *)interstitial {
    // Do nothing.
}

- (void)interstitialWillDismiss:(AmazonAdInterstitial *)interstitial {
    ANLogDebug(@"Amazon interstitial will dismiss");
    [self.delegate willCloseAd];
}

- (void)interstitialDidDismiss:(AmazonAdInterstitial *)interstitial {
    ANLogDebug(@"Amazon interstitial did dismiss");
    [self.delegate didCloseAd];
}

@end
