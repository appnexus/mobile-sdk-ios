//
//  SCSVASTCreative.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 20/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SCSVASTTrackingEvent, SCSVASTURL;

@interface SCSVASTCreative : NSObject

/// An array of all the tracking events for this creative.
@property (nonatomic, readonly) NSMutableArray <SCSVASTTrackingEvent *> *trackingEvents;

/// The clickURL to open when the creative is clickedThrough
@property (nullable, nonatomic, readonly) SCSVASTURL *clickThrough;

/// An array of all the URLs to call when the creative is clicked.
@property (nonatomic, readonly) NSMutableArray <SCSVASTURL *> *clickTracking;

- (instancetype)init NS_UNAVAILABLE;

/**
 Initializer from a dictionary.
 
 @param dictionary A dictionary from the parsed XML.
 */
- (nullable instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

/**
 Adds tracking events to this creative.
 
 @param events An array of tracking events.
 */
- (void)addTrackingEvents:(NSArray <SCSVASTTrackingEvent *> *)events;

/**
 Indicates whether or not this creative is valid. This method will be surcharged in subclasses.
 
 @param forWrapper Indicates if the Ad owning this creative is a wrapper ad.
 @return Whether or not this creative is valid.
 */
- (BOOL)isValidForWrapper:(BOOL)forWrapper;

@end

NS_ASSUME_NONNULL_END
