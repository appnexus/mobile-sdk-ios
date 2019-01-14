//
//  SASVideoEvent.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 08/09/2016.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/// List of all valid video events that can be emitted by a video ad player.
typedef NS_ENUM(NSInteger, SASVideoEvent) {
    
    /// Undefined video event.
    SASVideoEventUndefined,
    
    /// The video has started.
    SASVideoEventStart,
    
    /// The video has been paused.
    SASVideoEventPause,
    
    /// The video has been resumed.
    SASVideoEventResume,
    
    /// The video will play again from the start.
    SASVideoEventRewind,
    
    /// The video has reached 25% of its total duration.
    SASVideoEventFirstQuartile,
    
    /// The video has reached 50% of its total duration.
    SASVideoEventMidpoint,
    
    /// The video has reached 75% of its total duration.
    SASVideoEventThirdQuartile,
    
    /// The video has been played completely.
    SASVideoEventComplete,
    
    /// The video has been skipped.
    SASVideoEventSkip,
    
    /// The video is now playing in fullscreen.
    SASVideoEventEnterFullscreen,
    
    /// The video is not playing in fullscreen anymore.
    SASVideoEventExitFullscreen
    
};

NS_ASSUME_NONNULL_END
