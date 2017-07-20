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

#import "ANAdAdapterBaseAdColony.h"
#import "ANAdAdapterBaseAdColony+PrivateMethods.h"



@implementation ANAdAdapterBaseAdColony

+ (void)configureWithAppID:(NSString *)appID
                   zoneIDs:(NSArray *)zoneIDs {
    [AdColony configureWithAppID:appID
                         zoneIDs:zoneIDs
                        delegate:nil
                         logging:NO];
}

+ (void)setAdColonyTargetingWithTargetingParameters:(ANTargetingParameters *)targetingParameters {
    if (targetingParameters.age) {
        [AdColony setUserMetadata:ADC_SET_USER_AGE
                        withValue:targetingParameters.age];
    }
    
    switch (targetingParameters.gender) {
        case ANGenderMale:
            [AdColony setUserMetadata:ADC_SET_USER_GENDER
                            withValue:ADC_USER_MALE];
            break;
        case ANGenderFemale:
            [AdColony setUserMetadata:ADC_SET_USER_GENDER
                            withValue:ADC_USER_FEMALE];
            break;
        default:
            break;
    }
    
    if (targetingParameters.location) {
        NSString *latitude = [NSString stringWithFormat:@"%f", targetingParameters.location.latitude];
        NSString *longitude = [NSString stringWithFormat:@"%f", targetingParameters.location.longitude];
        [AdColony setUserMetadata:ADC_SET_USER_LATITUDE
                        withValue:latitude];
        [AdColony setUserMetadata:ADC_SET_USER_LONGITUDE
                        withValue:longitude];
    }
}

@end
