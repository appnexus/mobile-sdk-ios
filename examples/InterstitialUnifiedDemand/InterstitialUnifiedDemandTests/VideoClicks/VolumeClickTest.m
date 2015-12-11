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

@interface VolumeClickTest()<ANVideoAdDelegate, ANInterstitialAdDelegate>
@end

@implementation VolumeClickTest

static BOOL isVolumeButtonClicked;

static ANInterstitialAd *interstitialAdView;
static XCTestExpectation *expectation;

+ (void)setUp{
    [super setUp];
    isVolumeButtonClicked = NO;
}

+ (void)tearDown{
    [super tearDown];
    UIViewController *controller = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    UIViewController *visibleViewController = controller.navigationController.visibleViewController;
    while (visibleViewController) {
        [visibleViewController dismissViewControllerAnimated:YES completion:nil];
        visibleViewController = controller.navigationController.visibleViewController;
    }
    interstitialAdView.delegate = nil;
    interstitialAdView.videoAdDelegate = nil;
    interstitialAdView = nil;
}

- (void)tearDown{
    [super tearDown];
    isVolumeButtonClicked = NO;
    expectation = nil;
}

- (void)test1PrepareForVolumeTesting{
    [tester waitForViewWithAccessibilityLabel:@"interstitial"];
    [self setupDelegatesForVideo];

    int breakCounter = 5;
    
    while (interstitial && breakCounter--) {
        [self performClickOnInterstitial];
        [tester waitForTimeInterval:3.0];
    }
    

    if (!interstitial) {
        [tester waitForViewWithAccessibilityLabel:@"player"];
        if (!player) {
            NSLog(@"Test: Not able to load the video.");
        }
    }
    
    XCTAssertNil(interstitial, @"Failed to load video.");
}

- (void) test2UnmuteVolume{
    
    XCTAssertNil(interstitial, @"Failed to load video.");

    expectation = [self expectationWithDescription:@"Waiting to unmute volume."];
    
    [tester waitForViewWithAccessibilityLabel:@"player"];
    [self tapOnVolumeButton];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
    XCTAssertTrue(isVolumeButtonClicked, @"failed to unmute volume.");
}

- (void) tapOnVolumeButton{
    [tester tapViewWithAccessibilityLabel:@"volume button"];
}

- (void) test3MuteVolume{

    XCTAssertNil(interstitial, @"Failed to load video.");
    
    expectation = [self expectationWithDescription:@"Waiting to mute volume."];
    
    [self tapOnVolumeButton];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
    XCTAssertTrue(isVolumeButtonClicked, @"failed to mute volume.");

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
    isVolumeButtonClicked = YES;
    [expectation fulfill];
}

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad{
    NSLog(@"Test: ad receive ad");
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error{
    NSLog(@"Test: request failed with error.");
}

@end
