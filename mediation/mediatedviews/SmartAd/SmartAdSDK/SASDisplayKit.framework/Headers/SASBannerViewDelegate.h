//
//  SASBannerViewDelegate.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 27/08/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SASVideoEvent.h"

NS_ASSUME_NONNULL_BEGIN

@class SASBannerView, SASAd;

/**
 Protocol that must be implemented by SASBannerView delegate.
 */
@protocol SASBannerViewDelegate <NSObject>

@optional

#pragma mark - Ad view lifecycle

/**
 Notifies the delegate that the ad data has been received.
 
 @note The ad creative is not loaded and/or displayed at this point.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 @param ad A SASAd object.
 */
- (void)bannerView:(SASBannerView *)bannerView didDownloadAd:(SASAd *)ad;

/**
 Notifies the delegate that the creative from the current ad has been loaded and displayed.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 */
- (void)bannerViewDidLoad:(SASBannerView *)bannerView;

/**
 Notifies the delegate that the SASBannerView failed to download the ad.
 
 This can happen when the user's connection is interrupted before downloading the ad
 or if the ad is invalid.
 
 @note Remember to remove the SASBannerView instance from its superview if necessary.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 @param error An error informing the delegate about the cause of the failure.
 */
- (void)bannerView:(SASBannerView *)bannerView didFailToLoadWithError:(NSError *)error;

/**
 Notifies the delegate that the expandable SASBannerView did collapse.
 
 This can happen:
 
 - if the user tapped the toggle button to close the ad,
 - when the ad's display duration is elapsed.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 */
- (void)bannerViewDidCollapse:(SASBannerView *)bannerView;

/**
 Notifies the delegate that a modal view will appear to display the ad's landing page.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 */
- (void)bannerViewWillPresentModalView:(SASBannerView *)bannerView;

/**
 Notifies the delegate that the previously open modal view will be dismissed.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 */
- (void)bannerViewWillDismissModalView:(SASBannerView *)bannerView;

/**
 Asks the delegate whether the SDK should handles the opening action for the provided URL.
 
 You can implement this method if you want to process some URLs yourself, for instance to make
 an in app redirection.
 
 @note Please note that click pixels will be sent, even if you choose to handle a particular URL yourself.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 @param URL The URL that will be called.
 @return YES if the Smart Display SDK should handle the URL, NO if the app should do it manually.
 */
- (BOOL)bannerView:(SASBannerView *)bannerView shouldHandleURL:(NSURL *)URL;

#pragma mark - MRAID

/**
 Notifies the delegate that the banner view is about to be resized.
 
 @note This method is not only called the first time an ad creative is resized, but also when the user rotates the device.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 @param frame The frame of the ad view before resizing it.
 */
- (void)bannerView:(SASBannerView *)bannerView willResizeWithFrame:(CGRect)frame;

/**
 Notifies the delegate that the banner view was resized.
 
 @note This method is not only called the first time an ad creative is resized, but also when the user rotates the device.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 @param frame The frame of the ad view after resizing it.
 */
- (void)bannerView:(SASBannerView *)bannerView didResizeWithFrame:(CGRect)frame;

/**
 Notifies the delegate that the banner view was resized.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 @param error The error that prevented the banner from being resized
 */
- (void)bannerViewDidFailToResize:(SASBannerView *)bannerView error:(NSError *)error;

/**
 Notifies the delegate that the resized banner was closed (i.e. is back in its original container).
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 @param frame The frame of the ad view after closing it.
 */
- (void)bannerView:(SASBannerView *)bannerView didCloseResizeWithFrame:(CGRect)frame;

/**
 Notifies the delegate that the banner view is about to be expanded.
 
 @note This method is not only called the first time an ad creative is expanded, but also when the user rotates the device.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 */
- (void)bannerViewWillExpand:(SASBannerView *)bannerView;

/**
 Notifies the delegate that the banner view was expanded.
 
 @warning This method is not only called the first time an ad creative is expanded, but also when the user rotates the device.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 @param frame The frame of the ad view after expanding.
 */
- (void)bannerView:(SASBannerView *)bannerView didExpandWithFrame:(CGRect)frame;

/**
 Notifies the delegate that the expanded banner is about to be closed (i.e. will be back in its original container).
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 */
- (void)bannerViewWillCloseExpand:(SASBannerView *)bannerView;

/**
 Notifies the delegate that the expanded banner was closed (i.e. is back in its original container).
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 @param frame The frame of the ad view after closing.
 */
- (void)bannerView:(SASBannerView *)bannerView didCloseExpandWithFrame:(CGRect)frame;

/**
 Notifies the delegate that the banner view received a message from the MRAID creative.
 
 Creatives can send messages using mraid.sasSendMessage("message"). These messages are sent to the ad view delegate by the SDK.
 
 @note this method IS NOT PART of MRAID 2.0 specification.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 @param message The message sent by the creative.
 */
- (void)bannerView:(SASBannerView *)bannerView didReceiveMessage:(NSString *)message;

/**
 Returns the visibility percentage of the banner view
 
 @note Visibility is already computed by the Smart Display SDK. Override this only if this computation does not work
 for your particular integration.
 
 @warning This method is called each 500ms by the Smart Display SDK: do not perform heavy computation in it.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 @return Visibility percentage value between 0 and 1.
 */
- (CGFloat)visibilityPercentageForBannerView:(SASBannerView *)bannerView;

#pragma mark - Sticky ads in scroll views

/**
 Notifies the delegate that the banner view stuck/unstuck one of its subview to the view hierarchy.
 
 This method will only be called when the SASBannerView is added to a scrollview instance (UITableView, UICollectionView…) and only
 for ads format with the stickToTop feature.
 
 Implement this method if you want to be able to modify the frame of the sticked view, for example if your UINavigationBar
 disappears at some point of the scroll, etc…
 
 @note This method is not only called the first time an ad creative is expanded, but also when the user rotates the device.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 @param stickyView The view instance that is stuck/unstuck to the UIWindow.
 @param stuck YES if the view is stuck, NO if the view is not stuck anymore
 @param stickyFrame The frame of the stickyView.
 */
- (void)bannerView:(SASBannerView *)bannerView withStickyView:(UIView *)stickyView didStick:(BOOL)stuck withFrame:(CGRect)stickyFrame;

/**
 Asks the delegate wether the banner view can stick to top or not.
 
 This method will be called when the SASBannerView is binded to a scrollview instance (UITableView, UICollectionView…) and
 when stick to top conditions are met: ads format with this feature, scroll view offset reaching top of the screen, etc…
 
 Implement this method if you want to be able to prevent an ad from sticking to top: for example, if you have loaded several banner
 views in the same controller and display only some of them, etc…
 
 @note This method is not only called the first time stick to top conditions are met but every time until ad is stuck.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 */

- (BOOL)bannerViewCanStickToTop:(SASBannerView *)bannerView NS_SWIFT_NAME(bannerViewCanStickToTop(_:));

#pragma mark - Native audio playback

/**
 Tells the banner view if it should handle AVAudioSession on its own when playing native (audio/video) ads.
 
 Implement this method and return NO if you want to override ad view's behavior with AVAudioSession.
 
 Use the adViewWillPlayAudio: and adViewDidFinishPlayingAudio: methods to implement your own behavior.
 
 @warning Disabling AVAudioSession handling can prevent the SDK to change the volume for a creative or to display mute/unmute buttons on some formats.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 @return YES (default if not implemented) to let ad view handle AVAudioSession for native videos, NO to implement your own behavior.
 */
- (BOOL)bannerViewShouldHandleAudioSession:(SASBannerView *)bannerView;

/**
 Notifies the delegate that the banner view will start playing native audio.
 
 Implement this method if you want to know when an ad view starts playing native audio (e.g. from a native video).
 
 This is useful if you want to pause your own audio, change the shared AudioSession or trigger other custom behavior.
 
 @note This method will only be triggered by native creatives, not by HTML based creatives.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 */
- (void)bannerViewWillPlayAudio:(SASBannerView *)bannerView;

/**
 Notifies the delegate that the banner view finished playing native audio.
 
 Implement this method if you want to know when an ad view finishes playing native audio (e.g. from a native video).
 
 This is useful if you want to resume your own audio, change the shared AudioSession or trigger other custom behavior.
 
 @note This method will only be triggered by native creatives, not by HTML based creatives.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 */
- (void)bannerViewDidFinishPlayingAudio:(SASBannerView *)bannerView;

/**
 Notifies the delegate that a video event has been generated by the banner view.
 
 Implement this method if you want to know when some events are reached when a video is played.
 
 This can be useful if you want to implement specific app behavior when the user interact with the video or when he
 reach a certain point of the video.
 
 @note This method will only be triggered by native creatives, not by HTML based creatives.
 
 @param bannerView The instance of SASBannerView that called this delegate method.
 @param videoEvent The video event that has been triggered.
 */
- (void)bannerView:(SASBannerView *)bannerView didSendVideoEvent:(SASVideoEvent)videoEvent;

@end

NS_ASSUME_NONNULL_END
