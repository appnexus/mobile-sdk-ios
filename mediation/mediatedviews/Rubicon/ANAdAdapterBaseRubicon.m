/*   Copyright 2016 APPNEXUS INC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
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
