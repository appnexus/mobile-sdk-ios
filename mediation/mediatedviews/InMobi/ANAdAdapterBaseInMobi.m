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

#import "ANAdAdapterBaseInMobi.h"
#import "ANLogging.h"
#import "InMobi.h"
#import "IMError.h"

@implementation ANAdAdapterBaseInMobi

static NSString *kANAdAdapterBaseInMobiAppId = @"";

+ (NSString *)appId {
    return kANAdAdapterBaseInMobiAppId;
}

+ (void)setInMobiAppID:(NSString *)newAppId {
    [InMobi initialize:newAppId];
    kANAdAdapterBaseInMobiAppId = newAppId;
}

+ (ANAdResponseCode)responseCodeFromInMobiError:(IMError *)error {
    switch (error.code) {
        case kIMErrorInvalidRequest:
            return ANAdResponseInvalidRequest;
        case kIMErrorNoFill:
            return ANAdResponseUnableToFill;
        case kIMErrorInternal:
            return ANAdResponseInternalError;
        case kIMErrorTimeout:
            return ANAdResponseNetworkError;
        case kIMErrorRequestCancelled:
            return ANAdResponseInternalError;
        case kIMErrorDoMonetization:
            return ANAdResponseInternalError;
        case kIMErrorDoNothing:
            return ANAdResponseInternalError;
        default:
            ANLogDebug(@"Unhandled InMobi IMError %@", error);
            return ANAdResponseInternalError;
    }
}

+ (void)setInMobiTargetingWithTargetingParameters:(ANTargetingParameters *)targetingParameters {
    if (targetingParameters.age) {
        NSNumber *ageNumber = [[[self class] sharedAgeNumberFormatter] numberFromString:targetingParameters.age];
        if (ageNumber) {
            [InMobi setAge:[ageNumber integerValue]];
        }
    }
    
    switch (targetingParameters.gender) {
        case ANGenderMale:
            [InMobi setGender:kIMGenderMale];
            break;
        case ANGenderFemale:
            [InMobi setGender:kIMGenderFemale];
            break;
        default:
            break;
    }
    
    if (targetingParameters.location) {
        [InMobi setLocationWithLatitude:targetingParameters.location.latitude
                              longitude:targetingParameters.location.longitude
                               accuracy:targetingParameters.location.horizontalAccuracy];
    }
}

+ (NSString *)keywordsFromTargetingParameters:(ANTargetingParameters *)targetingParameters {
    NSMutableArray *keywords = [[NSMutableArray alloc] init];
    [targetingParameters.customKeywords enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [keywords addObject:value];
    }];
    return [keywords componentsJoinedByString:@","];
}

+ (NSNumberFormatter *)sharedAgeNumberFormatter {
    static dispatch_once_t sharedAgeNumberFormatterToken;
    static NSNumberFormatter *sharedAgeNumberFormatter;
    dispatch_once(&sharedAgeNumberFormatterToken, ^{
        sharedAgeNumberFormatter = [[NSNumberFormatter alloc] init];
        sharedAgeNumberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    });
    return sharedAgeNumberFormatter;
}

@end