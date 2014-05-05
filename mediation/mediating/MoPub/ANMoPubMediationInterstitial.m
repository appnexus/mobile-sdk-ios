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
#import ANMOPUBMEDIATIONINTERSTITIALHEADER
#import ANLOCATIONHEADER

@interface ANMOPUBMEDIATIONINTERSTITIAL ()

@property (nonatomic, retain) ANINTERSTITIALAD *interstitial;

@end

@implementation ANMOPUBMEDIATIONINTERSTITIAL

@synthesize interstitial = _interstitial;

#pragma mark - MPInterstitialCustomEvent Subclass Methods

// requires server to return info with "id" field, corresponding to AN placement id

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    NSLog(@"Requesting %@", NSStringFromClass([ANINTERSTITIALAD class]));
    
    id placementId = [info objectForKey:@"id"];
    
    // fail if any of the parameters is missing
    if (!placementId) {
        NSLog(@"Parameters from server were invalid");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }
    
    self.interstitial = [[ANINTERSTITIALAD alloc] initWithPlacementId:placementId];
    self.interstitial.delegate = self;
    
    if ([self.delegate location]) {
        CLLocation *mpLoc = [self.delegate location];
        ANLOCATION *anLoc = [ANLOCATION getLocationWithLatitude:(CGFloat)mpLoc.coordinate.latitude
                                                      longitude:(CGFloat)mpLoc.coordinate.longitude
                                                      timestamp:mpLoc.timestamp
                                             horizontalAccuracy:(CGFloat)mpLoc.horizontalAccuracy];
        [self.interstitial setLocation:anLoc];
    }
    
    NSMutableDictionary *customKeywords = [info mutableCopy];
    [self.interstitial setCustomKeywords:customKeywords];
    
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

- (void)adDidReceiveAd:(id<ANADPROTOCOL>)ad
{
    NSLog(@"Did load %@", NSStringFromClass([ANINTERSTITIALAD class]));
    if (self.delegate)
        [self.delegate interstitialCustomEvent:self didLoadAd:self.interstitial];
}

- (void)ad:(id<ANADPROTOCOL>)ad requestFailedWithError:(NSError *)error
{
    NSLog(@"Did fail to load %@", NSStringFromClass([ANINTERSTITIALAD class]));
    if (self.delegate)
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)adFailedToDisplay:(ANInterstitialAd *)ad
{
    NSLog(@"Failed to display %@", NSStringFromClass([ANINTERSTITIALAD class]));
    if (self.delegate) {
        [self.delegate interstitialCustomEventDidExpire:self];
    }
}

- (void)adWillPresent:(id<ANADPROTOCOL>)ad {
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)adDidPresent:(id<ANADPROTOCOL>)ad {
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)adWillClose:(id<ANADPROTOCOL>)ad {
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)adDidClose:(id<ANADPROTOCOL>)ad {
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)adWasClicked:(id<ANADPROTOCOL>)ad {
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

@end