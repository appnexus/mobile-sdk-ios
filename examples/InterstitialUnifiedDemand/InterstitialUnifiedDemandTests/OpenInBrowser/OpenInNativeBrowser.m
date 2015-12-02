/* Copyright 2015 APPNEXUS INC
 
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

#define interstitial [[[UIApplication sharedApplication] keyWindow] accessibilityElementWithLabel:@"interstitial"]
#define player [[[UIApplication sharedApplication] keyWindow] accessibilityElementWithLabel:@"player"]

#import "OpenInNativeBrowser.h"
#import <KIF/KIFTestCase.h>
#import "ANInterstitialAd.h"

@interface OpenInNativeBrowser()<ANVideoAdDelegate, ANInterstitialAdDelegate>{
    ANInterstitialAd *interstitialAdView;
    BOOL isDelegateFired;
}

@property (nonatomic, strong) XCTestExpectation *expectation;

@end

@implementation OpenInNativeBrowser

- (void)setUp{
    
    isDelegateFired = NO;
    [tester waitForViewWithAccessibilityLabel:@"interstitial"];
    
    int breakCounter = 5;
    
    while (interstitial && breakCounter--) {
        [self performClickOnInterstitial];
        [tester waitForTimeInterval:2.0];
    }
    
    [self setupDelegatesForVideo];
    if (!interstitial) {
        [tester waitForViewWithAccessibilityLabel:@"player"];
        if (!player) {
            NSLog(@"Test: Not able to load the video.");
        }
    }
}

- (void) test1OpenClickInNativeBrowser{
    
    self.expectation = [self expectationWithDescription:@"Waiting for delegates to fire."];
    
    [tester tapViewWithAccessibilityLabel:@"player"];

    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"isDelegateFired: %i", isDelegateFired);
        XCTAssertTrue(isDelegateFired, @"Click opened in In-App Browser.");
    }];
    
}

-(void) setupDelegatesForVideo{
    
    UIViewController *controller = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if (controller) {
        SEL aSelector = NSSelectorFromString(@"interstitialAd");
        interstitialAdView = (ANInterstitialAd *)[controller performSelector:aSelector];
        interstitialAdView.delegate = self;
        interstitialAdView.videoAdDelegate = self;
    }
}

- (void) performClickOnInterstitial{
    if (interstitial) {
        [tester tapViewWithAccessibilityLabel:@"interstitial"];
    }
}

- (void)adWillLeaveApplication:(id<ANAdProtocol>)ad{
    NSLog(@"Test: ad will leave application");
    isDelegateFired = YES;
    [self.expectation fulfill];
}

@end
