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

#import "ANAdAdapterBaseDFP.h"

@implementation ANAdAdapterBaseDFP

+ (GADRequest *)googleAdRequestFromTargetingParameters:(ANTargetingParameters *)targetingParameters {
    GADRequest *request = [GADRequest request];
    
    ANGender gender = targetingParameters.gender;
    switch (gender) {
        case ANGenderMale:
            request.gender = kGADGenderMale;
            break;
        case ANGenderFemale:
            request.gender = kGADGenderFemale;
            break;
        case ANGenderUnknown:
            request.gender = kGADGenderUnknown;
        default:
            break;
    }
    
    ANLocation *location = targetingParameters.location;
    if (location) {
        [request setLocationWithLatitude:location.latitude
                               longitude:location.longitude
                                accuracy:location.horizontalAccuracy];
    }
    
    GADExtras *extras = [[GADExtras alloc] init];
    NSMutableDictionary *extrasDictionary = [targetingParameters.customKeywords mutableCopy];
    if (!extrasDictionary) {
        extrasDictionary = [[NSMutableDictionary alloc] init];
    }
    NSString *age = targetingParameters.age;
    if (age) {
        [extrasDictionary setValue:age forKey:@"Age"];
    }
    extras.additionalParameters = extrasDictionary;
    [request registerAdNetworkExtras:extras];
    
    return request;
}

+ (ANAdResponseCode)responseCodeFromRequestError:(GADRequestError *)error {
    ANAdResponseCode code = ANAdResponseInternalError;
    
    switch (error.code) {
        case kGADErrorInvalidRequest:
            code = ANAdResponseInvalidRequest;
            break;
        case kGADErrorNoFill:
            code = ANAdResponseUnableToFill;
            break;
        case kGADErrorNetworkError:
            code = ANAdResponseNetworkError;
            break;
        case kGADErrorServerError:
            code = ANAdResponseNetworkError;
            break;
        case kGADErrorOSVersionTooLow:
            code = ANAdResponseInternalError;
            break;
        case kGADErrorTimeout:
            code = ANAdResponseNetworkError;
            break;
        case kGADErrorInterstitialAlreadyUsed:
            code = ANAdResponseInternalError;
            break;
        case kGADErrorMediationDataError:
            code = ANAdResponseInvalidRequest;
            break;
        case kGADErrorMediationAdapterError:
            code = ANAdResponseInternalError;
            break;
        case kGADErrorMediationNoFill:
            code = ANAdResponseUnableToFill;
            break;
        case kGADErrorMediationInvalidAdSize:
            code = ANAdResponseInvalidRequest;
            break;
        case kGADErrorInternalError:
            code = ANAdResponseInternalError;
            break;
        case kGADErrorInvalidArgument:
            code = ANAdResponseInvalidRequest;
            break;
        default:
            code = ANAdResponseInternalError;
            break;
    }
    return code;
}

@end