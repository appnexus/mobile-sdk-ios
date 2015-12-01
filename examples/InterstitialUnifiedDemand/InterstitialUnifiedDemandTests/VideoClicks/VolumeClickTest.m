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

#import "VolumeClickTest.h"
#import <KIF/KIFTestCase.h>
#import "ANInterstitialAd.h"

@interface VolumeClickTest()<ANVideoAdDelegate, ANInterstitialAdDelegate>{
    ANInterstitialAd *interstitialAdView;
}

@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic) int tapsRequired;

@end

@implementation VolumeClickTest

- (void)setUp{
    UIView *view = [tester waitForViewWithAccessibilityLabel:@"interstitial"];
    
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"ANInterstitialAd")]) {
            break;
        }
    }
    
    int breakCounter = 10;
    
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

- (void) test1UnmuteVolume{
    
    [tester tapViewWithAccessibilityLabel:@"volume button"];
    
    self.expectation = [self expectationWithDescription:@"Waiting for delegates to be fired."];
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.description);
        }
    }];
    
}

- (void) test2MuteVolume{
    
    [tester tapViewWithAccessibilityLabel:@"volume button"];
    
    self.expectation = [self expectationWithDescription:@"Waiting for delegates to be fired."];
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.description);
        }
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

- (void)adMuted:(BOOL)isMuted withAd:(id<ANAdProtocol>)ad{
    NSLog(@"Test: Ad was %@", isMuted?@"Muted":@"Unmuted");
    XCTAssertTrue(YES, @"AsMuted delegate fired.");
    [self.expectation fulfill];
}

@end
