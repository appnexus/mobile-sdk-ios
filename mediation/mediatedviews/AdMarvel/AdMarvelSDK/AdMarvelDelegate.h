//
// AdMarvelDelegate.h
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
@class AdMarvelView;

typedef enum : NSUInteger {
    AdMarvelVideoEventImpressionLogged = 0,
    AdMarvelVideoEventPlaybackStarted,
    AdMarvelVideoEventFirstQuartile,
    AdMarvelVideoEventMidpoint,
    AdMarvelVideoEventThirdQuartile,
    AdMarvelVideoEventPlaybackCompleted,
    AdMarvelVideoEventClicked,
    AdMarvelVideoEventClosed,
    AdMarvelVideoEventCustom
} AdMarvelVideoEvent;

#pragma mark -
#pragma mark Targeting Parameter Constants

// Optional Targeting Parameter Constants
#define TARGETING_PARAM_APP_VERSION	@"APP_VERSION"	// Incrementing version of app useful for targeting campaigns (ex: 1.4.2) 
#define TARGETING_PARAM_MSISDN		@"MSISDN"		// Phone number with country code (ex: 16501234567)
#define TARGETING_PARAM_CARRIER		@"CARRIER"		// ID of the carrier
#define TARGETING_PARAM_AGE			@"AGE"			// Age (ex: 27)
#define TARGETING_PARAM_DOB			@"DOB"			// Date of birth in format yyyy-mm-dd (ex: 2008-05-25)
#define TARGETING_PARAM_AREA_CODE	@"AREA_CODE"	// Area code (ex: 650)
#define TARGETING_PARAM_POSTAL_CODE	@"POSTAL_CODE"	// Postal code (ex: 94123)
#define TARGETING_PARAM_GENDER		@"GENDER"		// Gender: "m" or "male"", "f" or "female"
#define TARGETING_PARAM_GEOLOCATION	@"GEOLOCATION"	// Latitude and longitude (ex: 32.9014,-117.2079)
#define TARGETING_PARAM_DMA			@"DMA"			// Designated Marketing Area code (ex: 807)
#define TARGETING_PARAM_ETHNICITY	@"ETHNICITY"	// Ethnicity:0-African American,1-Asian,2-Hispanic,3-White,4-Other
#define TARGETING_PARAM_SEEKING		@"SEEKING"		// Gender interested in: "m" or "male"", "f" or "female", "both"
#define TARGETING_PARAM_INCOME		@"INCOME"		// Income (ex: 50000)
#define TARGETING_PARAM_MARITAL		@"MARITAL"		// Marital status: "single" or "married"
#define TARGETING_PARAM_EDUCATION	@"EDUCATION"	// Education level:0-No College,1-College Degree,2-Graduate School
#define TARGETING_PARAM_KEYWORDS	@"KEYWORDS"		// Space delimited keywords (ex: MOVIE CATS FUNNY)
#define TARGETING_PARAM_SEARCH		@"SEARCH"		// User search, can really affect fill rates so recommended to use keywords instead
#define TARGETING_PARAM_INT_TYPE	@"INT_TYPE"		// Interstitial type: "AppOpen", "PreRoll", "PostRoll", "AppClose", "ScreenChange", "Other" or custom value.
#define TARGETING_PARAM_UNIQUE_ID   @"UNIQUE_ID"    // This is the unique ID AdMarvel will use for frequency capping.  This will automatically be generated but the app can overwrite it if they want (please see README for more details).
#define TARGETING_PARAM_UDID        @"UDID"         // If you have access to the UDID and need it for advertising then send it in this targeting parameter. The raw UDID is preferred as it is more flexible.


@protocol AdMarvelDelegate <NSObject>

@optional

// These methods need to be implemented to return the partner id and site id that were provisioned by AdMarvel for your App.
- (NSString *)partnerId:(AdMarvelView *)adMarvelView;
- (NSString *)siteId:(AdMarvelView *)adMarvelView;

// Returns the view controller that will be responsible for displaying modal views.
// This is mostly used when the SDK needs to takeover full screen (such as when an ad is clicked).
// NOTE: As of iOS 6 the app now controls which orientations can be used by ads/in-app browser in either the Info.plist or in the AppDelegate application:supportedInterfaceOrientationsForWindow: method.
//       We recommend for maximum compatibility with RichMedia ads that your app enables all orientations and then programatically restricts orientations where necessary using the UIViewController supportedInterfaceOrientations method.
- (UIViewController *) applicationUIViewController:(AdMarvelView *)adMarvelView;

// The rectangle where you want to display the ad.  The minimum size should be 300x50.  It defaults to CGRectMake(0,0,320,50).
// This is ignored for interstitial ads which are always full screen.
- (CGRect) adMarvelViewFrame:(AdMarvelView *)adMarvelView;

// Optional NSDictionary containing targeting parameters for the user. Defaults to empty (which means all geo information will be taken from the device IP address).
- (NSDictionary*) targetingParameters:(AdMarvelView *)adMarvelView;

// Return YES if you want to enable testing.  Defaults to testing not enabled (NO).
- (BOOL) testingEnabled:(AdMarvelView *)adMarvelView;

// Return NO if you want to disable animations when a new ad displayed.  Defaults to animations enabled (YES).
- (BOOL) animationsEnabled:(AdMarvelView *)adMarvelView;

#pragma mark - Location Service Methods
// Controls if location services enabled.  This is not required and only should be enabled if your app is already using location services.  Defaults to NO.
- (BOOL) locationServicesEnabled:(AdMarvelView *)adMarvelView;

// If location services are enabled then this method will be called to get the users current location.  Returning nil means the user's location is not available.
// It is strongly suggested that apps that don't already have the user's location shouldn't bother requesting their location just for ad serving purposes.
- (CLLocation *) locationObject:(AdMarvelView *)adMarvelView;


#pragma mark - Click Detection Methods
// Callback that gets invoked when an ad is clicked on that has a special AdMarvel SDK URL.  This enables an ad click to trigger special functionality within the application.
// These special ads would be loaded through the AdMarvel campaign management UI.  The click URL must start with admarvelsdk:// (instead of http:// ) to trigger this callback.
// The SDK will not perform any action other than calling this callback method when an ad with this type is clicked.  Only the text after admarvelsdk:// will be passed in the urlString parameter.
- (void) handleAdMarvelSDKClick:(NSString*)urlString forAdMarvelView:(AdMarvelView *)adMarvelView;

// Callback to let app know that a special banner has been clicked.  This method is provided to help track if an ad click is respondible for sending the user out of the app.
// Either this method, fullScreenWebViewActivated, adDidExpand or handleAdMarvelSDKClick should be called on ad click where supported.
// Examples click actions that would trigger this are click to call, click to app, click to itunes, etc.
// If the app is going to exit or go to the background the the normal UIApplicationDelegate methods will still get called after this.
// NOTE: Some ad network SDKs don't provide a tracking option for ads that don't open a full screen view so our SDK can't provide this additional information in those cases.
- (void) adMarvelViewWasClicked:(AdMarvelView *)adMarvelView;

#pragma mark - Orientation Change Control Methods
// Callbacks to let app know that the banner would like it to disable rotations.  Enable will only be called to reset rotations if disable was previously called.
// This is most often used when the user has begun to interact with an ad and the exprerience on rotation is not defined.
// Examples of this would be expandable ads or ads that are utilizing accelerometer events where rotation would interfere with user experience.
- (void) disableRotations:(AdMarvelView *)adMarvelView;
- (void) enableRotations:(AdMarvelView *)adMarvelView;

#pragma mark - Ad UI Customization Methods
// These items control the display of text ads.  The ads will be default to a black border, gray background and white text.
- (UIColor*) textAdFontColor:(AdMarvelView *)adMarvelView;
- (UIColor*) textAdBackgroundColor:(AdMarvelView *)adMarvelView;
- (UIColor*) textAdBorderColor:(AdMarvelView *)adMarvelView;

// Controls for style of tool bar on full page web view that opens when an ad is clicked.  Defaults to black and UIBarStyleDefault.
- (UIColor*) fullScreenToolBarColor:(AdMarvelView *)adMarvelView;
- (UIBarStyle) fullScreenToolBarStyle:(AdMarvelView *)adMarvelView;

// The color of the background behind the ad if it doesn't take up the full frame.  Defaults to clear.
// Note that the UI color should be specified using [UIColor colorWithRed:green:blue:alpha:] since grayscale values will cause issues in some cases.
- (UIColor*) backgroundColor:(AdMarvelView *)adMarvelView;

#pragma mark - Banner Ad Request Notification Methods
// Callbacks that let you know the status of a call to getAdWithNotification.  These will be called once the ad has either been retrieved successfully or has failed.
// For the first getAd call the app should either wait to display the AdMarvelView until getAdSucceded is called or set the background color in such a way that an empty AdMarvelView doesn't look out of place.
- (void) getAdSucceeded:(AdMarvelView *)adMarvelView;
- (void) getAdFailed:(AdMarvelView *)adMarvelView;

#pragma mark - FullScreen Notification Methods
// Callbacks to let the app know that the full screen web view has been activated and closed.
// These callbacks are useful if your app needs to pause any onscreen activity while the web view is being viewed (i.e. for a game).  You might also want to get a new ad when the full screen closes.
- (void) fullScreenWebViewActivated:(AdMarvelView *)adMarvelView;
- (void) fullScreenWebViewClosed:(AdMarvelView *)adMarvelView;

#pragma mark - Ad Size Change Notification Methods
// Callbacks to let the app know that an ad has just expanded or collapsed.  This means that an ad is taking up part of the screen but interaction with various elements of the app may still be possible.
// If it has expanded then the ad is currently currently displaying over some of the content.  The app should keep track of this and call collapseAd if the user interacts with the app instead of the ad.
- (void) adDidExpand:(AdMarvelView *)adMarvelView;
- (void) adDidCollapse:(AdMarvelView *)adMarvelView;

// This callback notifies you about video events
-(void) didReceiveVideoEvent:(AdMarvelVideoEvent)event withInfo:(NSDictionary*)dictionary forAdMarvelView:(AdMarvelView *)adMarvelView;

#pragma mark -
#pragma mark - Interstitial Ad Methods

// Callbacks that let you know the status of a call to getInterstitialAd.  These will be called once the ad has either been loaded successfully (succeeded) or is not available (failed).
// As a saftey precaution there is a timer setup that guarantees that these will be called within 10 seconds in case something went wrong and the application is waiting for a response.
- (void) getInterstitialAdSucceeded:(AdMarvelView *)adMarvelView;
- (void) getInterstitialAdFailed:(AdMarvelView *)adMarvelView;

// Callbacks to let the app know that a full screen interstitial has been activated and closed. 
// These callbacks are useful if your app needs to pause any onscreen activity while the interstitial is being viewed and restart after it is closed.
// These are optional since fullScreenWebViewActivated and fullScreenWebViewClosed will be called as well in case only those are implemented.
- (void) interstitialActivated:(AdMarvelView *)adMarvelView;
- (void) interstitialClosed:(AdMarvelView *)adMarvelView;

#pragma mark -
#pragma mark - Deprecated Methods

// These methods need to be implemented to return the partner id and site id that were provisioned by AdMarvel for your App.
- (NSString *)partnerId __attribute__((deprecated("use partnerId:(AdMarvelView *)adMarvelView")));
- (NSString *)siteId __attribute__((deprecated("use siteId:(AdMarvelView *)adMarvelView")));

// Returns the view controller that will be responsible for displaying modal views.
// This is mostly used when the SDK needs to takeover full screen (such as when an ad is clicked).
// NOTE: As of iOS 6 the app now controls which orientations can be used by ads/in-app browser in either the Info.plist or in the AppDelegate application:supportedInterfaceOrientationsForWindow: method.
//       We recommend for maximum compatibility with RichMedia ads that your app enables all orientations and then programatically restricts orientations where necessary using the UIViewController supportedInterfaceOrientations method.
- (UIViewController *) applicationUIViewController __attribute__((deprecated("use applicationUIViewController:(AdMarvelView *)adMarvelView")));

// Optional NSDictionary containing targeting parameters for the user. Defaults to empty (which means all geo information will be taken from the device IP address).
- (NSDictionary*) targetingParameters __attribute__((deprecated("use targetingParameters:(AdMarvelView *)adMarvelView")));

// Return YES if you want to enable testing.  Defaults to testing not enabled (NO).
- (BOOL) testingEnabled __attribute__((deprecated("use testingEnabled:(AdMarvelView *)adMarvelView")));

// Controls for style of tool bar on full page web view that opens when an ad is clicked.  Defaults to black and UIBarStyleDefault.
- (UIColor*) fullScreenToolBarColor __attribute__((deprecated("use fullScreenToolBarColor:(AdMarvelView *)adMarvelView")));
- (UIBarStyle) fullScreenToolBarStyle __attribute__((deprecated("use fullScreenToolBarStyle:(AdMarvelView *)adMarvelView")));

// Controls if location services enabled.  This is not required and only should be enabled if your app is already using location services.  Defaults to NO.
- (BOOL) locationServicesEnabled __attribute__((deprecated("use locationServicesEnabled:(AdMarvelView *)adMarvelView")));

// If location services are enabled then this method will be called to get the users current location.  Returning nil means the user's location is not available.
// It is strongly suggested that apps that don't already have the user's location shouldn't bother requesting their location just for ad serving purposes.
- (CLLocation *) locationObject __attribute__((deprecated("use locationObject:(AdMarvelView *)adMarvelView")));

// Callbacks to let the app know that the full screen web view has been activated and closed.
// These callbacks are useful if your app needs to pause any onscreen activity while the web view is being viewed (i.e. for a game).  You might also want to get a new ad when the full screen closes.
- (void) fullScreenWebViewActivated __attribute__((deprecated("use fullScreenWebViewActivated:(AdMarvelView *)adMarvelView")));
- (void) fullScreenWebViewClosed __attribute__((deprecated("use fullScreenWebViewClosed:(AdMarvelView *)adMarvelView")));

// Callback that gets invoked when an ad is clicked on that has a special AdMarvel SDK URL.  This enables an ad click to trigger special functionality within the application.
// These special ads would be loaded through the AdMarvel campaign management UI.  The click URL must start with admarvelsdk:// (instead of http:// ) to trigger this callback.
// The SDK will not perform any action other than calling this callback method when an ad with this type is clicked.  Only the text after admarvelsdk:// will be passed in the urlString parameter.
- (void) handleAdMarvelSDKClick:(NSString*)urlString __attribute__((deprecated("use handleAdMarvelSDKClick:(NSString*)urlString forAdMarvelView:(AdMarvelView *)adMarvelView")));

// The rectangle where you want to display the ad.  The minimum size should be 300x50.  It defaults to CGRectMake(0,0,320,50).
// This is ignored for interstitial ads which are always full screen.
- (CGRect) adMarvelViewFrame __attribute__((deprecated("use adMarvelViewFrame:(AdMarvelView *)adMarvelView")));

// Return NO if you want to disable animations when a new ad displayed.  Defaults to animations enabled (YES).
- (BOOL) animationsEnabled __attribute__((deprecated("use animationsEnabled:(AdMarvelView *)adMarvelView")));

// The color of the background behind the ad if it doesn't take up the full frame.  Defaults to clear.
// Note that the UI color should be specified using [UIColor colorWithRed:green:blue:alpha:] since grayscale values will cause issues in some cases.
- (UIColor*) backgroundColor __attribute__((deprecated("use backgroundColor:(AdMarvelView *)adMarvelView")));

// These items control the display of text ads.  The ads will be default to a black border, gray background and white text.
- (UIColor*) textAdFontColor __attribute__((deprecated("use textAdFontColor:(AdMarvelView *)adMarvelView")));
- (UIColor*) textAdBackgroundColor __attribute__((deprecated("use textAdBackgroundColor:(AdMarvelView *)adMarvelView")));
- (UIColor*) textAdBorderColor __attribute__((deprecated("use textAdBorderColor:(AdMarvelView *)adMarvelView")));

// Callbacks that let you know the status of a call to getAdWithNotification.  These will be called once the ad has either been retrieved successfully or has failed.
// For the first getAd call the app should either wait to display the AdMarvelView until getAdSucceded is called or set the background color in such a way that an empty AdMarvelView doesn't look out of place.
- (void) getAdSucceeded __attribute__((deprecated("use getAdSucceeded:(AdMarvelView *)adMarvelView")));
- (void) getAdFailed __attribute__((deprecated("use getAdFailed:(AdMarvelView *)adMarvelView")));

// Callbacks to let the app know that an ad has just expanded or collapsed.  This means that an ad is taking up part of the screen but interaction with various elements of the app may still be possible.
// If it has expanded then the ad is currently currently displaying over some of the content.  The app should keep track of this and call collapseAd if the user interacts with the app instead of the ad.
- (void) adDidExpand __attribute__((deprecated("use adDidExpand:(AdMarvelView *)adMarvelView")));
- (void) adDidCollapse __attribute__((deprecated("use adDidCollapse:(AdMarvelView *)adMarvelView")));

// Callbacks that let you know the status of a call to getInterstitialAd.  These will be called once the ad has either been loaded successfully (succeeded) or is not available (failed).
// As a saftey precaution there is a timer setup that guarantees that these will be called within 10 seconds in case something went wrong and the application is waiting for a response.
- (void) getInterstitialAdSucceeded __attribute__((deprecated("use getInterstitialAdSucceeded:(AdMarvelView *)adMarvelView")));
- (void) getInterstitialAdFailed __attribute__((deprecated("use getInterstitialAdFailed:(AdMarvelView *)adMarvelView")));

// Callbacks to let the app know that a full screen interstitial has been activated and closed.
// These callbacks are useful if your app needs to pause any onscreen activity while the interstitial is being viewed and restart after it is closed.
// These are optional since fullScreenWebViewActivated and fullScreenWebViewClosed will be called as well in case only those are implemented.
- (void) interstitialActivated __attribute__((deprecated("use interstitialActivated:(AdMarvelView *)adMarvelView")));
- (void) interstitialClosed __attribute__((deprecated("use interstitialClosed:(AdMarvelView *)adMarvelView")));

// Callbacks to let app know that the banner would like it to disable rotations.  Enable will only be called to reset rotations if disable was previously called.
// This is most often used when the user has begun to interact with an ad and the exprerience on rotation is not defined.
// Examples of this would be expandable ads or ads that are utilizing accelerometer events where rotation would interfere with user experience.
- (void) disableRotations __attribute__((deprecated("use disableRotations:(AdMarvelView *)adMarvelView")));
- (void) enableRotations __attribute__((deprecated("use enableRotations:(AdMarvelView *)adMarvelView")));

// Callback to let app know that a special banner has been clicked.  This method is provided to help track if an ad click is respondible for sending the user out of the app.
// Either this method, fullScreenWebViewActivated, adDidExpand or handleAdMarvelSDKClick should be called on ad click where supported.
// Examples click actions that would trigger this are click to call, click to app, click to itunes, etc.
// If the app is going to exit or go to the background the the normal UIApplicationDelegate methods will still get called after this.
// NOTE: Some ad network SDKs don't provide a tracking option for ads that don't open a full screen view so our SDK can't provide this additional information in those cases.
- (void) adMarvelViewWasClicked __attribute__((deprecated("use adMarvelViewWasClicked:(AdMarvelView *)adMarvelView")));

@end