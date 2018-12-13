//
//  SCSURLSessionTask.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 22/09/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCSURLSessionTask : NSObject

/**
 Public initializer.
 
 @param dataTask the NSURLSessionDataTask associated with this SCSURLSessionTask
 
 @return an initialized instance of SCSURLSessionTask
 */
- (instancetype)initWithDataTask:(NSURLSessionDataTask *)dataTask;

/**
 The identifier for this SCSURLSessionTask
 
 @return the identifier of this SCSURLSessionTask
 */
- (nullable NSNumber *)identifier;

/**
 Resume the current task.
 */
- (void)resume;

/**
 Cancel the current task
 */
- (void)cancel;

/**
 Convenient initializer from a NSURLSession
 
 @param session The NSURLSession for the task
 @param request The NSURLRequest to be performed
 @param completionHandler The completion block to be executed at the end of the task
 
 @return an initialized instance of SCSURLSessionTask
 */
+ (SCSURLSessionTask *)sessionTaskWithSession:(NSURLSession *)session request:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
