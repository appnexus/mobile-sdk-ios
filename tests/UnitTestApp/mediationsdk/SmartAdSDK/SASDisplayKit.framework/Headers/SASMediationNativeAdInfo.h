//
//  SASMediationNativeAdInfo.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 13/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASNativeAdImage.h"
#import "SASNativeAd.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a native ad that has been retrieved from a third party mediation SDK.
 
 Use this class to forward information from a mediation SDK to the Smart Display SDK so it
 can use it in its mediation waterfall.
 */
@interface SASMediationNativeAdInfo : NSObject

#pragma mark - Required information

/// The title of the ad (required).
@property (nonatomic, readonly) NSString *title;

#pragma mark - Optional information

/// The subtitle of the ad.
///
/// Can be used as a short description.
@property (nonatomic, copy, nullable) NSString *subtitle;

/// The body of the ad.
///
/// Can be used as a long description.
@property (nonatomic, copy, nullable) NSString *body;

/// The call to action text of the ad.
///
/// This text represents the action that will be made when the ad is clicked: for instance 'Open' or 'Download'.
@property (nonatomic, copy, nullable) NSString *callToAction;

/// The icon of the ad.
@property (nonatomic, strong, nullable) SASNativeAdImage *icon;

/// The cover image of the ad.
///
/// A cover image is an image that is generally larger that the icon and that will generally be used as a background image.
@property (nonatomic, strong, nullable) SASNativeAdImage *coverImage;

/// The video URL that should be displayed by a media view.
@property (nonatomic, strong, nullable) NSURL *videoURL;

/// An optional dictionary of video tracking events that will be called by the media view.
///
/// These video events must have a valid event name (NSString type) as key and a valid URL
/// (NSURL type) as object, otherwise they will be ignored.
///
/// Valid event names are:
/// - click
/// - creativeView
/// - start
/// - firstQuartile
/// - midpoint
/// - thirdQuartile
/// - complete
/// - mute
/// - unmute
/// - pause
/// - rewind
/// - resume
/// - fullscreen
/// - exitFullscreen
/// - progress
/// - timeToClick
/// - skip
/// - vpaidAdInteraction
@property (nonatomic, strong, nullable) NSDictionary *videoTrackingEvents;

/// The 'sponsored by' message of the ad.
///
/// Generally contains the brand name of the sponsor.
@property (nonatomic, copy, nullable) NSString *sponsored;

/// The rating between 0-5 of the advertised app / product or SASRatingUndefined if not set.
@property (nonatomic, assign) float rating;

/// Number of social likes of the advertised app / product or SASLikesUndefined if not set.
@property (nonatomic, assign) long likes;

/// Number of downloads / installs of the advertised app or SASDownloadsUndefined if not set.
@property (nonatomic, assign) long downloads;

/// A list of impression URLs that should be called by the Smart SDK when the impression is counted.
@property (nonatomic, strong, nullable) NSArray *impressionURLs;

/// A list of click counting URLs that should be called by the Smart SDK when the ad is clicked.
@property (nonatomic, strong, nullable) NSArray *countClickURLs;

#pragma mark - Init method

/**
 Initialize a new instance of SASMediationNativeAdInfo.
 
 @param title The title of the mediation ad.
 @return An Initialized new instance of SASMediationNativeAdInfo.
 */
- (instancetype)initWithTitle:(NSString *)title;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
