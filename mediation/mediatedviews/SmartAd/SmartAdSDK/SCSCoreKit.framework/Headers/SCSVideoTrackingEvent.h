//
//  SCSVideoTrackingEvent.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 17/05/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSTrackingEvent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a generic video tracking event.
 */
@protocol SCSVideoTrackingEvent <NSObject, SCSTrackingEvent>

@required

/**
 Returns the offset of the event.
 
 The offset of a video event describes when the event must be called during the playback
 of a video. It is always relative to the currently played video.
 
 @return The offset of the event.
 */
- (NSTimeInterval)eventOffset;

@end

/// Generic type of video event.
typedef NS_ENUM(NSUInteger, SCSVideoTrackingEventType) {
    /// Click event.
    SCSVideoTrackingEventTypeClick,
    
    /// CreativeView event. Only for non linear creatives.
    SCSVideoTrackingEventTypeCreativeView,
    
    /// Start event.
    SCSVideoTrackingEventTypeStart,
    
    /// FirstQuartile event.
    SCSVideoTrackingEventTypeFirstQuartile,
    
    /// Midpoint event.
    SCSVideoTrackingEventTypeMidpoint,
    
    /// ThirdQuartile event.
    SCSVideoTrackingEventTypeThirdQuartile,
    
    /// Complete event.
    SCSVideoTrackingEventTypeComplete,
    
    /// Mute event.
    SCSVideoTrackingEventTypeMute,
    
    /// Unmute event.
    SCSVideoTrackingEventTypeUnmute,
    
    /// Pause event.
    SCSVideoTrackingEventTypePause,
    
    /// Rewind event.
    SCSVideoTrackingEventTypeRewind,
    
    /// Resume event.
    SCSVideoTrackingEventTypeResume,
    
    /// Fullscreen event.
    SCSVideoTrackingEventTypeFullscreen,
    
    /// ExitFullscreen event.
    SCSVideoTrackingEventTypeExitFullscreen,
    
    /// Progress event.
    SCSVideoTrackingEventTypeProgress,
    
    /// TimeToClick event.
    SCSVideoTrackingEventTypeTimeToClick,
    
    /// Skip event.
    SCSVideoTrackingEventTypeSkip,
    
    /// AdInteraction event.
    SCSVideoTrackingEventTypeAdInteraction,
    
    /// FirstSecond event.
    SCSVideoTrackingEventTypeFirstSecond,
};

NS_ASSUME_NONNULL_END
