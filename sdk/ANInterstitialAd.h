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

#import <UIKit/UIKit.h>
#import "ANAdProtocol.h"

// List of allowed ad sizes. These must fit in the maximum size of the view, which in this case, will be the size of the window
#define kANInterstitialAdSize300x250 CGSizeMake(300,250)
#define kANInterstitialAdSize320x480 CGSizeMake(320,480)
#define kANInterstitialAdSize900x500 CGSizeMake(900,500)
#define kANInterstitialAdSize1024x1024 CGSizeMake(1024,1024)

@protocol ANInterstitialAdDelegate;

@interface ANInterstitialAd : NSObject <ANAdProtocol>

@property (nonatomic, readwrite, weak) id<ANInterstitialAdDelegate> delegate;
@property (nonatomic, readwrite, assign) NSTimeInterval autoDismissTimeInterval;

- (id)initWithPlacementId:(NSString *)placementId;
- (void)loadAd;
- (void)displayAdFromViewController:(UIViewController *)controller;

@end

@protocol ANInterstitialAdDelegate <ANAdDelegate>

- (void)adNoAdToShow:(ANInterstitialAd *)ad;

@optional
- (void)adWillPresent:(ANInterstitialAd *)ad;
- (void)adWillClose:(ANInterstitialAd *)ad;
- (void)adDidClose:(ANInterstitialAd *)ad;

@end