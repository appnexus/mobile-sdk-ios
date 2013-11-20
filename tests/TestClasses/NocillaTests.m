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

#pragma mark Standard Tests

- (void)testSuccessfulBannerDidLoad {
    [self stubWithBody:[ANTestResponses successfulBanner]];
    [self loadBannerAd];
    
    STAssertTrue([self waitForCompletion:TEST_TIMEOUT], @"Test timed out");
    STAssertTrue(self.adDidLoad, @"Banner should have loaded successfully");
    STAssertFalse(self.adFailedToLoad, @"Failure callback should not have been called");
    
    [self clearTest];
}

- (void)testBannerBlankResponseDidFail {
    [self stubWithBody:@""];
    [self loadBannerAd];
    
    STAssertTrue([self waitForCompletion:TEST_TIMEOUT], @"Test timed out");
    STAssertFalse(self.adDidLoad, @"Banner should not have loaded");
    STAssertTrue(self.adFailedToLoad, @"Failure callback should have been called");
    
    [self clearTest];
}

#pragma mark Basic Mediation Tests

- (void)testSuccessfulMediationBannerDidLoad {
    [self stubWithBody:[ANTestResponses mediationSuccessfulBanner]];
    [self loadBannerAd];
    
    STAssertTrue([self waitForCompletion:TEST_TIMEOUT], @"Test timed out");
    STAssertTrue(self.adDidLoad, @"Banner should have loaded successfully");
    STAssertFalse(self.adFailedToLoad, @"Failure callback should not have been called");
    
    [self clearTest];
}

@end
