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
#import ANGADCUSTOMINTERSTITIALADHEADER
#import ANLOCATIONHEADER

@interface ANGADCUSTOMINTERSTITIALAD ()
@property (nonatomic, readwrite, strong) ANINTERSTITIALAD *interstitialAd;
@end

@implementation ANGADCUSTOMINTERSTITIALAD
@synthesize interstitialAd;
@synthesize delegate;

#pragma mark -
#pragma mark GADCustomEventInterstitial

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter label:(NSString *)serverLabel request:(GADCustomEventRequest *)customEventRequest
{
	self.interstitialAd = [[ANINTERSTITIALAD alloc] initWithPlacementId:serverParameter];
    self.interstitialAd.delegate = self;
	self.interstitialAd.shouldServePublicServiceAnnouncements = NO;
    
    if ([customEventRequest userHasLocation]) {
        ANLOCATION *loc = [ANLOCATION getLocationWithLatitude:[customEventRequest userLatitude]
                                                    longitude:[customEventRequest userLongitude]
                                                    timestamp:nil
                                           horizontalAccuracy:[customEventRequest userLocationAccuracyInMeters]];
        [self.interstitialAd setLocation:loc];
    }
    
    GADGender gadGender = [customEventRequest userGender];
    ANGENDER anGender = (ANGENDER)UNKNOWN;
    if (gadGender != kGADGenderUnknown) {
        if (gadGender == kGADGenderMale) anGender = (ANGENDER)MALE;
        else if (gadGender == kGADGenderFemale) anGender = (ANGENDER)FEMALE;
    }
    [self.interstitialAd setGender:anGender];
    
    NSDate *userBirthday = [customEventRequest userBirthday];
    if (userBirthday) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy"];
        NSString *birthYear = [dateFormatter stringFromDate:userBirthday];
        [self.interstitialAd setAge:birthYear];
    }
    
    NSMutableDictionary *customKeywords = [[customEventRequest additionalParameters] mutableCopy];
    [self.interstitialAd setCustomKeywords:customKeywords];
    
    [self.interstitialAd loadAd];
}

#pragma mark -
#pragma mark ANAdDelegate

- (void)adDidReceiveAd:(id<ANADPROTOCOL>)ad
{
	[self.delegate customEventInterstitial:self didReceiveAd:ad];
}

- (void)ad:(id<ANADPROTOCOL>)ad requestFailedWithError:(NSError *)error
{
    [self.delegate customEventInterstitial:self didFailAd:error];
}

#pragma mark -
#pragma mark ANINTERSTITIALADDelegate

- (void)adFailedToDisplay:(ANINTERSTITIALAD *)ad {
}

- (void)adWillPresent:(ANINTERSTITIALAD *)ad {
    [self.delegate customEventInterstitialWillPresent:self];
}

- (void)adWillClose:(ANINTERSTITIALAD *)ad {
    [self.delegate customEventInterstitialWillDismiss:self];
}

- (void)adDidClose:(ANINTERSTITIALAD *)adView {
    [self.delegate customEventInterstitialDidDismiss:self];
}

- (void)adWillLeaveApplication:(id<ANADPROTOCOL>)ad {
    [self.delegate customEventInterstitialWillLeaveApplication:self];
}

#pragma mark -
#pragma mark GADCustomEventInterstitial

- (void)presentFromRootViewController:(UIViewController *)rootViewController
{
	[self.interstitialAd displayAdFromViewController:rootViewController];
}

@end
