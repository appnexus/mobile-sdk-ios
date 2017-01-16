//
//  RFMAdDelegate.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 3/27/14.
//  Copyright © 2014 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * This class provides RFMAdView delegate callbacks to monitor ad status and provide information
 * for optimum ad interaction experience.
 */

@class RFMAdView;
@protocol RFMAdDelegate <NSObject>

@required
#pragma mark -
#pragma mark Required Methods

@optional
#pragma mark -s
#pragma mark Optional Notification Methods

/** @name Controlling full screen ad display */

/**
 * **Optional** SuperView of RFMAdView.
 *
 * Set this delegate method for optimum user experience with rich media ads that need to modify the 
 * view to non-standard sizes during user interaction.
 *
 * @return The superview of RFMAdView instance.
 */
-(UIView *)rfmAdSuperView;

/**
 * **Optional** View controller to present full screen modals.
 *
 * The view controller which will be the parent controller for full screen modals. Full screen modals
 * are used by RFM Ad SDK to load post click in-app browsers.
 * For best results, please return the view controller whose content view covers full screen (apart
 * from tab bar, nav bar and status bar). If the view controller that requested for ads does not have
 * full screen access then return the parent view controller that does have full screen access.
 *
 * @return The UIViewController instance that will be the parent for full screen modals.
 */
-(UIViewController *)viewControllerForRFMModalView;

/** @name Loading the ad */

/**
 * **Optional** Delegate callback when ad request has been sent to server.
 *
 * This callback is triggered when an ad request has been successfully sent to the ad server. Please 
 * note that this does not signify that a response has been received from the ad server. This callback
 * is useful for checking the request URL that is actually sent to the ad server.
 *
 * @param adView The instance of RFMAdView for which this callback has been triggered.
 * @param requestUrlString The request URL for the request sent to RFM ad server.
 */
- (void)didRequestAd:(RFMAdView *)adView withUrl:(NSString *)requestUrlString;

/**
 * **Optional** Delegate callback when an ad has been successfully fetched and loaded.
 *
 * For non-cacheable ads, this is a good time to add the RFMAdView instance to the view hierarchy if it
 * wasn't already part of view hierarchy.
 * For cacheable ads, this callback can be used to trigger RFMAdView showCachedAd method.
 *
 * @param adView The instance of RFMAdView for which this callback has been triggered.
 * @see didFailToReceiveAd:reason:
 */
- (void)didReceiveAd:(RFMAdView *)adView;

/**
 * **Optional** Delegate callback when the SDK failed to load an ad.
 *
 * Sent when an ad request failed to load an ad. This is a good opportunity to remove the RFMAdView 
 * instance from superview if it had previously been added.
 *
 * @param adView The instance of RFMAdView for which this callback has been triggered.
 * @param errorReason The reason for failure to load an ad.
 * @see didReceiveAd:
 */
- (void)didFailToReceiveAd:(RFMAdView *)adView reason:(NSString *)errorReason;

/**
 * **Optional** Delegate callback when the SDK displays a previously cached ad.
 *
 * Applicable only for cacheable ads callflow (i.e. when RFMAdView's showCachedAd is triggered). This
 * callback is triggered when the SDK is able to successfully display a cached ad.
 *
 * @param adView The instance of RFMAdView for which this callback has been triggered.
 * @see didFailToDisplayAd:reason:
 */
- (void)didDisplayAd:(RFMAdView *)adView;

/**
 * **Optional** Delegate callback when the SDK fails to display a previously cached ad.
 *
 * Applicable only for cacheable ads callflow (i.e. when RFMAdView's showCachedAd is triggered). This 
 * callback is triggered when the SDK is unable to display a cached ad.
 *
 * @param adView The instance of RFMAdView for which this callback has been triggered.
 * @param errorReason The reason for failure to display an ad.
 * @see didDisplayAd:
 */
- (void)didFailToDisplayAd:(RFMAdView *)adView reason:(NSString *)errorReason;

/** @name User Interaction */

/**
 * **Optional** Delegate callback when an interstitial ad is about to be dismissed.
 *
 * Applicable only for interstitial ads. This callback is triggered when the interstitial view is 
 * about to dismissed in response to user click of close button. This is a good time to start preparing
 * the view which will be displayed in lieu of the interstitial ad.
 *
 * @param adView The instance of RFMAdView for which this callback has been triggered.
 */
-(void)willDismissInterstitialFromAd:(RFMAdView *)adView;

/**
 * This delegate callback is applicable only for interstitial ads. This callback is triggered when the
 * interstitial view has been dismissed in response to user click of close button.
 */
-(void)didDismissInterstitial;

/**
 * **Optional** Delegate callback when a full screen ad landing view will be displayed.
 *
 * This callback is triggered when RFMAdView is about to take over the application screen with a full 
 * screen ad landing page in response to user interaction with the ad. Use this callback to stop animations,
 * time sensitive interactions, ad refresh timers, etc as the user wants to interact with the ad.
 *
 * @param adView The instance of RFMAdView for which this callback has been triggered.
 */
- (void)willPresentFullScreenModalFromAd:(RFMAdView *)adView;

/**
 * **Optional** Delegate callback when a full screen ad landing view is being displayed.
 *
 * This callback is triggered right after RFMAdView takes over the application screen with a full screen
 * ad landing page in response to user interaction with the ad. This callback signifies that the user is
 * interacting with the ad. The application should pause any transitions until the user has completed
 * ad interaction.
 *
 * @param adView The instance of RFMAdView for which this callback has been triggered.
 * @see willDismissFullScreenModalFromAd:
 * @see didDismissFullScreenModalFromAd:
 */
- (void)didPresentFullScreenModalFromAd:(RFMAdView *)adView;

/**
 * **Optional** Delegate callback when a full screen ad landing view is about to be dismissed.
 *
 * This callback is triggered when the ad view is about to be dismissed in response to user click of 
 * close button. This is a good time to start preparing the view which will be displayed in lieu of the 
 * interstitial ad.
 *
 * @param adView The instance of RFMAdView for which this callback has been triggered.
 * @see willPresentFullScreenModalFromAd:
 * @see didPresentFullScreenModalFromAd:
 */
- (void)willDismissFullScreenModalFromAd:(RFMAdView *)adView;

/**
 * **Optional** Delegate callback when a full screen ad landing view has been dismissed.
 *
 * This callback is triggered when the interstitial view has been dismissed in response to user click of 
 * close button. Use this opportunity to restart anything you may have stopped as part of 
 * willPresentFullScreenModalFromAd:.
 *
 * @param adView The instance of RFMAdView for which this callback has been triggered.
 * @see willPresentFullScreenModalFromAd:
 * @see didPresentFullScreenModalFromAd:
 */
- (void)didDismissFullScreenModalFromAd:(RFMAdView *)adView;

/**
 * **Optional** Delegate callback when app is pushed to background while the ad banner was loading.
 *
 * This callback is triggered if the application will enter background while the ad banner is still 
 * loading due to the user clicking home button, the user clicking a button that triggers another 
 * application and sends the current application into background, etc. Prior to calling this function, 
 * RFMAdSDK will stop loading the banner.
 *
 * @param adView The instance of RFMAdView for which this callback has been triggered.
 * @see willPresentFullScreenModalFromAd:
 * @see didPresentFullScreenModalFromAd:
 */
- (void)adViewDidStopLoadingAndEnteredBackground:(RFMAdView *)adView;

/**
 * Sent just before reporting to Ad Forensics server begins, when the default or customized Ad Forensics
 * gesture recognizer is triggered.
 *
 * @warning We strongly recommend that you stop requesting new ads with the RFMAdview instance when you 
 * receive this callback. Otherwise there could be unpredicted behaviors if the RFMAdview is refreshed 
 * while Ad Forensics reporting is in progress.
 *
 * @param adView The instance of RFMAdView for which this callback has been triggered.
 */
- (void)adForensicsReportingWillBegin:(RFMAdView *)adView;

/**
 * Sent just after reporting to Ad Forensics server finishes, when reporting connection is closed and Ad
 * Forensics progress dialog is dismissed.
 *
 * Note: If you implement adForensicsReportingWillBegin, we strongly recommend you to implement this
 * callback and resume requesting new ads with the RFMAdview instance.
 *
 * @param adView The instance of RFMAdView for which this callback has been triggered.
 */
- (void)adForensicsReportingDidFinish:(RFMAdView *)adView;

/**
 * Sent if reporting to Ad Forensics server failed.
 *
 * Note: If you implement adForensicsReportingWillBegin, we strongly recommend you to implement this
 * callback and resume requesting new ads with the RFMAdview instance.
 *
 * @param adView The instance of RFMAdView for which this callback has been triggered
 * @param errorReason The reason for Ad Forensics reporting failing.
 */
- (void)adForensicsReportingDidFail:(RFMAdView *)adView reason:(NSString *)errorReason;

#pragma mark - DEPRECATED METHODS

/** @name Deprecated */

/**
 * **Optional** View controller to present full screen modals
 *
 * The view controller which will be the parent controller for full screen modals. Full screen modals 
 * are used by RFM Ad SDK to load post click in-app browsers.
 * For best results, please return the view controller whose content view covers full screen (apart from
 * tab bar, nav bar and status bar). If the view controller which requested for ads does not have full 
 * screen access then return the parent view controller which has full screen access.
 *
 * @param rfmAdView The instance of RFMAdView that this method applies to.
 * @return The UIViewController instance that will be the parent for full screen modals.
 * @see viewControllerForRFMModalView
 * @warning **Deprecated in RFM iOS SDK 3.0.0**
 */
-(UIViewController *)currentViewControllerForRFMAd:(RFMAdView *)rfmAdView DEPRECATED_ATTRIBUTE;

/**
 * **Optional** Delegate callback when the SDK failed to load an ad.
 *
 * Sent when an ad request failed to load an ad. This is a good opportunity to remove the RFMAdView
 * instance from superview if it had previously been added.
 * 
 * @param adView The instance of RFMAdView for which this callback has been triggered.
 * @see didFailToReceiveAd:reason:
 * @warning **Deprecated in RFM iOS SDK 3.0.0**
 */
- (void)didFailToReceiveAd:(RFMAdView *)adView DEPRECATED_ATTRIBUTE;

/**
 * **Optional** Delegate callback when the SDK fails to display a previously cached ad.
 *
 * Applicable only for cacheable ads callflow (i.e. when RFMAdView's showCachedAd is triggered). This
 * callback is triggered when the SDK is unable to display a cached ad.
 *
 * @param adView The instance of RFMAdView for which this callback has been triggered.
 * @see didFailToDisplayAd:reason:
 * @warning **Deprecated in RFM iOS SDK 3.0.0**
 */
- (void)didFailToDisplayAd:(RFMAdView *)adView DEPRECATED_ATTRIBUTE;

@end
