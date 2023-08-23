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

#import "ANHTTPStubbingManager.h"
#import "TestGlobal.h"
#import "MARHelper.h"

#import "ANLogManager.h"
#import "ANSDKSettings.h"

#import "ANAdView.h"
#import "ANAdView+PrivateMethods.h"
#import "ANAdViewInternalDelegate.h"

#import "ANBannerAdView.h"
#import "ANBannerAdView+ANTest.h"
#import "ANInterstitialAd+ANTest.h"
#import "ANNativeAdRequest+ANTest.h"
#import "ANInstreamVideoAd+Test.h"
#import "ANMultiAdRequest.h"

#import "ANAdFetcherBase.h"
#import "ANAdFetcher+ANTest.h"
#import "ANMRAIDContainerView+ANTest.h"
#import "XandrAd.h"
#import "ANNativeRenderingViewController.h"




#pragma mark -

@interface  LazyLoadFeatureTests  :XCTestCase <ANBannerAdViewDelegate, ANMultiAdRequestDelegate, ANInstreamVideoAdLoadDelegate, ANNativeAdRequestDelegate>

@property (nonatomic, readwrite, strong)  ANBannerAdView  *lazyBanner;
@property (nonatomic, readwrite, strong)  ANBannerAdView  *lazyBannerNativeRenderer;
@property (nonatomic, readwrite, strong)  ANBannerAdView  *multiFormatBanner;

@property (nonatomic, readwrite, strong)            ANMultiAdRequest    *mar;
@property (nonatomic, readwrite, strong, nullable)  MARAdUnits          *adUnitsForTest;

@property (nonatomic, readwrite)  NSUInteger  countOfRequestedAdUnits;

@property (nonatomic, readwrite)  ANAdResponseInfo  *responseInfoFirstTime;
@property (nonatomic, readwrite)  ANAdResponseInfo  *responseInfoSecondTime;


@property (nonatomic, strong)  XCTestExpectation  *expectationLazyAdDidReceiveAd;
@property (nonatomic, strong)  XCTestExpectation  *expectationAdDidReceiveAd;
@property (nonatomic, strong)  XCTestExpectation  *expectationAdDidReceiveNativeAd;
@property (nonatomic, strong)  XCTestExpectation  *expectationMultiAdRequestSuccess;
@property (nonatomic, strong)  XCTestExpectation  *expectationRequestFailedWithError;
@property (nonatomic, strong)  XCTestExpectation  *expectationAdDidReceiveAdBannerNativeRenderer;


@property (nonatomic, strong)  XCTestExpectation  *expectationAdResponseInfoIsDefined;
@property (nonatomic, strong)  XCTestExpectation  *expectationAdResponseInfoIsDefinedAndDifferent;
@property (nonatomic, strong)  XCTestExpectation  *expectationTryToLoadWebviewSecondTimeForLazyAdUnit;
@property (nonatomic, strong)  XCTestExpectation  *expectationAutoRefreshTimerIsSetProperly;
@property (nonatomic, strong)  XCTestExpectation  *expectationFindANAdResponseInfoOnLazyFailure;
@property (nonatomic, strong)  XCTestExpectation  *expectationAdResponseInfoIsDefinedAndDifferentForTwoCallsToLoadAd;
@property (nonatomic, strong)  XCTestExpectation  *expectationRunLoadAdASecondTimeWithoutCallingLoadLazyAd;


@property (nonatomic)  BOOL  loadWebviewWhenLazyLoadCompletes;
@property (nonatomic)  BOOL  swizzleToPreventWebviewLoad;
@property (nonatomic)  BOOL  loadWebviewForAdUnitThatIsNotLazy;


@property (nonatomic, strong)  UIViewController  *rootVC;

@end




#pragma mark -

/**
 * NOTE: This feature has been renamed from "Lazy Webview" to "Lazy Load".
 */
@implementation  LazyLoadFeatureTests

#pragma mark Lifecycle.

- (void)setUp
{
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;

    [ANLogManager setANLogLevel:ANLogLevelAll];
    // Init here if not the tests will crash
      [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];

   

    //
    [self createAdUnits];

    self.mar = nil;
    self.adUnitsForTest = [[MARAdUnits alloc] initWithDelegate:self];

    [ANBannerAdView setDoNotResetAdUnitUUID:YES];
    [ANInterstitialAd setDoNotResetAdUnitUUID:YES];
    [ANNativeAdRequest setDoNotResetAdUnitUUID:YES];
    [ANInstreamVideoAd setDoNotResetAdUnitUUID:YES];


    //
    self.rootVC = [ANGlobal getKeyWindow].rootViewController;

    self.loadWebviewWhenLazyLoadCompletes               = YES;
    self.swizzleToPreventWebviewLoad                    = NO;
    self.loadWebviewForAdUnitThatIsNotLazy              = NO;

    self.responseInfoFirstTime   = nil;
    self.responseInfoSecondTime  = nil;
}

- (void)tearDown
{
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    
    //
    self.expectationLazyAdDidReceiveAd                          = nil;
    self.expectationAdDidReceiveAd                              = nil;
    self.expectationAdDidReceiveNativeAd                        = nil;
    self.expectationMultiAdRequestSuccess                       = nil;
    self.expectationRequestFailedWithError                      = nil;
    self.expectationAdDidReceiveAdBannerNativeRenderer          = nil;

    self.expectationAdResponseInfoIsDefined                     = nil;
    self.expectationAdResponseInfoIsDefinedAndDifferent         = nil;
    self.expectationTryToLoadWebviewSecondTimeForLazyAdUnit     = nil;
    self.expectationAutoRefreshTimerIsSetProperly               = nil;
    self.expectationFindANAdResponseInfoOnLazyFailure           = nil;
    self.expectationRunLoadAdASecondTimeWithoutCallingLoadLazyAd    = nil;
}

- (void)createAdUnits
{
    int  adWidth   = 300;
    int  adHeight  = 250;

    // We want to center our ad on the screen.
    CGRect   screenRect  = [[UIScreen mainScreen] bounds];
    CGFloat  originX     = (screenRect.size.width / 2) - (adWidth / 2);
    CGFloat  originY     = (screenRect.size.height / 2) - (adHeight / 2);

    // Needed for when we create our ad view.
    CGRect  rect  = CGRectMake(originX, originY, adWidth, adHeight);
    CGSize  size  = CGSizeMake(adWidth, adHeight);


    // Make some banner ad views.
    //
    self.lazyBanner = [ANBannerAdView adViewWithFrame:rect placementId:@"11112222" adSize:size];

    self.lazyBanner.delegate                 = self;
//    self.lazyBanner.rootViewController       = self.rootVC;
    self.lazyBanner.autoRefreshInterval      = 0;
    self.lazyBanner.shouldAllowVideoDemand   = NO;      // self.banner1 is always Banner-banner.
    self.lazyBanner.shouldAllowNativeDemand  = NO;

    self.lazyBanner.shouldServePublicServiceAnnouncements = NO;

   // self.lazyBanner.externalUid              = @"banner-banner";

    self.lazyBanner.enableLazyLoad = YES;
    
    
    
    
    // Make some banner native renderer ad views.
    //
    self.lazyBannerNativeRenderer = [ANBannerAdView adViewWithFrame:rect placementId:@"11112222" adSize:size];

    self.lazyBannerNativeRenderer.delegate                 = self;
    self.lazyBannerNativeRenderer.shouldAllowVideoDemand   = NO;
    self.lazyBannerNativeRenderer.shouldAllowBannerDemand = NO;
    self.lazyBannerNativeRenderer.shouldAllowNativeDemand  = YES;
    self.lazyBannerNativeRenderer.enableNativeRendering = YES;
    self.lazyBannerNativeRenderer.shouldServePublicServiceAnnouncements = NO;
    self.lazyBannerNativeRenderer.enableLazyLoad = YES;


    //
    self.multiFormatBanner = [ANBannerAdView adViewWithFrame:rect placementId:@"33334444" adSize:size];

    self.multiFormatBanner.delegate                 = self;
//    self.multiFormatBanner.rootViewController       = self.rootVC;
    self.multiFormatBanner.autoRefreshInterval      = 0;
    self.multiFormatBanner.shouldAllowVideoDemand   = YES;
    self.multiFormatBanner.shouldAllowNativeDemand  = YES;

    self.lazyBanner.shouldServePublicServiceAnnouncements = NO;

    //self.multiFormatBanner.externalUid              = @"banner-multiformat";

    self.multiFormatBanner.enableLazyLoad = NO;

}




#pragma mark - Tests.

- (void)testHTMLBannerBasicOperation
{
    [TestGlobal stubRequestWithResponse:@"LazyWebview_Basic"];

    self.expectationLazyAdDidReceiveAd  = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationLazyAdDidReceiveAd", __PRETTY_FUNCTION__]];
    self.expectationAdDidReceiveAd      = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationAdDidReceiveAd", __PRETTY_FUNCTION__]];

    //
    [self.lazyBanner loadAd];

    [self waitForExpectationsWithTimeout:kWaitVeryLong handler:nil];
}

- (void)testBannerNativeRenderingBasicOperation
{
    [TestGlobal stubRequestWithResponse:@"LazyBannerNativeRendering_Basic"];

    self.expectationLazyAdDidReceiveAd  = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationLazyAdDidReceiveAd", __PRETTY_FUNCTION__]];
    self.expectationAdResponseInfoIsDefined  = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationAdResponseInfoIsDefined", __PRETTY_FUNCTION__]];
    self.expectationAdDidReceiveAdBannerNativeRenderer      = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationAdDidReceiveAd", __PRETTY_FUNCTION__]];

    //
    [self.lazyBannerNativeRenderer loadAd];

    [self waitForExpectationsWithTimeout:kWaitVeryLong handler:nil];
}

- (void)testFeatureFlagCanBeSet
{
    XCTAssert(self.multiFormatBanner.enableLazyLoad == NO);
    self.multiFormatBanner.enableLazyLoad = YES;
    XCTAssert(self.multiFormatBanner.enableLazyLoad == YES);
}

- (void)testFeatureFlagCannotBeUnset
{
    XCTAssert(self.multiFormatBanner.enableLazyLoad == NO);
    self.multiFormatBanner.enableLazyLoad = YES;
    XCTAssert(self.multiFormatBanner.enableLazyLoad == YES);
    self.multiFormatBanner.enableLazyLoad = NO;
    XCTAssert(self.multiFormatBanner.enableLazyLoad == YES);
}

- (void)testFeatureFlagCannotBeSetDuringLoadAd
{
    XCTAssert(self.multiFormatBanner.enableLazyLoad == NO);

    //
    [TestGlobal stubRequestWithResponse:@"LazyWebview_Basic"];

    self.expectationAdDidReceiveAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    //
    [self.multiFormatBanner loadAd];

    [TestGlobal waitForSeconds: kWaitQuarterSecond
              thenExecuteBlock: ^{
                                    self.multiFormatBanner.enableLazyLoad = YES;
                                    XCTAssert(self.multiFormatBanner.enableLazyLoad == NO);
                                } ];

    [self waitForExpectationsWithTimeout:kWaitVeryLong handler:nil];
}

- (void)testAdResponseInfoIsDeliveredForLazyLoad
{
    [TestGlobal stubRequestWithResponse:@"LazyWebview_Basic"];

    self.expectationLazyAdDidReceiveAd       = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationLazyAdDidReceiveAd", __PRETTY_FUNCTION__]];
    self.expectationAdResponseInfoIsDefined  = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationAdResponseInfoIsDefined", __PRETTY_FUNCTION__]];

    //
    self.loadWebviewWhenLazyLoadCompletes = NO;
    [self.lazyBanner loadAd];

    [self waitForExpectationsWithTimeout:kWaitShort handler:nil];
}

- (void)testLoadWebviewDoesNothingForAdUnitsThatAreNotLazyLoaded
{
    [TestGlobal stubRequestWithResponse:@"LazyWebview_Basic"];

    self.expectationLazyAdDidReceiveAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationLazyAdDidReceiveAd", __PRETTY_FUNCTION__]];
    self.expectationLazyAdDidReceiveAd.inverted = YES;

    self.expectationAdDidReceiveAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationAdDidReceiveAd", __PRETTY_FUNCTION__]];
    self.expectationAdDidReceiveAd.assertForOverFulfill = YES;

    //
    self.loadWebviewWhenLazyLoadCompletes = NO;
    self.loadWebviewForAdUnitThatIsNotLazy = YES;

    [self.multiFormatBanner loadAd];

    [self waitForExpectationsWithTimeout:kWaitVeryLong handler:nil];
}

- (void)testLoadWebviewDoesNothingForLazyAdUnitsThatAreAlreadyLoaded
{
    [TestGlobal stubRequestWithResponse:@"LazyWebview_Basic"];

    self.expectationLazyAdDidReceiveAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationLazyAdDidReceiveAd", __PRETTY_FUNCTION__]];

    self.expectationAdDidReceiveAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationAdDidReceiveAd", __PRETTY_FUNCTION__]];
    self.expectationAdDidReceiveAd.assertForOverFulfill = YES;

    self.expectationTryToLoadWebviewSecondTimeForLazyAdUnit = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationTryToLoadWebviewSecondTimeForLazyAdUnit", __PRETTY_FUNCTION__]];

    //
    [self.lazyBanner loadAd];

    [self waitForExpectationsWithTimeout:kWaitShort handler:nil];
}

- (void)testLoadWebviewDoesNothingWhenAdUnitReturnsNobid
{
    [TestGlobal stubRequestWithResponse:@"LazyWebview_nobid"];

    self.expectationRequestFailedWithError              = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationRequestFailedWithError", __PRETTY_FUNCTION__]];
    self.expectationFindANAdResponseInfoOnLazyFailure   = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationFindANAdResponseInfoOnLazyFailure", __PRETTY_FUNCTION__]];

    //
    [self.lazyBanner loadAd];

    [self waitForExpectationsWithTimeout:kWaitShort handler:nil];
}

/*
 * TBD -- Replace this test with two new tests, #25 and #26, defined on feature wiki in the section "Testing >> New Test for AdUnits and Single Request Mode (SRM)".
 *
 *   https://corpwiki.xandr-services.com/display/CT/MobileSDK+AdUnit+load+re-architecture#MobileSDKAdUnitloadre-architecture-NewTestforAdUnitsandSingleRequestMode(SRM)
 *
- (void)testAutoRefreshTimerIsNotStartedBeforeLazyWebview
{
    [TestGlobal stubRequestWithResponse:@"LazyWebview_Basic"];

    self.expectationLazyAdDidReceiveAd              = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationLazyAdDidReceiveAd", __PRETTY_FUNCTION__]];
    self.expectationAdDidReceiveAd                  = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationAdDidReceiveAd", __PRETTY_FUNCTION__]];
    self.expectationAutoRefreshTimerIsSetProperly   = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationAutoRefreshTimer", __PRETTY_FUNCTION__]];

    //
    self.lazyBanner.autoRefreshInterval = 108;
    XCTAssertNil(self.lazyBanner.universalAdFetcher.autoRefreshTimer);

    [self.lazyBanner loadAd];
    XCTAssertNil(self.lazyBanner.universalAdFetcher.autoRefreshTimer);

    [self waitForExpectationsWithTimeout:kWaitShort handler:nil];
}
 *
 */

- (void)testMultiAdRequestWorksWithLazyWebview
{
    [TestGlobal stubRequestWithResponse:@"testMARCombinationAllRTB"];

    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.bannerBanner,
                                                           self.adUnitsForTest.interstitial,
                                                           self.adUnitsForTest.native,
                                                           self.adUnitsForTest.instreamVideo,
                                                           nil ];

    self.countOfRequestedAdUnits = 4;

    self.adUnitsForTest.bannerBanner.utRequestUUIDString = @"1";
    self.adUnitsForTest.interstitial.utRequestUUIDString = @"2";
    self.adUnitsForTest.native.utRequestUUIDString = @"3";
    self.adUnitsForTest.instreamVideo.utRequestUUIDString = @"4";

    XCTAssertNotNil(self.mar);


    //
    self.expectationMultiAdRequestSuccess   = [self expectationWithDescription:@"EXPECTATION: expectationMultiAdRequestSuccess"];
    self.expectationLazyAdDidReceiveAd      = [self expectationWithDescription:@"EXPECTATION: expectationLazyAdDidReceiveAd"];

    self.expectationAdDidReceiveAd                           = [self expectationWithDescription:@"EXPECTATION: expectationAdDidReceiveAd"];
    self.expectationAdDidReceiveAd.expectedFulfillmentCount  = self.countOfRequestedAdUnits;


    self.loadWebviewWhenLazyLoadCompletes = YES;
    self.adUnitsForTest.bannerBanner.enableLazyLoad = YES;
    [self.mar load];

    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];
}

- (void)testLoadWebviewFailsWhenWebviewAllocationFails
{
    [TestGlobal stubRequestWithResponse:@"LazyWebview_Basic"];

    self.expectationLazyAdDidReceiveAd                  = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationLazyAdDidReceiveAd", __PRETTY_FUNCTION__]];
    self.expectationRequestFailedWithError              = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationRequestFailedWithError", __PRETTY_FUNCTION__]];

    self.expectationAdResponseInfoIsDefined             = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationAdResponseInfoIsDefined", __PRETTY_FUNCTION__]];
    self.expectationFindANAdResponseInfoOnLazyFailure   = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationFindANAdResponseInfoOnNobidFailure", __PRETTY_FUNCTION__]];


    //
    [ANMRAIDContainerView swizzleMRAIDContainerView:YES];
    self.swizzleToPreventWebviewLoad = YES;

    [self.lazyBanner loadAd];

    [self waitForExpectationsWithTimeout:kWaitShort handler:nil];
}

- (void)testBannerNativeDoesNotAllowLazyLoading
{
    [TestGlobal stubRequestWithResponse:@"ANAdResponseRTB_Native"];

    self.expectationAdDidReceiveNativeAd = [self expectationWithDescription:@"EXPECTATION: expectationAdDidReceiveNativeAd"];

    self.expectationLazyAdDidReceiveAd           = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationLazyAdDidReceiveAd", __PRETTY_FUNCTION__]];
    self.expectationLazyAdDidReceiveAd.inverted  = YES;

    //
    self.multiFormatBanner.enableLazyLoad = YES;
    [self.multiFormatBanner loadAd];

    [self waitForExpectationsWithTimeout:kWaitShort handler:nil];
}

- (void)testBannerVideoDoesNotAllowLazyLoading
{
    [TestGlobal stubRequestWithResponse:@"SuccessfulOutstreamBannerVideoResponse"];

    self.expectationAdDidReceiveAd = [self expectationWithDescription:@"EXPECTATION: expectationAdDidReceiveAd"];

    self.expectationLazyAdDidReceiveAd           = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationLazyAdDidReceiveAd", __PRETTY_FUNCTION__]];
    self.expectationLazyAdDidReceiveAd.inverted  = YES;

    //
    self.multiFormatBanner.enableLazyLoad = YES;
    [self.multiFormatBanner loadAd];

    [self waitForExpectationsWithTimeout:kWaitShort handler:nil];
}

- (void)testLoadWebviewFailsIfLoadAdHasNotBeenCalled
{
    self.expectationAdDidReceiveAd              = [self expectationWithDescription:@"EXPECTATION: expectationAdDidReceiveAd"];
    self.expectationAdDidReceiveAd.inverted     = YES;

    self.expectationLazyAdDidReceiveAd           = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationLazyAdDidReceiveAd", __PRETTY_FUNCTION__]];
    self.expectationLazyAdDidReceiveAd.inverted  = YES;

    //
    BOOL  returnValue  = [self.lazyBanner loadLazyAd];
    XCTAssertFalse(returnValue);

    [self waitForExpectationsWithTimeout:kWaitShort handler:nil];
}

- (void)testLoadAdAgainAfterSuccessfulLoadLazyAd
{
    [TestGlobal stubRequestWithResponse:@"LazyWebview_Basic"];

    self.expectationLazyAdDidReceiveAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationLazyAdDidReceiveAd", __PRETTY_FUNCTION__]];
    self.expectationLazyAdDidReceiveAd.expectedFulfillmentCount = 2;

    self.expectationAdDidReceiveAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationAdDidReceiveAd", __PRETTY_FUNCTION__]];

    self.expectationAdResponseInfoIsDefinedAndDifferent = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationAdResponseInfoIsDefinedAndDifferent", __PRETTY_FUNCTION__]];
    self.expectationAdResponseInfoIsDefinedAndDifferent.expectedFulfillmentCount = 2;

    //
    self.lazyBanner.autoRefreshInterval = 108;
    [self.lazyBanner loadAd];

    [self waitForExpectationsWithTimeout:kWaitVeryLong handler:nil];
}

- (void)testLoadAdTwiceInARow
{
    [TestGlobal stubRequestWithResponse:@"LazyWebview_Basic"];

    self.expectationLazyAdDidReceiveAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationLazyAdDidReceiveAd", __PRETTY_FUNCTION__]];
    self.expectationLazyAdDidReceiveAd.expectedFulfillmentCount = 2;

    self.expectationAdResponseInfoIsDefinedAndDifferent = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationAdResponseInfoIsDefinedAndDifferent", __PRETTY_FUNCTION__]];
    self.expectationAdResponseInfoIsDefinedAndDifferent.expectedFulfillmentCount = 2;

    self.expectationRunLoadAdASecondTimeWithoutCallingLoadLazyAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationRunLoadAdASecondTimeWithoutCallingLoadLazyAd", __PRETTY_FUNCTION__]];
    self.expectationRunLoadAdASecondTimeWithoutCallingLoadLazyAd.expectedFulfillmentCount = 1;


    //
    self.lazyBanner.autoRefreshInterval = 108;
    [self.lazyBanner loadAd];

    [self waitForExpectationsWithTimeout:kWaitShort handler:nil];
}




#pragma mark - ANAdProtocol.

- (void)adDidReceiveAd:(id)ad
{
    TINFO(@"Ad did receive ad -- %@", (self.mar) ? [MARHelper adunitDescription:ad] : @"");

    if (self.expectationTryToLoadWebviewSecondTimeForLazyAdUnit)
    {
        BOOL  returnValue  = [self.lazyBanner loadLazyAd];
        XCTAssertFalse(returnValue);

        [self.expectationTryToLoadWebviewSecondTimeForLazyAdUnit fulfill];
    }

    if (self.expectationAutoRefreshTimerIsSetProperly) {
        XCTAssertNotNil(self.lazyBanner.adFetcher.autoRefreshTimer);
        [self.expectationAutoRefreshTimerIsSetProperly fulfill];
    }

    if (self.expectationAdResponseInfoIsDefinedAndDifferent)
    {
        [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
        [TestGlobal stubRequestWithResponse:@"LazyWebview_MRAID"];

        //
        ANBannerAdView  *banner  = (ANBannerAdView *)ad;

        XCTAssertNotNil(banner.adFetcher.autoRefreshTimer);

        [banner loadAd];  // Run a second lazy load, after the first successful lazy load + webview load.
    }

    if (self.expectationAdDidReceiveAd) {
        [self.expectationAdDidReceiveAd fulfill];
    }
    
    if(self.expectationAdDidReceiveAdBannerNativeRenderer){

        //The returned AdView should be of type ANBAnnerAdview so no need to check type confermance before type casting.
        ANBannerAdView  *banner  = (ANBannerAdView *)ad;
        XCTAssertTrue([banner.contentView isKindOfClass:[ANNativeRenderingViewController class]]);
        
        [self.expectationAdDidReceiveAdBannerNativeRenderer fulfill];
    }
}

- (void)lazyAdDidReceiveAd:(id)ad
{
    TINFO(@"Lazy ad did receive ad -- %@", (self.mar) ? [MARHelper adunitDescription:ad] : @"");


    //
    if (self.expectationLazyAdDidReceiveAd) {
        [self.expectationLazyAdDidReceiveAd fulfill];
    }


    //
    if ([ad isKindOfClass:[ANBannerAdView class]])
    {
        ANBannerAdView  *banner  = (ANBannerAdView *)ad;

        if (self.expectationAdResponseInfoIsDefined)
        {
            XCTAssertNotNil(banner.adResponseInfo);
            XCTAssertNotNil(banner.adResponseInfo.creativeId);
            XCTAssertNotNil(banner.adResponseInfo.contentSource);

            [self.expectationAdResponseInfoIsDefined fulfill];
        }

        if (self.loadWebviewWhenLazyLoadCompletes && banner.enableLazyLoad)
        {
            TINFO(@"%s -- LOADING lazy webview...", __PRETTY_FUNCTION__);

            if (self.expectationAutoRefreshTimerIsSetProperly) {
                XCTAssertNil(self.lazyBanner.adFetcher.autoRefreshTimer);
            }

            [banner loadLazyAd];
        }

        if (self.loadWebviewForAdUnitThatIsNotLazy)
        {
            BOOL  returnValue  = [banner loadLazyAd];
            XCTAssertFalse(returnValue);
        }

        if (self.expectationAdResponseInfoIsDefinedAndDifferent)
        {
            if (!self.responseInfoFirstTime)
            {
                self.responseInfoFirstTime = banner.adResponseInfo;

                XCTAssertNotNil(self.responseInfoFirstTime);
                XCTAssertNotNil(self.responseInfoFirstTime.creativeId);
                XCTAssertNotNil(self.responseInfoFirstTime.contentSource);

            } else {
                self.responseInfoSecondTime = banner.adResponseInfo;

                XCTAssertNil(banner.contentView);

                XCTAssertNotNil(self.responseInfoSecondTime);
                XCTAssertNotNil(self.responseInfoSecondTime.creativeId);
                XCTAssertNotNil(self.responseInfoSecondTime.contentSource);

                XCTAssertFalse([self.responseInfoFirstTime.creativeId isEqualToString:self.responseInfoSecondTime.creativeId]);
                XCTAssertFalse([self.responseInfoFirstTime.placementId isEqualToString:self.responseInfoSecondTime.placementId]);

//                XCTAssertNil(banner.universalAdFetcher.autoRefreshTimer);   //FIX -- should it run or not?
            }

            [self.expectationAdResponseInfoIsDefinedAndDifferent fulfill];

            if (self.expectationRunLoadAdASecondTimeWithoutCallingLoadLazyAd && !self.responseInfoSecondTime)
            {
                [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
                [TestGlobal stubRequestWithResponse:@"LazyWebview_MRAID"];

                //
                ANBannerAdView  *banner  = (ANBannerAdView *)ad;

//                XCTAssertNil(banner.universalAdFetcher.autoRefreshTimer);  //FIX -- should it run or not?

                [banner loadAd];  // Run lazy load again, without loading the webview of the existing lazy load.

                [self.expectationRunLoadAdASecondTimeWithoutCallingLoadLazyAd fulfill];
            }

        } //ENDIF -- expectationAdResponseInfoIsDefinedAndDifferent
    } //ENDIF -- ad is ANBannerAdView
}

- (void)ad:(nonnull id)loadInstance didReceiveNativeAd:(nonnull id)responseInstance
{
    TINFO(@"Ad did receive Multi-format NATIVE ad -- %@", (self.mar) ? [MARHelper adunitDescription:loadInstance] : @"");

    if (self.expectationAdDidReceiveNativeAd) {
        [self.expectationAdDidReceiveNativeAd fulfill];
    }
}


- (void)ad:(id)ad requestFailedWithError:(NSError *)error
{
    TINFO(@"Ad failed to load: %@ -- %@", error, (self.mar) ? [MARHelper adunitDescription:ad] : @"");

    if ([ad isKindOfClass:[ANBannerAdView class]])
    {
        ANBannerAdView  *banner  = (ANBannerAdView *)ad;

        if (banner.enableLazyLoad && (banner.adResponseInfo.adType == ANAdTypeBanner))
        {
            TERROR(@"%s -- Lazy webview load FAILED.", __PRETTY_FUNCTION__);
        }

        if (self.expectationTryToLoadWebviewSecondTimeForLazyAdUnit) {
            BOOL  returnValue  = [banner loadLazyAd];
            XCTAssertFalse(returnValue);

            [self.expectationTryToLoadWebviewSecondTimeForLazyAdUnit fulfill];
        }

        if (self.expectationFindANAdResponseInfoOnLazyFailure)
        {
            XCTAssertNotNil(banner.adResponseInfo);
            XCTAssertNotNil(banner.adResponseInfo.placementId);

            [self.expectationFindANAdResponseInfoOnLazyFailure fulfill];
        }
    }

    if (self.swizzleToPreventWebviewLoad) {
        [ANMRAIDContainerView swizzleMRAIDContainerView:NO];
    }

    if (self.expectationRequestFailedWithError) {
        [self.expectationRequestFailedWithError fulfill];
    }
}


- (void)adDidClose:(id)ad
{
    TINFO(@"Ad did close");
}

- (void)adWasClicked:(id)ad
{
    TINFO(@"Ad was clicked");
}

- (void)adWasClicked:(id)ad withURLString:(NSString *)urlString
{
    TINFO(@"ClickThroughURL=%@", urlString);
}




#pragma mark - ANMultiAdRequestDelegate.

- (void)multiAdRequestDidComplete:(ANMultiAdRequest *)mar
{
    TINFO(@"%s", __PRETTY_FUNCTION__);

    if (self.expectationMultiAdRequestSuccess) {
        [self.expectationMultiAdRequestSuccess fulfill];
    }
}

- (void)multiAdRequest:(ANMultiAdRequest *)mar didFailWithError:(NSError *)error
{
    TINFO(@"%s", __PRETTY_FUNCTION__);
}




#pragma mark - ANNativeRequestDelegate.

- (void)adRequest:(nonnull ANNativeAdRequest *)request didReceiveResponse:(nonnull ANNativeAdResponse *)response
{
    TINFO(@"Ad did receive NATIVE ad -- %@", (self.mar) ? [MARHelper adunitDescription:request] : @"");

    if (self.expectationAdDidReceiveAd) {
        [self.expectationAdDidReceiveAd fulfill];
    }
}

- (void)adRequest:(nonnull ANNativeAdRequest *)request didFailToLoadWithError:(nonnull NSError *)error withAdResponseInfo:(nullable ANAdResponseInfo *)adResponseInfo
{
    TINFO(@"Ad did receive NATIVE ad -- %@", (self.mar) ? [MARHelper adunitDescription:request] : @"");
}


@end
