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
#import <GoogleMobileAds/GoogleMobileAds.h>

NSString *const kANAdAdapterNativeAdMobNativeAppInstallAdKey = @"kANAdAdapterNativeAdMobNativeAppInstallAdKey";
NSString *const kANAdAdapterNativeAdMobNativeContentKey = @"kANAdAdapterNativeAdMobNativeContentKey";

@interface ANAdAdapterNativeAdMob () <GADNativeAppInstallAdLoaderDelegate, GADNativeContentAdLoaderDelegate>

@property (nonatomic) GADAdLoader *nativeAdLoader;

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
        ANLogDebug(@"No AdMob Native Ad types enabled –– did you forget to call ANAdAdapterNativeAdMob.enableNativeAppInstallAds or ANAdAdapterNativeAdMob.enableNativeContentAds?");
        [self.requestDelegate didFailToLoadNativeAd:ANAdResponseMediatedSDKUnavailable];
        return;
    }
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.nativeAdLoader = [[GADAdLoader alloc] initWithAdUnitID:adUnitId
                                             rootViewController:nil
                                                        adTypes:[adTypes copy]
                                                        options:@[]];
    self.nativeAdLoader.delegate = self;
    [self.nativeAdLoader loadRequest:[ANAdAdapterBaseDFP googleAdRequestFromTargetingParameters:targetingParameters]];
}

- (void)registerViewForImpressionTrackingAndClickHandling:(UIView *)view
                                   withRootViewController:(UIViewController *)rvc
                                           clickableViews:(NSArray *)clickableViews {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
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
    ANNativeMediatedAdResponse *response = [[ANNativeMediatedAdResponse alloc] initWithCustomAdapter:self
                                                                                         networkCode:ANNativeAdNetworkCodeAdMob];
    response.title = nativeAppInstallAd.headline;
    response.body = nativeAppInstallAd.body;
    response.iconImageURL = nativeAppInstallAd.icon.imageURL;
    response.mainImageURL = ((GADNativeAdImage *)[nativeAppInstallAd.images firstObject]).imageURL;
    response.callToAction = nativeAppInstallAd.callToAction;
    response.rating = [[ANNativeAdStarRating alloc] initWithValue:[nativeAppInstallAd.starRating floatValue]
                                                            scale:5.0];
    response.socialContext = nativeAppInstallAd.store;
    response.customElements = @{kANAdAdapterNativeAdMobNativeAppInstallAdKey:nativeAppInstallAd};
    [self.requestDelegate didLoadNativeAd:response];
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeContentAd:(GADNativeContentAd *)nativeContentAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ANNativeMediatedAdResponse *response = [[ANNativeMediatedAdResponse alloc] initWithCustomAdapter:self
                                                                                         networkCode:ANNativeAdNetworkCodeAdMob];
    response.title = nativeContentAd.headline;
    response.body = nativeContentAd.body;
    response.iconImageURL = nativeContentAd.logo.imageURL;
    response.mainImageURL = ((GADNativeAdImage *)[nativeContentAd.images firstObject]).imageURL;
    response.callToAction = nativeContentAd.callToAction;
    response.customElements = @{kANAdAdapterNativeAdMobNativeContentKey:nativeContentAd};
    [self.requestDelegate didLoadNativeAd:response];
}

@end