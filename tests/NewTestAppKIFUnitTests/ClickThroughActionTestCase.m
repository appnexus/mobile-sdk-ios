/*   Copyright 2018 APPNEXUS INC
 
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
#import "ANInterstitialAd.h"
#import "ANURLConnectionStub.h"
#import "ANHTTPStubbingManager.h"
#import "XCTestCase+ANCategory.h"
#import "ANMRAIDContainerView.h"
#import "ANANJAMImplementation.h"
#import "ANBrowserViewController.h"
#import "UIApplication+ANTest.h"
#import "ANTestGlobal.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANLogging.h"


static NSTimeInterval  durationWaitForBrowser  = 10.0;
static NSTimeInterval  durationWaitForView     =  3.0;



@interface ClickThroughActionTestCase : KIFTestCase <UIWebViewDelegate, ANBannerAdViewDelegate, ANInterstitialAdDelegate>

@property (nonatomic, strong)  UIViewController  *rootVC;

@property (nonatomic, strong)  ANBannerAdView  *bannerAd;
@property (nonatomic)  CGFloat  bannerWidth;
@property (nonatomic)  CGFloat  bannerHeight;
@property (nonatomic)  CGFloat  bannerOriginX;
@property (nonatomic)  CGFloat  bannerOriginY;

@property (nonatomic, strong)  ANInterstitialAd  *interstitialAd;

@property (nonatomic, strong) XCTestExpectation  *internalBrowserExpectation;
@property (nonatomic, strong) XCTestExpectation  *externalBrowserExpectation;
@property (nonatomic, strong) XCTestExpectation  *clickThroughURLExpectation;

@property (nonatomic)  BOOL  calledAdDidPresent;
@property (nonatomic)  BOOL  calledAdWillLeaveApplication;
@property (nonatomic)  BOOL  calledAdWasClicked;
@property (nonatomic)  BOOL  calledAdWasClickedWithURL;

@property (nonatomic, strong)  NSString  *clickThroughURL;


@end




@implementation ClickThroughActionTestCase

#pragma mark - Test lifecycle.

- (void)setUp 
{
    [super setUp];

    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;

    //
    self.rootVC = [[UIApplication sharedApplication] keyWindow].rootViewController;

    self.bannerAd = nil;
    self.interstitialAd = nil;

    self.calledAdDidPresent = NO;
    self.calledAdWillLeaveApplication = NO;
    self.calledAdWasClicked = NO;
    self.calledAdWasClickedWithURL = NO;

    self.clickThroughURL = nil;

    self.internalBrowserExpectation = nil;
    self.externalBrowserExpectation = nil;
    self.clickThroughURLExpectation = nil;
    
    //
    self.bannerWidth = 300;
    self.bannerHeight = 250;
    self.bannerOriginX = 50;
    self.bannerOriginY = 50;

    self.bannerAd = [[ANBannerAdView alloc] initWithFrame: CGRectMake(self.bannerOriginX, self.bannerOriginY, self.bannerWidth, self.bannerHeight)
                                              placementId: @"10001"
                                                   adSize: CGSizeMake(self.bannerWidth, self.bannerHeight)];

    self.bannerAd.rootViewController = self.rootVC;
    self.bannerAd.delegate = self;

    [self.rootVC.view addSubview:self.bannerAd];
}

- (void)tearDown 
{
    [super tearDown];

    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];

    [self.bannerAd removeFromSuperview];
    self.bannerAd.delegate = nil;
    self.bannerAd.appEventDelegate = nil;
    self.bannerAd = nil;
    self.interstitialAd = nil;
    self.internalBrowserExpectation = nil;
    self.externalBrowserExpectation = nil;
    self.clickThroughURLExpectation = nil;
    self.clickThroughURL = nil;
    [[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController dismissViewControllerAnimated: NO
                                                                                                               completion: nil ];
}




#pragma mark - Test methods.

- (void)testSDKBrowserWithOldAPI
{
    [self stubRequestWithResponse:@"ClickThroughActionBasicBannerResponse"];

    self.bannerAd.opensInNativeBrowser = NO;
    self.internalBrowserExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    //
    [self.bannerAd loadAd];

    [tester waitForTimeInterval:durationWaitForView * 2];
    [tester tapScreenAtPoint:CGPointMake(self.bannerWidth / 2, self.bannerHeight / 2)];

    [tester waitForTimeInterval:durationWaitForView * 4];
    [self waitForExpectationsWithTimeout:durationWaitForBrowser handler:nil];

    //
    XCTAssertTrue([self.rootVC.presentedViewController isKindOfClass:[ANBrowserViewController class]]);
    XCTAssertTrue(self.calledAdWasClicked);
}

- (void)testDeviceBrowserWithOldAPI
{
    [self stubRequestWithResponse:@"ClickThroughActionBasicBannerResponse"];

    self.bannerAd.opensInNativeBrowser = YES;
    self.externalBrowserExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    //
    [self.bannerAd loadAd];

    [tester waitForTimeInterval:durationWaitForView * 2];
    [tester tapScreenAtPoint:CGPointMake(self.bannerWidth / 2, self.bannerHeight / 2)];

    [tester waitForTimeInterval:durationWaitForView * 2];
    [self waitForExpectationsWithTimeout:durationWaitForBrowser handler:nil];

    //
    XCTAssertTrue(self.calledAdWillLeaveApplication);
    XCTAssertTrue(self.calledAdWasClicked);
}

- (void) testChangesToTheOldAPIAreReflectedInTheNewAPI
{
    self.bannerAd.clickThroughAction = ANClickThroughActionReturnURL;

    self.bannerAd.opensInNativeBrowser = NO;
    XCTAssertTrue(ANClickThroughActionOpenSDKBrowser == self.bannerAd.clickThroughAction);

    self.bannerAd.opensInNativeBrowser = YES;
    XCTAssertTrue(ANClickThroughActionOpenDeviceBrowser == self.bannerAd.clickThroughAction);
}

- (void) testChangesToTheNewAPIAreReflectedInTheOldAPI
{
    self.bannerAd.opensInNativeBrowser = YES;

    self.bannerAd.clickThroughAction = ANClickThroughActionOpenSDKBrowser;
    XCTAssertTrue(NO == self.bannerAd.opensInNativeBrowser);

    self.bannerAd.clickThroughAction = ANClickThroughActionOpenDeviceBrowser;
    XCTAssertTrue(YES == self.bannerAd.opensInNativeBrowser);
}

- (void) testChangesToTheOldAPIAreReflectedInTheNewAPIForNativeResponseEntrypoint
{
    ANNativeAdResponse  *nativeResponse  = [[ANNativeAdResponse alloc] init];

    nativeResponse.clickThroughAction = ANClickThroughActionReturnURL;

    nativeResponse.opensInNativeBrowser = NO;
    XCTAssertTrue(ANClickThroughActionOpenSDKBrowser == nativeResponse.clickThroughAction);

    nativeResponse.opensInNativeBrowser = YES;
    XCTAssertTrue(ANClickThroughActionOpenDeviceBrowser == nativeResponse.clickThroughAction);
}

- (void) testChangesToTheNewAPIAreReflectedInTheOldAPIForNativeResponseEntrypoint
{
    ANNativeAdResponse  *nativeResponse  = [[ANNativeAdResponse alloc] init];

    nativeResponse.opensInNativeBrowser = YES;

    nativeResponse.clickThroughAction = ANClickThroughActionOpenSDKBrowser;
    XCTAssertTrue(NO == nativeResponse.opensInNativeBrowser);

    nativeResponse.clickThroughAction = ANClickThroughActionOpenDeviceBrowser;
    XCTAssertTrue(YES == nativeResponse.opensInNativeBrowser);
}

- (void)testGetClickThroughURLFromBannerEntrypoint
{
    [self stubRequestWithResponse:@"ClickThroughActionBasicBannerResponse"];

    self.bannerAd.clickThroughAction = ANClickThroughActionReturnURL;
    self.clickThroughURLExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    //
    [self.bannerAd loadAd];

    [tester waitForTimeInterval:durationWaitForView];
    [tester tapScreenAtPoint:CGPointMake(self.bannerWidth / 2, self.bannerHeight / 2)];

    [self waitForExpectationsWithTimeout:durationWaitForBrowser handler:nil];

    //
    XCTAssertTrue(self.calledAdWasClickedWithURL);
    XCTAssertFalse(self.calledAdWasClicked);
    XCTAssertTrue([self.clickThroughURL length] > 0);
}

- (void)testGetClickThroughURLFromInterstitialEntrypoint
{
    [self stubRequestWithResponse:@"ClickThroughActionBasicBannerResponse"];

    self.bannerAd.clickThroughAction = ANClickThroughActionReturnURL;
    self.clickThroughURLExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    //
    self.interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:@"10203040"];

    self.interstitialAd.delegate = self;
    self.interstitialAd.clickThroughAction = ANClickThroughActionReturnURL;

    [self.interstitialAd loadAd];

    [tester waitForTimeInterval:durationWaitForView * 2];
    CGFloat  screenWidth   = self.rootVC.view.frame.size.width;
    CGFloat  screenHeight  = self.rootVC.view.frame.size.height;
    [tester tapScreenAtPoint:CGPointMake(screenWidth / 2, screenHeight / 2)];

    [self waitForExpectationsWithTimeout:durationWaitForBrowser*2 handler:nil];

    //
    XCTAssertTrue(self.calledAdWasClickedWithURL);
    XCTAssertFalse(self.calledAdWasClicked);
    XCTAssertTrue([self.clickThroughURL length] > 0);
}

- (void)testGetClickThroughURLFromBannerVideoEntrypoint
{
    [self stubRequestWithResponse:@"ClickThroughActionBasicOutstreamVideoResponse"];

    self.bannerAd.clickThroughAction = ANClickThroughActionReturnURL;
    self.clickThroughURLExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    //
    [self.bannerAd loadAd];

    [tester waitForTimeInterval:durationWaitForView * 2];                              //XXX
    [tester tapScreenAtPoint:CGPointMake(self.bannerWidth, self.bannerOriginY + 1)];   //XXX


    [self waitForExpectationsWithTimeout:durationWaitForBrowser handler:nil];

    //
    XCTAssertTrue(self.calledAdWasClickedWithURL);
    XCTAssertFalse(self.calledAdWasClicked);
    XCTAssertTrue([self.clickThroughURL length] > 0);
}




#pragma mark - Stubbing

- (void)stubRequestWithResponse:(NSString *)responseName 
{
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *baseResponse = [NSString stringWithContentsOfFile: [currentBundle pathForResource: responseName
                                                                                         ofType: @"json" ]
                                                       encoding: NSUTF8StringEncoding
                                                          error: nil ];

    ANURLConnectionStub  *requestStub  = [[ANURLConnectionStub alloc] init];

    requestStub.requestURL    = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    requestStub.responseCode  = 200;
    requestStub.responseBody  = baseResponse;

    [[ANHTTPStubbingManager sharedStubbingManager] addStub:requestStub];
}




#pragma mark - ANBannerAdViewDelegate

- (void)adDidReceiveAd:(id)ad
{
TESTTRACE();
    if (self.interstitialAd)  {
        [self.interstitialAd displayAdFromViewController:self.rootVC];
    }
}

- (void)adDidPresent:(id)ad
{
TESTTRACE();
    [self.internalBrowserExpectation fulfill];
    self.calledAdDidPresent = YES;
}

- (void)adWillLeaveApplication:(id)ad
{
TESTTRACE();
    [self.externalBrowserExpectation fulfill];
    self.calledAdWillLeaveApplication = YES;
}

- (void)adWasClicked:(id)ad
{
TESTTRACE();
    self.calledAdWasClicked = YES;
}

- (void)adWasClicked:(id)ad withURL:(NSString *)urlString
{
TESTTRACEM(@"ClickThroughURL=%@", urlString);
    self.calledAdWasClickedWithURL = YES;

    if (urlString) {
        [self.clickThroughURLExpectation fulfill];
        self.clickThroughURL = urlString;
    }
}


@end

