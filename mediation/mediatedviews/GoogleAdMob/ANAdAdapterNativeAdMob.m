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

#import "ANAdAdapterNativeAdMob.h"
#import "ANAdAdapterBaseDFP.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#if __has_include(<AppNexusSDK/AppNexusSDK.h>)
#import <AppNexusSDK/AppNexusSDK.h>
#else
#import "ANProxyViewController.h"
#endif

@interface ANAdAdapterNativeAdMob () <GADNativeAdLoaderDelegate, GADNativeAdDelegate>

@property (nonatomic) GADAdLoader *nativeAdLoader;
@property (nonatomic) ANProxyViewController *proxyViewController;
@property (nonatomic) GADNativeAd *nativeAd;

@end

@implementation ANAdAdapterNativeAdMob

@synthesize requestDelegate = _requestDelegate;
@synthesize nativeAdDelegate = _nativeAdDelegate;
@synthesize expired = _expired;


#pragma mark - ANNativeCustomAdapter

- (instancetype)init {
    if (self = [super init]) {
        self.proxyViewController = [[ANProxyViewController alloc] init];
    }
    return self;
}

- (void)requestNativeAdWithServerParameter:(nullable NSString *)parameterString
                                  adUnitId:(nullable NSString *)adUnitId
                       targetingParameters:(nullable ANTargetingParameters *)targetingParameters {


    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.nativeAdLoader = [[GADAdLoader alloc] initWithAdUnitID:adUnitId
                                             rootViewController:(UIViewController *)self.proxyViewController
                                                        adTypes:@[GADAdLoaderAdTypeNative]
                                                        options:@[]];
    self.nativeAdLoader.delegate = self;
    [self.nativeAdLoader loadRequest:[ANAdAdapterBaseDFP googleAdMobRequestFromTargetingParameters:targetingParameters rootViewController:nil]];
}

- (void)registerViewForImpressionTrackingAndClickHandling:(nonnull UIView *)view
                                   withRootViewController:(nonnull UIViewController *)rvc
                                           clickableViews:(nullable NSArray *)clickableViews {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.proxyViewController.rootViewController = rvc;
    self.proxyViewController.adView = view;
    if (self.nativeAd) {
        if ([view isKindOfClass:[GADNativeAdView class]]) {
            GADNativeAdView *nativeContentAdView = (GADNativeAdView *)view;
            [nativeContentAdView setNativeAd:self.nativeAd];
        } else {
            ANLogError(@"Could not register native ad view––expected a view which is a subclass of GADNativeAdView");
        }
        return;
    }
}

#pragma mark - GADAdLoaderDelegate

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ANLogError(@"Error loading Google native ad: %@", error);
    [self.requestDelegate didFailToLoadNativeAd:[ANAdAdapterBaseDFP responseCodeFromRequestError:error]];
}

#pragma mark - GADNativeAppInstallAdLoaderDelegate

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd
{
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.nativeAd = nativeAd;
    ANNativeMediatedAdResponse *response = [[ANNativeMediatedAdResponse alloc] initWithCustomAdapter:self
                                                                                         networkCode:ANNativeAdNetworkCodeAdMob];
    nativeAd.delegate = self;
    response.title = nativeAd.headline;
    response.body = nativeAd.body;
    response.iconImageURL = nativeAd.icon.imageURL;
    response.mainImageURL = ((GADNativeAdImage *)[nativeAd.images firstObject]).imageURL;
    response.callToAction = nativeAd.callToAction;
    response.rating = [[ANNativeAdStarRating alloc] initWithValue:[nativeAd.starRating floatValue]
                                                            scale:5.0];
    response.customElements = @{kANNativeElementObject:nativeAd};
    [self.requestDelegate didLoadNativeAd:response];
}

#pragma mark - GADNativeAdDelegate

- (void)nativeAdWillPresentScreen:(GADNativeAd *)nativeAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.nativeAdDelegate willPresentAd];
    [self.nativeAdDelegate didPresentAd];
}

- (void)nativeAdWillDismissScreen:(GADNativeAd *)nativeAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.nativeAdDelegate willCloseAd];
}

- (void)nativeAdDidDismissScreen:(GADNativeAd *)nativeAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.nativeAdDelegate didCloseAd];
}

- (void)nativeAdWillLeaveApplication:(GADNativeAd *)nativeAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.nativeAdDelegate willLeaveApplication];
}

- (void)nativeAdDidRecordImpression:(GADNativeAd *)nativeAd{
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.nativeAdDelegate adDidLogImpression];
}

@end
