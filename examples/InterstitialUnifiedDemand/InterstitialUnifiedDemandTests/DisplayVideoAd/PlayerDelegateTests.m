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

#import "PlayerDelegateTests.h"
#import <KIF/KIFTestCase.h>
#import "ANInterstitialAd.h"

@interface PlayerDelegateTests()<ANVideoAdDelegate, ANInterstitialAdDelegate>{
    ANInterstitialAd *interstitialAdView;
}
@end

@implementation PlayerDelegateTests

static BOOL isAdStartedPlayingVideo;
static BOOL isFirstQuartileDone;
static BOOL isMidPointQuartileDone;
static BOOL isthirdQuartileDone;
static BOOL isCreativeViewDone;
static BOOL isPlayingCompelete;

-(void)setUp{
    [super setUp];
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

- (void)tearDown{
    isAdStartedPlayingVideo = NO;
    isCreativeViewDone = NO;
    isFirstQuartileDone = NO;
    isMidPointQuartileDone = NO;
    isthirdQuartileDone = NO;
    isPlayingCompelete = NO;
}

static dispatch_semaphore_t waitForPlayerDelegatesToFire;

- (void) test2PlayerRelatedDelegates{
    
    XCTAssertNil(interstitial, @"Failed to load video");
    
    waitForPlayerDelegatesToFire = dispatch_semaphore_create(0);
    
    dispatch_semaphore_wait(waitForPlayerDelegatesToFire, dispatch_time(DISPATCH_TIME_NOW, 100*NSEC_PER_SEC));
    
    XCTAssertTrue(isAdStartedPlayingVideo, @"Ad failed to start video.");
    XCTAssertTrue(isFirstQuartileDone, @"Ad did not play till first quartile.");
    XCTAssertTrue(isMidPointQuartileDone, @"Ad did not play till mid point quartile.");
    XCTAssertTrue(isthirdQuartileDone, @"Ad did not play till third quartile.");
    XCTAssertTrue(isPlayingCompelete, @"Ad did not finish playing video till the end.");
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
    NSLog(@"Test: ad receive ad");
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error{
    NSLog(@"Test: request failed with error.");
}

- (void)adStartedPlayingVideo:(id<ANAdProtocol>)ad{
    NSLog(@"Test: video ad started playing video.");
    isAdStartedPlayingVideo = YES;
}

- (void)adFinishedQuartileEvent:(ANVideoEvent)videoEvent withAd:(id<ANAdProtocol>)ad{
    switch (videoEvent) {
        case ANVideoEventQuartileFirst:
            NSLog(@"Test: First Quartile");
            isFirstQuartileDone = YES;
            break;
        case ANVideoEventQuartileMidPoint:
            NSLog(@"Test: Mid Point");
            isMidPointQuartileDone = YES;
            break;
        case ANVideoEventQuartileThird:
            NSLog(@"Test: Third Quartile");
            isthirdQuartileDone = YES;
            break;
        default:
            break;
    }
}

- (void)adFinishedPlayingCompleteVideo:(id<ANAdProtocol>)ad{
    NSLog(@"Test: Video finished playing complete video.");
    isPlayingCompelete = YES;
    dispatch_semaphore_signal(waitForPlayerDelegatesToFire);
}

@end
