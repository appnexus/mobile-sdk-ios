//
//  SCSURLSession.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 20/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import "SCSURLSessionResponse.h"
#import "SCSURLSessionProviderProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class SCSURLSessionTask;

/**
 The SCSURLSession class provides an API to retrieve data from an URL or an URL request.
 */
@interface SCSURLSession : NSObject

/// The default timeout used when requesting by URL.
@property (class, nonatomic, readonly) NSTimeInterval DEFAULT_TIMEOUT NS_SWIFT_NAME(defaultTimeout);

/// The default cache policy when requesting by URL.
@property (class, nonatomic, readonly) NSURLRequestCachePolicy DEFAULT_CACHE_POLICY NS_SWIFT_NAME(defaultCachePolicy);

/// The shared instance of the SCSURLSession object.
@property (class, nonatomic, readonly) SCSURLSession *sharedInstance NS_SWIFT_NAME(shared);

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize a new url session instance using a provider.
 
 Note: you should use the shared instance of SCSURLSession except if you need a custom session provider (for unit tests for example).
 
 @param sessionProvider The session provider that is going to be used to call the request.
 @return An initialized url session instance.
 */
- (instancetype)initWithSessionProvider:(id<SCSURLSessionProviderProtocol>)sessionProvider NS_DESIGNATED_INITIALIZER;

/**
 Retrieve data asynchronously from an URL request.
 
 @param urlRequest The url request used to retrieve the data.
 @param completionHandler Completion handler that will be called at the end of the request or in case of error.
 
 @return The SCSURLSessionTask performing the request.
 */
- (SCSURLSessionTask *)asynchronousDataRequestWithURLRequest:(NSURLRequest *)urlRequest completionHandler:(void (^)(SCSURLSessionResponse *, SCSURLSessionTask *))completionHandler;

/**
 Retrieve data synchronously from an URL request.
 
 @warning This method blocks the caller thread until the request is completed or failed, do not use it in the main thread!
 
 @param urlRequest The url request used to retrieve the data.
 @return A SCSURLSessionResponse that contains the data and the url response or the error depending of the status of the request.
 */
- (SCSURLSessionResponse *)synchronousDataRequestWithURLRequest:(NSURLRequest *)urlRequest;

/**
 Retrieve data asynchronously from an URL using the default cache policy and timeout interval.
 
 @param url The url where the data can be found.
 @param completionHandler Completion handler that will be called at the end of the request or in case of error.
 
 @return The SCSURLSessionTask performing the request.
 */
- (SCSURLSessionTask *)asynchronousDataRequestWithURL:(NSURL *)url completionHandler:(void (^)(SCSURLSessionResponse *, SCSURLSessionTask *))completionHandler;

/**
 Retrieve data synchronously from an URL using the default cache policy and timeout interval.
 
 @warning This method blocks the caller thread until the request is completed or failed, do not use it in the main thread!
 
 @param url the url where the data can be found.
 @return A SCSURLSessionResponse that contains the data and the url response or the error depending of the status of the request.
 */
- (SCSURLSessionResponse *)synchronousDataRequestWithURL:(NSURL *)url;

/**
 Retrieve data asynchronously from an URL.
 
 @param url The url where the data can be found.
 @param cachePolicy The cache policy for this request.
 @param timeoutInterval The timeout interval that will be used for this request.
 @param completionHandler Completion handler that will be called at the end of the request or in case of error.
 
 @return The SCSURLSessionTask performing the request.
 */
- (SCSURLSessionTask *)asynchronousDataRequestWithURL:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval completionHandler:(void (^)(SCSURLSessionResponse *, SCSURLSessionTask *))completionHandler;

/**
 Retrieve data synchronously from an URL.
 
 @warning This method blocks the caller thread until the request is completed or failed, do not use it in the main thread!
 
 @param url the url where the data can be found.
 @param cachePolicy the cache policy for this request.
 @param timeoutInterval the timeout interval that will be used for this request.
 @return A SCSURLSessionResponse that contains the data and the url response or the error depending of the status of the request.
 */
- (SCSURLSessionResponse *)synchronousDataRequestWithURL:(NSURL *)url cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval;

@end

NS_ASSUME_NONNULL_END
