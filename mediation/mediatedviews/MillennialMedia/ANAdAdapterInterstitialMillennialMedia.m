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

#import "ANAdAdapterInterstitialMillennialMedia.h"
#import <MMAdSDK/MMAdSDK.h>

#if __has_include(<AppNexusSDK/AppNexusSDK.h>)
#import <AppNexusSDK/AppNexusSDK.h>
#else
#import "ANLogging.h"
#endif

@interface ANAdAdapterInterstitialMillennialMedia () <MMInterstitialDelegate>
@property (nonatomic, readwrite, strong) MMInterstitialAd *interstitialAd;
@end

@implementation ANAdAdapterInterstitialMillennialMedia
@synthesize delegate;

#pragma mark ANCustomAdapterInterstitial

- (void)requestInterstitialAdWithParameter:(nullable NSString *)parameterString
                                  adUnitId:(nullable NSString *)idString
                       targetingParameters:(nullable ANTargetingParameters *)targetingParameters {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (!idString) {
        [self.delegate didFailToLoadAd:ANAdResponseCode.UNABLE_TO_FILL];
        return;
    }
    [self configureMillennialSettingsWithTargetingParameters:targetingParameters];
    self.interstitialAd = [[MMInterstitialAd alloc] initWithPlacementId:idString];
    self.interstitialAd.delegate = self;
    if (self.isReady) {
        ANLogDebug(@"MillennialMedia interstitial was already available, attempting to load cached ad");
        [self.delegate didLoadInterstitialAd:self];
        return;
    }
    
    MMRequestInfo *requestInfo = [[MMRequestInfo alloc] init];
    requestInfo.keywords = [[targetingParameters.customKeywords allValues] copy];
    
    [self.interstitialAd load:requestInfo];
}

- (void)presentFromViewController:(UIViewController *)viewController {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (![self isReady]) {
        ANLogDebug(@"MillennialMedia interstitial no longer available, failed to present ad");
        [self.delegate failedToDisplayAd];
        return;
    }
    
    [self.interstitialAd showFromViewController:viewController];
}

- (BOOL)isReady {
    return self.interstitialAd.ready && !self.interstitialAd.expired;
}

- (void)dealloc {
    self.interstitialAd.delegate = nil;
}

#pragma mark - MMInterstitialDelegate

- (void)interstitialAdLoadDidSucceed:(MMInterstitialAd * __nonnull)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didLoadInterstitialAd:self];
}

- (void)interstitialAd:(MMInterstitialAd * __nonnull)ad loadDidFailWithError:(NSError * __nonnull)error {
    ANLogDebug(@"MillennialMedia interstitial failed to load with error: %@", error);
    ANAdResponseCode *code = ANAdResponseCode.INTERNAL_ERROR;
    
    switch (error.code) {
        case MMSDKErrorServerResponseBadStatus:
            code = ANAdResponseCode.INVALID_REQUEST;
            break;
        case MMSDKErrorServerResponseNoContent:
            code = ANAdResponseCode.UNABLE_TO_FILL;
            break;
        case MMSDKErrorPlacementRequestInProgress:
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
        case MMSDKErrorRequestsDisabled:
            code = ANAdResponseCode.MEDIATED_SDK_UNAVAILABLE;
            break;
        case MMSDKErrorNoFill:
            code = ANAdResponseCode.UNABLE_TO_FILL;
            break;
        case MMSDKErrorVersionMismatch:
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
        case MMSDKErrorMediaDownloadFailed:
            code = ANAdResponseCode.NETWORK_ERROR;
            break;
        case MMSDKErrorRequestTimeout:
            code = ANAdResponseCode.NETWORK_ERROR;
            break;
        case MMSDKErrorNotInitialized:
            ANLogError(@"%@ - Millennial Media SDK Uninitialized", NSStringFromSelector(_cmd));
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
        case MMSDKErrorInterstitialAdAlreadyLoaded:
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
        case MMSDKErrorInterstitialAdContentUnavailable:
            code = ANAdResponseCode.UNABLE_TO_FILL;
            break;
        default:
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
    }
    
    [self.delegate didFailToLoadAd:code];
}

- (void)interstitialAdWillDisplay:(MMInterstitialAd * __nonnull)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing
}

- (void)interstitialAdDidDisplay:(MMInterstitialAd * __nonnull)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing
}

- (void)interstitialAd:(MMInterstitialAd * __nonnull)ad showDidFailWithError:(NSError * __nonnull)error {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate failedToDisplayAd];
}

- (void)interstitialAdWillDismiss:(MMInterstitialAd * __nonnull)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willCloseAd];
}

- (void)interstitialAdDidDismiss:(MMInterstitialAd * __nonnull)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didCloseAd];
}

- (void)interstitialAdDidExpire:(MMInterstitialAd * __nonnull)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing
}

- (void)interstitialAdTapped:(MMInterstitialAd * __nonnull)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate adWasClicked];
}

- (void)interstitialAdWillLeaveApplication:(MMInterstitialAd * __nonnull)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willLeaveApplication];
}

@end
