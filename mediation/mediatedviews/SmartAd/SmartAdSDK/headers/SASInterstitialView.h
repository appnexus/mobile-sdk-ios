//
//  SASInterstitialView.h
//  SmartAdServer
//
//  Created by Clémence Laurent on 09/03/12.
//  Copyright (c) 2012 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASAdView.h"
#import "SASAdViewDelegate.h"


/** The SASInterstitialView class provides a wrapper view that displays an ad interstitial to the user.
 
 When the user taps a SASInterstitialView instance, the view triggers an action programmed into the advertisement.
 For example, an advertisement might, present a modal advertisement, show a movie, or launch a third party application (Safari, the App Store, YouTube...).
 Your application is notified by the **SASAdViewDelegate protocol** methods which are called during the ad's lifecycle.
 You can interact with the view by 
 
 - refreshing it: refresh
 - removing it: removeFromSuperView
 
 The delegate of a SASInterstitialView object must adopt the SASAdViewDelegate protocol.
 The protocol methods allow the delegate to be aware of the ad-related events.
 You can use it to handle your app's or the ad's (the SASInterstitialView instance) behavior like adapting your viewController's view size depending on the ad being displayed or not.
 
 */

@class SASAd;
@interface SASInterstitialView : SASAdView


///-----------------------------------------
/// @name Creating an insterstitial view
///-----------------------------------------


/** Initializes and returns a SASInterstitialView object for the given frame.
 
 @param frame A rectangle specifying the initial location and size of the ad interstitial view in its superview's coordinates.
 The frame of the table view changes when it loads an expand format.
 
 */

- (nonnull id)initWithFrame:(CGRect)frame;

/** Initializes and returns a SASInterstitialView object for the given frame, and optionally sets a loader on it.
 
 @param frame A rectangle specifying the initial location and size of the ad interstitial view in its superview's coordinates. The frame of the table view changes when it loads an expand format. 
 @param loaderType An SASLoader that determines which loader the view should display while downloading the ad. It can take the following values:
 
	typedef enum {
 SASLoaderNone,
 SASLoaderActivityIndicatorStyleBlack,
 SASLoaderActivityIndicatorStyleWhite,
 SASLoaderActivityIndicatorStyleTransparent
	} SASLoader;
 
 `SASLoaderNone`
 
 Default loader. No loader is displayed.
 
 `SASLoaderActivityIndicatorStyleBlack`
 
 The loader consists of a black view with a yellow loader.
 
 `SASLoaderActivityIndicatorStyleWhite`
 
 The loader consists of a white view with a yellow loader.
 
 `SASLoaderActivityIndicatorStyleTransparent`
 
 The loader consists of a black semi-transparent view with a yellow loader.
 
 */

- (nonnull id)initWithFrame:(CGRect)frame loader:(SASLoader)loaderType;


///-----------------------------------
/// @name Prefetching an interstitial
///-----------------------------------

/** Prefetches an interstitial from Smart AdServer cache in offline or online mode.
 
 Call this method after initializing your SASInterstitialView object with an initWithFrame: to load the appropriate SASAd object from the server and display the previously prefetched ad.
 The SASInterstitialView will fail, and notify the delegate if the timeout expires.
 
 @param formatId The format ID in the Smart AdServer manage interface.
 @param pageId The page ID in the Smart AdServer manage interface.
 @param isMaster The master flag. If this is YES, the a Page view will be counted. This should have the YES value for the first ad on the page, and NO for the others (if you have more than one ad on the same page).
 @param target If you specified targets in the Smart AdServer manage interface, you can send it here to target your advertisement.
 
 */

- (void)prefetchFormatId:(NSInteger)formatId pageId:(nonnull NSString *)pageId master:(BOOL)isMaster target:(nullable NSString *)target;


/** Clears the cache used by the prefetched placement.
 
 */

+ (void)clearPrefetchCache;

@end
