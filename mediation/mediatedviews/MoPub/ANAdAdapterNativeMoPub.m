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

#import "ANAdAdapterNativeMoPub.h"
#import "MPNativeAdRequest.h"
#import "MPNativeAd.h"
#import "MPNativeAdConstants.h"
#import "MPNativeAdRequestTargeting.h"
#import <CoreLocation/CoreLocation.h>
#import "ANLogging.h"
#import "MPNativeAdDelegate.h"

@interface ANAdAdapterNativeMoPub () <MPNativeAdDelegate>

@property (nonatomic, readwrite, strong) MPNativeAd *nativeAd;
@property (nonatomic, readwrite, weak) UIViewController *rootViewController;

@end

@implementation ANAdAdapterNativeMoPub

@synthesize requestDelegate = _requestDelegate;
@synthesize nativeAdDelegate = _nativeAdDelegate;
@synthesize expired = _expired;

- (void)requestNativeAdWithServerParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)adUnitId
                       targetingParameters:(ANTargetingParameters *)targetingParameters {
    MPNativeAdRequest *nativeAdRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:adUnitId];
    MPNativeAdRequestTargeting *targeting = [MPNativeAdRequestTargeting targeting];
    targeting.location = [self locationFromTargetingParameters:targetingParameters];
    targeting.keywords = [self keywordsFromTargetingParameters:targetingParameters];
    nativeAdRequest.targeting = targeting;
    
    [nativeAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if (error) {
            ANLogError(@"Error loading MoPub native ad: %@", error);
            [self.requestDelegate didFailToLoadNativeAd:ANAdResponseInternalError];
        } else {
            [self processNativeAd:response];
        }
    }];
}

- (void)processNativeAd:(MPNativeAd *)nativeAd {
    self.nativeAd = nativeAd;
    ANNativeMediatedAdResponse *response = [[ANNativeMediatedAdResponse alloc] initWithCustomAdapter:self
                                                                                         networkCode:ANNativeAdNetworkCodeMoPub];
    response.title = nativeAd.properties[kAdTitleKey];
    response.body = nativeAd.properties[kAdTextKey];
    response.callToAction = nativeAd.properties[kAdCTATextKey];
    response.iconImageURL = [NSURL URLWithString:nativeAd.properties[kAdIconImageKey]];
    response.mainImageURL = [NSURL URLWithString:nativeAd.properties[kAdMainImageKey]];
    response.rating = [[ANNativeAdStarRating alloc] initWithValue:[nativeAd.starRating floatValue]
                                                        scale:kUniversalStarRatingScale];
    response.customElements = nativeAd.properties;
    [self.requestDelegate didLoadNativeAd:response];
}

- (NSString *)keywordsFromTargetingParameters:(ANTargetingParameters *)targetingParameters {
    NSMutableArray *keywordArray = [[NSMutableArray alloc] init];
    
    ANGender gender = targetingParameters.gender;
    switch (gender) {
        case MALE:
            [keywordArray addObject:@"m_gender:male"];
            break;
        case FEMALE:
            [keywordArray addObject:@"m_gender:female"];
            break;
        default:
            break;
    }
    
    if ([targetingParameters age]) {
        [keywordArray addObject:[NSString stringWithFormat:@"m_age:%@", targetingParameters.age]];
    }
    
    [targetingParameters.customKeywords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [keywordArray addObject:[NSString stringWithFormat:@"%@:%@", key, obj]];
    }];
    
    return [keywordArray componentsJoinedByString:@","];
}

- (CLLocation *)locationFromTargetingParameters:(ANTargetingParameters *)targetingParameters {
    ANLocation *location = targetingParameters.location;
    if (location) {
        CLLocation *mpLoc = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(location.latitude, location.longitude)
                                                          altitude:0
                                                horizontalAccuracy:location.horizontalAccuracy
                                                  verticalAccuracy:0
                                                         timestamp:location.timestamp];
        return mpLoc;
    }
    return nil;
}

#pragma mark - ANNativeCustomAdapter

- (UIViewController *)viewControllerForPresentingModalView {
    return self.rootViewController;
}

- (void)handleClickFromRootViewController:(UIViewController *)rvc {
    [self.nativeAdDelegate adWasClicked];
    [self.nativeAdDelegate willPresentAd];
    [self.nativeAdDelegate didPresentAd];
    self.rootViewController = rvc;
    self.nativeAd.delegate = self;
    [self.nativeAd displayContentWithCompletion:^(BOOL success, NSError *error) {
        if (error) {
            ANLogError(@"APPNEXUS: Error handling MoPub native ad click, %@", error);
        }
        [self.nativeAdDelegate willCloseAd];
        [self.nativeAdDelegate didCloseAd];
    }];
}

- (void)registerViewForImpressionTracking:(UIView *)view {
    [self.nativeAd prepareForDisplayInView:view];
    self.expired = YES;
}

- (void)unregisterViewFromTracking {
    self.nativeAd = nil;
}

- (void)dealloc {
    [self unregisterViewFromTracking];
}

@end