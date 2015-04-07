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

#import "ANAdAdapterBannerVdopia.h"
#import "LVDOAdSize.h"
#import "LVDOAdView.h"
#import "ANLogging.h"

static NSInteger const kANAdAdapterBannerVdopiaInvalidSize = -1;

@interface ANAdAdapterBannerVdopia ()

@property (nonatomic, readwrite, strong) LVDOAdView *adViewController;
@property (nonatomic, readwrite, assign) CGSize vdoAdSize;

@end

@implementation ANAdAdapterBannerVdopia

#pragma mark - ANCustomAdapterBanner

@synthesize delegate = _delegate;

- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(UIViewController *)rootViewController
                serverParameter:(NSString *)parameterString
                       adUnitId:(NSString *)idString
            targetingParameters:(ANTargetingParameters *)targetingParameters {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    int vdoSize = [[self class] vdoSizeForAdSize:size];
    if (vdoSize == kANAdAdapterBannerVdopiaInvalidSize) {
        ANLogDebug(@"Could not fetch ad from VDOPIA. No corresponding vdoSize for ad size %@", NSStringFromCGSize(size));
        [self.delegate didFailToLoadAd:ANAdResponseInvalidRequest];
        return;
    }
    self.vdoAdSize = size;
    self.adViewController = [[LVDOAdView alloc] initWithAdUnitId:idString
                                                            size:vdoSize
                                                        delegate:self
                                                  bannerPosition:topBanner];
    LVDOAdRequest *adRequest = [[self class] adRequestFromTargetingParameters:targetingParameters];
    [self.adViewController loadAd:adRequest];
}

#pragma mark - LVDOAdViewDelegate

- (void)adViewDidReceiveAd {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.adViewController.view setFrame:CGRectMake(0, 0, self.vdoAdSize.width, self.vdoAdSize.height)];
    [self.delegate didLoadBannerAd:self.adViewController.view];
}

- (void)adViewWillPresentScreen {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willPresentAd];
    [self.delegate didPresentAd];
}

- (void)adViewWillDismissScreen {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willCloseAd];
}

- (void)adViewDidDismissScreen {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didCloseAd];
}

- (void)dealloc {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.adViewController.delegate = nil;
}

#pragma mark - Vdopia Ad Size

+ (int)vdoSizeForAdSize:(CGSize)size {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (CGSizeEqualToSize(kVDOAdSizeBanner, size)) {
        return adSizeBanner;
    } else if (CGSizeEqualToSize(kVDOAdSizeIABMRECT, size)) {
        return adSizeIABMRECT;
    } else if (CGSizeEqualToSize(kVDOAdSizeLeaderboard, size)) {
        return adSizeLeaderboard;
    }
    return kANAdAdapterBannerVdopiaInvalidSize;
}

@end