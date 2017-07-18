//
//  RFMAdProtocols.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 2/28/17.
//  Copyright © 2017 Rubicon Project. All rights reserved.
//

#ifndef RFMAdProtocols_h
#define RFMAdProtocols_h

/**
 * Cue point position enum type.
 *
 */
typedef NS_ENUM(NSUInteger, RFMCuePointPosition) {
    /** Undefined position, this is the default */
    RFMCuePointPositionUndefined = 0,
    /** Preroll position, only one allowed */
    RFMCuePointPositionPreRoll = 1,
    /** Midroll position */
    RFMCuePointPositionMidRoll = 2,
    /** Postroll position, only one allowed */
    RFMCuePointPositionPostRoll = 3
};

/**
 * Ad status enum type.
 */
typedef NS_ENUM(NSUInteger, RFMAdStatus) {
    /** Initial status */
    RFMAdStatusInitial = 0,
    /** Error status, there is a problem with the ad */
    RFMAdStatusError = 1,
    /** Expired status, currently this is not used, placeholder for future */
    RFMAdStatusExpired = 2,
    /** Cached status, ad has been cached onto the local disk  */
    RFMAdStatusCached = 3,
    /** Loaded status, ad has been successfully loaded */
    RFMAdStatusLoaded = 4,
    /** Ready status, ad is ready for display */
    RFMAdStatusReady = 5,
    /** Finished status, ad has been displayed or skipped */
    RFMAdStatusFinished = 6,
    /** Invalidated status, currently this is not used, placeholder for future */
    RFMAdStatusInvalidated = 7
};

/**
 * Video Ad events enum type.
 */
typedef NS_ENUM(NSUInteger, RFMVideoAdEvent) {
    /** Load event, video has been loaded */
    RFMVideoAdEventLoad = 0,
    /** Start event, video playback has started */
    RFMVideoAdEventStart = 1,
    /** First quartile event, video playback has reached 25% */
    RFMVideoAdEventFirstQuartile = 2,
    /** Mid point event, video playback has 50% */
    RFMVideoAdEventMidPoint = 3,
    /** Third quartile event, video playback has reached 75% */
    RFMVideoAdEventThirdQuartile = 4,
    /** Complete event, video playback has completed */
    RFMVideoAdEventComplete = 5,
    /** Tap event, currently this is not used, placeholder for future */
    RFMVideoAdEventTap = 6,
    /** Skip event, video playback was not played to completion */
    RFMVideoAdEventSkip = 7,
    /** Pause event, video playback was paused */
    RFMVideoAdEventPause = 8,
    /** Resume event, video playback was resumed */
    RFMVideoAdEventResume = 9,
    /** Close event, currently this is not used, placeholder for future */
    RFMVideoAdEventClose = 10
};

/**
 * Cue point structure.
 */
typedef struct RFMCuePoint {
    /** Cue point position, can be pre mid or post */
    RFMCuePointPosition position;
    /** Value of ad start point based on a percentage value, 0-100 */
    NSUInteger start;
} RFMCuePoint;

/** Convenience function that makes RFMCuePoint structs */
RFMCuePoint RFMCuePointMake(RFMCuePointPosition position, NSUInteger start);

/** convenience method to compare cue points */
bool RFMCuePointEqualsCuePoint(RFMCuePoint cuePoint1, RFMCuePoint cuePoint2);

extern const RFMCuePoint RFMCuePointPreRoll;
extern const RFMCuePoint RFMCuePointPostRoll;

/**
 * Ad protocol that defines methods related to ad status and cache invalidation.
 */
@protocol RFMAd <NSObject>
@required
/**
 * Method that returns the status of the ad instance
 * @return RFMAdStatus enum value for status
 * @see RFMAdStatus
 */
- (RFMAdStatus)status;

/**
 * Invalidate ad instance, currently not implemented, future placeholder.
 */
- (void)invalidate;
@end

/**
 * Video ad protocol for accessing the cue point and manual impression tracking.
 * Inherits from RFMAd protocol.
 */
@protocol RFMVideoAd <RFMAd>
@required
/**
 * Returns the video ad cue point.
 * @return cuePoint RFMCuePoint struct
 */
- (RFMCuePoint)cuePoint;

/**
 * Allows for the manual impression tracking of a video ad.
 * @param videoEvent RFMVideoAdEvent enum value
 * @see RFMVideoAdEvent
 */
- (void)trackImpressionForVideoAdEvent:(RFMVideoAdEvent)videoEvent;
@end

#endif /* RFMAdProtocols_h */
