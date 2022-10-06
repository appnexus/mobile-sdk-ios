/*   Copyright 2017 APPNEXUS INC
 
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
#import "ANBannerAdView+ANTest.h"
#import "ANAdFetcher+ANTest.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "XCTestCase+ANAdResponse.h"
#import "ANTestGlobal.h"

@interface ANBannerVideoAutoRefreshAdViewTestCase : XCTestCase<ANBannerAdViewDelegate>
@property (nonatomic, readwrite, strong)  ANBannerAdView        *banner;
@property (nonatomic, strong) XCTestExpectation *loadAdSuccesfulException;
@end

@implementation ANBannerVideoAutoRefreshAdViewTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}


- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.loadAdSuccesfulException = nil;
    self.banner.delegate = nil;
    self.banner.appEventDelegate = nil;
    [self.banner removeFromSuperview];
    self.banner = nil;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}

-(void) setupBannerVideoAdWithPlacementID:(NSString *)placementID
{    
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    self.banner = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)
                                            placementId:placementID
                                                 adSize:CGSizeMake(320, 480)];
    self.banner.shouldAllowVideoDemand = true;
    self.banner.accessibilityLabel = @"AdView";
    self.banner.autoRefreshInterval = 16;
    self.banner.delegate = self;
    self.banner.rootViewController = [ANGlobal getKeyWindow].rootViewController;
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.banner];
}

#pragma mark - Test methods.



// Checks to see if AutoRefresh on and if the /ut response is a HTML banner then AutoRefresh timer is still active
// Also checks if the received media type is Banner.
- (void) testBannerAutoRefresh
{
    [self setupBannerVideoAdWithPlacementID:@"1281482"];
    [self stubRequestWithResponse:@"SuccessfulStandardAdFromRTBObjectResponse"];
    [self.banner loadAd];
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertNotNil(self.banner.adFetcher.autoRefreshTimer);
    XCTAssertEqual(self.banner.adResponseInfo.adType, ANAdTypeBanner);
}



// Checks to see if AutoRefresh on and if the /ut response is a Video then AutoRefresh timer is turned off
- (void) testVideoAutoRefresh
{
    self.banner.shouldAllowVideoDemand = true;
    [self setupBannerVideoAdWithPlacementID:@"9887537"];
    [self stubRequestWithResponse:@"SuccessfulOutstreamVideoResponse"];
    [self.banner loadAd];
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqual(self.banner.adResponseInfo.adType, ANAdTypeVideo);
    XCTAssertNil(self.banner.adFetcher.autoRefreshTimer);
}



// Checks to see if AutoRefresh on and video errored out after playing then Auto refresh is turned back on
- (void) testVideoAutoRefreshVideoError
{
    [self setupBannerVideoAdWithPlacementID:@"9887537"];
    [self stubRequestWithResponse:@"SuccessfulOutstreamVideoFailedResponse"];
    [self.banner loadAd];
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertNotNil(self.banner.adFetcher.autoRefreshTimer);
    
    // TODO Need to inject video-error by hand here into ANAdWebViewController -->. #pragma mark - WKScriptMessageHandler. userContentController: (WKUserContentController *)userContentController
    
    // TODO Need to assert autoRefreshTimer not nil if video error.
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



