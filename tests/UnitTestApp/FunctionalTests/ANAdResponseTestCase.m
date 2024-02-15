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
#import "XandrAd.h"
#import "ANAdResponseInfo.h"
#import "ANDSAResponseInfo.h"
#import "ANDSATransparencyInfo.h"

@interface ANAdResponseTestCase : XCTestCase<ANBannerAdViewDelegate, ANInterstitialAdDelegate, ANNativeAdRequestDelegate, ANInstreamVideoAdLoadDelegate>

@property (nonatomic, readwrite, strong)  ANBannerAdView        *banner;
@property (nonatomic, readwrite, strong)  ANInterstitialAd      *interstitial;
@property (nonatomic, readwrite, strong)  ANNativeAdRequest     *adRequest;
@property (nonatomic, readwrite, strong)  ANNativeAdResponse    *adResponse;
@property (nonatomic, readwrite, strong)  ANAdResponseInfo    *adResponseInfo;
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
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    self.receiveAdSuccess = NO;
    self.receiveAdFailure = NO;
}

- (void)tearDown {
    [super tearDown];
    [self clearSetupBannerAd];
    [self clearSetupInterstitialAd];
    [self clearSetupInstreamAd];
    [self clearSetupNativeAd];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    self.loadAdResponseReceivedExpectation = nil;
    
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}


- (void)clearSetupBannerAd {
    self.banner = nil;
    self.banner.delegate = nil;
    self.banner.appEventDelegate = nil;
    [self.banner removeFromSuperview];
    self.banner = nil;
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
             [additionalView removeFromSuperview];
         }
}

-(void) setupBannerAd{
    [self clearSetupBannerAd];
    self.banner = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)
                                            placementId:@"13653381"
                                                 adSize:CGSizeMake(320, 480)];
    self.banner.autoRefreshInterval = 0;
    self.banner.delegate = self;
    self.banner.rootViewController = [ANGlobal getKeyWindow].rootViewController;
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.banner];
}

- (void)clearSetupInterstitialAd {
    self.interstitial = nil;
    [self.interstitial removeFromSuperview];
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
             [additionalView removeFromSuperview];
         }
}

-(void) setupInterstitialAd{
    [self clearSetupInterstitialAd];
    self.interstitial = [[ANInterstitialAd alloc] initWithPlacementId:@"1"];
    self.interstitial.delegate = self;
}

- (void)clearSetupNativeAd {
    self.adRequest = nil;
    self.adResponse = nil;
    self.adResponseInfo = nil;
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
             [additionalView removeFromSuperview];
         }
}

-(void) setupNativeAd{
    [self clearSetupNativeAd];
    self.adRequest = [[ANNativeAdRequest alloc] init];
    self.adRequest.delegate = self;
}

- (void)clearSetupInstreamAd {
    self.instreamVideoAd = nil;
    self.instreamVideoAd.adPlayer = nil;
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
             [additionalView removeFromSuperview];
         }
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
    XCTAssertEqualObjects(self.banner.adResponseInfo.creativeId, @"163051950");
    XCTAssertEqualObjects(self.banner.adResponseInfo.placementId, @"16392991");
    XCTAssertTrue(self.banner.adResponseInfo.memberId == 10094);
    XCTAssertTrue(self.banner.adResponseInfo.adType == ANAdTypeBanner);
    XCTAssertEqualObjects(self.banner.adResponseInfo.contentSource, @"rtb");
    XCTAssertNil(self.banner.adResponseInfo.networkName);
    XCTAssertEqualObjects(self.banner.adResponseInfo.auctionId, @"9187200539711848928");

}


- (void)testAdResponseWithRTBBannerAdFailToLoadAd {
    
    [self setupBannerAd];
    [self stubRequestWithResponse:@"ANAdResponseRTB_BannerFail"];
    [self.banner loadAd];
    
    self.loadAdResponseFailedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqualObjects(self.banner.adResponseInfo.placementId, @"19881071");
    XCTAssertEqualObjects(self.banner.adResponseInfo.auctionId, @"8856182017388121550");

}

- (void)testAdResponseWithCSMBannerAdFailToLoadAd {
    
    [self setupBannerAd];
    [self stubRequestWithResponse:@"ANAdResponseCSM_BannerFail"];
    [self.banner loadAd];
    
    self.loadAdResponseFailedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqualObjects(self.banner.adResponseInfo.placementId, @"19881071");
    XCTAssertEqualObjects(self.banner.adResponseInfo.auctionId, @"8371000362677779861");
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
   XCTAssertEqualObjects(self.banner.adResponseInfo.creativeId, @"162039377");
   XCTAssertEqualObjects(self.banner.adResponseInfo.placementId, @"16392991");
   XCTAssertTrue(self.banner.adResponseInfo.memberId == 10094);
   XCTAssertTrue(self.banner.adResponseInfo.adType == ANAdTypeNative);
   XCTAssertEqualObjects(self.banner.adResponseInfo.contentSource, @"rtb");
   XCTAssertNil(self.banner.adResponseInfo.networkName);
   XCTAssertEqualObjects(self.banner.adResponseInfo.auctionId, @"4353110489672000411");
}

- (void) testAdResponseWithBannerNativeAdFailToLoadAd
{
    [self setupBannerAd];
    self.banner.shouldAllowNativeDemand = YES;
    self.banner.enableNativeRendering = YES;
    [self.banner setAdSize:CGSizeMake(300, 250)];
    [self stubRequestWithResponse:@"ANAdResponseRTB_NativeFail"];
    [self.banner loadAd];
    self.loadAdResponseFailedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
   [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                handler:^(NSError *error) {
                                    
                                }];
   XCTAssertEqualObjects(self.banner.adResponseInfo.placementId, @"19881071");
   XCTAssertEqualObjects(self.banner.adResponseInfo.auctionId, @"127336549891345873");
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
   XCTAssertEqualObjects(self.banner.adResponseInfo.creativeId, @"162035356");
   XCTAssertEqualObjects(self.banner.adResponseInfo.placementId, @"16392991");
   XCTAssertTrue(self.banner.adResponseInfo.memberId == 10094);
   XCTAssertTrue(self.banner.adResponseInfo.adType == ANAdTypeVideo);
   XCTAssertEqualObjects(self.banner.adResponseInfo.contentSource, @"rtb");
   XCTAssertNil(self.banner.adResponseInfo.networkName);
   XCTAssertEqualObjects(self.banner.adResponseInfo.auctionId, @"5025666871894732601");

}


- (void) testAdResponseWithBannerAdWithBid
{
    [self setupBannerAd];
    self.banner.shouldAllowVideoDemand = YES;
    [self.banner setAdSize:CGSizeMake(300, 250)];
    [self stubRequestWithResponse:@"CpmPublisherCurrencyBannerObjectResponse"];
    [self.banner loadAd];
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    XCTAssertEqualObjects(self.banner.adResponseInfo.creativeId, @"308555277");
    XCTAssertEqualObjects(self.banner.adResponseInfo.placementId, @"22170885");
    XCTAssertTrue(self.banner.adResponseInfo.memberId == 10094);
    XCTAssertTrue(self.banner.adResponseInfo.adType == ANAdTypeBanner);
    XCTAssertEqualObjects(self.banner.adResponseInfo.contentSource, @"rtb");
    XCTAssertEqualObjects(self.banner.adResponseInfo.cpm, [NSNumber numberWithFloat:[@(0.5) floatValue]]);
    XCTAssertEqualObjects(self.banner.adResponseInfo.cpmPublisherCurrency, [NSNumber numberWithFloat:[@(0.5) floatValue]]);
    XCTAssertEqualObjects(self.banner.adResponseInfo.publisherCurrencyCode, @"$");
    
}

- (void) testAdResponseWithBannerAdWithoutBid
{
    
    [self setupBannerAd];
    self.banner.shouldAllowVideoDemand = YES;
    [self.banner setAdSize:CGSizeMake(300, 250)];
    [self stubRequestWithResponse:@"ANAdResponseRTB_Banner"];
    [self.banner loadAd];
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    XCTAssertEqualObjects(self.banner.adResponseInfo.creativeId, @"163051950");
    XCTAssertEqualObjects(self.banner.adResponseInfo.placementId, @"16392991");
    XCTAssertTrue(self.banner.adResponseInfo.memberId == 10094);
    XCTAssertTrue(self.banner.adResponseInfo.adType == ANAdTypeBanner);
    XCTAssertNotEqualObjects(self.banner.adResponseInfo.cpm, @(0.500000));
    XCTAssertNotEqualObjects(self.banner.adResponseInfo.cpmPublisherCurrency, @(0.500000));
    XCTAssertNotEqualObjects(self.banner.adResponseInfo.publisherCurrencyCode, @"$");
    
}

- (void) testAdResponseWithBannerVideoAdFailToLoadAd
{
    [self setupBannerAd];
    self.banner.shouldAllowVideoDemand = YES;
    [self.banner setAdSize:CGSizeMake(300, 250)];
    [self stubRequestWithResponse:@"ANAdResponseRTB_VideoFail"];
    [self.banner loadAd];
    self.loadAdResponseFailedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
   [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                handler:^(NSError *error) {
                                    
                                }];
   XCTAssertEqualObjects(self.banner.adResponseInfo.placementId, @"19881071");
   XCTAssertEqualObjects(self.banner.adResponseInfo.auctionId, @"6677786726688787883");

}

- (void)testAdResponseWithInterstitialAd {
    
    [self setupInterstitialAd];
    [self stubRequestWithResponse:@"ANAdResponseRTB_Banner"];
    [self.interstitial loadAd];
    
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqualObjects(self.interstitial.adResponseInfo.creativeId, @"163051950");
    XCTAssertEqualObjects(self.interstitial.adResponseInfo.placementId, @"16392991");
    XCTAssertTrue(self.interstitial.adResponseInfo.memberId == 10094);
    XCTAssertTrue(self.interstitial.adResponseInfo.adType == ANAdTypeBanner);
    XCTAssertEqualObjects(self.interstitial.adResponseInfo.contentSource, @"rtb");
    XCTAssertNil(self.interstitial.adResponseInfo.networkName);
    XCTAssertEqualObjects(self.interstitial.adResponseInfo.auctionId, @"9187200539711848928");
}

- (void)testAdResponseWithInterstitialAdFailToLoadAd {
    
    [self setupInterstitialAd];
    [self stubRequestWithResponse:@"ANAdResponseRTB_BannerFail"];
    [self.interstitial loadAd];
    
    self.loadAdResponseFailedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqualObjects(self.interstitial.adResponseInfo.placementId, @"19881071");
    XCTAssertEqualObjects(self.interstitial.adResponseInfo.auctionId, @"8856182017388121550");
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
   XCTAssertEqualObjects(self.adResponse.adResponseInfo.creativeId, @"162039377");
   XCTAssertEqualObjects(self.adResponse.adResponseInfo.placementId, @"16392991");
   XCTAssertTrue(self.adResponse.adResponseInfo.memberId == 10094);
   XCTAssertTrue(self.adResponse.adResponseInfo.adType == ANAdTypeNative);
   XCTAssertEqualObjects(self.adResponse.adResponseInfo.contentSource, @"rtb");
   XCTAssertNil(self.adResponse.adResponseInfo.networkName);
   XCTAssertEqualObjects(self.adResponse.adResponseInfo.auctionId, @"4353110489672000411");

}

- (void)testAdResponseWithNativeAdFailToLoadAd {
    [self setupNativeAd];
    [self stubRequestWithResponse:@"ANAdResponseRTB_NativeFail"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
   self.loadAdResponseFailedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
   [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                handler:^(NSError *error) {
                                    
                                }];
   XCTAssertEqualObjects(self.adResponseInfo.placementId, @"19881071");
   XCTAssertEqualObjects(self.adResponseInfo.auctionId, @"127336549891345873");

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
   XCTAssertEqualObjects(self.instreamVideoAd.adResponseInfo.creativeId, @"162035356");
   XCTAssertEqualObjects(self.instreamVideoAd.adResponseInfo.placementId, @"16392991");
   XCTAssertTrue(self.instreamVideoAd.adResponseInfo.memberId == 10094);
   XCTAssertTrue(self.instreamVideoAd.adResponseInfo.adType == ANAdTypeVideo);
   XCTAssertEqualObjects(self.instreamVideoAd.adResponseInfo.contentSource, @"rtb");
   XCTAssertNil(self.instreamVideoAd.adResponseInfo.networkName);
   XCTAssertEqualObjects(self.instreamVideoAd.adResponseInfo.auctionId, @"5025666871894732601");
}

- (void) testAdResponseWithInstreamAdFailToLoadAd
{
    [self setupInstreamAd];
    [self stubRequestWithResponse:@"ANAdResponseRTB_VideoFail"];
    [self.instreamVideoAd loadAdWithDelegate:self];
    self.loadAdResponseFailedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
   [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                handler:^(NSError *error) {
                                    
                                }];
   XCTAssertEqualObjects(self.instreamVideoAd.adResponseInfo.placementId, @"19881071");
   XCTAssertEqualObjects(self.instreamVideoAd.adResponseInfo.auctionId, @"6677786726688787883");
}

/**
 Tests banner DSA response
 */
- (void)testAdResponseWithBannerDSA
{
    [self setupBannerAd];
    [self stubRequestWithResponse:@"ANDSAResponse_Banner"];
    [self.banner loadAd];
    
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqualObjects(self.banner.adResponseInfo.dsaResponseInfo.behalf, @"test");
    XCTAssertEqualObjects(self.banner.adResponseInfo.dsaResponseInfo.paid, @"testname");
    XCTAssertTrue(self.banner.adResponseInfo.dsaResponseInfo.adRender == 1);
    NSArray<NSNumber *> *expectedParams = @[@1, @2, @3];
    for (ANDSATransparencyInfo *transparencyInfo in self.banner.adResponseInfo.dsaResponseInfo.transparencyList) {
        XCTAssertEqualObjects(transparencyInfo.domain, @"test.com");
        XCTAssertEqualObjects(transparencyInfo.dsaparams, expectedParams);
    }
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
        [self.interstitial displayAdFromViewController:[ANGlobal getKeyWindow].rootViewController];
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

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error withAdResponseInfo:(ANAdResponseInfo *)adResponseInfo{
    TESTTRACEM(@"error.info=%@", error.userInfo);
    self.adResponseInfo = adResponseInfo;
    [self.loadAdResponseReceivedExpectation fulfill];
    [self.loadAdResponseFailedExpectation fulfill];
    self.receiveAdFailure = YES;
}
@end
