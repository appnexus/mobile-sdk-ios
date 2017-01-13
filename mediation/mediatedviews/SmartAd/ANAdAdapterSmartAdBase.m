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
#import "ANAdAdapterSmartAdBase.h"
#import "SASAdView.h"




@implementation ANAdAdapterSmartAdBase

@synthesize delegate;

- (void) setSmartAdSiteId:(NSInteger)siteId{
    
    [SASAdView setSiteID:siteId baseURL:SMARTAD_BASEURL];
    
}

- (NSString *)keywordsFromTargetingParameters:(ANTargetingParameters *)targetingParameters {
        //currently we are not sure in what format the params needs to be passed to the SmartAd server. Hence keeping it empty
    if(targetingParameters.location != nil){
        ANLocation *location = targetingParameters.location;
        if (location) {
            CLLocation *mpLoc = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(location.latitude, location.longitude)
                                                              altitude:0
                                                    horizontalAccuracy:location.horizontalAccuracy
                                                      verticalAccuracy:0
                                                             timestamp:location.timestamp];
            [SASAdView setLocation:mpLoc];
            
        }
    }
        return @"";
}

#pragma mark - PrivateMethods

-(NSDictionary *) parseAdUnitParameters:(NSString *) adUnitString{
    
    if(adUnitString != nil || ![adUnitString isEqualToString:@""]){
        NSData *data = [adUnitString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *adUnitDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(adUnitDictionary != nil){
            NSInteger siteId = [adUnitDictionary[SMARTAD_SITEID] integerValue];
            [self setSmartAdSiteId:siteId];
        }
        return adUnitDictionary;
    }
    return nil;
}


@end
