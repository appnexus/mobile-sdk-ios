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

#import "ANAdAdapterInterstitialDFP.h"
#import "ANAdAdapterBaseDFP.h"

@interface ANAdAdapterInterstitialDFP ()

@property (nonatomic, readwrite, strong) GAMInterstitialAd *interstitialAd;

@end

@implementation ANAdAdapterInterstitialDFP
@synthesize delegate;

#pragma mark ANCustomAdapterInterstitial

- (void)requestInterstitialAdWithParameter:(nullable NSString *)parameterString
                                  adUnitId:(nullable NSString *)idString
                       targetingParameters:(nullable ANTargetingParameters *)targetingParameters
{
    ANLogDebug(@"Requesting DFP interstitial");    
    [GAMInterstitialAd loadWithAdManagerAdUnitID:idString
                                          request:[ANAdAdapterBaseDFP dfpRequestFromTargetingParameters:targetingParameters rootViewController:nil] completionHandler:^(GAMInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
        if (error) {
            ANLogDebug(@"DFP interstitial failed to load with error: %@", error);
            [self.delegate didFailToLoadAd:[ANAdAdapterBaseDFP responseCodeFromRequestError:error]];
            return;
        }
        ANLogDebug(@"AdMob interstitial did load");
        [self.delegate didLoadInterstitialAd:self];
        self.interstitialAd = interstitialAd;
        self.interstitialAd.fullScreenContentDelegate = self;
    }];
}

- (void)presentFromViewController:(UIViewController *)viewController
{
    if (self.interstitialAd && [self.interstitialAd
                                canPresentFromRootViewController:viewController
                                error:nil]) {
        ANLogDebug(@"Showing DFP interstitial");
        [self.interstitialAd presentFromRootViewController:viewController];
    } else {
        ANLogDebug(@"DFP interstitial was unavailable");
        [self.delegate failedToDisplayAd];
        return;
    }
}


#pragma mark GADFullScreenContentDelegate

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    [self.delegate failedToDisplayAd];
}

- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
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

@end
