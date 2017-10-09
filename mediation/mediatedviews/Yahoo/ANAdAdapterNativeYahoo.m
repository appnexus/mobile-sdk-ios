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

#import "ANAdAdapterNativeYahoo.h"
#import "ANAdAdapterBaseYahoo+PrivateMethods.h"
#import "ANNativeMediationAdResponse.h"
#import "ANLogging.h"
#import "FlurryAdNative.h"

@interface ANAdAdapterNativeYahoo () <FlurryAdNativeDelegate>

@property (nonatomic, readwrite, strong) FlurryAdNative *nativeAd;

@end

@implementation ANAdAdapterNativeYahoo

@synthesize nativeAdDelegate = _nativeAdDelegate;
@synthesize expired = _expired;
@synthesize requestDelegate = _requestDelegate;

- (void)requestNativeAdWithServerParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)adUnitId
                       targetingParameters:(ANTargetingParameters *)targetingParameters {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (!adUnitId.length) {
        ANLogDebug(@"Unable to fetch Flurry banner ad - no space provided or space was empty");
        [self.requestDelegate didFailToLoadNativeAd:ANAdResponseUnableToFill];
        return;
    }
    self.nativeAd = [[FlurryAdNative alloc] initWithSpace:adUnitId];
    self.nativeAd.adDelegate = self;
    self.nativeAd.targeting = [ANAdAdapterBaseYahoo adTargetingWithTargetingParameters:targetingParameters];
    [self.nativeAd fetchAd];
}

- (void)registerViewForImpressionTrackingAndClickHandling:(UIView *)view
                                   withRootViewController:(UIViewController *)rvc
                                           clickableViews:(NSArray *)clickableViews {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.nativeAd.viewControllerForPresentation = rvc;
    self.nativeAd.trackingView = view;
}

- (void)dealloc {
    [self unregisterViewFromTracking];
}

- (BOOL)hasExpired {
    return self.nativeAd.expired;
}

- (void)unregisterViewFromTracking {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.nativeAd removeTrackingView];
    self.nativeAd.viewControllerForPresentation = nil;
    self.nativeAd.adDelegate = nil;
    self.nativeAd = nil;
}

#pragma mark - FlurryAdNativeDelegate

- (void)adNativeDidFetchAd:(FlurryAdNative *)nativeAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ANNativeMediationAdResponse *response = [[ANNativeMediationAdResponse alloc] initWithCustomAdapter:self
                                                                                         networkCode:ANNativeAdNetworkCodeYahoo];
    NSMutableDictionary *customElements = [[NSMutableDictionary alloc] init];
    ANNativeAdStarRating *starRating = nil;
    BOOL showRating = NO;
    for (FlurryAdNativeAsset *asset in nativeAd.assetList) {
        if ([asset.name isEqualToString:@"headline"]) {
            response.title = asset.value;
        } else if ([asset.name isEqualToString:@"summary"]) {
            response.body = asset.value;
        } else if ([asset.name isEqualToString:@"secHqImage"]) {
            response.mainImageURL = [NSURL URLWithString:asset.value];
        } else if ([asset.name isEqualToString:@"secImage"]) {
            response.iconImageURL = [NSURL URLWithString:asset.value];
        } else if ([asset.name isEqualToString:@"appRating"]) {
            NSArray *ratingComponents = [asset.value componentsSeparatedByString:@"/"];
            if (ratingComponents.count == 2) {
                starRating = [[ANNativeAdStarRating alloc] initWithValue:[ratingComponents[0] floatValue]
                                                                   scale:[ratingComponents[1] floatValue]];
            }
        } else if ([asset.name isEqualToString:@"showRating"]) {
            showRating = [asset.value boolValue];
        }
        customElements[asset.name] = asset.value;
    }
    
    if (showRating && starRating != nil) {
        response.rating = starRating;
    }
    
    response.customElements = [customElements copy];
    [self.requestDelegate didLoadNativeAd:response];
}

- (void)adNative:(FlurryAdNative *)nativeAd
         adError:(FlurryAdError)adError
errorDescription:(NSError *)errorDescription {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    switch (adError) {
        case FLURRY_AD_ERROR_CLICK_ACTION_FAILED:
        case FLURRY_AD_ERROR_DID_FAIL_TO_RENDER:
            ANLogDebug(@"%@ Ignored Flurry error: %@", NSStringFromSelector(_cmd), errorDescription);
            return;
        case FLURRY_AD_ERROR_DID_FAIL_TO_FETCH_AD:
            ANLogDebug(@"%@ Flurry native ad load failed with error: %@", NSStringFromSelector(_cmd), errorDescription);
            [self.requestDelegate didFailToLoadNativeAd:ANAdResponseUnableToFill];
            break;
        default:
            ANLogDebug(@"%@ Unhandled Flurry error: %@", NSStringFromSelector(_cmd), errorDescription);
            break;
    }
}

- (void)adNativeWillPresent:(FlurryAdNative *)nativeAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.nativeAdDelegate willPresentAd];
    [self.nativeAdDelegate didPresentAd];
}

- (void)adNativeWillLeaveApplication:(FlurryAdNative *)nativeAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.nativeAdDelegate willLeaveApplication];
}

- (void)adNativeWillDismiss:(FlurryAdNative *)nativeAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.nativeAdDelegate willCloseAd];
}

- (void)adNativeDidDismiss:(FlurryAdNative *)nativeAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.nativeAdDelegate didCloseAd];
}

- (void)adNativeDidReceiveClick:(FlurryAdNative *)nativeAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.nativeAdDelegate adWasClicked];
}

@end
