
//
//  SASAdView.h
//  SmartAdServer
//
//  Created by Cl??mence Laurent on 20/07/12.
//  Copyright (c) 2012 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SASAdViewDelegate.h"

#define kSASSDKName							@"SDKiOS"
#define kSASSDKVersion						@"6.6"
#define kSASSDKRev                          @"64663237363936663730313632333933653534363138623331303139626335616536333730663562"

#define kSASCloseLinearMessage				@"closeLinear"


typedef void(^_Nullable DismissalAnimations)(SASAdView * _Nonnull adView);

typedef NS_ENUM(NSInteger, SASLoader) {
    SASLoaderNone,
	SASLoaderActivityIndicatorStyleBlack,
    SASLoaderActivityIndicatorStyleWhite,
    SASLoaderActivityIndicatorStyleTransparent
};


/** The SASAdView class provides a wrapper view that displays advertisements to the user.
 
 When the user taps a SASAdView instance, the view triggers an action programmed into the advertisement.
 For example, an advertisement might present a modal advertisement, show a video, or launch a third party application (Safari, the App Store, YouTube...).
 Your application is notified by the SASAdViewDelegate protocol methods which are called during the ad's lifecycle.
 You can interact with the view by:
 
 - refreshing it: refresh
 - removing it: removeFromSuperView
 
 
 The delegate of a SASAdView object must adopt the SASAdViewDelegate protocol.
 The protocol methods allow the delegate to be aware of the ad-related events.
 You can use it to handle your app's or the ad's (the SASAdView instance) behavior like adapting your UIViewController's view size depending on the ad being displayed or not.
 
 */

@class SASRequestManager, SASLoaderView, SASMRAIDBridge, SASAdViewController;
@interface SASAdView : UIView


///-----------------------------------
/// @name Ad view properties
///-----------------------------------

/** The object that acts as the delegate of the receiving ad view.
 
 The delegate must adopt the SASAdViewDelegate protocol.
 
 @warning *Important*: The delegate is not retained by the SASAdView, so you need to set the ad's delegate to nil before the delegate is released.
 
 */

@property (nonatomic, weak, nullable) id <SASAdViewDelegate> delegate;


/** The modal parent view controller is used to present the modal view controller following the ad's click.
 
 It must not be nil otherwise most post click interaction will not be able to work properly (post click modal, StoreKit, ???).
 
 @warning *Important*: The modal parent view controller is not retained by the SASAdView, so you need to set it to nil before it is released.
 
 */

@property (nonatomic, weak, nullable) UIViewController *modalParentViewController;


/** Whether the ad should stay in place (typically a banner) or be removed after a certain duration (typically an interstitial).
 
 */

@property (assign, getter = isUnlimited) BOOL unlimited;


/** Whether the ad should expand from the top to bottom.
 
 On a banner placement, "expand" formats can be loaded.
 This will cause the view to resize itself in an animated way. If you place your banner at the top of your view, set this property to YES, 
 if you place it at the bottom, set it to NO.
 
 */

@property (nonatomic, assign) BOOL expandsFromTop;


/** The animations used to dismiss the ad view.
 
 A block object containing the changes to commit to the views. This is where you programmatically change any animable properties of the views in your view hierarchy. 
 This block takes no parameters and has no return value.
 
 */

@property (nonatomic, copy) DismissalAnimations dismissalAnimations;

/**
 * Returns the timestamp used during the last loadFormatId:pageId:master:target: call.
 */

@property (nonatomic, readonly) unsigned long lastCallTimestamp;

///-----------------------------------
/// @name Global Settings
///-----------------------------------

/** Sets your app's site ID and base URL.
 
 This method should be called before initializing any SASAdView instance.
 It's only necessary to call it once in your app's life cycle.
 If you don't know your siteID or baseURL, please contact your sales house which can retrieve them from its Smart AdServer account (Sites &amp; pages).
 
 @param siteID Your site ID in the Smart AdServer manage interface.
 @param baseURL The base URL of the website redirecting to the ad server (without the ending slash).
 
 */

+ (void)setSiteID:(NSInteger)siteID baseURL:(nonnull NSString *)baseURL;


/** Sets the base URL for the ad call.
 
 If you need the call to be done on a different domain than the one previously set, use this method to specify it (if you use a CNAME for example).
 
 @param baseURL The base URL of the website redirecting to the ad server (without the ending slash).
 
 */

+ (void)setBaseURL:(nonnull NSString *)baseURL;


/** Specifies the device's location. This object incorporates the geographical coordinates and altitude of the device???s location along with values indicating
 the accuracy of the measurements and when those measurements were made.
 
 Use this method if you want to provide geo-targeted advertisement.
 For example in your CLLocationManagerDelegate:
 
     - (void)locationManager:(CLLocationManager *)locationManager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
         [SASAdView setLocation:newLocation];
     }
 
 If used, this method should be called as often as possible in order to provide up to date geo-targeting.
 
 @warning *Important:* your application can be rejected by Apple if you use the device&rsquo;s location *only* for advertising.
 Your application needs to have a feature (other than advertising) using geo-location in order to be allowed to ask for the device&rsquo;s position.
 
 @param location The device's location.
 */

+ (void)setLocation:(nonnull CLLocation *)location;


/** Enable / Disable automatic location detection by the SDK. 
 
 Default: enabled.
 
 Passing NO to this method will disable the automatic location detection by the SDK.
 Passing YES or leaving it to default will allow the SDK to check for the Location Permission, and if the permission is already granted, to request the user's current location everytime the app enters foreground.
 NB: the SDK will never ASK for the location permission on its own, it only checks whether the permission is granted or not.

 You can override the location detected automatically by using the setLocation: method.
 
 */
+ (void)setAllowAutomaticLocationDetection:(BOOL)allow;


/** Specifies the device's heading.
 
 Use this method if you want to provide heading to the creative, through the MRAID getHeading() method.
 For example in your CLLocationManagerDelegate:
 
     - (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
	     [SASAdView setHeading:newHeading.trueHeading];
     }
 
 If used, this method should be called as often as possible in order to provide up to date heading.
 
 @warning *Important:* your application can be rejected by Apple if you use the device&rsquo;s geo-location *only* for advertising.
 Your application needs to have a feature (other than advertising) using geolocation in order to be allowed to ask for the device&rsquo;s position.
 
 @param heading The device's heading.
 */

+ (void)setHeading:(CLLocationDirection)heading;


/** Enables test mode.
 
 Passing YES to this method will enable test mode and display a default ad that always deliver.
 This allows for easier development. Enable test mode in your application:didFinishLaunchingWithOptions: method:
 
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
		[SASAdView setTestModeEnabled:YES];
	}
 
 */

+ (void)setTestModeEnabled:(BOOL)testModeEnabled;


/** Enables logging mode.
 
 Passing YES to this method will enable warning and error logs in your console.
 You may want to do this if you have problems in the integration, to see where the issue is.
 Letting this in production is not optimal, as logging consumes resources.
 
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
		[SASAdView setLoggingEnabled:YES];
	}
 
 */

+ (void)setLoggingEnabled:(BOOL)loggingEnabled;


/** Enables the transient session ID (default value: YES / enabled).
 
 Passing YES will enable the transient session ID which will be generated if the IDFA is not valid.
 This transient session ID is used only for insertion capping/linking. It will not be shared with any other apps and will be
 automatically reset frequently.
 
 */

+ (void)setTransientSessionIDEnabled:(BOOL)transientIDEnabled;


/** Enables the hashed mode for the UDID in the ad requests.
 
 Calling this method will cause the UDID to be hashed by the SDK when requesting an advertisement.
 
 @warning By hashing the UDID, Smart AdServer will not get the original value, so it can prevent from interfacing with other partners and applications.
 
 */

+ (void)enableIdentifierHashing;


/** Handle custom URLs for LivePreview.
 
 @param url The URL that opened the app.
 
 */

+ (BOOL)handleOpenURL:(nonnull NSURL *)url;


///-----------------------------------
/// @name Creating ad views
///-----------------------------------

/** *Deprecated* Initializes and returns a SASAdView object for the given frame.
 
 @param frame A rectangle specifying the initial location and size of the ad view in its superview's coordinates.
 The frame of the table view changes when it loads an expand format.

 @warning This method is deprecated, please call it from a SASBannerView or a SASInterstitialView instance.

 */

- (nonnull id)initWithFrame:(CGRect)frame;


/** *Deprecated* Initializes and returns a SASAdView object for the given frame, and optionally sets a loader on it.
 
 @param frame A rectangle specifying the initial location and size of the ad view in its superview's coordinates. The frame of the table view changes when it loads an expand format.
 @param loaderType A loader that determines which loader the view should display while downloading the ad. The possible values are:

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

 @warning This method is deprecated, please call it from a SASBannerView or a SASInterstitialView instance.

 */

- (nonnull id)initWithFrame:(CGRect)frame loader:(SASLoader)loaderType;


///-----------------------------------
/// @name Loading ad data
///-----------------------------------

/** Fetches an ad from Smart AdServer.
 
 Call this method after initializing your SASAdView object to load the appropriate SASAd object from the server.
 
 @param formatId The format ID in the Smart AdServer manage interface.
 @param pageId The page ID in the Smart AdServer manage interface.
 @param isMaster The master flag. If this is YES, the a Page view will be counted. This should have the YES value for the first ad on the page, 
 and NO for the others (if you have more than one ad on the same page).
 @param target If you specified targets in the Smart AdServer manage interface, you can specify it here to target your advertisement.
 
 */

- (void)loadFormatId:(NSInteger)formatId
			  pageId:(nonnull NSString *)pageId
			  master:(BOOL)isMaster
			  target:(nullable NSString *)target;


/** Fetches an ad from Smart AdServer with a specified timeout.
 
 Call this method after initializing your SASAdView object with an initWithFrame: to load the appropriate SASAd object from the server.
 If the timeout expires, the SASAdView will fail to prefetch and notify the delegate. If an ad is available in the cache, it will display it even in offline mode.
 
 @param formatId The format ID in the Smart AdServer manage interface.
 @param pageId The page ID in the Smart AdServer manage interface.
 @param isMaster The master flag. If this is YES, the a Page view will be counted. This should have the YES value for the first ad on the page, 
 and NO for the others (if you have more than one ad on the same page).
 @param target If you specified targets in the Smart AdServer manage interface, you can specify it here to target your advertisement.
 @param timeout The time given to the ad view to download the ad data. After this time, the ad download will fail,  
 call [SASAdViewDelegate adView:didFailToLoadWithError:], and be dismissed if not unlimited. A negative value will disable the timeout.
 
 */

- (void)loadFormatId:(NSInteger)formatId
			  pageId:(nonnull NSString *)pageId
			  master:(BOOL)isMaster
			  target:(nullable NSString *)target
			 timeout:(float)timeout;


/* Updates the ad data.
 
 Call this method to fetch a new ad from Smart AdServer with the same settings you provided with loadFormatId:pageId:master:target:.
 This will set the master flag to NO, because you probably don't want to count a new page view.
 
 */

- (void)refresh;



/** Indicates if the ad loaded in the SASAdView supports rotation.
 
 Some MRAID creative can disallow orientation changes (because they don't support every screen orientations) so your application should test before 
 rotating that shouldAutoRotate returns YES, otherwise the creative might not work properly.
 This method should typically be called inside the '-(BOOL)shouldAutorotate' method (on iOS6 and later) or 
 in '- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation' method (in iOS5 and earlier).
 
 @return YES if the creative allows rotation.
 */

- (BOOL)shouldAutoRotate;


///---------------------------------------
/// @name Communication with the creative
///---------------------------------------

/** Send a message to the webview hosting the creative.
 
 The message can be retrieved in the creative by adding an MRAID event listener on the 'sasMessage' event. It will not be sent if the creative is not
 fully loaded.
 
 @param message The message that will be sent to the creative (it is not sent if nil or empty).
 
 */

- (void)sendMessageToWebView:(nonnull NSString *)message;


@end
