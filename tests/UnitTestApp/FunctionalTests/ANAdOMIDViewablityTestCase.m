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
#import <CoreLocation/CoreLocation.h>

#import "ANHTTPStubbingManager.h"
#import "ANBannerAdView+ANTest.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANTestGlobal.h"
#import "ANInterstitialAd.h"
#import "ANInterstitialAd+ANTest.h"
#import "ANNativeAdResponse+ANTest.h"
#import "ANNativeAdRequest+ANTest.h"
#import "ANInstreamVideoAd.h"
#import "ANInstreamVideoAd+Test.h"
#import "ANVideoAdPlayer.h"
#import "ANAdView+PrivateMethods.h"
#import "XandrAd.h"


@interface ANAdOMIDViewablityTestCase : XCTestCase<ANBannerAdViewDelegate, ANInterstitialAdDelegate, ANNativeAdRequestDelegate , ANInstreamVideoAdLoadDelegate>

@property (nonatomic, readwrite, strong)  ANBannerAdView        *banner;
@property (nonatomic, readwrite, strong)  ANInterstitialAd      *interstitial;
@property (nonatomic, readwrite, strong)  ANNativeAdRequest     *adRequest;
@property (nonatomic, readwrite, strong)  ANNativeAdResponse    *adResponseInfo;
@property (nonatomic, readwrite, strong)  ANInstreamVideoAd  *instreamVideoAd;
@property (nonatomic, readwrite)  BOOL  receiveAdSuccess;
@property (nonatomic, readwrite)  BOOL  receiveAdFailure;
@property (nonatomic, strong) XCTestExpectation *loadAdResponseReceivedExpectation;
@property (nonatomic, strong) XCTestExpectation *loadAdResponseFailedExpectation;
@property (nonatomic) UIView *friendlyObstruction;
@property (nonatomic) UIView *nativeView;

@end
@implementation ANAdOMIDViewablityTestCase

#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    self.receiveAdSuccess = NO;
    self.receiveAdFailure = NO;
    self.friendlyObstruction=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 250)];
    self.nativeView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 250)];
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];

}

- (void)tearDown {
    [super tearDown];
    [self clearSetupBannerAd];
    [self clearSetupInterstitialAd];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    self.loadAdResponseReceivedExpectation = nil;
}


- (void)clearSetupBannerAd {
    self.banner = nil;
    self.banner.delegate = nil;
    self.banner.appEventDelegate = nil;
    [self.banner removeFromSuperview];
    self.banner = nil;
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}

-(void) setupBannerAd{
    [self clearSetupBannerAd];
    self.banner = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)
                                            placementId:@"13653381"
                                                 adSize:CGSizeMake(320, 480)];
    self.banner.autoRefreshInterval = 0;
    self.banner.delegate = self;
    self.banner.rootViewController = [ANGlobal getKeyWindow].rootViewController;
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.banner];
}

- (void)clearSetupInterstitialAd {
    self.interstitial = nil;
    [self.interstitial removeFromSuperview];
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}

-(void) setupInterstitialAd{
    [self clearSetupInterstitialAd];
    self.interstitial = [[ANInterstitialAd alloc] initWithPlacementId:@"1"];
    self.interstitial.delegate = self;
}

- (void)clearSetupNativeAd {
    self.adRequest = nil;
    self.adResponseInfo = nil;
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}

-(void) setupNativeAd{
    [self clearSetupNativeAd];
    self.adRequest = [[ANNativeAdRequest alloc] init];
    self.adRequest.delegate = self;
}

- (void)clearSetupInstreamAd {
    self.instreamVideoAd = nil;
    self.instreamVideoAd.adPlayer = nil;
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}
-(void) setupInstreamAd {
    [self clearSetupInstreamAd];
    self.instreamVideoAd  = [[ANInstreamVideoAd alloc] initWithPlacementId:@"12534678"];
}


#pragma mark - Test methods.

- (void)testFriendlyObstructionBannerAd {
    
    [self setupBannerAd];
  
    [self.banner addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    XCTAssertEqual(self.banner.obstructionViews.count, 1);
    
    [self.banner removeOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    XCTAssertEqual(self.banner.obstructionViews.count, 0);
    
    [self.banner addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    XCTAssertEqual(self.banner.obstructionViews.count, 1);
    
    
    [self.banner removeAllOpenMeasurementFriendlyObstructions];
    XCTAssertEqual(self.banner.obstructionViews.count, 0);
    
}


- (void)testFriendlyObstructionBannerAdNullCheck {
    
    [self setupBannerAd];
    
    [self.banner addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    [self.banner addOpenMeasurementFriendlyObstruction:nil];

    XCTAssertEqual(self.banner.obstructionViews.count, 1);
    [self.banner removeOpenMeasurementFriendlyObstruction:nil];
    XCTAssertEqual(self.banner.obstructionViews.count, 1);

    [self.banner removeAllOpenMeasurementFriendlyObstructions];
    XCTAssertEqual(self.banner.obstructionViews.count, 0);
}

- (void) testAdFriendlyObstructionBannerNativeRendererAd
{
    [self setupBannerAd];
    self.banner.shouldAllowNativeDemand = YES;
    self.banner.enableNativeRendering = YES;
    [self.banner setAdSize:CGSizeMake(300, 250)];
    [self stubRequestWithResponse:@"ANAdResponseRTB_Native"];
    [self.banner loadAd];
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];

    [self.banner addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    XCTAssertEqual(self.banner.obstructionViews.count, 1);
    
    [self.banner removeOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    XCTAssertEqual(self.banner.obstructionViews.count, 0);
    
    [self.banner addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    XCTAssertEqual(self.banner.obstructionViews.count, 1);
    
    
    [self.banner removeAllOpenMeasurementFriendlyObstructions];
    XCTAssertEqual(self.banner.obstructionViews.count, 0);
    
    
    
    
}


- (void) testAdFriendlyObstructionBannerNativeAd
{
    [self stubRequestWithResponse:@"ANAdResponseRTB_Native"];
    [self setupBannerAd];
    self.banner.shouldAllowNativeDemand = YES;
    [self.banner loadAd];
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout: kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
}

- (void)testFriendlyObstructionInterstitialAd {
    
    [self setupInterstitialAd];

    [self.interstitial addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    XCTAssertEqual(self.interstitial.obstructionViews.count, 1);
    
    [self.interstitial removeOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    XCTAssertEqual(self.interstitial.obstructionViews.count, 0);
    
    [self.interstitial addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    XCTAssertEqual(self.interstitial.obstructionViews.count, 1);
    
    
    [self.interstitial removeAllOpenMeasurementFriendlyObstructions];
    XCTAssertEqual(self.interstitial.obstructionViews.count, 0);
}



- (void)testFriendlyObstructionInterstitialAdNullCheck {
    
    [self setupInterstitialAd];
    
    [self.interstitial addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    [self.interstitial addOpenMeasurementFriendlyObstruction:nil];

    XCTAssertEqual(self.interstitial.obstructionViews.count, 1);
    [self.interstitial removeOpenMeasurementFriendlyObstruction:nil];
    XCTAssertEqual(self.interstitial.obstructionViews.count, 1);

    [self.interstitial removeAllOpenMeasurementFriendlyObstructions];
    XCTAssertEqual(self.interstitial.obstructionViews.count, 0);
}



- (void)testFriendlyObstructionNativeAd {
    [self setupNativeAd];
    [self stubRequestWithResponse:@"ANAdResponseRTB_Native"];
    [self.adRequest loadAd];
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
}

- (void) testFriendlyObstructionInstreamAd
{
    [self setupInstreamAd];

    [self.instreamVideoAd addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    XCTAssertEqual(self.instreamVideoAd.obstructionViews.count, 1);
    
    [self.instreamVideoAd removeOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    XCTAssertEqual(self.instreamVideoAd.obstructionViews.count, 0);
    
    [self.instreamVideoAd addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    XCTAssertEqual(self.instreamVideoAd.obstructionViews.count, 1);
    
    
    [self.instreamVideoAd removeAllOpenMeasurementFriendlyObstructions];
    XCTAssertEqual(self.instreamVideoAd.obstructionViews.count, 0);
}

- (void)testFriendlyObstructionInstreamAdNullCheck {
    
    [self setupInstreamAd];

    [self.instreamVideoAd addOpenMeasurementFriendlyObstruction:self.friendlyObstruction];
    [self.instreamVideoAd addOpenMeasurementFriendlyObstruction:nil];

    XCTAssertEqual(self.instreamVideoAd.obstructionViews.count, 1);
    [self.instreamVideoAd removeOpenMeasurementFriendlyObstruction:nil];
    XCTAssertEqual(self.instreamVideoAd.obstructionViews.count, 1);

    [self.instreamVideoAd removeAllOpenMeasurementFriendlyObstructions];
    XCTAssertEqual(self.instreamVideoAd.obstructionViews.count, 0);
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
    [self.loadAdResponseReceivedExpectation fulfill];
    self.receiveAdSuccess = YES;
    if ([ad isKindOfClass:[ANInterstitialAd class]]) {
        [self.interstitial displayAdFromViewController:[ANGlobal getKeyWindow].rootViewController];
    }
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    TESTTRACEM(@"error.info=%@", error.userInfo);
    
    [self.loadAdResponseReceivedExpectation fulfill];
    [self.loadAdResponseFailedExpectation fulfill];
    self.receiveAdFailure = YES;
}

#pragma mark - ANNativeAdRequestDelegate

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response{
    

    [response registerViewForTracking:self.nativeView withRootViewController:self clickableViews:@[] openMeasurementFriendlyObstructions:@[self.friendlyObstruction] error:nil];
    XCTAssertEqual(response.obstructionViews.count, 1);
    
    [response registerViewForTracking:self.nativeView withRootViewController:self clickableViews:@[] openMeasurementFriendlyObstructions:@[] error:nil];
    XCTAssertEqual(response.obstructionViews.count, 0);
    
    
    
    [self.loadAdResponseReceivedExpectation fulfill];
    self.receiveAdSuccess = YES;
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error withAdResponseInfo:(ANAdResponseInfo *)adResponseInfo{
    TESTTRACEM(@"error.info=%@", error.userInfo);
    
    [self.loadAdResponseReceivedExpectation fulfill];
    [self.loadAdResponseFailedExpectation fulfill];
    self.receiveAdFailure = YES;
}

- (void)ad:(id)loadInstance didReceiveNativeAd:(id)responseInstance{
    ANNativeAdResponse *response = (ANNativeAdResponse *)responseInstance;

    
    [response registerViewForTracking:self.nativeView withRootViewController:self clickableViews:@[] openMeasurementFriendlyObstructions:@[self.friendlyObstruction] error:nil];
    XCTAssertEqual(response.obstructionViews.count, 1);
    
    [response registerViewForTracking:self.nativeView withRootViewController:self clickableViews:@[] openMeasurementFriendlyObstructions:@[] error:nil];
    XCTAssertEqual(response.obstructionViews.count, 0);
    
    
    [self.loadAdResponseReceivedExpectation fulfill];
    self.receiveAdSuccess = YES;
}

@end
