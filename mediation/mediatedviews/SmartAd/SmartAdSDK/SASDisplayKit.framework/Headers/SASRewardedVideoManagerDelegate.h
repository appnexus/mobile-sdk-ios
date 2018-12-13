//
//  SASRewardedVideoManagerDelegate.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 13/06/2017.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASVideoEvent.h"

NS_ASSUME_NONNULL_BEGIN

@class SASAdPlacement, SASRewardedVideoManager, SASReward, SASAd;

/**
 Protocol that must be implemented by SASRewardedVideoManager delegate.
 */
@protocol SASRewardedVideoManagerDelegate <NSObject>

@optional

/**
 Notifies the delegate that an ad has been loaded and is ready to be displayed.
 
 @param manager The instance of SASRewardedVideoManager that called this delegate method.
 @param ad The ad that has been loaded.
 */
- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didLoadAd:(SASAd *)ad;

/**
 Notifies the delegate that the last ad call has failed. Check the error for more information.
 
 @param manager The instance of SASRewardedVideoManager that called this delegate method.
 @param error The error that occurred during the ad loading.
 */
- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didFailToLoadWithError:(NSError *)error;

/**
 Notifies the delegate that the ad cannot be displayed. Check the error for more information.
 
 @param manager The instance of SASRewardedVideoManager that called this delegate method.
 @param error The error that occurred when showing the ad.
 */
- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didFailToShowWithError:(NSError *)error;

/**
 Notifies the delegate that the ad has been displayed.
 
 @param manager The instance of SASRewardedVideoManager that called this delegate method.
 @param viewController The view controller used to display the ad.
 */
- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didAppearFromViewController:(UIViewController *)viewController;

/**
 Notifies the delegate that the ad has been closed.
 
 @param manager The instance of SASRewardedVideoManager that called this delegate method.
 @param viewController The view controller used to display the ad.
 */
- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didDisappearFromViewController:(UIViewController *)viewController;

/**
 Notifies the delegate that a video event has been sent by the video player.
 
 @note This method will only be called in case of video ad.
 
 @param manager The instance of SASRewardedVideoManager that called this delegate method.
 @param videoEvent The video event sent by the video player.
 */
- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didSendVideoEvent:(SASVideoEvent)videoEvent;

/**
 Notifies the delegate that a reward has been granted to the user.
 
 @param manager The instance of SASRewardedVideoManager that called this delegate method.
 @param reward The reward that has been retrieved.
 */
- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didCollectReward:(SASReward *)reward;

/**
 Returns whether the SDK should handle the opening of a given click URL.
 
 @note Click counting will happen no matter if the URL is handled by the SDK or by your application.
 
 @param manager The instance of SASRewardedVideoManager that called this delegate method.
 @param URL The URL that must be handled.
 @return YES if the URL must be handled by the SDK, NO if your application will handle the URL itself.
 */
- (BOOL)rewardedVideoManager:(SASRewardedVideoManager *)manager shouldHandleURL:(NSURL *)URL;

/**
 Notifies the delegate that a click modal view controller will be open.
 
 @param manager The instance of SASRewardedVideoManager that called this delegate method.
 @param viewController The view controller used to display the ad.
 */
- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager willPresentModalViewFromViewController:(UIViewController *)viewController;

/**
 Notifies the delegate that a click modal view controller will be closed.
 
 @param manager The instance of SASRewardedVideoManager that called this delegate method.
 @param viewController The view controller used to display the ad.
 */
- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager willDismissModalViewFromViewController:(UIViewController *)viewController;

/**
 Returns whether the SDK should handle the audio session.
 
 The SDK might want to handle the audio session when playing some video ads to control how the ad sound will
 interact with other apps or to completely mute the ad.
 
 @param manager The instance of SASRewardedVideoManager that called this delegate method.
 @return YES if the SDK can handle the audio session, NO if your application can handle the session itself.
 */
- (BOOL)rewardedVideoManagerShouldHandleAudioSession:(SASRewardedVideoManager *)manager;

/**
 Notifies the delegate that the ad will start playing audio.
 
 @param manager The instance of SASRewardedVideoManager that called this delegate method.
 */
- (void)rewardedVideoManagerWillPlayAudio:(SASRewardedVideoManager *)manager;

/**
 Notifies the delegate that the ad will stop playing audio.
 
 @param manager The instance of SASRewardedVideoManager that called this delegate method.
 */
- (void)rewardedVideoManagerDidFinishPlayingAudio:(SASRewardedVideoManager *)manager;

/**
 Notifies the delegate that the ad has finished playing the video ad and has open an HTML end card.
 
 @param manager The instance of SASRewardedVideoManager that called this delegate method.
 @param viewController The view controller used to display the end card.
 */
- (void)rewardedVideoManager:(SASRewardedVideoManager *)manager didLoadEndCardFromViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
