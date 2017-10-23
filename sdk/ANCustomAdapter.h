/*   Copyright 2013 APPNEXUS INC
 
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

#import "ANTargetingParameters.h"
#import "ANAdConstants.h"



@protocol ANCustomAdapterBannerDelegate;
@protocol ANCustomAdapterInterstitialDelegate;




@protocol ANCustomAdapterDelegate <NSObject>

- (void)didFailToLoadAd:(ANAdResponseCode)errorCode;
- (void)adWasClicked;
- (void)willPresentAd;
- (void)didPresentAd;
- (void)willCloseAd;
- (void)didCloseAd;
- (void)willLeaveApplication;

@end



@protocol ANCustomAdapter <NSObject>

@property (nonatomic, readwrite, weak) id<ANCustomAdapterDelegate> delegate;

@end



@protocol ANCustomAdapterBanner <ANCustomAdapter>

@property (nonatomic, readwrite, weak) id<ANCustomAdapterBannerDelegate, ANCustomAdapterDelegate> delegate;

- (void)requestBannerAdWithSize:(CGSize)size
             rootViewController:(UIViewController *)rootViewController
                serverParameter:(NSString *)parameterString
                       adUnitId:(NSString *)idString
            targetingParameters:(ANTargetingParameters *)targetingParameters;

@end



@protocol ANCustomAdapterInterstitial <ANCustomAdapter>

@property (nonatomic, readwrite, weak) id<ANCustomAdapterInterstitialDelegate, ANCustomAdapterDelegate> delegate;

- (void)requestInterstitialAdWithParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)idString
                       targetingParameters:(ANTargetingParameters *)targetingParameters;

- (void)presentFromViewController:(UIViewController *)viewController;

- (BOOL)isReady;

@end



@protocol ANCustomAdapterBannerDelegate <ANCustomAdapterDelegate>

- (void)didLoadBannerAd:(UIView *)view;

@end



@protocol ANCustomAdapterInterstitialDelegate <ANCustomAdapterDelegate>

- (void)didLoadInterstitialAd:(id<ANCustomAdapterInterstitial>)adapter;

- (void)failedToDisplayAd;

@end
