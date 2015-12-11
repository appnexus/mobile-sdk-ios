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

@interface OpenInNativeBrowser()<ANVideoAdDelegate, ANInterstitialAdDelegate>
@end

@implementation OpenInNativeBrowser

static BOOL isDelegateFired;

static ANInterstitialAd *interstitialAdView;
static XCTestExpectation *expectation;

+ (void)setUp{
    [super setUp];
    isDelegateFired = NO;
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
    expectation = nil;
}

- (void)test1PrepareForDisplay{
    
    [tester waitForViewWithAccessibilityLabel:@"interstitial"];
    [self setupDelegatesForVideo];

    int breakCounter = 5;
    
    while (interstitial && breakCounter--) {
        [self performClickOnInterstitial];
        [tester waitForTimeInterval:2.0];
    }
    
    if (!interstitial) {
        [tester waitForViewWithAccessibilityLabel:@"player"];
        if (!player) {
            NSLog(@"Test: Not able to load the video.");
        }
    }
    
    XCTAssertNil(interstitial, @"Failed to load video.");
}

- (void) test2OpenClickInNativeBrowser{
    
    XCTAssertNil(interstitial, @"Failed to load video.");
    
    expectation = [self expectationWithDescription:@"Waiting for player to be clicked."];
    
    [tester tapViewWithAccessibilityLabel:@"player"];
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
    
    XCTAssertTrue(isDelegateFired, @"Failed.");
    
}

-(void) setupDelegatesForVideo{
    
    UIViewController *controller = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if (controller) {
        SEL aSelector = NSSelectorFromString(@"interstitialAd");
        interstitialAdView = (ANInterstitialAd *)[controller performSelector:aSelector];
        interstitialAdView.opensInNativeBrowser = YES;
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
    [expectation fulfill];
}

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad{
    NSLog(@"Test: ad receive ad");
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error{
    NSLog(@"Test: request failed with error.");
}


@end
