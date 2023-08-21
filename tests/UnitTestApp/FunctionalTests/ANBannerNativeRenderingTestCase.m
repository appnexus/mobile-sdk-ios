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
#import "ANAdFetcher+ANTest.h"
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

@interface ANBannerNativeRenderingTestCase : XCTestCase <ANBannerAdViewDelegate >

@property (nonatomic, readwrite, strong)  ANBannerAdView        *multiFormatAd;
@property (nonatomic, readwrite, strong)  ANAdFetcher  *adFetcher;

@property (nonatomic, readwrite, weak)  XCTestExpectation  *expectationRequest;
@property (nonatomic, readwrite, weak)  XCTestExpectation  *expectationResponse;



@property (nonatomic, readwrite, strong)  UIView        *bannerSuperView;
@property (nonatomic, readwrite) CGAffineTransform transformValue;
@property (nonatomic, strong) XCTestExpectation *loadAdShouldResizeAdToFitContainerExpectation;
@property (nonatomic, readwrite)  BOOL  shouldResizeAdToFitContainer;

@end



@implementation ANBannerNativeRenderingTestCase

#pragma mark - Test lifecycle.

- (void)setUp {
    TESTTRACE();
    [super setUp];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestCompleted:)
                                                 name:kANHTTPStubURLProtocolRequestDidLoadNotification
                                               object:nil];
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];
    
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
    
    self.adFetcher = nil;
    self.expectationRequest = nil;
    self.expectationResponse = nil;
    self.loadAdShouldResizeAdToFitContainerExpectation = nil;
    self.shouldResizeAdToFitContainer = NO;
    
    
    
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }

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
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.multiFormatAd];
    
    
}

- (void)testEnableNativeRendererWithRendererId {
    
    TESTTRACE();
    
    [self stubRequestWithResponse:@"appnexus_bannerNative_rendering"];
    [self initBannerNativeRenderingAd:YES NativeRendering:YES];
    
    
    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval*2 handler:nil];
    XCTAssertTrue(self.multiFormatAd.enableNativeRendering);
}


- (void)testSetRendererIdWithoutEnablingNativeRendering {
    
    TESTTRACE();
    
    [self initBannerNativeRenderingAd:YES NativeRendering:NO];
    [self stubRequestWithResponse:@"appnexus_bannerNative_rendering"];
    
    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval*2 handler:nil];
    XCTAssertFalse(self.multiFormatAd.enableNativeRendering);
    
}


- (void)testEnableNativeRenderingWithoutRendererId {

    TESTTRACE();

    [self stubRequestWithResponse:@"appnexus_bannerNative_rendering"];

    [self initBannerNativeRenderingAd:YES NativeRendering:YES];


    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval*2 handler:nil];
    XCTAssertTrue(self.multiFormatAd.enableNativeRendering);

}


// AutoRefresh is not enabled for NativeRendering
- (void) testBannerNativeRenderingAutoRefreshSet
{
    [self stubRequestWithResponse:@"appnexus_bannerNative_rendering"];
    
    [self initBannerNativeRenderingAd:YES NativeRendering:YES];
    self.multiFormatAd.autoRefreshInterval = 10.0;
    
    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [self.multiFormatAd loadAd];
    
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval*2 handler:nil];
    XCTAssertNil(self.multiFormatAd.adFetcher.autoRefreshTimer);
    
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
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval*2 handler:nil];
    XCTAssertFalse(self.multiFormatAd.enableNativeRendering);
}

// AutoRefresh is not enabled for NativeRendering
- (void)testEnableNativeRenderingWithRendererIdAndRefreshTimer
{
    TESTTRACE();
    
    [self stubRequestWithResponse:@"appnexus_bannerNative_rendering"];
    
    [self initBannerNativeRenderingAd:YES NativeRendering:YES];
    
    
    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];
    
    XCTAssertNil(self.multiFormatAd.adFetcher.autoRefreshTimer);
}

- (void)testNativeRenderingUsesNativeWebViewController
{
    TESTTRACE();

    [self stubRequestWithResponse:@"appnexus_bannerNative_rendering"];
    [self initBannerNativeRenderingAd:YES NativeRendering:YES];


    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    [self.multiFormatAd loadAd];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];

    XCTAssertTrue([self.multiFormatAd.contentView isKindOfClass:[ANNativeRenderingViewController class]]);
}



- (void)testNativeRenderingShouldResizeAdToFitContainerTrue {

    self.shouldResizeAdToFitContainer = YES;
    self.bannerSuperView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , 320, 400)];
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.bannerSuperView];
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

}



- (void)testNativeRenderingShouldResizeAdToFitContainerFalse {

    self.shouldResizeAdToFitContainer = NO;
    self.bannerSuperView = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , 320, 400)];
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.bannerSuperView];
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

    XCTAssertNotEqual(self.transformValue.a, self.multiFormatAd.contentView.transform.a);
    XCTAssertNotEqual(self.transformValue.d, self.multiFormatAd.contentView.transform.d);

}


- (void)testNativeRenderingInvalidURL {
    
    TESTTRACE();
    
    [self stubRequestWithResponse:@"appnexus_bannerNative_renderingInvalidURL"];
    [self initBannerNativeRenderingAd:YES NativeRendering:YES];
    
    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    
    [self.multiFormatAd loadAd];
    
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval*2 handler:nil];
    XCTAssertTrue(self.multiFormatAd.enableNativeRendering);
}


#pragma mark - ANBannerAdViewDelegate

- (void)adDidReceiveAd:(id)ad
{
    TESTTRACE();
    
    XCTAssertNotNil(ad);
    self.multiFormatAd = (ANBannerAdView *)ad;
    [self.expectationResponse fulfill];
    if(self.shouldResizeAdToFitContainer && self.loadAdShouldResizeAdToFitContainerExpectation){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            XCTAssertEqual(self.transformValue.a, self.multiFormatAd.contentView.transform.a);
            XCTAssertEqual(self.transformValue.d, self.multiFormatAd.contentView.transform.d);
            [self.loadAdShouldResizeAdToFitContainerExpectation fulfill];
        });
    }
    else if (self.loadAdShouldResizeAdToFitContainerExpectation) {
        [self.loadAdShouldResizeAdToFitContainerExpectation fulfill];
    }
    
}

- (void)ad:(id)loadInstance didReceiveNativeAd:(id)responseInstance
{
    TESTTRACE();
    
    XCTAssertNotNil(loadInstance);
    XCTAssertNotNil(responseInstance);
    [self.expectationResponse fulfill];
    if (self.loadAdShouldResizeAdToFitContainerExpectation) {
        [self.loadAdShouldResizeAdToFitContainerExpectation fulfill];
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
