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


#import "ANGADCustomBannerAd.h"
#import "ANBannerAdView.h"
#import "ANLocation.h"

@interface ANGADCustomBannerAd ()
@property (nonatomic, readwrite, strong) ANBannerAdView *bannerAdView;
@end

@implementation ANGADCustomBannerAd
@synthesize delegate;
@synthesize bannerAdView;

#pragma mark -
#pragma mark GADCustomEventBanner

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString *)serverParameter
                  label:(NSString *)serverLabel
                request:(GADCustomEventRequest *)customEventRequest
{    
    // Create an ad request using custom targeting options from the custom event
    // request.
    CGRect frame = CGRectMake(0, 0, adSize.size.width, adSize.size.height);
    self.bannerAdView = [ANBannerAdView adViewWithFrame:frame placementId:serverParameter adSize:adSize.size];
    
    self.bannerAdView.rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    self.bannerAdView.delegate = self;
    self.bannerAdView.opensInNativeBrowser = YES;
	self.bannerAdView.shouldServePublicServiceAnnouncements = NO;
    
    if ([customEventRequest userHasLocation]) {
        ANLocation *loc = [ANLocation getLocationWithLatitude:[customEventRequest userLatitude]
                                                    longitude:[customEventRequest userLongitude]
                                                    timestamp:nil
                                           horizontalAccuracy:[customEventRequest userLocationAccuracyInMeters]];
        [self.bannerAdView setLocation:loc];
    }
    
    GADGender gadGender = [customEventRequest userGender];
    ANGender anGender = UNKNOWN;
    if (gadGender != kGADGenderUnknown) {
        if (gadGender == kGADGenderMale) anGender = MALE;
        else if (gadGender == kGADGenderFemale) anGender = FEMALE;
    }
    [self.bannerAdView setGender:anGender];
    
    NSDate *userBirthday = [customEventRequest userBirthday];
    if (userBirthday) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy"];
        NSString *birthYear = [dateFormatter stringFromDate:userBirthday];
        [self.bannerAdView setAge:birthYear];
    }
    
    NSMutableDictionary *customKeywords = [[customEventRequest additionalParameters] mutableCopy];
    [self.bannerAdView setCustomKeywords:customKeywords];
    
    [self.bannerAdView loadAd];
}

#pragma mark ANAdViewDelegate

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad
{
    [self.delegate customEventBanner:self didReceiveAd:(ANBannerAdView *)ad];
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    [self.delegate customEventBanner:self didFailAd:error];
}

- (void)adWasClicked:(id<ANAdProtocol>)ad {
    [self.delegate customEventBanner:self clickDidOccurInAd:self.bannerAdView];
}

- (void)adWillPresent:(id<ANAdProtocol>)ad {
    [self.delegate customEventBannerWillPresentModal:self];
}

- (void)adWillClose:(id<ANAdProtocol>)ad {
    [self.delegate customEventBannerWillDismissModal:self];
}

- (void)adDidClose:(id<ANAdProtocol>)ad {
    [self.delegate customEventBannerDidDismissModal:self];
}

- (void)adWillLeaveApplication:(id<ANAdProtocol>)ad {
    [self.delegate customEventBannerWillLeaveApplication:self];
}

@end
