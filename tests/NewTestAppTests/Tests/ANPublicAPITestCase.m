/*   Copyright 2015 APPNEXUS INC
 
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ANBannerAdView.h"
#import "ANInterstitialAd.h"
#import "ANGlobal.h"
#import "ANURLConnectionStub.h"
#import "ANHTTPStubbingManager.h"
#import "XCTestCase+ANCategory.h"

@interface ANPublicAPITestCase : XCTestCase

@property (nonatomic, readwrite, strong) XCTestExpectation *requestExpectation;
@property (nonatomic, readwrite, strong) ANBannerAdView *banner;
@property (nonatomic, readwrite, strong) ANInterstitialAd *interstitial;
@property (nonatomic) NSURLRequest *request;

@end

@implementation ANPublicAPITestCase

- (void)setUp {
    [super setUp];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [self setupRequestTracker];
}

- (void)tearDown {
    [super tearDown];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
}

- (void)setupRequestTracker {
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestLoaded:)
                                                 name:kANHTTPStubURLProtocolRequestDidLoadNotification
                                               object:nil];
}

- (void)requestLoaded:(NSNotification *)notification {
    self.request = notification.userInfo[kANHTTPStubURLProtocolRequest];
    [self.requestExpectation fulfill];
}

- (void)testSetPlacementOnlyOnBanner {
    [self stubRequestWithResponse:@"SuccessfulMRAIDResponse"];
    self.requestExpectation = [self expectationWithDescription:@"request"];
    self.banner = [[ANBannerAdView alloc]
                   initWithFrame:CGRectMake(0, 0, 320, 50)
                   placementId:@"1"
                   adSize:CGSizeMake(320, 50)];
    [self.banner loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
    self.requestExpectation = nil;
    NSString *requestPath = [[self.request URL] absoluteString];
    XCTAssertEqual(@"1", [self.banner placementId]);
    XCTAssertTrue([requestPath containsString:@"?id=1"]);
}

- (void)testSetInventoryCodeAndMemberIDOnBanner {
    [self stubRequestWithResponse:@"SuccessfulMRAIDResponse"];
        self.requestExpectation = [self expectationWithDescription:@"request"];
    self.banner = [[ANBannerAdView alloc]
                   initWithFrame:CGRectMake(0, 0, 320, 50)
                   memberId:1
                   inventoryCode:@"test"
                   adSize:CGSizeMake(320, 50)];
    [self.banner loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
    self.requestExpectation = nil;
    NSString *requestPath = [[self.request URL] absoluteString];
    XCTAssertEqual(@"test", [self.banner inventoryCode]);
    XCTAssertEqual(1, [self.banner memberId]);
    XCTAssertTrue([requestPath containsString:@"?member=1&inv_code=test"]);
}

- (void)testSetBothInventoryCodeAndPlacementIdOnBanner {
    [self stubRequestWithResponse:@"SuccessfulMRAIDResponse"];
    self.requestExpectation = [self expectationWithDescription:@"request"];
    self.banner = [[ANBannerAdView alloc]
                   initWithFrame:CGRectMake(0, 0, 320, 50)
                   placementId:@"1"
                   adSize:CGSizeMake(320, 50)];
    [self.banner setInventoryCode:@"test" memberId:2];
    [self.banner loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
    self.requestExpectation = nil;
    NSString *requestPath = [[self.request URL] absoluteString];
    XCTAssertEqual(@"1", [self.banner placementId]);
    XCTAssertEqual(@"test", [self.banner inventoryCode]);
    XCTAssertEqual(2, [self.banner memberId]);
    XCTAssertTrue([requestPath containsString:@"?member=2&inv_code=test"]);
}

- (void)testSetPlacementOnlyOnInterstitial {
    [self stubRequestWithResponse:@"SuccessfulMRAIDResponse"];
    self.requestExpectation = [self expectationWithDescription:@"request"];
    self.interstitial = [[ANInterstitialAd alloc] initWithPlacementId:@"1"];
    [self.interstitial loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
    self.requestExpectation = nil;
    NSString *requestPath = [[self.request URL] absoluteString];
    XCTAssertEqual(@"1", [self.interstitial placementId]);
    XCTAssertTrue([requestPath containsString:@"?id=1"]);
}

- (void)testSetInventoryCodeAndMemberIDOnInterstitial {
    [self stubRequestWithResponse:@"SuccessfulMRAIDResponse"];
    self.requestExpectation = [self expectationWithDescription:@"request"];
    self.interstitial = [[ANInterstitialAd alloc] initWithMemberId:2
                                                     inventoryCode:@"test"];
    [self.interstitial loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
    self.requestExpectation = nil;
    NSString *requestPath = [[self.request URL] absoluteString];
    XCTAssertEqual(@"test", [self.interstitial inventoryCode]);
    XCTAssertEqual(2, [self.interstitial memberId]);
    XCTAssertTrue([requestPath containsString:@"?member=2&inv_code=test"]);
}

- (void)testSetBothInventoryCodeAndPlacementIdOnInterstitial {
    self.requestExpectation = [self expectationWithDescription:@"request"];
    [self stubRequestWithResponse:@"SuccessfulMRAIDResponse"];
    self.interstitial = [[ANInterstitialAd alloc] initWithPlacementId:@"1"];
    [self.interstitial setInventoryCode:@"test" memberId:2];
    [self.interstitial loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
    self.requestExpectation = nil;
    NSString *requestPath = [[self.request URL] absoluteString];
    XCTAssertEqual(@"1", [self.interstitial placementId]);
    XCTAssertEqual(@"test", [self.interstitial inventoryCode]);
    XCTAssertEqual(2, [self.interstitial memberId]);
    XCTAssertTrue([requestPath containsString:@"?member=2&inv_code=test"]);
}

- (void)stubRequestWithResponse:(NSString *)responseName {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *baseResponse = [NSString stringWithContentsOfFile:[currentBundle pathForResource:responseName
                                                                                        ofType:@"json"]
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    ANURLConnectionStub *requestStub = [[ANURLConnectionStub alloc] init];
    requestStub.requestURLRegexPatternString = @"http://mediation.adnxs.com/mob\\?.*";
    requestStub.responseCode = 200;
    requestStub.responseBody = baseResponse;
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:requestStub];
}


@end
