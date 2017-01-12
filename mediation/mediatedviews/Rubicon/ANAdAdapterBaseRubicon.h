//
//  ANAdAdapterBaseRubicon.h
//  ANSDK
//
//  Created by Punnaghai Puviarasu on 1/11/17.
//  Copyright © 2017 AppNexus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RFMAdSDK/RFMAdSDK.h>

#define RUBICON_BASEURL		@"https://mrp.rubiconproject.com/"
#define RUBICON_APP_ID      @"app_id"
#define RUBICON_PUB_ID      @"pub_id"

@interface ANAdAdapterBaseRubicon : NSObject

+(void) setRubiconPublisherID:(NSString *) publisherID;

-(RFMAdRequest *) constructRequestObject:(NSString *) adUnitString;

@end
