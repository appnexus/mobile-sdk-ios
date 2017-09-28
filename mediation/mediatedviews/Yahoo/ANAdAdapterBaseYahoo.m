/*   Copyright 2015 APPNEXUS INC
 
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

#import "ANAdAdapterBaseYahoo+PrivateMethods.h"
#import "Flurry.h"

@implementation ANAdAdapterBaseYahoo

+ (void)setFlurryAPIKey:(NSString *)apiKey {
    [Flurry startSession:apiKey];
}

+ (FlurryAdTargeting *)adTargetingWithTargetingParameters:(ANTargetingParameters *)targetingParameters {
    FlurryAdTargeting *flurryTargeting = [FlurryAdTargeting targeting];
    ANLocation *location = targetingParameters.location;
    if (location) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
        CLLocation *yahooLocation = [[CLLocation alloc] initWithCoordinate:coordinate
                                                                  altitude:0
                                                        horizontalAccuracy:location.horizontalAccuracy
                                                          verticalAccuracy:-1
                                                                 timestamp:location.timestamp];
        flurryTargeting.location = yahooLocation;
    }
    
    NSMutableDictionary *keywords = [targetingParameters.customKeywords mutableCopy];
    if (!keywords) {
        keywords = [[NSMutableDictionary alloc] init];
    }
    
    NSString *age = targetingParameters.age;
    if (age) {
        keywords[@"age"] = age;
    }
    
    ANGender gender = targetingParameters.gender;
    FlGender flurryGender = 0;
    switch (gender) {
        case ANGenderMale:
            flurryGender = FL_MALE;
            break;
        case ANGenderFemale:
            flurryGender = FL_FEMALE;
            break;
        case ANGenderUnknown:
        default:
            break;
    }
    if (flurryGender) {
        keywords[@"gender"] = @(flurryGender);
    }
    
    flurryTargeting.keywords = [keywords copy];
    
    return flurryTargeting;
}

@end