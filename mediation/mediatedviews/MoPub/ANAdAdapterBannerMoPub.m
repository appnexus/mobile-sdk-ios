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

#import "ANAdAdapterBannerMoPub.h"

@interface ANAdAdapterBannerMoPub ()

@property (nonatomic, strong) MPAdView *adView;
@property (nonatomic, weak) UIViewController *rootViewController;

@end

@implementation ANAdAdapterBannerMoPub

@synthesize delegate;

- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(nullable UIViewController *)rootViewController
                serverParameter:(nullable NSString *)parameterString
                       adUnitId:(nullable NSString *)idString
            targetingParameters:(nullable ANTargetingParameters *)targetingParameters {
    if ([MoPub sharedInstance].isSdkInitialized)
    {
        [self initialseBannerAdWithSize:size rootViewController:rootViewController serverParameter:parameterString adUnitId:idString targetingParameters:targetingParameters];
    }
    else
    {
        MPMoPubConfiguration * sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization: idString];
        [[MoPub sharedInstance] initializeSdkWithConfiguration:sdkConfig completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self initialseBannerAdWithSize:size rootViewController:rootViewController serverParameter:parameterString adUnitId:idString targetingParameters:targetingParameters];
            });
        }];
    }
}

- (void) initialseBannerAdWithSize:(CGSize)size
                rootViewController:(UIViewController *)rootViewController
                   serverParameter:(NSString *)parameterString
                          adUnitId:(NSString *)idString
               targetingParameters:(ANTargetingParameters *)targetingParameters {
    self.adView = [[MPAdView alloc] initWithAdUnitId:idString];
    self.adView.delegate = self;
    self.adView.location = [self locationFromTargetingParameters:targetingParameters];
    self.adView.keywords = [self keywordsFromTargetingParameters:targetingParameters];
    self.rootViewController = rootViewController;
    [self.adView loadAdWithMaxAdSize:size];
}

- (void)dealloc {
    self.adView.delegate = nil;
}

#pragma mark - MPAdViewDelegate

- (UIViewController *)viewControllerForPresentingModalView {
    return self.rootViewController;
}

- (void)adViewDidLoadAd:(MPAdView *)view adSize:(CGSize)adSize{
    self.adView.frame = ({
        CGRect frame = self.adView.frame;
        frame.size.height = adSize.height;
        frame;
    });
    [self.delegate didLoadBannerAd:self.adView];
}

- (void)adView:(MPAdView *)view didFailToLoadAdWithError:(NSError *)error{
    [self.delegate didFailToLoadAd:ANAdResponseCode.UNABLE_TO_FILL];
}

- (void)willPresentModalViewForAd:(MPAdView *)view {
    [self.delegate willPresentAd];
}

- (void)didDismissModalViewForAd:(MPAdView *)view {
    [self.delegate didCloseAd];
}

- (void)willLeaveApplicationFromAd:(MPAdView *)view {
    [self.delegate willLeaveApplication];
}

@end
