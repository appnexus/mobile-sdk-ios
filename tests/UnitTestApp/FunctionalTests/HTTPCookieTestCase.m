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
#import "ANHTTPStubbingManager.h"
#import "ANTestGlobal.h"
#import "ANBannerAdView+ANTest.h"
#import "ANHTTPCookieStorage.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANVideoAdPlayer+Test.h"
#import "ANAdFetcherBase+ANTest.h"
#import "ANAdWebViewController+ANTest.h"
#import "ANInstreamVideoAd.h"
#import "ANTimeTracker.h"
#import "XandrAd.h"


@interface HTTPCookieTestCase : XCTestCase <ANBannerAdViewDelegate , ANInstreamVideoAdLoadDelegate>
@property (nonatomic, readwrite, strong)  ANBannerAdView        *banner;
@property (nonatomic, strong) XCTestExpectation *loadAdResponseReceivedExpectation;
@property (nonatomic, strong) XCTestExpectation *loadAdSecondResponseReceivedExpectation;
@property ( readwrite)  int        requestOrder;
@property (nonatomic, readwrite, strong)  ANInstreamVideoAd  *instreamVideoAd;

@end

@implementation HTTPCookieTestCase

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    self.banner = nil;
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];

}

- (void)tearDown {
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    self.banner.delegate = nil;
    self.banner.appEventDelegate = nil;
    [self.banner removeFromSuperview];
    self.banner = nil;
    [[ANGlobal getKeyWindow].rootViewController.presentedViewController dismissViewControllerAnimated:NO
                                                                                                               completion:nil];
    
    self.loadAdResponseReceivedExpectation = nil;
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
        [additionalView removeFromSuperview];
    }
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}


-(NSString *) getCookieString: (NSDictionary *)cookie{
    return [NSString stringWithFormat:@"%@", cookie];
}

- (void)testBannerAdCookieSet {
    
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    XCTAssertNotNil([[ANHTTPCookieStorage sharedInstance] getCurrentCookie]);
    self.requestOrder = 1;
    self.banner = [[ANBannerAdView alloc] initWithFrame:CGRectMake(50 , 50 , 300,250)
                                            placementId:BANNER_PLACEMENT
                                                 adSize:CGSizeMake(300 , 250)];
    self.banner.forceCreativeId = 182434863;
    self.banner.accessibilityLabel = @"AdView";
    self.banner.autoRefreshInterval = 0;
    self.banner.delegate = self;
    [self.banner loadAd];
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
    }];
    NSDictionary *lastResponseCookie = [ANHTTPCookieStorage sharedInstance].adFetcherResponseCookie;
    XCTAssertNotEqual([ANHTTPCookieStorage sharedInstance].adFetcherRequestCookie , lastResponseCookie);
    XCTAssertTrue([[[ANHTTPCookieStorage sharedInstance].bannerWebViewCookie objectForKey:@"Cookie"] containsString:[lastResponseCookie objectForKey:@"Cookie"]]);
    XCTAssertTrue([[[ANHTTPCookieStorage sharedInstance].getCurrentCookie objectForKey:@"Cookie"] containsString:[lastResponseCookie objectForKey:@"Cookie"]]);
    self.requestOrder = 2;
    [self.banner loadAd];
    self.loadAdSecondResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
    }];
    XCTAssertNotEqual([ANHTTPCookieStorage sharedInstance].adFetcherRequestCookie , lastResponseCookie);
    XCTAssertEqualObjects([ANHTTPCookieStorage sharedInstance].adFetcherResponseCookie , lastResponseCookie);
}

- (void)testVideoAdCookieSet {
    
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    XCTAssertNotNil([[ANHTTPCookieStorage sharedInstance] getCurrentCookie]);
    self.requestOrder = 1;
    self.instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithPlacementId:VIDEO_PLACEMENT];
    self.instreamVideoAd.forceCreativeId = 182434863;
    [self.instreamVideoAd loadAdWithDelegate:self];
    
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
    }];
    NSDictionary *lastResponseCookie = [ANHTTPCookieStorage sharedInstance].adFetcherResponseCookie;
    XCTAssertNotEqual([ANHTTPCookieStorage sharedInstance].adFetcherRequestCookie , lastResponseCookie);
    XCTAssertTrue([[[ANHTTPCookieStorage sharedInstance].videoAdPlayerCookie objectForKey:@"Cookie"] containsString:[lastResponseCookie objectForKey:@"Cookie"]]);
    self.requestOrder = 2;
    [self.instreamVideoAd loadAdWithDelegate:self];
    self.loadAdSecondResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
    }];
    
    
    XCTAssertNotEqual([ANHTTPCookieStorage sharedInstance].adFetcherRequestCookie , lastResponseCookie);
    XCTAssertEqualObjects([ANHTTPCookieStorage sharedInstance].adFetcherResponseCookie , lastResponseCookie);
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

- (void)fulfillExpectation:(XCTestExpectation *)expectation
{
    [expectation fulfill];
}

- (void)waitForTimeInterval:(NSTimeInterval)delay
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    [self performSelector:@selector(fulfillExpectation:) withObject:expectation afterDelay:delay];
    
    [self waitForExpectationsWithTimeout:delay + 1 handler:nil];
}


#pragma mark - ANAdDelegate

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad
{
    if(self.requestOrder == 1){
        [self.loadAdResponseReceivedExpectation fulfill];
    }else if(self.requestOrder == 2){
        [self.loadAdSecondResponseReceivedExpectation fulfill];
    }
}


- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    TESTTRACEM(@"error.info=%@", error.userInfo);
    
}

@end
