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

@interface ViewController : UIViewController



- (ANBannerAdView *)loadAdMobBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate;
- (ANInterstitialAd *)loadAdMobInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate;

- (ANBannerAdView *)loadDFPBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate;
- (ANInterstitialAd *)loadDFPInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate;

- (ANBannerAdView *)loadAdMarvelBannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate;
- (ANInterstitialAd *) loadAdMarvelInterstitialWithDelegate:(id<ANInterstitialAdDelegate>)delegate;

- (void)stubMediatedAd:(ANMediatedAd *)mediatedAd;
- (ANBannerAdView *)bannerWithDelegate:(id<ANBannerAdViewDelegate>)delegate
                             frameSize:(CGSize)frameSize
                                adSize:(CGSize)adSize;

- (ANBannerAdView *)loadAdMobBannerResizeWithDelegate:(id<ANBannerAdViewDelegate>)delegate shouldResize:(BOOL)resize;

@end

