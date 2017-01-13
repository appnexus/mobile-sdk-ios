//
//  SASVideoEvent.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 08/09/2016.
//
//

typedef NS_ENUM(NSInteger, SASVideoEvent) {
    SASVideoEventUndefined,
    SASVideoEventStart,
    SASVideoEventPause,
    SASVideoEventResume,
    SASVideoEventRewind,
    SASVideoEventFirstQuartile,
    SASVideoEventMidpoint,
    SASVideoEventThirdQuartile,
    SASVideoEventComplete,
    SASVideoEventSkip,
    SASVideoEventEnterFullscreen,
    SASVideoEventExitFullscreen
};
