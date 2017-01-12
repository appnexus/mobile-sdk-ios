//
//  ANAdAdapterBaseRubicon.m
//  ANSDK
//
//  Created by Punnaghai Puviarasu on 1/11/17.
//  Copyright © 2017 AppNexus. All rights reserved.
//

#import "ANAdAdapterBaseRubicon.h"

@implementation ANAdAdapterBaseRubicon

+(void) setRubiconPublisherID:(NSString *) publisherID{
    
    [RFMAdSDK initWithAccountId:publisherID];

}

-(RFMAdRequest *) constructRequestObject:(NSString *) idString{
    
    if(idString != nil || ![idString isEqualToString:@""]){
        NSData *data = [idString dataUsingEncoding:NSUTF8StringEncoding];
        id idDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(idDictionary != nil && [idDictionary isKindOfClass:[NSDictionary class]]){
            NSString *appId = [idDictionary objectForKey:RUBICON_APP_ID];
            NSString *publisherId = [idDictionary objectForKey:RUBICON_PUB_ID];
            
            if(appId != nil && publisherId != nil){
                RFMAdRequest *rfmAdRequest = [[RFMAdRequest alloc] initRequestWithServer:RUBICON_BASEURL
                                                                                andAppId:RUBICON_APP_ID
                                                                                andPubId:RUBICON_PUB_ID];
                return rfmAdRequest;
            }
        }
    }
    return nil;
}

@end
