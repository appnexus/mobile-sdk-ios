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

#import "ANAdView.h"

#define kANBannerAdViewDefaultAutorefreshInterval 30.0
#define kANBannerAdViewMinimumAutorefreshInterval 15.0
#define kANBannerAdViewAutorefreshThreshold 0.0

@protocol ANBannerAdViewDelegate;

@interface ANBannerAdView : ANAdView

@property (nonatomic, readwrite, weak) id<ANBannerAdViewDelegate> delegate;
@property (nonatomic, readwrite, assign) NSTimeInterval autorefreshInterval;

// Initializes an ad view with the specified frame, placementId, and requested ad size (which must be smaller than the view's size)
- (id)initWithFrame:(CGRect)frame placementId:(NSString *)placementId;
- (id)initWithFrame:(CGRect)frame placementId:(NSString *)placementId adSize:(CGSize)size;

// Autoreleased constructors of the above initializers
+ (ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(NSString *)placementId;
+ (ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(NSString *)placementId adSize:(CGSize)size;

// Loads a single ad into this ad view.
- (void)loadAd;

- (void)setFrame:(CGRect)frame animated:(BOOL)animated;

@end

@protocol ANBannerAdViewDelegate <ANAdDelegate>

@optional
- (void)bannerAdView:(ANBannerAdView *)adView willResizeToFrame:(CGRect)frame;
- (void)bannerAdViewDidResize:(ANBannerAdView *)adView;

@end