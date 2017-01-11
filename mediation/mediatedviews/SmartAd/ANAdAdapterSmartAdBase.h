//
//  ANAdAdapterSmartAdBase.h
//  ANSDK
//
//  Created by Punnaghai Puviarasu on 1/9/17.
//  Copyright © 2017 AppNexus. All rights reserved.
//


#import "ANCustomAdapter.h"
#import <CoreLocation/CoreLocation.h>

#define SMARTAD_BASEURL		@"https://mobile.smartadserver.com"
#define SMART_SITEID        @"site_id"
#define SMART_FORMATID      @"format_id"
#define SMART_PAGEID        @"page_id"

@interface ANAdAdapterSmartAdBase : NSObject <ANCustomAdapter>

- (NSString *) keywordsFromTargetingParameters:(ANTargetingParameters *)targetingParameters;

@end
