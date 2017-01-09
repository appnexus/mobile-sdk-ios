//
//  AdMarvelNativeAdDelegate.h
//

#import <Foundation/Foundation.h>

#import "AdMarvelDelegate.h"

@class AdMarvelNativeAd;

/*!
 The methods declared by the AdMarvelNativeAdDelegate protocol allow the adopting delegate to respond to messages from the AdMarvelNativeAd class. Thus it can be used to get the native ad success or failure status.
 */
@protocol AdMarvelNativeAdDelegate <NSObject>

@required

// These methods need to be implemented to return the partner id and site id that were provisioned by AdMarvel for your App.
- (NSString *)partnerIdForNativeAd:(AdMarvelNativeAd *)nativeAd;
- (NSString *)siteIdForNativeAd:(AdMarvelNativeAd *)nativeAd;

// Returns the view controller that will be responsible for displaying modal views.
// This is mostly used when the SDK needs to takeover full screen (such as when an ad is clicked).
// NOTE: As of iOS 6 the app now controls which orientations can be used by ads/in-app browser in either the Info.plist or in the AppDelegate application:supportedInterfaceOrientationsForWindow: method.
// We recommend for maximum compatibility with RichMedia ads that your app enables all orientations and then programatically restricts orientations where necessary using the UIViewController supportedInterfaceOrientations method.
- (UIViewController *) applicationUIViewControllerForNativeAd:(AdMarvelNativeAd *)nativeAd;

@optional

// Optional NSDictionary containing targeting parameters for the user. Defaults to empty (which means all geo information will be taken from the device IP address).
- (NSDictionary*) targetingParametersForNativeAd:(AdMarvelNativeAd *)nativeAd;


// Return YES if you want to enable testing.  Defaults to testing not enabled (NO).
- (BOOL) testingEnabledForNativeAd:(AdMarvelNativeAd *)nativeAd;

/*!
 Callbacks that let you know the status of a call to getNativeAd.  These will be called once the ad has either been retrieved successfully or the request has failed.
 */
-(void) getNativeAdSucceeded:(AdMarvelNativeAd*) nativeAd;
-(void) getNativeAdFailed:(AdMarvelNativeAd*) nativeAd withError:(NSError*)error;

/*
 *Callback that let the app know when the application is about to go to the background or terminated
 */
- (void) nativeAdWillLeaveApplication:(AdMarvelNativeAd*) nativeAd;

// Controls for style of tool bar on full page web view that opens when an ad is clicked.  Defaults to black and UIBarStyleDefault.
- (UIColor*) fullScreenToolBarColorForNativeAd:(AdMarvelNativeAd *)nativeAd;
- (UIBarStyle) fullScreenToolBarStyleForNativeAd:(AdMarvelNativeAd *)nativeAd;

// Callback that gets invoked when an ad is clicked on that has a special AdMarvel SDK URL.  This enables an ad click to trigger special functionality within the application.
// These special ads would be loaded through the AdMarvel campaign management UI.  The click URL must start with admarvelsdk:// (instead of http:// ) to trigger this callback.
// The SDK will not perform any action other than calling this callback method when an ad with this type is clicked.  Only the text after admarvelsdk:// will be passed in the urlString parameter.
- (void) handleAdMarvelSDKClick:(NSString*)urlString forNativeAd:(AdMarvelNativeAd *)nativeAd;

// Controls if location services enabled.  This is not required and only should be enabled if your app is already using location services.  Defaults to NO.
- (BOOL) locationServicesEnabledForNativeAd:(AdMarvelNativeAd *)nativeAd;

// If location services are enabled then this method will be called to get the users current location.  Returning nil means the user's location is not available.
// It is strongly suggested that apps that don't already have the user's location shouldn't bother requesting their location just for ad serving purposes.
- (CLLocation *) locationObjectForNativeAd:(AdMarvelNativeAd *)nativeAd;

// Callbacks to let the app know that the full screen web view has been activated and closed.
// These callbacks are useful if your app needs to pause any onscreen activity while the web view is being viewed (i.e. for a game).  You might also want to get a new ad when the full screen closes.
- (void) fullScreenWebViewActivatedForNativeAd:(AdMarvelNativeAd *)nativeAd;
- (void) fullScreenWebViewClosedForNativeAd:(AdMarvelNativeAd *)nativeAd;

// This callback notifies you about video events
-(void) didReceiveVideoEvent:(AdMarvelVideoEvent)event withInfo:(NSDictionary*)dictionary forNativeAd:(AdMarvelNativeAd *)nativeAd;


@end
