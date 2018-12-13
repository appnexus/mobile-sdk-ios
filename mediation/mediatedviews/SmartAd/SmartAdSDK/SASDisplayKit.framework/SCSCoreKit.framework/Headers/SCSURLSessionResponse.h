//
//  SCSURLSessionResponse.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 20/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Response of a SCSURLSession task.
 */
@interface SCSURLSessionResponse : NSObject

/// The data of the response if available.
@property (nonatomic, readonly, nullable) NSData *data;

/// The URL response if available.
@property (nonatomic, readonly, nullable) NSURLResponse *response;

/// An error associated with the response if available.
@property (nonatomic, readonly, nullable) NSError *error;

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize a new URL session reponse from data / response / error.
 
 @param data The data of the response if available.
 @param response The URL response if available.
 @param error An error associated with the response if available.
 @return An initialized instance of SCSURLSessionResponse.
 */
- (instancetype)initWithData:(nullable NSData *)data response:(nullable NSURLResponse *)response error:(nullable NSError *)error NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
