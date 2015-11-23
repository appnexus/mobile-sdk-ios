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

#import "ANAdAdapterBannerInMobi.h"
#import "ANAdAdapterBaseInMobi.h"
#import "ANAdAdapterBaseInMobi+PrivateMethods.h"
#import "ANLogging.h"

#import "IMBanner.h"

@interface ANAdAdapterBannerInMobi () <IMBannerDelegate>

@property (nonatomic, readwrite, strong) IMBanner *banner;

@end

@implementation ANAdAdapterBannerInMobi

@synthesize delegate = _delegate;

- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(UIViewController *)rootViewController
                serverParameter:(NSString *)parameterString
                       adUnitId:(NSString *)idString
            targetingParameters:(ANTargetingParameters *)targetingParameters {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (![ANAdAdapterBaseInMobi appId].length) {
        ANLogError(@"InMobi mediation failed. Call [ANAdAdapterBaseInMobi setInMobiAppID:@\"YOUR_PROPERTY_ID\"] to set the InMobi global App Id");
        [self.delegate didFailToLoadAd:ANAdResponseMediatedSDKUnavailable];
        return;
    }
    if (!idString.length) {
        ANLogError(@"Unable to load InMobi banner due to empty ad unit id");
        [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
        return;
    }
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    self.banner = [[IMBanner alloc] initWithFrame:frame placementId:[idString longLongValue]];
    self.banner.delegate = self;
    [self.banner shouldAutoRefresh:NO];
    self.banner.keywords = [ANAdAdapterBaseInMobi keywordsFromTargetingParameters:targetingParameters];
    self.banner.extras = targetingParameters.customKeywords;
    [ANAdAdapterBaseInMobi setInMobiTargetingWithTargetingParameters:targetingParameters];
    [self.banner load];
}

- (void)dealloc {
    self.banner.delegate = nil;
}

#pragma mark - IMBannerDelegate

- (void)bannerDidFinishLoading:(IMBanner *)banner {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didLoadBannerAd:banner];
}

- (void)banner:(IMBanner *)banner didFailToLoadWithError:(IMRequestStatus *)error {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ANLogDebug(@"Received InMobi Error: %@", error);
    [self.delegate didFailToLoadAd:[ANAdAdapterBaseInMobi responseCodeFromInMobiRequestStatus:error]];
}

- (void)banner:(IMBanner *)banner didInteractWithParams:(NSDictionary *)params {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate adWasClicked];
}

- (void)userWillLeaveApplicationFromBanner:(IMBanner *)banner {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willLeaveApplication];
}

- (void)bannerWillPresentScreen:(IMBanner *)banner {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willPresentAd];
}

- (void)bannerDidPresentScreen:(IMBanner *)banner {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didPresentAd];
}

- (void)bannerWillDismissScreen:(IMBanner *)banner {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willCloseAd];
}

- (void)bannerDidDismissScreen:(IMBanner *)banner {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didCloseAd];
}

- (void)banner:(IMBanner *)banner rewardActionCompletedWithRewards:(NSDictionary *)rewards {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // Do nothing
}

@end