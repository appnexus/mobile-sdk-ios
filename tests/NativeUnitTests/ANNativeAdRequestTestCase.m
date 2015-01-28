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
#import "ANNativeAdRequest+ANBaseUrlOverride.h"
#import "ANGlobal.h"

@interface ANNativeAdRequestTestCase : XCTestCase <ANNativeAdRequestDelegate>

@property (nonatomic, readwrite, strong) ANNativeAdRequest *adRequest;
@property (nonatomic, readwrite, strong) XCTestExpectation *delegateCallbackExpectation;
@property (nonatomic, readwrite, assign) BOOL successfulAdCall;
@property (nonatomic, readwrite, strong) ANNativeAdResponse *adResponse;
@property (nonatomic, readwrite, strong) NSError *adRequestError;

@end

@implementation ANNativeAdRequestTestCase

- (void)setUp {
    [super setUp];
    self.adRequest = [[ANNativeAdRequest alloc] init];
    self.adRequest.delegate = self;
}

- (void)tearDown {
    [super tearDown];
    self.adRequest = nil;
    self.delegateCallbackExpectation = nil;
    self.successfulAdCall = NO;
    self.adResponse = nil;
    self.adRequestError = nil;
}

- (void)testAppNexusWithMainImageLoad {
    [self.adRequest loadAdWithBaseUrlString:@"http://rlissack.adnxs.net:8080/jtest/native/appnexus_standard_response.json"];
    self.adRequest.shouldLoadMainImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    [self validateGenericAdResponse];
    XCTAssertEqual(self.adResponse.networkCode, ANNativeAdNetworkCodeAppNexus);
    XCTAssertNil(self.adResponse.iconImage);
    self.adResponse.mainImageURL ? XCTAssertNotNil(self.adResponse.mainImage) : XCTAssertNil(self.adResponse.mainImage);
    self.adResponse.mainImageURL ? XCTAssertTrue([self.adResponse.mainImage isKindOfClass:[UIImage class]]) : nil;
}

- (void)testFacebook {
    [self.adRequest loadAdWithBaseUrlString:@"http://rlissack.adnxs.net:8080/jtest/native/facebook_mediated_response.json"];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    if (self.successfulAdCall) {
        [self validateGenericAdResponse];
        XCTAssertEqual(self.adResponse.networkCode, ANNativeAdNetworkCodeFacebook);
        XCTAssertNil(self.adResponse.iconImage);
        XCTAssertNil(self.adResponse.mainImage);
    } else {
        XCTAssertNotNil(self.adRequestError);
    }
}

- (void)testFacebookWithIconImageLoad {
    [self.adRequest loadAdWithBaseUrlString:@"http://rlissack.adnxs.net:8080/jtest/native/facebook_mediated_response.json"];
    self.adRequest.shouldLoadIconImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    if (self.successfulAdCall) {
        [self validateGenericAdResponse];
        XCTAssertEqual(self.adResponse.networkCode, ANNativeAdNetworkCodeFacebook);
        self.adResponse.iconImageURL ? XCTAssertNotNil(self.adResponse.iconImage) : XCTAssertNil(self.adResponse.iconImage);
        self.adResponse.iconImageURL ? XCTAssertTrue([self.adResponse.iconImage isKindOfClass:[UIImage class]]) : nil;
        XCTAssertNil(self.adResponse.mainImage);
    } else {
        XCTAssertNotNil(self.adRequestError);
    }
}

- (void)testMoPub {
    [self.adRequest loadAdWithBaseUrlString:@"http://rlissack.adnxs.net:8080/jtest/native/mopub_mediated_response.json"];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    if (self.successfulAdCall) {
        [self validateGenericAdResponse];
        XCTAssertEqual(self.adResponse.networkCode, ANNativeAdNetworkCodeMoPub);
        XCTAssertNil(self.adResponse.iconImage);
        XCTAssertNil(self.adResponse.mainImage);
    } else {
        XCTAssertNotNil(self.adRequestError);
    }
}

- (void)testInvalidMediationAdapter {
    [self.adRequest loadAdWithBaseUrlString:@"http://rlissack.adnxs.net:8080/jtest/native/custom_adapter_mediated_response.json"];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertFalse(self.successfulAdCall);
    XCTAssertNotNil(self.adRequestError);
}

- (void)testWaterfallMediationAdapterEndingInFacebook {
    [self.adRequest loadAdWithBaseUrlString:@"http://rlissack.adnxs.net:8080/jtest/native/custom_adapter_fb_mediated_response.json"];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    if (self.successfulAdCall) {
        [self validateGenericAdResponse];
        XCTAssertEqual(self.adResponse.networkCode, ANNativeAdNetworkCodeFacebook);
        XCTAssertNil(self.adResponse.iconImage);
        XCTAssertNil(self.adResponse.mainImage);
    } else {
        XCTAssertNotNil(self.adRequestError);
    }
}

- (void)testNoResponse {
    [self.adRequest loadAdWithBaseUrlString:@"http://rlissack.adnxs.net:8080/jtest/native/empty_response.json"];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertFalse(self.successfulAdCall);
    XCTAssertNotNil(self.adRequestError);
}

- (void)testCustomAdapterFailToStandardResponse {
    [self.adRequest loadAdWithBaseUrlString:@"http://rlissack.adnxs.net:8080/jtest/native/custom_adapter_to_standard_response.json"];
    self.adRequest.shouldLoadMainImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    [self validateGenericAdResponse];
    XCTAssertEqual(self.adResponse.networkCode, ANNativeAdNetworkCodeAppNexus);
    XCTAssertNil(self.adResponse.iconImage);
    self.adResponse.mainImageURL ? XCTAssertNotNil(self.adResponse.mainImage) : XCTAssertNil(self.adResponse.mainImage);
    self.adResponse.mainImageURL ? XCTAssertTrue([self.adResponse.mainImage isKindOfClass:[UIImage class]]) : nil;
}

- (void)testCustomAdapterFailToNativeAd {
    [self.adRequest loadAdWithBaseUrlString:@"http://rlissack.adnxs.net:8080/jtest/native/custom_adapter_to_native_ad.json"];
    self.adRequest.shouldLoadMainImage = YES;
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    [self validateGenericAdResponse];
    XCTAssertEqual(self.adResponse.networkCode, ANNativeAdNetworkCodeAppNexus);
    XCTAssertNil(self.adResponse.iconImage);
    self.adResponse.mainImageURL ? XCTAssertNotNil(self.adResponse.mainImage) : XCTAssertNil(self.adResponse.mainImage);
    self.adResponse.mainImageURL ? XCTAssertTrue([self.adResponse.mainImage isKindOfClass:[UIImage class]]) : nil;
}

- (void)testMediatedResponseInvalidType {
    [self.adRequest loadAdWithBaseUrlString:@"http://rlissack.adnxs.net:8080/jtest/native/custom_adapter_invalid_type.json"];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertFalse(self.successfulAdCall);
    XCTAssertNotNil(self.adRequestError);
}

- (void)testSuccessfulResponseWithNoAds {
    [self.adRequest loadAdWithBaseUrlString:@"http://rlissack.adnxs.net:8080/jtest/native/no_ads_ok_response.json"];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertFalse(self.successfulAdCall);
    XCTAssertNotNil(self.adRequestError);
}

- (void)testMediatedResponseEmptyMediatedAd {
    [self.adRequest loadAdWithBaseUrlString:@"http://rlissack.adnxs.net:8080/jtest/native/empty_mediated_ad_response.json"];
    self.delegateCallbackExpectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertFalse(self.successfulAdCall);
    XCTAssertNotNil(self.adRequestError);
}

- (void)validateGenericAdResponse {
    XCTAssertNotNil(self.adResponse);
    if (self.adResponse.title) {
        XCTAssert([self.adResponse.title isKindOfClass:[NSString class]]);
    }
    if (self.adResponse.body) {
        XCTAssert([self.adResponse.body isKindOfClass:[NSString class]]);
    }
    if (self.adResponse.callToAction) {
        XCTAssert([self.adResponse.body isKindOfClass:[NSString class]]);
    }
    if (self.adResponse.rating) {
        XCTAssert([self.adResponse.rating isKindOfClass:[ANNativeAdStarRating class]]);
    }
    if (self.adResponse.socialContext) {
        XCTAssert([self.adResponse.socialContext isKindOfClass:[NSString class]]);
    }
    if (self.adResponse.mainImageURL) {
        XCTAssert([self.adResponse.mainImageURL isKindOfClass:[NSURL class]]);
    }
    if (self.adResponse.iconImageURL) {
        XCTAssert([self.adResponse.iconImageURL isKindOfClass:[NSURL class]]);
    }
    if (self.adResponse.customElements) {
        XCTAssert([self.adResponse.customElements isKindOfClass:[NSDictionary class]]);
    }
}

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

@end