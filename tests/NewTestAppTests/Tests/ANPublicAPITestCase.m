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
#import "ANTestGlobal.h"
#import "ANURLConnectionStub.h"
#import "ANHTTPStubbingManager.h"
#import "XCTestCase+ANCategory.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "NSURLRequest+HTTPBodyTesting.h"

@interface ANPublicAPITestCase : XCTestCase

@property (nonatomic, readwrite, strong)  XCTestExpectation     *requestExpectation;
@property (nonatomic, readwrite, strong)  ANBannerAdView        *banner;
@property (nonatomic, readwrite, strong)  ANInterstitialAd      *interstitial;
@property (nonatomic)                     NSURLRequest          *request;

@end


@implementation ANPublicAPITestCase

#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [self setupRequestTracker];
}

- (void)tearDown {
    [super tearDown];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark - Test helper methods.

- (void)setupRequestTracker {
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestLoaded:)
                                                 name:kANHTTPStubURLProtocolRequestDidLoadNotification
                                               object:nil];
}

- (void)requestLoaded:(NSNotification *)notification
{
TESTTRACE();
    if (self.requestExpectation) {
        self.request = notification.userInfo[kANHTTPStubURLProtocolRequest];
        [self.requestExpectation fulfill];
        self.requestExpectation = nil;
    }
}

- (void)stubRequestWithResponse:(NSString *)responseName
{
    NSBundle  *currentBundle  = [NSBundle bundleForClass:[self class]];
    NSString  *baseResponse   = [NSString stringWithContentsOfFile: [currentBundle pathForResource:responseName ofType:@"json"]
                                                          encoding: NSUTF8StringEncoding
                                                             error: nil ];

    ANURLConnectionStub *requestStub = [[ANURLConnectionStub alloc] init];

    requestStub.requestURL    = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    requestStub.responseCode  = 200;
    requestStub.responseBody  = baseResponse;

    [[ANHTTPStubbingManager sharedStubbingManager] addStub:requestStub];
}

- (NSDictionary *) getJSONBodyOfURLRequestAsDictionary: (NSURLRequest *)urlRequest
{
    NSString      *bodyAsString  = [[NSString alloc] initWithData:[urlRequest ANHTTPStubs_HTTPBody] encoding:NSUTF8StringEncoding];
    NSData        *objectData    = [bodyAsString dataUsingEncoding:NSUTF8StringEncoding];
    NSError       *error         = nil;

    NSDictionary  *json          = [NSJSONSerialization JSONObjectWithData: objectData
                                                                   options: NSJSONReadingMutableContainers
                                                                     error: &error];
    if (error)  { return nil; }

    return  json;
}


#pragma mark - Test methods.

- (void)testSetPlacementOnlyOnBanner
{
    [self stubRequestWithResponse:@"SuccessfulMRAIDResponse"];
    self.requestExpectation = [self expectationWithDescription:@"request"];

    self.banner = [[ANBannerAdView alloc]
                   initWithFrame:CGRectMake(0, 0, 320, 50)
                   placementId:@"1"
                   adSize:CGSizeMake(320, 50)];

    [self.banner loadAd];
    [self waitForExpectationsWithTimeout: 2 * kAppNexusRequestTimeoutInterval
                                 handler: ^(NSError * _Nullable error) { /*EMPTY*/ }
             ];
    self.requestExpectation = nil;

    //
    XCTAssertEqual(@"1", [self.banner placementId]);

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    XCTAssertEqual([jsonBody[@"tags"][0][@"id"] integerValue], 1);
}

- (void)testSetInventoryCodeAndMemberIDOnBanner
{
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

    //
    XCTAssertEqual(@"test", [self.banner inventoryCode]);
    XCTAssertEqual(1, [self.banner memberId]);

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];

    XCTAssertEqual([jsonBody[@"member_id"] integerValue], 1);

    NSString  *codeValue  = jsonBody[@"tags"][0][@"code"];   //XXX  @"code" value is of type NSTaggedPointerString.
    XCTAssertEqual([codeValue isEqualToString:@"test"], YES);
}

//NB  Both placementID and (inventoryCode, memberID) tuple exist in the class,
//    but (inventoryCode, memberID) tuple take precedence over placementID in the UT Request.
//
- (void)testSetInventoryCodeAndPlacementIdOnBanner
{
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

    //
    XCTAssertEqual(@"1",        [self.banner placementId]);
    XCTAssertEqual(@"test",     [self.banner inventoryCode]);
    XCTAssertEqual(2,           [self.banner memberId]);

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];

    XCTAssertNil(jsonBody[@"tags"][0][@"id"]);

    XCTAssertEqual([jsonBody[@"member_id"] integerValue], 2);

    NSString  *codeValue  = jsonBody[@"tags"][0][@"code"];   //XXX  @"code" value is of type NSTaggedPointerString.
    XCTAssertEqual([codeValue isEqualToString:@"test"], YES);
}

- (void)testSetPlacementOnlyOnInterstitial
{
    [self stubRequestWithResponse:@"SuccessfulMRAIDResponse"];
    self.requestExpectation = [self expectationWithDescription:@"request"];

    self.interstitial = [[ANInterstitialAd alloc] initWithPlacementId:@"1"];
    [self.interstitial loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
    self.requestExpectation = nil;

    //
    XCTAssertEqual(@"1", [self.interstitial placementId]);

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    XCTAssertEqual([jsonBody[@"tags"][0][@"id"] integerValue], 1);
}

- (void)testSetInventoryCodeAndMemberIDOnInterstitial
{
    [self stubRequestWithResponse:@"SuccessfulMRAIDResponse"];
    self.requestExpectation = [self expectationWithDescription:@"request"];

    self.interstitial = [[ANInterstitialAd alloc] initWithMemberId:2
                                                     inventoryCode:@"test"];
    [self.interstitial loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
    self.requestExpectation = nil;

    //
    XCTAssertEqual(@"test", [self.interstitial inventoryCode]);
    XCTAssertEqual(2, [self.interstitial memberId]);

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];

    XCTAssertEqual([jsonBody[@"member_id"] integerValue], 2);

    NSString  *codeValue  = jsonBody[@"tags"][0][@"code"];   //XXX  @"code" value is of type NSTaggedPointerString.
    XCTAssertEqual([codeValue isEqualToString:@"test"], YES);
}

//NB  Both placementID and (inventoryCode, memberID) tuple exist in the class,
//    but (inventoryCode, memberID) tuple take precedence over placementID in the UT Request.
//
- (void)testSetBothInventoryCodeAndPlacementIdOnInterstitial
{
    self.requestExpectation = [self expectationWithDescription:@"request"];
    [self stubRequestWithResponse:@"SuccessfulMRAIDResponse"];

    self.interstitial = [[ANInterstitialAd alloc] initWithPlacementId:@"1"];
    [self.interstitial setInventoryCode:@"test" memberId:2];
    [self.interstitial loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
    self.requestExpectation = nil;

    //
    XCTAssertEqual(@"1", [self.interstitial placementId]);
    XCTAssertEqual(@"test", [self.interstitial inventoryCode]);
    XCTAssertEqual(2, [self.interstitial memberId]);

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];

    XCTAssertNil(jsonBody[@"tags"][0][@"id"]);

    XCTAssertEqual([jsonBody[@"member_id"] integerValue], 2);

    NSString  *codeValue  = jsonBody[@"tags"][0][@"code"];   //XXX  @"code" value is of type NSTaggedPointerString.
    XCTAssertEqual([codeValue isEqualToString:@"test"], YES);
}

@end
