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
#import "ANURLConnectionStub.h"
#import "ANHTTPStubbingManager.h"
#import "NSURLRequest+HTTPBodyTesting.h"
#import "ANNativeAdRequest+ANTest.h"
#import "XandrAd.h"




@interface NativeSDKTestAppTests : XCTestCase <ANMultiAdRequestDelegate, ANNativeAdRequestDelegate>

@property (nonatomic, readwrite, strong)            ANMultiAdRequest    *mar;

@property (nonatomic, readwrite, strong)  ANNativeAdRequest     *adRequest;
@property (nonatomic, readwrite, strong)  ANNativeAdResponse    *adResponseInfo;

@property (nonatomic, readwrite, strong)  ANNativeAdRequest     *adRequest2;
@property (nonatomic, readwrite, strong)  ANNativeAdResponse    *adResponse;

@property (nonatomic, readwrite)  NSUInteger  countOfRequestedAdUnits;

@property (nonatomic)                     NSURLRequest  *request;
@property (nonatomic, readwrite, strong)  NSError       *adRequestError;

@property (nonatomic, readwrite)  NSUInteger  MAR_countOfCompletionSuccesses;
@property (nonatomic, readwrite)  NSUInteger  MAR_countOfCompletionFailures;
@property (nonatomic, readwrite)  NSUInteger  AdUnit_countOfReceiveSuccesses;
@property (nonatomic, readwrite)  NSUInteger  AdUnit_countOfReceiveFailures;


@property (nonatomic, strong, readwrite, nullable)  XCTestExpectation  *expectationMARLoadCompletionOrFailure;

@property (nonatomic, readwrite, strong)  XCTestExpectation  *expectationAdUnitLoadResponseOrFailure;


@end



@implementation NativeSDKTestAppTests



#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    
    self.mar = nil;
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];

    self.MAR_countOfCompletionSuccesses  = 0;
    self.MAR_countOfCompletionFailures   = 0;
    self.AdUnit_countOfReceiveSuccesses = 0;
    self.AdUnit_countOfReceiveFailures = 0;
    
    self.countOfRequestedAdUnits = 0;
    
    //[ANLogManager setANLogLevel:ANLogLevelAll];
    self.adRequest = [[ANNativeAdRequest alloc] init];
    self.adRequest.delegate = self;
    
    self.adRequest2 = [[ANNativeAdRequest alloc] init];
    self.adRequest2.delegate = self;

    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    [ANNativeAdRequest setDoNotResetAdUnitUUID:YES];
}

- (void)tearDown {
    [super tearDown];
    
    self.adRequest = nil;
    self.expectationAdUnitLoadResponseOrFailure = nil;
    self.adRequest2 = nil;
    self.adResponse = nil;
    self.adResponseInfo = nil;
    self.adRequestError = nil;
    
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}

#pragma mark - Test methods.


- (void)testNativeSDKRTBAd {
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    self.countOfRequestedAdUnits  = 1;
    [self.adRequest loadAd];
    self.adRequest.shouldLoadMainImage = YES;
    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    [self validateGenericNativeAdObject];
    
    XCTAssertEqual(self.adResponseInfo.networkCode, ANNativeAdNetworkCodeAppNexus);
   
}



- (void)testNativeSDKCSMAd {
    [self stubRequestWithResponse:@"appnexus_mock_mediation_response"];
    self.countOfRequestedAdUnits  = 1;
    [self.adRequest loadAd];
    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    
    
    XCTAssertNotNil(self.adResponseInfo);
    XCTAssertNil(self.adRequestError);

}

- (void)testMARNativeSDK {
    [self stubRequestWithResponse:@"testMARCombinationTwoRTBNative"];

    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: 10094
                                     delegate: self
                                      adUnits: self.adRequest,self.adRequest2, nil ];

    self.adRequest.utRequestUUIDString = @"1";
    self.adRequest2.utRequestUUIDString = @"2";

    self.countOfRequestedAdUnits  = 2;

    XCTAssertNotNil(self.mar);

    [self.mar load];
    
    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
       
       [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];

    XCTAssertEqual(self.MAR_countOfCompletionSuccesses, 1);
    
    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, self.countOfRequestedAdUnits);

}

#pragma mark - MultiAdRequest delegate

- (void)multiAdRequestDidComplete:(ANMultiAdRequest *)mar
{
    [self.expectationMARLoadCompletionOrFailure fulfill];
    self.expectationMARLoadCompletionOrFailure = nil;
    self.MAR_countOfCompletionSuccesses += 1;
}

- (void)multiAdRequest:(nonnull ANMultiAdRequest *)mar  didFailWithError:(NSError *)error
{
    [self.expectationMARLoadCompletionOrFailure fulfill];
    self.expectationMARLoadCompletionOrFailure = nil;
    self.MAR_countOfCompletionFailures += 1;
}


#pragma mark - Helper methods.

- (void)validateGenericNativeAdObject {
        XCTAssertNotNil(self.adResponse);
    if (self.adResponse.title) {
        XCTAssert([self.adResponse.title isKindOfClass:[NSString class]]);
    }
    if (self.adResponseInfo.title) {
        XCTAssert([self.adResponseInfo.title isKindOfClass:[NSString class]]);
    }else{
        XCTAssertTrue(false);
    }
    if (self.adResponseInfo.body) {
        XCTAssert([self.adResponseInfo.body isKindOfClass:[NSString class]]);
    }else{
        XCTAssertTrue(false);
    }
    if (self.adResponseInfo.callToAction) {
        XCTAssert([self.adResponseInfo.body isKindOfClass:[NSString class]]);
    }else{
        XCTAssertTrue(false);
    }
    if (self.adResponseInfo.rating) {
        XCTAssert([self.adResponseInfo.rating isKindOfClass:[ANNativeAdStarRating class]]);
    }else{
        XCTAssertTrue(false);
    }
    if (self.adResponseInfo.mainImageURL) {
        XCTAssert([self.adResponseInfo.mainImageURL isKindOfClass:[NSURL class]]);
    }else{
        XCTAssertTrue(false);
    }
    if (self.adResponseInfo.iconImageURL) {
        XCTAssert([self.adResponseInfo.iconImageURL isKindOfClass:[NSURL class]]);
    }else{
        XCTAssertTrue(false);
    }
    if (self.adResponseInfo.customElements) {
        XCTAssert([self.adResponseInfo.customElements isKindOfClass:[NSDictionary class]]);
    }else{
        XCTAssertTrue(false);
    }
    if (self.adResponseInfo.adResponseInfo.creativeId) {
        XCTAssert([self.adResponseInfo.adResponseInfo.creativeId isKindOfClass:[NSString class]]);
    }else{
        XCTAssertTrue(false);
    }
}




#pragma mark - ANNativeAdRequestDelegate

- (void)adRequest:(nonnull ANNativeAdRequest *)request didReceiveResponse:(nonnull ANNativeAdResponse *)response
{
    if(self.adRequest == request){
        self.adResponse = response;
    } else if (self.adRequest2 == request){
        self.adResponse = response;
    }
    
    self.AdUnit_countOfReceiveSuccesses += 1;
    if(self.countOfRequestedAdUnits == self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures){
        [self.expectationAdUnitLoadResponseOrFailure fulfill];
        self.expectationAdUnitLoadResponseOrFailure = nil;
    }
    
    self.adResponseInfo = response;
    [self.expectationMARLoadCompletionOrFailure fulfill];
}

- (void)adRequest:(nonnull ANNativeAdRequest *)request didFailToLoadWithError:(nonnull NSError *)error
{
    self.adRequestError = error;
    self.AdUnit_countOfReceiveFailures += 1;
    [self.expectationAdUnitLoadResponseOrFailure fulfill];
    
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
@end
