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

@interface ANNativeAdResponseTestCase : KIFTestCase <ANNativeAdRequestDelegate>

@property (nonatomic, readwrite, strong) ANNativeAdRequest *adRequest;
@property (nonatomic, readwrite, strong) XCTestExpectation *delegateCallbackExpectation;
@property (nonatomic, readwrite, assign) BOOL successfulAdCall;
@property (nonatomic, readwrite, strong) ANNativeAdResponse *adResponse;
@property (nonatomic, readwrite, strong) NSError *adRequestError;
@property (nonatomic, readwrite, strong) ANNativeAdView *nativeAdView;

@property (nonatomic, readwrite, strong) NSMutableArray *impressionTrackers;
@property (nonatomic, readwrite, strong) NSMutableArray *clickTrackers;

@end

@implementation ANNativeAdResponseTestCase

- (void)setUp {
    [super setUp];
    [ANLogManager setANLogLevel:ANLogLevelAll];
    self.adRequest = [[ANNativeAdRequest alloc] init];
    self.adRequest.delegate = self;
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [self stubResultCBResponse];

    UINib *adNib = [UINib nibWithNibName:@"ANNativeAdView" bundle:[NSBundle bundleForClass:[self class]]];
    NSArray *array = [adNib instantiateWithOwner:self options:nil];
    self.nativeAdView = [array firstObject];

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
    self.impressionTrackers = nil;
    self.clickTrackers = nil;
}

- (void)testAppNexusWithIconImageLoad {
    [self stubRequestWithResponse:@"appnexus_standard_response"];
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestLoaded:)
                                                 name:kANHTTPStubURLProtocolRequestDidLoadNotification
                                               object:nil];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);
    XCTAssertNotNil(self.adResponse.iconImage);
    XCTAssertNil(self.adResponse.mainImage);
    
    ANNativeAdView *nativeAdView = self.nativeAdView;
    nativeAdView.titleLabel.text = self.adResponse.title;
    nativeAdView.bodyLabel.text = self.adResponse.body;
    nativeAdView.iconImageView.image = self.adResponse.iconImage;
    [nativeAdView.callToActionButton setTitle:self.adResponse.callToAction forState:UIControlStateNormal];
    
    UIViewController *rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rvc.view addSubview:nativeAdView];
    
    NSError *registerError;
    [self.adResponse registerViewForTracking:nativeAdView
                      withRootViewController:rvc
                              clickableViews:@[nativeAdView.callToActionButton]
                                       error:&registerError];
    XCTAssertNil(registerError);
    
    ANNativeStandardAdResponse *standardResponse = (ANNativeStandardAdResponse *)self.adResponse;
    XCTAssertEqual(standardResponse.impTrackers.count, 1);
    XCTAssertEqual(standardResponse.clickTrackers.count, 1);

    self.impressionTrackers = [standardResponse.impTrackers mutableCopy];
    self.clickTrackers = [standardResponse.clickTrackers mutableCopy];
    
    [tester waitForTimeInterval:2.0];
    XCTAssertEqual(self.impressionTrackers.count, 0);
    
    self.adResponse.landingPageLoadsInBackground = NO;
    [tester tapViewWithAccessibilityLabel:@"ANNativeAdViewCallToAction"];
    [tester waitForViewWithAccessibilityLabel:@"In App Browser"];
    [tester waitForTimeInterval:2.0];
    XCTAssertEqual(self.clickTrackers.count, 0);
    
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester waitForTimeInterval:3.0];
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
    XCTAssertNotNil(self.adResponse.iconImage);
    XCTAssertNotNil(self.adResponse.mainImage);
    
    XCTAssertTrue([self.adResponse.iconImage isKindOfClass:[UIImage class]]);
    XCTAssertTrue([self.adResponse.mainImage isKindOfClass:[UIImage class]]);

    UINib *adNib = [UINib nibWithNibName:@"ANNativeAdViewMainImage" bundle:[NSBundle bundleForClass:[self class]]];
    NSArray *array = [adNib instantiateWithOwner:self options:nil];
    self.nativeAdView = [array firstObject];

    ANNativeAdView *nativeAdView = self.nativeAdView;
    nativeAdView.titleLabel.text = self.adResponse.title;
    nativeAdView.bodyLabel.text = self.adResponse.body;
    nativeAdView.iconImageView.image = self.adResponse.iconImage;
    nativeAdView.mainImageView.image = self.adResponse.mainImage;
    [nativeAdView.callToActionButton setTitle:self.adResponse.callToAction forState:UIControlStateNormal];
    
    UIViewController *rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rvc.view addSubview:nativeAdView];
    
    NSError *registerError;
    [self.adResponse registerViewForTracking:nativeAdView
                      withRootViewController:rvc
                              clickableViews:@[nativeAdView.callToActionButton]
                                       error:&registerError];
    XCTAssertNil(registerError);
    
    [tester waitForTimeInterval:2.0];
    [tester tapViewWithAccessibilityLabel:@"ANNativeAdViewCallToAction"];
    [tester waitForTimeInterval:2.0];
    XCTAssertNotNil(rvc.presentedViewController);
    [rvc dismissViewControllerAnimated:YES completion:nil];
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
    XCTAssertNotNil(self.adResponse.iconImage);
    XCTAssertNil(self.adResponse.mainImage);
    
    ANNativeAdView *nativeAdView = self.nativeAdView;
    nativeAdView.titleLabel.text = self.adResponse.title;
    nativeAdView.bodyLabel.text = self.adResponse.body;
    nativeAdView.iconImageView.image = self.adResponse.iconImage;
    [nativeAdView.callToActionButton setTitle:self.adResponse.callToAction forState:UIControlStateNormal];
    
    UIViewController *rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rvc.view addSubview:nativeAdView];
    
    NSError *registerError;
    [self.adResponse registerViewForTracking:nativeAdView
                      withRootViewController:rvc
                              clickableViews:@[nativeAdView.callToActionButton]
                                       error:&registerError];
    XCTAssertNil(registerError);
    
    [tester waitForTimeInterval:2.0];
    [tester tapViewWithAccessibilityLabel:@"ANNativeAdViewCallToAction"];
    [tester waitForTimeInterval:2.0];
    XCTAssertNotNil(rvc.presentedViewController);
    [rvc dismissViewControllerAnimated:YES completion:nil];
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
    XCTAssertTrue([self.adResponse.mainImageURL.absoluteString containsString:@"rlissack.adnxs.net"]);
    XCTAssertNotNil(self.adResponse.iconImage);
    XCTAssertNotNil(self.adResponse.mainImage);
    
    XCTAssertTrue([self.adResponse.iconImage isKindOfClass:[UIImage class]]);
    XCTAssertTrue([self.adResponse.mainImage isKindOfClass:[UIImage class]]);
    
    UINib *adNib = [UINib nibWithNibName:@"ANNativeAdViewMainImage" bundle:[NSBundle bundleForClass:[self class]]];
    NSArray *array = [adNib instantiateWithOwner:self options:nil];
    self.nativeAdView = [array firstObject];
    
    ANNativeAdView *nativeAdView = self.nativeAdView;
    nativeAdView.titleLabel.text = self.adResponse.title;
    nativeAdView.bodyLabel.text = self.adResponse.body;
    nativeAdView.iconImageView.image = self.adResponse.iconImage;
    nativeAdView.mainImageView.image = self.adResponse.mainImage;
    [nativeAdView.callToActionButton setTitle:self.adResponse.callToAction forState:UIControlStateNormal];
    
    UIViewController *rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rvc.view addSubview:nativeAdView];
    
    NSError *registerError;
    [self.adResponse registerViewForTracking:nativeAdView
                      withRootViewController:rvc
                              clickableViews:@[nativeAdView.callToActionButton]
                                       error:&registerError];
    XCTAssertNil(registerError);
    
    [tester waitForTimeInterval:2.0];
    [tester tapViewWithAccessibilityLabel:@"ANNativeAdViewCallToAction"];
    [tester waitForTimeInterval:2.0];
    XCTAssertNotNil(rvc.presentedViewController);
    [rvc dismissViewControllerAnimated:YES completion:nil];
    [tester waitForTimeInterval:3.0];
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
    XCTAssertTrue([self.adResponse.mainImageURL.absoluteString containsString:@"rlissack.adnxs.net"]);
    XCTAssertNotNil(self.adResponse.iconImage);
    XCTAssertNotNil(self.adResponse.mainImage);
    
    XCTAssertTrue([self.adResponse.iconImage isKindOfClass:[UIImage class]]);
    XCTAssertTrue([self.adResponse.mainImage isKindOfClass:[UIImage class]]);
    
    UINib *adNib = [UINib nibWithNibName:@"ANNativeAdViewMainImage" bundle:[NSBundle bundleForClass:[self class]]];
    NSArray *array = [adNib instantiateWithOwner:self options:nil];
    self.nativeAdView = [array firstObject];
    
    ANNativeAdView *nativeAdView = self.nativeAdView;
    nativeAdView.titleLabel.text = self.adResponse.title;
    nativeAdView.bodyLabel.text = self.adResponse.body;
    nativeAdView.iconImageView.image = self.adResponse.iconImage;
    nativeAdView.mainImageView.image = self.adResponse.mainImage;
    [nativeAdView.callToActionButton setTitle:self.adResponse.callToAction forState:UIControlStateNormal];
    
    UIViewController *rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rvc.view addSubview:nativeAdView];
    
    NSError *registerError;
    [self.adResponse registerViewForTracking:nativeAdView
                      withRootViewController:rvc
                              clickableViews:@[nativeAdView.callToActionButton]
                                       error:&registerError];
    XCTAssertNil(registerError);
    
    [tester waitForTimeInterval:2.0];
    [tester tapViewWithAccessibilityLabel:@"ANNativeAdViewCallToAction"];
    [tester waitForTimeInterval:2.0];
    XCTAssertNotNil(rvc.presentedViewController);
    [rvc dismissViewControllerAnimated:YES completion:nil];
    [tester waitForTimeInterval:3.0];
}

- (void)testAppNexusWithMultipleTrackers {
    [self stubRequestWithResponse:@"appnexus_multiple_trackers"];
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestLoaded:)
                                                 name:kANHTTPStubURLProtocolRequestDidLoadNotification
                                               object:nil];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);
    XCTAssertNotNil(self.adResponse.iconImage);
    XCTAssertNil(self.adResponse.mainImage);
    
    ANNativeAdView *nativeAdView = self.nativeAdView;
    nativeAdView.titleLabel.text = self.adResponse.title;
    nativeAdView.bodyLabel.text = self.adResponse.body;
    nativeAdView.iconImageView.image = self.adResponse.iconImage;
    [nativeAdView.callToActionButton setTitle:self.adResponse.callToAction forState:UIControlStateNormal];
    
    UIViewController *rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rvc.view addSubview:nativeAdView];
    
    NSError *registerError;
    [self.adResponse registerViewForTracking:nativeAdView
                      withRootViewController:rvc
                              clickableViews:@[nativeAdView.callToActionButton]
                                       error:&registerError];
    XCTAssertNil(registerError);
    
    ANNativeStandardAdResponse *standardResponse = (ANNativeStandardAdResponse *)self.adResponse;
    XCTAssertEqual(standardResponse.impTrackers.count, 3);
    XCTAssertEqual(standardResponse.clickTrackers.count, 4);
    
    self.impressionTrackers = [standardResponse.impTrackers mutableCopy];
    self.clickTrackers = [standardResponse.clickTrackers mutableCopy];
    
    [tester waitForTimeInterval:2.0];
    XCTAssertEqual(self.impressionTrackers.count, 0);
    
    self.adResponse.landingPageLoadsInBackground = NO;
    [tester tapViewWithAccessibilityLabel:@"ANNativeAdViewCallToAction"];
    [tester waitForViewWithAccessibilityLabel:@"In App Browser"];
    [tester waitForTimeInterval:2.0];
    XCTAssertEqual(self.clickTrackers.count, 0);
    
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester waitForTimeInterval:3.0];
}

- (void)testMoPubWithIconImageLoad {
    [self stubRequestWithResponse:@"mopub_mediated_response"];
    [self.adRequest loadAd];
    self.adRequest.shouldLoadIconImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertTrue(self.successfulAdCall);
    XCTAssertNil(self.adRequestError);
    
    ANNativeAdView *nativeAdView = self.nativeAdView;
    nativeAdView.titleLabel.text = self.adResponse.title;
    nativeAdView.bodyLabel.text = self.adResponse.body;
    nativeAdView.iconImageView.image = self.adResponse.iconImage;
    [nativeAdView.callToActionButton setTitle:self.adResponse.callToAction forState:UIControlStateNormal];
    
    UIViewController *rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rvc.view addSubview:nativeAdView];
    
    NSError *registerError;
    [self.adResponse registerViewForTracking:nativeAdView
                      withRootViewController:rvc
                              clickableViews:@[nativeAdView.callToActionButton]
                                       error:&registerError];
    XCTAssertNil(registerError);

    [tester waitForTimeInterval:2.0];
    [tester tapViewWithAccessibilityLabel:@"ANNativeAdViewCallToAction"];
    [tester waitForTimeInterval:2.0];
    XCTAssertNotNil(rvc.presentedViewController);
    [rvc dismissViewControllerAnimated:YES completion:nil];
    [tester waitForTimeInterval:3.0];
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
    
    ANNativeAdView *nativeAdView = self.nativeAdView;
    nativeAdView.titleLabel.text = self.adResponse.title;
    nativeAdView.bodyLabel.text = self.adResponse.body;
    nativeAdView.iconImageView.image = self.adResponse.iconImage;
    [nativeAdView.callToActionButton setTitle:self.adResponse.callToAction forState:UIControlStateNormal];
    
    UIViewController *rvc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rvc.view addSubview:nativeAdView];
    
    NSError *registerError;
    [self.adResponse registerViewForTracking:nativeAdView
                      withRootViewController:rvc
                              clickableViews:@[nativeAdView.callToActionButton]
                                       error:&registerError];
    XCTAssertNil(registerError);
    
    [tester waitForTimeInterval:2.0];

    if ([[UIScreen mainScreen] respondsToSelector:@selector(coordinateSpace)]) {
        [tester tapViewWithAccessibilityLabel:@"ANNativeAdViewCallToAction"];
        [tester waitForTimeInterval:2.0];
        XCTAssertNotNil(rvc.presentedViewController);
        [rvc dismissViewControllerAnimated:YES completion:nil];
        [tester waitForTimeInterval:3.0];
    }
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

@end
