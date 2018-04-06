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

/**
 This is the interface through which interstitial ads are (1)
 fetched and then (2) shown.  These are distinct steps.  Here's an
 example:
 
 @code
       // Make an interstitial ad.
       self.inter = [[ANInterstitialAd alloc] initWithPlacementId:@"1326299"];

       // We set ourselves as the delegate so we can respond to the
       // required `adDidReceiveAd' message of the
       // `ANInterstitialAdDelegate' protocol (see the bottom of this
       // file for an example)
       self.inter.delegate = self;

       // If the user clicks, open a native browser.  You can toggle
       // this.
       self.inter.opensInNativeBrowser = true;

       // Fetch an ad in the background.  In order to show this ad,
       // you'll need to implement `adDidReceiveAd' (see below).
       [self.inter loadAd];
 @endcode
 
 */
@interface ANInterstitialAd : ANAdView

@property (nonatomic, readwrite, weak) id<ANInterstitialAdDelegate> delegate;

/**
 Delegate object that receives custom app event notifications from this
 ANInterstitialAd.
 */
@property (nonatomic, readwrite, weak) id<ANAppEventDelegate> appEventDelegate;

/**
 The ad view's background color. If the color is fully or partially transparent,
 set opaque to NO to render an interstitial with a transparent background.
 
 @note: Transparent interstitial backgrounds are supported only on iOS 8 and above.
 */
@property (nonatomic, readwrite, strong) UIColor *backgroundColor;

/**
 Set to NO if the background color is fully or partially transparent. Default is YES.
 
 @note: Transparent interstitial backgrounds are supported only on iOS 8 and above.
 */
@property (nonatomic, readwrite, getter=isOpaque) BOOL opaque;

/**
 Whether the interstitial ad has been fetched and is ready to
 display.
 */
@property (nonatomic, readonly, assign) BOOL isReady;

/**
 The delay between when an interstitial ad is displayed and when the
 close button appears to the user. 10 seconds is the default; it is
 also the maximum. Setting the value to 0 allows the close button to
 appear immediately.
 */
@property (nonatomic, readwrite, assign) NSTimeInterval closeDelay;

/**
 The set of allowed ad sizes for the interstitial ad.
 The set should contain CGSize values wrapped as NSValue objects.
 */
@property (nonatomic, readwrite, strong)  NSMutableSet<NSValue *>  *allowedAdSizes;


/**
 The set of setDismissOnClick for the interstitial ad dismiss
 the interstitial ad view when the user clicks the ad
 */
@property (nonatomic, readwrite, assign) BOOL dismissOnClick;


/**
 Initialize the ad view, with required placement ID. Note that
 you'll need to get a placement ID from your AppNexus representative
 or your ad network.
 @param placementId the placement ID given from AN
 @returns void
 */
- (instancetype)initWithPlacementId:(NSString *)placementId;

/**
 Instead of requesting ads using placement id, alternatively, you can
 use the initialization method below to initialize an interstitial
 using member id and inventory code.
 */
- (instancetype)initWithMemberId:(NSInteger)memberId inventoryCode:(NSString *)inventoryCode;

/**
 Actually loads the ad into your ad view.
 */
- (void)loadAd;

/**
 Once you've loaded the ad into your view with loadAd, you'll show
 it to the user.  For example:
 
 @code
     - (void)adDidReceiveAd:(id<ANAdProtocol>)ad
     {
          if (self.inter.isReady) {
              [self.inter displayAdFromViewController:self];
          }
     }
 @endcode
 
 Technically, you don't need to implement adDidReceiveAd in order to
 display the ad; it's used here for convenience. Note that you should
 check isReady first to make sure there's an ad to show.
*/
- (void)displayAdFromViewController:(UIViewController *)controller;

/**
 Instead of displaying an interstitial to the user using displayAdFromViewController, alternatively, you can use the
 method below which will auto-dismiss the ad after the delay seconds.
 */

- (void)displayAdFromViewController:(UIViewController *)controller autoDismissDelay:(NSTimeInterval)delay;


@end

#pragma mark ANInterstitialAdDelegate

@protocol ANInterstitialAdDelegate <ANAdDelegate>

@optional
/**
 This method tells your ad view what to do if the ad can't be shown.
 A simple implementation used during development could just log,
 like so:

 @code
 - (void)adFailedToDisplay:(ANInterstitialAd *)ad
 {
     NSLog(@"Oh no, the ad failed to display!");
 }
 @endcode
 */
- (void)adFailedToDisplay:(ANInterstitialAd *)ad;
@end
