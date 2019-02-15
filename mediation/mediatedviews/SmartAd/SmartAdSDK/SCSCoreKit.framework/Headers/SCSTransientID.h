//
//  SCSTransientID.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 23/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Transient device identifier.
 */
@interface SCSTransientID : NSObject

/// The device identifier.
@property (nullable, nonatomic, readonly) NSString *transientID;

/// The last generation date.
@property (nullable, nonatomic, readonly) NSDate *lastGeneration;

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize a new transient device identifier.
 
 @param transientID The device identifier.
 @param lastGeneration The last generation date.
 @return An initialized transient device identifier.
 */
- (instancetype)initWithTransientID:(nullable NSString *)transientID lastGeneration:(nullable NSDate *)lastGeneration NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
