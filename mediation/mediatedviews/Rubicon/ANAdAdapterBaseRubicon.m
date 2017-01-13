//
//  ANAdAdapterBaseRubicon.m
//  ANSDK
//
//  Created by Punnaghai Puviarasu on 1/11/17.
//  Copyright © 2017 AppNexus. All rights reserved.
//

#import "ANAdAdapterBaseRubicon.h"
#import <CoreLocation/CoreLocation.h>

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
            NSString *serverName = [idDictionary objectForKey:RUBICON_BASEURL];
            if(appId != nil && publisherId != nil){
                RFMAdRequest *rfmAdRequest = [[RFMAdRequest alloc] initRequestWithServer:serverName
                                                                                andAppId:appId
                                                                                andPubId:publisherId];
                return rfmAdRequest;
            }
        }
    }
    return nil;
}

#pragma mark -private methods

-(void) setTargetingParameters :(ANTargetingParameters *) targetingParameters forRequest:(RFMAdRequest *) rfmAdRequest {
    NSMutableDictionary *keywordDictionary = [[NSMutableDictionary alloc] init];
    
    ANGender gender = targetingParameters.gender;
    switch (gender) {
        case ANGenderMale:
            keywordDictionary[@"gender"] = @"male";
            break;
        case ANGenderFemale:
            keywordDictionary[@"gender"] = @"female";
            break;
        default:
            break;
    }
    
    if ([targetingParameters age]) {
        keywordDictionary[@"age"] = targetingParameters.age;
    }
    
    [targetingParameters.customKeywords enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        keywordDictionary[key] = obj;
    }];
    
    [rfmAdRequest setTargetingInfo:keywordDictionary];
    
    ANLocation *location = targetingParameters.location;
    if (location) {
        CLLocation *mpLoc = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(location.latitude, location.longitude)
                                                          altitude:0
                                                horizontalAccuracy:location.horizontalAccuracy
                                                  verticalAccuracy:0
                                                         timestamp:location.timestamp];
        [rfmAdRequest setLocationLatitude:mpLoc.coordinate.latitude];
        [rfmAdRequest setLocationLongitude:mpLoc.coordinate.longitude];
    }
    
}

@end
