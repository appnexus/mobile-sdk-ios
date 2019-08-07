//
//  SASNativeAd.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 18/08/2015.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASNativeAdDelegate.h"

#define SASRatingUndefined -1
#define SASLikesUndefined -1
#define SASDownloadsUndefined -1

NS_ASSUME_NONNULL_BEGIN

@class SASNativeAdImage;

/**
 A SASNativeAd represents an ad that will be displayed by the native code of the application.
 
 @note Contrary to the SASAd object, the SASNativeAd only contains information that needs to be displayed but
 does not create any view for the actual display: your application is reponsible of the ad rendering.
 */
@interface SASNativeAd : NSObject <NSCopying, NSCoding>

#pragma mark - Required information

/// The title of the ad (required).
@property (nonatomic, readonly, nullable, strong) NSString *title;

#pragma mark - Optional information

/// The subtitle of the ad.
///
/// Can be used as a short description.
@property (nonatomic, readonly, nullable, strong) NSString *subtitle;

/// The body of the ad.
///
/// Can be used as a long description.
@property (nonatomic, readonly, nullable, strong) NSString *body;

/// The call to action text of the ad.
///
/// This text represents the action that will be made when the ad is clicked: for instance 'Open' or 'Download'.
@property (nonatomic, readonly, nullable, strong) NSString *callToAction;

/// The icon of the ad.
@property (nonatomic, readonly, nullable, strong) SASNativeAdImage *icon;

/// The cover image of the ad.
///
/// A cover image is an image that is generally larger that the icon and that will generally be used as a background image.
@property (nonatomic, readonly, nullable, strong) SASNativeAdImage *coverImage;

/// The 'sponsored by' message of the ad.
///
/// Generally contains the brand name of the sponsor.
@property (nonatomic, readonly, nullable, strong) NSString *sponsored;

/// The rating between 0-5 of the advertised app / product or SASRatingUndefined if not set.
@property (nonatomic, readonly) float rating;

/// Number of social likes of the advertised app / product or SASLikesUndefined if not set.
@property (nonatomic, readonly) int64_t likes;

/// Number of downloads / installs of the advertised app or SASDownloadsUndefined if not set.
@property (nonatomic, readonly) int64_t downloads;

/// A dictionary of custom parameters that have been sent by the ad.
///
/// This dictionary can be used to carry additional resources or information. You need a compatible Smart AdServer template to use this feature.
@property (nonatomic, readonly, nullable, strong) NSDictionary *extraParameters;

#pragma mark - Other properties

/// The object that acts as the delegate of the receiving native ad.
///
/// The delegate must adopt the SASNativeAdDelegate protocol.
@property (nonatomic, nullable, weak) id <SASNativeAdDelegate> delegate;

/// Indicates whether the native ad has a media to be displayed in a SASNativeAdMediaView.
@property (nonatomic, readonly) BOOL hasMedia;

/// The aspect ratio of the media (width / height).
@property (nonatomic, readonly) float mediaAspectRatio;

/// A string which contains useful informations about the ad.
///
/// This string can be sent to Smart's support to improve bug resolution if the issue is related
/// to a given ad, or can be used with your app crash reporting tool to analyze crash sources.
///
/// @warning The string content and format is not guaranted to stay the same: you should avoid parsing it.
@property (nonatomic, readonly) NSString *debugString;

#pragma mark - Util methods

/**
 Returns the recommanded height to display the native ad media in a given container, according to the media aspect ratio.
 
 If no media exists, this method will return 0.
 
 If 'container' is nil, the height returned will be the optimal height for a fullscreen width.
 
 @param container The container in which the ad media will be displayed (if nil, the current window will be used instead).
 @return The optimized height for the mediaview.
 */
- (CGFloat)optimalMediaViewHeightForContainer:(nullable UIView *)container;

/**
 Returns the recommanded height to display the native ad media in a given width, according to the media aspect ratio.
 
 If no media exists, this method will return 0.
 
 @param width The width of the container in which the ad media will be displayed (if nil, the current window will be used instead).
 @return The optimized height for a given width.
 */
- (CGFloat)optimalMediaViewHeightForWidth:(CGFloat)width;

/**
 Returns the recommanded height to display the native cover image in a given container, according to the cover image aspect ratio.
 
 If no cover image exists, this method will return 0.
 
 If 'container' is nil, the height returned will be the optimal height for a fullscreen width.
 
 @param container The container in which the ad cover image will be displayed (if nil, the current window will be used instead).
 @return The optimized height for the cover image.
 */
- (CGFloat)optimalCoverViewHeightForContainer:(nullable UIView *)container;

/**
 Returns the recommanded height to display the native ad cover image in a given width, according to the cover image aspect ratio.
 
 If no cover image exists, this method will return 0.
 
 @param width The width of the container in which the ad cover image will be displayed (if nil, the current window will be used instead)
 @return The optimized height for a given width
 */
- (CGFloat)optimalCoverViewHeightForWidth:(CGFloat)width;

#pragma mark - View registering

/**
 Registers the view that will be used for viewability tracking and tappable views that will be used as click target in your native ad.
 
 @note You MUST register at least one view for each displayed native ad otherwise the impression will not be registered.
 
 @param view A view that will be registered as main view and used for viewability tracking.
 @param views An array of views that will be registered as click target.
 @param modalParentViewController The view controller that will be used if the ad needs to open a modal view or a store controller.
 */
- (void)registerView:(UIView *)view tappableViews:(NSArray *)views modalParentViewController:(UIViewController *)modalParentViewController;

/**
 Convenient method to register only one view as click target and viewability tracking.
 
 @note You MUST register at least one view for each displayed native ad otherwise the impression will not be registered.
 
 @param view A view that will be registered as click target and used for viewability tracking.
 @param modalParentViewController The view controller that will be used if the ad needs to open a modal view or a store controller.
 */
- (void)registerView:(UIView *)view modalParentViewController:(UIViewController *)modalParentViewController;

/**
 Unregisters all views that are currently being used as click target.
 */
- (void)unregisterViews;

@end

NS_ASSUME_NONNULL_END
