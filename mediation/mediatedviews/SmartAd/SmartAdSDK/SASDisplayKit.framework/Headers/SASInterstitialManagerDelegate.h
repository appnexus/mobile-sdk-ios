//
//  SASInterstitialManagerDelegate.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 26/07/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "SASVideoEvent.h"

NS_ASSUME_NONNULL_BEGIN

@class SASInterstitialManager, SASAd;

/**
 Protocol that must be implemented by SASInterstitialManager delegate.
 */
@protocol SASInterstitialManagerDelegate <NSObject>

@optional

/**
 Notifies the delegate that an ad has been loaded and is ready to be displayed.
 
 @param manager The instance of SASInterstitialManager that called this delegate method.
 @param ad The ad that has been loaded.
 */
- (void)interstitialManager:(SASInterstitialManager *)manager didLoadAd:(SASAd *)ad;

/**
 Notifies the delegate that the last ad call has failed. Check the error for more information.
 
 @param manager The instance of SASInterstitialManager that called this delegate method.
 @param error The error that occurred during the ad loading.
 */
- (void)interstitialManager:(SASInterstitialManager *)manager didFailToLoadWithError:(NSError *)error;

/**
 Notifies the delegate that the ad cannot be displayed. Check the error for more information.
 
 @param manager The instance of SASInterstitialManager that called this delegate method.
 @param error The error that occurred when showing the ad.
 */
- (void)interstitialManager:(SASInterstitialManager *)manager didFailToShowWithError:(NSError *)error;

/**
 Notifies the delegate that the ad has been displayed.
 
 @param manager The instance of SASInterstitialManager that called this delegate method.
 @param viewController The view controller used to display the ad.
 */
- (void)interstitialManager:(SASInterstitialManager *)manager didAppearFromViewController:(UIViewController *)viewController;

/**
 Notifies the delegate that the ad has been closed.
 
 @param manager The instance of SASInterstitialManager that called this delegate method.
 @param viewController The view controller used to display the ad.
 */
- (void)interstitialManager:(SASInterstitialManager *)manager didDisappearFromViewController:(UIViewController *)viewController;

/**
 Notifies the delegate that a video event has been sent by the video player.
 
 @note This method will only be called in case of video ad.
 
 @param manager The instance of SASInterstitialManager that called this delegate method.
 @param videoEvent The video event sent by the video player.
 */
- (void)interstitialManager:(SASInterstitialManager *)manager didSendVideoEvent:(SASVideoEvent)videoEvent;

/**
 Returns whether the SDK should handle the opening of a given click URL.
 
 @note Click counting will happen no matter if the URL is handled by the SDK or by your application.
 
 @param manager The instance of SASInterstitialManager that called this delegate method.
 @param URL The URL that must be handled.
 @return YES if the URL must be handled by the SDK, NO if your application will handle the URL itself.
 */
- (BOOL)interstitialManager:(SASInterstitialManager *)manager shouldHandleURL:(NSURL *)URL;

/**
 Notifies the delegate that a message has been sent by the MRAID creative.
 
 MRAID creatives can send messages using mraid.sasSendMessage("message"). These messages are sent to the interstitial manager delegate by the SDK.
 Please note that this method IS NOT PART of MRAID 2.0 specification.
 
 @param manager The instance of SASInterstitialManager that called this delegate method.
 @param message The message sent by the creative.
 */
- (void)interstitialManager:(SASInterstitialManager *)manager didReceiveMessage:(NSString *)message;

/**
 Notifies the delegate that a click modal view controller will be open.
 
 @param manager The instance of SASInterstitialManager that called this delegate method.
 @param viewController The view controller used to display the ad.
 */
- (void)interstitialManager:(SASInterstitialManager *)manager willPresentModalViewFromViewController:(UIViewController *)viewController;

/**
 Notifies the delegate that a click modal view controller will be closed.
 
 @param manager The instance of SASInterstitialManager that called this delegate method.
 @param viewController The view controller used to display the ad.
 */
- (void)interstitialManager:(SASInterstitialManager *)manager willDismissModalViewFromViewController:(UIViewController *)viewController;

/**
 Returns whether the SDK should handle the audio session.
 
 The SDK might want to handle the audio session when playing some video ads to control how the ad sound will
 interact with other apps or to completely mute the ad.
 
 @param manager The instance of SASInterstitialManager that called this delegate method.
 @return YES if the SDK can handle the audio session, NO if your application can handle the session itself.
 */
- (BOOL)interstitialManagerShouldHandleAudioSession:(SASInterstitialManager *)manager;

/**
 Notifies the delegate that the ad will start playing audio.
 
 @param manager The instance of SASInterstitialManager that called this delegate method.
 */
- (void)interstitialManagerWillPlayAudio:(SASInterstitialManager *)manager;

/**
 Notifies the delegate that the ad will stop playing audio.
 
 @param manager The instance of SASInterstitialManager that called this delegate method.
 */
- (void)interstitialManagerDidFinishPlayingAudio:(SASInterstitialManager *)manager;

@end

NS_ASSUME_NONNULL_END
