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

#import "ANNativeAdRequest.h"
#import "ANGlobal.h"
#import "ANNativeAdView.h"
#import "ANLogManager.h"

#import "ANURLConnectionStub.h"
#import "ANHTTPStubbingManager.h"

#import "XCTestCase+ANCategory.h"

#import "ANNativeStandardAdResponse.h"
#import "ANAdAdapterNativeAdMob.h"
#import "ANGADNativeAppInstallAdView.h"

@interface ANNativeAdResponseTestCase : KIFTestCase <ANNativeAdRequestDelegate, ANNativeAdDelegate>

@property (nonatomic, readwrite, strong) ANNativeAdRequest *adRequest;
@property (nonatomic, readwrite, strong) XCTestExpectation *delegateCallbackExpectation;
@property (nonatomic, readwrite, assign) BOOL successfulAdCall;
@property (nonatomic, readwrite, strong) ANNativeAdResponse *adResponse;
@property (nonatomic, readwrite, strong) NSError *adRequestError;
@property (nonatomic, readwrite, strong) ANNativeAdView *nativeAdView;
@property (nonatomic, readwrite, strong) ANGADNativeAppInstallAdView *installAdView;

@property (nonatomic, readwrite, strong) NSMutableArray *impressionTrackers;
@property (nonatomic, readwrite, strong) NSMutableArray *clickTrackers;

@property (nonatomic, readwrite, strong) UIViewController *rootViewController;

@property (nonatomic, readwrite, assign) BOOL receivedCallbackAdWasClicked;
@property (nonatomic, readwrite, assign) BOOL receivedCallbackAdWillPresent;
@property (nonatomic, readwrite, assign) BOOL receivedCallbackAdDidPresent;
@property (nonatomic, readwrite, assign) BOOL receivedCallbackAdWillClose;
@property (nonatomic, readwrite, assign) BOOL receivedCallbackAdDidClose;
@property (nonatomic, readwrite, assign) BOOL receivedCallbackAdWillLeaveApplication;

@end

@implementation ANNativeAdResponseTestCase

- (void)setUp {
    [super setUp];
    [ANLogManager setANLogLevel:ANLogLevelAll];
    self.adRequest = [[ANNativeAdRequest alloc] init];
    self.adRequest.delegate = self;
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [self stubResultCBResponse];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kANHTTPStubURLProtocolRequestDidLoadNotification
                                                  object:nil];
    self.impressionTrackers = nil;
    self.clickTrackers = nil;
    
    self.rootViewController = nil;
    
    self.receivedCallbackAdWasClicked = NO;
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
                                 handler:^(NSError *error) {
                                     
                                 }];
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
    [self stubRequestWithResponse:@"appnexus_standard_response_store_url"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.adRequest.shouldLoadMainImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
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
    [self stubRequestWithResponse:@"appnexus_standard_response_store_url"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
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

- (void)testAppNexusWithMultipleMainMedia {
    [self stubRequestWithResponse:@"appnexus_multiple_main_media"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.adRequest.shouldLoadMainImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);
    
    [self iconImageShouldBePresentInResponse:YES];
    [self mainImageShouldBePresentInResponse:YES];
    
    XCTAssertTrue([self.adResponse.mainImageURL.absoluteString containsString:@"acdn.adnxs.com/mobile"]);

    [self createMainImageNativeView];
    [self populateNativeViewWithResponse];
    [self registerNativeView];
    [self addNativeViewToViewHierarchy];
    
    [tester waitForTimeInterval:2.0];
    
    [self clickOnAd];
    [tester waitForTimeInterval:2.0];
    [self assertPresentCallbacksReceived];
    
    [self closeInAppBrowser];
    [tester waitForTimeInterval:3.0];
    [self assertCloseCallbacksReceived];
}

- (void)testAppNexusWithMultipleMainMediaDefault {
    [self stubRequestWithResponse:@"appnexus_multiple_main_media_default"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.adRequest.shouldLoadMainImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);

    [self iconImageShouldBePresentInResponse:YES];
    [self mainImageShouldBePresentInResponse:YES];
    
    XCTAssertTrue([self.adResponse.mainImageURL.absoluteString containsString:@"acdn.adnxs.com/mobile"]);
    
    [self createMainImageNativeView];
    [self populateNativeViewWithResponse];
    [self registerNativeView];
    [self addNativeViewToViewHierarchy];
    
    [tester waitForTimeInterval:2.0];
    
    [self clickOnAd];
    [tester waitForTimeInterval:2.0];
    [self assertPresentCallbacksReceived];
    
    [self closeInAppBrowser];
    [tester waitForTimeInterval:3.0];
    [self assertCloseCallbacksReceived];
}

- (void)testAppNexusWithMultipleTrackers {
    [self stubRequestWithResponse:@"appnexus_multiple_trackers"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
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
                                 handler:^(NSError *error) {
                                     
                                 }];
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
    [self stubResultCBResponse];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);
    
    [self populateNativeViewWithResponse];
    [self registerNativeView];
    
    [tester waitForTimeInterval:3.0];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(coordinateSpace)]) {
        [self clickOnAd];
        [tester waitForTimeInterval:2.0];
        [self assertPresentCallbacksReceived];
        
        [self forceDismissPresentedController];
        [tester waitForTimeInterval:3.0];
    }
    
    //-----//

    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [self stubResultCBResponse];
    [self.adRequest loadAd];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);

    [self populateNativeViewWithResponse];
    [self registerNativeView];
    
    [tester waitForTimeInterval:3.0];
}

- (void)testAppNexusClickFallbackBehavior {
    [self stubRequestWithResponse:@"appnexus_click_fallback_example"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
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
    // click_url_fallback will be triggered after click_url fails
    [tester waitForTimeInterval:2.0];
    [self assertPresentCallbacksReceived];
    [self assertPendingClickTrackerCount:0];
    
    [self closeInAppBrowser];
    [tester waitForTimeInterval:3.0];
    [self assertCloseCallbacksReceived];
}

#pragma mark - Mediation Tests

- (void)testMoPubWithIconImageLoad {
//    [self stubRequestWithResponse:@"mopub_mediated_response"];
//    [self.adRequest loadAd];
//    self.adRequest.shouldLoadIconImage = YES;
//    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
//    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
//                                 handler:^(NSError *error) {
//                                     
//                                 }];
//    XCTAssertTrue(self.successfulAdCall);
//    XCTAssertNil(self.adRequestError);
//    
//    [self iconImageShouldBePresentInResponse:YES];
//    [self mainImageShouldBePresentInResponse:NO];
//    
//    [self createBasicNativeView];
//    [self populateNativeViewWithResponse];
//    [self registerNativeView];
//    [self addNativeViewToViewHierarchy];
//
//    [tester waitForTimeInterval:2.0];
//    
//    [self clickOnAd];
//    [tester waitForTimeInterval:2.0];
//    [self assertPresentCallbacksReceived];
//    
//    [self forceDismissPresentedController];
//    [tester waitForTimeInterval:3.0];
}

- (void)testFacebookWithIconImageLoad {
    [self stubRequestWithResponse:@"facebook_mediated_response"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);
    
    [self iconImageShouldBePresentInResponse:YES];
    [self mainImageShouldBePresentInResponse:NO];
    
    [self createBasicNativeView];
    [self populateNativeViewWithResponse];
    [self registerNativeView];
    [self addNativeViewToViewHierarchy];
    
    [tester waitForTimeInterval:2.0];

    if ([[UIScreen mainScreen] respondsToSelector:@selector(coordinateSpace)]) {
        [self clickOnAd];
        [tester waitForTimeInterval:2.0];
        [self assertPresentCallbacksReceived];
        
        [self forceDismissPresentedController];
        [tester waitForTimeInterval:3.0];
    }
}

- (void)testAdMobWithIconImageLoad {
    [self stubRequestWithResponse:@"adMob_mediated_response"];
    [ANAdAdapterNativeAdMob enableNativeAppInstallAds];
    self.adRequest.shouldLoadIconImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self.adRequest loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);
    
    [self iconImageShouldBePresentInResponse:YES];
    [self mainImageShouldBePresentInResponse:NO];
    
    [self createGADInstallNativeView];
    NSError *registerError;
    UIViewController *rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.adResponse.delegate = self;
    [self.adResponse registerViewForTracking:self.installAdView
                      withRootViewController:rvc
                              clickableViews:@[]
                                       error:&registerError];
    XCTAssertNil(registerError);
    XCTAssertNotNil(self.installAdView.nativeAppInstallAd);
    XCTAssertTrue([self.installAdView.nativeAppInstallAd isKindOfClass:[GADNativeAppInstallAd class]]);
}

#pragma mark - ANNativeAdRequestDelegate

- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response {
    self.adResponse = response;
    self.successfulAdCall = YES;
    [self.delegateCallbackExpectation fulfill];
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error {
    self.adRequestError = error;
    self.successfulAdCall = NO;
    [self.delegateCallbackExpectation fulfill];
}

# pragma mark - Ad Server Response Stubbing

- (void)stubRequestWithResponse:(NSString *)responseName {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *baseResponse = [NSString stringWithContentsOfFile:[currentBundle pathForResource:responseName
                                                                                        ofType:@"json"]
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    ANURLConnectionStub *requestStub = [[ANURLConnectionStub alloc] init];
    requestStub.requestURLRegexPatternString = @"http://mediation.adnxs.com/mob\\?.*";
    requestStub.responseCode = 200;
    requestStub.responseBody = baseResponse;
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:requestStub];
}

- (void)stubResultCBResponse {
    ANURLConnectionStub *resultCBStub = [[ANURLConnectionStub alloc] init];
    resultCBStub.requestURLRegexPatternString = @"http://nym1.mobile.adnxs.com/mediation.*";
    resultCBStub.responseCode = 200;
    resultCBStub.responseBody = @"";
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:resultCBStub];
}

#pragma mark - ANAdDelegate

- (void)adWasClicked:(ANNativeAdResponse *)response {
    self.receivedCallbackAdWasClicked = YES;
}

- (void)adWillPresent:(ANNativeAdResponse *)response {
    self.receivedCallbackAdWillPresent = YES;
}

- (void)adDidPresent:(ANNativeAdResponse *)response {
    self.receivedCallbackAdDidPresent = YES;
}

- (void)adWillClose:(ANNativeAdResponse *)response {
    self.receivedCallbackAdWillClose = YES;
}

- (void)adDidClose:(ANNativeAdResponse *)response {
    self.receivedCallbackAdDidClose = YES;
}

- (void)adWillLeaveApplication:(ANNativeAdResponse *)response {
    self.receivedCallbackAdWillLeaveApplication = YES;
}

#pragma mark - Helper

- (void)requestLoaded:(NSNotification *)notification {
    NSURLRequest *request = notification.userInfo[kANHTTPStubURLProtocolRequest];
    __block NSInteger indexToRemove = -1;
    [self.impressionTrackers enumerateObjectsUsingBlock:^(NSURL *URL, NSUInteger idx, BOOL *stop) {
        if ([request.URL isEqual:URL]) {
            indexToRemove = (NSInteger)idx;
            *stop = YES;
        }
    }];
    if (indexToRemove >= 0) {
        [self.impressionTrackers removeObjectAtIndex:indexToRemove];
        return;
    }
    [self.clickTrackers enumerateObjectsUsingBlock:^(NSURL *URL, NSUInteger idx, BOOL *stop) {
        if ([request.URL isEqual:URL]) {
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

- (void)createGADInstallNativeView {
    UINib *adNib = [UINib nibWithNibName:@"ANGADNativeAppInstallAdView" bundle:[NSBundle bundleForClass:[self class]]];
    NSArray *array = [adNib instantiateWithOwner:self options:nil];
    self.installAdView = [array firstObject];
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

- (void)assertPendingImpressionTrackerCount:(NSInteger)numImpTrackers {
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
    [tester tapViewWithAccessibilityLabel:@"Done"];
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
