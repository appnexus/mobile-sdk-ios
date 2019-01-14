//
//  SCSHash.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 17/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Class used to provide various hashes of string objects.
 */
@interface SCSHash : NSObject

/**
 Compute the MD5 hash of a given string.
 
 @param input A non empty string.
 @return The MD5 hash of the non empty string (or an empty string if input is empty).
 */
+ (NSString *)md5:(NSString *)input;

@end

NS_ASSUME_NONNULL_END
