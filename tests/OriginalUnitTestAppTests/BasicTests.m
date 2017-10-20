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



@interface BasicTests : ANBaseTestCase
@end




@implementation BasicTests

float const BASIC_TIMEOUT = 10.0;



- (void)clearTest {
    [super clearTest];
}

- (BOOL)waitForDidPresentCalled {
                //FIX -- abstrct spinwait for seconds with conditionsBlock (optinoally nil)?
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:BASIC_TIMEOUT];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0) {
            break;
        }
    }
    while (!self.adDidPresentCalled);
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
    XCTAssertTrue([self waitForCompletion:BASIC_TIMEOUT], @"Test timed out");
}




#pragma mark - Standard Tests

- (void)testSuccessfulBannerDidLoad {
LOGMARK();
    [self stubWithBody:[ANTestResponses successfulBanner]];
    [self loadBannerAd];
    [self waitForLoad];
    
    [self checkAdDidLoad];
    [self clearTest];
}

- (void)testBannerBlankContentDidFail {
LOGMARK();
    [self stubWithBody:[ANTestResponses blankContentBanner]];
    [self loadBannerAd];
    [self waitForLoad];
    
    [self checkAdFailedToLoad];
    [self clearTest];
}

- (void)testBannerBlankResponseDidFail {
LOGMARK();
    [self stubWithBody:@""];
    [self loadBannerAd];
    [self waitForLoad];

    [self checkAdFailedToLoad];
    [self clearTest];
}

- (void)testSuccessfulInterstitialDidLoad {
LOGMARK();
    // response format for interstitials and banners is the same
    [self stubWithBody:[ANTestResponses successfulBanner]];
    [self fetchInterstitialAd];
    [self waitForLoad];

    [self checkAdDidLoad];
    
    [self showInterstitialAd];
    [self clearTest];
}

- (void)testInterstitialBlankContentDidFail {
LOGMARK();
    [self stubWithBody:[ANTestResponses blankContentBanner]];
    [self fetchInterstitialAd];
    [self waitForLoad];

    [self checkAdFailedToLoad];
    
    [self showInterstitialAd];
    [self clearTest];
}

- (void)testInterstitialBlankResponseDidFail {
LOGMARK();
    [self stubWithBody:@""];
    [self fetchInterstitialAd];
    [self waitForLoad];
    
    [self checkAdFailedToLoad];
    
    [self showInterstitialAd];
    [self clearTest];
}




#pragma mark - Basic Mediation Tests

- (void)testSuccessfulMediationBannerDidLoad {
    [self stubWithBody:[ANTestResponses mediationSuccessfulBanner]];
    [self stubResultCBResponses:nil];
    [self loadBannerAd];
    [self waitForLoad];
    
    [self checkAdDidLoad];
    [self clearTest];
}

@end
