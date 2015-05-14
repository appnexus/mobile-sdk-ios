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

#define kANAdAdapterBannerInMobiAdSize320w48h CGSizeMake(320,48)
#define kANAdAdapterBannerInMobiAdSize300w250h CGSizeMake(300,250)
#define kANAdAdapterBannerInMobiAdSize728w90h CGSizeMake(728,90)
#define kANAdAdapterBannerInMobiAdSize468w60h CGSizeMake(468,60)
#define kANAdAdapterBannerInMobiAdSize120w600h CGSizeMake(120,600)
#define kANAdAdapterBannerInMobiAdSize320w50h CGSizeMake(320,50)

static int const kANAdAdapterBannerInMobiInvalidAdSize = -1;

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
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    NSString *appId;
    if (idString.length) {
        appId = idString;
    } else {
        appId = [ANAdAdapterBaseInMobi appId];
    }
    int adSize = [[self class] adSizeValueForAdSize:size];
    if (adSize == kANAdAdapterBannerInMobiInvalidAdSize) {
        [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
        return;
    }
    self.banner = [[IMBanner alloc] initWithFrame:frame
                                            appId:appId
                                           adSize:adSize];
    self.banner.delegate = self;
    self.banner.refreshInterval = REFRESH_INTERVAL_OFF;
    self.banner.additionaParameters = targetingParameters.customKeywords;
    self.banner.keywords = [ANAdAdapterBaseInMobi keywordsFromTargetingParameters:targetingParameters];
    [ANAdAdapterBaseInMobi setInMobiTargetingWithTargetingParameters:targetingParameters];
    [self.banner loadBanner];
}

+ (int)adSizeValueForAdSize:(CGSize)adSize {
    if (CGSizeEqualToSize(adSize, kANAdAdapterBannerInMobiAdSize320w48h)) {
        return IM_UNIT_320x48;
    } else if (CGSizeEqualToSize(adSize, kANAdAdapterBannerInMobiAdSize300w250h)) {
        return IM_UNIT_300x250;
    } else if (CGSizeEqualToSize(adSize, kANAdAdapterBannerInMobiAdSize728w90h)) {
        return IM_UNIT_728x90;
    } else if (CGSizeEqualToSize(adSize, kANAdAdapterBannerInMobiAdSize468w60h)) {
        return IM_UNIT_468x60;
    } else if (CGSizeEqualToSize(adSize, kANAdAdapterBannerInMobiAdSize120w600h)) {
        return IM_UNIT_120x600;
    } else if (CGSizeEqualToSize(adSize, kANAdAdapterBannerInMobiAdSize320w50h)) {
        return IM_UNIT_320x50;
    } else {
        ANLogDebug(@"Invalid banner size passed to InMobi Adapter %@", NSStringFromCGSize(adSize));
    }
    
    return kANAdAdapterBannerInMobiInvalidAdSize;
}

- (void)dealloc {
    [self.banner stopLoading];
    self.banner.delegate = nil;
}

#pragma mark - IMBannerDelegate

- (void)bannerDidReceiveAd:(IMBanner *)banner {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didLoadBannerAd:banner];
}

- (void)banner:(IMBanner *)banner didFailToReceiveAdWithError:(IMError *)error {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    ANLogDebug(@"Received InMobi Error: %@", error);
    [self.delegate didFailToLoadAd:[ANAdAdapterBaseInMobi responseCodeFromInMobiError:error]];
}

- (void)bannerDidInteract:(IMBanner *)banner withParams:(NSDictionary *)dictionary {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate adWasClicked];
}

- (void)bannerWillPresentScreen:(IMBanner *)banner {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willPresentAd];
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

- (void)bannerWillLeaveApplication:(IMBanner *)banner {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willLeaveApplication];
}

@end