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

#import "ANGADCustomInterstitialAd.h"

@interface ANGADCustomInterstitialAd ()
@property (nonatomic, readwrite, strong) ANInterstitialAd *interstitialAd;
@end

@implementation ANGADCustomInterstitialAd
@synthesize interstitialAd;
@synthesize delegate;

#pragma mark -
#pragma mark GADCustomEventInterstitial

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter label:(NSString *)serverLabel request:(GADCustomEventRequest *)customEventRequest
{
	self.interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:serverParameter];
    self.interstitialAd.delegate = self;
	self.interstitialAd.shouldServePublicServiceAnnouncements = NO;
    
    if ([customEventRequest userHasLocation]) {
        ANLocation *loc = [ANLocation getLocationWithLatitude:[customEventRequest userLatitude]
                                                    longitude:[customEventRequest userLongitude]
                                                    timestamp:nil
                                           horizontalAccuracy:[customEventRequest userLocationAccuracyInMeters]];
        [self.interstitialAd setLocation:loc];
    }
    
    NSMutableDictionary *customKeywords = [[customEventRequest additionalParameters] mutableCopy];
    [customKeywords enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.interstitialAd addCustomKeywordWithKey:key value:obj];
    } ];
    
    [self.interstitialAd loadAd];
}

#pragma mark -
#pragma mark ANAdDelegate

- (void)adDidReceiveAd:(id)ad
{
	[self.delegate customEventInterstitialDidReceiveAd:self];
}

- (void)ad:(id)ad requestFailedWithError:(NSError *)error
{
    [self.delegate customEventInterstitial:self didFailAd:error];
}

#pragma mark -
#pragma mark ANInterstitialAdDelegate

- (void)adFailedToDisplay:(ANInterstitialAd *)ad {
    
}

- (void)adWillPresent:(ANInterstitialAd *)ad {

}

- (void)adWillClose:(ANInterstitialAd *)ad {
    [self.delegate customEventInterstitialWillDismiss:self];
}

- (void)adDidClose:(ANInterstitialAd *)adView {
    [self.delegate customEventInterstitialDidDismiss:self];
}

- (void)adWillLeaveApplication:(id)ad {
    [self.delegate customEventInterstitialWillLeaveApplication:self];
}

#pragma mark -
#pragma mark GADCustomEventInterstitial

- (void)presentFromRootViewController:(UIViewController *)rootViewController
{
    if (![self.interstitialAd isReady]) {
        NSLog(@"Could not display interstitial ad, no ad ready");
        return;
    }
    [self.delegate customEventInterstitialWillPresent:self];
    [self.interstitialAd displayAdFromViewController:rootViewController];
}

@end
