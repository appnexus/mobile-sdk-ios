//
//  AdMarvelView.h
//

#import <UIKit/UIKit.h>

#import "AdMarvelDelegate.h"
#import "AdMarvelRewardDelegate.h"

// View for displaying the ads.  Add this to your main view.
@interface AdMarvelView : UIView

// The AdMarvelDelegate for this AdMarvelView.
// This needs to be used to set the delegate to nil if it is ever going to be dealloced.  This prevents a released delegate from being referenced by the AdMarvelView.
// The delegate should also be set to nil right before you release the AdMarvelView itself.
@property(nonatomic,weak) NSObject<AdMarvelDelegate>* delegate;


//This delegate is needed to send reward related events
//This delegate should not need to be set to nil since it should exist for the entire lifespan of the app.
@property(nonatomic,weak) NSObject<AdMarvelRewardDelegate>* rewardDelegate;

// Create an AdMarvel view with an AdMarvelDelegate containing all the desired configuration values.
// This method only returns a reference to the AdMarvelView so make sure you retain it if needed.
// We do recommend retaining the AdMarvelView so that you can set the delegate to nil before releasing it.
+(AdMarvelView*) createAdMarvelViewWithDelegate:(NSObject<AdMarvelDelegate>*) delegate;

// Asynchrounsly get an ad from the AdMarvel SDK.
// If one isn't available then the view will do nothing, leaving any current ad displayed.  If one is available it will replace the existing ad.
// In most cases you will want to use getAdWithNotification unless you are just using a timer to refresh an existing ad and don't care the result of the call.
-(void) getAd;

// Same behavior as getAd except the delegate will receive a call to either getAdSucceeded or getAdFailed.
// It is recommended that you use this method always so you can perform conditional logic based on whether an ad was successfully retrieved or not.
-(void) getAdWithNotification;

// Method for checking if the view is currently taking up the full screen (such as when a full screen web view is launched when an ad is clicked).
-(BOOL) isInFullScreenMode;

// Check what version of the SDK you are using.
-(NSString*) getSDKVersion;

// These functions let the app directly interact with an expandable ad.  In general the app will only want to do this to collapse an ad after the adDidExpand delegate method has been called
// and the app needs to update its display (ex: has a popup of it's own to display or is switching tabs).  An app should really only expand an ad if it has previously collapsed it.
// These functions have no effect if they are called and either there is no ad or the current ad is not an AdMarvel expandable ad.
- (void) collapseAd;
- (void) expandAd;

// Method for checking if the view is currently displaying an expanded ad
-(BOOL) isAdExpanded;

// Asynchronously load an interstital.
// The callbacks getInterstitialAdSucceeded and getInterstitialAdFailed let you know whether this call succeded or not.  Once an interstitial is loaded you will need to call displayInterstitial.
// It is suggested you set the TARGETING_PARAM_INT_TYPE targeting type correctly so interstitials can be targeted at different events.
// NOTE: If you are calling this from within applicationDidFinishLaunching the network calls for the ad request will not start executing until the applicationDidFinishLaunching call returns.
-(void) getInterstitialAd;

// Displays an interstitial if loaded.
// To load an interstitial you need to have previously called getInterstitialAd.  If an interstitial is availble this will return YES and display it.  If no interstital is loaded it will return NO.
// NOTE: Since an interstitial could be a video or could click to video it is important that your app always creates a new MPMoviePlayerController each time it plays its own videos.
-(BOOL) displayInterstitial;

// Check if an interstitial is loaded.
// You should call getInterstitialAd before this check.  This is best used as a fast check before displaying in content (ScreenChange) interstitials that have been pre loaded.
// If you are waiting for an interstitial to load (such as for a launch (AppOpen) interstitials) you should listen for the delegate callbacks that let you know if the getInterstitialAd request succeeded.
-(BOOL) isInterstitialReady;

// These methods let the app indicate whether it considers the AdMarvelView to be visible or not.  This is useful when AdMarvelViews are embedded in a scrolling view and need to be loaded in advance.
// Calling these methods will let the AdMarvelView notify the creative of the status change. For most ads this is a no op but if an ad supports this feature it can take the appropriate action.
// These methods are required when you are using custom offline campaigns for recording the appropriate impression data.  These methods are not needed for interstitial ads however.
- (void) adMarvelViewDisplayed;
- (void) adMarvelViewHidden;

// Asynchronously load a reward interstital ad that will generate reward events when viewed completely.
// The AdMarvelDelegate callbacks getInterstitialAdSucceeded and getInterstitialAdFailed let you know whether this call succeded or not.  You can optionally later check by calling isInterstitialReady.
// Once a reward interstitial is loaded you will need to call displayInterstitial to show it.  Listen to the standard AdMarvelDelegate callbacks for when the interstitial is displayed and closed
// NOTE: This call will not work if you have not set the rewardDelegate property first.  The AdMarvelRewardDelegate is required to provide success/failure confirmation of the reward associated with the interstitial viewing.
- (void) requestRewardInterstitialAdForUser:(NSString*) userId additionalConfig:(NSDictionary*) rewardConfigParameters;

// Use this method to pass ad network connector classes name.
//@adNetworkAdapterClassNames : array of class name strings
+(void) registerAdNetworkClasses:(NSArray *)adNetworkConnectorClassNames;

#pragma mark Deprecated
// Optional method for creating an AdMarvel view and prefetching the initial ad.
// Setting prefetch to YES should speed up the first getAd call if this call can be done a lot earlier in the initialization before getAd is needed.
// If getAd is going to be called right after this method then there is no reason to enable prefetching.
// This should only be used if all the necessary targeting information is available in the delegate and getAd it gauranteed to be called later.
+(AdMarvelView*) createAdMarvelViewWithDelegate:(NSObject<AdMarvelDelegate>*) delegate prefetchAd:(BOOL)prefetchAd __attribute__((deprecated("Prefetch was deprecated starting 3.2.5")));
@end
