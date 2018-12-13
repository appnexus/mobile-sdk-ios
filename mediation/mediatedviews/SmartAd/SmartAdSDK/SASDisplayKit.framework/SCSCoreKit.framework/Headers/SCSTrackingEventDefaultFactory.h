//
//  SCSTrackingEventDefaultFactory.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 29/05/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSTrackingEvent.h"
#import "SCSTrackingEventFactory.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Default SCSTrackingEventFactory implementation.
 
 This implementation can only manipulates abstract events and filter them.
 */
@interface SCSTrackingEventDefaultFactory : NSObject <SCSTrackingEventFactory>

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize a new instance of the default tracking event factory.
 
 @param events The events that will be returned by the factory.
 @return A newly initialized instance of the default tracking event factory.
 */
- (instancetype)initWithEvents:(NSArray<id<SCSTrackingEvent>> *)events;

/**
 Initialize a new instance of the default tracking event factory.
 
 @param events The events that will be returned by the factory if they are not filtered.
 @param filter A filter that will be applied to eliminate some unwanted events from the factory (the block should return YES to keep the event in the factory, NO otherwise).
 @return A newly initialized instance of the default tracking event factory.
 */
- (instancetype)initWithEvents:(NSArray<id<SCSTrackingEvent>> *)events withFilter:(BOOL(^_Nullable)(id<SCSTrackingEvent>))filter NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
