/*   Copyright 2013 APPNEXUS INC
 
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

#import "ANAdAdapterMillennialMediaBase.h"

@implementation ANAdAdapterMillennialMediaBase
@synthesize delegate;

- (void)configureMillennialSettingsWithTargetingParameters:(ANTargetingParameters *)targetingParameters {
    static dispatch_once_t initializeMillennialToken;
    dispatch_once(&initializeMillennialToken, ^{
       [[MMSDK sharedInstance] initializeWithSettings:[[MMAppSettings alloc] init]
                                     withUserSettings:[[MMUserSettings alloc] init]];
    });
    
    MMUserSettings *userSettings = [[MMSDK sharedInstance] userSettings];
    
    ANGender gender = targetingParameters.gender;
    switch (gender) {
        case ANGenderMale:
            userSettings.gender = MMGenderMale;
            break;
        case ANGenderFemale:
            userSettings.gender = MMGenderFemale;
            break;
        case ANGenderUnknown:
            userSettings.gender = MMGenderOther;
        default:
            break;
    }
    
    NSString *age = targetingParameters.age;
    if (age) {
        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *ageNumber = [numberFormatter numberFromString:age];
        if (ageNumber) {
            userSettings.age = ageNumber;
        }
    }
    
    if (targetingParameters.location) {
        [MMSDK sharedInstance].sendLocationIfAvailable = YES;
    }
}

+ (void)setMillennialSiteId:(NSString *)siteId  {
    MMAppSettings  *appSettings  = [MMSDK sharedInstance].appSettings;
    appSettings.siteId = siteId;
}

@end
