/*   Copyright 2016 APPNEXUS INC
 
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
#import <AdSupport/AdSupport.h>
#import "ANBannerAdView.h"
#import "ANURLConnectionStub.h"
#import "ANHTTPStubbingManager.h"
#import "XCTestCase+ANCategory.h"
#import "ANMRAIDContainerView.h"

@interface ANJAMTestCase : XCTestCase <ANAppEventDelegate, ANAdWebViewControllerBrowserDelegate>
@property (nonatomic, strong) ANBannerAdView *adView;
@property (nonatomic, strong) XCTestExpectation *deviceIdExpectation;
@property (nonatomic, strong) XCTestExpectation *dispatchAppEventExpectation;
@property (nonatomic, strong) XCTestExpectation *internalBrowserExpectation;
@property (nonatomic, strong) XCTestExpectation *externalBrowserExpectation;
@end

@implementation ANJAMTestCase

- (void)setUp {
    [super setUp];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    self.adView = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)
                                            placementId:@"2140063"
                                                 adSize:CGSizeMake(320, 50)];
    self.adView.appEventDelegate = self;
}

- (void)tearDown {
    [super tearDown];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    self.adView = nil;
}

- (void)testANJAMDeviceIDResponse {
    [self stubRequestWithResponse:@"ANJAMDeviceIdResponse"];
    self.deviceIdExpectation = [self expectationWithDescription:@"Waiting for app event to be received."];
    [self.adView loadAd];
    [self waitForExpectationsWithTimeout:6.0 handler:nil];
    self.deviceIdExpectation = nil;
}

- (void)testANJAMDispatchAppEvent {
    [self stubRequestWithResponse:@"ANJAMDispatchAppEventResponse"];
    self.dispatchAppEventExpectation = [self expectationWithDescription:@"Waiting for app event to be received."];
    [self.adView loadAd];
    [self waitForExpectationsWithTimeout:6.0 handler:nil];
    self.dispatchAppEventExpectation = nil;
}

- (void)testANJAMInternalBrowserResponse{
    
    //this test fails as the delegate is not fired.
    
    [self stubRequestWithResponse:@"ANJAMInternalBrowserResponse"];
    [self.adView loadAd];
    ANMRAIDContainerView *mraidView = (ANMRAIDContainerView *)[self.adView performSelector:NSSelectorFromString(@"contentView")];
    ANAdWebViewController *webViewController = mraidView.webViewController;
    
    webViewController.browserDelegate = self;
    
    self.adView.opensInNativeBrowser = NO;
    
    self.internalBrowserExpectation = [self expectationWithDescription:@"Waiting for internal browser to be opened."];
    [self waitForExpectationsWithTimeout:6.0 handler:nil];
    self.internalBrowserExpectation = nil;
    
    webViewController = nil;
    mraidView = nil;
}

- (void)testANJAMExternalBrowserResponse{
    
    //This test fails as the delegate is not fired.
    
    [self stubRequestWithResponse:@"ANJAMExternalBrowserResponse"];
    [self.adView loadAd];
    ANMRAIDContainerView *mraidView = (ANMRAIDContainerView *)[self.adView performSelector:NSSelectorFromString(@"contentView")];
    ANAdWebViewController *webViewController = mraidView.webViewController;
    
    webViewController.browserDelegate = self;
    
    self.adView.opensInNativeBrowser = YES;
    
    self.externalBrowserExpectation = [self expectationWithDescription:@"Waiting for default browser to be opened."];
    [self waitForExpectationsWithTimeout:6.0 handler:nil];
    self.externalBrowserExpectation = nil;
    
    webViewController = nil;
    mraidView = nil;
}

- (void)ad:(id<ANAdProtocol>)ad didReceiveAppEvent:(NSString *)name withData:(NSString *)data {
    if ([name isEqualToString:@"idfa"]) {
        XCTAssertNotNil(data);
        NSString *advertisingIdentifier = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
        XCTAssertEqualObjects(data, advertisingIdentifier);
        [self.deviceIdExpectation fulfill];
    } else if ([name isEqualToString:@"SomeEvent"]) {
        XCTAssertNotNil(data);
        XCTAssertEqualObjects(data, @"TheEventData");
        [self.dispatchAppEventExpectation fulfill];
    }
}

#pragma mark - Stubbing

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

- (void)openDefaultBrowserWithURL:(NSURL *)URL{
    XCTAssertNotNil(URL);
    XCTAssertNotEqual(URL.absoluteString.length, 0);
    if (self.internalBrowserExpectation) {
        [self.internalBrowserExpectation fulfill];
    }
}

- (void)openInAppBrowserWithURL:(NSURL *)URL{
    XCTAssertNotNil(URL);
    XCTAssertNotEqual(URL.absoluteString.length, 0);
    if (self.externalBrowserExpectation) {
        [self.externalBrowserExpectation fulfill];
    }
}

//Help me with RecordEvent Response test case. Not sure how i will get handle to ANRecordEventDelegate to handle webViewDidFinishLoad delegate method.
//How to get handle to ANAdWebViewController so that i can get the delegates openInAppBrowserWithURL: and openDefaultBrowserWithURL: to fire. the contentview holds the standardAdView object which in turn holds the ANAdWebViewController object. But in my case, the contentView itself is nil, so, not able to get the other objects.

@end