/*   Copyright 2022 APPNEXUS INC
 
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
#define kAppNexusRequestTimeoutInterval 30.0


#import <Foundation/Foundation.h>

#if TARGET_OS_IOS

#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

#import <XCTest/XCTest.h>

@import AppNexusNativeMacOSSDK;
#import "ANTestGlobal.h"
#import "ANURLConnectionStub.h"
#import "ANHTTPStubbingManager.h"
#import "NSURLRequest+HTTPBodyTesting.h"




@interface ANNativeAdRequestTestCase : XCTestCase <ANNativeAdRequestDelegate,ANNativeAdDelegate>

@property (nonatomic, readwrite, strong)  ANNativeAdRequest     *adRequest;
@property (nonatomic, readwrite, strong)  ANNativeAdResponse    *adResponseInfo;

@property (nonatomic)                     NSURLRequest  *request;
@property (nonatomic, readwrite, strong)  NSError       *adRequestError;

@property (nonatomic, readwrite, strong)  XCTestExpectation  *requestExpectation;
@property (nonatomic, readwrite, strong)  XCTestExpectation  *delegateCallbackExpectation;

@property (nonatomic, readwrite, assign)  BOOL  successfulAdCall;
@property (nonatomic, readwrite, strong) XCTestExpectation *nativeAdWillExpireExpectation;
@property (nonatomic, readwrite, strong) XCTestExpectation *nativeAdDidExpireExpectation;

@end



@implementation ANNativeAdRequestTestCase



#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];

    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [self setupRequestTracker];
    
    self.adRequest = [[ANNativeAdRequest alloc] init];
    self.adRequest.delegate = self;
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];

}

- (void)tearDown {
    [super tearDown];

    self.adRequest.delegate = nil;
    self.adRequest = nil;
    self.delegateCallbackExpectation = nil;
    self.successfulAdCall = NO;
    self.adResponseInfo = nil;
    self.adRequestError = nil;
    ANSDKSettings.sharedInstance.publisherUserId = nil;
    self.nativeAdWillExpireExpectation = nil;
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)setupRequestTracker {
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestLoaded:)
                                                 name:kANHTTPStubURLProtocolRequestDidLoadNotification
                                               object:nil];
}

- (void)requestLoaded:(NSNotification *)notification {
    if (self.requestExpectation) {
        self.request = notification.userInfo[kANHTTPStubURLProtocolRequest];
        [self.requestExpectation fulfill];
        self.requestExpectation = nil;
    }
}



#pragma mark - Test methods.

- (void)testSetPlacementIdOnlyOnNative
{
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest setPlacementId:@"1"];
    ANSDKSettings.sharedInstance.publisherUserId = @"AppNexus";
    
    self.requestExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
    self.requestExpectation = nil;

    XCTAssertEqual(@"1", [self.adRequest placementId]);
    
    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    XCTAssertEqual([jsonBody[@"tags"][0][@"id"] integerValue], 1);
    // externalUid Test
    NSDictionary *user = jsonBody[@"user"];
    NSString *externalUid = user[@"external_uid"];
    XCTAssertNotNil(externalUid);
    XCTAssertEqualObjects(externalUid, @"AppNexus");
    
}

- (void)testSetForceCreativeIdOnlyOnNative
{
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    self.adRequest.forceCreativeId = 135482485;
    
    self.requestExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
    self.requestExpectation = nil;

    XCTAssertEqual(135482485, self.adRequest.forceCreativeId);
    
    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    XCTAssertEqual([jsonBody[@"tags"][0][@"force_creative_id"] integerValue], 135482485);
    
}


- (void)testTrafficSourceCodeAndExtInvCodeSet {

    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest setInventoryCode:@"test" memberId:2];
    [self.adRequest setExtInvCode:@"Xandr-ext_inv_code"];
    [self.adRequest setTrafficSourceCode:@"Xandr-traffic_source_code"];
    
    self.requestExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adRequest loadAd];
    [self waitForExpectationsWithTimeout:4 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    self.requestExpectation = nil;
    
    XCTAssertEqual(2, [self.adRequest memberId]);
    XCTAssertEqual(@"test", [self.adRequest inventoryCode]);
    
    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    XCTAssertEqualObjects(jsonBody[@"tags"][0][@"traffic_source_code"], @"Xandr-traffic_source_code");
    XCTAssertEqualObjects(jsonBody[@"tags"][0][@"ext_inv_code"], @"Xandr-ext_inv_code");
    
    
}



- (void)testExtInvCode {
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest setInventoryCode:@"test" memberId:2];
    [self.adRequest setExtInvCode:@"Xandr-traffic_source_code"];
    
    self.requestExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    self.requestExpectation = nil;
    
    XCTAssertEqual(2, [self.adRequest memberId]);
    XCTAssertEqual(@"test", [self.adRequest inventoryCode]);
    
    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    NSDictionary *tag = jsonBody[@"tags"][0];
    XCTAssertEqualObjects(tag[@"ext_inv_code"], @"Xandr-traffic_source_code");
    XCTAssertFalse([tag objectForKey:@"traffic_source_code"]);
}


- (void)testTrafficSourceCode {

    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest setInventoryCode:@"test" memberId:2];
    [self.adRequest setTrafficSourceCode:@"Xandr-traffic_source_code"];
    
    self.requestExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    self.requestExpectation = nil;
    
    XCTAssertEqual(2, [self.adRequest memberId]);
    XCTAssertEqual(@"test", [self.adRequest inventoryCode]);
    
    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    NSDictionary *tag = jsonBody[@"tags"][0];
    XCTAssertFalse([tag objectForKey:@"ext_inv_code"]);
    XCTAssertEqualObjects(tag[@"traffic_source_code"], @"Xandr-traffic_source_code");
    
}





- (void)testTrafficSourceCodeAndExtInvCodeNotSet {
    
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest setInventoryCode:@"test" memberId:2];
    
    self.requestExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    self.requestExpectation = nil;
    
    XCTAssertEqual(2, [self.adRequest memberId]);
    XCTAssertEqual(@"test", [self.adRequest inventoryCode]);
    
    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    NSDictionary *tag = jsonBody[@"tags"][0];
    XCTAssertFalse([tag objectForKey:@"ext_inv_code"]);
    XCTAssertFalse([tag objectForKey:@"traffic_source_code"]);
}


- (void)testSetInventoryCodeAndMemberIdOnlyOnNative {

    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest setInventoryCode:@"test" memberId:2];
    ANSDKSettings.sharedInstance.publisherUserId = @"AppNexus";
    self.requestExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    self.requestExpectation = nil;

    XCTAssertEqual(2, [self.adRequest memberId]);
    XCTAssertEqual(@"test", [self.adRequest inventoryCode]);

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    XCTAssertNil(jsonBody[@"tags"][0][@"id"]);
    XCTAssertEqual([jsonBody[@"member_id"] integerValue], 2);
    NSString  *codeValue  = jsonBody[@"tags"][0][@"code"];   //@"code" value is of type NSTaggedPointerString.
    XCTAssertEqual([codeValue isEqualToString:@"test"], YES);
    // externalUid Test
    NSDictionary *user = jsonBody[@"user"];
    NSString *externalUid = user[@"external_uid"];
    XCTAssertNotNil(externalUid);
    XCTAssertEqualObjects(externalUid, @"AppNexus");

}

- (void)testSetBothInventoryCodeAndPlacementIdOnNative {
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest setInventoryCode:@"test" memberId:2];
    [self.adRequest setPlacementId:@"1"];
    ANSDKSettings.sharedInstance.publisherUserId = @"AppNexus";

    self.requestExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    self.requestExpectation = nil;

    XCTAssertEqual(2, [self.adRequest memberId]);
    XCTAssertEqual(@"test", [self.adRequest inventoryCode]);
    XCTAssertEqual(@"1", [self.adRequest placementId]);

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    
    XCTAssertNil(jsonBody[@"tags"][0][@"id"]); // When both member_id/inventorycode and PlacementID exist, then placement_id is ignored in the request
    
    XCTAssertEqual([jsonBody[@"member_id"] integerValue], 2);
    
    NSString  *codeValue  = jsonBody[@"tags"][0][@"code"];   //@"code" value is of type NSTaggedPointerString.
    XCTAssertEqual([codeValue isEqualToString:@"test"], YES);
    // externalUid Test
    NSDictionary *user = jsonBody[@"user"];
    NSString *externalUid = user[@"external_uid"];
    XCTAssertNotNil(externalUid);
    XCTAssertEqualObjects(externalUid, @"AppNexus");
}

- (void)testAppNexusWithAdditionalDescription {

    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadMainImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    [self validateGenericNativeAdObject];
    
    XCTAssertEqual(self.adResponseInfo.networkCode, ANNativeAdNetworkCodeAppNexus);
    XCTAssertNotNil(self.adResponseInfo.additionalDescription);
}

- (void)testNoResponse {

    [self stubRequestWithResponse:@"empty_response"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    XCTAssertFalse(self.successfulAdCall);
    XCTAssertNotNil(self.adRequestError);
}


- (void)testSuccessfulResponseWithNoAds {

    [self stubRequestWithResponse:@"no_ads_ok_response"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    XCTAssertFalse(self.successfulAdCall);
    XCTAssertNotNil(self.adRequestError);
}

- (void)testMediatedResponseEmptyMediatedAd {

    [self stubRequestWithResponse:@"empty_mediated_ad_response"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    XCTAssertFalse(self.successfulAdCall);
    XCTAssertNotNil(self.adRequestError);
}

- (void)loadNativeAdRequest{
    self.adRequest= [[ANNativeAdRequest alloc] init];
    [self.adRequest setPlacementId:@"1"];
    ANSDKSettings.sharedInstance.publisherUserId = @"AppNexus";
    self.adRequest.forceCreativeId = 135482485;
    [self.adRequest setRendererId:127];
    // [self.adRequest getIncrementCountEnabledOrIfSet:YES thenValue:NO];
    self.adRequest.gender = ANGenderMale;
    self.adRequest.shouldLoadIconImage = YES;
    self.adRequest.shouldLoadMainImage = YES;
    self.adRequest.delegate = self;
    [self.adRequest loadAd];

}


- (void)testNativeSDKRTBClickURLAd {
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    XCTAssertEqualObjects(self.adResponseInfo.customElements[@"ELEMENT"][@"link"][@"url"], @"http://www.appnexus.com");
    
    XCTAssertNil(self.adResponseInfo.customElements[@"ELEMENT"][@"link"][@"click_trackers"]);
    
    

}


- (void)testNativeSDKRTBClickURLNilAd {
    [self stubRequestWithResponse:@"appnexus_standard_response_link"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    XCTAssertNil(self.adResponseInfo.customElements[@"ELEMENT"][@"link"]);

}




- (void)testNativeSDKRTBClickFallbackURLAd {
    [self stubRequestWithResponse:@"appnexus_standard_response_clickfallbackurl"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    XCTAssertEqualObjects(self.adResponseInfo.customElements[@"ELEMENT"][@"link"][@"fallback_url"],@"https://xandr.com");
    XCTAssertNil(self.adResponseInfo.customElements[@"ELEMENT"][@"link"][@"click_trackers"]);
}


- (void)testNativeSDKRTBClickFallbackURLNotFound {
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    XCTAssertNil(self.adResponseInfo.customElements[@"ELEMENT"][@"link"][@"fallback_url"]);
    XCTAssertNil(self.adResponseInfo.customElements[@"ELEMENT"][@"link"][@"click_trackers"]);

}

#pragma mark - Helper methods.

- (void)validateGenericNativeAdObject {
    XCTAssertNotNil(self.adResponseInfo);
    if (self.adResponseInfo.title) {
        XCTAssert([self.adResponseInfo.title isKindOfClass:[NSString class]]);
    }
    if (self.adResponseInfo.body) {
        XCTAssert([self.adResponseInfo.body isKindOfClass:[NSString class]]);
    }
    if (self.adResponseInfo.callToAction) {
        XCTAssert([self.adResponseInfo.body isKindOfClass:[NSString class]]);
    }
    if (self.adResponseInfo.rating) {
        XCTAssert([self.adResponseInfo.rating isKindOfClass:[ANNativeAdStarRating class]]);
    }
    if (self.adResponseInfo.mainImageURL) {
        XCTAssert([self.adResponseInfo.mainImageURL isKindOfClass:[NSURL class]]);
    }
    if (self.adResponseInfo.iconImageURL) {
        XCTAssert([self.adResponseInfo.iconImageURL isKindOfClass:[NSURL class]]);
    }
    if (self.adResponseInfo.customElements) {
        XCTAssert([self.adResponseInfo.customElements isKindOfClass:[NSDictionary class]]);
    }
    if (self.adResponseInfo.adResponseInfo.creativeId) {
        XCTAssert([self.adResponseInfo.adResponseInfo.creativeId isKindOfClass:[NSString class]]);
    }
}

#pragma mark - ANNativeAdRequestDelegate

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response
{
TESTTRACE();

    response.delegate = self;
    self.adResponseInfo = response;
    self.successfulAdCall = YES;
    [self.delegateCallbackExpectation fulfill];
}
- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error withAdResponseInfo:(ANAdResponseInfo *)adResponseInfo{

    TESTTRACE();
        self.adRequestError = error;
        self.successfulAdCall = NO;
        [self.delegateCallbackExpectation fulfill];
}

- (void)adDidExpire:(nonnull id)response {
    NSLog(@"adDidExpire");
    [self.nativeAdDidExpireExpectation fulfill];
}

- (void)adWillExpire:(nonnull id)response {
    NSLog(@"adWillExpire");
    [self.nativeAdWillExpireExpectation fulfill];
}



# pragma mark - Ad Server Response Stubbing

- (void)stubRequestWithResponse:(NSString *)responseName {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *baseResponse = [NSString stringWithContentsOfFile:[currentBundle pathForResource:responseName
                                                                                        ofType:@"json"]
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];
    ANURLConnectionStub *requestStub = [[ANURLConnectionStub alloc] init];
    requestStub.requestURL      = @"https://mediation.adnxs.com/ut/v3";
    requestStub.responseCode    = 200;
    requestStub.responseBody    = baseResponse;
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


@end
