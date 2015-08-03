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

#import "ANAdAdapterInterstitialVungle.h"
#import "ANLogging.h"
#import <VungleSDK/VungleSDK.h>

@interface ANAdAdapterInterstitialVungle () <VungleSDKDelegate>

@end

@implementation ANAdAdapterInterstitialVungle

#pragma mark - ANCustomAdapterInterstitial

@synthesize delegate = _delegate;

- (BOOL)isReady {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [VungleSDK sharedSDK].isAdPlayable;
}

- (void)requestInterstitialAdWithParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)idString
                       targetingParameters:(ANTargetingParameters *)targetingParameters {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([VungleSDK sharedSDK].isAdPlayable) {
        ANLogTrace(@"%@ %@ | Vungle interstitial cached ad available", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        [self.delegate didLoadInterstitialAd:self];
    } else {
        ANLogTrace(@"%@ %@ | Vungle interstitial cached ad unavailable", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
    }
}

- (void)presentFromViewController:(UIViewController *)viewController {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (![self isReady]) {
        ANLogDebug(@"%@ %@ | failedToDisplayAd", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        [self.delegate failedToDisplayAd];
        return;
    }
    VungleSDK *sdk = [VungleSDK sharedSDK];
    NSError *error;
    sdk.delegate = self;
    [sdk playAd:viewController
          error:&error];
    if (error) {
        ANLogDebug(@"%@ %@ | received Vungle error %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
        switch (error.code) {
            case VungleSDKErrorCannotPlayAd:
                ANLogDebug(@"%@ %@ | failedToDisplayAd", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
                if (sdk.delegate == self) {
                    sdk.delegate = nil;
                }
                [self.delegate failedToDisplayAd];
                return;
            case VungleSDKErrorInvalidPlayAdExtraKey:
            case VungleSDKErrorInvalidPlayAdOption:
            default:
                ANLogDebug(@"%@ %@ | unhandled Vungle error code %ld", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (long)error.code);
                return;
        }
    }
}

#pragma mark - VungleSDKDelegate

- (void)vungleSDKwillShowAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing.
}

- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo
                 willPresentProductSheet:(BOOL)willPresentProductSheet {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (!willPresentProductSheet) {
        [self.delegate willCloseAd];
        [self.delegate didCloseAd];
    }
}

- (void)vungleSDKwillCloseProductSheet:(id)productSheet {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willCloseAd];
    [self.delegate didCloseAd];
}

- (void)dealloc {
    VungleSDK *sdk = [VungleSDK sharedSDK];
    if (sdk.delegate == self) {
        sdk.delegate = nil;
    }
}

@end