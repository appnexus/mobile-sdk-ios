/*
 *
 *    Copyright 2017 APPNEXUS INC
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */


#import <XCTest/XCTest.h>

#import "ANGlobal.h"
#import "ANTestGlobal.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"

#import "ANInstreamVideoAd.h"
#import "ANInstreamVideoAd+Test.h"
#import "ANVideoAdPlayer.h"
#import "XandrAd.h"


static NSString   *placementID      = @"12534678";
static NSInteger   memberID         = 958;
static NSString   *inventoryCode    = @"trucksmash";



@interface ANInstreamVideoAdTestCase : XCTestCase <ANInstreamVideoAdLoadDelegate>

@property (nonatomic, readwrite, strong)  ANInstreamVideoAd  *instreamVideoAd;

@property (nonatomic, strong)  XCTestExpectation  *expectationLoadVideoAd;

@property (nonatomic, strong)  NSURLRequest  *request;
@property (nonatomic, strong)  NSDictionary  *jsonRequestBody;

@end




@implementation ANInstreamVideoAdTestCase

#pragma mark - Test lifecycle.

- (void)setUp
{
    [super setUp];
    [[ANSDKSettings sharedInstance] optionalSDKInitialization:nil];
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;

    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = YES;
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(requestLoaded:)
                                                 name: kANHTTPStubURLProtocolRequestDidLoadNotification
                                               object: nil ];

    self.request = nil;
}

- (void)tearDown
{
    [super tearDown];
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];

    self.instreamVideoAd = nil;
    self.expectationLoadVideoAd = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
        [additionalView removeFromSuperview];
    }
}




#pragma mark - Test methods.

- (void)testInitializeWithPlacementID
{
    ANInstreamVideoAd  *instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithPlacementId:placementID];

    [self stubRequestWithResponse:@"SuccessfulInstreamVideoAdResponse"];

    [instreamVideoAd loadAdWithDelegate:self];

    self.expectationLoadVideoAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];

    //
    XCTAssertEqual(instreamVideoAd.placementId, placementID);
    XCTAssertEqual([self.jsonRequestBody[@"tags"][0][@"id"] integerValue], [placementID integerValue]);

}

- (void)testInitializeWithForceCreativeID
{
    ANInstreamVideoAd  *instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithPlacementId:placementID];
    instreamVideoAd.forceCreativeId = 135482485;
    [self stubRequestWithResponse:@"SuccessfulInstreamVideoAdResponse"];

    [instreamVideoAd loadAdWithDelegate:self];

    self.expectationLoadVideoAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];

    //
    XCTAssertEqual(135482485, instreamVideoAd.forceCreativeId);
    XCTAssertEqual([self.jsonRequestBody[@"tags"][0][@"force_creative_id"] integerValue], 135482485);

}

- (void)testInitializeWithMemberIDAndCode
{
    ANInstreamVideoAd  *instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithMemberId:958 inventoryCode:@"trucksmash"];

    [self stubRequestWithResponse:@"SuccessfulInstreamVideoAdResponse"];

    [instreamVideoAd loadAdWithDelegate:self];

    self.expectationLoadVideoAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];

    XCTAssertEqual(instreamVideoAd.memberId, memberID);
    XCTAssertEqual(instreamVideoAd.inventoryCode, inventoryCode);
    XCTAssertEqual([self.jsonRequestBody[@"member_id"] integerValue], memberID);
    XCTAssertTrue([self.jsonRequestBody[@"tags"][0][@"code"] isEqualToString:inventoryCode]);
}



- (void)testCustomKeywordsAdded
{
    ANInstreamVideoAd  *instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithPlacementId:placementID];
    [instreamVideoAd addCustomKeywordWithKey:@"force_creative_id" value:@"123456789"];
    [self stubRequestWithResponse:@"SuccessfulInstreamVideoAdResponse"];
    
    [instreamVideoAd loadAdWithDelegate:self];
    
    self.expectationLoadVideoAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertEqualObjects(self.jsonRequestBody[@"tags"][0][@"keywords"][0][@"key"], @"force_creative_id");
    XCTAssertEqualObjects(self.jsonRequestBody[@"tags"][0][@"keywords"][0][@"value"][0], @"123456789");

    XCTAssertEqual(instreamVideoAd.placementId, placementID);
}

- (void)testTrafficSourceCode
{
    ANInstreamVideoAd  *instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithPlacementId:placementID];
    [instreamVideoAd setTrafficSourceCode:@"Xandr"];
    [self stubRequestWithResponse:@"SuccessfulInstreamVideoAdResponse"];
    
    [instreamVideoAd loadAdWithDelegate:self];
    
    self.expectationLoadVideoAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertEqualObjects(self.jsonRequestBody[@"tags"][0][@"traffic_source_code"], @"Xandr");
    XCTAssertNil(self.jsonRequestBody[@"tags"][0][@"ext_inv_code"]);
    instreamVideoAd = nil;
}


- (void)testExtInvCode
{
    ANInstreamVideoAd  *instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithPlacementId:placementID];
    [instreamVideoAd setExtInvCode:@"Xandr"];
    [self stubRequestWithResponse:@"SuccessfulInstreamVideoAdResponse"];
    
    [instreamVideoAd loadAdWithDelegate:self];
    
    self.expectationLoadVideoAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertEqualObjects(self.jsonRequestBody[@"tags"][0][@"ext_inv_code"], @"Xandr");
    XCTAssertNil(self.jsonRequestBody[@"tags"][0][@"traffic_source_code"]);
    instreamVideoAd = nil;
}

- (void)testTrafficSourceCodeAndExtInvCodeSet
{
    ANInstreamVideoAd  *instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithPlacementId:placementID];
    [self stubRequestWithResponse:@"SuccessfulInstreamVideoAdResponse"];
    [instreamVideoAd setExtInvCode:@"Xandr-ext_inv_code"];
    [instreamVideoAd setTrafficSourceCode:@"Xandr-traffic_source_code"];
    
    [instreamVideoAd loadAdWithDelegate:self];
    
    self.expectationLoadVideoAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    XCTAssertEqualObjects(self.jsonRequestBody[@"tags"][0][@"traffic_source_code"], @"Xandr-traffic_source_code");
    XCTAssertEqualObjects(self.jsonRequestBody[@"tags"][0][@"ext_inv_code"], @"Xandr-ext_inv_code");
    instreamVideoAd = nil;
}

- (void)testTrafficSourceCodeAndExtInvCodeNotSet
{
    ANInstreamVideoAd  *instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithPlacementId:placementID];
    [self stubRequestWithResponse:@"SuccessfulInstreamVideoAdResponse"];
    
    [instreamVideoAd loadAdWithDelegate:self];
    
    self.expectationLoadVideoAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    NSDictionary *tag = self.jsonRequestBody[@"tags"][0];
    XCTAssertFalse([tag objectForKey:@"ext_inv_code"]);
    XCTAssertFalse([tag objectForKey:@"traffic_source_code"]);
    instreamVideoAd = nil;
}

- (void)testTrafficSourceCodeAndExtInvCodeNullSet
{
    ANInstreamVideoAd  *instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithPlacementId:placementID];
    [self stubRequestWithResponse:@"SuccessfulInstreamVideoAdResponse"];
    [instreamVideoAd setExtInvCode:NULL];
    [instreamVideoAd setTrafficSourceCode:NULL];
    
    [instreamVideoAd loadAdWithDelegate:self];
    
    self.expectationLoadVideoAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    NSDictionary *tag = self.jsonRequestBody[@"tags"][0];
    XCTAssertFalse([tag objectForKey:@"ext_inv_code"]);
    XCTAssertFalse([tag objectForKey:@"traffic_source_code"]);
    instreamVideoAd = nil;
}


- (void)testAdDuration {
        [self initializeInstreamVideoWithAllProperties];
        NSLog(@"reached here");
        XCTAssertNotNil(self.instreamVideoAd);
        NSUInteger duration = [self.instreamVideoAd getAdDuration];
        XCTAssertNotEqual(duration, 0);
 }

-(void) testVastCreativeURL {
    
        [self initializeInstreamVideoWithAllProperties];
        NSLog(@"reached here");
        XCTAssertNotNil(self.instreamVideoAd);
        NSString *vastcreativeTag = [self.instreamVideoAd getVastURL];
        XCTAssertNotNil(vastcreativeTag);
        XCTAssertNotEqual(vastcreativeTag.length, 0);
        XCTAssertNotNil(vastcreativeTag);
        XCTAssertEqual(vastcreativeTag, @"http://sampletag.com");
}

-(void) testVastCreativeXML {
    
    [self initializeInstreamVideoWithAllProperties];
    NSLog(@"reached here");
    XCTAssertNotNil(self.instreamVideoAd);
    NSString *vastcreativeXMLTag = [self.instreamVideoAd getVastXML];
    XCTAssertNotNil(vastcreativeXMLTag);
    XCTAssertNotEqual(vastcreativeXMLTag.length, 0);
    XCTAssertNotNil(vastcreativeXMLTag);
    XCTAssertEqual(vastcreativeXMLTag, @"http://sampletag.com");
}

-(void) testCreativeTag {
        [self initializeInstreamVideoWithAllProperties];
        NSLog(@"reached here");
        XCTAssertNotNil(self.instreamVideoAd);
        NSString *creativeTag = [self.instreamVideoAd getCreativeURL];
        XCTAssertNotEqual(creativeTag.length, 0);
        XCTAssertNotNil(creativeTag);
        XCTAssertEqual(creativeTag, @"http://sampletag.com");
}

-(void) testAdDurationNotSet {
        [self initializeInstreamVideoWithNoProperties];
        XCTAssertNotNil(self.instreamVideoAd);
        NSUInteger duration = [self.instreamVideoAd getAdDuration];
        XCTAssertEqual(duration, 0);
}

-(void) testVastCreativeValuesNotSet {
        [self initializeInstreamVideoWithNoProperties];
        XCTAssertNotNil(self.instreamVideoAd);
        NSString *vastcreativeTag = [self.instreamVideoAd getVastURL];
        XCTAssertEqual(vastcreativeTag.length, 0);
}

-(void) testCreativeValuesNotSet {
    
        [self initializeInstreamVideoWithNoProperties];
        XCTAssertNotNil(self.instreamVideoAd);
        NSString *creativeTag = [self.instreamVideoAd getCreativeURL];
        XCTAssertEqual(creativeTag.length, 0);
}

-(void) testVastCreativeXMLValuesNotSet {
    [self initializeInstreamVideoWithNoProperties];
    XCTAssertNotNil(self.instreamVideoAd);
    NSString *vastcreativeXMLTag = [self.instreamVideoAd getVastXML];
    XCTAssertEqual(vastcreativeXMLTag.length, 0);
}

-(void) testPlayHeadTimeForVideoSet {
    [self initializeInstreamVideoWithNoProperties];
    XCTAssertNotNil(self.instreamVideoAd);
    NSUInteger duration = [self.instreamVideoAd getAdPlayElapsedTime];
    XCTAssertNotEqual(duration, 0);
}

- (void)testVerticalVideoOrientation
{
    ANInstreamVideoAd  *instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithPlacementId:placementID];
    
    [self stubRequestWithResponse:@"SuccessfulVerticalVideoAdResponse"];
    
    [instreamVideoAd loadAdWithDelegate:self];
    
    self.expectationLoadVideoAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    
    //
    XCTAssertEqual(instreamVideoAd.getVideoOrientation, ANPortrait);
    
}


- (void)testLandscapeVideoOrientation
{
    ANInstreamVideoAd  *instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithPlacementId:placementID];
    
    [self stubRequestWithResponse:@"SuccessfulInstreamVideoAdResponse"];
    
    [instreamVideoAd loadAdWithDelegate:self];
    
    self.expectationLoadVideoAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    
    //
    XCTAssertEqual(instreamVideoAd.getVideoOrientation, ANLandscape);
    
}



- (void)testSquareVideoOrientation
{
    ANInstreamVideoAd  *instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithPlacementId:placementID];
    
    [self stubRequestWithResponse:@"SuccessfulSquareInstreamVideoAdResponse"];
    
    [instreamVideoAd loadAdWithDelegate:self];
    
    self.expectationLoadVideoAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    
    //
    XCTAssertEqual(instreamVideoAd.getVideoOrientation, ANSquare);
    
}

#pragma mark - Helper methods.

-(void) initializeInstreamVideoWithAllProperties {
    self.instreamVideoAd = [[ANInstreamVideoAd alloc] init];
    self.instreamVideoAd.adPlayer = [[ANVideoAdPlayer alloc] init];
    self.instreamVideoAd.adPlayer.videoDuration = 10;
    self.instreamVideoAd.adPlayer.creativeURL = @"http://sampletag.com";
    self.instreamVideoAd.adPlayer.vastURLContent = @"http://sampletag.com";
    self.instreamVideoAd.adPlayer.vastXMLContent = @"http://sampletag.com";
    
}

-(void) initializeInstreamVideoWithNoProperties {
    self.instreamVideoAd = [[ANInstreamVideoAd alloc] init];
    self.instreamVideoAd.adPlayer = [[ANVideoAdPlayer alloc] init];
}

- (void) stubRequestWithResponse:(NSString *)responseName
{
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

- (void)requestLoaded:(NSNotification *)notification
{
    NSURLRequest  *incomingRequest  = notification.userInfo[kANHTTPStubURLProtocolRequest];

    NSString  *requestString  = [[incomingRequest URL] absoluteString];
    NSString  *searchString   = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];

    if (!self.request && [requestString containsString:searchString])
    {
        self.request          = notification.userInfo[kANHTTPStubURLProtocolRequest];
        self.jsonRequestBody  = [ANHTTPStubbingManager jsonBodyOfURLRequestAsDictionary:self.request];
    }
}




#pragma mark - ANInstreamVideoAdLoadDelegate.

- (void)adDidReceiveAd:(id)ad
{
TESTTRACE();

    [self.expectationLoadVideoAd fulfill];
}

- (void)ad:(id)ad requestFailedWithError:(NSError *)error
{
TESTTRACE();
}


@end
