/*   Copyright 2014 APPNEXUS INC
 
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "XCTestCase+ANBannerAdView.h"
#import "XCTestCase+ANAdResponse.h"
#import "ANAdView+PrivateMethods.h"
#import "ANAdFetcher+ANTest.h"
#import "ANBannerAdView+ANTest.h"

#import "ANTestGlobal.h"
#import "ANNativeStandardAdResponse.h"
#import "ANNativeMediatedAdResponse.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANAdAdapterNativeAdMob.h"




@interface ANBannerNativeTestCase : XCTestCase <ANBannerAdViewDelegate , ANNativeAdDelegate , ANNativeAdRequestDelegate >

@property (nonatomic, readwrite, strong)  ANBannerAdView        *multiFormatAd;
@property (nonatomic, readwrite, strong)  ANNativeAdResponse    *nativeAd;
@property (nonatomic, readwrite, strong)  ANMRAIDContainerView  *standardAd;

@property (nonatomic, readwrite, weak)  XCTestExpectation  *expectationRequest;
@property (nonatomic, readwrite, weak)  XCTestExpectation  *expectationResponse;

@property (nonatomic, readwrite)          NSTimeInterval  timeoutForImpbusRequest;

@property (nonatomic, readwrite)  BOOL  foundNativeStandardAdResponseObject;
@property (nonatomic, readwrite)  BOOL  foundNativeMediatedAdResponseObject;
@property (nonatomic, readwrite)  BOOL  foundStandardAdResponseObject;

@end




@implementation ANBannerNativeTestCase

#pragma mark - Test lifecycle.


- (void)setUp {
    TESTTRACE();
    [super setUp];
    
    self.timeoutForImpbusRequest = 20.0;

    self.foundNativeStandardAdResponseObject = NO;
    self.foundNativeMediatedAdResponseObject = NO;
    self.foundStandardAdResponseObject = NO;
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];


    //
    [[ANHTTPStubbingManager sharedStubbingManager] enable];

    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestCompleted:)
                                                 name:kANHTTPStubURLProtocolRequestDidLoadNotification
                                               object:nil];
}

- (void)tearDown {
    TESTTRACE();
    [super tearDown];
    
    self.multiFormatAd = nil;
    self.nativeAd = nil;
    self.standardAd = nil;
    
    self.expectationRequest = nil;
    self.expectationResponse = nil;
    
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
        [additionalView removeFromSuperview];
    }
}


- (void) requestCompleted:(NSNotification *)notification
{
    if (self.expectationRequest) {
        [self.expectationRequest fulfill];
        self.expectationRequest = nil;
    }
}




#pragma mark - Test methods.

- (void)testDefinesAllowedMediaTypeNative
{
    TESTTRACE();

    self.multiFormatAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    XCTAssertFalse([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeNative)]);
}


- (void)testIsBannerNativeVideoDefault
{
    TESTTRACE();
    
    self.multiFormatAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    XCTAssertEqual(self.multiFormatAd.adAllowedMediaTypes.count , 1);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeBanner)]);
  }

- (void)testIsBannerVideoEnabled
{
    TESTTRACE();

    self.multiFormatAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    self.multiFormatAd.shouldAllowVideoDemand = YES;
    XCTAssertEqual(self.multiFormatAd.adAllowedMediaTypes.count , 2);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeBanner)]);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeVideo)]);
    XCTAssertFalse([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeNative)]);
}


- (void)testIsBannerDisabled
{
    TESTTRACE();

    self.multiFormatAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    self.multiFormatAd.shouldAllowBannerDemand = NO;
    XCTAssertEqual(self.multiFormatAd.adAllowedMediaTypes.count , 0);
    XCTAssertFalse([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeBanner)]);
    XCTAssertFalse([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeVideo)]);
    XCTAssertFalse([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeNative)]);
}


- (void)testIsBannerDisabledNativeVideoEnabled
{
    TESTTRACE();

    self.multiFormatAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    self.multiFormatAd.shouldAllowBannerDemand = NO;
    self.multiFormatAd.shouldAllowVideoDemand = YES;
    self.multiFormatAd.shouldAllowNativeDemand = YES;
    XCTAssertEqual(self.multiFormatAd.adAllowedMediaTypes.count , 2);
    XCTAssertFalse([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeBanner)]);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeVideo)]);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeNative)]);
}


- (void)testIsBannerNativeDisabledVideoEnabled
{
    TESTTRACE();

    self.multiFormatAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    self.multiFormatAd.shouldAllowBannerDemand = NO;
    self.multiFormatAd.shouldAllowVideoDemand = YES;
    self.multiFormatAd.shouldAllowNativeDemand = NO;
    XCTAssertEqual(self.multiFormatAd.adAllowedMediaTypes.count , 1);
    XCTAssertFalse([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeBanner)]);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeVideo)]);
    XCTAssertFalse([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeNative)]);
}

- (void)testIsBannerVideoDisabledNativeEnabled
{
    TESTTRACE();

    self.multiFormatAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    self.multiFormatAd.shouldAllowBannerDemand = NO;
    self.multiFormatAd.shouldAllowVideoDemand = NO;
    self.multiFormatAd.shouldAllowNativeDemand = YES;
    XCTAssertEqual(self.multiFormatAd.adAllowedMediaTypes.count , 1);
    XCTAssertFalse([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeBanner)]);
    XCTAssertFalse([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeVideo)]);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeNative)]);
}


- (void)testIsBannerNativeEnabled
{
    TESTTRACE();

    self.multiFormatAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    self.multiFormatAd.shouldAllowNativeDemand = YES;
    XCTAssertEqual(self.multiFormatAd.adAllowedMediaTypes.count , 2);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeBanner)]);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeNative)]);
    XCTAssertFalse([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeVideo)]);
}

- (void)testIsBannerNativeVideoEnabled
{
    TESTTRACE();

    self.multiFormatAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    self.multiFormatAd.shouldAllowVideoDemand = YES;
    self.multiFormatAd.shouldAllowNativeDemand = YES;
    XCTAssertEqual(self.multiFormatAd.adAllowedMediaTypes.count , 3);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeBanner)]);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeNative)]);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeVideo)]);
}

- (void)testIsBannerNativeVideoHighImpactEnabled
{
    TESTTRACE();

    self.multiFormatAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    self.multiFormatAd.shouldAllowVideoDemand = YES;
    self.multiFormatAd.shouldAllowNativeDemand = YES;
    self.multiFormatAd.shouldAllowHighImpactDemand = YES;
    XCTAssertEqual(self.multiFormatAd.adAllowedMediaTypes.count , 4);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeBanner)]);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeNative)]);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeVideo)]);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeHighImpact)]);
}

- (void)testIsBannerNativeVideoHighImpactDisabled
{
    TESTTRACE();

    self.multiFormatAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    self.multiFormatAd.shouldAllowVideoDemand = YES;
    self.multiFormatAd.shouldAllowNativeDemand = YES;
    self.multiFormatAd.shouldAllowHighImpactDemand = NO;
    XCTAssertEqual(self.multiFormatAd.adAllowedMediaTypes.count , 3);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeBanner)]);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeNative)]);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeVideo)]);
    XCTAssertFalse([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeHighImpact)]);
}

- (void)testIsBannerNativeEnabledVideoDisabledHighImpactEnabled
{
    TESTTRACE();

    self.multiFormatAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    self.multiFormatAd.shouldAllowVideoDemand = NO;
    self.multiFormatAd.shouldAllowNativeDemand = YES;
    self.multiFormatAd.shouldAllowHighImpactDemand = YES;
    XCTAssertEqual(self.multiFormatAd.adAllowedMediaTypes.count , 3);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeBanner)]);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeNative)]);
    XCTAssertFalse([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeVideo)]);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeHighImpact)]);
}

- (void)testIsBannerNativeDisabledVideoEnabledHighImpactEnabled
{
    TESTTRACE();

    self.multiFormatAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    self.multiFormatAd.shouldAllowVideoDemand = YES;
    self.multiFormatAd.shouldAllowNativeDemand = NO;
    self.multiFormatAd.shouldAllowHighImpactDemand = YES;
    XCTAssertEqual(self.multiFormatAd.adAllowedMediaTypes.count , 3);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeBanner)]);
    XCTAssertFalse([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeNative)]);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeVideo)]);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeHighImpact)]);
}

- (void)testIsBannerNativeVideoHighImpactDefault
{
    TESTTRACE();

    self.multiFormatAd = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    XCTAssertEqual(self.multiFormatAd.adAllowedMediaTypes.count , 1);
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeBanner)]);
    XCTAssertFalse([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeNative)]);
    XCTAssertFalse([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeVideo)]);
    XCTAssertFalse([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeHighImpact)]);
}

- (void) checkTypeURLsAndRefreshTimer
{
   XCTAssertTrue(ANAdTypeNative == self.multiFormatAd.adResponseInfo.adType);

    XCTAssertNotNil(self.nativeAd.mainImageURL);
    XCTAssertNotNil(self.nativeAd.iconImageURL);

    XCTAssertNil(self.nativeAd.mainImage);
    XCTAssertNil(self.nativeAd.iconImage);

    XCTAssertNotNil(self.multiFormatAd.adFetcher.autoRefreshTimer);
}

- (void)testReceiveNativeStandardReponseObject
{
    TESTTRACE();

    [self stubRequestWithResponse:@"appnexus_standard_response"];

    self.multiFormatAd  = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    self.multiFormatAd.delegate = self;
    self.multiFormatAd.shouldAllowNativeDemand = YES;
    [self.multiFormatAd setAdSize:CGSizeMake(300, 250)];

    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest handler:nil];

    XCTAssertTrue(self.foundNativeStandardAdResponseObject);
    [self checkTypeURLsAndRefreshTimer];
}

- (void)testReceiveNativeMediationReponseObject
{
    TESTTRACE();

    [self stubRequestWithResponse:@"bannerNative_native_mediation"];


    self.multiFormatAd  = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"2"];
    self.multiFormatAd.delegate = self;
    self.multiFormatAd.shouldAllowNativeDemand = YES;
    [self.multiFormatAd setAdSize:CGSizeMake(300, 250)];
    [self.multiFormatAd loadAd];

    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest*2 handler:nil];

    XCTAssertTrue(self.foundNativeMediatedAdResponseObject);
    [self checkTypeURLsAndRefreshTimer];
}

- (void)testReceiveBannerNativeVideoUsingRendererIdObject
{
    TESTTRACE();
    
    [self stubRequestWithResponse:@"native_videoResponse"];
    
    self.multiFormatAd  = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"2"];
    self.multiFormatAd.delegate = self;
    [self.multiFormatAd setShouldAllowNativeDemand:YES];
    [self.multiFormatAd setNativeAdRendererId:127];
    [self.multiFormatAd setAdSize:CGSizeMake(300, 250)];
    
    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest*2 handler:nil];
    XCTAssertEqual(self.multiFormatAd.nativeAdRendererId, 127);
  
}

- (void)testAdTypeValueAcrossRefreshToDifferentMediaType
{
    // Load Banner ad.
    //
    [self stubRequestWithResponse:@"bannerNative_basic_banner"];

    self.multiFormatAd  = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"3"];
    self.multiFormatAd.delegate = self;
    [self.multiFormatAd setAdSize:CGSizeMake(300, 250)];

    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest handler:nil];


    XCTAssertTrue(ANAdTypeBanner == self.multiFormatAd.adResponseInfo.adType);
    XCTAssertNotNil(self.multiFormatAd.adFetcher.autoRefreshTimer);


    // Load Native ad.
    //
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [self stubRequestWithResponse:@"appnexus_standard_response"];

    self.multiFormatAd  = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    self.multiFormatAd.delegate = self;
    [self.multiFormatAd setAdSize:CGSizeMake(300, 250)];

    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest handler:nil];

   XCTAssertTrue(ANAdTypeNative == self.multiFormatAd.adResponseInfo.adType);
}


- (void)testCreativeIdIsStoredInBannerAdViewObject
{
    TESTTRACE();
    [self stubRequestWithResponse:@"appnexus_standard_response"];

    self.multiFormatAd  = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"4019246"];
    self.multiFormatAd.delegate = self;
    self.multiFormatAd.shouldAllowNativeDemand = YES;
    [self.multiFormatAd setAdSize:CGSizeMake(300, 250)];

    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest handler:nil];

   XCTAssertNotNil(self.multiFormatAd.adResponseInfo.creativeId);
   XCTAssertEqual(self.multiFormatAd.adResponseInfo.creativeId, self.nativeAd.adResponseInfo.creativeId);
}

- (void)testClickThruSettingsWithOpenSDKBrowser
{
    TESTTRACE();
    [self stubRequestWithResponse:@"appnexus_standard_response"];

    self.multiFormatAd  = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"4019246"];
    self.multiFormatAd.delegate = self;
    self.multiFormatAd.shouldAllowNativeDemand = YES;
    self.multiFormatAd.clickThroughAction = ANClickThroughActionOpenSDKBrowser;
    [self.multiFormatAd setAdSize:CGSizeMake(300, 250)];

    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest handler:nil];

    XCTAssertEqual(self.nativeAd.clickThroughAction, ANClickThroughActionOpenSDKBrowser);
}

- (void)testClickThruSettingsWithOpenDeviceBrowser
{
    TESTTRACE();
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    
    self.multiFormatAd  = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"4019246"];
    self.multiFormatAd.delegate = self;
    self.multiFormatAd.shouldAllowNativeDemand = YES;
    self.multiFormatAd.clickThroughAction = ANClickThroughActionOpenDeviceBrowser;
    [self.multiFormatAd setAdSize:CGSizeMake(300, 250)];
    
    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest handler:nil];
    
    XCTAssertEqual(self.nativeAd.clickThroughAction, ANClickThroughActionOpenDeviceBrowser);
}

- (void)testClickThruSettingsWithReturnURL
{
    TESTTRACE();
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    
    self.multiFormatAd  = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"4019246"];
    self.multiFormatAd.delegate = self;
    self.multiFormatAd.shouldAllowNativeDemand = YES;
    self.multiFormatAd.clickThroughAction = ANClickThroughActionReturnURL;
    [self.multiFormatAd setAdSize:CGSizeMake(300, 250)];
    
    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest handler:nil];
    
    XCTAssertEqual(self.nativeAd.clickThroughAction, ANClickThroughActionReturnURL);
}




#pragma mark - ANBannerAdViewDelegate

- (void)adDidReceiveAd:(id)ad
{
    TESTTRACE();

    XCTAssertNotNil(ad);

    if ([ad isKindOfClass:[ANBannerAdView class]]) {
        self.standardAd = (ANMRAIDContainerView *)ad;
        self.foundStandardAdResponseObject = YES;
        [self.expectationResponse fulfill];
    }
}

- (void)ad:(id)loadInstance didReceiveNativeAd:(id)responseInstance
{
    TESTTRACE();

    XCTAssertNotNil(loadInstance);
    XCTAssertNotNil(responseInstance);

    if ([responseInstance isKindOfClass:[ANNativeStandardAdResponse class]]) {
        self.nativeAd = (ANNativeAdResponse *)responseInstance;
        self.foundNativeStandardAdResponseObject = YES;
        [self.expectationResponse fulfill];
    }

    if ([responseInstance isKindOfClass:[ANNativeMediatedAdResponse class]]) {
        self.nativeAd = (ANNativeAdResponse *)responseInstance;
        self.foundNativeMediatedAdResponseObject = YES;
        [self.expectationResponse fulfill];
    }
}

- (void)                 ad: (id)ad
     requestFailedWithError: (NSError *)error
{
    TESTTRACE();

    [self.expectationResponse fulfill];
}




# pragma mark - Ad Server Response Stubbing

- (void)stubRequestWithResponse:(NSString *)responseName
{
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];

    NSString *baseResponse = [NSString stringWithContentsOfFile: [currentBundle pathForResource:responseName ofType:@"json"]
                                                       encoding: NSUTF8StringEncoding
                                                          error: nil ];

    ANURLConnectionStub *requestStub = [[ANURLConnectionStub alloc] init];


    requestStub.requestURL      = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    requestStub.responseCode    = 200;
    requestStub.responseBody    = baseResponse;

    [[ANHTTPStubbingManager sharedStubbingManager] addStub:requestStub];
}


@end
