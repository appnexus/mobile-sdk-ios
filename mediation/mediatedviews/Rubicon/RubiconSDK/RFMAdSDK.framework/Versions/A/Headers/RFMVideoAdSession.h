//
//  RFMVideoAdSession.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 2/28/17.
//  Copyright © 2017 Rubicon Project. All rights reserved.
//

#import "RFMAdSession.h"

extern void * const RFMCurrentProgressKVOContext;

@class RFMVideoAdSession;
@protocol RFMPlayerControl;

/**
 * Protocol defines methods to help the session coordinate between informing
 * the delegate of video events and managing the video player through the player adapter.
 */
@protocol RFMVideoAdSessionDelegate <RFMAdSessionDelegate>

@required
/**
 * Required method allows access to the player observer.
 * @return An instance that conforms to the RFMVideoPlayerProgressObserver protocol
 */
- (id <RFMVideoPlayerProgressObserver>)playerObserver;

@optional
/**
 * Optional method allows access to the player adapter.
 * @return Instance that conforms to the RFMPlayerControl protocol
 */
- (id <RFMPlayerControl>)playerAdapter;

/**
 * Optional method informs the delegate when a video event has occurred
 * @param videoEvent RFMVideoAdEvent enum that was triggered
 * @param ad Opaque type that adopts the RFMVideoAd protocol
 * @see didFailToPlayVideoAd:
 */
- (void)didReceiveVideoAdEvent:(RFMVideoAdEvent)videoEvent ad:(id <RFMVideoAd>)ad;

/**
 * Optional method informs the delegate when an error has occurred during video ad playback.
 * @param ad paque type that adopts the RFMVideoAd protocol
 * @see didReceiveVideoAdEvent:ad:
 */
- (void)didFailToPlayVideoAd:(id <RFMVideoAd>)ad;

/**
 * Optional method makes a request to the delegate for permission
 * to pause video content playback, i.e. when a cue point has been hit and
 * the video ad is ready for playback
 * @return BOOL flag to allow for video ad playback to begin,
 * YES means video ad playback will commence
 * @see didRequestContentResume
 */
- (BOOL)didRequestContentPause;

/**
 * Optional method informs the delegate that video ad playback is over
 * and video content must be resumed.
 */
- (void)didRequestContentResume;

/**
 * Optional method informs the delegate when the session no longer has any
 * video ads remaining in the queue or has run out of runnable cue points.
 * @param session RFMVideoAdSession instance
 */
- (void)sessionDidFinish:(RFMVideoAdSession*)session;

@end

/**
 * This class manages video playback session state and serves as a container to store
 * opaque video ad instances.  In addition, it exposes methods to start the session,
 * pause video ad playback, resume video ad playback, and skip video ad playback.
 */
@interface RFMVideoAdSession : RFMAdSession

@property (nonatomic, strong, readonly) id <RFMVideoAd> currentAd;

/**
 * Content mode, YES value indicates video content playback, NO value indicates video ad playback.
 */
@property (nonatomic, assign, getter=isContentMode, setter=setContentMode:) BOOL contentMode;


/**
 * Delegate that adopts the RFMVideoAdSessionDelegate protocol.
 * @return Instance that conforms to the RFMVideoAdSessionDelegate protocol
 */
- (id <RFMVideoAdSessionDelegate>)delegate;

/**
 * Sets and stores cue points into the video session.
 * @param cuePoints Set that contains all the requested cue points
 */
- (void)setCuePoints:(NSSet <NSValue*>*)cuePoints;

/**
 * Starts the video session.
 * @return BOOL flag return status, YES indicates the session was successfully started
 */
- (BOOL)start;

/**
 * If a video ad is playing, this method will pause video playback of the ad.
 * @see resumeAd
 */
- (void)pauseAd;

/**
 * If a video ad is paused, this method will resume video playback of the ad.
 * @see pauseAd
 */
- (void)resumeAd;

/**
 * If the session is not in content mode, skips the current video ad.
 */
- (void)skipAd;

/**
 * Sets the playerView, for the purposes of video ad extended UI functionality (skip overlay).*
 * @param playerView Instance of UIView that frames the video player
 */
- (void)setPlayerView:(UIView*)playerView;

@end
