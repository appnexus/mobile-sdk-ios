//
//  SASNativeAdMediaViewDelegate.h
//  SmartAdServer
//
//  Created by Thomas Geley on 20/07/2016.
//
//

#import "SASVideoEvent.h"

/**
 
 The delegate of a SASNativeAdMediaView object must adopt the SASNativeAdMediaViewDelegate protocol.
 
 Many methods of SASNativeAdMediaViewDelegate pass the SASNativeAdMediaView sending by the message.
 Most of the medias displayed in SASNativeAdMediaView will be video media.
 The protocol methods allow the delegate to be aware of the media related events such as modal presentation wehn entering fullscreen or audio changes.
 You can use it to handle your app's or the native ad's behavior.
 
 NB: these events are only media related. For example a click, which is related to the SASNativeAd binded to the SASNativeAdMediaView will not trigger any methods of the SASNativeAdMediaViewDelegate protocol.
 
 */

@class SASNativeAdMediaView;

@protocol SASNativeAdMediaViewDelegate <NSObject>

@optional

/** Notifies the delegate that the SASNativeAdMediaView failed to load its media.
 
 This can happen when the user's connection is interrupted before downloading the media.
 In this case you might want to:
 
 - refresh the ad view
 - dismiss the ad view
 - or just remove the media view from the view hierarchy and switch to another native ad UI.
 
 @param mediaView The SASNativeAdMediaView object informing the delegate about the failure.
 @param error An error informing the delegate about the cause of the failure.
 
 */

- (void)nativeAdMediaView:(nonnull SASNativeAdMediaView *)mediaView didFailToLoadMediaWithError:(nullable NSError *)error;


/** Notifies the delegate that the media from the current SASNativeAd has been loaded and displayed into the SASNativeAdMediaView.
 
 @param mediaView The SASNativeAdMediaView object informing the delegate about the creative being loaded.
 
 */

- (void)nativeAdMediaViewDidLoadMedia:(nonnull SASNativeAdMediaView *)mediaView;


/** Notifies the delegate that a modal view will be presented to display the media in fullscreen.
 
 @param mediaView The SASNativeAdMediaView object informing the delegate about the upcoming modal presentation.
 
 */

- (void)nativeAdMediaViewWillPresentFullscreenModalMedia:(nonnull SASNativeAdMediaView *)mediaView;


/** Notifies the delegate that a modal view has been presented to display the media in fullscreen.
 
 @param mediaView The SASNativeAdMediaView object informing the delegate about the finished modal presentation.
 
 */

- (void)nativeAdMediaViewDidPresentFullscreenModalMedia:(nonnull SASNativeAdMediaView *)mediaView;


/** Notifies the delegate that a modal view displaying the media in fullscreen is about to dismiss.
 
 @param mediaView The SASNativeAdMediaView object informing the delegate about the upcoming modal dismissal.
 
 */

- (void)nativeAdMediaViewWillCloseFullscreenModalMedia:(nonnull SASNativeAdMediaView *)mediaView;


/** Notifies the delegate that a modal view displaying the media in fullscreen has been dismissed.
 
 @param mediaView The SASNativeAdMediaView object informing the delegate about the finished modal dismissal.
 
 */

- (void)nativeAdMediaViewDidCloseFullscreenModalMedia:(nonnull SASNativeAdMediaView *)mediaView;


#pragma mark - Native Audio Playback

/** Tells the MediaView if it should handle AVAudioSession on its own when playing native (audio/video) ads.
 
 Implement this method and return NO if you want to override MediaView's behavior with AVAudioSession.
 
 Use the nativeAdMediaViewWillPlayAudio: and nativeAdMediaViewDidFinishPlayingAudio: methods to implement your own behavior.
 
 @param mediaView The SASNativeAdMediaView object which is going to interact with AVAudioSession.
 @return YES (default if not implemented) to let the MediaView handle AVAudioSession for native videos, NO to implement your own behavior.
 
 @warning Disabling AVAudioSession handling can prevent the SDK to change the volume for a creative or to display mute/unmute buttons on some formats.
 
 */

- (BOOL)nativeAdMediaViewShouldHandleAudioSession:(nonnull SASNativeAdMediaView *)mediaView;


/** Notifies the delegate that the MediaView will start playing native audio.
 
 Implement this method if you want to know when a MediaView starts playing native audio (e.g. from a native video).
 This is useful if you want to pause your own audio, change the shared AudioSession or trigger other custom behavior.
 
 @param mediaView The SASNativeAdMediaView object which is going to play audio.
 
 */

- (void)nativeAdMediaViewWillPlayAudio:(nonnull SASNativeAdMediaView *)mediaView;


/** Notifies the delegate that the SASNativeAdMediaView finished playing native audio.
 
 Implement this method if you want to know when a MediaView finishes playing native audio.
 This is useful if you want to resume your own audio, change the shared AudioSession or trigger other custom behavior.
 
 @param mediaView The SASNativeAdMediaView object which finished playing audio.
 
 */

- (void)nativeAdMediaViewDidFinishPlayingAudio:(nonnull SASNativeAdMediaView *)mediaView;

#pragma mark - Native video playback

/** Notifies the delegate that the SASNativeAdMediaView has generated a video event.
 
 Implement this method if you want to know when some events are reached when a video is played.
 This can be useful if you want to implement specific app behavior when the user interact with the video or when he
 reach a certain point of the video (for instance, to implement a rewarded video scheme in a game, using the event
 SASVideoEventComplete).
 
 @param mediaView The SASNativeAdMediaView object currently playing the video.
 @param videoEvent The video event.
 
 @warning This method will only be triggered by native creatives, not by HTML based creatives.
 
 */

- (void)nativeAdMediaView:(nonnull SASNativeAdMediaView *)mediaView didSendVideoEvent:(SASVideoEvent)videoEvent;

@end
