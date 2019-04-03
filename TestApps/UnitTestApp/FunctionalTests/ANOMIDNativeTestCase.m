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
#import "ANGlobal.h"
#import "ANHTTPStubbingManager.h"
#import "XCTestCase+ANCategory.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "NSURLRequest+HTTPBodyTesting.h"
#import "ANLogManager.h"
#import "ANNativeAdRequest+ANTest.h"
#import "ANNativeAdResponse+PrivateMethods.h"
#import "SDKValidationURLProtocol.h"

@interface ANOMIDNativeTestCase : XCTestCase<ANNativeAdRequestDelegate, SDKValidationURLProtocolDelegate>

@property (nonatomic, readwrite, strong)  ANNativeAdRequest     *adRequest;
@property (nonatomic, readwrite, strong)  ANNativeAdResponse    *adResponse;
@property (nonatomic, readwrite, strong)  XCTestExpectation  *delegateCallbackExpectation;
@property (nonatomic, readwrite, strong)  NSMutableString     *requestData;

@end

@implementation ANOMIDNativeTestCase

- (void)setUp {
    [super setUp];
    self.requestData = [[NSMutableString alloc] init];
    [ANLogManager setANLogLevel:ANLogLevelAll];
    self.adRequest = [[ANNativeAdRequest alloc] init];
    self.adRequest.delegate = self;
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = YES;
    [SDKValidationURLProtocol setDelegate:self];
    [NSURLProtocol registerClass:[SDKValidationURLProtocol class]];
}

- (void)tearDown {
    [super tearDown];
    self.requestData = nil;
    self.adRequest = nil;
    self.delegateCallbackExpectation = nil;
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Test methods.

- (void)testOMIDSessionIsNotNill {
    [self stubRequestWithResponse:@"OMID_Native_RTBResponse"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    XCTAssertNotNil(self.adResponse.omidAdSession);
}

- (void)testOMIDSDKValidation{
    [self stubRequestWithResponse:@"OMID_Native_RTBResponse"];
    [self.adRequest loadAd];
    [XCTestCase delayForTimeInterval:10];
    XCTAssertTrue([self.requestData containsString:@"OmidSupported"]);
    XCTAssertTrue([self.requestData containsString:@"true"]);
    XCTAssertTrue([self.requestData containsString:@"sessionStart"]);
    XCTAssertTrue([self.requestData containsString:@"partnerName"]);
    XCTAssertTrue([self.requestData containsString:@"appnexus.com-omios"]);
    XCTAssertTrue([self.requestData containsString:@"partnerVersion"]);
    XCTAssertTrue([self.requestData containsString:@"5.1.2"]);
    XCTAssertTrue([self.requestData containsString:@"impression"]);
}

- (void)testOMIDSessionFinish{
    [self stubRequestWithResponse:@"OMID_Native_RTBResponse"];
    [self.adRequest loadAd];
    [XCTestCase delayForTimeInterval:10];
    XCTAssertTrue([self.requestData containsString:@"OmidSupported"]);
    XCTAssertTrue([self.requestData containsString:@"true"]);
    XCTAssertTrue([self.requestData containsString:@"sessionStart"]);
    XCTAssertTrue([self.requestData containsString:@"partnerName"]);
    XCTAssertTrue([self.requestData containsString:@"appnexus.com-omios"]);
    XCTAssertTrue([self.requestData containsString:@"partnerVersion"]);
    XCTAssertTrue([self.requestData containsString:@"5.1.2"]);
    XCTAssertTrue([self.requestData containsString:@"impression"]);
    [self.adResponse unregisterViewFromTracking];
    [XCTestCase delayForTimeInterval:5];
    XCTAssertTrue([self.requestData containsString:@"sessionFinish"]);
}


#pragma mark - ANNativeAdRequestDelegate

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response
{
    self.adResponse = response;
    NSError *registerError;
    UIViewController *rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [self.adResponse registerViewForTracking:rvc.view withRootViewController:rvc clickableViews:nil error:&registerError];
    [self.delegateCallbackExpectation fulfill];
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error
{
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

# pragma mark - Intercept HTTP Request Callback 

- (void)didReceiveIABResponse:(NSString *)response {
    [self.requestData appendString:response];
}

@end
