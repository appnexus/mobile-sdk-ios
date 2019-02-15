/*   Copyright 2015 APPNEXUS INC
 
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
#import <KIF/KIF.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>

#import "ANNativeAdRequest.h"
#import "ANGlobal.h"
#import "ANTestGlobal.h"
#import "ANNativeAdView.h"
#import "ANLogManager.h"

#import "ANURLConnectionStub.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"

#import "XCTestCase+ANCategory.h"

#import "ANNativeStandardAdResponse.h"
#import "ANAdAdapterNativeAdMob.h"
#import "ANGADUnifiedNativeAdView.h"
#import "ANNativeMediatedAdResponse+PrivateMethods.h"



@interface ANNativeAdResponseTestCase : KIFTestCase <ANNativeAdRequestDelegate, ANNativeAdDelegate>

@property (nonatomic, readwrite, strong) ANNativeAdRequest *adRequest;

@property (nonatomic, readwrite, strong) XCTestExpectation *delegateCallbackExpectation;
@property (nonatomic, readwrite, strong) XCTestExpectation *clickThroughWithURLExpectation;

@property (nonatomic, readwrite, assign) BOOL successfulAdCall;
@property (nonatomic, readwrite, strong) ANNativeAdResponse *adResponse;
@property (nonatomic, readwrite, strong) NSError *adRequestError;
@property (nonatomic, readwrite, strong) ANNativeAdView *nativeAdView;
@property (nonatomic, readwrite, strong) ANGADUnifiedNativeAdView *unifedNativeAdView;

@property (nonatomic, readwrite, strong) NSMutableArray *impressionTrackers;
@property (nonatomic, readwrite, strong) NSMutableArray *clickTrackers;

@property (nonatomic, readwrite, strong) UIViewController *rootViewController;

@property (nonatomic, readwrite, assign) BOOL receivedCallbackAdWasClicked;
@property (nonatomic, readwrite, assign) BOOL receivedCallbackAdWasClickedWithURL;
@property (nonatomic, readwrite, assign) BOOL receivedCallbackAdWillPresent;
@property (nonatomic, readwrite, assign) BOOL receivedCallbackAdDidPresent;
@property (nonatomic, readwrite, assign) BOOL receivedCallbackAdWillClose;
@property (nonatomic, readwrite, assign) BOOL receivedCallbackAdDidClose;
@property (nonatomic, readwrite, assign) BOOL receivedCallbackAdWillLeaveApplication;

@property (nonatomic)          BOOL      nativeAdResponseShouldReturnClickThroughURL;
@property (nonatomic, strong)  NSString  *clickThroughURL;
@property (nonatomic, strong)  NSString  *clickThroughFallbackURL;

@end



@implementation ANNativeAdResponseTestCase

#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    [ANLogManager setANLogLevel:ANLogLevelAll];
    self.adRequest = [[ANNativeAdRequest alloc] init];
    self.adRequest.delegate = self;
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
}

- (void)tearDown {
    [super tearDown];
    self.adRequest = nil;
    self.delegateCallbackExpectation = nil;
    self.successfulAdCall = NO;
    self.adResponse = nil;
    self.adRequestError = nil;
    [self.nativeAdView removeFromSuperview];
    self.nativeAdView = nil;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.impressionTrackers = nil;
    self.clickTrackers = nil;
    
    self.rootViewController = nil;
    
    self.receivedCallbackAdWasClicked = NO;
    self.receivedCallbackAdWasClickedWithURL = NO;
    self.nativeAdResponseShouldReturnClickThroughURL = NO;
    self.clickThroughURL = nil;
    self.clickThroughFallbackURL = nil;

    self.receivedCallbackAdWillPresent = NO;
    self.receivedCallbackAdDidPresent = NO;
    self.receivedCallbackAdWillClose = NO;
    self.receivedCallbackAdDidClose = NO;
    self.receivedCallbackAdWillLeaveApplication = NO;
}




#pragma mark - Tests

- (void)testAppNexusWithIconImageLoad {
    [self stubRequestWithResponse:@"appnexus_standard_response"];

    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];

    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);
    
    [self iconImageShouldBePresentInResponse:YES];
    [self mainImageShouldBePresentInResponse:NO];
    
    [self createBasicNativeView];
    [self populateNativeViewWithResponse];
    [self registerNativeView];
    [self addNativeViewToViewHierarchy];
    
    [self pullImpressionAndClickTrackersFromResponse];
    [self setupURLDidLoadTracker];
    [self assertPendingImpressionTrackerCount:1];
    [self assertPendingClickTrackerCount:1];
    
    [tester waitForTimeInterval:2.0];
    [self assertPendingImpressionTrackerCount:0];
    [self assertPendingClickTrackerCount:1];
    [self clickOnAd];

    [tester waitForTimeInterval:2.0];
    [self assertPresentCallbacksReceived];
    [self assertPendingClickTrackerCount:0];
    [self closeInAppBrowser];

    [tester waitForTimeInterval:3.0];
    [self assertCloseCallbacksReceived];
}

- (void)testAppNexusWithIconAndMainImageLoad {
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.adRequest.shouldLoadMainImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];

    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);
    
    [self iconImageShouldBePresentInResponse:YES];
    [self mainImageShouldBePresentInResponse:YES];

    [self createMainImageNativeView];
    [self populateNativeViewWithResponse];
    [self registerNativeView];
    [self addNativeViewToViewHierarchy];
    
    [tester waitForTimeInterval:2.0];
    [self clickOnAd];

    [tester waitForTimeInterval:2.0];
    [self assertPresentCallbacksReceived];
    [self forceDismissPresentedController];

    [tester waitForTimeInterval:3.0];
}

- (void)testAppNexusWithIconImageLoadToStoreUrl {
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);
    
    [self iconImageShouldBePresentInResponse:YES];
    [self mainImageShouldBePresentInResponse:NO];
    
    [self createBasicNativeView];
    [self populateNativeViewWithResponse];
    [self registerNativeView];
    [self addNativeViewToViewHierarchy];
    
    [tester waitForTimeInterval:2.0];
    
    [self clickOnAd];
    [tester waitForTimeInterval:2.0];
    [self assertPresentCallbacksReceived];
    
    [self forceDismissPresentedController];
    [tester waitForTimeInterval:3.0];
}

- (void)testAppNexusWithMultipleTrackers {
    [self stubRequestWithResponse:@"appnexus_multiple_trackers"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);
    
    [self iconImageShouldBePresentInResponse:YES];
    [self mainImageShouldBePresentInResponse:NO];
    
    [self createBasicNativeView];
    [self populateNativeViewWithResponse];
    [self registerNativeView];
    [self addNativeViewToViewHierarchy];
    
    [self pullImpressionAndClickTrackersFromResponse];
    [self setupURLDidLoadTracker];
    [self assertPendingImpressionTrackerCount:3];
    [self assertPendingClickTrackerCount:4];

    [tester waitForTimeInterval:2.0];
    [self assertPendingImpressionTrackerCount:0];
    [self assertPendingClickTrackerCount:4];
    [self clickOnAd];

    [tester waitForTimeInterval:2.0];
    [self assertPresentCallbacksReceived];
    [self assertPendingClickTrackerCount:0];
    
    [self closeInAppBrowser];

    [tester waitForTimeInterval:3.0];
    [self assertCloseCallbacksReceived];
}

- (void)testAppNexusRecycledView {
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.adRequest.shouldLoadMainImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);
    
    [self createMainImageNativeView];
    [self populateNativeViewWithResponse];
    [self addNativeViewToViewHierarchy];
    [self registerNativeView];

    [tester waitForTimeInterval:3.0];
    
    [self clickOnAd];
    [tester waitForTimeInterval:2.0];
    [self assertPresentCallbacksReceived];
    
    [self closeInAppBrowser];
    [tester waitForTimeInterval:3.0];
    [self assertCloseCallbacksReceived];
    
    self.adResponse = nil;
    
    //-----//


    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [self stubRequestWithResponse:@"facebook_mediated_response"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);
    
    [self populateNativeViewWithResponse];
    [self registerNativeView];
    
    [tester waitForTimeInterval:3.0];

    /* These cases are not possible to be executed because click triggers opening of SAFARI browser and there is no way to come back using KIF or XCTest since it is launched external to the app.
        Plus there is a cascading effect of other test cases failing because of we are not back in the app. Mediation adapter test have hidden this behind a flag #define kANMediationAdaptersUITesting 1
                 
    if ([[UIScreen mainScreen] respondsToSelector:@selector(coordinateSpace)]) {
        [self clickOnAd];
        [tester waitForTimeInterval:2.0];
        [self assertPresentCallbacksReceived];
        
        [self forceDismissPresentedController];
        [tester waitForTimeInterval:3.0];
    }
                 */

    //-----//

    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);

    [self populateNativeViewWithResponse];
    [self registerNativeView];
    
    [tester waitForTimeInterval:3.0];
}

- (void)testAppNexusClickFallbackBehavior {
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);
    
    [self iconImageShouldBePresentInResponse:YES];
    [self mainImageShouldBePresentInResponse:NO];
    
    [self createBasicNativeView];
    [self populateNativeViewWithResponse];
    [self registerNativeView];
    [self addNativeViewToViewHierarchy];
    
    [self pullImpressionAndClickTrackersFromResponse];
    [self setupURLDidLoadTracker];
    [self assertPendingImpressionTrackerCount:1];
    [self assertPendingClickTrackerCount:1];
    
    [tester waitForTimeInterval:2.0];
    
    [self assertPendingClickTrackerCount:1];
    
    [self clickOnAd];
    // click_url_fallback will be triggered after click_url fails
    [tester waitForTimeInterval:2.0];
    [self assertPresentCallbacksReceived];

    [self closeInAppBrowser];
    [tester waitForTimeInterval:3.0];
    [self assertCloseCallbacksReceived];
}

- (void) testAppNexusWithClickThroughActionReturnURL
{
    [self stubRequestWithResponse:@"appnexus_standard_response"];

    self.nativeAdResponseShouldReturnClickThroughURL = YES;

    self.adRequest.shouldLoadIconImage = YES;
    [self.adRequest loadAd];

    //
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];

    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);

    //
    [self createBasicNativeView];
    [self populateNativeViewWithResponse];
    [self registerNativeView];
    [self addNativeViewToViewHierarchy];

    [tester waitForTimeInterval:2.0];

    //
    self.clickThroughWithURLExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]];

    [self clickOnAd];

    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval handler:nil];

    //
    XCTAssertTrue(self.receivedCallbackAdWasClickedWithURL);
    XCTAssertFalse(self.receivedCallbackAdWasClicked);
    XCTAssertTrue([self.clickThroughURL length] > 0);

    if (self.clickThroughFallbackURL) {
        XCTAssertTrue([self.clickThroughFallbackURL length] > 0);
    }
}




#pragma mark - Mediation Tests

- (void)testFacebookWithIconImageLoad {
    [self stubRequestWithResponse:@"facebook_mediated_response"];
    [FBAdSettings setLogLevel:FBAdLogLevelLog];
    [FBAdSettings addTestDevice:[FBAdSettings testDeviceHash]];
    [FBAdSettings addTestDevice:@"277a4a8d628c973785eb36e68c319fef5527e6cb"]; // CST/Mobile 12, iPhone 6s Plus
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);
    
    [self iconImageShouldBePresentInResponse:YES];
    [self mainImageShouldBePresentInResponse:NO];
    
    [self createBasicNativeView];
    [self populateNativeViewWithResponse];
    [self registerNativeView];
    [self addNativeViewToViewHierarchy];
    
    [tester waitForTimeInterval:2.0];

    /*These cases are not possible to be executed because click triggers opening of SAFARI browser and there is no way to come back using KIF or XCTest since it is launched external to the app.
       Plus there is a cascading effect of other test cases failing because of we are not back in the app. Mediation adapter test have hidden this behind a flag #define kANMediationAdaptersUITesting 1
    if ([[UIScreen mainScreen] respondsToSelector:@selector(coordinateSpace)]) {
        [self clickOnAd];
        [tester waitForTimeInterval:2.0];
        [self assertPresentCallbacksReceived];
        
        [self forceDismissPresentedController2];
        [tester waitForTimeInterval:3.0];
    }
             */
}

- (void)testAdMobWithIconImageLoad {
    [self stubRequestWithResponse:@"adMob_mediated_response"];
//    [ANAdAdapterNativeAdMob enableNativeAppInstallAds];
//    [ANAdAdapterNativeAdMob enableNativeContentAds];
    self.adRequest.shouldLoadIconImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);
    XCTAssertEqualObjects(self.adResponse.creativeId, @"123456");
    
    [self iconImageShouldBePresentInResponse:YES];
    [self mainImageShouldBePresentInResponse:NO];
    
    [self createGADUnifiedNativeView];
    NSError *registerError;
    UIViewController *rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.adResponse.delegate = self;
    [self.adResponse registerViewForTracking:self.unifedNativeAdView
                      withRootViewController:rvc
                              clickableViews:@[]
                                       error:&registerError];
    XCTAssertNil(registerError);
    XCTAssertNotNil(self.unifedNativeAdView.nativeAd);
    XCTAssertTrue([self.unifedNativeAdView.nativeAd isKindOfClass:[GADUnifiedNativeAd class]]);
}


- (void)testCustomDummyAdapterSuccesful {
    [self stubRequestWithResponse:@"custom_dummy_mediated_response"];

    self.adRequest.shouldLoadIconImage = false;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);
    
    [self createBasicNativeView];
    [self populateNativeViewWithResponse];
    
    // Setup impression recording objects
    [self setupURLDidLoadTracker];
    
    XCTAssertTrue([self.adResponse isKindOfClass:[ANNativeMediatedAdResponse class]]);
    ANNativeMediatedAdResponse *medidatedAdResponse = (ANNativeMediatedAdResponse *)self.adResponse;
    self.impressionTrackers = [medidatedAdResponse.impTrackers mutableCopy];
    
    
    [self assertPendingImpressionTrackerCount:1];
    
    // Calling registerNativeView on the Dummy Adapter will make impression trackers to be fired immediately
    [self registerNativeView];
    
    [tester waitForTimeInterval:2.0];
    [self assertPendingImpressionTrackerCount:0];
}


#pragma mark - ANNativeAdRequestDelegate

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response
{
TESTTRACE();
    if (self.nativeAdResponseShouldReturnClickThroughURL) {
        response.clickThroughAction = ANClickThroughActionReturnURL;
    }

    self.adResponse = response;
    self.successfulAdCall = YES;
    [self.delegateCallbackExpectation fulfill];
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error
{
TESTTRACE();
    self.adRequestError = error;
    self.successfulAdCall = NO;
    [self.delegateCallbackExpectation fulfill];
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




#pragma mark - ANAdDelegate

- (void)adWasClicked:(id)response
{
TESTTRACE();
    self.receivedCallbackAdWasClicked = YES;
}

- (void)adWasClicked:(id)response withURL:(NSString *)clickURLString fallbackURL:(NSString *)clickFallbackURLString
{
TESTTRACE();
    [self.clickThroughWithURLExpectation fulfill];
    self.receivedCallbackAdWasClickedWithURL = YES;

    self.clickThroughURL = clickURLString;
    self.clickThroughFallbackURL = clickFallbackURLString;
}

- (void)adWillPresent:(id)response {
    self.receivedCallbackAdWillPresent = YES;
}

- (void)adDidPresent:(id)response {
    self.receivedCallbackAdDidPresent = YES;
}

- (void)adWillClose:(id)response {
    self.receivedCallbackAdWillClose = YES;
}

- (void)adDidClose:(id)response {
    self.receivedCallbackAdDidClose = YES;
}

- (void)adWillLeaveApplication:(id)response {
    self.receivedCallbackAdWillLeaveApplication = YES;
}




#pragma mark - Helper

- (void)requestLoaded:(NSNotification *)notification {
    NSURLRequest *request = notification.userInfo[kANHTTPStubURLProtocolRequest];
    __block NSInteger indexToRemove = -1;
    [self.impressionTrackers enumerateObjectsUsingBlock:^(NSString *URL, NSUInteger idx, BOOL *stop) {
        if ([request.URL.absoluteString isEqualToString:URL]) {
            indexToRemove = (NSInteger)idx;
            *stop = YES;
        }
    }];
    if (indexToRemove >= 0) {
        [self.impressionTrackers removeObjectAtIndex:indexToRemove];
        return;
    }
    [self.clickTrackers enumerateObjectsUsingBlock:^(NSString *URL, NSUInteger idx, BOOL *stop) {
        if ([request.URL.absoluteString isEqualToString:URL]) {
            indexToRemove = (NSInteger)idx;
            *stop = YES;
        }
    }];
    if (indexToRemove >= 0) {
        [self.clickTrackers removeObjectAtIndex:indexToRemove];
    }
}

- (void)setupURLDidLoadTracker {
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestLoaded:)
                                                 name:kANHTTPStubURLProtocolRequestDidLoadNotification
                                               object:nil];
}

- (void)iconImageShouldBePresentInResponse:(BOOL)iconPresent {
    if (iconPresent) {
        XCTAssertNotNil(self.adResponse.iconImage);
        XCTAssertTrue([self.adResponse.iconImage isKindOfClass:[UIImage class]]);
    } else {
        XCTAssertNil(self.adResponse.iconImage);
    }
}

- (void)mainImageShouldBePresentInResponse:(BOOL)mainImagePresent {
    if (mainImagePresent) {
        XCTAssertNotNil(self.adResponse.mainImage);
        XCTAssertTrue([self.adResponse.mainImage isKindOfClass:[UIImage class]]);
    } else {
        XCTAssertNil(self.adResponse.mainImage);
    }
}

- (void)createBasicNativeView {
    UINib *adNib = [UINib nibWithNibName:@"ANNativeAdView" bundle:[NSBundle bundleForClass:[self class]]];
    NSArray *array = [adNib instantiateWithOwner:self options:nil];
    self.nativeAdView = [array firstObject];
}

- (void)createGADUnifiedNativeView {
    UINib *adNib = [UINib nibWithNibName:@"ANGADUnifiedNativeAdView" bundle:[NSBundle bundleForClass:[self class]]];
    NSArray *array = [adNib instantiateWithOwner:self options:nil];
    self.unifedNativeAdView = [array firstObject];
}

- (void)createMainImageNativeView {
    UINib *adNib = [UINib nibWithNibName:@"ANNativeAdViewMainImage" bundle:[NSBundle bundleForClass:[self class]]];
    NSArray *array = [adNib instantiateWithOwner:self options:nil];
    self.nativeAdView = [array firstObject];
}

- (void)populateNativeViewWithResponse {
    ANNativeAdView *nativeAdView = self.nativeAdView;
    nativeAdView.titleLabel.text = self.adResponse.title;
    nativeAdView.bodyLabel.text = self.adResponse.body;
    nativeAdView.iconImageView.image = self.adResponse.iconImage;
    nativeAdView.mainImageView.image = self.adResponse.mainImage;
    [nativeAdView.callToActionButton setTitle:self.adResponse.callToAction forState:UIControlStateNormal];
}

- (void)registerNativeView {
    NSError *registerError;
    UIViewController *rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.adResponse.delegate = self;
    [self.adResponse registerViewForTracking:self.nativeAdView
                      withRootViewController:rvc
                              clickableViews:@[self.nativeAdView.callToActionButton]
                                       error:&registerError];
    XCTAssertNil(registerError);
}

- (void)assertPendingImpressionTrackerCount:(NSInteger)numImpTrackers
{
    XCTAssertEqual(self.impressionTrackers.count, numImpTrackers);
}

- (void)assertPendingClickTrackerCount:(NSInteger)numClickTrackers {
    XCTAssertEqual(self.clickTrackers.count, numClickTrackers);
}

- (void)pullImpressionAndClickTrackersFromResponse {
    XCTAssertTrue([self.adResponse isKindOfClass:[ANNativeStandardAdResponse class]]);
    ANNativeStandardAdResponse *standardResponse = (ANNativeStandardAdResponse *)self.adResponse;
    self.impressionTrackers = [standardResponse.impTrackers mutableCopy];
    self.clickTrackers = [standardResponse.clickTrackers mutableCopy];
}

- (void)addNativeViewToViewHierarchy {
    UIViewController *rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.rootViewController = rvc;
    [rvc.view addSubview:self.nativeAdView];
}

- (void)clickOnAd {
    self.adResponse.landingPageLoadsInBackground = NO;
    [tester tapViewWithAccessibilityLabel:@"ANNativeAdViewCallToAction"];
}

- (void)assertPresentCallbacksReceived {
    XCTAssertTrue(self.receivedCallbackAdWasClicked);
    XCTAssertTrue(self.receivedCallbackAdWillPresent);
    XCTAssertTrue(self.receivedCallbackAdDidPresent);
}

- (void)closeInAppBrowser {
    [tester tapViewWithAccessibilityLabel:@"OK"];
}

- (void)forceDismissPresentedController {
    XCTAssertNotNil(self.rootViewController.presentedViewController);
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)assertCloseCallbacksReceived {
    XCTAssertTrue(self.receivedCallbackAdWillClose);
    XCTAssertTrue(self.receivedCallbackAdDidClose);
}

@end
