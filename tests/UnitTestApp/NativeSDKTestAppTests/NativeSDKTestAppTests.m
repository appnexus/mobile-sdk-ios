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
#import <AppNexusNativeSDK/AppNexusNativeSDK.h>
#import "ANURLConnectionStub.h"
#import "ANHTTPStubbingManager.h"
#import "NSURLRequest+HTTPBodyTesting.h"

#define kAppNexusRequestTimeoutInterval 30.0



@interface NativeSDKTestAppTests : XCTestCase <ANNativeAdRequestDelegate>

@property (nonatomic, readwrite, strong)  ANNativeAdRequest     *adRequest;
@property (nonatomic, readwrite, strong)  ANNativeAdResponse    *adResponseInfo;

@property (nonatomic)                     NSURLRequest  *request;
@property (nonatomic, readwrite, strong)  NSError       *adRequestError;

@property (nonatomic, readwrite, strong)  XCTestExpectation  *delegateCallbackExpectation;

@end



@implementation NativeSDKTestAppTests



#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    
    [ANLogManager setANLogLevel:ANLogLevelAll];
    self.adRequest = [[ANNativeAdRequest alloc] init];
    self.adRequest.delegate = self;
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
}

- (void)tearDown {
    [super tearDown];
    
    self.adRequest = nil;
    self.delegateCallbackExpectation = nil;
    self.adResponseInfo = nil;
    self.adRequestError = nil;
    
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Test methods.


- (void)testNativeSDKRTBAd {
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadMainImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    [self validateGenericNativeAdObject];
    
    XCTAssertEqual(self.adResponseInfo.networkCode, ANNativeAdNetworkCodeAppNexus);
   
}



- (void)testNativeSDKCSMAd {
    [self stubRequestWithResponse:@"appnexus_mock_mediation_response"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    
    
    XCTAssertNotNil(self.adResponseInfo);
    XCTAssertNil(self.adRequestError);

}


#pragma mark - Helper methods.

- (void)validateGenericNativeAdObject {
    //    XCTAssertNotNil(self.adResponseInfo);
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
    if (self.adResponseInfo.creativeId) {
        XCTAssert([self.adResponseInfo.creativeId isKindOfClass:[NSString class]]);
    }else{
        XCTAssertTrue(false);
    }
}




#pragma mark - ANNativeAdRequestDelegate

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response
{
    self.adResponseInfo = response;
    [self.delegateCallbackExpectation fulfill];
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error
{
    self.adRequestError = error;
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
    requestStub.requestURL      = @"http://mediation.adnxs.com/ut/v3";
    requestStub.responseCode    = 200;
    requestStub.responseBody    = baseResponse;
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:requestStub];
}
@end
