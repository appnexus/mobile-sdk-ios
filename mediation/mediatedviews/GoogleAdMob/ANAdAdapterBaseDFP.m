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
#import "ANGoogleMediationSettings.h"


@implementation ANAdAdapterBaseDFP

+ (GADRequest *)googleAdMobRequestFromTargetingParameters:(ANTargetingParameters *)targetingParameters rootViewController: (UIViewController *)rootViewController {
    GADRequest *request = [GADRequest request];
    return  [[self class] completeAdRequest:request fromTargetingParameters:targetingParameters rootViewController:rootViewController];
}

+ (GAMRequest *)dfpRequestFromTargetingParameters:(ANTargetingParameters *)targetingParameters rootViewController: (UIViewController *)rootViewController
{
    GAMRequest  *dfpRequest  = [GAMRequest request];
    return  (GAMRequest *)[[self class] completeAdRequest:dfpRequest fromTargetingParameters:targetingParameters rootViewController:rootViewController];
}

+ (GADRequest *)completeAdRequest: (GADRequest *)gadRequest
          fromTargetingParameters: (ANTargetingParameters *)targetingParameters
               rootViewController: (UIViewController *)rootViewController
{
    if ([ANGoogleMediationSettings getIPadMultiSceneSupport] && rootViewController) {
        if (@available(iOS 13.0, *)) {
            gadRequest.scene = rootViewController.view.window.windowScene;
        }
    }
    NSString *content_url = targetingParameters.customKeywords[@"content_url"];
    if ([content_url length] > 0)
    {
        gadRequest.contentURL = content_url;

        NSMutableDictionary *dictWithoutContentUrl = [targetingParameters.customKeywords mutableCopy];
        [dictWithoutContentUrl removeObjectForKey:@"content_url"];
        targetingParameters.customKeywords = dictWithoutContentUrl;
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
    [gadRequest registerAdNetworkExtras:extras];

    return gadRequest;
}


+ (ANAdResponseCode *)responseCodeFromRequestError:(NSError *)error {
    ANAdResponseCode *code = ANAdResponseCode.INTERNAL_ERROR;
    
    switch (error.code) {
        case GADErrorInvalidRequest:
            code = ANAdResponseCode.INVALID_REQUEST;
            break;
        case GADErrorNoFill:
            code = ANAdResponseCode.UNABLE_TO_FILL;
            break;
        case GADErrorNetworkError:
            code = ANAdResponseCode.NETWORK_ERROR;
            break;
        case GADErrorServerError:
            code = ANAdResponseCode.NETWORK_ERROR;
            break;
        case GADErrorOSVersionTooLow:
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
        case GADErrorTimeout:
            code = ANAdResponseCode.NETWORK_ERROR;
            break;
        case GADErrorAdAlreadyUsed:
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
        case GADErrorMediationDataError:
            code = ANAdResponseCode.INVALID_REQUEST;
            break;
        case GADErrorMediationAdapterError:
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
        case GADErrorMediationInvalidAdSize:
            code = ANAdResponseCode.INVALID_REQUEST;
            break;
        case GADErrorInternalError:
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
        case GADErrorInvalidArgument:
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
        case GADErrorReceivedInvalidResponse:
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
        case GADErrorMediationNoFill:
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
        case GADErrorApplicationIdentifierMissing:
            code = ANAdResponseCode.INVALID_REQUEST;
            break;
        default:
            code = ANAdResponseCode.INTERNAL_ERROR;
            break;
    }
    return code;
}

@end
