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

#import "ANAdAdapterBannerFacebook.h"

@interface ANAdAdapterBannerFacebook()

@property (nonatomic, strong) FBAdView *fbAdView;

@end

@implementation ANAdAdapterBannerFacebook

@synthesize delegate;

- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(nullable UIViewController *)rootViewController
                serverParameter:(nullable NSString *)parameterString
                       adUnitId:(nullable NSString *)idString
            targetingParameters:(nullable ANTargetingParameters *)targetingParameters {
    FBAdSize fbAdSize;
    CGRect frame;

    if (CGSizeEqualToSize(size, CGSizeMake(320, 50))) {
        fbAdSize = kFBAdSize320x50;
        frame = CGRectMake(0, 0, 320, 50);
    } else if (size.height == 50) {
        fbAdSize = kFBAdSizeHeight50Banner;
        frame = CGRectMake(0, 0, 1, 50);
    } else if (size.height == 90) {
        fbAdSize = kFBAdSizeHeight90Banner;
        frame = CGRectMake(0, 0, 1, 90);
    } else if (size.height == 250) {
        fbAdSize = kFBAdSizeHeight250Rectangle;
        frame = CGRectMake(0, 0, 1, 250);
    } else {
        [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
        return;
    }

    self.fbAdView = [[FBAdView alloc] initWithPlacementID:idString
                                                   adSize:fbAdSize
                                       rootViewController:rootViewController];
    self.fbAdView.frame = frame;
    self.fbAdView.delegate = self;
    [self.fbAdView loadAd];
}
 
#pragma mark FBAdViewDelegate methods

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error {
    ANLogDebug(@"Facebook banner failed to load with error: %@", error);
    ANAdResponseCode code = ANAdResponseInternalError;
    if (error.code == 1001) {
        code = ANAdResponseUnableToFill;
    }
    [self.delegate didFailToLoadAd:code];
}

- (void)adViewDidLoad:(FBAdView *)adView {
    [self.delegate didLoadBannerAd:adView];
}

- (void)adViewDidClick:(FBAdView *)adView {
    [self.delegate adWasClicked];
    [self.delegate willPresentAd];
    [self.delegate didPresentAd];
}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView {
    [self.delegate willCloseAd];
    [self.delegate didCloseAd];
}

- (void)adViewWillLogImpression:(FBAdView *)adView {
    ANLogDebug(@"Facebook Banner ad impression is being captured.");
}
@end
