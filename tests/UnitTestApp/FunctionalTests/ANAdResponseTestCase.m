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

#import <XCTest/XCTest.h>
#import <CoreLocation/CoreLocation.h>

#import "ANHTTPStubbingManager.h"
#import "ANBannerAdView+ANTest.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANTestGlobal.h"
#import "ANInterstitialAd.h"
#import "ANInterstitialAd+ANTest.h"
#import "ANNativeAdResponse.h"
#import "ANNativeAdRequest+ANTest.h"
#import "ANInstreamVideoAd.h"
#import "ANInstreamVideoAd+Test.h"
#import "ANVideoAdPlayer.h"

@interface ANAdResponseTestCase : XCTestCase<ANBannerAdViewDelegate, ANInterstitialAdDelegate, ANNativeAdRequestDelegate, ANInstreamVideoAdLoadDelegate>

@property (nonatomic, readwrite, strong)  ANBannerAdView        *banner;
@property (nonatomic, readwrite, strong)  ANInterstitialAd      *interstitial;
@property (nonatomic, readwrite, strong)  ANNativeAdRequest     *adRequest;
@property (nonatomic, readwrite, strong)  ANNativeAdResponse    *adResponse;
@property (nonatomic, readwrite, strong)  ANInstreamVideoAd  *instreamVideoAd;
@property (nonatomic, readwrite)  BOOL  receiveAdSuccess;
@property (nonatomic, readwrite)  BOOL  receiveAdFailure;
@property (nonatomic, strong) XCTestExpectation *loadAdResponseReceivedExpectation;
@property (nonatomic, strong) XCTestExpectation *loadAdResponseFailedExpectation;
@end
@implementation ANAdResponseTestCase

#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    self.receiveAdSuccess = NO;
    self.receiveAdFailure = NO;
}

- (void)tearDown {
    [super tearDown];
    [self clearSetupBannerAd];
    [self clearSetupInterstitialAd];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    self.loadAdResponseReceivedExpectation = nil;
}


- (void)clearSetupBannerAd {
    self.banner = nil;
    self.banner.delegate = nil;
    self.banner.appEventDelegate = nil;
    [self.banner removeFromSuperview];
    self.banner = nil;
}

-(void) setupBannerAd{
    [self clearSetupBannerAd];
    self.banner = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)
                                            placementId:@"13653381"
                                                 adSize:CGSizeMake(320, 480)];
    self.banner.autoRefreshInterval = 0;
    self.banner.delegate = self;
    self.banner.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.banner];
}

- (void)clearSetupInterstitialAd {
    self.interstitial = nil;
    [self.interstitial removeFromSuperview];
}

-(void) setupInterstitialAd{
    [self clearSetupInterstitialAd];
    self.interstitial = [[ANInterstitialAd alloc] initWithPlacementId:@"1"];
    self.interstitial.delegate = self;
}

- (void)clearSetupNativeAd {
    self.adRequest = nil;
    self.adResponse = nil;
}

-(void) setupNativeAd{
    [self clearSetupNativeAd];
    self.adRequest = [[ANNativeAdRequest alloc] init];
    self.adRequest.delegate = self;
}

- (void)clearSetupInstreamAd {
    self.instreamVideoAd = nil;
    self.instreamVideoAd.adPlayer = nil;
}
-(void) setupInstreamAd {
    [self clearSetupInstreamAd];
    self.instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithPlacementId:@"12534678"];
    self.instreamVideoAd.adPlayer = [[ANVideoAdPlayer alloc] init];
    self.instreamVideoAd.adPlayer.videoDuration = 10;
    self.instreamVideoAd.adPlayer.creativeURL = @"http://sampletag.com";
    self.instreamVideoAd.adPlayer.vastURLContent = @"http://sampletag.com";
    self.instreamVideoAd.adPlayer.vastXMLContent = @"http://sampletag.com";
}


#pragma mark - Test methods.

- (void)testAdResponseWithRTBBannerAd {
    
    [self setupBannerAd];
    [self stubRequestWithResponse:@"ANAdResponseRTB_Banner"];
    [self.banner loadAd];
    
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqualObjects(self.banner.adResponse.creativeId, @"163051950");
    XCTAssertEqualObjects(self.banner.adResponse.placementId, @"16392991");
    XCTAssertTrue(self.banner.adResponse.memberId == 10094);
    XCTAssertTrue(self.banner.adResponse.adType == ANAdTypeBanner);
    XCTAssertEqualObjects(self.banner.adResponse.contentSource, @"rtb");
    XCTAssertNil(self.banner.adResponse.networkName);
    
}

- (void)testAdResponseWithCSMBannerAd {
    
    [self setupBannerAd];
    [self stubRequestWithResponse:@"ANAdResponseCSM_Banner"];
    [self.banner loadAd];
    
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqualObjects(self.banner.adResponse.creativeId, @"187027997");
    XCTAssertEqualObjects(self.banner.adResponse.placementId, @"17432496");
    XCTAssertTrue(self.banner.adResponse.memberId == 958);
    XCTAssertTrue(self.banner.adResponse.adType == ANAdTypeBanner);
    XCTAssertEqualObjects(self.banner.adResponse.contentSource, @"csm");
    XCTAssertEqualObjects(self.banner.adResponse.networkName, @"ANAdAdapterBannerDFP");
    
}

- (void) testAdResponseWithBannerNativeAd
{
    [self setupBannerAd];
    self.banner.shouldAllowNativeDemand = YES;
    self.banner.enableNativeRendering = YES;
    [self.banner setAdSize:CGSizeMake(300, 250)];
    [self stubRequestWithResponse:@"ANAdResponseRTB_Native"];
    [self.banner loadAd];
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
   [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                handler:^(NSError *error) {
                                    
                                }];
   XCTAssertEqualObjects(self.banner.adResponse.creativeId, @"162039377");
   XCTAssertEqualObjects(self.banner.adResponse.placementId, @"16392991");
   XCTAssertTrue(self.banner.adResponse.memberId == 10094);
   XCTAssertTrue(self.banner.adResponse.adType == ANAdTypeNative);
   XCTAssertEqualObjects(self.banner.adResponse.contentSource, @"rtb");
   XCTAssertNil(self.banner.adResponse.networkName);
}

- (void) testAdResponseWithBannerVideoAd
{
    [self setupBannerAd];
    self.banner.shouldAllowVideoDemand = YES;
    [self.banner setAdSize:CGSizeMake(300, 250)];
    [self stubRequestWithResponse:@"ANAdResponseRTB_Video"];
    [self.banner loadAd];
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
   [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                handler:^(NSError *error) {
                                    
                                }];
   XCTAssertEqualObjects(self.banner.adResponse.creativeId, @"162035356");
   XCTAssertEqualObjects(self.banner.adResponse.placementId, @"16392991");
   XCTAssertTrue(self.banner.adResponse.memberId == 10094);
   XCTAssertTrue(self.banner.adResponse.adType == ANAdTypeVideo);
   XCTAssertEqualObjects(self.banner.adResponse.contentSource, @"rtb");
   XCTAssertNil(self.banner.adResponse.networkName);
}

- (void)testAdResponseWithInterstitialAd {
    
    [self setupInterstitialAd];
    [self stubRequestWithResponse:@"ANAdResponseRTB_Banner"];
    [self.interstitial loadAd];
    
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqualObjects(self.interstitial.adResponse.creativeId, @"163051950");
    XCTAssertEqualObjects(self.interstitial.adResponse.placementId, @"16392991");
    XCTAssertTrue(self.interstitial.adResponse.memberId == 10094);
    XCTAssertTrue(self.interstitial.adResponse.adType == ANAdTypeBanner);
    XCTAssertEqualObjects(self.interstitial.adResponse.contentSource, @"rtb");
    XCTAssertNil(self.interstitial.adResponse.networkName);
    
}

- (void)testAdResponseWithNativeAd {
    [self setupNativeAd];
    [self stubRequestWithResponse:@"ANAdResponseRTB_Native"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
   self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
   [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                handler:^(NSError *error) {
                                    
                                }];
   XCTAssertEqualObjects(self.adResponse.adResponse.creativeId, @"162039377");
   XCTAssertEqualObjects(self.adResponse.adResponse.placementId, @"16392991");
   XCTAssertTrue(self.adResponse.adResponse.memberId == 10094);
   XCTAssertTrue(self.adResponse.adResponse.adType == ANAdTypeNative);
   XCTAssertEqualObjects(self.adResponse.adResponse.contentSource, @"rtb");
   XCTAssertNil(self.adResponse.adResponse.networkName);
}

- (void) testAdResponseWithInstreamAd
{
    [self setupInstreamAd];
    [self stubRequestWithResponse:@"ANAdResponseRTB_Video"];
    [self.instreamVideoAd loadAdWithDelegate:self];
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
   [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                handler:^(NSError *error) {
                                    
                                }];
   XCTAssertEqualObjects(self.instreamVideoAd.adResponse.creativeId, @"162035356");
   XCTAssertEqualObjects(self.instreamVideoAd.adResponse.placementId, @"16392991");
   XCTAssertTrue(self.instreamVideoAd.adResponse.memberId == 10094);
   XCTAssertTrue(self.instreamVideoAd.adResponse.adType == ANAdTypeVideo);
   XCTAssertEqualObjects(self.instreamVideoAd.adResponse.contentSource, @"rtb");
   XCTAssertNil(self.instreamVideoAd.adResponse.networkName);
}

#pragma mark - Stubbing

- (void) stubRequestWithResponse:(NSString *)responseName {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *baseResponse = [NSString stringWithContentsOfFile: [currentBundle pathForResource:responseName
                                                                                         ofType:@"json" ]
                                                       encoding: NSUTF8StringEncoding
                                                          error: nil ];
    
    ANURLConnectionStub  *requestStub  = [[ANURLConnectionStub alloc] init];
    
    requestStub.requestURL    = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    requestStub.responseCode  = 200;
    requestStub.responseBody  = baseResponse;
    
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:requestStub];
}

- (void)fulfillExpectation:(XCTestExpectation *)expectation
{
    [expectation fulfill];
}

- (void)waitForTimeInterval:(NSTimeInterval)delay
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    [self performSelector:@selector(fulfillExpectation:) withObject:expectation afterDelay:delay];
    
    [self waitForExpectationsWithTimeout:delay + 1 handler:nil];
}

#pragma mark - ANAdDelegate

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad
{
    [self.loadAdResponseReceivedExpectation fulfill];
    self.receiveAdSuccess = YES;
    if ([ad isKindOfClass:[ANInterstitialAd class]]) {
        [self.interstitial displayAdFromViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    }
}


- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    TESTTRACEM(@"error.info=%@", error.userInfo);

    [self.loadAdResponseReceivedExpectation fulfill];
    [self.loadAdResponseFailedExpectation fulfill];
    self.receiveAdFailure = YES;
}

#pragma mark - ANNativeAdRequestDelegate

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response
{
    self.adResponse = response;
    [self.loadAdResponseReceivedExpectation fulfill];
    self.receiveAdSuccess = YES;
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error
{
    TESTTRACEM(@"error.info=%@", error.userInfo);

    [self.loadAdResponseReceivedExpectation fulfill];
    [self.loadAdResponseFailedExpectation fulfill];
    self.receiveAdFailure = YES;
}
@end
