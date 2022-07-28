/*   Copyright 2020 APPNEXUS INC
 
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
#import "ANBannerAdView.h"
#import "ANInterstitialAd.h"
#import "ANNativeAdRequest.h"
#import "ANNativeAdResponse.h"
#import "ANHTTPStubbingManager.h"
#import "NSURLRequest+HTTPBodyTesting.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANGlobal.h"
#import "XandrAd.h"
#define kAppNexusCSMTimeoutInterval 6.0


@interface ANAdMediationTimeoutTestCase : XCTestCase <ANBannerAdViewDelegate, ANInterstitialAdDelegate , ANNativeAdRequestDelegate,ANNativeAdDelegate>

@property (nonatomic,readwrite,strong) ANNativeAdRequest *nativeAdRequest;
@property (nonatomic,readwrite,strong) ANNativeAdResponse *nativeAdResponse;

@property (nonatomic, readwrite, strong) ANBannerAdView *banner;
@property (strong, nonatomic) ANInterstitialAd *interstitialAd;


@property (nonatomic, strong) XCTestExpectation *mediationBannerRespectTimeoutFail;
@property (nonatomic, strong) XCTestExpectation *mediationInterstitialRespectTimeoutFail;
@property (nonatomic, strong) XCTestExpectation *mediationNativeRespectTimeoutFail;

@end

@implementation ANAdMediationTimeoutTestCase

- (void)setUp {
    
    [self clearObject];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];
}
-(void)loadNativeAd{
    
    self.nativeAdRequest= [[ANNativeAdRequest alloc] init];
    self.nativeAdRequest.placementId = @"1";
    self.nativeAdRequest.delegate = self;
    [self.nativeAdRequest loadAd];
}

- (void)loadBannerAd {
    
    // Make a banner ad view.
    self.banner = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 50) placementId:@"1" adSize:CGSizeMake(320, 50)];
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.banner];
    
    self.banner.delegate = self;
    [self.banner loadAd];
    
}


- (void)loadInterstitialAd {
    
    self.interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:@"1"];
    self.interstitialAd.delegate = self;
    [self.interstitialAd loadAd];
    
}

- (void)testCSMBannerRespectTimeoutFail{
    
    __block BOOL isTimeoutOver = NO;
    [self stubRequestWithResponse:@"timeout_banner"];
    self.mediationBannerRespectTimeoutFail = [self expectationWithDescription:@"Didn't receive CSM Banner Ad Fail"];
    [self loadBannerAd];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, ((kAppNexusCSMTimeoutInterval + 1) * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        isTimeoutOver = YES;
        
    });
    
    
    [self waitForExpectationsWithTimeout:kAppNexusCSMTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    XCTAssertFalse(isTimeoutOver);
    
}

- (void)testCSMInterstitialRespectTimeoutFail{
    __block BOOL isTimeoutOver = NO;
    
    [self stubRequestWithResponse:@"timeout_interstiatal"];
    self.mediationInterstitialRespectTimeoutFail = [self expectationWithDescription:@"Didn't receive CSM Interstitial Ad Fail"];
    [self loadInterstitialAd];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, ((kAppNexusCSMTimeoutInterval +1) * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        
        isTimeoutOver = YES;
        
    });
    
    [self waitForExpectationsWithTimeout:kAppNexusCSMTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    XCTAssertFalse(isTimeoutOver);
    
}

- (void)testCSMNativeRespectTimeoutFail{
    
    __block BOOL isTimeoutOver = NO;
    
    [self stubRequestWithResponse:@"timeout_native"];
    self.mediationNativeRespectTimeoutFail = [self expectationWithDescription:@"Didn't receive CSM Native Ad Fail"];
    [self loadNativeAd];
    
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, ((kAppNexusCSMTimeoutInterval +1) * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        isTimeoutOver = YES;
        
        
    });
    
    [self waitForExpectationsWithTimeout:kAppNexusCSMTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
    XCTAssertFalse(isTimeoutOver);
}


- (void)testCSMBannerRespectTimeoutFailOver{
    
    __block BOOL isTimeoutOver = NO;
    [self stubRequestWithResponse:@"timeout_banner_over"];
    self.mediationBannerRespectTimeoutFail = [self expectationWithDescription:@"Didn't receive CSM Banner Ad Fail due to Timeout Over"];
    [self loadBannerAd];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, ((kAppNexusCSMTimeoutInterval + 1) * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        isTimeoutOver = YES;
        
    });
    
    
    [self waitForExpectationsWithTimeout:kAppNexusCSMTimeoutInterval*2
                                 handler:^(NSError *error) {
        
    }];
    XCTAssertTrue(isTimeoutOver);
    
}

- (void)testCSMInterstitialRespectTimeoutFailOver{
    __block BOOL isTimeoutOver = NO;
    
    [self stubRequestWithResponse:@"timeout_interstiatal_over"];
    self.mediationInterstitialRespectTimeoutFail = [self expectationWithDescription:@"Didn't receive CSM Interstitial Ad Fail due to Timeout Over"];
    [self loadInterstitialAd];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, ((kAppNexusCSMTimeoutInterval +1) * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        
        isTimeoutOver = YES;
        
    });
    
    [self waitForExpectationsWithTimeout:kAppNexusCSMTimeoutInterval*2
                                 handler:^(NSError *error) {
        
    }];
    XCTAssertTrue(isTimeoutOver);
    
}


- (void)testCSMNativeRespectTimeoutFailOver{
    
    __block BOOL isTimeoutOver = NO;
    
    [self stubRequestWithResponse:@"timeout_native_over"];
    self.mediationNativeRespectTimeoutFail = [self expectationWithDescription:@"Didn't receive CSM Native Ad Fail due to Timeout Over"];
    [self loadNativeAd];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, ((kAppNexusCSMTimeoutInterval +1) * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        isTimeoutOver = YES;
        
        
    });
    
    [self waitForExpectationsWithTimeout:kAppNexusCSMTimeoutInterval*2
                                 handler:^(NSError *error) {
        
    }];
    
    XCTAssertTrue(isTimeoutOver);
}


// SSM Ad

- (void)testSSMBannerRespectTimeoutFail{
    
    __block BOOL isTimeoutOver = NO;
    [self stubRequestWithResponse:@"timeout_ssm"];
    self.mediationBannerRespectTimeoutFail = [self expectationWithDescription:@"Didn't receive SSM Banner Ad Fail"];
    [self loadBannerAd];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, ((kAppNexusCSMTimeoutInterval + 1) * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        isTimeoutOver = YES;
        
    });
    
    
    [self waitForExpectationsWithTimeout:kAppNexusCSMTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    XCTAssertFalse(isTimeoutOver);
    
}


- (void)testSSMBannerRespectTimeoutFailOver{
    
    __block BOOL isTimeoutOver = NO;
    [self stubRequestWithResponse:@"timeout_ssm_over"];
    self.mediationBannerRespectTimeoutFail = [self expectationWithDescription:@"Didn't receive SSM Banner Ad Fail due to Timeout Over"];
    [self loadBannerAd];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, ((kAppNexusCSMTimeoutInterval + 1) * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        
        isTimeoutOver = YES;
        
    });
    
    
    [self waitForExpectationsWithTimeout:kAppNexusCSMTimeoutInterval*2
                                 handler:^(NSError *error) {
        
    }];
    XCTAssertTrue(isTimeoutOver);
    
}

- (void)tearDown {
    [self clearObject];
}

-(void)clearObject{
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANGlobal getKeyWindow].rootViewController.presentedViewController dismissViewControllerAnimated:NO
                                                                                                               completion:nil];
    
    // Clear all expectations for next test
    
    self.banner = nil;
    self.interstitialAd = nil;
    self.nativeAdRequest = nil;
    self.nativeAdResponse = nil;
    
    self.mediationBannerRespectTimeoutFail = nil;
    self.mediationInterstitialRespectTimeoutFail = nil;
    self.mediationNativeRespectTimeoutFail = nil;
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
        [additionalView removeFromSuperview];
    }
    
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

- (void)adDidReceiveAd:(id)ad {
    NSLog(@"Ad did receive ad");
    // No testcase to perfrom Receive Ad
}

- (void)ad:(id)ad requestFailedWithError:(NSError *)error {
    NSLog(@"Ad failed to load: %@", error);
    [self.mediationBannerRespectTimeoutFail fulfill];
    [self.mediationInterstitialRespectTimeoutFail fulfill];

}



- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response
{
    // No testcase to perfrom Receive Ad
}

- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error withAdResponseInfo:(ANAdResponseInfo *)adResponseInfo{
    [self.mediationNativeRespectTimeoutFail fulfill];
}

@end
