//
//  SASRewardedVideoDelegate.h
//  SmartAdServer
//
//  Created by Thomas Geley on 13/06/2017.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "SASVideoEvent.h"

NS_ASSUME_NONNULL_BEGIN

@class SASRewardedVideoPlacement, SASReward, SASAd;

@protocol SASRewardedVideoDelegate <NSObject>

@optional

/** 
 Notifies the delegate that a rewarded video has been loaded and is ready to be shown.
 
 @param ad The SASAd instance that has been loaded.
 @param placement The SASRewardedVideoPlacement instance associated with this rewarded video.
 
 */
- (void)rewardedVideoDidLoadAd:(SASAd *)ad forPlacement:(SASRewardedVideoPlacement *)placement;


/**
 Notifies the delegate that a rewarded video has failed to load.
 
 @param placement The SASRewardedVideoPlacement instance associated with this rewarded video.
 @param error An error with information about the loading failure.
 
 */
- (void)rewardedVideoDidFailToLoadForPlacement:(SASRewardedVideoPlacement *)placement error:(nullable NSError *)error;


/**
 Notifies the delegate that a rewarded video has failed to show / play.
 
 @param placement The SASRewardedVideoPlacement instance associated with this rewarded video.
 @param error An error with information about the failure.
 
 */
- (void)rewardedVideoDidFailToShowForPlacement:(SASRewardedVideoPlacement *)placement error:(nullable NSError *)error;


/**
 Notifies the delegate that a rewarded video associated view has been added to the view hierarchy and is now shown.
 
 @param placement The SASRewardedVideoPlacement instance associated with this rewarded video.
 @param controller The view controller where the ad's view has been added to the view hierarchy.
 
 */
- (void)rewardedVideoDidAppearForPlacement:(SASRewardedVideoPlacement *)placement fromViewController:(UIViewController *)controller;


/**
 Notifies the delegate that a rewarded video associated view has been removed from the view hierarchy and is not shown anymore.
 
 @param placement The SASRewardedVideoPlacement instance associated with this rewarded video.
 @param controller The view controller from which the ad's view has been removed from the view hierarchy.
 
 */
- (void)rewardedVideoDidDisappearForPlacement:(SASRewardedVideoPlacement *)placement fromViewController:(UIViewController *)controller;


/**
 Notifies the delegate that a rewarded video forwarded a video event (see relevant enum for details).
 
 @param placement The SASRewardedVideoPlacement instance associated with this rewarded video.
 @param videoEvent The SASVideoEvent forwarded.
 
 */
- (void)rewardedVideoForPlacement:(SASRewardedVideoPlacement *)placement didSendVideoEvent:(SASVideoEvent)videoEvent;


/** 
 Notifies the delegate that the user should be rewarded for watching a video.
 
 Implement this method if you want to use the Rewarded Video feature.
 Check the properties of the SASReward object to design your response to this method.
 
 @param placement The SASRewardedVideoPlacement instance associated with this rewarded video.
 @param reward The SASReward object collected. See its documentation to know the available properties.
 
 */
- (void)rewardedVideoForPlacement:(SASRewardedVideoPlacement *)placement didCollectReward:(SASReward *)reward;


/** 
 Asks the delegate whether to execute the ad action.
 
 Implement this method if you want to process some URLs yourself.
 
 @param placement The SASRewardedVideoPlacement instance associated with this rewarded video.
 @param URL The URL that will be called.
 @return Whether the Smart AdServer SDK should handle the URL.
 @warning Returning NO means that the URL won't be processed by the SDK.
 @warning Please note that a click will be counted, even if you return NO (you are supposed to handle the URL in this case).
 
 */
- (BOOL)rewardedVideoForPlacement:(SASRewardedVideoPlacement *)placement shouldHandleURL:(NSURL *)URL;


/** 
 Notifies the delegate that a modal view will appear to display the ad's redirect URL web page if appropriate.
 This won't be called in case of URLs which should not be displayed in a browser like YouTube, iTunes,...
 In this case, it will call adView:shouldHandleURL:.
 
 @param placement The SASRewardedVideoPlacement instance associated with this rewarded video.
 @param controller The view controller from which the modal view will be presented.
 
 */
- (void)rewardedVideoForPlacement:(SASRewardedVideoPlacement *)placement willPresentModalViewFromViewController:(UIViewController *)controller;


/**
 Notifies the delegate that the modal view will be dismissed.
 
 @param placement The SASRewardedVideoPlacement instance associated with this rewarded video.
 @param controller The view controller from which the modal view will be dismissed.
 
 */
- (void)rewardedVideoForPlacement:(SASRewardedVideoPlacement *)placement willDismissModalViewFromViewController:(UIViewController *)controller;


/** 
 Tells the rewarded video if it should handle AVAudioSession on its own when playing native (audio/video) ads.
 
 Implement this method and return NO if you want to override ad view's behavior with AVAudioSession.
 
 Use the rewardedVideoWillPlayAudio: and rewardedVideoDidFinishPlayingAudio: methods to implement your own behavior.
 
 @return YES (default if not implemented) to let ad view handle AVAudioSession for native videos, NO to implement your own behavior.
 
 @warning Disabling AVAudioSession handling can prevent the SDK to change the volume for a creative or to display mute/unmute buttons on some formats.
 
 */
- (BOOL)rewardedVideoShouldHandleAudioSession;


/** 
 Notifies the delegate that the rewarded video will start playing native audio.
 
 Implement this method if you want to know when an ad view starts playing native audio (e.g. from a native video).
 This is useful if you want to pause your own audio, change the shared AudioSession or trigger other custom behavior.
 
 @warning This method will only be triggered by native creatives, not by HTML based creatives.
 
 */
- (void)rewardedVideoWillPlayAudio;


/** 
 Notifies the delegate that the ad view finished playing native audio.
 
 Implement this method if you want to know when an ad view finishes playing native audio (e.g. from a native video).
 This is useful if you want to resume your own audio, change the shared AudioSession or trigger other custom behavior.
 
 @warning This method will only be triggered by native creatives, not by HTML based creatives.
 
 */
- (void)rewardedVideoDidFinishPlayingAudio;


/** 
 Notifies the delegate that the end card creative from the current rewarded video ad has been loaded and displayed.
 
 @param placement The SASRewardedVideoPlacement instance associated with this rewarded video.
 @param view The UIView instance where the end card is displayed.
 @param controller The view controller where the end card's view is displayed.
 
 */
- (void)rewardedVideoForPlacement:(SASRewardedVideoPlacement *)placement didLoadEndCardInView:(UIView *)view fromViewController:(UIViewController *)controller;


/**
 Notifies the delegate that the rewarded video will start playing native video.
 
 Implement this method if you want to know when an ad view starts playing native video (e.g. from a native video).
 This is useful if you want to track on your side the AVPlayer behaviour.
 
 @param placement The SASRewardedVideoPlacement instance associated with this rewarded video.
 @param player The AVPlayer instance which is going to play the video.
 @param playerLayer A CALayer inheriting instance. AVPlayerLayer class for standard native videos. CALayer class for 360° native videos.
 @param containingView The UIView which is going to contain the video.
 
 @warning Interacting with the AVPlayer instance can lead to unexpected behaviour. This method will only be triggered by native video creatives, not by HTML based creatives.
 
 */
- (void)rewardedVideoForPlacement:(SASRewardedVideoPlacement *)placement willPlayVideoWithAVPlayer:(AVPlayer *)player withPlayerLayer:(CALayer *)playerLayer withContainingView:(UIView *)containingView;

@end

NS_ASSUME_NONNULL_END
