//
//  SCSLocation.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 23/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Representation of a GPS location.
 */
@interface SCSLocation : NSObject

/// The coordinate associated to this location.
@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize a SCSLocation instance using Core Location coordinate.
 
 @param locationCoordinate The coordinate that need to be associated with the SCSLocation instance.
 @return An initialized SCSLocation instance.
 */
- (instancetype)initWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
