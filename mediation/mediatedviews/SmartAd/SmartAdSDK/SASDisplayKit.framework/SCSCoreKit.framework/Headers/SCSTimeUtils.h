//
//  SCSTimeUtils.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 21/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A time exploded into hours / minutes / seconds integers.
typedef struct SCSTimeUtilsExplodedTime {
    
    /// The hours part of the time.
    NSInteger hours;
    
    /// The minutes part of the time.
    NSInteger minutes;
    
    /// The seconds part of the time.
    NSInteger seconds;
    
} SCSTimeUtilsExplodedTime;

/// The type of offset time interval.
typedef NS_ENUM(NSUInteger, SCSTimeUtilsOffsetType) {
    /// The offset is expressed as a text duration string ('HH:MM:SS.mmm').
    SCSTimeUtilsOffsetTypeTextDuration,
    
    /// The offset is expressed as a percentage string ('XX%').
    SCSTimeUtilsOffsetTypePercentage,
    
    /// The offset is invalid.
    SCSTimeUtilsOffsetTypeInvalid,
};

/**
 Utils methods to handle times and durations.
 */
@interface SCSTimeUtils : NSObject

/**
 Explodes a duration in seconds into a struct with hours, minutes, seconds components.
 
 @param seconds The duration to be exploded.
 @return A struct with hours, minutes, seconds components as integers.
 */
+ (SCSTimeUtilsExplodedTime)secondsToHoursMinutesSeconds:(NSInteger)seconds;

/**
 Transforms a duration in seconds into a string with the pattern HH:MM:SS. HH is optional if duration is too short.
 
 @param duration The duration to be transformed.
 @return An human readable string representing the duration with the pattern HH:MM:SS. HH is optional is duration is < to 3600s.
 */
+ (nullable NSString *)stringFromDuration:(NSInteger)duration;

/**
 Transforms a duration in seconds into a string. The number of digits can be specified. Missing digits will be replaced by leading zeros.
 
 @param duration The duration to be transformed.
 @param numberOfDigits The number of digits expected in the returned string.
 @return A string representing the duration.
 */
+ (nullable NSString *)stringFromDuration:(NSInteger)duration withNumberOfDigits:(NSInteger)numberOfDigits;

/**
 Extracts the time from a date object and convert it to a string with hh:mm:ss format with a default NSCalendar.
 
 @param date The date from where the time should be extracted.
 @return A string containing a well formatted time or nil if the time cannot be retrieved.
 */
+ (nullable NSString *)timeFromDate:(NSDate *)date;

/**
 Extracts the time from a date object and convert it to a string with hh:mm:ss format.
 
 @param date The date from where the time should be extracted.
 @param calendar A custom calendar used to transform the time with a given timezone or locale.
 @return A string containing a well formatted time or nil if the time cannot be retrieved.
 */
+ (nullable NSString *)timeFromDate:(NSDate *)date calendar:(NSCalendar *)calendar;

/**
 Converts a VAST duration into a Cocoa TimeInterval if possible.
 
 The VAST duration string is considered as valid if it's formated like:
 
 - HH:MM:SS.mmm
 - HH:MM:SS
 - MM:SS.mmm
 - MM:SS
 - SS.mmm
 - SS
 
 @param duration A properly formated duration string (see method description).
 @return A TimeInterval corresponding to the duration if possible, -1.0 otherwise.
 */
+ (NSTimeInterval)timeIntervalFromVASTDuration:(NSString *)duration;

/**
 Convert a percent VAST duration string into percentage if possible.
 
 @param duration A valid percent VAST duration string.
 @return The percentage (between 0 and 100) corresponding to the percent VAST duration if possible, -1 otherwise.
 */
+ (double)percentageFromPercentVASTDuration:(NSString *)duration;

/**
 Convert a percent VAST duration string into a time interval if possible.
 
 @param duration A valid percent VAST duration string.
 @param totalTime The total time of the current content video.
 @return The time interval corresponding the to percent VAST duration and the current content video if possible, -1 otherwise.
 */
+ (NSTimeInterval)timeIntervalFromPercentVASTDuration:(NSString *)duration withTotalTime:(NSTimeInterval)totalTime;

/**
 Retrieve a time inverval from a total time and a percentage of this total time.
 
 @param percent The percentage of the total time (must be a number between 0 and 100).
 @param totalTime The total time (must be a number greater than 0).
 @return The time interval corresponding to 'percent%' of the total time or -1 if the time interval can be retrieved (because of invalid parameters).
 */
+ (NSTimeInterval)timeIntervalFromPercentage:(double)percent withTotalTime:(NSTimeInterval)totalTime;

/**
 Convert hours / minutes / seconds / milliseconds strings in TimeInterval instance (if possible).
 
 @param hours The hours string of the time interval.
 @param minutes The minutes string of the time interval.
 @param seconds The seconds string of the time interval.
 @param milliseconds The milliseconds string of the time interval (can be nil).
 @return A TimeInterval corresponding to the duration if possible, -1.0 otherwise.
 */
+ (NSTimeInterval)timeIntervalWithHours:(NSString *)hours minutes:(NSString *)minutes seconds:(NSString *)seconds milliseconds:(nullable NSString *)milliseconds;

/**
 Convert an array of TimeCodes strings into consumable NSInterval (double) NSNumber.
 Note: timecodes strings must be validated before being passed as a parameter. See [SCSTimeUtils timeIntervalFromVASTDuration:]
 
 @param timecodes An array of valid timecodes.
 @return An array of NSNumber corresponding to the NSTimeInterval for the timecode.
 */
+ (nullable NSArray <NSNumber *> *)consumableTimecodes:(NSArray <NSString *> *)timecodes;

/**
 Check the validity of an offset string and returns its type so it can be converted into a numeric offset.
 
 @param offsetString The offset string.
 @return The offset's type of the string.
 */
+ (SCSTimeUtilsOffsetType)offsetTypeFromString:(NSString *)offsetString;

@end

NS_ASSUME_NONNULL_END
