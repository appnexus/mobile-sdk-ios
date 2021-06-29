/*   Copyright 2016 APPNEXUS INC
 
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
#import "ANAdAdapterInterstitialSmartAd.h"

@interface ANAdAdapterInterstitialSmartAd ()
    
    @property (nonatomic, strong) SASInterstitialManager *sasInterstitialAdManager;
    @property (nonatomic) BOOL isInterstitialReady;

@end

@implementation ANAdAdapterInterstitialSmartAd

    
@synthesize delegate;

- (void)requestInterstitialAdWithParameter:(nullable NSString *)parameterString
                                  adUnitId:(nullable NSString *)idString
                       targetingParameters:(nullable ANTargetingParameters *)targetingParameters {
    
    SASAdPlacement *placement = [self parseAdUnitParameters:idString targetingParameters:targetingParameters];
    
    if (placement != nil) {
        self.sasInterstitialAdManager = [[SASInterstitialManager alloc] initWithPlacement:placement delegate:self];
        [self.sasInterstitialAdManager load];
    } else {
        [self.delegate didFailToLoadAd:ANAdResponseCode.MEDIATED_SDK_UNAVAILABLE];
    }
}

- (void)presentFromViewController:(UIViewController *)viewController {
    [self.sasInterstitialAdManager showFromViewController:viewController];
}

- (BOOL)isReady {
    ANLogTrace(@"");
    return self.sasInterstitialAdManager.adStatus == SASAdStatusReady;
}
    
#pragma mark - SASAdView delegate

- (void)interstitialManager:(SASInterstitialManager *)manager didLoadAd:(SASAd *)ad {
    ANLogTrace(@"");
    [self.delegate didLoadInterstitialAd:self];
}
    
- (void)interstitialManager:(SASInterstitialManager *)manager didFailToLoadWithError:(NSError *)error {
    ANLogTrace(@"");
    [self.delegate didFailToLoadAd:ANAdResponseCode.UNABLE_TO_FILL];
}

- (void)interstitialManager:(SASInterstitialManager *)manager didFailToShowWithError:(NSError *)error {
    ANLogTrace(@"");
    [self.delegate failedToDisplayAd];
}

- (void)interstitialManager:(SASInterstitialManager *)manager didAppearFromViewController:(UIViewController *)viewController {
    ANLogTrace(@"");
    [self.delegate didPresentAd];
}

- (void)interstitialManager:(SASInterstitialManager *)manager didDisappearFromViewController:(UIViewController *)viewController {
    ANLogTrace(@"");
    [self.delegate didCloseAd];
}

@end
