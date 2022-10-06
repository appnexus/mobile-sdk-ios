/*
 *
 *    Copyright 2020 APPNEXUS INC
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import <XCTest/XCTest.h>
#import "ANMultiAdRequest.h"
#import "ANHTTPStubbingManager.h"
#import "ANNativeAdRequest.h"
#import "ANInterstitialAd.h"
#import "ANInstreamVideoAd.h"
#import "ANBannerAdView.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANAdView+PrivateMethods.h"
#import "ANBannerAdView+ANTest.h"
#import "ANAdFetcher+ANTest.h"



@interface ANMARScalingTestCase : XCTestCase <ANMultiAdRequestDelegate, ANBannerAdViewDelegate>

@property (nonatomic, readwrite, strong)            ANMultiAdRequest    *mar;
@property (nonatomic, strong) XCTestExpectation *loadAdResponseReceivedExpectation;

@property (nonatomic, readwrite)  NSInteger  totalAdCount;
@property (nonatomic, readwrite)  NSInteger  currentAdCount;

@property (nonatomic, readwrite)  BOOL  receiveAdSuccess;
@property (nonatomic, readwrite)  BOOL  receiveAdFailure;


@end

@implementation ANMARScalingTestCase

- (void)setUp {
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    self.receiveAdSuccess = NO;
    self.receiveAdFailure = NO;
    
    
     [ANBannerAdView setDoNotResetAdUnitUUID:YES];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    ANSDKSettings.sharedInstance.locationEnabledForCreative = NO;
    self.mar = nil;
    
    [ANBannerAdView setDoNotResetAdUnitUUID:NO];
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
        [additionalView removeFromSuperview];
    }
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testMARCombinationTwelveRTBBanner {
    self.currentAdCount = 0;
    self.totalAdCount = 12;
    self.receiveAdFailure = false;
    [self stubRequestWithResponse:@"testMARCombinationTwelveRTBBanner"];
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId:10094 andDelegate:self];
    for (int i = 1; i <= self.totalAdCount; i++)
    {
        ANBannerAdView *bannerAd1 = [self setBannerAdUnit:CGRectMake(0, 50, 320, 50) size:CGSizeMake(320, 50)placement:@"17982237"];
        bannerAd1.delegate = self;
        bannerAd1.utRequestUUIDString = [NSString stringWithFormat:@"%d",i];
        [self.mar addAdUnit:bannerAd1];
    }
    [self.mar load];
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    XCTAssertTrue(self.receiveAdSuccess);
    XCTAssertFalse(self.receiveAdFailure);

}


- (void)testMARCombinationThirtyCSMBanner {
    self.currentAdCount = 0;
    self.totalAdCount = 30;
    self.receiveAdFailure = false;
    [self stubRequestWithResponse:@"testMARCombinationThirtyCSMBanner"];
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId:10094 andDelegate:self];
    for (int i = 1; i <= self.totalAdCount; i++)
    {
        ANBannerAdView *bannerAd1 = [self setBannerAdUnit:CGRectMake(0, 50, 320, 50) size:CGSizeMake(320, 50)placement:@"17982237"];
        bannerAd1.delegate = self;
        bannerAd1.utRequestUUIDString = [NSString stringWithFormat:@"%d",i];
        [self.mar addAdUnit:bannerAd1];
    }
    [self.mar load];
    self.loadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    XCTAssertTrue(self.receiveAdSuccess);
    XCTAssertFalse(self.receiveAdFailure);
}


- (void)adDidReceiveAd:(id<ANAdProtocol>)ad
{
    self.currentAdCount += 1;
    if(self.currentAdCount == self.totalAdCount){
        self.receiveAdSuccess = true;
        [self.loadAdResponseReceivedExpectation fulfill];
    }
}



- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    self.receiveAdFailure = true;
    [self.loadAdResponseReceivedExpectation fulfill];
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
    requestStub.responseCode  = 200;
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

//Ad Request Builder

-(ANBannerAdView *) setBannerAdUnit:(CGRect)rect  size:(CGSize )size placement:(NSString *)placement  {
    ANBannerAdView* bannerAdView = [[ANBannerAdView alloc] initWithFrame:rect
                                                             placementId:placement
                                                                  adSize:size];
    bannerAdView.rootViewController = [ANGlobal getKeyWindow].rootViewController;
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:bannerAdView];
    return bannerAdView;
}
@end

