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

#import "ANAdAdapterInterstitialiAd.h"
#import "ANLogging.h"

@interface ANAdAdapterInterstitialiAd ()
@property (nonatomic, readwrite, strong) id interstitialAd;
@end

@implementation ANAdAdapterInterstitialiAd
@synthesize delegate;
@synthesize responseURLString;

#pragma mark ANCustomAdapterInterstitial

// iAd doesn't have use placement id
- (void)requestInterstitialAdWithParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)idString
                                  location:(ANLocation *)location
{
    ANLogDebug(@"Requesting iAd interstitial");
	Class iAdClass = NSClassFromString(@"ADInterstitialAd");

	if (iAdClass)
	{
		self.interstitialAd = [[iAdClass alloc] init];
		[self.interstitialAd setDelegate:self];
	}
	else
	{
		[self.delegate adapterInterstitial:self didFailToReceiveInterstitialAd:ANAdResponseMediatedSDKUnavailable];
	}
}

- (void)presentFromViewController:(UIViewController *)viewController
{
    ANLogDebug(@"Showing iAd interstitial");
	[self.interstitialAd presentFromViewController:viewController];
}

#pragma mark ADInterstitialAdDelegate
- (void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd
{
    ANLogDebug(@"iAd interstitial did load");
	[self.delegate adapterInterstitial:self didLoadInterstitialAd:interstitialAd];
}

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd
{
    ANLogDebug(@"iAd interstitial did unload");
    [self.delegate adapterInterstitial:self didClose:interstitialAd];
	
}
- (BOOL)interstitialAdActionShouldBegin:(ADInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave {
    if (willLeave) {
        ANLogDebug(@"iAd interstitial will leave application");
        [self.delegate adapterInterstitial:self willLeaveApplication:interstitialAd];
    } else {
        ANLogDebug(@"iAd interstitial will present");
        [self.delegate adapterInterstitial:self willPresent:interstitialAd];
    }
    return YES;
}

- (void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd {
    ANLogDebug(@"iAd interstitial action did finish");
    [self.delegate adapterInterstitial:self didClose:interstitialAd];
}

- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
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
    
	[self.delegate adapterInterstitial:self didFailToReceiveInterstitialAd:code];
}

@end
