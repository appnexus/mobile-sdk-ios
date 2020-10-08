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
#import "ANUniversalAdFetcher+ANTest.h"
#import "ANInterstitialAd+ANTest.h"
#import "ANNativeAdRequest+ANTest.h"
#import "ANInstreamVideoAd+Test.h"
#import "ANAdView+ANTest.h"
#import "ANTimeTracker.h"





@interface AdPerformanceStatsMARAdTestCase : XCTestCase<ANMultiAdRequestDelegate>
@property (nonatomic, readwrite, strong)            ANMultiAdRequest    *mar;

@property (nonatomic, readwrite, strong)  ANBannerAdView       *bannerAd;
@property (strong, nonatomic) ANInterstitialAd *interstitialAd;
@property (nonatomic,readwrite,strong) ANNativeAdRequest *nativeAdRequest;
@property (strong, nonatomic)  ANInstreamVideoAd  *videoAd;

@property (nonatomic, strong) XCTestExpectation *firstLoadAdResponseReceivedExpectation;
@property (nonatomic, strong) XCTestExpectation *secondLoadAdResponseReceivedExpectation;
@property (nonatomic, strong) NSString *testCase;



@end

@implementation AdPerformanceStatsMARAdTestCase

#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    [self clearCountsAndExpectations];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}


- (void)clearCountsAndExpectations
{
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    
    self.firstLoadAdResponseReceivedExpectation = nil;
    self.secondLoadAdResponseReceivedExpectation = nil;
    
    self.bannerAd = nil;
    self.interstitialAd = nil;
    self.videoAd = nil;
    self.nativeAdRequest = nil;
    self.mar = nil;
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
        [additionalView removeFromSuperview];
    }
}


#pragma mark - Test methods.



-(void)createAllMARCombination {
    self.bannerAd = [self setBannerAdUnit:CGRectMake(0, 50, 320, 50) size:CGSizeMake(320, 50)placement:MAR_PLACEMENT];
    self.bannerAd.forceCreativeId = 223272198;
    self.interstitialAd = [self setInterstitialAdUnit:MAR_PLACEMENT];
    self.interstitialAd.forceCreativeId = 223272198;
    self.nativeAdRequest = [self setNativeAdUnit:NATIVE_PLACEMENT];
    self.nativeAdRequest.forceCreativeId = 135482485;
    self.videoAd = [self setInstreamVideoAdUnit:VIDEO_PLACEMENT];
    self.videoAd.forceCreativeId = 182434863;
    
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId:10094 andDelegate:self];
    
    [self.mar addAdUnit:self.bannerAd];
    [self.mar addAdUnit:self.interstitialAd];
    [self.mar addAdUnit:self.nativeAdRequest];
    [self.mar addAdUnit:self.videoAd];
    
    
    
    [self.mar load];
    
}


-(void)testMAR{
    self.testCase = PERFORMANCESTATSRTBAD_FIRST_REQUEST;
    [self createAllMARCombination];
    [[ANTimeTracker sharedInstance] setTimeAt:PERFORMANCESTATSRTBAD_FIRST_REQUEST];
    
    self.firstLoadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout: kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
    self.testCase = PERFORMANCESTATSRTBAD_SECOND_REQUEST;
    [[ANTimeTracker sharedInstance] getDiffereanceAt:PERFORMANCESTATSRTBAD_SECOND_REQUEST];
    [self createAllMARCombination];
    self.secondLoadAdResponseReceivedExpectation = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout: kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
}



- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self clearCountsAndExpectations];
    
}


#pragma mark - ANAdDelegate
- (void)multiAdRequestDidComplete:(ANMultiAdRequest *)mar{
    NSLog(@"multiAdRequest - multiAdRequestDidComplete");
    
    if( [self.testCase isEqualToString:PERFORMANCESTATSRTBAD_FIRST_REQUEST]){
        
        [[ANTimeTracker sharedInstance] getDiffereanceAt:@"adDidReceiveAd-FirstRequest"];
        
        NSString *adLoadKey = [NSString stringWithFormat:@"%@%@",MAR,PERFORMANCESTATSRTBAD_FIRST_REQUEST];
        [ANTimeTracker saveSet:adLoadKey date:[NSDate date] loadTime:[ANTimeTracker sharedInstance].timeTaken];
        NSLog(@"PerformanceStats RTB %@ - %@",adLoadKey, [ANTimeTracker getData:adLoadKey]);
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTBMARAD_FIRST_LOAD,[ANTimeTracker sharedInstance].timeTaken);
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTB_NETWORK_FIRST_LOAD,[[ANTimeTracker sharedInstance] getTimeTakenByNetworkCall]);
        
        [self.firstLoadAdResponseReceivedExpectation fulfill];
        
    }else if( [self.testCase isEqualToString:PERFORMANCESTATSRTBAD_SECOND_REQUEST]){
        
        [[ANTimeTracker sharedInstance] getDiffereanceAt:@"adDidReceiveAd-SecondRequest"];
        
        NSString *adLoadKey = [NSString stringWithFormat:@"%@%@",MAR,PERFORMANCESTATSRTBAD_SECOND_REQUEST];
        [ANTimeTracker saveSet:adLoadKey date:[NSDate date] loadTime:[ANTimeTracker sharedInstance].timeTaken];
        NSLog(@"PerformanceStats RTB %@ - %@",adLoadKey, [ANTimeTracker getData:adLoadKey]);
        
        XCTAssertGreaterThan(PERFORMANCESTATSRTBMARAD_SECOND_LOAD,[ANTimeTracker sharedInstance].timeTaken);
        XCTAssertGreaterThan(PERFORMANCESTATSRTB_NETWORK_SECOND_LOAD,[[ANTimeTracker sharedInstance] getTimeTakenByNetworkCall]);
        [self.secondLoadAdResponseReceivedExpectation fulfill];
    }
}

- (void)multiAdRequest:(ANMultiAdRequest *)mar didFailWithError:(NSError *)error{
    NSLog(@"multiAdRequest - didFailWithError");
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


-(ANNativeAdRequest *) setNativeAdUnit : (NSString *)placement {
    ANNativeAdRequest *nativeAdRequest= [[ANNativeAdRequest alloc] init];
    nativeAdRequest.placementId = placement;
    nativeAdRequest.shouldLoadIconImage = YES;
    nativeAdRequest.shouldLoadMainImage = YES;
    return nativeAdRequest;
}

-(ANBannerAdView *) setBannerAdUnit:(CGRect)rect  size:(CGSize )size placement:(NSString *)placement  {
    ANBannerAdView* bannerAdView = [[ANBannerAdView alloc] initWithFrame:rect
                                                             placementId:placement
                                                                  adSize:size];
    bannerAdView.rootViewController = [ANGlobal getKeyWindow].rootViewController;
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:bannerAdView];
    return bannerAdView;
}

-(ANInterstitialAd *) setInterstitialAdUnit: (NSString *)placement  {
    ANInterstitialAd *interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:placement];
    return interstitialAd;
}


-(ANInstreamVideoAd *) setInstreamVideoAdUnit: (NSString *)placement  {
    ANInstreamVideoAd* instreamVideoAdUnit = [[ANInstreamVideoAd alloc] initWithPlacementId:placement];
    return instreamVideoAdUnit;
}
@end
