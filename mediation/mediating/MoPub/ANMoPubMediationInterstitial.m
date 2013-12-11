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

#import "ANMoPubMediationInterstitial.h"
#import "ANInterstitialAd.h"

@interface ANMoPubMediationInterstitial ()

@property (nonatomic, retain) ANInterstitialAd *interstitial;

@end

@implementation ANMoPubMediationInterstitial

@synthesize interstitial = _interstitial;

#pragma mark - MPInterstitialCustomEvent Subclass Methods

// requires server to return info with "id" field, corresponding to AN placement id

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    NSLog(@"Requesting AN Interstitial");
    
    id placementId = [info objectForKey:@"id"];
    
    // fail if any of the parameters is missing
    if (!placementId) {
        NSLog(@"Parameters from server were invalid");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }
    
    self.interstitial = [[ANInterstitialAd alloc] initWithPlacementId:placementId];
    self.interstitial.delegate = self;
    
    [self.interstitial loadAd];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.interstitial displayAdFromViewController:rootViewController];
}

- (void)dealloc
{
    self.interstitial.delegate = nil;
    self.interstitial = nil;
}

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad
{
    NSLog(@"Did load AN Interstitial");
    if (self.delegate)
        [self.delegate interstitialCustomEvent:self didLoadAd:self.interstitial];
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    NSLog(@"Did fail to load AN Interstitial");
    if (self.delegate)
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)adFailedToDisplay:(ANInterstitialAd *)ad
{
    NSLog(@"Failed to display AN Interstitial");
    if (self.delegate) {
        [self.delegate interstitialCustomEventDidExpire:self];
    }
}

- (void)adWillPresent:(id<ANAdProtocol>)ad {
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)adDidPresent:(id<ANAdProtocol>)ad {
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)adWillClose:(id<ANAdProtocol>)ad {
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)adDidClose:(id<ANAdProtocol>)ad {
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)adWasClicked:(id<ANAdProtocol>)ad {
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

@end