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

#import <AmazonAd/AmazonAdOptions.h>
#import <AmazonAd/AmazonAdError.h>
#import "ANAdAdapterBannerAmazon.h"
#import "ANLogging.h"

@interface ANAdAdapterBannerAmazon ()
@property (nonatomic, weak) UIViewController *rootViewController;
@property (nonatomic) AmazonAdView *adView;
@end

@implementation ANAdAdapterBannerAmazon


@synthesize delegate = _delegate;

- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(UIViewController *)rootViewController
                serverParameter:(NSString *)parameterString
                       adUnitId:(NSString *)idString
            targetingParameters:(ANTargetingParameters *)targetingParameters {
    ANLogDebug(@"Requesting Amazon banner with size: %@", NSStringFromCGSize(size));
    AmazonAdView *adView = [AmazonAdView amazonAdViewWithAdSize:size];
    adView.delegate = self;
    self.rootViewController = rootViewController;
    [adView loadAd:[self adOptionsForTargetingParameters:targetingParameters]];
    self.adView = adView;
}

- (UIViewController *)viewControllerForPresentingModalView {
    return self.rootViewController;
}

- (void)adViewDidLoad:(AmazonAdView *)view {
    ANLogDebug(@"Amazon banner did load");
    [self.delegate didLoadBannerAd:view];
}

- (void)adViewDidFailToLoad:(AmazonAdView *)view
                  withError:(AmazonAdError *)error {
    ANLogDebug(@"Amazon banner did fail to load");
    [self handleAmazonError:error];
}

- (void)adViewWillExpand:(AmazonAdView *)view {
    ANLogDebug(@"Amazon banner will expand");
    [self.delegate willPresentAd];
    [self.delegate didPresentAd];
}

- (void)adViewDidCollapse:(AmazonAdView *)view {
    ANLogDebug(@"Amazon banner will collapse");
    [self.delegate willCloseAd];
    [self.delegate didCloseAd];
}

- (void)adViewWillResize:(AmazonAdView *)view toFrame:(CGRect)frame {
    ANLogDebug(@"Amazon view will resize to frame: %@", NSStringFromCGRect(frame));
    // Do nothing.
}

- (BOOL)willHandleAdViewResize:(AmazonAdView *)view toFrame:(CGRect)frame {
    return NO;
}

- (void)dealloc {
    self.adView.delegate = nil; // clearing unsafe_unretained property
}

@end
