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

#import "ANAdAdapterNativeFacebook.h"
#import "ANLogging.h"



@interface ANAdAdapterNativeFacebook ()

@property (nonatomic) FBNativeAd *fbNativeAd;

@end




@implementation ANAdAdapterNativeFacebook

@synthesize requestDelegate = _requestDelegate;
@synthesize nativeAdDelegate = _nativeAdDelegate;
@synthesize expired = _expired;



#pragma mark - ANNativeCustomAdapter

- (void)requestNativeAdWithServerParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)adUnitId
                       targetingParameters:(ANTargetingParameters *)targetingParameters
{
    self.fbNativeAd = [[FBNativeAd alloc] initWithPlacementID:adUnitId];
    self.fbNativeAd.delegate = self;

    [self.fbNativeAd loadAd];
}

- (void)registerViewForImpressionTrackingAndClickHandling:(UIView *)view
                                   withRootViewController:(UIViewController *)rvc
                                           clickableViews:(NSArray *)clickableViews {
    if (clickableViews.count) {
        [self.fbNativeAd registerViewForInteraction:view
                                 withViewController:rvc
                                 withClickableViews:clickableViews];
    } else {
        [self.fbNativeAd registerViewForInteraction:view
                                 withViewController:rvc];
    }
}

- (void)dealloc {
    [self unregisterViewFromTracking];
}

- (BOOL)hasExpired {
    return ![self.fbNativeAd isAdValid];
}

- (void)unregisterViewFromTracking {
    [self.fbNativeAd unregisterView];
    self.fbNativeAd = nil;
}



#pragma mark - FBNativeAdDelegate

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error {
    ANLogError(@"Error loading Facebook native ad: %@", error);
    ANAdResponseCode code = ANAdResponseInternalError;
    if (error.code == 1001) {
        code = ANAdResponseUnableToFill;
    }
    [self.requestDelegate didFailToLoadNativeAd:code];
}

- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd {
    ANNativeMediationAdResponse *response = [[ANNativeMediationAdResponse alloc] initWithCustomAdapter:self
                                                                                         networkCode:ANNativeAdNetworkCodeFacebook];
    response.title = nativeAd.title;
    response.body = nativeAd.body;
    response.iconImageURL = nativeAd.icon.url;
    response.mainImageURL = nativeAd.coverImage.url;
    response.callToAction = nativeAd.callToAction;
    response.rating = [[ANNativeAdStarRating alloc] initWithValue: nativeAd.starRating.value
                                                            scale: nativeAd.starRating.scale ];
    response.socialContext = nativeAd.socialContext;
    [self.requestDelegate didLoadNativeAd:response];
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd {
    [self.nativeAdDelegate adWasClicked];
    [self.nativeAdDelegate willPresentAd];
    [self.nativeAdDelegate didPresentAd];
}

- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd {
    [self.nativeAdDelegate willCloseAd];
    [self.nativeAdDelegate didCloseAd];
}

@end
