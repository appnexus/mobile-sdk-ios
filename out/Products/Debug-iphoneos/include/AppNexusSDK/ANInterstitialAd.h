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

@protocol ANInterstitialAdDelegate;

@interface ANInterstitialAd : ANAdView

@property (nonatomic, readwrite, weak) id<ANInterstitialAdDelegate> delegate;
@property (nonatomic, readwrite, strong) UIColor *backgroundColor;
@property (nonatomic, readonly, assign) BOOL isReady;
@property (nonatomic, readwrite, assign) NSTimeInterval closeDelay;

- (id)initWithPlacementId:(NSString *)placementId;
- (void)loadAd;
- (void)displayAdFromViewController:(UIViewController *)controller;

@end

@protocol ANInterstitialAdDelegate <ANAdDelegate>
- (void)adFailedToDisplay:(ANInterstitialAd *)ad;
@end
