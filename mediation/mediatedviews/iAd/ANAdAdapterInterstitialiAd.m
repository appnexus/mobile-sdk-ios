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

#import "ANBasicConfig.h"
#import ANADADAPTERINTERSTITIALIADHEADER

@interface ANADADAPTERINTERSTITIALIAD ()
@property (nonatomic, readwrite, strong) id interstitialAd;
@end

@implementation ANADADAPTERINTERSTITIALIAD
@synthesize delegate;

#pragma mark ANCustomAdapterInterstitial

// iAd doesn't have use placement id
- (void)requestInterstitialAdWithParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)idString
                       targetingParameters:(ANTARGETINGPARAMETERS *)targetingParameters
{
    NSLog(@"Requesting iAd interstitial");
    Class iAdInterstitialClass = NSClassFromString(@"ADInterstitialAd");
    if (iAdInterstitialClass) {
        self.interstitialAd = [[iAdInterstitialClass alloc] init];
        [self.interstitialAd setDelegate:self];
    } else {
        [self.delegate didFailToLoadAd:(ANADRESPONSECODE)ANAdResponseMediatedSDKUnavailable];
    }
}

- (void)presentFromViewController:(UIViewController *)viewController
{
    ADInterstitialAd *iAd = (ADInterstitialAd *)self.interstitialAd;
    if (!iAd.loaded) {
        NSLog(@"iAd interstitial unavailable");
        [self.delegate failedToDisplayAd];
        return;
    }
    
    NSLog(@"Showing iAd interstitial");
    [self.delegate willPresentAd];
	[self.interstitialAd presentFromViewController:viewController];
    [self.delegate didPresentAd];
}

- (BOOL)isReady {
    ADInterstitialAd *iAd = (ADInterstitialAd *)self.interstitialAd;
    return iAd.loaded;
}

#pragma mark ADInterstitialAdDelegate

- (void)interstitialAdWillLoad:(ADInterstitialAd *)interstitialAd
{
    NSLog(@"iAd interstitial will load");
}

- (void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd
{
    NSLog(@"iAd interstitial did load");
    [self.delegate didLoadInterstitialAd:self];
}

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd
{
    NSLog(@"iAd interstitial did unload");
    [self.delegate failedToDisplayAd];
}

- (BOOL)interstitialAdActionShouldBegin:(ADInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave {
    [self.delegate adWasClicked];
    if (willLeave) {
        NSLog(@"iAd interstitial will leave application");
        [self.delegate willLeaveApplication];
    }
    
    return YES;
}

- (void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd {
    NSLog(@"iAd interstitial action did finish");
    [self.delegate willCloseAd];
    [self.delegate didCloseAd];
}

- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    NSLog(@"iAd banner interstitial to load with error: %@", [error localizedDescription]);
    ANAdResponseCode code = ANAdResponseInternalError;
    
    switch (error.code) {
        case ADErrorUnknown:
            code = ANAdResponseInternalError;
            break;
        case ADErrorServerFailure:
            code = ANAdResponseNetworkError;
            break;
        case ADErrorLoadingThrottled:
            code = ANAdResponseNetworkError;
            break;
        case ADErrorInventoryUnavailable:
            code = ANAdResponseUnableToFill;
            break;
        case ADErrorConfigurationError:
            code = ANAdResponseInternalError;
            break;
        case ADErrorBannerVisibleWithoutContent:
            code = ANAdResponseInternalError;
            break;
        case ADErrorApplicationInactive:
            code = ANAdResponseInternalError;
            break;
        default:
            code = ANAdResponseInternalError;
            break;
    }
    
	[self.delegate didFailToLoadAd:(ANADRESPONSECODE)code];
}

@end
