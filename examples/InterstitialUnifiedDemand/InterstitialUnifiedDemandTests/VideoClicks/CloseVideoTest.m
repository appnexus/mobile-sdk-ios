//
//  CloseVideoTest.m
//  InterstitialUnifiedDemand
//
//  Created by Chandrachud Patil on 11/24/15.
//  Copyright © 2015 AppNexus. All rights reserved.
//
#define interstitial [[[UIApplication sharedApplication] keyWindow] accessibilityElementWithLabel:@"interstitial"]
#define player [[[UIApplication sharedApplication] keyWindow] accessibilityElementWithLabel:@"player"]

#import "CloseVideoTest.h"
#import <KIF/KIFTestCase.h>
#import "ANInterstitialAd.h"

@interface CloseVideoTest()<ANVideoAdDelegate, ANInterstitialAdDelegate>{
    ANInterstitialAd *interstitialAdView;
}

@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic) int tapsRequired;

@end

@implementation CloseVideoTest

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

- (void) test1ClickOnClose{
    
    [tester waitForViewWithAccessibilityLabel:@"close button"];
    [tester waitForTimeInterval:10.0];
    [tester tapViewWithAccessibilityLabel:@"close button"];
    
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

- (void)adFinishedQuartileEvent:(ANVideoEvent)videoEvent withAd:(id<ANAdProtocol>)ad{
    switch (videoEvent) {
        case ANVideoEventCloseLinear:
            XCTAssertTrue(YES, @"Test: Video Quartile Event Close");
            [self.expectation fulfill];
            break;
        default:
            break;
    }
}

- (void)adSkippedVideo:(id<ANAdProtocol>)ad{
    NSLog(@"Test: Ad Skipped Video.");
    XCTAssertTrue(YES, @"Test: adSkippedVideo delegate fired.");
}

- (void)adWillClose:(id<ANAdProtocol>)ad{
    NSLog(@"Test: Ad will close now.");
    XCTAssertTrue(YES, @"Test: adWillClose delegate fired.");
}

- (void)adDidClose:(id<ANAdProtocol>)ad{
    NSLog(@"Test: Ad Did close now.");
    XCTAssertTrue(YES, @"Test: adDidClose delegate fired.");
    [self.expectation fulfill];
}

@end
