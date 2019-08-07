//
//  SCSTimerInterval.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 20/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Specifiy the type of interval for a timer.
typedef NS_ENUM(NSUInteger, SCSTimerIntervalType) {
    /// The timer will fire only once.
    SCSTimerIntervalTypeNonRepeating,
    
    /// The timer will fire a finite number of times then stop.
    SCSTimerIntervalTypeFiniteRepetitions,
    
    /// The timer will fire until it is manually stopped.
    SCSTimerIntervalTypeInfiniteRepetitions,
};

/**
 Specify the time interval between each timer firing as well as the repetition pattern.
 */
@interface SCSTimerInterval : NSObject

/// The type of interval for the timer.
@property (nonatomic, readonly) SCSTimerIntervalType type;

/// The time interval before the timer fires.
@property (nonatomic, readonly) NSTimeInterval time;

/// The number of repetitions if the timer is of type SCSTimerIntervalTypeFiniteRepetitions, 0 otherwise.
@property (nonatomic, readonly) unsigned int count;

- (instancetype)init NS_UNAVAILABLE;

/**
 Instantiate a non repeating time interval.
 
 @param time The time interval before the timer fires.
 @return An initialized instance.
 */
+ (instancetype)nonRepeatingWithTime:(NSTimeInterval)time;

/**
 Instantiate a time interval with a finite number of repetitions.
 
 @param time The time interval between each timer firing.
 @param count The number of repetitions.
 @return An initialized instance.
 */
+ (instancetype)finiteRepetitionsWithTime:(NSTimeInterval)time count:(unsigned int)count;

/**
 Instantiate a time interval with an infinite number of repetitions.
 
 @param time The time interval between each timer firing.
 @return An initialized instance.
 */
+ (instancetype)infiniteRepetitionsWithTime:(NSTimeInterval)time;

@end

NS_ASSUME_NONNULL_END
