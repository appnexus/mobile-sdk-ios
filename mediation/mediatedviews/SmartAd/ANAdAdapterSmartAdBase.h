//
//  ANAdAdapterSmartAdBase.h
//  ANSDK
//
//  Created by Punnaghai Puviarasu on 1/9/17.
//  Copyright © 2017 AppNexus. All rights reserved.
//


#import "ANCustomAdapter.h"
#import <CoreLocation/CoreLocation.h>

@interface ANAdAdapterSmartAdBase : NSObject <ANCustomAdapter>

- (NSString *) keywordsFromTargetingParameters:(ANTargetingParameters *)targetingParameters;

- (void) locationFromTargetingParameters:(ANTargetingParameters *)targetingParameters;

@end
