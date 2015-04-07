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

#import "ANAdAdapterInterstitialAdColony.h"
#import "ANLogging.h"
#import <AdColony/AdColony.h>

@interface ANAdAdapterInterstitialAdColony () <AdColonyAdDelegate>

@property (nonatomic, readwrite, strong) NSString *zoneID;

@end

@implementation ANAdAdapterInterstitialAdColony

#pragma mark - ANCustomAdapterInterstitial

@synthesize delegate = _delegate;

- (void)requestInterstitialAdWithParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)idString
                       targetingParameters:(ANTargetingParameters *)targetingParameters {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.zoneID = idString;
    ADCOLONY_ZONE_STATUS zoneStatus = [AdColony zoneStatusForZone:idString];
    ANAdResponseCode errorCode = ANAdResponseInternalError;
    switch (zoneStatus) {
        case ADCOLONY_ZONE_STATUS_ACTIVE:
            ANLogDebug(@"%@ %@ | AdColony interstitial ad available", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            [self.delegate didLoadInterstitialAd:self];
            return;
        case ADCOLONY_ZONE_STATUS_NO_ZONE:
            errorCode = ANAdResponseInvalidRequest;
            break;
        case ADCOLONY_ZONE_STATUS_OFF:
            errorCode = ANAdResponseInvalidRequest;
            break;
        case ADCOLONY_ZONE_STATUS_LOADING:
            errorCode = ANAdResponseUnableToFill;
            break;
        case ADCOLONY_ZONE_STATUS_UNKNOWN:
            errorCode = ANAdResponseInternalError;
            break;
        default:
            ANLogDebug(@"%@ %@ | Unhandled AdColony Zone Status: %ld", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (long)zoneStatus);
            errorCode = ANAdResponseInternalError;
            break;
    }
    ANLogDebug(@"%@ %@ | AdColony interstitial unavailable, zone status %ld", NSStringFromClass([self class]), NSStringFromSelector(_cmd), (long)zoneStatus);
    [self.delegate didFailToLoadAd:errorCode];
}

- (void)presentFromViewController:(UIViewController *)viewController {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([self isReady]) {
        [AdColony playVideoAdForZone:self.zoneID
                        withDelegate:self];
    } else {
        ANLogDebug(@"%@ %@ | failedToDisplayAd", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        [self.delegate failedToDisplayAd];
    }
}

- (BOOL)isReady {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ADCOLONY_ZONE_STATUS zoneStatus = [AdColony zoneStatusForZone:self.zoneID];
    return (zoneStatus == ADCOLONY_ZONE_STATUS_ACTIVE);
}

#pragma mark - AdColonyAdDelegate

- (void)onAdColonyAdStartedInZone:(NSString *)zoneID {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing.
}

- (void)onAdColonyAdFinishedWithInfo:(AdColonyAdInfo *)info {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (info.shown) {
        [self.delegate willCloseAd];
        [self.delegate didCloseAd];
    } else {
        ANLogDebug(@"%@ %@ | failedToDisplayAd", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        [self.delegate failedToDisplayAd];
    }
}

- (void)onAdColonyAdAttemptFinished:(BOOL)shown
                             inZone:(NSString *)zoneID {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (shown) {
        [self.delegate willCloseAd];
        [self.delegate didCloseAd];
    } else {
        ANLogDebug(@"%@ %@ | failedToDisplayAd", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        [self.delegate failedToDisplayAd];
    }
}

@end