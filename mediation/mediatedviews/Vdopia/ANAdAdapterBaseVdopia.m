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

#import "ANAdAdapterBaseVdopia.h"
#import "ANLogging.h"

@implementation ANAdAdapterBaseVdopia

@synthesize delegate = _delegate;

+ (LVDOAdRequest *)adRequestFromTargetingParameters:(ANTargetingParameters *)targetingParameters {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    LVDOAdRequest *adRequest = [LVDOAdRequest request];
    
    switch (targetingParameters.gender) {
        case ANGenderMale:
            adRequest.gender = LVDOGenderMale;
            break;
        case ANGenderFemale:
            adRequest.gender = LVDOGenderFemale;
            break;
        default:
            break;
    }
    
    if (targetingParameters.location) {
        [LVDOAdRequest setLocationWithLatitude:targetingParameters.location.latitude
                                     longitude:targetingParameters.location.longitude
                                      accuracy:targetingParameters.location.horizontalAccuracy];
    }
    
    if (targetingParameters.customKeywordsMapToStrings) {
        NSMutableArray *keywords = [[NSMutableArray alloc] init];
        [targetingParameters.customKeywordsMapToStrings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [keywords addObject:[obj description]];
        }];
        [LVDOAdRequest addKeyword:keywords];
    }
    
    return adRequest;
}

#pragma mark - LVDOAdViewDelegate

- (void)didFailToReceiveAdWithError:(int)errorCode {
    ANLogTrace(@"%@ %@; Received VDOPIA error code %d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), errorCode);
    ANAdResponseCode responseCode = ANAdResponseInternalError;
    switch (errorCode) {
        case vdoAdErrorIncorrectAdRecieved:
            responseCode = ANAdResponseInternalError;
            break;
        case vdoAdErrorunKnownAd:
            responseCode = ANAdResponseInternalError;
            break;
        case vdoAdErrorNoAd:
            responseCode = ANAdResponseUnableToFill;
            break;
        case vdoAdErrorInventoryUnavailable:
            responseCode = ANAdResponseUnableToFill;
            break;
        case vdoAdErrorNetworkFailure:
            responseCode = ANAdResponseNetworkError;
            break;
        default:
            break;
    }
    [self.delegate didFailToLoadAd:responseCode];
}

- (void)adViewOnClick {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate adWasClicked];
}

- (void)adViewWillLeaveApplication {
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate willLeaveApplication];
}

#pragma mark - LVDOAdViewDelegate Abstract Methods

- (void)adViewDidReceiveAd {

}

- (void)adViewWillPresentScreen {

}

- (void)adViewWillDismissScreen {

}

- (void)adViewDidDismissScreen {

}

@end
