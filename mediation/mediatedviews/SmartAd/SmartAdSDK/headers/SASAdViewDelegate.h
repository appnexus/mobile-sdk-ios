//
//  SASAdViewDelegate.h
//  SmartAdServer
//
//  Created by Clémence Laurent on 23/07/12.
//  Copyright (c) 2012 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SASVideoEvent.h"


/**
 
 The delegate of a SASAdView object must adopt the SASAdViewDelegate protocol.
 
 Many methods of SASAdViewDelegate return the ad view sent by the message.
 The protocol methods allow the delegate to be aware of the ad-related events.
 You can use it to handle your app's or the ad's behavior like adapting your viewController's view size depending on the ad being displayed or not.
 
 */

@class SASAdView, SASAd, SASReward;

@protocol SASAdViewDelegate <NSObject>

@optional

///-----------------------------------
/// @name Methods
///-----------------------------------

/** Notifies the delegate that the ad json has been received and fetched and that it will launch its download.
 
 It lets you know what the ad data is so you can adapt your ad behavior. See the SASAd Class Reference for more information.
 
 @param adView The ad view corresponding the SASAd object.
 @param ad A SASAd object.
 
*/

- (void)adView:(nonnull SASAdView *)adView didDownloadAd:(nonnull SASAd *)ad;


/** Notifies the delegate that the creative from the current ad has been loaded and displayed.
 
 @param adView An ad view object informing the delegate about the creative being loaded.
 @warning This method is not only called the first time an ad creative is displayed, but also when the user rotates the device, and in a browsable HTML creative, when a new page is loaded.
 
 */

- (void)adViewDidLoad:(nonnull SASAdView *)adView;


/** Notifies the delegate that the SASAdView failed to download the ad.
 
 This can happen when the user's connection is interrupted before downloading the ad.
 In this case you might want to:
 
 - refresh the ad view: see [SASBannerView refresh]
 - dismiss the ad view: [SASAdView removeFromSuperview]
 
 @param adView An ad view object informing the delegate about the failure.
 @param error An error informing the delegate about the cause of the failure.
 
 */

- (void)adView:(nonnull SASAdView *)adView didFailToLoadWithError:(nonnull NSError *)error;


/** Notifies the delegate that the creative from the current ad has been prefetched in cache.
 
 @param adView An ad view object informing the delegate about the creative being prefetched.
 
 */

- (void)adViewDidPrefetch:(nonnull SASAdView *)adView;


/** Notifies the delegate that the SASAdView failed to prefetch the ad in cache.
 
 This can happen when the user's connection is interrupted before downloading the ad.
 In this case you might want to:
 
 - remove the ad view if it's unlimited: [SASAdView removeFromSuperview]
 
 @param adView An ad view object informing the delegate about the failure.
 @param error An error informing the delegate about the cause of the failure.
 
 */

- (void)adView:(nonnull SASAdView *)adView didFailToPrefetchWithError:(nonnull NSError *)error;


/** Notifies the delegate that the SASAdView which displayed an expandable ad did collapse.
 
 This can happen:
 
 - if the user tapped the toggle button to close the ad
 - after the ad's duration
 
 @param adView An ad view object informing the delegate that it did collapse.
 
 */

- (void)adViewDidCollapse:(nonnull SASAdView *)adView;


/** Notifies the delegate that the SASAdView has been dismissed.
 
 This can happen:
 
 - if the user taps the "Skip" button
 - if the ad's duration elapsed
 - if the ad has been clicked
 - if the ad creative decided to close itself
 - if your application decided to remove it by calling [SASInterstitialView removeFromSuperview]
 
 @param adView The ad view informing the delegate that it was dismissed.
 @warning You should not call the adView in this method, except if you want to release it (set your property and the ad's delegate to nil then).
 
 */

- (void)adViewDidDisappear:(nonnull SASAdView *)adView;


/** Notifies the delegate that a modal view will appear to display the ad's redirect URL web page if appropriate.
 This won't be called in case of URLs which should not be displayed in a browser like YouTube, iTunes,...
 In this case, it will call adView:shouldHandleURL:.
 
 @param adView The instance of SASAdView displaying the modal view.

 */

- (void)adViewWillPresentModalView:(nonnull SASAdView *)adView;


/** Notifies the delegate that the modal view will be dismissed.
 
 @param adView The instance of SASAdView closing the modal view.

 */

- (void)adViewWillDismissModalView:(nonnull SASAdView *)adView;


/** Notifies the delegate that an ad action has been made (for example the user tapped the ad).
 
 With this method you are informed of the user's action, and you can take appropriate decision (save state, launch your introduction video,...).
 
 @param adView An ad view object informing the delegate about the ad being clicked.
 @param willExit Whether the user chooses to leave the app.
 
 @warning *This method has been deprecated.*
 
 - if you want to know if the application is exiting, use UIApplicationDelegate methods instead.
 - if you want to know if an adview is tapped, implement the adView:shouldHandleURL: method
 
 */

- (void)adView:(nonnull SASAdView *)adView willPerformActionWithExit:(BOOL)willExit  __attribute__((availability(ios,
                                                                                                                 deprecated=6.2,
                                                                                                                 message="This method will be removed in future versions")));


/** Asks the delegate whether to execute the ad action.
 
 Implement this method if you want to process some URLs yourself.
 
 @param adView An ad view object informing the delegate about the ad responsible for the click.
 @param URL The URL that will be called.
 @return Whether the Smart AdServer SDK should handle the URL.
 @warning Returning NO means that the URL won't be processed by the SDK.
 @warning Please note that a click will be counted, even if you return NO (you are supposed to handle the URL in this case).
 
 */

- (BOOL)adView:(nonnull SASAdView *)adView shouldHandleURL:(nonnull NSURL *)URL;


/** Returns the animations used to dismiss the ad view.
 
 @param adView The ad view to be dismissed.
 @return The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
 
 */

- (NSTimeInterval)animationDurationForDismissingAdView:(nonnull SASAdView *)adView;


/** Returns the animations used to dismiss the ad view.
 
 @param adView The ad view to be dismissed.
 @return A mask of options indicating how you want to perform the animations. For a list of valid constants, see UIViewAnimationOptions.
 
 */

- (UIViewAnimationOptions)animationOptionsForDismissingAdView:(nonnull SASAdView *)adView;


// MRAID Delegate Methods

/** Notifies the delegate that the ad view is about to be resized.
 
 @param adView The ad view to be resized.
 @param frame The frame of the ad view before resizing it.
 @warning This method is not only called the first time an ad creative is resized, but also when the user rotates the device.
 
 */

- (void)adView:(nonnull SASAdView *)adView willResizeWithFrame:(CGRect)frame;


/** Notifies the delegate that the ad view was resized.
 
 @param adView The resized ad view.
 @param frame The frame of the ad view after resizing it.
 @warning This method is not only called the first time an ad creative is resized, but also when the user rotates the device.
 
 */

- (void)adView:(nonnull SASAdView *)adView didResizeWithFrame:(CGRect)frame;


/** Notifies the delegate that the ad view was resized.
 
 @param adView The ad view that failed to resize.
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. 
 You may specify nil for this parameter if you do not want the error information.
 
 */
- (void)adViewDidFailToResize:(nonnull SASAdView *)adView error:(nonnull NSError *)error;


/** Notifies the delegate that the resized ad was closed.
 
 @param adView The resized ad view that was closed.
 @param frame The frame of the ad view after closing it.
 
 */

- (void)adView:(nonnull SASAdView *)adView didCloseResizeWithFrame:(CGRect)frame;


/** Notifies the delegate that the ad view is about to be expanded.
 
 @param adView The ad view to be expanded.
 @warning This method is not only called the first time an ad creative is expanded, but also when the user rotates the device.
 
 */

- (void)adViewWillExpand:(nonnull SASAdView *)adView;


/** Notifies the delegate that the ad view was expanded.
 
 @param adView The expanded ad view.
 @param frame The frame of the ad view after expanding.
 @warning This method is not only called the first time an ad creative is expanded, but also when the user rotates the device.
 
 */

- (void)adView:(nonnull SASAdView *)adView didExpandWithFrame:(CGRect)frame;


/** Notifies the delegate that the expanded ad is about to be closed.
 
 @param adView The expanded ad view that is about to be closed.
 
 */

- (void)adViewWillCloseExpand:(nonnull SASAdView *)adView;


/** Notifies the delegate that the expanded ad was closed.
 
 @param adView The expanded ad view that was closed.
 @param frame The frame of the ad view after closing.
 
 */


- (void)adView:(nonnull SASAdView *)adView didCloseExpandWithFrame:(CGRect)frame;


/** Notifies the delegate that the ad view received a message from the MRAID creative.
 
 Creatives can send messages using mraid.sasSendMessage("message"). These messages are sent to the ad view delegate by the SDK.
 Please note that this method IS NOT PART of MRAID 2.0 specification.
 
 @param adView The receiver ad view.
 @param message The message sent by the creative.
 
 */

- (void)adView:(nonnull SASAdView *)adView didReceiveMessage:(nonnull NSString *)message;


/** Returns the visibility percentage of the ad view
 
 Implement this method if you want to override the banner visibility.
 
 @param adView The ad view object on which the visibility percentage will occur
 @return Visibility percentage value between 0 and 1.
 @warning Visibility is already computed by Smart AdServer SDK, override only if one case is not cover by this computation.
 @warning This method is called each 500ms by Smart AdServer SDK, do not perform heavy computation.
 
 */

- (CGFloat)visibilityPercentageForAdView:(nonnull SASAdView *)adView;


#pragma mark - Sticky Ads in ScrollViews

/** Notifies the delegate that the ad view stuck/unstuck one of its subview to the view hierarchy.
 
 This method will only be called when the SASAdView is added to a scrollview instance (UITableView, UICollectionView...) and only for ads format with the stickToTop feature.
 Implement this method if you want to be able to modify the frame of the sticked view, for example if your UINavigationBar disappears at some point of the scroll, etc...
 
 @param adView the sending adView.
 @param stickyView the view instance that is stuck/unstuck to the UIWindow
 @param stuck true if the view is stuck, false if the view is not stuck anymore
 @param stickyFrame the frame of the stickyView.
 @warning This method is not only called the first time an ad creative is expanded, but also when the user rotates the device.
 
 */

- (void)adView:(nonnull SASAdView *)adView withStickyView:(nonnull UIView *)stickyView didStick:(BOOL)stuck withFrame:(CGRect)stickyFrame;


/** Ask the delegate wether the adView can stick to top or not
 
 This method will be called when the SASAdView is binded to a scrollview instance (UITableView, UICollectionView...) and when stick to top conditions are met : ads format with this feature, scrollview offset reaching top of the screen, etc.
 Implement this method if you want to be able to prevent an ad from sticking to top : for example, if you store several adviews in the same controller and display only some of them, etc...
 
 @param adView the sending adView.
 @warning This method is not only called the first time stick to top conditions are met but every time until ad is stuck.
 
 */

- (BOOL)adViewCanStickToTop:(nonnull SASAdView *)adView;


#pragma mark - Native Audio Playback

/** Tells the ad view if it should handle AVAudioSession on its own when playing native (audio/video) ads.
 
 Implement this method and return NO if you want to override ad view's behavior with AVAudioSession.
 
 Use the adViewWillPlayAudio: and adViewDidFinishPlayingAudio: methods to implement your own behavior.
 
 @param adView The ad view object on which is going to interact with AVAudioSession.
 @return YES (default if not implemented) to let ad view handle AVAudioSession for native videos, NO to implement your own behavior.
 
 @warning Disabling AVAudioSession handling can prevent the SDK to change the volume for a creative or to display mute/unmute buttons on some formats.
 
 */

- (BOOL)adViewShouldHandleAudioSession:(nonnull SASAdView *)adView;


/** Notifies the delegate that the ad view will start playing native audio.
 
 Implement this method if you want to know when an ad view starts playing native audio (e.g. from a native video). 
 This is useful if you want to pause your own audio, change the shared AudioSession or trigger other custom behavior.
 
 @param adView The ad view object which is going to play audio.
 
 @warning This method will only be triggered by native creatives, not by HTML based creatives.
 
 */

- (void)adViewWillPlayAudio:(nonnull SASAdView *)adView;


/** Notifies the delegate that the ad view finished playing native audio.
 
 Implement this method if you want to know when an ad view finishes playing native audio (e.g. from a native video).
 This is useful if you want to resume your own audio, change the shared AudioSession or trigger other custom behavior.
 
 @param adView The ad view object which finished playing audio.
 
 @warning This method will only be triggered by native creatives, not by HTML based creatives.
 
 */

- (void)adViewDidFinishPlayingAudio:(nonnull SASAdView *)adView;


/** Notifies the delegate that a video event has been generated by the ad view.
 
 Implement this method if you want to know when some events are reached when a video is played.
 This can be useful if you want to implement specific app behavior when the user interact with the video or when he
 reach a certain point of the video (for instance, to implement a rewarded video scheme in a game, using the event
 SASVideoEventComplete).
 
 @param adView The ad view currently playing the video.
 @param videoEvent The video event.
 
 @warning This method will only be triggered by native creatives, not by HTML based creatives.
 
 */

- (void)adView:(nonnull SASAdView *)adView didSendVideoEvent:(SASVideoEvent)videoEvent;

#pragma mark - Rewarded Video

/** Notifies the delegate that the user should be rewarded for watching a video.
 
 Implement this method if you want to use the Rewarded Video feature.
 Check the properties of the SASReward object to design your response to this method.
 
 @param adView The ad view that collected the reward.
 @param reward The SASReward object collected. See its documentation to know the available properties.
 
 */

- (void)adView:(nonnull SASAdView *)adView didCollectReward:(nonnull SASReward *)reward;


/** Notifies the delegate that the ad view will start playing native video.
 
 Implement this method if you want to know when an ad view starts playing native video (e.g. from a native video).
 This is useful if you want to track on your side the AVPlayer behaviour.
 
 @param adView The SASAdView instance which is going to play the video.
 @param player The AVPlayer instance responsible for playing the video.
 @param playerLayer A CALayer inheriting instance. AVPlayerLayer class for standard native videos. CALayer class for 360° native videos.
 @param containingView The UIView which is going to contain the video layer.
 
 @warning Interacting with the AVPlayer instance can lead to unexpected behaviour. This method will only be triggered by native video creatives, not by HTML based creatives.
 
 */

- (void)adView:(nonnull SASAdView *)adView willPlayVideoWithAVPlayer:(nonnull AVPlayer *)player withPlayerLayer:(nonnull CALayer *)playerLayer withContainingView:(nonnull UIView *)containingView;


/** Notifies the delegate that the layer rendering the current native video ad did change to a new CALayer instance and/or a new container view.
 
 This method will be called for Video-Read ads when they enter fullscreen.
 
 Implement this method if you want to know when a playing native video ad changes its rendering layer or its hierarchical parent.
 This is useful if you want to track the viewability of the video ad.
 
 @param adView The SASAdView instance which is going to play the video.
 @param player The AVPlayer instance responsible for playing the video.
 @param playerLayer A CALayer inheriting instance where the video is rendered. AVPlayerLayer class for standard native videos. CALayer class for 360° native videos.
 @param containingView The UIView which is going to contain the video layer.
 
 @warning Interacting with the AVPlayer instance can lead to unexpected behaviour. This method will only be triggered by native video creatives, not by HTML based creatives.
 
 */

- (void)adView:(nonnull SASAdView *)adView withAVPlayer:(nonnull AVPlayer *)player didSwitchToPlayerLayer:(nonnull CALayer *)playerLayer withContainingView:(nonnull UIView *)containingView;


/** Notifies the delegate that the end card creative from the current video ad has been loaded and displayed.
 
 @param adView An ad view object informing the delegate about the end card creative being loaded.
 
 */

- (void)adViewDidLoadEndCard:(nonnull SASAdView *)adView;

@end
