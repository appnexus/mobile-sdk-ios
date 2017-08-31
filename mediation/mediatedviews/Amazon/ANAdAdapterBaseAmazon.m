/*   Copyright 2014 APPNEXUS INC
 
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

#import "ANAdAdapterBaseAmazon.h"

#import <AmazonAd/AmazonAdOptions.h>
#import <AmazonAd/AmazonAdRegistration.h>
#import <AmazonAd/AmazonAdError.h>
#import <AmazonAd/AmazonAdOptions.h>

#import "ANLogging.h"

static NSString *const kANAdAdapterBaseAmazonAgeKey = @"age";

static NSString *const kANAdAdapterBaseAmazonGenderKey = @"gender";
static NSString *const kANAdAdapterBaseAmazonGenderMaleValue = @"m";
static NSString *const kANAdAdapterBaseAmazonGenderFemaleValue = @"f";

@implementation ANAdAdapterBaseAmazon

@synthesize delegate = _delegate;

+ (void)setAmazonAppKey:(NSString *)appKey {
    [[AmazonAdRegistration sharedRegistration] setAppKey:appKey];
}

- (AmazonAdOptions *)adOptionsForTargetingParameters:(ANTargetingParameters *)targetingParameters {
    AmazonAdOptions *options = [AmazonAdOptions options];
    [targetingParameters.customKeywordsMapToStrings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [options setAdvancedOption:[obj description]
                            forKey:[key description]];
    }];
    if (targetingParameters.location) {
        options.usesGeoLocation = YES;
    }
    switch (targetingParameters.gender) {
        case ANGenderMale:
            [options setAdvancedOption:kANAdAdapterBaseAmazonGenderMaleValue
                                forKey:kANAdAdapterBaseAmazonGenderKey];
            break;
        case ANGenderFemale:
            [options setAdvancedOption:kANAdAdapterBaseAmazonGenderFemaleValue
                                forKey:kANAdAdapterBaseAmazonGenderKey];
            break;
        default:
            break;
    }
    if (targetingParameters.age) {
        [options setAdvancedOption:targetingParameters.age
                            forKey:kANAdAdapterBaseAmazonAgeKey];
    }
    return options;
}

- (void)handleAmazonError:(AmazonAdError *)amazonError {
    ANLogDebug(@"Received error from Amazon with description: %@", amazonError.description);
    ANAdResponseCode responseCode = ANAdResponseInternalError;
    switch (amazonError.errorCode) {
        case AmazonAdErrorRequest:
            responseCode = ANAdResponseInvalidRequest;
            break;
        case AmazonAdErrorNoFill:
            responseCode = ANAdResponseUnableToFill;
            break;
        case AmazonAdErrorInternalServer:
            responseCode = ANAdResponseInternalError;
            break;
        case AmazonAdErrorNetworkConnection:
            responseCode = ANAdResponseNetworkError;
            break;
        case AmazonAdErrorReserved:
            responseCode = ANAdResponseInternalError;
            break;
        default:
            break;
    }
    
    [self.delegate didFailToLoadAd:responseCode];
}

@end
