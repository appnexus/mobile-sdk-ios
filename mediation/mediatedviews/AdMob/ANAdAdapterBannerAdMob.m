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

#import "ANAdAdapterBannerAdMob.h"

@interface ANAdAdapterBannerAdMob ()
@property (nonatomic, readwrite, strong) GADBannerView *bannerView;
@end

@implementation ANAdAdapterBannerAdMob
@synthesize delegate;

#pragma mark ANCustomAdapterBanner

- (void)requestBannerAdWithSize:(CGSize)size
                serverParameter:(NSString *)parameterString
                       adUnitId:(NSString *)idString
                       location:(ANLocation *)location
             rootViewController:(UIViewController *)rootViewController
{
    NSLog(@"Requesting AdMob banner with size: %fx%f", size.width, size.height);
	GADAdSize gadAdSize = GADAdSizeFromCGSize(size);
	self.bannerView = [[GADBannerView alloc] initWithAdSize:gadAdSize];
	
	self.bannerView.adUnitID = idString;
	
	self.bannerView.rootViewController = rootViewController;
	self.bannerView.delegate = self;
	GADRequest *request = [GADRequest request];
    
    if (location) {
        [request setLocationWithLatitude:location.latitude
                               longitude:location.longitude
                                accuracy:location.horizontalAccuracy];
    }
    
	[self.bannerView loadRequest:request];
}

#pragma mark GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    NSLog(@"AdMob banner did load");
	[self.delegate didLoadBannerAd:view];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"AdMob banner failed to load with error: %@", error);
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
    
 	[self.delegate didFailToLoadAd:code];
}

- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    [self.delegate willPresentAd];
}

- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    [self.delegate willCloseAd];
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    [self.delegate didCloseAd];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    [self.delegate willLeaveApplication];
}

- (void)dealloc
{
    NSLog(@"AdMob banner being destroyed");
	self.bannerView.delegate = nil;
	self.bannerView = nil;
}

@end
