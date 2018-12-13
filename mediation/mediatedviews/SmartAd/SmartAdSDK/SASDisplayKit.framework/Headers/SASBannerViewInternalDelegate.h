//
//  SASBannerViewDelegate.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 28/08/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SASVideoEvent.h"

NS_ASSUME_NONNULL_BEGIN

@class SASBannerView;

/**
 Internal SASBannerView delegate.
 
 This delegate can be used to retrieve internal views and events of the SDK. It should only
 be implemented to if you are using a third party SDK responsible to measure some stats on
 your ads SDKs.
 
 @warning Views and objects retrieved from these methods should never be used for anything else
 than viewability and performance measurement. These internal objects might change without warning
 in future SDK version.
 */
@protocol SASBannerViewInternalDelegate <NSObject>

/**
 Notifies the delegate that the banner view will start playing native video.
 
 Implement this method if you want to know when an banner view starts playing native video (e.g. from a native video).
 
 This is useful if you want to track on your side the AVPlayer behaviour.
 
 @warning Interacting with the AVPlayer instance can lead to unexpected behaviour. This method will only be triggered
 by native video creatives, not by HTML based creatives.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 @param player The AVPlayer instance responsible for playing the video.
 @param playerLayer A CALayer inheriting instance. AVPlayerLayer class for standard native videos. CALayer class for 360° native videos.
 @param containingView The UIView which is going to contain the video layer.
 */
- (void)bannerView:(SASBannerView *)bannerView willPlayVideoWithAVPlayer:(AVPlayer *)player withPlayerLayer:(CALayer *)playerLayer withContainingView:(UIView *)containingView;

/**
 Notifies the delegate that the layer rendering the current native video ad did change
 to a new CALayer instance and/or a new container view.
 
 This method will be called for Video-Read ads when they enter fullscreen.
 
 Implement this method if you want to know when a playing native video ad changes its rendering layer or its hierarchical parent.
 
 This is useful if you want to track the viewability of the video ad.
 
 @warning Interacting with the AVPlayer instance can lead to unexpected behaviour. This method will only be triggered
 by native video creatives, not by HTML based creatives.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 @param player The AVPlayer instance responsible for playing the video.
 @param playerLayer A CALayer inheriting instance where the video is rendered. AVPlayerLayer class for standard native
 videos. CALayer class for 360° native videos.
 @param containingView The UIView which is going to contain the video layer.
 */
- (void)bannerView:(SASBannerView *)bannerView withAVPlayer:(AVPlayer *)player didSwitchToPlayerLayer:(CALayer *)playerLayer withContainingView:(UIView *)containingView;

@end

NS_ASSUME_NONNULL_END
