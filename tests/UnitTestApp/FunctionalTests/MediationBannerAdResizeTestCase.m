/*   Copyright 2019 APPNEXUS INC
 
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

#import <XCTest/XCTest.h>
#import "ViewController.h"
#import "ANBannerAdView.h"
#import "ANGlobal.h"
#import "XCTestCase+ANCategory.h"
#import "UIView+ANCategory.h"
#import "ANMediationContainerView.h"
#import "ANHTTPStubbingManager.h"

@interface BannerMediationAdaptersResizeTestCase : XCTestCase <ANBannerAdViewDelegate>

@property (nonatomic) XCTestExpectation *adResponseExpectation;
@property (nonatomic) BOOL didFailToReceiveAd;
@property (nonatomic, readwrite)  BOOL  shouldResizeAdToFitContainer;

@property (nonatomic, weak) ViewController *rootViewController;
@end

@implementation BannerMediationAdaptersResizeTestCase

- (void)setUp {
    [super setUp];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    self.rootViewController = (ViewController *)[ANGlobal getKeyWindow].rootViewController;
}

- (void)tearDown {
    [super tearDown];
    for (UIView *view in self.rootViewController.view.subviews) {
        if ([view isKindOfClass:[ANBannerAdView class]]) {
            [view removeFromSuperview];
        }
    }
    self.didFailToReceiveAd = NO;
    self.adResponseExpectation = nil;
    if (self.rootViewController.presentedViewController) {
        [self.rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    
    self.shouldResizeAdToFitContainer = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
    
}

#pragma mark - Successful Banners


/* TBD
No visible @interface for 'ViewController' declares the selector 'loadAdMobBannerResizeWithDelegate:shouldResize:'
 */

/*
- (void)testAdMobSuccessfulBannerResizeFalse {
    self.shouldResizeAdToFitContainer = NO;
    
    ANBannerAdView *bannerAdView = [self.rootViewController loadAdMobBannerResizeWithDelegate:self shouldResize:NO];
    [self.rootViewController.view addSubview:bannerAdView];
    
    self.adResponseExpectation = [self expectationWithDescription:@"ad received/failed response"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertFalse(self.didFailToReceiveAd, @"ad:requestFailedWithError: was called when adDidReceiveAd: was expected");
    
#if kANMediationAdaptersUITesting
    bannerAdView.accessibilityLabel = @"banner";
#endif
}


- (void)testAdMobSuccessfulBannerResizeTrue {
    self.shouldResizeAdToFitContainer = YES;
    
    ANBannerAdView *bannerAdView = [self.rootViewController loadAdMobBannerResizeWithDelegate:self shouldResize:YES];
    [self.rootViewController.view addSubview:bannerAdView];
    
    self.adResponseExpectation = [self expectationWithDescription:@"ad received/failed response"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertFalse(self.didFailToReceiveAd, @"ad:requestFailedWithError: was called when adDidReceiveAd: was expected");
    
#if kANMediationAdaptersUITesting
    bannerAdView.accessibilityLabel = @"banner";
#endif
}
 */



- (void)adDidReceiveAd:(id)ad {
    XCTAssertTrue([NSThread isMainThread]);
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        ANBannerAdView *bannerAdObject = (ANBannerAdView *)ad;
        XCTAssertTrue([bannerAdObject.subviews.firstObject isKindOfClass:[ANMediationContainerView class]]);
        
        if(self.shouldResizeAdToFitContainer){
            XCTAssertNotEqual(bannerAdObject.subviews.firstObject.frame.size.width, 320);
            XCTAssertNotEqual(bannerAdObject.subviews.firstObject.frame.size.height ,  50);
            XCTAssertEqual(bannerAdObject.frame.size.width, 400);
            XCTAssertEqual(bannerAdObject.frame.size.height, 100);
            
        }else{
            XCTAssertEqual(bannerAdObject.subviews.firstObject.frame.size.width, 320);
            XCTAssertEqual(bannerAdObject.subviews.firstObject.frame.size.height, 50);
            XCTAssertEqual(bannerAdObject.frame.size.width, 400);
            XCTAssertEqual(bannerAdObject.frame.size.height, 100);
            
            
        }
        self.didFailToReceiveAd = NO;
        [self.adResponseExpectation fulfill];
        
    });
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error {
    XCTAssertTrue([NSThread mainThread]);
    self.didFailToReceiveAd = YES;
    [self.adResponseExpectation fulfill];
}


@end
