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

#import "ANAdAdapterInterstitialAdMob.h"
#import "ANAdAdapterBaseDFP.h"

@interface ANAdAdapterInterstitialAdMob ()

//@property (nonatomic, readwrite, strong) GADInterstitial *interstitialAd;
@property(nonatomic, strong) GADInterstitialAd *interstitialAd;

@end

@implementation ANAdAdapterInterstitialAdMob
@synthesize delegate;

#pragma mark ANCustomAdapterInterstitial

- (void)requestInterstitialAdWithParameter:(nullable NSString *)parameterString
                                  adUnitId:(nullable NSString *)idString
                       targetingParameters:(nullable ANTargetingParameters *)targetingParameters
{
    ANLogDebug(@"Requesting AdMob interstitial");
    [GADInterstitialAd loadWithAdUnitID:idString
                                request:[self createRequestFromTargetingParameters:targetingParameters]
                      completionHandler:^(GADInterstitialAd *ad, NSError *error) {
      if (error) {
        ANLogError(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
          [self.delegate didFailToLoadAd:[ANAdAdapterBaseDFP responseCodeFromRequestError:error]];
          return;
      }
      ANLogDebug(@"AdMob interstitial did load");
      [self.delegate didLoadInterstitialAd:self];
      self.interstitialAd = ad;
      self.interstitialAd.fullScreenContentDelegate = self;
    }];
}

- (void)presentFromViewController:(UIViewController *)viewController
{
    if (self.interstitialAd && [self.interstitialAd
                                canPresentFromRootViewController:viewController
                                error:nil]) {
        ANLogDebug(@"Showing AdMob interstitial");
        [self.interstitialAd presentFromRootViewController:viewController];
    } else {
        ANLogDebug(@"AdMob interstitial was unavailable");
        [self.delegate failedToDisplayAd];
        return;
    }
}

- (GADRequest *)createRequestFromTargetingParameters:(ANTargetingParameters *)targetingParameters {
    return [ANAdAdapterBaseDFP googleAdMobRequestFromTargetingParameters:targetingParameters rootViewController:nil];
}

#pragma mark GADFullScreenContentDelegate

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    [self.delegate failedToDisplayAd];
}

- (void)adWilllPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    [self.delegate willPresentAd];
}

-(void) adWillDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad{
    ANLogDebug(@"AdMob interstitial will close");
    [self.delegate willCloseAd];
}

- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    ANLogDebug(@"AdMob interstitial did close");
    [self.delegate didCloseAd];
}

- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad{
    ANLogDebug(@"AdMob interstitial impression recorded");
    [self.delegate adDidLogImpression];
}

// Tells the delegate that a click has been recorded for the ad.
- (void)adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>)ad{
    [self.delegate adWasClicked];
}

@end
