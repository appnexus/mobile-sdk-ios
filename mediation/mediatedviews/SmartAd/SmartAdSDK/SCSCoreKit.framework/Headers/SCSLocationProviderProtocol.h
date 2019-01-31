//
//  SCSLocationProviderProtocol.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 23/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SCSLocationProviderDelegate;

/**
 Protocol that must be implemented by all classes that want to handle the location of the device.
 */
@protocol SCSLocationProviderProtocol <NSObject>

/**
 Instantiate and start the underlying location provider.
 */
- (void)startLocationProvider;

/**
 Stop and release the underlying location provider.
 */
- (void)stopAndCleanLocationProvider;

/**
 Returns the current status of the underlying location provider.
 
 @return true if the location service is enabled, false otherwise.
 */
- (BOOL)locationServiceEnabled;

/**
 Returns the current authorization status of the underlying location provider.
 
 @return The current authorization status of the underlying location provider.
 */
- (CLAuthorizationStatus)authorizationStatus;

@end

NS_ASSUME_NONNULL_END
