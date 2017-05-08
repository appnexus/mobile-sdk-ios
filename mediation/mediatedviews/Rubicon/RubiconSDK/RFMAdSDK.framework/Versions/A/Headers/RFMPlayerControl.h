//
//  RFMPlayerControl.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 3/16/17.
//  Copyright © 2017 Rubicon Project. All rights reserved.
//

#ifndef RFMPlayerControl_h
#define RFMPlayerControl_h

/**
 * This protocol defines the methods that control the playback of video.
 * The video ad session utilizes this protocol to initiate ad playback,
 * resume content, get duration, and to check for playback errors.
 */
@protocol RFMPlayerControl <NSObject>

@required
/**
 * Required method to begin playback of the video ad.
 * @param url NSURL that references the video ad source
 */
- (void)playVideoAdAtURL:(NSURL*)url;

/**
 * If an ad is playing, this method pauses video ad playback.
 * This method is required.
 * @see resumeAdPlayback
 */
- (void)pauseAdPlayback;

/**
 * If an ad is paused, this method resumes video ad playback.
 * This method is required.
 * @see pauseAdPlayback
 */
- (void)resumeAdPlayback;

/**
 * Required method to resume the playback of the original video content.
 */
- (void)resumeContentPlayback;

/**
 * Required method for the retrieval of total duration (current video item).
 * @returns NSTImeInterval value (seconds)
 */
- (NSTimeInterval)totalDuration;

/**
 * Required method that checks whether a video item is, currently, in playback
 * @return BOOL Video ad playback flag, YES means that the player is currently playing a video item
 * @see isStopped
 */
- (BOOL)isPlaying;

/**
 * Required method that checks if the video playback has stopped
 * @return BOOL Video ad playback flag, YES means that the player has stopped playback
 * * @see isPlaying
 */
- (BOOL)isStopped;

/**
 * Required method that checks the error status of the player
 * @return NSError instance which represents the error, nil means there, currently, is no error
 */
- (NSError*)error;

@end


#endif /* RFMPlayerControl_h */
