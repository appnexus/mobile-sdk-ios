//
//  SASNativeAdMediaView.h
//  SmartAdServer
//
//  Created by Thomas Geley on 29/06/2016.
//
//

#import <UIKit/UIKit.h>
#import "SASNativeAdMediaViewDelegate.h"

/** The SASNativeAdMediaView class provides a wrapper view that is able to play medias from a SASNativeAd.
 
 Some SASNativeAd comes with a media (most of the time a video) that needs to be played.
 You can use the method [SASNativeAd hasMedia] to know if your SASNativeAd needs a SASNativeAdMediaView to be displayed properly. (See SASNativeAd documentation for more infos).
 
 Native ads medias cannot be played outside of a SASNativeAdMediaView.
 
 The delegate of a SASNativeAdMediaView object must adopt the SASNativeAdMediaViewDelegate protocol.
 The protocol methods allow the delegate to be aware of the media related events.
 
 */

@class SASNativeAd;

@interface SASNativeAdMediaView : UIView

///-----------------------------------
/// @name Media View properties
///-----------------------------------

/** The object that acts as the delegate of the receiving SASNativeAdMediaView.

The delegate must adopt the SASAdNativeAdMediaViewDelegate protocol.

@warning *Important* : The delegate is not retained by the SASNativeAdMediaView, so you need to set the ad's delegate to nil before the delegate is released.

*/

@property (nonatomic, nullable, weak) id <SASNativeAdMediaViewDelegate> delegate;


/** The SASNativeAd currently registered with the MediaView.
 
This Native Ad must have a media and cannot be registered to another SASNativeAdMediaView.
 
 */

@property (nonatomic, nullable, readonly, strong) SASNativeAd *nativeAd;


///-----------------------------------
/// @name Registering Native Ads
///-----------------------------------

/** Register the NativeAd that will use the MediaView to display its media (video most of the time).
 
 You MUST register the SASNativeAd for it to be able to play its media. NativeAd Medias cannot be played outside of their SASNativeAdMediaView.
 
 @param nativeAd The SASNativeAd to be registered to play its media in the MediaView.
 
 */

- (void)registerNativeAd:(nonnull SASNativeAd *)nativeAd;


///-----------------------------------
/// @name Media Playback
///-----------------------------------

/**
 Indicates whether the MediaView is currently playing a media.
 */

- (BOOL)isPlayingMedia;


@end

