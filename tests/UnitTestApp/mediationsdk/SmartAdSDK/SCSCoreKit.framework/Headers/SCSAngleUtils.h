//
//  SCSAngleUtils.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 17/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Some methods to manipulate angles.
 */
@interface SCSAngleUtils : NSObject

/**
 Convert a degree angle in radians.
 
 @param degrees An angle expressed in degrees.
 @return The same angle expressed in radians.
 */
+ (double)radiansFromDegrees:(double)degrees;

/**
 Convert a radian angle in degrees.
 
 @param radians An angle expressed in radians.
 @return The same angle expressed in degrees.
 */
+ (double)degreesFromRadians:(double)radians;

@end

NS_ASSUME_NONNULL_END
