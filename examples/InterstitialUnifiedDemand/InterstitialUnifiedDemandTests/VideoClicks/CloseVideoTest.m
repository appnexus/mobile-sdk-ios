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

#import "CloseVideoTest.h"
#import <KIF/KIFTestCase.h>
#import "ANInterstitialAd.h"

@interface CloseVideoTest()<ANVideoAdDelegate, ANInterstitialAdDelegate>{
    ANInterstitialAd *interstitialAdView;
}

@end

@implementation CloseVideoTest

static BOOL isCloseButtonClicked;

- (void)setUp{
    [super setUp];
    isCloseButtonClicked = NO;
}

- (void)tearDown{
    [super tearDown];
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
    
    XCTAssertNil(interstitial, @"Failed to load video");
}

static dispatch_semaphore_t waitForCloseButtonToBeClicked;

- (void) test2ClickOnClose{

    XCTAssertNil(interstitial, @"Failed to load video");

    waitForCloseButtonToBeClicked = dispatch_semaphore_create(0);
    
//    [tester waitForViewWithAccessibilityLabel:@"close button"];
    [tester waitForTimeInterval:15.0];
    [tester tapViewWithAccessibilityLabel:@"close button"];
    
    dispatch_semaphore_wait(waitForCloseButtonToBeClicked, dispatch_time(DISPATCH_TIME_NOW,10*NSEC_PER_SEC));
    
    NSLog(@"isCloseButtonClicked: %@", isCloseButtonClicked?@"YES":@"NO");
    
    XCTAssertTrue(isCloseButtonClicked, @"Failed.");
    
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

- (void)adSkippedVideo:(id<ANAdProtocol>)ad{
    NSLog(@"Test: Ad Skipped Video.");
}

- (void)adWillClose:(id<ANAdProtocol>)ad{
    NSLog(@"Test: Ad will close now.");
}

- (void)adDidClose:(id<ANAdProtocol>)ad{
    NSLog(@"Test: Ad Did close now.");
    isCloseButtonClicked = YES;
    dispatch_semaphore_signal(waitForCloseButtonToBeClicked);
}

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad{
    NSLog(@"Test: ad receive ad");
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error{
    NSLog(@"Test: request failed with error.");
}

@end
