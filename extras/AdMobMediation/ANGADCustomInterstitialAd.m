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

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter label:(NSString *)serverLabel request:(GADCustomEventRequest *)request
{
	self.interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:serverParameter];
    self.interstitialAd.delegate = self;
	self.interstitialAd.shouldServePublicServiceAnnouncements = NO;
    [self.interstitialAd loadAd];
}

#pragma mark -
#pragma mark ANAdDelegate

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad
{
	[self.delegate customEventInterstitial:self didReceiveAd:ad];
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    [self.delegate customEventInterstitial:self didFailAd:error];
}

#pragma mark -
#pragma mark ANInterstitialAdDelegate

- (void)adWillPresent:(ANInterstitialAd *)ad
{
	[self.delegate customEventInterstitialWillPresent:self];
}

- (void)adNoAdToShow:(ANInterstitialAd *)adView
{
    
}

- (void)adWillClose:(ANInterstitialAd *)ad
{
	[self.delegate customEventInterstitialWillDismiss:self];
}

- (void)adDidClose:(ANInterstitialAd *)adView
{
    [self.delegate customEventInterstitialDidDismiss:self];
}

#pragma mark -
#pragma mark GADCustomEventInterstitial

- (void)presentFromRootViewController:(UIViewController *)rootViewController
{
	[self.interstitialAd displayAdFromViewController:rootViewController];
}

@end
