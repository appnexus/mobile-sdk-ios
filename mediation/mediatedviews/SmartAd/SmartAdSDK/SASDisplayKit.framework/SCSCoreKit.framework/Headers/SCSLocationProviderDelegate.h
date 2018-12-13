//
//  SCSLocationProviderDelegate.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 23/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SCSLocationProviderProtocol;

/**
 Location provider delegate.
 */
@protocol SCSLocationProviderDelegate <NSObject>

/**
 Warn the delegate that the location has been updated.
 
 @param provider The location provider involved in the location update.
 @param locations An array of locations.
 */
- (void)locationProvider:(id<SCSLocationProviderProtocol>)provider didUpdateLocations:(NSArray<CLLocation *> *)locations NS_SWIFT_NAME(locationProvider(_:didUpdateLocations:));

@end

NS_ASSUME_NONNULL_END
