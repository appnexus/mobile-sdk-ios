//
//  SCSRandom.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 20/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Generate random numbers.
 */
@interface SCSRandom : NSObject

/**
 Generate a random unsigned int between [0, UINT_MAX[.
 
 @return A random unsigned int between [0, UINT_MAX[.
 */
+ (uint32_t)randomUnsignedInt;

/**
 Generate a random unsigned int between [min, max[.
 
 @return A random unsigned int between [min, max[.
 */
+ (uint32_t)randomUnsignedIntWithMin:(uint32_t)min max:(uint32_t)max;

@end
