//
//  OMIDVideoEvents.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 30/06/2017.
//

#import <Foundation/Foundation.h>
#import "OMIDAdSession.h"
#import "OMIDVASTProperties.h"

/*!
 * @abstract List of supported video event player states.
 */
typedef NS_ENUM(NSUInteger, OMIDPlayerState) {
    OMIDPlayerStateMinimized,
    OMIDPlayerStateCollapsed,
    OMIDPlayerStateNormal,
    OMIDPlayerStateExpanded,
    OMIDPlayerStateFullscreen
};

/*!
 * @abstract List of supported video event user interaction types.
 */
typedef NS_ENUM(NSUInteger, OMIDInteractionType) {
    OMIDInteractionTypeClick,
    OMIDInteractionTypeAcceptInvitation
};

/*!
 * @discussion This provides a complete list of native video events supported by OMID.
 * Using this event API assumes the video player is fully responsible for communicating all video events at the appropriate times.
 * Only one video events implementation can be associated with the ad session and any attempt to create multiple instances will result in an error.
 */
@interface OMIDAppnexusVideoEvents : NSObject

/*!
 * @abstract Initializes video events instance for the associated ad session.
 * @discussion Any attempt to create a video events instance will fail if the supplied ad session has already started.
 *
 * @param session The ad session associated with the ad events.
 * @return A new video events instance. Returns nil if the supplied ad session is nil or if a video events instance has already been registered with the ad session or if a video events instance has been created after the ad session has started.
 * @see OMIDAdSession
 */
- (nullable instancetype)initWithAdSession:(nonnull OMIDAppnexusAdSession *)session error:(NSError *_Nullable *_Nullable)error;

/*!
 * @abstract Notifies all video listeners that video content has been loaded and ready to start playing.
 *
 * @param vastProperties The parameters containing static information about the video placement.
 * @see OMIDVASTProperties
 */
- (void)loadedWithVastProperties:(nonnull OMIDAppnexusVASTProperties *)vastProperties;

/*!
 * @abstract Notifies all video listeners that video content has started playing.
 *
 * @param duration The duration of the selected video media (in seconds).
 * @param videoPlayerVolume The volume from the native video player with a range between 0 and 1.
 */
- (void)startWithDuration:(CGFloat)duration
        videoPlayerVolume:(CGFloat)videoPlayerVolume;

/*!
 * @abstract Notifies all video listeners that video playback has reached the first quartile.
 */
- (void)firstQuartile;

/*!
 * @abstract Notifies all video listeners that video playback has reached the midpoint.
 */
- (void)midpoint;

/*!
 * @abstract Notifies all video listeners that video playback has reached the third quartile.
 */
- (void)thirdQuartile;

/*!
 * @abstract Notifies all video listeners that video playback is complete.
 */
- (void)complete;

/*!
 * @abstract Notifies all video listeners that video playback has paused after a user interaction.
 */
- (void)pause;

/*!
 * @abstract Notifies all video listeners that video playback has resumed (after being paused) after a user interaction.
 */
- (void)resume;

/*!
 * @abstract Notifies all video listeners that video playback has stopped as a user skip interaction.
 * @discussion Once skipped video it should not be possible for the video to resume playing content.
 */
- (void)skipped;

/*!
 * @abstract Notifies all video listeners that video playback has stopped and started buffering.
 */
- (void)bufferStart;

/*!
 * @abstract Notifies all video listeners that buffering has finished and video playback has resumed.
 */
- (void)bufferFinish;

/*!
 * @abstract Notifies all video listeners that the video player volume has changed.
 *
 * @param playerVolume The volume from the native video player with a range between 0 and 1.
 */
- (void)volumeChangeTo:(CGFloat)playerVolume;

/*!
 * @abstract Notifies all video listeners that video player state has changed. See {@link OMIDPlayerState} for list of supported states.
 *
 * @param playerState The latest video player state.
 * @see OMIDPlayerState
 */
- (void)playerStateChangeTo:(OMIDPlayerState)playerState;

/*!
 * @abstract Notifies all video listeners that the user has performed an ad interaction. See {@link OMIDInteractionType} fro list of supported types.
 *
 * @param interactionType The latest user integration.
 * @see OMIDInteractionType
 */
- (void)adUserInteractionWithType:(OMIDInteractionType)interactionType
NS_SWIFT_NAME(adUserInteraction(withType:));

@end
