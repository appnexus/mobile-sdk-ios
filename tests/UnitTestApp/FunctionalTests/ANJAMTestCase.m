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

#import <AdSupport/AdSupport.h>
#import <XCTest/XCTest.h>
#import "ANBannerAdView.h"
#import "ANHTTPStubbingManager.h"
#import "XCTestCase+ANCategory.h"
#import "ANMRAIDContainerView.h"
#import "ANANJAMImplementation.h"
#import "ANBrowserViewController.h"
#import "ANGlobal.h"
#import "ANTestGlobal.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANLogging.h"
#import "XandrAd.h"


@interface ANJAMTestCase : XCTestCase <ANAppEventDelegate, ANBannerAdViewDelegate, UIWebViewDelegate>
@property (nonatomic, strong) ANBannerAdView *adView;
@property (nonatomic, strong) XCTestExpectation *deviceIdExpectation;
@property (nonatomic, strong) XCTestExpectation *customKeywordsExpectation;
@property (nonatomic, strong) XCTestExpectation *dispatchAppEventExpectation;
@property (nonatomic, strong) XCTestExpectation *internalBrowserExpectation;
@property (nonatomic, strong) XCTestExpectation *externalBrowserExpectation;
@property (nonatomic, strong) XCTestExpectation *mayDeepLinkExpectation;
@property (nonatomic, strong) XCTestExpectation *recordEventExpectation;

@property (nonatomic, strong) UIWebView *recordEventDelegateView;
@end



@implementation ANJAMTestCase

#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    self.adView = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)
                                            placementId:@"2140063"
                                                 adSize:CGSizeMake(320, 50)];
    self.adView.accessibilityLabel = @"AdView";
    self.adView.rootViewController = [ANGlobal getKeyWindow].rootViewController;
    self.adView.appEventDelegate = self;
    self.adView.delegate = self;
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.adView];
    
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];
}

- (void)tearDown {
    [super tearDown];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [self.adView removeFromSuperview];
    self.adView.delegate = nil;
    self.adView.appEventDelegate = nil;
    self.adView = nil;
    self.deviceIdExpectation = nil;
    self.customKeywordsExpectation = nil;
    self.dispatchAppEventExpectation = nil;
    self.internalBrowserExpectation = nil;
    self.externalBrowserExpectation = nil;
    self.mayDeepLinkExpectation = nil;
    self.recordEventExpectation = nil;
    self.recordEventDelegateView = nil;
    [[ANGlobal getKeyWindow].rootViewController.presentedViewController dismissViewControllerAnimated:NO             completion:nil];
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
    ANSDKSettings.sharedInstance.disableIDFAUsage = NO;
}



#pragma mark - Test methods.

- (void)testANJAMDeviceIDResponse {
    [self stubRequestWithResponse:@"ANJAMDeviceIdResponse"];
    self.deviceIdExpectation = [self expectationWithDescription:@"Waiting for app event to be received."];
    [self.adView loadAd];
    [self waitForExpectationsWithTimeout:3 * kAppNexusRequestTimeoutInterval handler:nil];
    self.deviceIdExpectation = nil;
    [self tearDown];
}


- (void)testANJAMDeviceIDResponseDisableIDFAUsageToYes {
    ANSDKSettings.sharedInstance.disableIDFAUsage = YES;
    [self stubRequestWithResponse:@"ANJAMDeviceIdResponse"];
    self.deviceIdExpectation = [self expectationWithDescription:@"Waiting for app event to be received."];
    [self.adView loadAd];
    [self waitForExpectationsWithTimeout:3 * kAppNexusRequestTimeoutInterval handler:nil];
    self.deviceIdExpectation = nil;
    [self tearDown];
}

- (void)testANJAMDeviceIDResponseDisableIDFAUsageToNo {
    ANSDKSettings.sharedInstance.disableIDFAUsage = NO;
    [self stubRequestWithResponse:@"ANJAMDeviceIdResponse"];
    self.deviceIdExpectation = [self expectationWithDescription:@"Waiting for app event to be received."];
    [self.adView loadAd];
    [self waitForExpectationsWithTimeout:3 * kAppNexusRequestTimeoutInterval handler:nil];
    self.deviceIdExpectation = nil;
    [self tearDown];
}


- (void)testANJAMDispatchAppEvent {
    [self stubRequestWithResponse:@"ANJAMDispatchAppEventResponse"];
    self.dispatchAppEventExpectation = [self expectationWithDescription:@"Waiting for app event to be received."];
    [self.adView loadAd];
    [self waitForExpectationsWithTimeout:3 * kAppNexusRequestTimeoutInterval handler:nil];
    self.dispatchAppEventExpectation = nil;
    [self tearDown];
}

- (void)testMayDeepLinkResponse{
    [self stubRequestWithResponse:@"ANJAMMayDeepLinkResponse"];
    self.mayDeepLinkExpectation = [self expectationWithDescription:@"Waiting for app event to be received."];
    [self.adView loadAd];
    [self waitForExpectationsWithTimeout:3 * kAppNexusRequestTimeoutInterval handler:nil];
    self.mayDeepLinkExpectation = nil;
    [self tearDown];
}

- (void)testMayDeepLinkNoResponse{
    [self stubRequestWithResponse:@"ANJAMMayDeepLinkResponseNo"];
    self.mayDeepLinkExpectation = [self expectationWithDescription:@"Waiting for app event to be received."];
    [self.adView loadAd];
    [self waitForExpectationsWithTimeout:3 * kAppNexusRequestTimeoutInterval handler:nil];
    self.mayDeepLinkExpectation = nil;
    [self tearDown];
}

- (void)testRecordEventResponse{
    #if TARGET_IPHONE_SIMULATOR
    [self stubRequestWithResponse:@"ANJAMRecordEventResponse"];
    self.recordEventExpectation = [self expectationWithDescription:@"Waiting for app event to be received."];
    [ANLogManager setNotificationsEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedLog:)
                                                 name:kANLoggingNotification
                                               object:nil];
    [self.adView loadAd];
    [self waitForExpectationsWithTimeout:3 * kAppNexusRequestTimeoutInterval handler:nil];
    self.recordEventExpectation = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kANLoggingNotification
                                                  object:nil];
    [ANLogManager setNotificationsEnabled:NO];

    #endif
    [self tearDown];
}

- (void)receivedLog:(NSNotification *)notification {
    NSString *message = notification.userInfo[kANLogMessageKey];
    if ([message hasSuffix:@"RecordEvent completed succesfully"]) {
        [self.recordEventExpectation fulfill];
    }
}



#pragma mark - Stubbing

- (void)stubRequestWithResponse:(NSString *)responseName {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *baseResponse = [NSString stringWithContentsOfFile:
                                [currentBundle pathForResource:responseName ofType:@"json" ]
                                encoding: NSUTF8StringEncoding
                                error: nil ];

    ANURLConnectionStub  *requestStub  = [[ANURLConnectionStub alloc] init];

    requestStub.requestURL    = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    requestStub.responseCode  = 200;
    requestStub.responseBody  = baseResponse;

    [[ANHTTPStubbingManager sharedStubbingManager] addStub:requestStub];
}



#pragma mark - ANAppEventDelegate.

- (void)            ad: (id<ANAdProtocol>)ad
    didReceiveAppEvent: (NSString *)name
              withData: (NSString *)data
{
TESTTRACE();
    if ([name isEqualToString:@"idfa"]) {
        XCTAssertNotNil(data);
        NSString *advertisingIdentifier = !ANSDKSettings.sharedInstance.disableIDFAUsage ?  ([[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString]) : @"";
        
        XCTAssertEqualObjects(data, advertisingIdentifier);
        [self.deviceIdExpectation fulfill];

    } else if ([name isEqualToString:@"SomeEvent"]) {
        XCTAssertNotNil(data);
        XCTAssertEqualObjects(data, @"TheEventData");
        [self.dispatchAppEventExpectation fulfill];

    } else if ([name isEqualToString:@"DeepLinkYes"]) {
        XCTAssertNotNil(data);
        XCTAssertEqualObjects(data, @"true");
        [self.mayDeepLinkExpectation fulfill];

    } else if ([name isEqualToString:@"CustomKeywordsYes"]) {
        XCTAssertNotNil(data);
        XCTAssertEqualObjects(data, @"bar1randomvalue");
        [self.customKeywordsExpectation fulfill];
    } else if ([name isEqualToString:@"DeepLinkNo"]) {
        XCTAssertNotNil(data);
        XCTAssertEqualObjects(data, @"false");
        [self.mayDeepLinkExpectation fulfill];
    }
}



#pragma mark - ANBannerAdViewDelegate

- (void)adDidPresent:(id<ANAdProtocol>)ad {
TESTTRACE();
    [self.internalBrowserExpectation fulfill];
}

- (void)adWillLeaveApplication:(id<ANAdProtocol>)ad{
TESTTRACE();
    [self.externalBrowserExpectation fulfill];
}

@end
