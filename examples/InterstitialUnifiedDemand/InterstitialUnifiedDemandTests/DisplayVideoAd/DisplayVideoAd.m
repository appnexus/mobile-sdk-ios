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

#import "DisplayVideoAd.h"
#import <KIF/KIFTestCase.h>
#import "ANInterstitialAd.h"

@interface DisplayVideoAd()<ANVideoAdDelegate, ANInterstitialAdDelegate>
@end

@implementation DisplayVideoAd

static ANInterstitialAd *interstitialAdView;

+ (void)setUp{
    [super setUp];
}

+ (void)tearDown{
    [super tearDown];
    UIViewController *controller = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [controller dismissViewControllerAnimated:NO completion:nil];
    interstitialAdView.delegate = nil;
    interstitialAdView.videoAdDelegate = nil;
    interstitialAdView = nil;
}

- (void) test1SetUp{
    
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
    
    XCTAssertNil(interstitial, @"Could not load video.");
}

- (void) test3ExistenceOfCloseCountDownTimerAtTopRight{
    XCTAssertNil(interstitial, @"Video could not be loaded.");
    UIView *circularView = [tester waitForViewWithAccessibilityLabel:@"close button"];
    CGRect superViewFrame = circularView.superview.frame;
    CGRect testFrame = CGRectMake(superViewFrame.size.width - 75, superViewFrame.origin.y, 50, 75);
    XCTAssertTrue(CGRectContainsPoint(testFrame, circularView.frame.origin), @"Countdown timer not found at top right position.");
}

- (void) test2ExistenceOfVolumeView{
    XCTAssertNil(interstitial, @"Video could not be loaded.");
    [tester waitForViewWithAccessibilityLabel:@"player"];
    [tester waitForViewWithAccessibilityLabel:@"volume button"];
}

- (void) test4ExistenceOfVolumeButtonAtBottomRight{
    XCTAssertNil(interstitial, @"Video could not be loaded.");
    UIView *volumeView = [tester waitForViewWithAccessibilityLabel:@"volume button"];
    CGRect superViewFrame = volumeView.superview.superview.frame;
    CGRect testFrame = CGRectMake(superViewFrame.size.width - 75, superViewFrame.size.height-75, 50, 50);
    
    CGPoint point = [volumeView convertPoint:volumeView.superview.center toView:volumeView.superview];
    
    XCTAssertTrue(CGRectContainsPoint(testFrame, point), @"Volume button not found at bottom right position.");
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

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad{
    NSLog(@"Test: ad received ad.");
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error{
    NSLog(@"Test: request failed with error.");
}

@end
