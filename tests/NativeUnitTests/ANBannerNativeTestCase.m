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
#import "ANUniversalAdFetcher+ANTest.h"
#import "ANBannerAdView+ANTest.h"

#import "ANTestGlobal.h"
#import "ANNativeStandardAdResponse.h"
#import "ANNativeMediatedAdResponse.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANAdAdapterNativeAdMob.h"




@interface ANBannerNativeTestCase : XCTestCase <ANBannerAdViewDelegate>

@property (nonatomic, readwrite, strong)  ANBannerAdView        *multiFormatAd;
@property (nonatomic, readwrite, strong)  ANNativeAdResponse    *nativeAd;
@property (nonatomic, readwrite, strong)  ANMRAIDContainerView  *standardAd;
@property (nonatomic, readwrite, strong)  ANUniversalAdFetcher  *adFetcher;

@property (nonatomic, readwrite, weak)  XCTestExpectation  *expectationRequest;
@property (nonatomic, readwrite, weak)  XCTestExpectation  *expectationResponse;

@property (nonatomic, readwrite)          NSTimeInterval  timeoutForImpbusRequest;

@property (nonatomic, readwrite)  BOOL  foundNativeStandardAdResponseObject;
@property (nonatomic, readwrite)  BOOL  foundNativeMediatedAdResponseObject;
@property (nonatomic, readwrite)  BOOL  foundStandardAdResponseObject;

@end




@implementation ANBannerNativeTestCase

#pragma mark - Test lifecycle.

+ (void)load {
    TESTTRACE();

    [ANGlobal getUserAgent];
    [ANLogManager setANLogLevel:ANLogLevelAll];
}

- (void)setUp {
    TESTTRACE();
    [super setUp];

    self.multiFormatAd = nil;
    self.nativeAd = nil;
    self.standardAd = nil;
    self.adFetcher = nil;

    self.expectationRequest = nil;
    self.expectationResponse = nil;

    self.timeoutForImpbusRequest = 10.0;

    self.foundNativeStandardAdResponseObject = NO;
    self.foundNativeMediatedAdResponseObject = NO;
    self.foundStandardAdResponseObject = NO;


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

    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
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
    XCTAssertTrue([self.multiFormatAd.adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeNative)]);
}

- (void) checkTypeURLsAndRefreshTimer
{
    XCTAssertTrue(ANAdTypeNative == self.multiFormatAd.adType);

    XCTAssertNotNil(self.nativeAd.mainImageURL);
    XCTAssertNotNil(self.nativeAd.iconImageURL);

    XCTAssertNil(self.nativeAd.mainImage);
    XCTAssertNil(self.nativeAd.iconImage);

    XCTAssertNotNil(self.multiFormatAd.universalAdFetcher.autoRefreshTimer);
}

- (void)testReceiveNativeStandardReponseObject
{
    TESTTRACE();

    [self stubRequestWithResponse:@"bannerNative_basic_native"];

    self.multiFormatAd  = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    self.multiFormatAd.delegate = self;
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
//    [ANAdAdapterNativeAdMob enableNativeAppInstallAds];
    [ANAdAdapterNativeAdMob enableNativeContentAds];


    self.multiFormatAd  = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"2"];
    self.multiFormatAd.delegate = self;
    [self.multiFormatAd setAdSize:CGSizeMake(300, 250)];

    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest handler:nil];

    XCTAssertTrue(self.foundNativeMediatedAdResponseObject);
    [self checkTypeURLsAndRefreshTimer];
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


    XCTAssertTrue(ANAdTypeBanner == self.multiFormatAd.adType);
    XCTAssertNotNil(self.multiFormatAd.universalAdFetcher.autoRefreshTimer);


    // Load Native ad.
    //
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [self stubRequestWithResponse:@"bannerNative_basic_native"];

    self.multiFormatAd  = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"1"];
    self.multiFormatAd.delegate = self;
    [self.multiFormatAd setAdSize:CGSizeMake(300, 250)];

    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest handler:nil];

    XCTAssertTrue(ANAdTypeNative == self.multiFormatAd.adType);
}


- (void)testCreativeIdIsStoredInBannerAdViewObject
{
    TESTTRACE();

    self.multiFormatAd  = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"4019246"];
    self.multiFormatAd.delegate = self;
    [self.multiFormatAd setAdSize:CGSizeMake(300, 250)];

    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest handler:nil];

    XCTAssertNotNil(self.multiFormatAd.creativeId);
    XCTAssertEqual(self.multiFormatAd.creativeId, self.nativeAd.creativeId);
}

- (void)testBrowserSettingsArePassedToNativeAdObject
{
    TESTTRACE();

    self.multiFormatAd  = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"4019246"];
    self.multiFormatAd.delegate = self;
    [self.multiFormatAd setAdSize:CGSizeMake(300, 250)];

    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest handler:nil];

    XCTAssertEqual(self.multiFormatAd.opensInNativeBrowser, self.nativeAd.opensInNativeBrowser);
    XCTAssertEqual(self.multiFormatAd.landingPageLoadsInBackground, self.nativeAd.landingPageLoadsInBackground);
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

    if ([ad isKindOfClass:[ANNativeStandardAdResponse class]]) {
        self.nativeAd = (ANNativeAdResponse *)ad;
        self.foundNativeStandardAdResponseObject = YES;
        [self.expectationResponse fulfill];
    }

    if ([ad isKindOfClass:[ANNativeMediatedAdResponse class]]) {
        self.nativeAd = (ANNativeAdResponse *)ad;
        self.foundNativeMediatedAdResponseObject = YES;
        [self.expectationResponse fulfill];
    }
}

- (void)                 ad: (id)ad
     requestFailedWithError: (NSError *)error
{
    TESTTRACE();

    XCTAssertTrue(NO);
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
