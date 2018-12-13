//
//  SASNativeAdMediaView.h
//  SmartAdServer
//
//  Created by Thomas Geley on 29/06/2016.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASNativeAdMediaViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class SASNativeAd;

/**
 Provides a standard view used to play SASNativeAd media.
 
 Some SASNativeAd comes with a media (most of the time a video) that needs to be played. You can use the
 method [SASNativeAd hasMedia] to know if your SASNativeAd needs a SASNativeAdMediaView to be displayed
 properly. (See Native Ads documentation for more information).
 
 @note Native ad media cannot be played outside of a SASNativeAdMediaView.
 */
@interface SASNativeAdMediaView : UIView

#pragma mark - Media view properties

/// The object that acts as the delegate of the receiving SASNativeAdMediaView.
@property (nonatomic, nullable, weak) id <SASNativeAdMediaViewDelegate> delegate;

/// The SASNativeAd currently registered with the MediaView.
///
/// This native ad must have a media and cannot be registered to another SASNativeAdMediaView.
@property (nonatomic, nullable, readonly, strong) SASNativeAd *nativeAd;

/// YES if the view is currently playing media, NO otherwise.
@property (nonatomic, readonly) BOOL isPlayingMedia;

#pragma mark - Registering Native Ads

/**
 Registers the native ad that will use this media view to display its media.
 
 You MUST register the SASNativeAd for it to be able to play its media. Native ad media cannot be played
 outside of their SASNativeAdMediaView.
 
 @param nativeAd The SASNativeAd to be registered to play its media in this media view.
 */
- (void)registerNativeAd:(SASNativeAd *)nativeAd;

@end

NS_ASSUME_NONNULL_END
