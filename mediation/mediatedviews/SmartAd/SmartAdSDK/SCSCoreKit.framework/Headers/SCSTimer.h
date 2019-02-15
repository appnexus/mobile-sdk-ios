//
//  SCSTimer.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 20/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import "SCSTimerInterval.h"
#import "SCSTimerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/// Describe the status of the timer.
typedef NS_ENUM(NSUInteger, SCSTimerStatus) {
    /// The timer has never been started.
    SCSTimerStatusNotStarted,
    
    /// The timer is currently running.
    SCSTimerStatusRunning,
    
    /// The timer has finished its task (for nonRepeating and finiteRepetitions timers only).
    SCSTimerStatusDone,
    
    /// The timer has been stopped manually.
    SCSTimerStatusStopped,
};

/**
 Class allowing the user to manipulate a timer without any risk of causing a retain cycle.
 
 This class wraps the native Timer class and add a new way to specifiy time intervals (allowing
 finite & infinite repetitions). It should be used in replacement of Timer in all Smart AdServer
 frameworks.
 
 When the timer is firing, a delegate method is called, instead of the traditional target/selector
 design pattern used by the native Timer. See SCSTimerDelegate.
 
 _Note: the purpose of SCSTimer is to avoid any strong retain on the timer target or on itself.
 If the target or the SCSTimer instance is not retained, the timer will automatically stops. You
 must always store the timer instance in a long lived reference in order to use a SCSTimer!_
 */
@interface SCSTimer : NSObject

/// The ID of the timer (can be used to identify the current instance).
@property (nonatomic, readonly) unsigned int ID;

/// The timer interval.
@property (nonatomic, readonly) SCSTimerInterval *interval;

/// The current status of the timer.
@property (nonatomic, readonly) SCSTimerStatus status;

/// The current delegate of the timer.
@property (nonatomic, weak, nullable) id<SCSTimerDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize a new SCSTimer instance.
 
 @param interval A timer interval.
 @return An initialized instance.
 */
- (instancetype)initWithInterval:(SCSTimerInterval *)interval;

/**
 Initialize a new SCSTimer instance.
 
 @param interval A timer interval.
 @param delegate A delegate called when the timer is fired.
 @return An initialized instance.
 */
- (instancetype)initWithInterval:(SCSTimerInterval *)interval delegate:(nullable id<SCSTimerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/**
 Starts the timer if it is not already started (does nothing otherwise).
 */
- (void)start;

/**
 Stops the timer.
 */
- (void)stop;

// For unit testing only!
@property (nonatomic, copy, nullable) void (^stopHandler)(SCSTimer *);

@end

NS_ASSUME_NONNULL_END
