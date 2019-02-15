//
//  SCSVASTTrackingEventFactory.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 18/05/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSTrackingEventFactory.h"

NS_ASSUME_NONNULL_BEGIN

@class SCSVASTTrackingEvent;

/**
 Implementation of SCSTrackingEventFactory for SCSVASTTracking events.
 */
@interface SCSVASTTrackingEventFactory : NSObject <SCSTrackingEventFactory>

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize a new instance of SCSVASTTrackingEventFactory for a set of VAST tracking events and a total content time.
 
 @param vastEvents An array of valid SCSVASTTrackingEvent instances.
 @param contentTotalTime The total time of the content video related to the events.
 @return An initialized instance of SCSVASTTrackingEventFactory.
 */
- (instancetype)initWithVASTTrackingEvents:(NSArray<SCSVASTTrackingEvent *> *)vastEvents contentTotalTime:(NSTimeInterval)contentTotalTime;

@end

NS_ASSUME_NONNULL_END
