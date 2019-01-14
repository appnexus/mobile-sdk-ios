//
//  SCSLocationManagerDataSource.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 05/04/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSLocationManager.h"
#import "SCSLocation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol that must be implemented by objects that want to act as data source for a SCSLocationManager instance.
 */
@protocol SCSLocationManagerDataSource <NSObject>

@required

/**
 Detect wether the automatic location detection should be enabled or not.
 
 @param locationManager The location manager that wants to enable the automatic location detection.
 @returns true if the automatic location detection can be enabled, false otherwise.
 */
- (BOOL)locationManagerShouldAllowAutomaticLocationDetection:(SCSLocationManager *)locationManager;

/**
 Returns a manual location that must be used instead of the actual device location if necessary.
 
 @param locationManager The location manager that requests a manual location.
 @returns A location object that will override the actual device location if necessary, nil otherwise.
 */
- (nullable SCSLocation *)manualLocationForLocationManager:(SCSLocationManager *)locationManager;

@end

NS_ASSUME_NONNULL_END
