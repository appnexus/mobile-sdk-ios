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

#import "ANAdAdapterNativeAdColony.h"
#import "ANAdAdapterBaseAdColony+PrivateMethods.h"
#import "ANLogging.h"
#import <AdColony/AdColony.h>
#import <AdColony/AdColonyNativeAdView.h>

#import "UIView+ANCategory.h"

NSString *const kANAdAdapterNativeAdColonyVideoView = @"ANAdAdapterNativeAdColonyVideoView";

#pragma mark - ANAdColonyViewController

@interface ANAdColonyViewController : UIViewController

@property (nonatomic, readwrite, weak) UIViewController *rootViewController;

@end

@implementation ANAdColonyViewController

- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated:(BOOL)flag
                   completion:(void (^)(void))completion {
    [self.rootViewController presentViewController:viewControllerToPresent
                                          animated:flag
                                        completion:completion];
}

- (void)dismissViewControllerAnimated:(BOOL)flag
                           completion:(void (^)(void))completion {
    [self.rootViewController dismissViewControllerAnimated:flag
                                                completion:completion];
}

@end

#pragma mark - ANAdAdapterNativeAdColony

@interface ANAdAdapterNativeAdColony () <AdColonyNativeAdDelegate>

@property (nonatomic, readwrite, strong) ANAdColonyViewController *proxyViewController;

@end

@implementation ANAdAdapterNativeAdColony

@synthesize requestDelegate = _requestDelegate;
@synthesize nativeAdDelegate = _nativeAdDelegate;
@synthesize expired = _expired;

- (void)requestNativeAdWithServerParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)adUnitId
                       targetingParameters:(ANTargetingParameters *)targetingParameters {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [ANAdAdapterBaseAdColony setAdColonyTargetingWithTargetingParameters:targetingParameters];
    AdColonyNativeAdView *nativeAdView = [AdColony getNativeAdForZone:adUnitId
                                             presentingViewController:self.proxyViewController];
    if (nativeAdView) {
        ANNativeMediatedAdResponse *adResponse = [self adResponseFromNativeAdView:nativeAdView];
        [self.requestDelegate didLoadNativeAd:adResponse];
    } else {
        ADCOLONY_ZONE_STATUS zoneStatus = [AdColony zoneStatusForZone:adUnitId];
        ANAdResponseCode errorCode = ANAdResponseInternalError;
        switch (zoneStatus) {
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
        [self.requestDelegate didFailToLoadNativeAd:errorCode];
    }
}

- (ANNativeMediatedAdResponse *)adResponseFromNativeAdView:(AdColonyNativeAdView *)nativeAdView {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ANNativeMediatedAdResponse *adResponse = [[ANNativeMediatedAdResponse alloc] initWithCustomAdapter:self
                                                                                           networkCode:ANNativeAdNetworkCodeAdColony];
    adResponse.title = nativeAdView.adTitle;
    adResponse.body = nativeAdView.adDescription;
    adResponse.iconImage = nativeAdView.advertiserIcon;
    
    NSMutableDictionary *mutableCustomElements = [[NSMutableDictionary alloc] init];
    if (nativeAdView.advertiserName) {
        mutableCustomElements[kANAdAdapterNativeAdColonyVideoView] = nativeAdView;
    }
    adResponse.customElements = [mutableCustomElements copy];
    
    return adResponse;
}

- (void)registerViewForImpressionTrackingAndClickHandling:(UIView *)view
                                   withRootViewController:(UIViewController *)rvc
                                           clickableViews:(NSArray *)clickableViews {
    self.proxyViewController.rootViewController = rvc;
}

- (ANAdColonyViewController *)proxyViewController {
    if (!_proxyViewController) _proxyViewController = [[ANAdColonyViewController alloc] init];
    return _proxyViewController;
}

#pragma mark - AdColonyNativeAdDelegate

- (void)onAdColonyNativeAdStarted:(AdColonyNativeAdView *)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing
}

- (void)onAdColonyNativeAdExpanded:(AdColonyNativeAdView *)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.nativeAdDelegate adWasClicked];
    [self.nativeAdDelegate willPresentAd];
    [self.nativeAdDelegate didPresentAd];
}

- (void)onAdColonyNativeAdFinished:(AdColonyNativeAdView *)ad
                          expanded:(BOOL)expanded {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (expanded) {
        [self.nativeAdDelegate willCloseAd];
        [self.nativeAdDelegate didCloseAd];
    }
}

- (void)onAdColonyNativeAd:(AdColonyNativeAdView *)ad
          finishedWithInfo:(AdColonyAdInfo *)info
                  expanded:(BOOL)expanded {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (expanded) {
        [self.nativeAdDelegate willCloseAd];
        [self.nativeAdDelegate didCloseAd];
    }
}

- (void)onAdColonyNativeAd:(AdColonyNativeAdView *)ad
                     muted:(BOOL)muted {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing
}

- (void)onAdColonyNativeAdEngagementPressed:(AdColonyNativeAdView *)ad {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.nativeAdDelegate adWasClicked];
}

@end