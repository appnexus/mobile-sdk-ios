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
#import "ANGlobal.h"
#import "ANHTTPStubbingManager.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANInstreamVideoAd.h"
#import "ANInterstitialAd.h"
#import "ANInterstitialAd+ANTest.h"
#import "ANNativeAdRequest+ANTest.h"
#import "ANInstreamVideoAd+Test.h"
#import "ANAdView+ANTest.h"
#import "ANMultiAdRequest.h"
#import "ANAdView+PrivateMethods.h"
#import "ANBannerAdView+ANTest.h"
@interface NoNetworkAdFailTestCase : XCTestCase <ANBannerAdViewDelegate , ANNativeAdRequestDelegate ,  ANInstreamVideoAdLoadDelegate,ANInterstitialAdDelegate , ANMultiAdRequestDelegate>
@property (nonatomic, readwrite, strong)  ANBannerAdView        *bannerAd;
@property (nonatomic, strong) XCTestExpectation *failAdExpectationTestcase;

@property (nonatomic, readwrite, strong)  ANInstreamVideoAd      *videoAd;

@property (nonatomic, readwrite, strong)  ANNativeAdRequest     *adRequest;

@property (nonatomic, readwrite, strong)  ANInterstitialAd      *interstitial;
@property (nonatomic, readwrite, strong)            ANMultiAdRequest    *mar;

@end

@implementation NoNetworkAdFailTestCase

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [self clearCountsAndExpectations];
    
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [ANBannerAdView setDoNotResetAdUnitUUID:YES];
    [ANInterstitialAd setDoNotResetAdUnitUUID:YES];
    [ANNativeAdRequest setDoNotResetAdUnitUUID:YES];
    [ANInstreamVideoAd setDoNotResetAdUnitUUID:YES];
}


- (void)clearCountsAndExpectations
{
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    
    self.bannerAd.delegate = nil;
    [self.bannerAd removeFromSuperview];
    self.bannerAd = nil;
    
    
    self.videoAd.loadDelegate = nil;
    [self.videoAd removeFromSuperview];
    self.videoAd = nil;
    
    
    
    self.adRequest.delegate = nil;
    self.adRequest = nil;
    
    
    self.interstitial.delegate = nil;
    self.interstitial = nil;
    self.mar = nil;
    
    [ANBannerAdView setDoNotResetAdUnitUUID:NO];
    [ANInterstitialAd setDoNotResetAdUnitUUID:NO];
    [ANNativeAdRequest setDoNotResetAdUnitUUID:NO];
    [ANInstreamVideoAd setDoNotResetAdUnitUUID:NO];
    
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
    
}
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.bannerAd.delegate = nil;
    self.bannerAd.appEventDelegate = nil;
    [self.bannerAd removeFromSuperview];
    [self clearCountsAndExpectations];
}


- (void)testBannerAd {
    [self stubRequestWithResponse:@"SuccessfulAllowMagicSizeBannerObjectResponse"];
    
    CGRect rect = CGRectMake(0, 0, 300, 250);
    int adWidth  = 300;
    int adHeight = 250;
    CGSize size = CGSizeMake(adWidth, adHeight);
    
    self.bannerAd = [[ANBannerAdView alloc] initWithFrame:rect
                                              placementId:@"19065996"
                                                   adSize:size];
    self.bannerAd.autoRefreshInterval = 0;
    self.bannerAd.delegate = self;
    [self.bannerAd loadAd];
    
    self.failAdExpectationTestcase = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
}



- (void)testVideoAd {
    [self stubRequestWithResponse:@""];
    
    self.videoAd = [[ANInstreamVideoAd alloc] initWithPlacementId:@"19065996"];
    [self.videoAd loadAdWithDelegate:self];
    
    
    self.failAdExpectationTestcase = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
}



- (void)testNativeAd {
    [self stubRequestWithResponse:@""];
    
    self.adRequest = [[ANNativeAdRequest alloc] init];
    self.adRequest.delegate = self;
    [self.adRequest setPlacementId:@"19065996"];
    
    [self.adRequest loadAd];
    self.failAdExpectationTestcase = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
}


- (void)testInterstitialAd {
    [self stubRequestWithResponse:@""];
    
    self.interstitial = [[ANInterstitialAd alloc] init];
    self.interstitial.placementId = @"19065996";
    self.interstitial.delegate = self;
    
    [self.interstitial loadAd];
    self.failAdExpectationTestcase = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
}


-(void)testMAR{
    [self createAllMARCombination:@""];
    
    self.failAdExpectationTestcase = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
    
}



-(void)createAllMARCombination:(NSString *)stubFileName {
    CGRect rect = CGRectMake(0, 0, 300, 250);
    int adWidth  = 300;
    int adHeight = 250;
    CGSize size = CGSizeMake(adWidth, adHeight);
    
    self.bannerAd = [[ANBannerAdView alloc] initWithFrame:rect
                                              placementId:@"19065996"
                                                   adSize:size];
    self.bannerAd.autoRefreshInterval = 0;
    self.bannerAd.delegate = self;
    [self.bannerAd loadAd];
    self.interstitial = [[ANInterstitialAd alloc] init];
    self.interstitial.placementId = @"19065996";
    
    self.interstitial.delegate = self;
    //    self.interstitialAd.delegate = self;
    self.adRequest = [[ANNativeAdRequest alloc] init];
    self.adRequest.delegate = self;
    [self.adRequest setPlacementId:@"19065996"];
    
    self.videoAd = [[ANInstreamVideoAd alloc] initWithPlacementId:@"19065996"];
    [self.videoAd loadAdWithDelegate:self];
    
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId:10094 andDelegate:self];
    
    [self stubRequestWithResponse:stubFileName];
    
    [self.mar addAdUnit:self.bannerAd];
    [self.mar addAdUnit:self.interstitial];
    [self.mar addAdUnit:self.adRequest];
    [self.mar addAdUnit:self.videoAd];
    
    
    
    [self.mar load];
    
}




#pragma mark - ANAdDelegate

- (void)multiAdRequest:(ANMultiAdRequest *)mar didFailWithError:(NSError *)error{
    NSLog(@"multiAdRequest - didFailWithError");
    [self.failAdExpectationTestcase fulfill];
    
}



- (void)adDidReceiveAd:(id)ad
{
    // No need for adDidReceiveAd
}



- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    NSLog(@" Ad Failed to Load");
    [self.failAdExpectationTestcase fulfill];
    
}


- (void)adRequest:(nonnull ANNativeAdRequest *)request didFailToLoadWithError:(nonnull NSError *)error withAdResponseInfo:(nullable ANAdResponseInfo *)adResponseInfo {
    NSLog(@"didFailToLoadWithError");
    [self.failAdExpectationTestcase fulfill];
    
}

- (void)adRequest:(nonnull ANNativeAdRequest *)request didReceiveResponse:(nonnull ANNativeAdResponse *)response {
    NSLog(@"didReceiveResponse");
    
}
#pragma mark - Stubbing

- (void) stubRequestWithResponse:(NSString *)responseName {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *baseResponse = [NSString stringWithContentsOfFile: [currentBundle pathForResource:responseName
                                                                                         ofType:@"json" ]
                                                       encoding: NSUTF8StringEncoding
                                                          error: nil ];
    
    ANURLConnectionStub  *requestStub  = [[ANURLConnectionStub alloc] init];
    
    requestStub.requestURL    = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    requestStub.responseCode  = -1;
    requestStub.responseBody  = baseResponse;
    
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:requestStub];
}

- (void)fulfillExpectation:(XCTestExpectation *)expectation
{
    [expectation fulfill];
}

- (void)waitForTimeInterval:(NSTimeInterval)delay
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    [self performSelector:@selector(fulfillExpectation:) withObject:expectation afterDelay:delay];
    
    [self waitForExpectationsWithTimeout:delay + 1 handler:nil];
}


@end
