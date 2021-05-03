/*   Copyright 2013 APPNEXUS INC
 
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

#import "ANBaseTestCase.h"
#import "ANHTTPStubbingManager.h"


@interface BasicTests : ANBaseTestCase
@end




@implementation BasicTests

float const BASIC_TEST_TIMEOUT = 60.0;

- (void)setUp {
    [super setUp];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    self.banner.delegate = nil;
    self.banner.appEventDelegate = nil;
    [self.banner removeFromSuperview];
    self.banner = nil;
    
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}

- (void)clearTest {
    [super clearTest];
}

- (BOOL)waitForDidPresentCalled {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:BASIC_TEST_TIMEOUT];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0) {
            break;
        }
    } while (!self.adDidPresentCalled);

    return self.adDidPresentCalled;
}

- (void)checkAdDidLoad {
    XCTAssertTrue(self.adDidLoadCalled, @"Success callback should be called");
    XCTAssertFalse(self.adFailedToLoadCalled, @"Failure callback should not be called");
}

- (void)checkAdFailedToLoad {
    XCTAssertFalse(self.adDidLoadCalled, @"Success callback should not be called");
    XCTAssertTrue(self.adFailedToLoadCalled, @"Failure callback should be called");
}

- (void)checkInterstitialDisplayed:(BOOL)displayed {
    XCTAssertEqual((BOOL)!displayed, self.adFailedToDisplayCalled, @"Interstitial callback adFailedToDisplay should be %d", (BOOL)!displayed);
    XCTAssertEqual(displayed, self.adWillPresentCalled, @"Interstitial callback adWillPresent should be %d", displayed);
    if (displayed) {
        [self waitForDidPresentCalled];
    }
    XCTAssertEqual(displayed, self.adDidPresentCalled, @"Interstitial callback adDidPresent should be %d", displayed);
}

- (void)waitForLoad {
    XCTAssertTrue([self waitForCompletion:BASIC_TEST_TIMEOUT], @"Test timed out");
}




#pragma mark - Standard Tests

- (void)testSuccessfulBannerDidLoad {
    [self stubWithInitialMockResponse:[ANTestResponses successfulBanner]];
    [self loadBannerAd];
    [self waitForLoad];
    
    [self checkAdDidLoad];
    [self clearTest];
}

- (void)testBannerBlankContentDidFail {
    [self stubWithInitialMockResponse:[ANTestResponses blankContentBanner]];
    [self loadBannerAd];
    [self waitForLoad];
    
    [self checkAdFailedToLoad];
    [self clearTest];
}

- (void)testBannerBlankResponseDidFail {
    [self stubWithInitialMockResponse:@""];
    [self loadBannerAd];
    [self waitForLoad];

    [self checkAdFailedToLoad];
    [self clearTest];
}

- (void)testSuccessfulInterstitialDidLoad {
    // response format for interstitials and banners is the same
    [self stubWithInitialMockResponse:[ANTestResponses successfulBanner]];
    [self fetchInterstitialAd];
    [self waitForLoad];

    [self checkAdDidLoad];
    
    [self showInterstitialAd];
    [self clearTest];
}

- (void)testInterstitialBlankContentDidFail {
    [self stubWithInitialMockResponse:[ANTestResponses blankContentBanner]];
    [self fetchInterstitialAd];
    [self waitForLoad];

    [self checkAdFailedToLoad];
    
    [self showInterstitialAd];
    [self clearTest];
}

- (void)testInterstitialBlankResponseDidFail {
    [self stubWithInitialMockResponse:@""];
    [self fetchInterstitialAd];
    [self waitForLoad];
    
    [self checkAdFailedToLoad];
    
    [self showInterstitialAd];
    [self clearTest];
}




#pragma mark - Basic Mediation Tests

- (void)testSuccessfulMediationBannerDidLoad
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ @"ANMockMediationAdapterSuccessfulBanner" ]]];

    [self loadBannerAd];
    [self waitForLoad];
    
    [self checkAdDidLoad];
    [self clearTest];
}

@end
