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

#import <SenTestingKit/SenTestingKit.h>
#import "Nocilla.h"
#import "TestResponses.h"
#import "ANBannerAdView.h"
#import "ANInterstitialAd.h"

#define TEST_TIMEOUT 10.0

@interface NocillaTests : SenTestCase
@property (nonatomic, readwrite, strong) ANBannerAdView *banner;
@property (nonatomic, readwrite, strong) ANInterstitialAd *interstitial;
@property (nonatomic, assign) BOOL testComplete;
@property (nonatomic, assign) BOOL adDidLoad;
@property (nonatomic, assign) BOOL adFailedToLoad;
@end

@interface NocillaTests () <ANBannerAdViewDelegate>

@end

@implementation NocillaTests

- (void)setUp {
    [super setUp];
    [[LSNocilla sharedInstance] start];
}

- (void)tearDown {
    [super tearDown];
    [[LSNocilla sharedInstance] stop];
}

- (void)clearTest {
    [[LSNocilla sharedInstance] clearStubs];
    _banner = nil;
    _interstitial = nil;
    _adDidLoad = NO;
    _adFailedToLoad = NO;
    _testComplete = NO;
}

- (void)testSimple {
    stubRequest(@"GET", @"http://*".regex)
    .andReturn(200)
    .withBody(MMBANNER)
    ;
    
    _banner = [[ANBannerAdView alloc]
               initWithFrame:CGRectMake(0, 0, 320, 50)
               placementId:@"1"
               adSize:CGSizeMake(320, 50)];
    
    [_banner setDelegate:self];
    [_banner loadAd];
    
    [self waitForCompletion:TEST_TIMEOUT];
    
    STAssertTrue(_adDidLoad, @"MMBanner should have loaded successfully");
    STAssertFalse(_adFailedToLoad, @"Failure callback should not have been called");
    
    [self clearTest];
}

- (void)runBannerTest {
    
    [self clearTest];
}

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0) {
            break;
        }
    }
    while (!_testComplete);
    return _testComplete;
}

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
    _adDidLoad = YES;
    _testComplete = YES;
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error {
    _adFailedToLoad = YES;
    _testComplete = YES;
}

@end
