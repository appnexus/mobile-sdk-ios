//
//  LazyWebviewFeature.m
//  UnitTests
//
//  Created by David Reeder on 5/29/20.
//  Copyright © 2020 AppNexus. All rights reserved.
//
    //FIX -- copyright.

#import <XCTest/XCTest.h>

#import "ANHTTPStubbingManager.h"
#import "TestGlobal.h"

#import "ANLogManager.h"
#import "ANSDKSettings.h"

#import "ANBannerAdView.h"
#import "ANMultiAdRequest.h"




#pragma mark -

@interface  LazyWebviewFeature  :XCTestCase <ANBannerAdViewDelegate, ANMultiAdRequestDelegate>

@property (nonatomic, readwrite, strong)  ANBannerAdView  *lazyBanner;
@property (nonatomic, readwrite, strong)  ANBannerAdView  *multiFormatBanner;

@property (nonatomic, strong)  XCTestExpectation  *expectationLazyAdDidReceiveAd;
@property (nonatomic, strong)  XCTestExpectation  *expectationAdDidReceiveAd;
@property (nonatomic, strong)  XCTestExpectation  *expectationAdResponseInfoIsDefined;
@property (nonatomic, strong)  XCTestExpectation  *expectationTryToLoadWebviewSecondTimeForLazyAdUnit;

@property (nonatomic)  BOOL  loadWebviewWhenLazyLoadCompletes;

@property (nonatomic, strong)  UIViewController  *rootVC;

@end




#pragma mark -

@implementation  LazyWebviewFeature

#pragma mark Lifecycle.

- (void)setUp
{
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;

    [ANLogManager setANLogLevel:ANLogLevelAll];

    [self createAdUnits];

    self.expectationLazyAdDidReceiveAd          = nil;
    self.expectationAdDidReceiveAd              = nil;
    self.expectationAdResponseInfoIsDefined     = nil;
    self.expectationTryToLoadWebviewSecondTimeForLazyAdUnit     = nil;

    self.loadWebviewWhenLazyLoadCompletes = YES;

    self.rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;

}

- (void)tearDown
{
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
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
//    self.lazyBanner.rootViewController       = self.rootVC;  //FIX -=- need these?
    self.lazyBanner.autoRefreshInterval      = 0;
    self.lazyBanner.shouldAllowVideoDemand   = NO;      // self.banner1 is always Banner-banner.
    self.lazyBanner.shouldAllowNativeDemand  = NO;

    self.lazyBanner.shouldServePublicServiceAnnouncements = NO;

    self.lazyBanner.externalUid              = @"banner-banner";

    self.lazyBanner.enableLazyWebviewLoad    = YES;


    //
    self.multiFormatBanner = [ANBannerAdView adViewWithFrame:rect placementId:@"33334444" adSize:size];

    self.multiFormatBanner.delegate                 = self;
//    self.multiFormatBanner.rootViewController       = self.rootVC;
    self.multiFormatBanner.autoRefreshInterval      = 0;
    self.multiFormatBanner.shouldAllowVideoDemand   = YES;
    self.multiFormatBanner.shouldAllowNativeDemand  = YES;

    self.lazyBanner.shouldServePublicServiceAnnouncements = NO;

    self.multiFormatBanner.externalUid              = @"banner-multiformat";

    self.multiFormatBanner.enableLazyWebviewLoad    = NO;
}




#pragma mark - Tests.

- (void)testBasicOperation
{
    [TestGlobal stubRequestWithResponse:@"LazyWebview_Basic"];

    self.expectationLazyAdDidReceiveAd  = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationLazyAdDidReceiveAd", __PRETTY_FUNCTION__]];
    self.expectationAdDidReceiveAd      = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationAdDidReceiveAd", __PRETTY_FUNCTION__]];

    //
    [self.lazyBanner loadAd];

    [self waitForExpectationsWithTimeout:kWaitShort handler:nil];
}

-(void)testFeatureFlagCanBeSet
{
    XCTAssert(self.multiFormatBanner.enableLazyWebviewLoad == NO);
    self.multiFormatBanner.enableLazyWebviewLoad = YES;
    XCTAssert(self.multiFormatBanner.enableLazyWebviewLoad == YES);
}

- (void)testFeatureFlagCannotBeUnset
{
    XCTAssert(self.multiFormatBanner.enableLazyWebviewLoad == NO);
    self.multiFormatBanner.enableLazyWebviewLoad = YES;
    XCTAssert(self.multiFormatBanner.enableLazyWebviewLoad == YES);
    self.multiFormatBanner.enableLazyWebviewLoad = NO;
    XCTAssert(self.multiFormatBanner.enableLazyWebviewLoad == YES);
}

- (void)testFeatureFlagCannotBeSetDuringLoadAd
{
    XCTAssert(self.multiFormatBanner.enableLazyWebviewLoad == NO);

    //
    [TestGlobal stubRequestWithResponse:@"LazyWebview_Basic"];

    self.expectationAdDidReceiveAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    //
    [self.multiFormatBanner loadAd];

    [TestGlobal waitForSeconds: kWaitQuarterSecond
              thenExecuteBlock: ^{
                                    self.multiFormatBanner.enableLazyWebviewLoad = YES;
                                    XCTAssert(self.multiFormatBanner.enableLazyWebviewLoad == NO);
                                } ];

    [self waitForExpectationsWithTimeout:kWaitShort handler:nil];
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
    [self.multiFormatBanner loadAd];

    [TestGlobal waitForSeconds: kWaitShort
              thenExecuteBlock: ^{
                                    [self.multiFormatBanner loadWebview];
                                } ];

    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];
}

- (void)testLoadWebviewDoesNothingForLazyAdUnitsThatAreAlreadyLoaded
{
    [TestGlobal stubRequestWithResponse:@"LazyWebview_Basic"];

    self.expectationLazyAdDidReceiveAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationLazyAdDidReceiveAd", __PRETTY_FUNCTION__]];

    self.expectationAdDidReceiveAd = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationAdDidReceiveAd", __PRETTY_FUNCTION__]];
    self.expectationAdDidReceiveAd.assertForOverFulfill = YES;

    self.expectationTryToLoadWebviewSecondTimeForLazyAdUnit = [self expectationWithDescription:[NSString stringWithFormat:@"%s -- expectationAdDidReceiveAd", __PRETTY_FUNCTION__]];

    //
    [self.lazyBanner loadAd];

    [self waitForExpectationsWithTimeout:kWaitVeryLong handler:nil];
}




#pragma mark - ANAdProtocol.

- (void)adDidReceiveAd:(id)ad
{
    TINFO(@"Ad did receive ad");

    if (self.expectationTryToLoadWebviewSecondTimeForLazyAdUnit)
    {
        [self.lazyBanner loadWebview];
        [self.expectationTryToLoadWebviewSecondTimeForLazyAdUnit fulfill];
    }

    if (self.expectationAdDidReceiveAd) {
        [self.expectationAdDidReceiveAd fulfill];
    }
}

- (void)lazyAdDidReceiveAd:(id)ad
{
    TINFO(@"Lazy ad did receive ad");

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

        if (self.loadWebviewWhenLazyLoadCompletes && banner.enableLazyWebviewLoad) {
            TINFO(@"%s -- LOADING lazy webview...", __PRETTY_FUNCTION__);
            [banner loadWebview];
        }
    }
}

- (void)ad:(nonnull id)loadInstance didReceiveNativeAd:(nonnull id)responseInstance
{
    TINFO(@"Ad did receive NATIVE ad.");
}


- (void)ad:(id)ad requestFailedWithError:(NSError *)error
{
    TINFO(@"Ad failed to load: %@", error);

    if ([ad isKindOfClass:[ANBannerAdView class]])
    {
        ANBannerAdView  *banner  = (ANBannerAdView *)ad;

        if (banner.enableLazyWebviewLoad && (banner.adResponseInfo.adType == ANAdTypeBanner))
        {
            TERROR(@"%s -- Lazy webview load FAILED.", __PRETTY_FUNCTION__);
        }
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
}

- (void)multiAdRequest:(ANMultiAdRequest *)mar didFailWithError:(NSError *)error
{
    TINFO(@"%s", __PRETTY_FUNCTION__);
}




#pragma mark - ANNativeRequestDelegate.

- (void)adRequest:(nonnull ANNativeAdRequest *)request didReceiveResponse:(nonnull ANNativeAdResponse *)response
{
    TINFO(@"%s", __PRETTY_FUNCTION__);
}

- (void)adRequest:(nonnull ANNativeAdRequest *)request didFailToLoadWithError:(nonnull NSError *)error withAdResponseInfo:(nullable ANAdResponseInfo *)adResponseInfo
{
    TINFO(@"%s", __PRETTY_FUNCTION__);
}


@end
