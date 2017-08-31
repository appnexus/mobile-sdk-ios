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

#import "ANLogging.h"
#import "ANLocation.h"

@interface ANMoPubMediationInterstitial ()

@property (nonatomic, retain) ANInterstitialAd *interstitial;

@end

@implementation ANMoPubMediationInterstitial

@synthesize interstitial = _interstitial;

#pragma mark - MPInterstitialCustomEvent Subclass Methods

// requires server to return info with "id" field, corresponding to AN placement id

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    ANLogDebug(@"Requesting %@", NSStringFromClass([ANInterstitialAd class]));
    
    id placementId = [info objectForKey:@"id"];
    
    // fail if any of the parameters is missing
    if (!placementId) {
        ANLogDebug(@"Parameters from server were invalid");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }
    
    self.interstitial = [[ANInterstitialAd alloc] initWithPlacementId:placementId];
    self.interstitial.delegate = self;
    
    if ([self.delegate location]) {
        CLLocation *mpLoc = [self.delegate location];
        ANLocation *anLoc = [ANLocation getLocationWithLatitude:(CGFloat)mpLoc.coordinate.latitude
                                                      longitude:(CGFloat)mpLoc.coordinate.longitude
                                                      timestamp:mpLoc.timestamp
                                             horizontalAccuracy:(CGFloat)mpLoc.horizontalAccuracy];
        [self.interstitial setLocation:anLoc];
    }
    
    NSMutableDictionary *customKeywordsMapToStrings = [info mutableCopy];
    [self.interstitial setCustomKeywords:customKeywordsMapToStrings];
    
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
    ANLogDebug(@"Did load %@", NSStringFromClass([ANInterstitialAd class]));
    if (self.delegate)
        [self.delegate interstitialCustomEvent:self didLoadAd:self.interstitial];
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    ANLogDebug(@"Did fail to load %@", NSStringFromClass([ANInterstitialAd class]));
    if (self.delegate)
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)adFailedToDisplay:(ANInterstitialAd *)ad
{
    ANLogDebug(@"Failed to display %@", NSStringFromClass([ANInterstitialAd class]));
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
