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
#import "ANLogging.h"
#import "ANGlobal.h"
#import "ANProxyViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

NSString *const kANAdAdapterNativeAdMobNativeAppInstallAdKey = @"kANAdAdapterNativeAdMobNativeAppInstallAdKey";
NSString *const kANAdAdapterNativeAdMobNativeContentKey = @"kANAdAdapterNativeAdMobNativeContentKey";
NSString *const kANAdAdapterNativeAdMobAdTypeKey = @"kANAdAdapterNativeAdMobAdTypeKey";

@interface ANAdAdapterNativeAdMob () <GADNativeAppInstallAdLoaderDelegate,
GADNativeContentAdLoaderDelegate, GADNativeAdDelegate>

@property (nonatomic) GADAdLoader *nativeAdLoader;
@property (nonatomic) ANProxyViewController *proxyViewController;
@property (nonatomic) GADNativeAppInstallAd *nativeAppInstallAd;
@property (nonatomic) GADNativeContentAd *nativeContentAd;

@end

@implementation ANAdAdapterNativeAdMob

@synthesize requestDelegate = _requestDelegate;
@synthesize nativeAdDelegate = _nativeAdDelegate;
@synthesize expired = _expired;

static BOOL nativeAppInstallAdsEnabled = NO;
static BOOL nativeContentAdsEnabled = NO;

+ (void)enableNativeAppInstallAds {
    nativeAppInstallAdsEnabled = YES;
}

+ (void)enableNativeContentAds {
    nativeContentAdsEnabled = YES;
}

#pragma mark - ANNativeCustomAdapter

- (instancetype)init {
    if (self = [super init]) {
        self.proxyViewController = [[ANProxyViewController alloc] init];
    }
    return self;
}

- (void)requestNativeAdWithServerParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)adUnitId
                       targetingParameters:(ANTargetingParameters *)targetingParameters {
    NSMutableArray *adTypes = [[NSMutableArray alloc] init];
    if (nativeAppInstallAdsEnabled) {
        [adTypes addObject:kGADAdLoaderAdTypeNativeAppInstall];
    } else if (nativeContentAdsEnabled) {
        [adTypes addObject:kGADAdLoaderAdTypeNativeContent];
    }
    if (adTypes.count == 0) {
        ANLogDebug(@"No AdMob Native Ad types enabled –– did you forget to call [ANAdAdapterNativeAdMob enableNativeAppInstallAds] or [ANAdAdapterNativeAdMob enableNativeContentAds]?");
        [self.requestDelegate didFailToLoadNativeAd:ANAdResponseMediatedSDKUnavailable];
        return;
    }
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.nativeAdLoader = [[GADAdLoader alloc] initWithAdUnitID:adUnitId
                                             rootViewController:(UIViewController *)self.proxyViewController
                                                        adTypes:[adTypes copy]
                                                        options:@[]];
    self.nativeAdLoader.delegate = self;
    [self.nativeAdLoader loadRequest:[ANAdAdapterBaseDFP googleAdRequestFromTargetingParameters:targetingParameters]];
}

- (void)registerViewForImpressionTrackingAndClickHandling:(UIView *)view
                                   withRootViewController:(UIViewController *)rvc
                                           clickableViews:(NSArray *)clickableViews {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.proxyViewController.rootViewController = rvc;
    self.proxyViewController.adView = view;
    if (self.nativeAppInstallAd) {
        if ([view isKindOfClass:[GADNativeAppInstallAdView class]]) {
            GADNativeAppInstallAdView *nativeAppInstallAdView = (GADNativeAppInstallAdView *)view;
            [nativeAppInstallAdView setNativeAppInstallAd:self.nativeAppInstallAd];
        } else {
            ANLogError(@"Could not register native ad view––expected a view which is a subclass of GADNativeAppInstallAdView");
        }
        return;
    }
    if (self.nativeContentAd) {
        if ([view isKindOfClass:[GADNativeContentAdView class]]) {
            GADNativeContentAdView *nativeContentAdView = (GADNativeContentAdView *)view;
            [nativeContentAdView setNativeContentAd:self.nativeContentAd];
        } else {
            ANLogError(@"Could not register native ad view––expected a view which is a subclass of GADNativeContentAdView");
        }
        return;
    }
}

#pragma mark - GADAdLoaderDelegate

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ANLogError(@"Error loading Google native ad: %@", error);
    ANAdResponseCode code = [ANAdAdapterBaseDFP responseCodeFromRequestError:error];
    [self.requestDelegate didFailToLoadNativeAd:code];
}

#pragma mark - GADNativeAppInstallAdLoaderDelegate

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAppInstallAd:(GADNativeAppInstallAd *)nativeAppInstallAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.nativeAppInstallAd = nativeAppInstallAd;
    ANNativeMediatedAdResponse *response = [[ANNativeMediatedAdResponse alloc] initWithCustomAdapter:self
                                                                                         networkCode:ANNativeAdNetworkCodeAdMob];
    nativeAppInstallAd.delegate = self;
    response.title = nativeAppInstallAd.headline;
    response.body = nativeAppInstallAd.body;
    response.iconImageURL = nativeAppInstallAd.icon.imageURL;
    response.mainImageURL = ((GADNativeAdImage *)[nativeAppInstallAd.images firstObject]).imageURL;
    response.callToAction = nativeAppInstallAd.callToAction;
    response.rating = [[ANNativeAdStarRating alloc] initWithValue:[nativeAppInstallAd.starRating floatValue]
                                                            scale:5.0];
    response.socialContext = nativeAppInstallAd.store;
    response.customElements = @{kANAdAdapterNativeAdMobNativeAppInstallAdKey:nativeAppInstallAd,
                                kANAdAdapterNativeAdMobAdTypeKey:@(ANAdAdapterNativeAdMobAdTypeInstall)};
    [self.requestDelegate didLoadNativeAd:response];
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeContentAd:(GADNativeContentAd *)nativeContentAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.nativeContentAd = nativeContentAd;
    ANNativeMediatedAdResponse *response = [[ANNativeMediatedAdResponse alloc] initWithCustomAdapter:self
                                                                                         networkCode:ANNativeAdNetworkCodeAdMob];
    nativeContentAd.delegate = self;
    response.title = nativeContentAd.headline;
    response.body = nativeContentAd.body;
    response.iconImageURL = nativeContentAd.logo.imageURL;
    response.mainImageURL = ((GADNativeAdImage *)[nativeContentAd.images firstObject]).imageURL;
    response.callToAction = nativeContentAd.callToAction;
    response.customElements = @{kANAdAdapterNativeAdMobNativeContentKey:nativeContentAd,
                                kANAdAdapterNativeAdMobAdTypeKey:@(ANAdAdapterNativeAdMobAdTypeContent)};
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

@end