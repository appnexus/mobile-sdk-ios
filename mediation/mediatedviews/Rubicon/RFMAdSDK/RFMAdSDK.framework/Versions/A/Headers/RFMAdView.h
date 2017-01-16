//
//  RFMAdView.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 3/6/14.
//  Copyright © 2014 Rubicon Project. All rights reserved.
//

#import "RFMAdDelegate.h"
#import "RFMAdConstants.h"
#import "RFMRewardedVideo.h"

@class RFMAdRequest;

/**
 * RFMAdView class provides the view for displaying Revv For Mobile ads.
 *
 * Use one of the create functions to create a banner or interstitial ad. We recommend to create a view once during the view controller creation and then use only the requestFreshAd method to refresh the view with new ads.
 */

@interface RFMAdView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, weak, setter = setDelegate:) id<RFMAdDelegate> delegate;
@property (assign, readonly) BOOL shouldPrecache;
@property (assign) BOOL interstitialWantsFullScreen;

#pragma mark -
#pragma mark View Creation

/** @name Creating a Banner Ad */

/**
 * Create and initialize an instance of RFMAdView with default size and position
 *
 * This method should be used to create a 320x50 banner in the default position  (top of content view below top navigation bar)  only if the app **does not support device orientation changes**.
 *
 * @param delegate The delegate of RFMAdView. Conforms with RFMAdDelegate protocol
 * @return A new instance of RFMAdView
 *
 * @see createAdOfFrame:withCenter:withDelegate:
 * @see createAdOfFrame:withPortraitCenter:withLandscapeCenter:withDelegate:
 *
 */
+(RFMAdView *)createAdWithDelegate:(id<RFMAdDelegate>)delegate;

/**
 * Create and initialize an instance of RFMAdView with custom banner size and location
 *
 * This method should be used to create a banner of custom size and placed in custom location only if the app **does not support device orientation changes**.
 *
 * @param frame Size of banner to be created
 * @param center Center co-ordinates of banner, with respect to RFMAdView's superview.
 * @param delegate The delegate of RFMAdView. Conforms with RFMAdDelegate protocol
 * @return A new instance of RFMAdView
 *
 * @see createAdWithDelegate:
 * @see createAdOfFrame:withPortraitCenter:withLandscapeCenter:withDelegate:
 */
+(RFMAdView *)createAdOfFrame:(CGRect)frame
                   withCenter:(CGPoint)center
                 withDelegate:(id<RFMAdDelegate>)delegate;

/**
 * Create and initialize an instance of RFMAdView with custom banner size and location
 *
 * This method should be used to create a banner of custom size and placed in custom location only
 *
 * @param frame Size of banner to be created
 * @param portraitCenter Center co-ordinates of banner in portrait mode, with respect to RFMAdView's superview.
  * @param landscapeCenter Center co-ordinates of banner in landscape mode, with respect to RFMAdView's superview.
 * @param delegate The delegate of RFMAdView. Conforms with RFMAdDelegate protocol
 * @return A new instance of RFMAdView
 *
 * @see createAdWithDelegate:
 * @see createAdOfFrame:withCenter:withDelegate:
 */
+(RFMAdView *)createAdOfFrame:(CGRect)frame
           withPortraitCenter:(CGPoint)portraitCenter
          withLandscapeCenter:(CGPoint)landscapeCenter
                 withDelegate:(id<RFMAdDelegate>)delegate;

/** @name Creating an Interstitial Ad */

/**
 * Create and initialize an instance of RFMAdView as a full screen interstitial ad
 *
 * This method should be used to create a full screen interstitial ad.
 *
 * @param delegate The delegate of RFMAdView. Conforms with RFMAdDelegate protocol
 * @return A new instance of RFMAdView
 *
 */
+(RFMAdView *)createInterstitialAdWithDelegate:(id<RFMAdDelegate>)delegate;

#pragma mark -
#pragma mark Ad Request

/** @name Loading an ad */

/**
 * Request a new ad from RFM ad server
 *
 * Method to request an ad once the AdView has been created.
 * You can call this several times during the view lifecycle.
 * The returned status shows whether the request was accepted by the SDK.
 * For example, if this method is called when the user
 * is viewing the landing page of a previous ad, the SDK does not initiate
 * a new ad request and instead returns BOOL “NO” as status.
 *
 * @param requestParams Request Parameters for this call. Instance of RFMAdRequest
 * @return Status Boolean status code informing if the request was accepted by the SDK or not.
 *
 * @see requestCachedAdWithRequestParams:
 *
 */
- (BOOL) requestFreshAdWithRequestParams:(RFMAdRequest *)requestParams;

/**
 * Request a new cacheable ad from RFM ad server
 *
 * Method to request a **cacheable** ad once the AdView has been created.
 * You can call this several times during the view lifecycle.
 * The returned status shows whether the request was accepted by the SDK.
 * For example, if this method is called when the user
 * is viewing the landing page of a previous ad, the SDK does not initiate
 * a new ad request and instead returns BOOL “NO” as status.
 *
 * @warning A cacheable ad has a two step load process. Not all
 * ads supported on RFM are cacheable. Please contact your Account Manager if you
 * plan on using this method.
 *
 * @param requestParams Request Parameters for this call. Instance of RFMAdRequest
 * @return Status Boolean status code informing if the request was accepted by the SDK or not.
 *
 * @see requestFreshAdWithRequestParams:
 *
 */
- (BOOL) requestCachedAdWithRequestParams:(RFMAdRequest *)requestParams;

/**
 * Check if a cacheable ad is ready for display
 *
 * Use this method to check if a cached ad is ready to be displayed or not. This is an optional method to allow better control of when to display a previously cached ad instead of calling showCachedAd directly without checking for availability.
 *
 * @warning Applies to cacheable ads only.
 *
 * @return Status Boolean status code informing if there is a cacheable ad ready to be displayed or not.
 *
 * @see requestCachedAdWithRequestParams:
 *
 */
- (BOOL) canDisplayCachedAd;

/**
 * Display a cached ad
 *
 * Call this method to display a previously cached ad. This method checks whether a cacheable ad can be displayed or not before attempting to display the ad.
 * Calling this method will invoke RFMAdDelegate callback didFailToDisplayAd in case of failure to display.
 *
 * @return Status Boolean status code informing if an ad can be displayed or not.
 *
 * @see requestCachedAdWithRequestParams:
 * @see canDisplayCachedAd
 *
 */
-(BOOL) showCachedAd;

/** @name Utility Methods */
/**
 * Adjust the placement of ad view coordinates contionally on specific OS versions
 *
 * Optional method to adjust the adview placement if parent view controller cannot set the edges for extended layout to none. This API will be useful for allowing apps running OS lower than iOS7 to set their placement coordinates for iOS6 and iOS7+ without an explicit version check.
 * Call this API for with the correct offset values to ensure that the adview is created at the desired coordinates.
 *
 * @param iosVersion Lowest OS version that the offset should be applied to. Set iOS version to string value of numerical version . ex: @"7.0".
 * @param portraitOffset  Vertical offset to be applied on RFMAdView coordinates in portrait mode
 * @param landscapeOffset Vertical offset to be applied on RFMAdView coordinates in landscape mode
 *
 */
-(void)applyVerticalOffsetForiOSGreaterThan:(NSString *)iosVersion
                             portraitOffset:(CGFloat)portraitOffset
                            landscapeOffset:(CGFloat)landscapeOffset;

/**
 * Set the Audio Session category for your application
 *
 * RFMAdSDK sets Audio Category to AVAudioSessionCategoryAmbient during creation.
 * Use this method if you would like to set a different Audio Session Category for the application.
 *
 * @param AVAudioSessionCategoryType Audio Session Category Type of your app
 * @return Status Boolean status code informing whether RFM SDK was able to set the Audio Session Category.
 *
 */
- (BOOL) setAVAudioSessionCategory:(NSString *)AVAudioSessionCategoryType;


/**
 * Get the Version number of RFM SDK in use.
 *
 * @return RFM SDK Version string
 *
 */
+ (NSString *)rfmSDKVersion;

#pragma mark Ad Forensics Settings

/**
 * Override the default Ad Forensics gesture with a gesture of RFMAdForensicsTouchGesture
 *
 * @param type The type of touch gesture to be used for Forensics reporting. See RFMAdForensicsTouchGesture for available types.
 */
- (void)setRFMAdForensicsTouchGestureWithType: (RFMAdForensicsTouchGesture)type;

/**
 * Override the default Ad Forensics gesture with a custom one. Some gesture recognizers are commonly
 * used in uiwebview. To avoid gesture conflicts, please avoid the following gestures for Ad Forensics:
 * - tap and tap multiple times
 * - swipe with one finger
 * - long press
 * - pinch
 * - pan
 * - rotation
 * Ad Forensics will be disabled if any of above gestures are used for Ad Forensics.
 *
 * @param aGesture A custom gesture to be used for Forensics reporting. An instance of UIGestureRecognizer.
 */
- (void)setRFMAdForensicsTouchGestureWithGestureRecognizer: (UIGestureRecognizer *)aGesture;

#pragma mark - Deprecated Methods

/** @name Deprecated */

/**
 * Adjust the placement of ad view coordinates contionally on iOS versions > 7.0
 *
 * Optional method to adjust the adview placement if parent view controller cannot set the edges for extended layout to none. This is useful for allowing apps running OS lower than iOS7 to set their placement coordinates for iOS6 and iOS7+ without an explicit version check.
 *
 * @param portraitOffset Vertical offset to be applied on RFMAdView coordinates in portrait mode
 * @param landscapeOffset Vertical offset to be applied on RFMAdView coordinates in landscape mode
 *
 * @see applyVerticalOffsetForiOSGreaterThan:portraitOffset:landscapeOffset:
 *
 * @warning **Deprecated in RFM SDK 3.0.0** Replaced with applyVerticalOffsetForiOSGreaterThan:portraitOffset:landscapeOffset:
 */
- (void) offsetCentersForiOS7WithPortaitOffset:(CGFloat)portraitOffset
                            andLandscapeOffset:(CGFloat)landscapeOffset DEPRECATED_ATTRIBUTE;

/**
 *  Get the Version number of RFM SDK in use.
 * 
 * @return RFM SDK Version string
 *
 * @see rfmSDKVersion
 * @warning **Deprecated in RFM SDK 3.0.0**. Replaced with rfmSDKVersion.
 *
 */
+ (NSString *)mbsAdVersion DEPRECATED_ATTRIBUTE;

/**
 * Check if a cacheable ad is ready for display
 *
 * Use this method to check if a cached ad is ready to be displayed or not. This is an optional method to allow better control of when to display a previously cached ad instead of calling showCachedAd directly without checking for availability.
 *
 *
 * @return Status Boolean status code informing if there is a cacheable ad ready to be displayed or not.
 *
 * @see requestCachedAdWithRequestParams:
 * @warning **Deprecated in RFM SDK 3.0.0** Replaced with canDisplayCachedAd
 */
- (BOOL) canDisplayAd DEPRECATED_ATTRIBUTE;

//Replace with showCachedAd
/**
 * Display a cached ad
 *
 * Call this method to display a previously cached ad. This method checks whether a cacheable ad can be displayed or not before attempting to display the ad.
 * Calling this method will invoke RFMAdDelegate callback didFailToDisplayAd in case of failure to display.
 *
 *
 * @return Status Boolean status code informing if an ad can be displayed or not.
 * @warning **Deprecated in RFM SDK 3.0.0** Replaced with showCachedAd
 *
 */
- (BOOL) showAd DEPRECATED_ATTRIBUTE;

@end
