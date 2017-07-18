//
// Created by Rubicon Project on 3/23/17.
// Copyright (c) 2017 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFMAdProtocols.h"


/**
 * Provides convenience method to
 * help convert between RFMCuePoint struct and NSValue objects.
 */
@interface NSValue (RFMCuePoint)

/**
 * Convenience method for converting a RFMCuePoint struct to an NSValue instance
 * @param cuePoint RFMCuePoint struct
 * @return A new instance of NSValue
 */
+ (instancetype)valueWithRFMCuePoint:(RFMCuePoint)cuePoint;

/**
 * Convenience method for converting the NSValue instance to a RFMCuePoint struct.
 * @return A RFMCuePoint struct
 */
- (RFMCuePoint)rfmCuePointValue;

@end
