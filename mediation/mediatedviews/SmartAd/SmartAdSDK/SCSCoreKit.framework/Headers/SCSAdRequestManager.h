//
//  SCSAdRequestManager.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 22/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import "SCSAdRequestValidatorProtocol.h"
#import "SCSURLSession.h"
#import "SCSURLSessionResponse.h"

/// List of all HTTP methods that can be used with the ad request manager.
typedef NS_ENUM(NSUInteger, SCSAdRequestManagerHTTPMethod) {
    /// POST method.
    SCSAdRequestManagerHTTPMethodPOST,
    
    /// GET method.
    SCSAdRequestManagerHTTPMethodGET,
};

NS_ASSUME_NONNULL_BEGIN

/**
 Class used to validate and perform ad requests.
 */
@interface SCSAdRequestManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize a new instance of SCSAdRequestManager.
 
 @param validator A class implementing SCSAdRequestValidatorProtocol to validate the request parameters.
 @return An initialized instance of SCSAdRequestManager.
 */
- (instancetype)initWithValidator:(id<SCSAdRequestValidatorProtocol>)validator;

/**
 Initialize a new instance of SCSAdRequestManager.
 
 Note: this init method allows to specify a custom URLSession object which is useful for testing. Use the
 initWithValidator: method to instanciate an instance with the shared URLSession instance.
 
 @param urlSession The URLSession to be used by this instance.
 @param validator A class implementing SCSAdRequestValidatorProtocol to validate the request parameters.
 @return An initialized instance of SCSAdRequestManager.
 */
- (instancetype)initWithUrlSession:(SCSURLSession *)urlSession validator:(id<SCSAdRequestValidatorProtocol>)validator NS_DESIGNATED_INITIALIZER;

/**
 Performs an ad request.
 
 @param baseURL The base URL of the request.
 @param path The path to the URL endpoint
 @param method The HTTP method that will be used to perform the request.
 @param headers The headers to be added to the request.
 @param getParameters The parameters to be added to the URL.
 @param postParameters The parameters to be posted in the HTTP Body (if using SCSAdRequestManagerHTTPMethodPOST).
 @param completionHandler Completion handler that will be called at the end of the request or in case of error.
 */
- (void)asynchronousRequestWithBaseURL:(NSString *)baseURL
                                  path:(nullable NSString *)path
                                method:(SCSAdRequestManagerHTTPMethod)method
                               headers:(nullable NSDictionary<NSString *, id> *)headers
                         getParameters:(nullable NSDictionary<NSString *, id> *)getParameters
                        postParameters:(nullable NSDictionary<NSString *, id> *)postParameters
                     completionHandler:(void(^)(SCSURLSessionResponse *))completionHandler;

/**
 Performs an ad request.
 
 @param baseURL The base URL of the request.
 @param path The path to the URL endpoint
 @param method The HTTP method that will be used to perform the request.
 @param headers The headers to be added to the request.
 @param getParameters The parameters to be added to the URL.
 @param postParameters The parameters to be posted in the HTTP Body (if using SCSAdRequestManagerHTTPMethodPOST).
 @param timeout the timeout for the request.
 @param completionHandler Completion handler that will be called at the end of the request or in case of error.
 */
- (void)asynchronousRequestWithBaseURL:(NSString *)baseURL
                                  path:(nullable NSString *)path
                                method:(SCSAdRequestManagerHTTPMethod)method
                               headers:(nullable NSDictionary<NSString *, id> *)headers
                         getParameters:(nullable NSDictionary<NSString *, id> *)getParameters
                        postParameters:(nullable NSDictionary<NSString *, id> *)postParameters
                               timeout:(NSTimeInterval)timeout
                     completionHandler:(void(^)(SCSURLSessionResponse *))completionHandler;

@end

NS_ASSUME_NONNULL_END
