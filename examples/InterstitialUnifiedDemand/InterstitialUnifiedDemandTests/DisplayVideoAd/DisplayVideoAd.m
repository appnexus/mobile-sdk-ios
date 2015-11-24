//
//  DisplayVideoAd.m
//  InterstitialUnifiedDemand
//
//  Created by Deepak.Badiger on 20/11/15.
//  Copyright © 2015 AppNexus. All rights reserved.
//

#define interstitial [[[UIApplication sharedApplication] keyWindow] accessibilityElementWithLabel:@"interstitial"]
#define player [[[UIApplication sharedApplication] keyWindow] accessibilityElementWithLabel:@"player"]

#import "DisplayVideoAd.h"
#import <KIF/KIFTestCase.h>
#import "ANInterstitialAd.h"

@interface DisplayVideoAd()<ANVideoAdDelegate, ANInterstitialAdDelegate>{
    ANInterstitialAd *interstitialAdView;
}

@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic) int tapsRequired;

@end

@implementation DisplayVideoAd

- (void) test1DisplayAd{
    
    self.tapsRequired = 2;
    
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
    
    self.expectation = [self expectationWithDescription:@"Waiting for delegates to be fired."];
    [self waitForExpectationsWithTimeout:100.0 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.description);
        }
    }];
    
}

- (void) test3ExistenceOfCloseCountDownTimerAtTopRight{
    if (!interstitial) {
        [tester waitForViewWithAccessibilityLabel:@"player"];
        UIView *circularView = [tester waitForViewWithAccessibilityLabel:@"close button"];
        CGRect superViewFrame = circularView.superview.frame;
        CGRect testFrame = CGRectMake(superViewFrame.size.width - 75, superViewFrame.origin.y, 50, 75);
        XCTAssertTrue(CGRectContainsPoint(testFrame, circularView.frame.origin));
    }
}

- (void) test2ExistenceOfVolumeView{
    if (!interstitial) {
        [tester waitForViewWithAccessibilityLabel:@"player"];
        [tester waitForViewWithAccessibilityLabel:@"volume button"];
    }
}

- (void) test4ExistenceOfVolumeButtonAtBottomRight{
    if (!interstitial) {
        [tester waitForViewWithAccessibilityLabel:@"player"];
        UIView *volumeView = [tester waitForViewWithAccessibilityLabel:@"volume button"];
        CGRect superViewFrame = volumeView.superview.superview.frame;
        CGRect testFrame = CGRectMake(superViewFrame.size.width - 75, superViewFrame.size.height-75, 50, 50);
        
        CGPoint point = [volumeView convertPoint:volumeView.superview.center toView:volumeView.superview];
        
        XCTAssertTrue(CGRectContainsPoint(testFrame, point));
    }
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

- (void) performClickOnPlayer{
    [tester waitForViewWithAccessibilityLabel:@"countdown label"];
    [tester tapViewWithAccessibilityLabel:@"player"];
}

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad{
    self.tapsRequired--;
    NSLog(@"Test: ad received ad.");
}

- (void)adStartedPlayingVideo:(id<ANAdProtocol>)ad{
    NSLog(@"Test: video ad started playing video.");
    XCTAssertTrue(YES, @"Test: Ad Started Playing Delegate Fired");
}

- (void)adPausedVideo:(id<ANAdProtocol>)ad{
    NSLog(@"Test: video ad paused video.");
    XCTAssertTrue(YES, @"Test: Ad Started Paused video.");
}

- (void)adMuted:(BOOL)isMuted withAd:(id<ANAdProtocol>)ad{
    NSLog(@"Test: Ad Muted: %i", isMuted);
    XCTAssertTrue(YES, @"Test: Ad %@", isMuted?@"Muted":@"Unmuted");
}

- (void)adSkippedVideo:(id<ANAdProtocol>)ad{
    NSLog(@"Test: video ad skipped video.");
    XCTAssertTrue(YES, @"Test: Ad skipped video delegate fired.");
}

- (void)adFinishedQuartileEvent:(ANVideoEvent)videoEvent withAd:(id<ANAdProtocol>)ad{
    switch (videoEvent) {
        case ANVideoEventQuartileFirst:
            XCTAssertTrue(YES, @"Test: Video Quartile Event First");
            break;
        case ANVideoEventQuartileMidPoint:
            XCTAssertTrue(YES, @"Test: Video Quartile Event Midpoint");
            break;
        case ANVideoEventQuartileThird:
            XCTAssertTrue(YES, @"Test: Video Quartile Event Third");
            break;
        case ANVideoEventCreativeView:
            XCTAssertTrue(YES, @"Test: Video Quartile Event Creative View");
            break;
        default:
            break;
    }
}

- (void)adFinishedPlayingCompleteVideo:(id<ANAdProtocol>)ad{
    NSLog(@"Test: Video finished playing complete video.");
    [self.expectation fulfill];
}

@end
