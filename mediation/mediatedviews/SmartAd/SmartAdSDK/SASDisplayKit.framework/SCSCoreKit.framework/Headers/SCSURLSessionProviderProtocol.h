//
//  SCSURLSessionProviderProtocol.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 20/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SCSURLSessionResponse;
@class SCSURLSessionTask;

/**
 Protocol that must be implemented by all classes that want to execute data requests for an URL session object.
 */
@protocol SCSURLSessionProviderProtocol <NSObject>

/**
 Retrieve data from an URL request asynchronously and returns the result using a completion handler.
 
 @param urlRequest The url request used to retrieve the data.
 @param completionHandler Completion handler that will be called at the end of the request or in case of error.
 
 @return the SCSURLSessionTask that will perform the request
 */
- (SCSURLSessionTask *)dataRequest:(NSURLRequest *)urlRequest completionHandler:(void (^)(SCSURLSessionResponse *, SCSURLSessionTask *))completionHandler;

@end

NS_ASSUME_NONNULL_END
