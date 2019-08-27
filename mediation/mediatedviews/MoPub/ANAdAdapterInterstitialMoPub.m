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

#import "ANAdAdapterInterstitialMoPub.h"

@interface ANAdAdapterInterstitialMoPub ()

@property (nonatomic, strong) MPInterstitialAdController *interstitialAd;

@end

@implementation ANAdAdapterInterstitialMoPub

- (void)requestInterstitialAdWithParameter:(nullable NSString *)parameterString
                                  adUnitId:(nullable NSString *)idString
                       targetingParameters:(nullable ANTargetingParameters *)targetingParameters {
    if ([MoPub sharedInstance].isSdkInitialized)
    {
        [self initialseInterstitialAdWithParameter:parameterString adUnitId:idString targetingParameters:targetingParameters];
    }
    else
    {
        MPMoPubConfiguration * sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization: idString];
        [[MoPub sharedInstance] initializeSdkWithConfiguration:sdkConfig completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
               [self initialseInterstitialAdWithParameter:parameterString adUnitId:idString targetingParameters:targetingParameters];
            });
        }];
    }
}

- (void) initialseInterstitialAdWithParameter:(NSString *)parameterString
                                     adUnitId:(NSString *)idString
                          targetingParameters:(ANTargetingParameters *)targetingParameters {
    self.interstitialAd = [MPInterstitialAdController interstitialAdControllerForAdUnitId:idString];
    self.interstitialAd.location = [self locationFromTargetingParameters:targetingParameters];
    self.interstitialAd.keywords = [self keywordsFromTargetingParameters:targetingParameters];
    self.interstitialAd.delegate = self;
    [self.interstitialAd loadAd];
}

- (void)dealloc {
    self.interstitialAd.delegate = nil;
}

- (void)presentFromViewController:(UIViewController *)viewController {
    if (![self isReady]) {
        ANLogDebug(@"MoPub interstitial was unavailable");
        [self.delegate failedToDisplayAd];
        return;
    }
    
    [self.interstitialAd showFromViewController:viewController];
}

- (BOOL)isReady {
    return self.interstitialAd.ready;
}

#pragma mark - MPInterstitialAdControllerDelegate

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    [self.delegate didLoadInterstitialAd:self];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial {
    [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
}

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial {
    [self.delegate willPresentAd];
}

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial {
    [self.delegate didPresentAd];
}

- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial {
    [self.delegate willCloseAd];
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial {
    [self.delegate didCloseAd];
}

@end
