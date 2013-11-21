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

+ (void)stubWithBody:(NSString *)body {
    stubRequest(@"GET", @"http://*".regex)
    .andReturn(200)
    .withBody(body)
    ;
}

- (BOOL)waitForDidPresentCalled {
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
    STAssertTrue(self.adDidLoadCalled, @"Success callback should be called");
    STAssertFalse(self.adFailedToLoadCalled, @"Failure callback should not be called");
}

- (void)checkAdFailedToLoad {
    STAssertFalse(self.adDidLoadCalled, @"Success callback should not be called");
    STAssertTrue(self.adFailedToLoadCalled, @"Failure callback should be called");
}

- (void)checkInterstitialDisplayed:(BOOL)displayed {
    STAssertEquals((BOOL)!displayed, self.adFailedToDisplayCalled,
                   @"Interstitial callback adFailedToDisplay should be %d", (BOOL)!displayed);
    STAssertEquals(displayed, self.adWillPresentCalled,
                   @"Interstitial callback adWillPresent should be %d", displayed);
    if (displayed) {
        [self waitForDidPresentCalled];
    }
    STAssertEquals(displayed, self.adDidPresentCalled,
                   @"Interstitial callback adDidPresent should be %d", displayed);
}

- (void)waitForLoad {
    STAssertTrue([self waitForCompletion:BASIC_TIMEOUT], @"Test timed out");
}

#pragma mark Standard Tests

- (void)testSuccessfulBannerDidLoad {
    [self stubWithBody:[ANTestResponses successfulBanner]];
    [self loadBannerAd];
    [self waitForLoad];
    
    [self checkAdDidLoad];
    [self clearTest];
}

- (void)testBannerBlankContentDidFail {
    [self stubWithBody:[ANTestResponses blankContentBanner]];
    [self loadBannerAd];
    [self waitForLoad];
    
    [self checkAdFailedToLoad];
    [self clearTest];
}

- (void)testBannerBlankResponseDidFail {
    [self stubWithBody:@""];
    [self loadBannerAd];
    [self waitForLoad];

    [self checkAdFailedToLoad];
    [self clearTest];
}

- (void)testSuccessfulInterstitialDidLoad {
    // response format for interstitials and banners is the same
    [self stubWithBody:[ANTestResponses successfulBanner]];
    [self fetchInterstitialAd];
    [self waitForLoad];

    [self checkAdDidLoad];
    
    [self showInterstitialAd];
    [self checkInterstitialDisplayed:YES];
    [self clearTest];
}

- (void)testInterstitialBlankContentDidFail {
    [self stubWithBody:[ANTestResponses blankContentBanner]];
    [self fetchInterstitialAd];
    [self waitForLoad];

    [self checkAdFailedToLoad];
    
    [self showInterstitialAd];
    [self checkInterstitialDisplayed:NO];
    [self clearTest];
}

- (void)testInterstitialBlankResponseDidFail {
    [self stubWithBody:@""];
    [self fetchInterstitialAd];
    [self waitForLoad];
    
    [self checkAdFailedToLoad];
    
    [self showInterstitialAd];
    [self checkInterstitialDisplayed:NO];
    [self clearTest];
}

#pragma mark Basic Mediation Tests

- (void)testSuccessfulMediationBannerDidLoad {
    [self stubWithBody:[ANTestResponses mediationSuccessfulBanner]];
    [self loadBannerAd];
    [self waitForLoad];
    
    [self checkAdDidLoad];
    [self clearTest];
}

@end
