//
//  SCSQuaternion.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 17/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <SceneKit/SceneKit.h>

#import "SCSAxis3.h"

NS_ASSUME_NONNULL_BEGIN

/**
 This class represents a quaternion number.
 */
@interface SCSQuaternion : NSObject

#pragma mark - Quaternion properties

/// w value of the quaternion.
@property (nonatomic, readonly) double w;

/// x value of the quaternion.
@property (nonatomic, readonly) double x;

/// y value of the quaternion.
@property (nonatomic, readonly) double y;

/// z value of the quaternion.
@property (nonatomic, readonly) double z;

#pragma mark - Initializers

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize the quaternion using w, x, y and z values.
 
 @param w The w value of the quaternion.
 @param x The x value of the quaternion.
 @param y The y value of the quaternion.
 @param z The z value of the quaternion.
 */
- (instancetype)initWithW:(double)w x:(double)x y:(double)y z:(double)z NS_DESIGNATED_INITIALIZER;

/**
 Initialize the quaternion using a CMQuaternion (from the CoreMotion framework).
 
 @param quaternion A valid CMQuaternion instance.
 */
- (instancetype)initFromCMQuaternion:(CMQuaternion)quaternion;

/**
 Initialize the quaternion representing a rotation around an axis (X, Y or Z).
 
 @param angle The rotation angle.
 @param axis The axis around which the rotation will happen.
 */
- (instancetype)initWithAngle:(double)angle axis:(SCSAxis3)axis;

/**
 Initialize the quaternion representing a rotation defined using Euler angles.
 
 @param xe The euler angle representing the rotation around the X axis.
 @param ye The euler angle representing the rotation around the Y axis.
 @param ze The euler angle representing the rotation around the Z axis.
 */
- (instancetype)initWithXe:(double)xe ye:(double)ye ze:(double)ze;

#pragma mark - Quaternion operators

/**
 Multiply the quaternion by another quaternion.
 
 - Parameters:
 @param other the quaternion self will be mutiplied by.
 @return A new quaternion that represents the product of the two quaternions.
 */
- (SCSQuaternion *)multipliedBy:(SCSQuaternion *)other;

/**
 Returns the norm of the vector representation of the quaternion.
 
 @return The norm of the quaternion.
 */
- (double)norm;

/**
 Returns the normalized version of the current quaternion.
 
 @return The normalized version of the current quaternion.
 */
- (SCSQuaternion *)normalized;

/**
 Convert the quaternion into a SceneKit 4 dimensions vector.
 
 @return The SceneKit vector representing the quaternion.
 */
- (SCSQuaternion *)inverted;

/**
 Convert the quaternion into a SceneKit 4 dimensions vector.
 
 @return The SceneKit vector representing the quaternion.
 */
- (SCNVector4)vector4;

@end

NS_ASSUME_NONNULL_END
