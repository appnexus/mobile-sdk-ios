//
//  ANHTTPNetworkSession.h
//  UpdatedNetworkLatency
//
//  Created by Punnaghai Puviarasu on 4/30/20.
//  Copyright © 2020 Punnaghai Puviarasu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANHTTPNetworkSession : NSObject

/**
 Singleton instance of @c MPHTTPNetworkSession.
 */
+ (instancetype)sharedInstance;

/**
 Initializes a HTTP network request.
 @param request Request to send.
 @param responseHandler Optional response handler that will be invoked on the current thread.
 @param errorHandler Optional error handler that will be invoked on the current thread.
 @param shouldRedirectWithNewRequest Optional logic control block to determine if a redirection should occur. This is invoked on the current thread.
 @returns The HTTP networking task.
 */
+ (NSURLSessionTask *)taskWithHttpRequest:(NSURLRequest *)request
                          responseHandler:(void (^ _Nullable)(NSData * data, NSHTTPURLResponse * response))responseHandler
                             errorHandler:(void (^ _Nullable)(NSError * error))errorHandler
             shouldRedirectWithNewRequest:(BOOL (^ _Nullable)(NSURLSessionTask * task, NSURLRequest * newRequest))shouldRedirectWithNewRequest;

/**
 Initializes a HTTP network request and immediately sends it.
 @param request Request to send.
 @returns The HTTP networking task.
 */
+ (NSURLSessionTask *)startTaskWithHttpRequest:(NSURLRequest *)request;

/**
 Initializes a HTTP network request and immediately sends it.
 @param request Request to send.
 @param responseHandler Optional response handler that will be invoked on the main thread.
 @param errorHandler Optional error handler that will be invoked on the main thread.
 @returns The HTTP networking task.
 */
+ (NSURLSessionTask *)startTaskWithHttpRequest:(NSURLRequest *)request
                               responseHandler:(void (^ _Nullable)(NSData * data, NSHTTPURLResponse * response))responseHandler
                                  errorHandler:(void (^ _Nullable)(NSError * error))errorHandler;

@end

NS_ASSUME_NONNULL_END
