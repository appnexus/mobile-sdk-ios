//
//  SCSTrackingEvent.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 16/05/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a generic tracking event.
 */
@protocol SCSTrackingEvent <NSObject>

@required

/**
 Returns the name of the event.
 
 @return The name of the event.
 */
- (NSString *)eventName;

/**
 Returns the URL of the event.
 
 @return The URL of the event.
 */
- (NSURL *)eventURL;

/**
 Returns the type of event: consumable or not.
 
 A consumable event will be discarded after being called once. It will be called an unlimited
 number of times otherwise.
 
 @return YES if the event is consumable, NO otherwise.
 */
- (BOOL)isEventConsumable;

@end

NS_ASSUME_NONNULL_END
