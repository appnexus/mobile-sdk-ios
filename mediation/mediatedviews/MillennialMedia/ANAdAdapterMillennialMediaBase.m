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

#import "ANAdAdapterMillennialMediaBase.h"

#import <MillennialMedia/MMAdView.h>

@implementation ANAdAdapterMillennialMediaBase
@synthesize delegate;

- (void) addMMNotificationObservers {
    // Notification will fire when an ad causes the application to terminate or enter the background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminateFromAd:)
                                                 name:MillennialMediaAdWillTerminateApplication
                                               object:nil];
    
    // Notification will fire when an ad is tapped.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adWasTapped:)
                                                 name:MillennialMediaAdWasTapped
                                               object:nil];
    
    // Notification will fire when an ad modal will appear.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adModalWillAppear:)
                                                 name:MillennialMediaAdModalWillAppear
                                               object:nil];
    
    // Notification will fire when an ad modal did appear.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adModalDidAppear:)
                                                 name:MillennialMediaAdModalDidAppear
                                               object:nil];
    
    // Notification will fire when an ad modal will dismiss.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adModalWillDismiss:)
                                                 name:MillennialMediaAdModalWillDismiss
                                               object:nil];
    
    // Notification will fire when an ad modal did dismiss.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adModalDidDismiss:)
                                                 name:MillennialMediaAdModalDidDismiss
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (MMRequest *)createRequestFromTargetingParameters:(ANTargetingParameters *)targetingParameters {
	MMRequest *request = [MMRequest request];
    
    ANGender gender = targetingParameters.gender;
    switch (gender) {
        case MALE:
            request.gender = MMGenderMale;
            break;
        case FEMALE:
            request.gender = MMGenderFemale;
            break;
        case UNKNOWN:
            request.gender = MMGenderOther;
        default:
            break;
    }
    
    ANLocation *location = targetingParameters.location;
    if (location) {
        request.location = [[CLLocation alloc]
                            initWithCoordinate:CLLocationCoordinate2DMake(location.latitude, location.longitude)
                            altitude:0
                            horizontalAccuracy:location.horizontalAccuracy
                            verticalAccuracy:0 course:0 speed:0
                            timestamp:location.timestamp];
    }
    
    NSString *age = targetingParameters.age;
    if (age) {
        NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber *ageNumber = [numberFormatter numberFromString:age];
        if (ageNumber) {
            request.age = ageNumber;
        }
    }
    
    request.keywords = [[targetingParameters.customKeywords allValues] copy];
    
    return request;
}

#pragma mark - Millennial Media Notification Methods

- (void)adWasTapped:(NSNotification *)notification {
    [self.delegate adWasClicked];
}

- (void)applicationWillTerminateFromAd:(NSNotification *)notification {
    [self.delegate willLeaveApplication];
}

- (void)adModalWillDismiss:(NSNotification *)notification {
    [self.delegate willCloseAd];
}

- (void)adModalDidDismiss:(NSNotification *)notification {
    [self.delegate didCloseAd];
}

- (void)adModalWillAppear:(NSNotification *)notification {
    [self.delegate willPresentAd];
}

- (void)adModalDidAppear:(NSNotification *)notification {
    [self.delegate didPresentAd];
}

@end
