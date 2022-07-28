/*
 *
 *    Copyright 2017 APPNEXUS INC
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */
#import <XCTest/XCTest.h>
#import "ANInterstitialAd.h"
#import "ANInterstitialAd+ANTest.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "XCTestCase+ANAdResponse.h"
#import "XandrAd.h"
#define  ROOT_VIEW_CONTROLLER  [ANGlobal getKeyWindow].rootViewController;
@interface ANInterstitialAdTestCase : XCTestCase <ANInterstitialAdDelegate>
@property (nonatomic, readwrite, strong)  ANInterstitialAd      *interstitial;
@property (nonatomic, strong) XCTestExpectation *loadAdSuccesfulException;
@property (nonatomic, strong) XCTestExpectation *closeAdSuccesfulException;
@property (nonatomic, readwrite)  BOOL  enableAutoDismissDelay;
@property (nonatomic, readwrite)  BOOL  didAdClose;
@end
@implementation ANInterstitialAdTestCase
- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];
    self.interstitial = [[ANInterstitialAd alloc] initWithPlacementId:@"1"];
    self.interstitial.delegate = self;
}
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.interstitial = nil;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
    
}
- (void)testANInterstitialWithTrue
{
    [self initializeANInterstitialTrue];
    XCTAssertEqual(@"1", [self.interstitial placementId]);
    XCTAssertTrue(self.interstitial.dismissOnClick);
}
- (void)testANInterstitialAdWithWithFalse
{
    [self initializeANInterstitialFalse];
    XCTAssertEqual(@"1", [self.interstitial placementId]);
    XCTAssertFalse(self.interstitial.dismissOnClick);
    
}
- (void)testANInterstitialAdWithDefault
{
    XCTAssertEqual(@"1", [self.interstitial placementId]);
    XCTAssertFalse(self.interstitial.dismissOnClick);
}
-(void) initializeANInterstitialFalse {
    self.interstitial.dismissOnClick = false;
}
-(void) initializeANInterstitialTrue {
    self.interstitial.dismissOnClick = true;
}
- (void)testANInterstitialWithAutoDismissAdDelay
{
    self.enableAutoDismissDelay = true;
    [self stubRequestWithResponse:@"SuccessfulStandardAdFromRTBObjectResponse"];
    [self.interstitial loadAd];
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                 }];
    XCTAssertEqual(10, self.interstitial.controller.autoDismissAdDelay);
    self.closeAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidClose to be received"];
    
    [self waitForExpectationsWithTimeout:5 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertTrue(self.didAdClose);
}
- (void)testANInterstitialWithoutAutoDismissAdDelay
{
    self.enableAutoDismissDelay = false;
    [self stubRequestWithResponse:@"SuccessfulStandardAdFromRTBObjectResponse"];
    [self.interstitial loadAd];
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqual(-1, self.interstitial.controller.autoDismissAdDelay);
    
    [self.interstitial.controller.closeButton sendActionsForControlEvents: UIControlEventTouchUpInside];
    self.closeAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidClose to be received"];
    
    [self waitForExpectationsWithTimeout:5 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertTrue(self.didAdClose);
    
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
    UIViewController *controller = ROOT_VIEW_CONTROLLER;
    
    if(self.enableAutoDismissDelay){
        [self.interstitial displayAdFromViewController:controller autoDismissDelay:10];
    }else{
        [self.interstitial displayAdFromViewController:controller];
    }
    [self.loadAdSuccesfulException fulfill];
}
-(void)adDidClose:(id<ANAdProtocol>)ad{
    self.didAdClose = true;
    [self.closeAdSuccesfulException fulfill];
}
- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error {
    [self.loadAdSuccesfulException fulfill];
    
}
@end
