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
#import "ANGlobal.h"
#import "ANAdConstants.h"
#import "ANTargetingParameters.h"

#import "IMSdk.h"
#import "IMRequestStatus.h"

@implementation ANAdAdapterBaseInMobi

static NSString *kANAdAdapterBaseInMobiAppId = @"";

+ (NSString *)appId {
    return kANAdAdapterBaseInMobiAppId;
}

+ (void)setInMobiAppID:(NSString *)newAppId {
    [IMSdk initWithAccountID:newAppId];
    kANAdAdapterBaseInMobiAppId = newAppId;
}

+ (ANAdResponseCode)responseCodeFromInMobiRequestStatus:(IMRequestStatus *)status {
    switch (status.code) {
        case kIMStatusCodeNetworkUnReachable:
            return ANAdResponseNetworkError;
        case kIMStatusCodeNoFill:
            return ANAdResponseUnableToFill;
        case kIMStatusCodeRequestInvalid:
            return ANAdResponseInvalidRequest;
        case kIMStatusCodeRequestPending:
            return ANAdResponseInternalError;
        case kIMStatusCodeRequestTimedOut:
            return ANAdResponseNetworkError;
        case kIMStatusCodeInternalError:
            return ANAdResponseInternalError;
        case kIMStatusCodeServerError:
            return ANAdResponseNetworkError;
        case kIMStatusCodeAdActive:
            return ANAdResponseInternalError;
        case kIMStatusCodeEarlyRefreshRequest:
            return ANAdResponseUnableToFill;
        default:
            ANLogDebug(@"Unhandled IMRequestStatus code: %ld", (long)status.code);
            return ANAdResponseInternalError;
    }
}

+ (void)setInMobiTargetingWithTargetingParameters:(ANTargetingParameters *)targetingParameters {
    if (targetingParameters.age) {
        NSNumber *ageNumber = [[[self class] sharedAgeNumberFormatter] numberFromString:targetingParameters.age];
        if (ageNumber) {
            NSInteger age = 0;
            if ([ageNumber integerValue] > 1900) {
                NSDate *date = [NSDate date];
                NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *components = [cal components:0
                                                      fromDate:date];
                age = [components year] - [ageNumber integerValue];
            } else {
                age = [ageNumber integerValue];
            }
            if (age > 0) {
                [IMSdk setAge:age];
            }
        }
        
    }
    
    switch (targetingParameters.gender) {
        case ANGenderMale:
            [IMSdk setGender:kIMSDKGenderMale];
            break;
        case ANGenderFemale:
            [IMSdk setGender:kIMSDKGenderFemale];
            break;
        default:
            break;
    }
    
    if (targetingParameters.location) {
        ANLocation *anLocation = targetingParameters.location;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(anLocation.latitude, anLocation.longitude);
        CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate
                                                             altitude:-1
                                                   horizontalAccuracy:anLocation.horizontalAccuracy
                                                     verticalAccuracy:-1
                                                            timestamp:anLocation.timestamp];
        [IMSdk setLocation:location];
    }
}

+ (NSString *)keywordsFromTargetingParameters:(ANTargetingParameters *)targetingParameters
{
    NSArray<NSString *>  *keywords  = [[ANGlobal convertCustomKeywordsAsMapToStrings:targetingParameters.customKeywords] allValues];

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
