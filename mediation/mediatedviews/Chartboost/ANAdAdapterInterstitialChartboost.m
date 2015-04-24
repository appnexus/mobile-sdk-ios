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

#import "ANAdAdapterInterstitialChartboost.h"
#import "ANAdAdapterBaseChartboost.h"
#import "ANChartboostEventReceiver.h"
#import "ANLogging.h"
#import <Chartboost/Chartboost.h>

@interface ANAdAdapterInterstitialChartboost () <ANChartboostInterstitialDelegate>

@property (nonatomic, readwrite, strong) NSString *cbLocation;

@end

@implementation ANAdAdapterInterstitialChartboost

@synthesize delegate = _delegate;

- (void)requestInterstitialAdWithParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)idString
                       targetingParameters:(ANTargetingParameters *)targetingParameters {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.cbLocation = targetingParameters.customKeywords[kANAdAdapterBaseChartboostCBLocationKey];
    if (!self.cbLocation) {
        self.cbLocation = CBLocationDefault;
    }
    
    [[ANChartboostEventReceiver sharedReceiver] cacheInterstitial:self.cbLocation
                                                     withDelegate:self];
}

- (void)presentFromViewController:(UIViewController *)viewController {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([self isReady]) {
        [Chartboost showInterstitial:self.cbLocation];
    } else {
        [self.delegate failedToDisplayAd];
    }
}

- (BOOL)isReady {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [Chartboost hasInterstitial:self.cbLocation];
}

#pragma mark - ANChartboostInterstitialDelegate

- (void)didCacheInterstitial {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didLoadInterstitialAd:self];
}

- (void)didFailToLoadInterstitialWithError:(ANAdResponseCode)errorCode {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didFailToLoadAd:errorCode];
}

- (void)didDisplayInterstitial {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // do nothing.
}

- (void)didClickInterstitial {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate adWasClicked];
}

- (void)didDismissInterstitial {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willCloseAd];
    [self.delegate didCloseAd];
}

- (void)didCloseInterstitial {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // do nothing.
}

- (void)dealloc {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // do nothing.
}

@end