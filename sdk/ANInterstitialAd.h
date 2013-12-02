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
//       // If the user clicks, open a native browser.  You can toggle
//       // this.
//       self.inter.opensInNativeBrowser = true;
//
//       // Fetch an ad in the background.  In order to show this ad,
//       // you'll need to implement `adDidReceiveAd' (see below).
//       [self.inter loadAd];
@interface ANInterstitialAd : ANAdView

@property (nonatomic, readwrite, weak) id<ANInterstitialAdDelegate> delegate;

// The ad view's background color.
@property (nonatomic, readwrite, strong) UIColor *backgroundColor;

// Whether the interstitial ad has been fetched and is ready to
// display.
@property (nonatomic, readonly, assign) BOOL isReady;

// The delay between when an interstitial ad is displayed and when the
// close button appears to the user. 10 seconds is the default; it is
// also the maximum. Setting the value to 0 allows the close button to
// appear immediately.
@property (nonatomic, readwrite, assign) NSTimeInterval closeDelay;

// Initialize the ad view, with required placement ID.  Note that
// you'll need to get a placement ID from your AppNexus representative
// or your ad network.
- (id)initWithPlacementId:(NSString *)placementId;

// Actually loads the ad into your ad view.  Note that you'll need to
// check isReady first to make sure there's an ad to show.
- (void)loadAd;

// Once you've loaded the ad into your view with loadAd, you'll show
// it to the user.  For example:

//     - (void)adDidReceiveAd:(id<ANAdProtocol>)ad
//     {
//         [self.inter displayAdFromViewController:self];
//     }
- (void)displayAdFromViewController:(UIViewController *)controller;

@end

@protocol ANInterstitialAdDelegate <ANAdDelegate>
// This method tells your ad view what to do if the ad can't be shown.
// A simple implementation used during development could just log,
// like so:

// - (void)adFailedToDisplay:(ANInterstitialAd *)ad
// {
//     NSLog(@"Oh no, the ad failed to display!");
// }
- (void)adFailedToDisplay:(ANInterstitialAd *)ad;
@end
