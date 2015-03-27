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

#import <UIKit/UIKit.h>
#import "ANBannerAdView.h"
#import "ANInterstitialAd.h"
#import "ANMediatedAd.h"

@interface ANMediationAdapterViewController : UIViewController

- (ANBannerAdView *)loadFacebookBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate;
- (ANInterstitialAd *)loadFacebookInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate;

- (ANBannerAdView *)loadAmazonBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate;
- (ANInterstitialAd *)loadAmazonInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate;

- (ANBannerAdView *)loadiAdBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate;
- (ANInterstitialAd *)loadiAdInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate;

- (ANBannerAdView *)loadAdMobBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate;
- (ANInterstitialAd *)loadAdMobInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate;

- (ANBannerAdView *)loadDFPBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate;
- (ANInterstitialAd *)loadDFPInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate;

- (ANBannerAdView *)loadInMobiBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate;
- (ANInterstitialAd *)loadInMobiInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate;

- (ANBannerAdView *)loadMillennialMediaBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate;
- (ANInterstitialAd *)loadMillennialMediaInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate;

- (ANBannerAdView *)loadMoPubBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate;
- (ANInterstitialAd *)loadMoPubInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate;

- (void)stubMediatedAd:(ANMediatedAd *)mediatedAd;
- (ANBannerAdView *)bannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate
                             frameSize:(CGSize)frameSize
                                adSize:(CGSize)adSize;

@end