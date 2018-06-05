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

#import "ANNativeAdRequest.h"
#import "ANGlobal.h"
#import "ANTestGlobal.h"
#import "ANURLConnectionStub.h"
#import "ANHTTPStubbingManager.h"
#import "XCTestCase+ANCategory.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "NSURLRequest+HTTPBodyTesting.h"
#import "ANLogManager.h"



@interface ANNativeAdRequestTestCase : XCTestCase <ANNativeAdRequestDelegate>

@property (nonatomic, readwrite, strong) ANNativeAdRequest *adRequest;
@property (nonatomic, readwrite, strong) XCTestExpectation *requestExpectation;
@property (nonatomic, readwrite, strong) XCTestExpectation *delegateCallbackExpectation;
@property (nonatomic, readwrite, assign) BOOL successfulAdCall;
@property (nonatomic, readwrite, strong) ANNativeAdResponse *adResponse;
@property (nonatomic, readwrite, strong) NSError *adRequestError;
@property (nonatomic) NSURLRequest *request;

@end



@implementation ANNativeAdRequestTestCase

#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    [ANLogManager setANLogLevel:ANLogLevelAll];
    self.adRequest = [[ANNativeAdRequest alloc] init];
    self.adRequest.delegate = self;
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [self setupRequestTracker];
}

- (void)tearDown {
    [super tearDown];

    self.adRequest = nil;
    self.delegateCallbackExpectation = nil;
    self.successfulAdCall = NO;
    self.adResponse = nil;
    self.adRequestError = nil;

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
    if (self.requestExpectation) {
        self.request = notification.userInfo[kANHTTPStubURLProtocolRequest];
        [self.requestExpectation fulfill];
        self.requestExpectation = nil;
    }
}



#pragma mark - Test methods.
        //TBDFIX -- Should test elements in outgoing UT Request via self.request.

- (void)testSetPlacementIdOnlyOnNative
{
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    //self.requestExpectation = [self expectationWithDescription:@"request"];
    [self.adRequest setPlacementId:@"1"];
    [self.adRequest setExternalUid:@"AppNexus"];
    
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

- (void)testSetInventoryCodeAndMemberIdOnlyOnNative {
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest setInventoryCode:@"test" memberId:2];
    [self.adRequest setExternalUid:@"AppNexus"];
    self.requestExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
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
    [self.adRequest setExternalUid:@"AppNexus"];

    self.requestExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
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

- (void)testAppNexusWithMainImageLoad {
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadMainImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    [self validateGenericNativeAdObject];

    XCTAssertEqual(self.adResponse.networkCode, ANNativeAdNetworkCodeAppNexus);
    XCTAssertNil(self.adResponse.iconImage);
    self.adResponse.mainImageURL ? XCTAssertNotNil(self.adResponse.mainImage) : XCTAssertNil(self.adResponse.mainImage);
    self.adResponse.mainImageURL ? XCTAssertTrue([self.adResponse.mainImage isKindOfClass:[UIImage class]]) : nil;
}

- (void)testFacebook {
    [self stubRequestWithResponse:@"facebook_mediated_response"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    if (self.successfulAdCall) {
        [self validateGenericNativeAdObject];
        XCTAssertEqual(self.adResponse.networkCode, ANNativeAdNetworkCodeFacebook);
        XCTAssertNil(self.adResponse.iconImage);
        XCTAssertNil(self.adResponse.mainImage);
        XCTAssertEqualObjects(self.adResponse.creativeId, @"111");
    } else {
        XCTAssertNotNil(self.adRequestError);
    }
}

- (void)testFacebookWithIconImageLoad {
    [self stubRequestWithResponse:@"facebook_mediated_response"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    if (self.successfulAdCall) {
        [self validateGenericNativeAdObject];
        XCTAssertEqual(self.adResponse.networkCode, ANNativeAdNetworkCodeFacebook);
        self.adResponse.iconImageURL ? XCTAssertNotNil(self.adResponse.iconImage) : XCTAssertNil(self.adResponse.iconImage);
        self.adResponse.iconImageURL ? XCTAssertTrue([self.adResponse.iconImage isKindOfClass:[UIImage class]]) : nil;
        XCTAssertNil(self.adResponse.mainImage);
    } else {
        XCTAssertNotNil(self.adRequestError);
    }
}

- (void)testInvalidMediationAdapter {
    [self stubRequestWithResponse:@"custom_adapter_mediated_response"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertFalse(self.successfulAdCall);
    XCTAssertNotNil(self.adRequestError);
}

- (void)testWaterfallMediationAdapterEndingInFacebook {
    [self stubRequestWithResponse:@"custom_adapter_fb_mediated_response"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    if (self.successfulAdCall) {
        [self validateGenericNativeAdObject];
        XCTAssertEqual(self.adResponse.networkCode, ANNativeAdNetworkCodeFacebook);
        XCTAssertNil(self.adResponse.iconImage);
        XCTAssertNil(self.adResponse.mainImage);
    } else {
        XCTAssertNotNil(self.adRequestError);
    }
}

- (void)testNoResponse {
    [self stubRequestWithResponse:@"empty_response"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertFalse(self.successfulAdCall);
    XCTAssertNotNil(self.adRequestError);
}

- (void)testCustomAdapterFailToStandardResponse {
    [self stubRequestWithResponse:@"custom_adapter_to_standard_response"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadMainImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    [self validateGenericNativeAdObject];
    XCTAssertEqual(self.adResponse.networkCode, ANNativeAdNetworkCodeAppNexus);
    XCTAssertNil(self.adResponse.iconImage);
    XCTAssertEqualObjects(self.adResponse.creativeId, @"125");
    self.adResponse.mainImageURL ? XCTAssertNotNil(self.adResponse.mainImage) : XCTAssertNil(self.adResponse.mainImage);
    self.adResponse.mainImageURL ? XCTAssertTrue([self.adResponse.mainImage isKindOfClass:[UIImage class]]) : nil;
}

- (void)testMediatedResponseInvalidType {
    [self stubRequestWithResponse:@"custom_adapter_invalid_type"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertFalse(self.successfulAdCall);
    XCTAssertNotNil(self.adRequestError);
}

- (void)testSuccessfulResponseWithNoAds {
    [self stubRequestWithResponse:@"no_ads_ok_response"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertFalse(self.successfulAdCall);
    XCTAssertNotNil(self.adRequestError);
}

- (void)testMediatedResponseEmptyMediatedAd {
    [self stubRequestWithResponse:@"empty_mediated_ad_response"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertFalse(self.successfulAdCall);
    XCTAssertNotNil(self.adRequestError);
}



#pragma mark - Helper methods.

- (void)validateGenericNativeAdObject {
    XCTAssertNotNil(self.adResponse);
    if (self.adResponse.title) {
        XCTAssert([self.adResponse.title isKindOfClass:[NSString class]]);
    }
    if (self.adResponse.body) {
        XCTAssert([self.adResponse.body isKindOfClass:[NSString class]]);
    }
    if (self.adResponse.callToAction) {
        XCTAssert([self.adResponse.body isKindOfClass:[NSString class]]);
    }
    if (self.adResponse.rating) {
        XCTAssert([self.adResponse.rating isKindOfClass:[ANNativeAdStarRating class]]);
    }
    if (self.adResponse.socialContext) {
        XCTAssert([self.adResponse.socialContext isKindOfClass:[NSString class]]);
    }
    if (self.adResponse.mainImageURL) {
        XCTAssert([self.adResponse.mainImageURL isKindOfClass:[NSURL class]]);
    }
    if (self.adResponse.iconImageURL) {
        XCTAssert([self.adResponse.iconImageURL isKindOfClass:[NSURL class]]);
    }
    if (self.adResponse.customElements) {
        XCTAssert([self.adResponse.customElements isKindOfClass:[NSDictionary class]]);
    }
    if (self.adResponse.creativeId) {
        XCTAssert([self.adResponse.creativeId isKindOfClass:[NSString class]]);
    }
}



#pragma mark - ANNativeAdRequestDelegate

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response
{
TESTTRACE();
    self.adResponse = response;
    self.successfulAdCall = YES;
    [self.delegateCallbackExpectation fulfill];
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error
{
TESTTRACE();
    self.adRequestError = error;
    self.successfulAdCall = NO;
    [self.delegateCallbackExpectation fulfill];
}



# pragma mark - Ad Server Response Stubbing

- (void)stubRequestWithResponse:(NSString *)responseName {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *baseResponse = [NSString stringWithContentsOfFile:[currentBundle pathForResource:responseName
                                                                                        ofType:@"json"]
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];
    ANURLConnectionStub *requestStub = [[ANURLConnectionStub alloc] init];
    requestStub.requestURL      = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
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
