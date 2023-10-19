/*   Copyright 2017 APPNEXUS INC
 
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
#import "ANBannerAdView+ANTest.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "XCTestCase+ANAdResponse.h"
#import "ANTestGlobal.h"
#import "ANAdFetcher+ANTest.h"
#import "ANRTBVideoAd.h"
#import "ANCSMVideoAd.h"
#import "ANMediatedAd.h"
#import "XandrAd.h"

@interface ANBannerAdViewVideoTestCase : XCTestCase<ANBannerAdViewDelegate>
@property (nonatomic, readwrite, strong)  ANBannerAdView        *banner;
@property (nonatomic, strong) XCTestExpectation *loadAdSuccesfulException;
@end

@implementation ANBannerAdViewVideoTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // Init here if not the tests will crash
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self clearSetupBannerVideoAd];
}


- (void)clearSetupBannerVideoAd {
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    self.banner.delegate = nil;
    self.banner.appEventDelegate = nil;
    [self.banner removeFromSuperview];
    self.banner = nil;
    self.loadAdSuccesfulException = nil;
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
        [additionalView removeFromSuperview];
    }
}

-(void) setupBannerVideoAd{
    [self clearSetupBannerVideoAd];
    
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    self.banner = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)
                                            placementId:@"9887537"
                                                 adSize:CGSizeMake(300, 250)];
    self.banner.accessibilityLabel = @"AdView";
    self.banner.autoRefreshInterval = 0;
    self.banner.delegate = self;
    self.banner.shouldAllowVideoDemand =  YES;
    self.banner.portraitBannerVideoPlayerSize = CGSizeMake(320, 400);
    self.banner.landscapeBannerVideoPlayerSize = CGSizeMake(330, 250);
    self.banner.squareBannerVideoPlayerSize = CGSizeMake(200, 200);
    self.banner.rootViewController = [ANGlobal getKeyWindow].rootViewController;
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.banner];
}

-(void) setupBannerNativeAd{
    [self clearSetupBannerVideoAd];
    
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    self.banner = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)
                                            placementId:@"9887537"
                                                 adSize:CGSizeMake(300, 250)];
    self.banner.accessibilityLabel = @"AdView";
    self.banner.autoRefreshInterval = 0;
    self.banner.delegate = self;
    self.banner.shouldAllowNativeDemand =  YES;
    self.banner.portraitBannerVideoPlayerSize = CGSizeMake(320, 400);
    self.banner.landscapeBannerVideoPlayerSize = CGSizeMake(330, 250);
    self.banner.squareBannerVideoPlayerSize = CGSizeMake(200, 200);
    self.banner.rootViewController = [ANGlobal getKeyWindow].rootViewController;
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.banner];
}

-(void) setupBannerAd{
    [self clearSetupBannerVideoAd];
    
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    self.banner = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)
                                            placementId:@"9887537"
                                                 adSize:CGSizeMake(300, 250)];
    self.banner.accessibilityLabel = @"AdView";
    self.banner.autoRefreshInterval = 0;
    self.banner.delegate = self;
    self.banner.portraitBannerVideoPlayerSize = CGSizeMake(320, 400);
    self.banner.landscapeBannerVideoPlayerSize = CGSizeMake(330, 250);
    self.banner.squareBannerVideoPlayerSize = CGSizeMake(200, 200);
    self.banner.rootViewController = [ANGlobal getKeyWindow].rootViewController;
    [[ANGlobal getKeyWindow].rootViewController.view addSubview:self.banner];
}

#pragma mark - Test methods.



// Checks to see if  AllowedMediaType is correct for a RTBVideo ad served in a ANBannerAdView
// Checks to see if  creativeID is set properly for RTBVideo ad served in a ANBannerAdView
// Checks to see if  ANMRAIDContainerView is the constructed view for RTBVideo ad served in a ANBannerAdView
- (void) testBannerVideo
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"SuccessfulOutstreamBannerVideoResponse"];
    [self.banner loadAd];
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqual(self.banner.adResponseInfo.adType , ANAdTypeVideo);
   XCTAssertEqualObjects(self.banner.adResponseInfo.creativeId, @"65588716");
    XCTAssert([self.banner.adFetcher.adView isKindOfClass:[ANMRAIDContainerView class]]);
}



// Checks to see if creativeId is not present in /ut response then it doesnot crash the app
- (void)testBannerVideoWithoutCreativeId {
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"SuccessfulANRTBVideoAdWithoutCreativeIdResponse"];
    [self.banner loadAd];
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqual(self.banner.adResponseInfo.creativeId.length, 0);
}


// Checks to see if  ANAllowedMediaTypeBanner for a RTB HTML ad served in a ANBannerAdView
// Checks to see if  creativeID is set properly for RTB HTML ad served in a ANBannerAdView
// Checks to see if  ANMRAIDContainerView is the constructed view for RTB HTML ad served in a ANBannerAdView
- (void)testRTBHTMLBanner {
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"SuccessfulStandardAdFromRTBObjectResponse"];
    XCTAssertNil(self.banner.adFetcher.adView);
    [self.banner loadAd];
    
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    
    XCTAssertNotNil(self.banner.adFetcher.adView);
    XCTAssert([self.banner.adFetcher.adView isKindOfClass:[ANMRAIDContainerView class]]);

    // Make sure AdView frame widh and heigh are proper. Portrait/Landscape/Square sizes should not be used for Banner
    XCTAssertEqual(self.banner.adFetcher.adView.frame.size.width,300);
    XCTAssertEqual(self.banner.adFetcher.adView.frame.size.height,250);
    // Make sure LoadAdSize widh and heigh are proper. Portrait/Landscape/Square sizes should not be used for Banner
    XCTAssertEqual(self.banner.loadedAdSize.width, 300);
    XCTAssertEqual(self.banner.loadedAdSize.height, 250);

   XCTAssertEqual(self.banner.adResponseInfo.adType, ANAdTypeBanner);
   XCTAssertEqualObjects(self.banner.adResponseInfo.creativeId, @"6332753");
}


// Checks to see if RTB video ad is parsed properly
- (void)testRTBVideoAd {
    NSMutableArray<id>  *adsArray    = [self adsArrayFromFirstTagInJSONResource:@"SuccessfulOutstreamBannerVideoResponse"];
    ANRTBVideoAd        *rtbVideoAd  = [adsArray firstObject];

    XCTAssertNotNil(rtbVideoAd.notifyUrlString);
    XCTAssert([rtbVideoAd.width isEqualToString:@"300"]);
    XCTAssert([rtbVideoAd.height isEqualToString:@"250"]);
    XCTAssertNotNil(rtbVideoAd.content);
    XCTAssertNotNil(rtbVideoAd.creativeId);
    XCTAssertEqualObjects(rtbVideoAd.creativeId, @"65588716");
}



// Checks for if the AllowedMediaType is correct for a RTBVideo ad served after SDK Mediation failed.
// This also act as a test for checking waterfall logic is working correctly for Video case.
// If the SDK Mediation was succesful then mediaType should have been banner which is false in this case and it is video.
- (void) testadSDKMediationFailVideoSuccessCase
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"BannerMediationFailRTBVideoSuccess"];
    [self.banner loadAd];
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
   XCTAssertEqual(self.banner.adResponseInfo.adType, ANAdTypeVideo);
    XCTAssertEqualObjects(self.banner.adResponseInfo.creativeId, @"65588716");
    XCTAssert([self.banner.adFetcher.adObjectHandler isKindOfClass:[ANRTBVideoAd class]]);
    XCTAssert(![self.banner.adFetcher.adObjectHandler isKindOfClass:[ANCSMVideoAd class]]);
}



- (void) testBannerVideoVerticalOrientation
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"SuccessfulVerticalVideoAdResponse"];
    [self.banner loadAd];
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqual(self.banner.adResponseInfo.adType , ANAdTypeVideo);
    XCTAssertEqual(self.banner.getVideoOrientation, ANPortrait);
    
    // Make sure AdView frame widh and heigh are proper. portraitBannerVideoPlayerSize should be used for Vertical Videos
    XCTAssertEqual(self.banner.adFetcher.adView.frame.size.width,320);
    XCTAssertEqual(self.banner.adFetcher.adView.frame.size.height,400);
    // Make sure LoadAdSize widh and heigh are proper.  portraitBannerVideoPlayerSize should be used for Vertical Videos
    XCTAssertEqual(self.banner.loadedAdSize.width, 320);
    XCTAssertEqual(self.banner.loadedAdSize.height, 400);
}


- (void) testBannerVideoLandscapeOrientation
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"SuccessfulInstreamVideoAdResponse"];
    [self.banner loadAd];
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqual(self.banner.adResponseInfo.adType , ANAdTypeVideo);
    XCTAssertEqual(self.banner.getVideoOrientation, ANLandscape);
    
    // Make sure AdView frame widh and heigh are proper. landscapeBannerVideoPlayerSize should be used for Vertical Videos
    XCTAssertEqual(self.banner.adFetcher.adView.frame.size.width,330);
    XCTAssertEqual(self.banner.adFetcher.adView.frame.size.height,250);
    // Make sure LoadAdSize widh and heigh are proper.  landscapeBannerVideoPlayerSize should be used for Vertical Videos
    XCTAssertEqual(self.banner.loadedAdSize.width, 330);
    XCTAssertEqual(self.banner.loadedAdSize.height, 250);
}


- (void) testBannerVideoSquareOrientation
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"SuccessfulSquareInstreamVideoAdResponse"];
    [self.banner loadAd];
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqual(self.banner.adResponseInfo.adType , ANAdTypeVideo);
    XCTAssertEqual(self.banner.getVideoOrientation, ANSquare);
    // Make sure AdView frame widh and heigh are proper. squareBannerVideoPlayerSize should be used for Vertical Videos
    XCTAssertEqual(self.banner.adFetcher.adView.frame.size.width,200);
    XCTAssertEqual(self.banner.adFetcher.adView.frame.size.height,200);
    // Make sure LoadAdSize widh and heigh are proper.  squareBannerVideoPlayerSize should be used for Vertical Videos
    XCTAssertEqual(self.banner.loadedAdSize.width, 200);
    XCTAssertEqual(self.banner.loadedAdSize.height, 200);
}


- (void) testBannerVideoUnkownOrientation
{
    [self setupBannerVideoAd];
    [self stubRequestWithResponse:@"SuccessfulStandardAdFromRTBObjectResponse"];
    [self.banner loadAd];
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqual(self.banner.getVideoOrientation, ANUnknown);
}

- (void) testBannerNativeUnkownOrientation
{
    [self setupBannerNativeAd];
    [self stubRequestWithResponse:@"SuccessfulStandardAdFromRTBObjectResponse"];
    [self.banner loadAd];
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqual(self.banner.getVideoOrientation, ANUnknown);
}

- (void) testBannerUnkownOrientation
{
    [self setupBannerAd];
    [self stubRequestWithResponse:@"SuccessfulStandardAdFromRTBObjectResponse"];
    [self.banner loadAd];
    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for adDidReceiveAd to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    XCTAssertEqual(self.banner.getVideoOrientation, ANUnknown);
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

#pragma mark - ANAdDelegate

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
    [self.loadAdSuccesfulException fulfill];
}


- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error {
    [self.loadAdSuccesfulException fulfill];

}


@end



