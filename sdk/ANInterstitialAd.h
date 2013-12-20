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

// This is the interface through which interstitial ads are (1)
// fetched and then (2) shown.  These are distinct steps.  Here's an
// example:

//       // Make an interstitial ad.
//       self.inter = [[ANInterstitialAd alloc] initWithPlacementId:@"1281482"];
//
//       // We set ourselves as the delegate so we can respond to the
//       // required `adDidReceiveAd' message of the
//       // `ANInterstitialAdDelegate' protocol (see the bottom of this
//       // file for an example)
//       self.inter.delegate = self;
//
//       // Fetch an ad in the background.  In order to show the ad,
//       // you'll need to implement `adDidReceiveAd' (see below).
//       [self.inter loadAd];
@interface ANInterstitialAd : ANAdView

@property (nonatomic, readwrite, weak) id<ANInterstitialAdDelegate> delegate;
@property (nonatomic, readwrite, strong) UIColor *backgroundColor;
@property (nonatomic, readonly, assign) BOOL isReady;
@property (nonatomic, readwrite, assign) NSTimeInterval closeDelay;

- (id)initWithPlacementId:(NSString *)placementId;
- (void)loadAd;
- (void)displayAdFromViewController:(UIViewController *)controller;

@end

// Your view controller needs to conform to this protocol by
// implementing the `adDidReceiveAd' method.  Here's a sample
// implementation:
//
//     - (void)adDidReceiveAd:(id<ANAdProtocol>)ad
//     {
//         [self.inter displayAdFromViewController:self];
//     }
//
@protocol ANInterstitialAdDelegate <ANAdDelegate>
- (void)adFailedToDisplay:(ANInterstitialAd *)ad;
@end
