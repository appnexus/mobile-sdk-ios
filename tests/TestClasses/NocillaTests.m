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

float const TEST_TIMEOUT = 10.0;

@interface NocillaTests : ANBaseTestCase
@end

@implementation NocillaTests

- (void)clearTest {
    [super clearTest];
}

+ (void)stubWithBody:(NSString *)body {
    stubRequest(@"GET", @"http://*".regex)
    .andReturn(200)
    .withBody(body)
    ;
}

- (void)loadBannerAd {
    self.banner = [[ANBannerAdView alloc]
                   initWithFrame:CGRectMake(0, 0, 320, 50)
                   placementId:@"1"
                   adSize:CGSizeMake(320, 50)];
    
    [self.banner setDelegate:self];
    [self.banner loadAd];
}

- (void)fetchInterstitialAd {
    self.interstitial = [[ANInterstitialAd alloc] initWithPlacementId:@"1"];
    self.interstitial.delegate = self;
    [self.interstitial loadAd];
}

- (void)showInterstitialAd {
    UIViewController *controller = [[UIApplication sharedApplication] keyWindow].rootViewController;
    [self.interstitial displayAdFromViewController:controller];
}

- (void)checkAdDidLoad {
    STAssertTrue(self.adDidLoadCalled, @"Success callback should be called");
    STAssertFalse(self.adFailedToLoadCalled, @"Failure callback should not be called");
}

- (void)checkAdFailedToLoad {
    STAssertFalse(self.adDidLoadCalled, @"Success callback should not be called");
    STAssertTrue(self.adFailedToLoadCalled, @"Failure callback should be called");
}

#pragma mark Standard Tests

- (void)testSuccessfulBannerDidLoad {
    [self stubWithBody:[ANTestResponses successfulBanner]];
    [self loadBannerAd];
    
    STAssertTrue([self waitForCompletion:TEST_TIMEOUT], @"Test timed out");
    [self checkAdDidLoad];
    
    [self clearTest];
}

- (void)testBannerBlankResponseDidFail {
    [self stubWithBody:@""];
    [self loadBannerAd];
    
    STAssertTrue([self waitForCompletion:TEST_TIMEOUT], @"Test timed out");
    [self checkAdFailedToLoad];
    
    [self clearTest];
}

- (void)testSuccessfulInterstitialDidLoad {
    // response format for interstitials and banners is the same
    [self stubWithBody:[ANTestResponses successfulBanner]];
    [self fetchInterstitialAd];
    
    STAssertTrue([self waitForCompletion:TEST_TIMEOUT], @"Test timed out");
    [self checkAdDidLoad];
    
    [self showInterstitialAd];
    STAssertFalse(self.adFailedToDisplayCalled, @"Interstitial should have displayed successfully");
    
    [self clearTest];
}

- (void)testInterstitialBlankResponseDidFail {
    [self stubWithBody:@""];
    [self fetchInterstitialAd];
    
    STAssertTrue([self waitForCompletion:TEST_TIMEOUT], @"Test timed out");
    [self checkAdFailedToLoad];
    
    [self showInterstitialAd];
    STAssertTrue(self.adFailedToDisplayCalled, @"Interstitial should have failed to display");
    
    [self clearTest];
}
#pragma mark Basic Mediation Tests

- (void)testSuccessfulMediationBannerDidLoad {
    [self stubWithBody:[ANTestResponses mediationSuccessfulBanner]];
    [self loadBannerAd];
    
    STAssertTrue([self waitForCompletion:TEST_TIMEOUT], @"Test timed out");
    [self checkAdDidLoad];
    
    [self clearTest];
}

@end
