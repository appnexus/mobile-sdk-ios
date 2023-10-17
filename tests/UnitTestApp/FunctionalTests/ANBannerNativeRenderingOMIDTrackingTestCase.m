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
/*

 ## FOR SAME TESTCASE REVIEW ANOMIDNativeTestCase
 
 
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

@interface ANBannerNativeRenderingOMIDTrackingTestCase : XCTestCase <ANBannerAdViewDelegate , SDKValidationURLProtocolDelegate >

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



@implementation ANBannerNativeRenderingOMIDTrackingTestCase

#pragma mark - Test lifecycle.

+ (void)load {
    TESTTRACE();

    [ANGlobal userAgent];
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
    [SDKValidationURLProtocol setDelegate:nil];
    [NSURLProtocol unregisterClass:[SDKValidationURLProtocol class]];


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

- (void)testOMIDTrackingNativeRendering{

    [SDKValidationURLProtocol setDelegate:self];
    [NSURLProtocol registerClass:[SDKValidationURLProtocol class]];
    [self stubRequestWithResponse:@"NativeAsssemblyRendererOMID_Native_RTBResponse"];
    [self initBannerNativeRenderingAd:YES NativeRendering:YES];

//    self.expectationRequest = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    self.expectationResponse = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    [self.multiFormatAd loadAd];
    [self waitForExpectations:@[ self.expectationResponse] timeout:600];

    // Delay added to allow OMID Event to fire
    [XCTestCase delayForTimeInterval:40];
    XCTAssertTrue([self.requestData containsString:@"OmidSupported"]);
    XCTAssertTrue([self.requestData containsString:@"true"]);
    XCTAssertTrue([self.requestData containsString:@"sessionStart"]);
    XCTAssertTrue([self.requestData containsString:@"partnerName"]);
    XCTAssertTrue([self.requestData containsString:AN_OMIDSDK_PARTNER_NAME]);
    XCTAssertTrue([self.requestData containsString:@"partnerVersion"]);
    XCTAssertTrue([self.requestData containsString:AN_SDK_VERSION]);
    XCTAssertTrue([self.requestData containsString:@"impression"]);
    XCTAssertTrue([self.requestData containsString:@"creativeType"]);
    XCTAssertTrue([self.requestData containsString:@"nativeDisplay"]);
    XCTAssertTrue([self.requestData containsString:@"impressionType"]);
    XCTAssertTrue([self.requestData containsString:@"viewable"]);
    XCTAssertTrue([self.requestData containsString:@"mediaType"]);
    XCTAssertTrue([self.requestData containsString:@"display"]);
    XCTAssertTrue([self.requestData containsString:OMID_SDK_VERSION]);
    XCTAssertTrue([self.requestData containsString:@"libraryVersion"]);
    [self.multiFormatAd removeFromSuperview];
    self.multiFormatAd = nil;
    
    self.expectationForOmidSessionFinish = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        XCTAssertTrue([self.requestData containsString:@"sessionFinish"]);
        [self.expectationForOmidSessionFinish fulfill];

    });
    
    [self waitForExpectations:@[self.expectationForOmidSessionFinish] timeout:50];
    self.requestData = nil;

}


#pragma mark - ANBannerAdViewDelegate

- (void)adDidReceiveAd:(id)ad
{
    [self.expectationResponse fulfill];

}

- (void)ad:(id)loadInstance didReceiveNativeAd:(id)responseInstance
{
    [self.expectationResponse fulfill];
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
    if ([response containsString:@"sessionFinish"]) {
        [self.expectationForOmidSessionFinish fulfill];
    }
    NSLog(@"self.requestData ===> %@",self.requestData);
    [self.requestData appendString:response];
}


@end
*/
