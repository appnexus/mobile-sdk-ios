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

#import <KIF/KIF.h>
#import <AdSupport/AdSupport.h>
#import "ANBannerAdView.h"
#import "ANURLConnectionStub.h"
#import "ANHTTPStubbingManager.h"
#import "XCTestCase+ANCategory.h"
#import "ANMRAIDContainerView.h"
#import "ANANJAMImplementation.h"
#import "ANBrowserViewController.h"
#import "ANGlobal.h"
#import "ANLogging.h"

@interface ANJAMTestCase : KIFTestCase <ANAppEventDelegate, ANBannerAdViewDelegate, UIWebViewDelegate>
@property (nonatomic, strong) ANBannerAdView *adView;
@property (nonatomic, strong) XCTestExpectation *deviceIdExpectation;
@property (nonatomic, strong) XCTestExpectation *dispatchAppEventExpectation;
@property (nonatomic, strong) XCTestExpectation *internalBrowserExpectation;
@property (nonatomic, strong) XCTestExpectation *externalBrowserExpectation;
@property (nonatomic, strong) XCTestExpectation *mayDeepLinkExpectation;
@property (nonatomic, strong) XCTestExpectation *recordEventExpectation;

@property (nonatomic, strong) UIWebView *recordEventDelegateView;
@end

@implementation ANJAMTestCase

- (void)setUp {
    [super setUp];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    self.adView = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)
                                            placementId:@"2140063"
                                                 adSize:CGSizeMake(320, 50)];
    self.adView.accessibilityLabel = @"AdView";
    self.adView.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.adView.appEventDelegate = self;
    self.adView.delegate = self;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.adView];
}

- (void)tearDown {
    [super tearDown];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [self.adView removeFromSuperview];
    self.adView.delegate = nil;
    self.adView.appEventDelegate = nil;
    self.adView = nil;
    [[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController dismissViewControllerAnimated:NO
                                                                                                               completion:nil];
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
    [self stubRequestWithResponse:@"ANJAMInternalBrowserResponse"];
    self.adView.opensInNativeBrowser = YES;
    self.internalBrowserExpectation = [self expectationWithDescription:@"Waiting for internal browser to be opened."];
    [self.adView loadAd];
    [tester waitForTimeInterval:1.0];
    [tester tapViewWithAccessibilityLabel:@"AdView"];
    [self waitForExpectationsWithTimeout:2.0
                                 handler:nil];
    XCTAssertTrue([[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController
                   isKindOfClass:[ANBrowserViewController class]]);
}

- (void)testANJAMExternalBrowserResponse{
    #if TARGET_IPHONE_SIMULATOR
    [self stubRequestWithResponse:@"ANJAMExternalBrowserResponse"];
    self.adView.opensInNativeBrowser = NO;
    self.externalBrowserExpectation = [self expectationWithDescription:@"Waiting for default browser to be opened."];
    [self.adView loadAd];
    [tester waitForTimeInterval:3.0];
    if ([NSProcessInfo processInfo].operatingSystemVersion.majorVersion >= 9) {
        [tester acknowledgeSystemAlert];
    }
    [self waitForExpectationsWithTimeout:3.0
                                 handler:nil];
    self.externalBrowserExpectation = nil;
    #endif
}

- (void)testMayDeepLinkResponse{
    [self stubRequestWithResponse:@"ANJAMMayDeepLinkResponse"];
    self.mayDeepLinkExpectation = [self expectationWithDescription:@"Waiting for app event to be received."];
    [self.adView loadAd];
    [self waitForExpectationsWithTimeout:20.0 handler:nil];
    self.mayDeepLinkExpectation = nil;
}

- (void)testMayDeepLinkNoResponse{
    [self stubRequestWithResponse:@"ANJAMMayDeepLinkResponseNo"];
    self.mayDeepLinkExpectation = [self expectationWithDescription:@"Waiting for app event to be received."];
    [self.adView loadAd];
    [self waitForExpectationsWithTimeout:6.0 handler:nil];
    self.mayDeepLinkExpectation = nil;
}

- (void)testRecordEventResponse{
    #if TARGET_IPHONE_SIMULATOR
    [self stubRequestWithResponse:@"ANJAMRecordEventResponse"];
    self.recordEventExpectation = [self expectationWithDescription:@"Waiting for app event to be received."];
    ANSetNotificationsEnabled(YES);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLog:)
                                                 name:kANLoggingNotification
                                               object:nil];
    [self.adView loadAd];
    [tester waitForTimeInterval:3.0];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
    self.recordEventExpectation = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kANLoggingNotification
                                                  object:nil];
    ANSetNotificationsEnabled(NO);
    #endif
}

- (void)receivedLog:(NSNotification *)notification {
    NSString *message = notification.userInfo[kANLogMessageKey];
    if ([message hasSuffix:@"RecordEvent completed succesfully"]) {
        [self.recordEventExpectation fulfill];
    }
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
    }else if ([name isEqualToString:@"DeepLinkYes"]) {
        XCTAssertNotNil(data);
        XCTAssertEqualObjects(data, @"true");
        [self.mayDeepLinkExpectation fulfill];
    }else if ([name isEqualToString:@"DeepLinkNo"]) {
        XCTAssertNotNil(data);
        XCTAssertEqualObjects(data, @"false");
        [self.mayDeepLinkExpectation fulfill];
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

#pragma mark - ANBannerAdViewDelegate

- (void)adDidPresent:(id<ANAdProtocol>)ad {
    [self.internalBrowserExpectation fulfill];
}

- (void)adWillLeaveApplication:(id<ANAdProtocol>)ad{
    [self.externalBrowserExpectation fulfill];
}

@end