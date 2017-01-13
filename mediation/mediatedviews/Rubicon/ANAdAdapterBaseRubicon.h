//
//  ANAdAdapterBaseRubicon.h
//  ANSDK
//
//  Created by Punnaghai Puviarasu on 1/11/17.
//  Copyright © 2017 AppNexus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RFMAdSDK/RFMAdSDK.h>
#import "ANCustomAdapter.h"

#define RUBICON_BASEURL		@"serverName"
#define RUBICON_APP_ID      @"adId"
#define RUBICON_PUB_ID      @"pubId"

@interface ANAdAdapterBaseRubicon : NSObject <ANCustomAdapter>

+(void) setRubiconPublisherID:(NSString *) publisherID;

-(RFMAdRequest *) constructRequestObject:(NSString *) adUnitString;

-(void) setTargetingParameters :(ANTargetingParameters *) targetingParameters forRequest:(RFMAdRequest *) rfmAdRequest;

@end
