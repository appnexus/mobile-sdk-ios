//
//  SCSVASTTrackingEvent.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 20/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSVideoTrackingEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCSVASTTrackingEvent : NSObject <SCSVideoTrackingEvent>

/// The name of the event. Event names are the same than in the VAST standard.
@property (nonatomic, readonly) NSString *name;

/// Time offset when the event should be triggered.
@property (nullable, nonatomic, readonly) NSString *offset;

/// URL to be called when the event is triggered.
@property (nonatomic, readonly) NSURL *url;

/// Time offset when the event should be triggered expressed as a time interval, relative to the content video (-1 if not defined).
/// This value is computed by a SCSVASTTrackingEventFactory instance.
@property (nonatomic, assign) NSTimeInterval eventOffset;

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize the SCSVASTTrackingEvent using name, offset and URL values.
 
 @param name The name of the tracking event.
 @param offset The offset value when it should be triggered.
 */
- (instancetype)initWithName:(NSString *)name offset:(nullable NSString *)offset url:(NSURL *)url NS_DESIGNATED_INITIALIZER;

/**
 Convenience initializer from a dictionary
 
 @param dictionary The dictionary with the key/values representing the TrackingEvent.
 */
- (nullable instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 Convenience initializer from a dictionary found in VAST Extensions
 
 @param dictionary The dictionary with the key/values representing the Extension Metric Event.
 */
- (nullable instancetype)initWithExtensionDictionary:(NSDictionary *)dictionary;

/**
 Utility method to retrieve all the TrackingEvents from a dictionary
 
 @param dictionary The dictionary with the key/values the TrackingEvents.
 @return An array of SCSVASTTrackingEvent or nil if no valid event is found.
 */
+ (nullable NSMutableArray <SCSVASTTrackingEvent *> *)findTrackingEvents:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
