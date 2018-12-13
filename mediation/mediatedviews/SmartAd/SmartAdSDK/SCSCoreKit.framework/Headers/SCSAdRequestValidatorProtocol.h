//
//  SCSAdRequestValidatorProtocol.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 22/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol that must be implemented by an object that need to check ad request validity.
 */
@protocol SCSAdRequestValidatorProtocol <NSObject>

/**
 Validate parameters for an Ad Request.
 
 @param baseURL The base URL of the ad request.
 @param headers The headers of the ad request.
 @param getParameters The GET parameters of the ad request.
 @param postParameters The POST parameters of the ad request.
 @return an error if parameters are invalid, nil otherwise.
 */
- (nullable NSError *)validateAdRequestWithBaseURL:(NSString *)baseURL
                                              path:(nullable NSString *)path
                                           headers:(nullable NSDictionary<NSString *, id> *)headers
                                     getParameters:(nullable NSDictionary<NSString *, id> *)getParameters
                                    postParameters:(nullable NSDictionary<NSString *, id> *)postParameters
NS_SWIFT_NAME(validateAdRequest(baseURL:path:headers:getParameters:postParameters:));

@end

NS_ASSUME_NONNULL_END
