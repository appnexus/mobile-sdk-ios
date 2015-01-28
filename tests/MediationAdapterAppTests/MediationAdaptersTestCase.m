/*   Copyright 2014 APPNEXUS INC
 
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

#define kANMediationAdaptersUITesting 1

#import <UIKit/UIKit.h>
#if kANMediationAdaptersUITesting
#import <KIF/KIF.h>
#else
#import <XCTest/XCTest.h>
#endif
#import "ANMediationAdapterViewController.h"
#import "ANBannerAdView.h"
#import "ANGlobal.h"
#import "XCTestCase+ANCategory.h"

#if kANMediationAdaptersUITesting
@interface MediationAdaptersTestCase : KIFTestCase <ANBannerAdViewDelegate>
#else
@interface MediationAdaptersTestCase : XCTestCase <ANBannerAdViewDelegate>
#endif
@property (nonatomic) XCTestExpectation *adResponseExpectation;
@property (nonatomic) BOOL didFailToReceiveAd;

// Can't do UI testing and use XCTestExpectation simultaneously, since they both modify the run loop.
@property (nonatomic) BOOL adWasClicked;
@property (nonatomic) BOOL adWillPresent;
@property (nonatomic) BOOL adDidPresent;
@property (nonatomic) BOOL adWillClose;
@property (nonatomic) BOOL adDidClose;

@property (nonatomic, weak) ANMediationAdapterViewController *rootViewController;
@end

@implementation MediationAdaptersTestCase

- (void)setUp {
    [super setUp];
    self.rootViewController = (ANMediationAdapterViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
}

- (void)tearDown {
    [super tearDown];
    for (UIView *view in self.rootViewController.view.subviews) {
        if ([view isKindOfClass:[ANBannerAdView class]]) {
            [view removeFromSuperview];
        }
    }
    self.didFailToReceiveAd = NO;
    self.adWasClicked = NO;
    self.adWillPresent = NO;
    self.adDidPresent = NO;
    self.adWillClose = NO;
    self.adDidClose = NO;
    if (self.rootViewController.presentedViewController) {
        [self.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - Successful Banners

- (void)testMillennialSuccessfulBanner {
    ANBannerAdView *bannerAdView = [self.rootViewController loadMillennialMediaBannerWithDelegate:self];
    [self.rootViewController.view addSubview:bannerAdView];
    
    self.adResponseExpectation = [self expectationWithDescription:@"ad received/failed response"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertFalse(self.didFailToReceiveAd, @"Received successful callback, but no ad was received.");
    
#if kANMediationAdaptersUITesting
    bannerAdView.accessibilityLabel = @"banner";
    [tester tapViewWithAccessibilityLabel:@"banner"];
    [tester waitForTimeInterval:3.0];
    XCTAssertTrue(self.adWasClicked, @"expected adWasClicked callback");
    XCTAssertTrue(self.adWillPresent, @"expected adWillPresent callback");
    XCTAssertTrue(self.adDidPresent, @"expected adDidPresent callback");
    [tester waitForTimeInterval:2.0];
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    [tester tapScreenAtPoint:CGPointMake(screenBounds.size.width - 25, screenBounds.size.height - 25)];
    if (screenBounds.size.height > 1136) {
        CGFloat x = (screenBounds.size.width - 640) / 2 + 640 - 10;
        CGFloat y = (screenBounds.size.height - 1136) / 2 + 10;
        [tester tapScreenAtPoint:CGPointMake(x,y)];
    } else {
        [tester tapScreenAtPoint:CGPointMake(screenBounds.size.width - 10, 10)];
    }
    [tester waitForTimeInterval:3.0];
    XCTAssertTrue(self.adWillClose, @"expected adWillClose callback");
    XCTAssertTrue(self.adDidClose, @"expected adDidClose callback");
    [tester waitForTimeInterval:2.0];
#endif
}

- (void)testiAdSuccessfulBanner {
    ANBannerAdView *bannerAdView = [self.rootViewController loadiAdBannerWithDelegate:self];
    [self.rootViewController.view addSubview:bannerAdView];
    
    self.adResponseExpectation = [self expectationWithDescription:@"ad received/failed response"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertFalse(self.didFailToReceiveAd, @"Received successful callback, but no ad was received.");
    
#if kANMediationAdaptersUITesting
    bannerAdView.accessibilityLabel = @"banner";
    [tester tapViewWithAccessibilityLabel:@"banner"];
    [tester waitForTimeInterval:3.0];
    XCTAssertTrue(self.adWasClicked, @"expected adWasClicked callback");
    XCTAssertTrue(self.adWillPresent, @"expected adWillPresent callback");
    XCTAssertTrue(self.adDidPresent, @"expected adDidPresent callback");
    [tester waitForTimeInterval:3.0];
#endif
}

- (void)testFacebookSuccessfulBanner {
    ANBannerAdView *bannerAdView = [self.rootViewController loadFacebookBannerWithDelegate:self];
    [self.rootViewController.view addSubview:bannerAdView];
    
    self.adResponseExpectation = [self expectationWithDescription:@"ad received/failed response"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertFalse(self.didFailToReceiveAd, @"Received successful callback, but no ad was received.");
    
#if kANMediationAdaptersUITesting
    bannerAdView.accessibilityLabel = @"banner";
    [tester tapScreenAtPoint:CGPointMake([UIScreen mainScreen].bounds.size.width - 10, 25)];
    [tester waitForTimeInterval:3.0];
    XCTAssertTrue(self.adWasClicked, @"expected adWasClicked callback");
    XCTAssertTrue(self.adWillPresent, @"expected adWillPresent callback");
    XCTAssertTrue(self.adDidPresent, @"expected adDidPresent callback");
    [tester waitForTimeInterval:3.0];
#endif
}

- (void)testMoPubSuccessfulBanner {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerMoPub";
    mediatedAd.adId = @"";
    mediatedAd.width = @"320";
    mediatedAd.height = @"50";
    [self.rootViewController stubMediatedAd:mediatedAd];
    
    ANBannerAdView *bannerAdView = [self.rootViewController bannerWithDelegate:self
                                                                     frameSize:CGSizeMake(320, 50)
                                                                        adSize:CGSizeMake(320, 50)];
    [self.rootViewController.view addSubview:bannerAdView];
    
    self.adResponseExpectation = [self expectationWithDescription:@"ad received/failed response"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertFalse(self.didFailToReceiveAd, @"Received successful callback, but no ad was received.");
    
#if kANMediationAdaptersUITesting
    bannerAdView.accessibilityLabel = @"banner";
    [tester tapViewWithAccessibilityLabel:@"banner"];
    [tester waitForTimeInterval:3.0];
    //XCTAssertTrue(self.adWasClicked, @"expected adWasClicked callback");
    XCTAssertTrue(self.adWillPresent, @"expected adWillPresent callback");
    //XCTAssertTrue(self.adDidPresent, @"expected adDidPresent callback");
    [tester waitForTimeInterval:2.0];
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    [tester tapScreenAtPoint:CGPointMake(screenBounds.size.width - 25, screenBounds.size.height - 25)];
    [tester waitForTimeInterval:3.0];
    //XCTAssertTrue(self.adWillClose, @"expected adWillClose callback");
    XCTAssertTrue(self.adDidClose, @"expected adDidClose callback");
    [tester waitForTimeInterval:2.0];
#endif
}

- (void)testAdMobSuccessfulBanner {
    ANBannerAdView *bannerAdView = [self.rootViewController loadAdMobBannerWithDelegate:self];
    [self.rootViewController.view addSubview:bannerAdView];
    
    self.adResponseExpectation = [self expectationWithDescription:@"ad received/failed response"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertFalse(self.didFailToReceiveAd, @"Received successful callback, but no ad was received.");
    
#if kANMediationAdaptersUITesting
    bannerAdView.accessibilityLabel = @"banner";
    //[tester tapViewWithAccessibilityLabel:@"banner"];
    //[tester waitForTimeInterval:3.0];
    //XCTAssertTrue(self.adWasClicked, @"expected adWasClicked callback");
#endif
}

- (void)testDFPSuccessfulBanner {
    ANBannerAdView *bannerAdView = [self.rootViewController loadDFPBannerWithDelegate:self];
    [self.rootViewController.view addSubview:bannerAdView];
    
    self.adResponseExpectation = [self expectationWithDescription:@"ad received/failed response"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertFalse(self.didFailToReceiveAd, @"Received successful callback, but no ad was received.");
    
#if kANMediationAdaptersUITesting
    bannerAdView.accessibilityLabel = @"banner";
    //[tester tapViewWithAccessibilityLabel:@"banner"];
    //[tester waitForTimeInterval:3.0];
    //XCTAssertTrue(self.adWasClicked, @"expected adWasClicked callback");
#endif
}

- (void)testAmazonSuccessfulBanner {
    ANBannerAdView *bannerAdView = [self.rootViewController loadAmazonBannerWithDelegate:self];
    [self.rootViewController.view addSubview:bannerAdView];
    
    self.adResponseExpectation = [self expectationWithDescription:@"ad received/failed response"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertFalse(self.didFailToReceiveAd, @"Received successful callback, but no ad was received.");
    
#if kANMediationAdaptersUITesting
    bannerAdView.accessibilityLabel = @"banner";
    //[tester tapViewWithAccessibilityLabel:@"banner"];
    //[tester waitForTimeInterval:3.0];
    //XCTAssertTrue(self.adWasClicked, @"expected adWasClicked callback");
    //XCTAssertTrue(self.adWillPresent, @"expected adWillPresent callback");
    //XCTAssertTrue(self.adDidPresent, @"expected adDidPresent callback");
    //[tester waitForTimeInterval:3.0];
#endif
}

#pragma mark - Failed Banners

- (void)testDFPFailedBanner {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerDFP";
    mediatedAd.adId = @"";
    [self.rootViewController stubMediatedAd:mediatedAd];
    
    ANBannerAdView *bannerAdView = [self.rootViewController bannerWithDelegate:self
                                                                     frameSize:CGSizeMake(320, 50)
                                                                        adSize:CGSizeMake(1, 1)];
    [self.rootViewController.view addSubview:bannerAdView];
    self.adResponseExpectation = [self expectationWithDescription:@"ad received/failed response"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertTrue(self.didFailToReceiveAd);
}

- (void)testMillennialFailedBanner {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerMillennialMedia";
    mediatedAd.adId = @"";
    [self.rootViewController stubMediatedAd:mediatedAd];
    
    ANBannerAdView *bannerAdView = [self.rootViewController bannerWithDelegate:self
                                                                     frameSize:CGSizeMake(320, 50)
                                                                        adSize:CGSizeMake(1, 1)];
    [self.rootViewController.view addSubview:bannerAdView];
    self.adResponseExpectation = [self expectationWithDescription:@"ad received/failed response"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertTrue(self.didFailToReceiveAd);
}

- (void)testFacebookFailedBanner {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerFacebook";
    mediatedAd.adId = @"";
    [self.rootViewController stubMediatedAd:mediatedAd];
    
    ANBannerAdView *bannerAdView = [self.rootViewController bannerWithDelegate:self
                                                                     frameSize:CGSizeMake(320, 50)
                                                                        adSize:CGSizeMake(1, 1)];
    [self.rootViewController.view addSubview:bannerAdView];
    self.adResponseExpectation = [self expectationWithDescription:@"ad received/failed response"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertTrue(self.didFailToReceiveAd);
}

- (void)testMoPubFailedBanner {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerMoPub";
    mediatedAd.adId = @"123";
    mediatedAd.width = @"1";
    mediatedAd.height = @"1";
    [self.rootViewController stubMediatedAd:mediatedAd];
    
    ANBannerAdView *bannerAdView = [self.rootViewController bannerWithDelegate:self
                                                                     frameSize:CGSizeMake(320, 50)
                                                                        adSize:CGSizeMake(1, 1)];
    [self.rootViewController.view addSubview:bannerAdView];
    self.adResponseExpectation = [self expectationWithDescription:@"ad received/failed response"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertTrue(self.didFailToReceiveAd);
}

- (void)testAdMobFailedBanner {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerAdMob";
    mediatedAd.adId = @"";
    [self.rootViewController stubMediatedAd:mediatedAd];
    
    ANBannerAdView *bannerAdView = [self.rootViewController bannerWithDelegate:self
                                                                     frameSize:CGSizeMake(320, 50)
                                                                        adSize:CGSizeMake(1, 1)];
    [self.rootViewController.view addSubview:bannerAdView];
    self.adResponseExpectation = [self expectationWithDescription:@"ad received/failed response"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertTrue(self.didFailToReceiveAd);
}

- (void)testAmazonFailedBanner {
    ANMediatedAd *mediatedAd = [[ANMediatedAd alloc] init];
    mediatedAd.className = @"ANAdAdapterBannerAmazon";
    mediatedAd.adId = @"";
    [self.rootViewController stubMediatedAd:mediatedAd];
    
    ANBannerAdView *bannerAdView = [self.rootViewController bannerWithDelegate:self
                                                                     frameSize:CGSizeMake(320, 50)
                                                                        adSize:CGSizeMake(1, 1)];
    [self.rootViewController.view addSubview:bannerAdView];
    self.adResponseExpectation = [self expectationWithDescription:@"ad received/failed response"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertTrue(self.didFailToReceiveAd);
}

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
    XCTAssertTrue([NSThread isMainThread]);
    self.didFailToReceiveAd = NO;
    [self.adResponseExpectation fulfill];
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error {
    XCTAssertTrue([NSThread mainThread]);
    self.didFailToReceiveAd = YES;
    [self.adResponseExpectation fulfill];
}

- (void)adWasClicked:(id<ANAdProtocol>)ad {
    XCTAssertTrue([NSThread isMainThread]);
    self.adWasClicked = YES;
}

- (void)adWillPresent:(id<ANAdProtocol>)ad {
    XCTAssertTrue([NSThread isMainThread]);
    self.adWillPresent = YES;
}

- (void)adDidPresent:(id<ANAdProtocol>)ad {
    XCTAssertTrue([NSThread isMainThread]);
    self.adDidPresent = YES;
}

- (void)adWillClose:(id<ANAdProtocol>)ad {
    XCTAssertTrue([NSThread isMainThread]);
    self.adWillClose = YES;
}

- (void)adDidClose:(id<ANAdProtocol>)ad {
    XCTAssertTrue([NSThread isMainThread]);
    self.adDidClose = YES;
}

@end
