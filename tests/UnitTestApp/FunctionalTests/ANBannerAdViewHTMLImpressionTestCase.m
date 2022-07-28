/*   Copyright 2020 APPNEXUS INC

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
#import "ANBannerAdView.h"
#import "XCTestCase+ANCategory.h"
#import "ANTrackerManager+ANTest.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANGlobal.h"
#import "XandrAd.h"

@interface ANBannerAdViewHTMLImpressionTestCase : XCTestCase <ANBannerAdViewDelegate>
@property (nonatomic, readwrite, strong)   ANBannerAdView     *bannerAdView;
@property (nonatomic, strong) XCTestExpectation *loadAdSuccesfulException;
@property (nonatomic, readwrite, strong)  NSString  *impressionurlString;
@property (nonatomic, readwrite, assign)  BOOL       impressionurlWasFired;
@end




@implementation ANBannerAdViewHTMLImpressionTestCase

- (void)setUp {
    [super setUp];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestLoaded:)
                                                 name:kANHTTPStubURLProtocolRequestDidLoadNotification
                                               object:nil];
    self.impressionurlString = @"https://nym1-mobile.adnxs.com/it?impression=1";
    self.impressionurlWasFired = NO;
    [self stubRequestWithResponse:@"ANAdResponseRTB_Banner"];

    self.bannerAdView = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)
                                                  placementId:@"16392991"
                                                       adSize:CGSizeMake(300, 250)];

    self.bannerAdView.delegate = self;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.loadAdSuccesfulException = nil;
    self.bannerAdView.delegate = nil;

    [self.bannerAdView removeFromSuperview];
    self.bannerAdView = nil;
    
    self.impressionurlString = nil;
    self.impressionurlWasFired = NO;
    
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
        for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
              [additionalView removeFromSuperview];
          }
}


//Test impression tracker is fired for Count on Begin To Render cases and banner is not on Window.
- (void)testImpressionCountOnBeginToRenderRecorded {
    //Setting Seller member id to 958, Buyer member id will be 10094 so impression type should be begin to render without banner on screen
    
    [[XandrAd sharedInstance] initWithMemberID:958 preCacheRequestObjects:true completionHandler:nil];

    [self.bannerAdView loadAd];
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:60
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqual(self.bannerAdView.adResponseInfo.adType, ANAdTypeBanner);
    [XCTestCase delayForTimeInterval:3.0];
    XCTAssertTrue(self.impressionurlWasFired);
}

//Test impression tracker is fired for Viewable Impression cases when banner is attached to window.
- (void)testViewableImpressionRecorded {
    //Setting Seller member id to 10094, Buyer member id will be 10094 so impression type should be begin to render without banner on screen
    [[XandrAd sharedInstance] initWithMemberID:10094 preCacheRequestObjects:true completionHandler:nil];
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.bannerAdView];
    [self.bannerAdView loadAd];
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:60
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqual(self.bannerAdView.adResponseInfo.adType, ANAdTypeBanner);
    [XCTestCase delayForTimeInterval:3.0];
    XCTAssertTrue(self.impressionurlWasFired);
}

/*
 * As per the implementation, impression tracker will always be fired either Ad is `loaded` when countImpressionOnAdReceived API is set YES
 * or Ad is `displayed` when countImpressionOnAdReceived API at its default value NO.
 * So below test case `testImpressionNotRecorded` will always be failed where we are asserting `impressionurlWasFired` should be false.
 * Thus commenting this testcase.
 //Test impression tracker is not fired when banner is not in Window and countImpressionOnAdReceived is at its default value NO
 - (void)testImpressionNotRecorded {
 //[self.bannerAdView setCountImpressionOnHTMLLoad:NO]; // This is also the default so not using for testing
 [self.bannerAdView loadAd];
 self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
 [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
 handler:^(NSError *error) {
 
 }];
 XCTAssertEqual(self.bannerAdView.adResponseInfo.adType, ANAdTypeBanner);
 [XCTestCase delayForTimeInterval:3.0];
 XCTAssertFalse(self.impressionurlWasFired);
 
 
 }
 *
 */



- (void)requestLoaded:(NSNotification *)notification {
    NSURLRequest *request = notification.userInfo[kANHTTPStubURLProtocolRequest];
    if (self.impressionurlString && [[request.URL absoluteString] isEqual:self.impressionurlString]) {
        self.impressionurlWasFired = YES;
    }
}


#pragma mark - Stubbing

- (void) stubRequestWithResponse:(NSString *)responseName {
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

#pragma mark - ANAdDelegate

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
    [self.loadAdSuccesfulException fulfill];
}


- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error {
    [self.loadAdSuccesfulException fulfill];
}


@end
