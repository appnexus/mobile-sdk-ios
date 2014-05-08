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

#import "ANAdAdapterInterstitialAdMob.h"

@interface ANAdAdapterInterstitialAdMob ()

@property (nonatomic, readwrite, strong) GADInterstitial *interstitialAd;

@end

@implementation ANAdAdapterInterstitialAdMob
@synthesize delegate;

#pragma mark ANCustomAdapterInterstitial

- (void)requestInterstitialAdWithParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)idString
                       targetingParameters:(ANTARGETINGPARAMETERS *)targetingParameters
{
    NSLog(@"Requesting AdMob interstitial");
	self.interstitialAd = [[GADInterstitial alloc] init];
	self.interstitialAd.adUnitID = idString;
	self.interstitialAd.delegate = self;
    [self.interstitialAd loadRequest:
     [self createRequestFromTargetingParameters:targetingParameters]];
}

- (void)presentFromViewController:(UIViewController *)viewController
{
    if (!self.interstitialAd.isReady || self.interstitialAd.hasBeenUsed) {
        NSLog(@"AdMob interstitial was unavailable");
        [self.delegate failedToDisplayAd];
        return;
    }

    NSLog(@"Showing AdMob interstitial");
	[self.interstitialAd presentFromRootViewController:viewController];
}

- (BOOL)isReady {
    return self.interstitialAd.isReady;
}

- (GADRequest *)createRequestFromTargetingParameters:(ANTARGETINGPARAMETERS *)targetingParameters {
	GADRequest *request = [GADRequest request];
    
    ANGENDER gender = targetingParameters.gender;
    switch (gender) {
        case MALE:
            request.gender = kGADGenderMale;
            break;
        case FEMALE:
            request.gender = kGADGenderFemale;
            break;
        case UNKNOWN:
            request.gender = kGADGenderUnknown;
        default:
            break;
    }
    
    ANLOCATION *location = targetingParameters.location;
    if (location) {
        [request setLocationWithLatitude:location.latitude
                               longitude:location.longitude
                                accuracy:location.horizontalAccuracy];
    }
    
    request.additionalParameters = targetingParameters.customKeywords;
    
    return request;
}

#pragma mark GADInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    NSLog(@"AdMob interstitial did load");
	[self.delegate didLoadInterstitialAd:self];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"AdMob interstitial failed to load with error: %@", error);
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
        default:
            code = ANAdResponseInternalError;
            break;
    }
    
    [self.delegate didFailToLoadAd:(ANADRESPONSECODE)code];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    [self.delegate willPresentAd];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    [self.delegate willCloseAd];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    [self.delegate didCloseAd];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    [self.delegate willLeaveApplication];
}

@end
