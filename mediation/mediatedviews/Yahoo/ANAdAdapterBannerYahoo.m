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

#import "ANAdAdapterBannerYahoo.h"
#import "FlurryAdBanner.h"
#import "FlurryAdBannerDelegate.h"
#import "ANAdAdapterBaseYahoo+PrivateMethods.h"
#import "ANLogging.h"

@interface ANAdAdapterBannerYahoo () <FlurryAdBannerDelegate>

@property (nonatomic, readwrite, strong) FlurryAdBanner *banner;
@property (nonatomic, readwrite, strong) UIView *wrapperView;
@property (nonatomic, readwrite, weak) UIViewController *rootViewController;

@end

@implementation ANAdAdapterBannerYahoo

@synthesize delegate = _delegate;

- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(UIViewController *)rootViewController
                serverParameter:(NSString *)parameterString
                       adUnitId:(NSString *)idString
            targetingParameters:(ANTargetingParameters *)targetingParameters {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (!idString.length) {
        ANLogDebug(@"Unable to fetch Flurry banner ad - no space provided or space was empty");
        [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
        return;
    }
    if (!rootViewController) {
        ANLogDebug(@"Unable to fetch Flurry banner ad - rootViewController is nil");
        [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
        return;
    }
    self.wrapperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    self.banner = [[FlurryAdBanner alloc] initWithSpace:idString];
    self.banner.adDelegate = self;
    self.banner.targeting = [ANAdAdapterBaseYahoo adTargetingWithTargetingParameters:targetingParameters];
    self.rootViewController = rootViewController;
    [self.banner fetchAdForFrame:self.wrapperView.frame];
}

- (void)dealloc {
    self.banner.adDelegate = nil;
}

#pragma mark - FlurryAdBannerDelegate

- (void)adBannerDidFetchAd:(FlurryAdBanner *)bannerAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (self.rootViewController) {
        [self.banner displayAdInView:self.wrapperView
       viewControllerForPresentation:self.rootViewController];
    } else {
        ANLogDebug(@"Unable to render Flurry banner ad - rootViewController is nil");
        [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
    }
}

- (void)adBanner:(FlurryAdBanner *)bannerAd
         adError:(FlurryAdError)adError
errorDescription:(NSError *)errorDescription {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    switch (adError) {
        case FLURRY_AD_ERROR_CLICK_ACTION_FAILED:
            ANLogDebug(@"%@ Ignored Flurry error: %@", NSStringFromSelector(_cmd), errorDescription);
            return;
        case FLURRY_AD_ERROR_DID_FAIL_TO_FETCH_AD:
        case FLURRY_AD_ERROR_DID_FAIL_TO_RENDER:
            ANLogDebug(@"%@ Flurry banner load failed with error: %@", NSStringFromSelector(_cmd), errorDescription);
            [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
            break;
        default:
            ANLogDebug(@"%@ Unhandled Flurry error: %@", NSStringFromSelector(_cmd), errorDescription);
            break;
    }
}

- (void)adBannerDidRender:(FlurryAdBanner *)bannerAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didLoadBannerAd:self.wrapperView];
}

- (void)adBannerWillPresentFullscreen:(FlurryAdBanner *)bannerAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willPresentAd];
}

- (void)adBannerWillLeaveApplication:(FlurryAdBanner *)bannerAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willLeaveApplication];
}

- (void)adBannerWillDismissFullscreen:(FlurryAdBanner *)bannerAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willCloseAd];
}

- (void)adBannerDidDismissFullscreen:(FlurryAdBanner *)bannerAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didCloseAd];
}

- (void)adBannerDidReceiveClick:(FlurryAdBanner *)bannerAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate adWasClicked];
}

- (void)adBannerVideoDidFinish:(FlurryAdBanner *)bannerAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing. Expect that adBannerDidDismissFullscreen will be called.
}

@end