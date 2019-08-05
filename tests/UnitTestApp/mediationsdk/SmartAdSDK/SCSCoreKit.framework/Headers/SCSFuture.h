//
//  SCSFuture.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 18/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSCSFutureErrorDomain       @"SCSFutureError"
#define kSCSFutureErrorCodeTimeout  1000

NS_ASSUME_NONNULL_BEGIN

/**
 Represents the result of an asynchronous task.
 */
@interface SCSFuture : NSObject

/// true if the result is already available, false otherwise.
@property (nonatomic, readonly) BOOL isDone;

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize a new SCSFuture instance with an asynchronous task.
 
 Notes:
 
 - the task will be run in the global queue and cannot manipulate UI classes.
 - the task will never be interrupted by the SCSFuture class and should not be infinite.
 
 @param task The task that will return the desired result.
 @return The initialized instance.
 */
- (instancetype)initWithTask:(id (^)(void))task NS_DESIGNATED_INITIALIZER;

/**
 Retrieve the result from the SCSFuture instance and block the main thread until it is available.
 
 @return The result of the SCSFuture instance.
 */
- (nullable id)get;

/**
 Retrieve the result from the SCSFuture instance and block the main thread until it is available. This
 method will throw an error after a given timeout period.
 
 @param timeout The timeout time before the method throws an error and returns without result.
 @param error An error if the result isn't available after the specified timeout.
 @return The result of the SCSFuture instance.
 */
- (nullable id)getWithTimeout:(NSTimeInterval)timeout error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
