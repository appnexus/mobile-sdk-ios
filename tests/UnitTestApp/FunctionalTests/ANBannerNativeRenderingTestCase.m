/*   Copyright 2019 APPNEXUS INC
 
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
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "XCTestCase+ANBannerAdView.h"
#import "XCTestCase+ANAdResponse.h"
#import "ANUniversalAdFetcher+ANTest.h"
#import "ANBannerAdView+ANTest.h"
#import "ANOMIDImplementation.h"

#import "ANTestGlobal.h"
#import "ANNativeStandardAdResponse.h"
#import "ANNativeMediatedAdResponse.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANAdAdapterNativeAdMob.h"
#import "TestANUniversalFetcher.h"
#import "ANUniversalTagRequestBuilder.h"
#import "ANNativeRenderingViewController.h"
#import "SDKValidationURLProtocol.h"
#import "NSURLRequest+HTTPBodyTesting.h"

@interface ANBannerNativeRenderingTestCase : XCTestCase <ANBannerAdViewDelegate , SDKValidationURLProtocolDelegate >

@property (nonatomic, readwrite, strong)  ANBannerAdView        *multiFormatAd;
@property (nonatomic, readwrite, strong)  ANNativeAdResponse    *nativeAd;
@property (nonatomic, readwrite, strong)  ANNativeRenderingViewController  *standardAd;
@property (nonatomic, readwrite, strong)  ANUniversalAdFetcher  *adFetcher;

@property (nonatomic, readwrite, weak)  XCTestExpectation  *expectationRequest;
@property (nonatomic, readwrite, weak)  XCTestExpectation  *expectationResponse;
@property (nonatomic, readwrite, weak)  XCTestExpectation *expectationForOmidSessionFinish;

@property (nonatomic, readwrite)          NSTimeInterval  timeoutForImpbusRequest;

@property (nonatomic, readwrite)  BOOL  foundBannerNativeRenderingAdResponseObject;
@property (nonatomic, readwrite)  BOOL  foundStandardNativeAdResponseObject;

@property (nonatomic, readwrite, strong)  UIView        *bannerSuperView;
@property (nonatomic, readwrite) CGAffineTransform transformValue;
@property (nonatomic, strong) XCTestExpectation *loadAdShouldResizeAdToFitContainerExpectation;
@property (nonatomic, readwrite)  BOOL  shouldResizeAdToFitContainer;
@property (nonatomic, readwrite, strong)  NSMutableString     *requestData;

@end



@implementation ANBannerNativeRenderingTestCase

#pragma mark - Test lifecycle.

+ (void)load {
    TESTTRACE();
    
    [ANGlobal getUserAgent];
    [ANLogManager setANLogLevel:ANLogLevelAll];
}

- (void)setUp {
    TESTTRACE();
    [super setUp];
    
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = YES;
    self.requestData = [[NSMutableString alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestCompleted:)
                                                 name:kANHTTPStubURLProtocolRequestDidLoadNotification
                                               object:nil];
    
    
    self.timeoutForImpbusRequest = 10.0;
    
}

- (void) requestCompleted:(NSNotification *)notification
{
    if (self.expectationRequest) {
        [self.expectationRequest fulfill];
        self.expectationRequest = nil;
    }
}

-(void)setNilProperty {
    
    [self.multiFormatAd removeFromSuperview];
    self.multiFormatAd = nil;
    [self.bannerSuperView removeFromSuperview];
    
    self.standardAd = nil;
    self.adFetcher = nil;
    self.expectationRequest = nil;
    self.expectationResponse = nil;
    self.loadAdShouldResizeAdToFitContainerExpectation = nil;
    self.foundBannerNativeRenderingAdResponseObject  = NO;
    self.foundStandardNativeAdResponseObject  = NO;
    self.shouldResizeAdToFitContainer = NO;
    
    self.nativeAd = nil;
    self.requestData = nil;
    
    
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    


}

- (void)tearDown {
    TESTTRACE();
    [super tearDown];
    [self setNilProperty];
    
}



-(void)initBannerNativeRenderingAd:(BOOL)nativeDemand
           NativeRendering: (BOOL)enableNativeRendering{
    
    self.multiFormatAd  = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250) placementId:@"2"];
    self.multiFormatAd.delegate = self;
    self.multiFormatAd.shouldAllowNativeDemand = nativeDemand;
    self.multiFormatAd.enableNativeRendering = enableNativeRendering;
    [self.multiFormatAd setAdSize:CGSizeMake(300, 250)];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.multiFormatAd];
    
    
}
- (void)testEnableNativeRendererWithRendererId {
    
    TESTTRACE();
    
    [self stubRequestWithResponse:@"appnexus_bannerNative_rendering"];
    [self initBannerNativeRenderingAd:YES NativeRendering:YES];
    
    
    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest*2 handler:nil];
    XCTAssertEqual(self.multiFormatAd.enableNativeRendering, YES);
    XCTAssertEqual(self.foundBannerNativeRenderingAdResponseObject, YES);
    XCTAssertEqual(self.foundStandardNativeAdResponseObject, NO);
}


- (void)testSetRendererIdWithoutEnablingNativeRendering {
    
    TESTTRACE();
    
    
    [self initBannerNativeRenderingAd:YES NativeRendering:NO];
    [self stubRequestWithResponse:@"appnexus_bannerNative_rendering"];
    
    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest*2 handler:nil];
    XCTAssertEqual(self.multiFormatAd.enableNativeRendering, NO);
    XCTAssertEqual(self.foundBannerNativeRenderingAdResponseObject, NO);
    XCTAssertEqual(self.foundStandardNativeAdResponseObject, YES);
    
    
}

- (void)testEnableNativeRenderingWithoutRendererId {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    TESTTRACE();
    
    [self stubRequestWithResponse:@"appnexus_bannerNative_rendering"];
    
    [self initBannerNativeRenderingAd:YES NativeRendering:YES];
    
    
    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest*2 handler:nil];
    XCTAssertEqual(self.multiFormatAd.enableNativeRendering, YES);
    XCTAssertEqual(self.foundBannerNativeRenderingAdResponseObject, YES);
    XCTAssertEqual(self.foundStandardNativeAdResponseObject, NO);
    
}


// Checks to see if AutoRefresh off and if the /ut response is a BannerNativeRendering then AutoRefresh timer is turned on

- (void) testBannerNativeRenderingAutoRefreshSet
{
    [self stubRequestWithResponse:@"appnexus_bannerNative_rendering"];
    
    [self initBannerNativeRenderingAd:YES NativeRendering:YES];
    self.multiFormatAd.autoRefreshInterval = 10.0;
    
    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [self.multiFormatAd loadAd];
    
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest*2 handler:nil];
    XCTAssertNotNil(self.multiFormatAd.universalAdFetcher.autoRefreshTimer);
    
}




- (void)testSetNoRendererIdWithoutEnablingNativeRendering {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    TESTTRACE();
    
    [self stubRequestWithResponse:@"appnexus_bannerNative_rendering"];
    
    [self initBannerNativeRenderingAd:YES NativeRendering:NO];
    
    
    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest*2 handler:nil];
    XCTAssertEqual(self.multiFormatAd.enableNativeRendering, NO);
    XCTAssertEqual(self.foundBannerNativeRenderingAdResponseObject, NO);
    XCTAssertEqual(self.foundStandardNativeAdResponseObject, YES);
}

- (void)testEnableNativeRenderingWithRendererIdAndRefreshTimer
{
    TESTTRACE();
    
    [self stubRequestWithResponse:@"appnexus_bannerNative_rendering"];
    
    [self initBannerNativeRenderingAd:YES NativeRendering:YES];
    
    
    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest handler:nil];
    
    XCTAssertTrue(self.foundBannerNativeRenderingAdResponseObject);
    XCTAssertNil(self.nativeAd);
    XCTAssertNotNil(self.multiFormatAd.universalAdFetcher.autoRefreshTimer);
}


- (void)testNativeRenderingUsesNativeWebViewController
{
    TESTTRACE();
    
    [self stubRequestWithResponse:@"appnexus_bannerNative_rendering"];
    [self initBannerNativeRenderingAd:YES NativeRendering:YES];
    
    
    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest handler:nil];
    
    XCTAssertTrue(self.foundBannerNativeRenderingAdResponseObject);
    XCTAssertTrue([self.multiFormatAd.contentView isKindOfClass:[ANNativeRenderingViewController class]]);
}



- (void)testNativeRenderingShouldResizeAdToFitContainerTrue {
    
    self.shouldResizeAdToFitContainer = YES;
    self.bannerSuperView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , 320, 400)];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.bannerSuperView];
    
    CGRect rect = CGRectMake(0, 0, self.bannerSuperView.frame.size.width, self.bannerSuperView.frame.size.height);
    int adWidth  = 300;
    int adHeight = 250;
    CGSize size = CGSizeMake(adWidth, adHeight);
    
    
    CGFloat  horizontalScaleFactor   = self.bannerSuperView.frame.size.width / adWidth;
    CGFloat  verticalScaleFactor     = self.bannerSuperView.frame.size.height / adHeight;
    CGFloat  scaleFactor             = horizontalScaleFactor < verticalScaleFactor ? horizontalScaleFactor : verticalScaleFactor;
    self.transformValue = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    
    
    
    self.multiFormatAd = [[ANBannerAdView alloc] initWithFrame:rect
                                                   placementId:@"1"
                                                        adSize:size];
    self.multiFormatAd.accessibilityLabel = @"AdView";
    self.multiFormatAd.autoRefreshInterval = 0;
    self.multiFormatAd.delegate = self;
    self.multiFormatAd.shouldAllowNativeDemand = YES;
    self.multiFormatAd.enableNativeRendering = YES;

    [self stubRequestWithResponse:@"appnexus_bannerNative_rendering"];
    self.multiFormatAd.shouldResizeAdToFitContainer = YES;
    
    [self.multiFormatAd loadAd];
    [self.bannerSuperView addSubview:self.multiFormatAd];
    
    self.loadAdShouldResizeAdToFitContainerExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    
    XCTAssertEqual(self.foundStandardNativeAdResponseObject, NO);
    
}




- (void)testNativeRenderingShouldResizeAdToFitContainerFalse {
    
    self.shouldResizeAdToFitContainer = NO;
    self.bannerSuperView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , 320, 400)];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.bannerSuperView];
    
    CGRect rect = CGRectMake(0, 0, self.bannerSuperView.frame.size.width, self.bannerSuperView.frame.size.height);
    int adWidth  = 300;
    int adHeight = 250;
    CGSize size = CGSizeMake(adWidth, adHeight);
    
    
    CGFloat  horizontalScaleFactor   = self.bannerSuperView.frame.size.width / adWidth;
    CGFloat  verticalScaleFactor     = self.bannerSuperView.frame.size.height / adHeight;
    CGFloat  scaleFactor             = horizontalScaleFactor < verticalScaleFactor ? horizontalScaleFactor : verticalScaleFactor;
    self.transformValue = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    
    
    
    self.multiFormatAd = [[ANBannerAdView alloc] initWithFrame:rect
                                                   placementId:@"1"
                                                        adSize:size];
    self.multiFormatAd.accessibilityLabel = @"AdView";
    self.multiFormatAd.autoRefreshInterval = 0;
    self.multiFormatAd.delegate = self;
    self.multiFormatAd.shouldAllowNativeDemand = YES;
    self.multiFormatAd.enableNativeRendering = YES;

    [self stubRequestWithResponse:@"appnexus_bannerNative_rendering"];
    self.multiFormatAd.shouldResizeAdToFitContainer = NO;
    
    [self.multiFormatAd loadAd];
    [self.bannerSuperView addSubview:self.multiFormatAd];
    
    self.loadAdShouldResizeAdToFitContainerExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    
    XCTAssertEqual(self.foundStandardNativeAdResponseObject, NO);
    
}


- (void)testNativeRenderingInvalidURL {
    
    TESTTRACE();
    
    
    [self stubRequestWithResponse:@"appnexus_bannerNative_renderingInvalidURL"];
    [self initBannerNativeRenderingAd:YES NativeRendering:YES];
    
    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [self.multiFormatAd loadAd];
    
    [self waitForExpectationsWithTimeout:self.timeoutForImpbusRequest*2 handler:nil];
    XCTAssertEqual(self.multiFormatAd.enableNativeRendering, YES);
    XCTAssertEqual(self.foundBannerNativeRenderingAdResponseObject, NO);
    XCTAssertEqual(self.foundStandardNativeAdResponseObject, YES);
    
}

- (void)testOMIDTrackingNativeRendering{

    [SDKValidationURLProtocol setDelegate:self];
    [NSURLProtocol registerClass:[SDKValidationURLProtocol class]];
    [self stubRequestWithResponse:@"NativeAsssemblyRendererOMID_Native_RTBResponse"];
    [self initBannerNativeRenderingAd:YES NativeRendering:YES];

    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    [self.multiFormatAd loadAd];
    [self waitForExpectations:@[self.expectationRequest, self.expectationResponse] timeout:10];

    // Delay added to allow OMID Event to fire
    [XCTestCase delayForTimeInterval:10];
    XCTAssertTrue([self.requestData containsString:@"OmidSupported"]);
    XCTAssertTrue([self.requestData containsString:@"true"]);
    XCTAssertTrue([self.requestData containsString:@"sessionStart"]);
    XCTAssertTrue([self.requestData containsString:@"partnerName"]);
    XCTAssertTrue([self.requestData containsString:AN_OMIDSDK_PARTNER_NAME]);
    XCTAssertTrue([self.requestData containsString:@"partnerVersion"]);
    XCTAssertTrue([self.requestData containsString:AN_SDK_VERSION]);
    XCTAssertTrue([self.requestData containsString:@"impression"]);
    self.expectationForOmidSessionFinish = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    [self.multiFormatAd removeFromSuperview];
    self.multiFormatAd = nil;
    [self waitForExpectations:@[self.expectationForOmidSessionFinish] timeout:30];
}


#pragma mark - ANBannerAdViewDelegate

- (void)adDidReceiveAd:(id)ad
{
    TESTTRACE();
    
    XCTAssertNotNil(ad);
    self.foundStandardNativeAdResponseObject = NO;
    
    
    if ([ad isKindOfClass:[ANBannerAdView class]]) {
        self.standardAd = (ANNativeRenderingViewController *)ad;
        self.foundBannerNativeRenderingAdResponseObject = YES;
        [self.expectationResponse fulfill];
    }
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        ANBannerAdView *bannerAdObject = (ANBannerAdView *)ad;
        if(self.shouldResizeAdToFitContainer){
            
            XCTAssertEqual(self.transformValue.a, bannerAdObject.contentView.transform.a);
            XCTAssertEqual(self.transformValue.d, bannerAdObject.contentView.transform.d);
            
        }else{
            XCTAssertNotEqual(self.transformValue.a, bannerAdObject.contentView.transform.a);
            XCTAssertNotEqual(self.transformValue.d, bannerAdObject.contentView.transform.d);
            
        }
        [self.loadAdShouldResizeAdToFitContainerExpectation fulfill];
        
    });
    
}

- (void)ad:(id)loadInstance didReceiveNativeAd:(id)responseInstance
{
    TESTTRACE();
    
    XCTAssertNotNil(loadInstance);
    XCTAssertNotNil(responseInstance);
    self.foundBannerNativeRenderingAdResponseObject = NO;
    
    if ([responseInstance isKindOfClass:[ANNativeStandardAdResponse class]] || [responseInstance isKindOfClass:[ANNativeMediatedAdResponse class]]) {
        self.nativeAd = (ANNativeAdResponse *)responseInstance;
        self.foundStandardNativeAdResponseObject = YES;
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


# pragma mark - Intercept HTTP Request Callback

- (void)didReceiveIABResponse:(NSString *)response {
    if ([response containsString:@"sessionFinish"] && self.expectationForOmidSessionFinish) {
        [self.expectationForOmidSessionFinish fulfill];
    }
    [self.requestData appendString:response];
}


@end
