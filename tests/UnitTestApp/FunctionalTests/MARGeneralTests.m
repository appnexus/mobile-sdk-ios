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

#import <XCTest/XCTest.h>

#import "MARHelper.h"
#import "ANHTTPStubbingManager.h"

#import "ANMultiAdRequest.h"
#import "ANMultiAdRequest+PrivateMethod.h"
#import "ANAdView+PrivateMethods.h"
#import "ANBannerAdView+ANTest.h"
#import "ANInterstitialAd+ANTest.h"
#import "ANNativeAdRequest+ANTest.h"
#import "ANInstreamVideoAd+Test.h"
#import "ANAdFetcher+ANTest.h"

#import "ANAdViewInternalDelegate.h"
#import "XandrAd.h"


#pragma mark - Global private constants.

static NSString  *kLocalScope   = @"Scope is LOCAL.";
static NSString  *kGlobalScope  = @"Scope is GLOBAL.";




#pragma mark -

@interface MARGeneralTests : XCTestCase <ANMultiAdRequestDelegate, ANBannerAdViewDelegate, ANInstreamVideoAdLoadDelegate, ANNativeAdRequestDelegate>

@property (nonatomic, readwrite, strong, nullable)  MARAdUnits          *adUnitsForTest;
@property (nonatomic, readwrite, strong)            ANMultiAdRequest    *mar;
@property (nonatomic, readwrite, strong)            ANMultiAdRequest    *mar2;


@property (nonatomic, readwrite, strong)  ANBannerAdView       *bannerAd1;
@property (nonatomic, readwrite, strong)  ANBannerAdView        *bannerAd2;


@property (nonatomic, strong) XCTestExpectation *loadAdResponseReceivedExpectation;
@property (nonatomic, strong) XCTestExpectation *loadAdResponseFailedExpectation;

@property (strong, nonatomic) ANInterstitialAd *interstitialAd1;

@property (nonatomic,readwrite,strong) ANNativeAdRequest *nativeAdRequest1;
@property (nonatomic,readwrite,strong) ANNativeAdResponse *nativeAdResponse1;

@property (strong, nonatomic)  ANInstreamVideoAd  *videoAd1;

//
@property (nonatomic, readwrite)  NSUInteger  MAR_countOfCompletionSuccesses;
@property (nonatomic, readwrite)  NSUInteger  MAR_countOfCompletionFailures;
@property (nonatomic, readwrite)  NSUInteger  AdUnit_countOfReceiveSuccesses;
@property (nonatomic, readwrite)  NSUInteger  AdUnit_countOfReceiveFailures;

@property (nonatomic, strong, readwrite, nullable)  XCTestExpectation  *expectationMARLoadCompletionOrFailure;
@property (nonatomic, strong, readwrite, nullable)  XCTestExpectation  *expectationAdUnitLoadResponseOrFailure;
@property (nonatomic, strong, readwrite, nullable)  XCTestExpectation  *expectationBackgroundBlockIsComplete;

@property (nonatomic, readwrite)  NSUInteger  countOfRequestedAdUnits;

@property (nonatomic, strong, readwrite, nullable)  XCTestExpectation  *expectationAdUnitLoadStop;

@end




#pragma mark -

@implementation MARGeneralTests

#pragma mark Test lifecycle.

- (void)setUp
{
    [super setUp];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    TMARK();
    
    self.adUnitsForTest = [[MARAdUnits alloc] initWithDelegate:self];
    
    [ANBannerAdView setDoNotResetAdUnitUUID:YES];
    [ANInterstitialAd setDoNotResetAdUnitUUID:YES];
    [ANNativeAdRequest setDoNotResetAdUnitUUID:YES];
    [ANInstreamVideoAd setDoNotResetAdUnitUUID:YES];
    
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];

}

- (void)clearCountsAndExpectations
{
    
    [ANBannerAdView setDoNotResetAdUnitUUID:NO];
    [ANInterstitialAd setDoNotResetAdUnitUUID:NO];
    [ANNativeAdRequest setDoNotResetAdUnitUUID:NO];
    [ANInstreamVideoAd setDoNotResetAdUnitUUID:NO];
    self.MAR_countOfCompletionSuccesses     = 0;
    self.MAR_countOfCompletionFailures      = 0;
    self.AdUnit_countOfReceiveSuccesses     = 0;
    self.AdUnit_countOfReceiveFailures      = 0;
    
    self.expectationMARLoadCompletionOrFailure = nil;
    self.expectationAdUnitLoadResponseOrFailure = nil;
    self.expectationAdUnitLoadStop = nil;

    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    self.mar = nil;
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
        [additionalView removeFromSuperview];
    }
}

- (void)tearDown
{
    [super tearDown];
    [self clearCountsAndExpectations];
}




#pragma mark - Tests for ANMultiAdRequest.

- (void)testFetchAndConfirmMultipleAdUnitsWithPassByReference
{
    TMARK();
    [self stubRequestWithResponse:@"testLoadTwoMARInstancesSimultaneously"];
    
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.bannerBanner,
                self.adUnitsForTest.bannerPlusNative,
                self.adUnitsForTest.bannerPlusVideo, nil ];
    
    self.countOfRequestedAdUnits  = 3;
    
    
    self.adUnitsForTest.bannerBanner.utRequestUUIDString = @"1";
    self.adUnitsForTest.bannerPlusNative.utRequestUUIDString = @"2";
    self.adUnitsForTest.bannerPlusVideo.utRequestUUIDString = @"3";

    XCTAssertNotNil(self.mar);
    
    [self.mar load];
    // Wait for MAR load to complete.
    //
    
    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    
    
    
    
    [self waitForExpectationsWithTimeout:3 * kAppNexusRequestTimeoutInterval handler:nil];
    
    XCTAssertEqual(self.MAR_countOfCompletionSuccesses, 1);
    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, self.countOfRequestedAdUnits);
    
    
    
    // Demonstrate objects within MAR instance are references, not deep copies.
    //
    NSPointerArray  *marAdUnits  = [self.mar internalGetAdUnits];
    
    NSMutableArray<NSString *>  *arrayOfAUInternal  = [[NSMutableArray<NSString *> alloc] init];
    NSMutableArray<NSString *>  *arrayOfAUExternal  = [[NSMutableArray<NSString *> alloc] init];
    
    NSUInteger  index  = 0;
    TDEBUG(@"count of marAdUnits:%@ weakAdUnitsArray:%@", @([marAdUnits count]), @(self.countOfRequestedAdUnits));
    
    while (index < self.countOfRequestedAdUnits)
    {
        [arrayOfAUInternal addObject:[NSString stringWithFormat:@"%p", [marAdUnits pointerAtIndex:index]]];
        
        index += 1;
    }
    
    [arrayOfAUExternal addObject:[NSString stringWithFormat:@"%p", self.adUnitsForTest.bannerBanner]];
    [arrayOfAUExternal addObject:[NSString stringWithFormat:@"%p", self.adUnitsForTest.bannerPlusNative]];
    [arrayOfAUExternal addObject:[NSString stringWithFormat:@"%p", self.adUnitsForTest.bannerPlusVideo]];
    
    
    [arrayOfAUInternal sortUsingComparator: ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString  *str1  = (NSString *)obj1;
        NSString  *str2  = (NSString *)obj2;
        
        return  [str1 localizedStandardCompare:str2];
    } ];
    
    [arrayOfAUExternal sortUsingComparator: ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString  *str1  = (NSString *)obj1;
        NSString  *str2  = (NSString *)obj2;
        
        return  [str1 localizedStandardCompare:str2];
    } ];
    
    
    TMARKMESSAGE(@"\n\t\t internal = %@ \n\t\t external = %@", arrayOfAUInternal, arrayOfAUExternal);
    
    XCTAssertEqual([arrayOfAUInternal count], [arrayOfAUExternal count]);
    
    index = 0;
    while (index < [arrayOfAUInternal count])
    {
        XCTAssertTrue([[arrayOfAUInternal objectAtIndex:index] isEqualToString:[arrayOfAUExternal objectAtIndex:index]]);
        index += 1;
    }
     
}

- (void)testFetchAndConfirmAdUnitsForAllMediaTypes
{
    TMARK();
    [self stubRequestWithResponse:@"testMARCombinationAllRTB"];
    
    self.mar = [[ANMultiAdRequest alloc] initAndLoadWithMemberId: self.adUnitsForTest.memberIDGood
                                                        delegate: self
                                                         adUnits: self.adUnitsForTest.bannerBanner,
                                                                  self.adUnitsForTest.interstitial,
                                                                  self.adUnitsForTest.native,
                                                                  self.adUnitsForTest.instreamVideo,
                                                                  nil ];
    self.countOfRequestedAdUnits  = 4;
    self.adUnitsForTest.bannerBanner.utRequestUUIDString = @"1";
    self.adUnitsForTest.interstitial.utRequestUUIDString = @"2";
    self.adUnitsForTest.native.utRequestUUIDString = @"3";
    self.adUnitsForTest.instreamVideo.utRequestUUIDString = @"4";

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    
    XCTAssertNotNil(self.mar);
    
    [self waitForExpectationsWithTimeout: 3 * kAppNexusRequestTimeoutInterval handler:nil];
    
    XCTAssertEqual(self.MAR_countOfCompletionSuccesses, 1);
    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses, self.countOfRequestedAdUnits);
     
}
- (void)testFetchAndStopMARAd
{
    TMARK();
    [self stubRequestWithResponse:@"testMARCombinationAllRTB"];
    
    
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.bannerBanner,
                self.adUnitsForTest.bannerPlusNative,
                self.adUnitsForTest.bannerPlusVideo, nil ];
    self.countOfRequestedAdUnits  = 3;
    
    self.adUnitsForTest.bannerBanner.utRequestUUIDString = @"1";
       self.adUnitsForTest.bannerPlusNative.utRequestUUIDString = @"2";
       self.adUnitsForTest.bannerPlusVideo.utRequestUUIDString = @"3";

    [self.mar load];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.expectationAdUnitLoadStop fulfill];
        self.expectationAdUnitLoadStop = nil;
    });
    
    self.expectationAdUnitLoadStop = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadStop"];
    [self waitForExpectationsWithTimeout:6 * kAppNexusRequestTimeoutInterval handler:nil];

    XCTAssertNotNil(self.mar);
    XCTAssertNotNil(self.mar.adFetcher);
    XCTAssertTrue(self.mar.adFetcher.isFetcherLoading);
    [self.mar stop];
    XCTAssertFalse(self.mar.adFetcher.isFetcherLoading);

}

- (void)testLoadThenReLoad
{
    TMARK();
    [self stubRequestWithResponse:@"testLoadTwoMARInstancesSimultaneously"];
    
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.bannerBanner,
                self.adUnitsForTest.bannerPlusNative,
                self.adUnitsForTest.bannerPlusVideo, nil ];
    self.countOfRequestedAdUnits  = 3;
    self.adUnitsForTest.bannerBanner.utRequestUUIDString = @"1";
       self.adUnitsForTest.bannerPlusNative.utRequestUUIDString = @"2";
       self.adUnitsForTest.bannerPlusVideo.utRequestUUIDString = @"3";

    [self.mar load];
    
    
    //
    XCTAssertNotNil(self.mar);
    XCTAssertEqual(self.countOfRequestedAdUnits, self.mar.countOfAdUnits);
    
    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    
    [self waitForExpectationsWithTimeout:6 * kAppNexusRequestTimeoutInterval handler:nil];
    
    XCTAssertEqual(self.MAR_countOfCompletionSuccesses, 1);
    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses, self.countOfRequestedAdUnits);
    
    
    // Reload the same set a second time.
    //
    self.AdUnit_countOfReceiveSuccesses = 0;
    self.MAR_countOfCompletionSuccesses = 0;
    [self.mar load];
    
    
    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    
    [self waitForExpectationsWithTimeout:6 * kAppNexusRequestTimeoutInterval handler:nil];
    
    
    XCTAssertEqual(self.MAR_countOfCompletionSuccesses, 1);
    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses, self.countOfRequestedAdUnits);
     
}

- (void)testLoadThenReLoadWithInventoryCode
{
    TMARK();
    [self stubRequestWithResponse:@"testLoadTwoMARInstancesSimultaneously"];
    
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.bannerBanner,
                self.adUnitsForTest.bannerPlusNative,
                self.adUnitsForTest.bannerPlusVideo, nil ];
    
    self.adUnitsForTest.bannerBanner.utRequestUUIDString = @"1";
       self.adUnitsForTest.bannerPlusNative.utRequestUUIDString = @"2";
       self.adUnitsForTest.bannerPlusVideo.utRequestUUIDString = @"3";

    
    self.countOfRequestedAdUnits  = 3;
    
    [self.mar load];
    
    
    //
    XCTAssertNotNil(self.mar);
    XCTAssertEqual(self.countOfRequestedAdUnits, self.mar.countOfAdUnits);
    
    
    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    
    [self waitForExpectationsWithTimeout:4 * kAppNexusRequestTimeoutInterval handler:nil];
    
    
    XCTAssertEqual(self.MAR_countOfCompletionSuccesses, 1);
    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, self.countOfRequestedAdUnits);
    
    
    // Reload the same set a second time, after changing one AdUnit to search via Inventory Code.
    //
    self.adUnitsForTest.bannerBanner.placementId = 0;
    [self.adUnitsForTest.bannerBanner setInventoryCode:self.adUnitsForTest.inventoryCodeNotredame memberId:self.adUnitsForTest.memberIDGood];
    
    [self.mar load];
    
    self.MAR_countOfCompletionSuccesses = 0;
    self.AdUnit_countOfReceiveSuccesses = 0;
    self.AdUnit_countOfReceiveFailures = 0;
    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    
    [self waitForExpectationsWithTimeout:4 * kAppNexusRequestTimeoutInterval handler:nil];
    
    
    XCTAssertEqual(self.MAR_countOfCompletionSuccesses, 1);
    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, self.countOfRequestedAdUnits);
     
}

- (void)testLoadTwoMARInstancesSimultaneously
{
    TMARK();
    
    [self stubRequestWithResponse:@"testLoadTwoMARInstancesSimultaneously"];
    [self stubRequestWithResponse:@"testLoadTwoMARInstancesSimultaneously"];
    
    
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.bannerBanner,
                nil ];
    
    
    self.adUnitsForTest.bannerBanner.utRequestUUIDString = @"1";

    
    self.mar2 = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                  delegate: self
                                                   adUnits: self.adUnitsForTest.banner,
                                                            nil ];
    
    self.adUnitsForTest.banner.utRequestUUIDString = @"1";

    
    self.countOfRequestedAdUnits  = 2;
    
    [self.mar load];
    [self.mar2 load];
    
    
    //
    XCTAssertNotNil(self.mar);
    XCTAssertNotNil(self.mar2);
    XCTAssertEqual(self.countOfRequestedAdUnits/2, self.mar.countOfAdUnits);
    XCTAssertEqual(self.countOfRequestedAdUnits/2, self.mar2.countOfAdUnits);
    
    
    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];

    [self waitForExpectationsWithTimeout:4 * kAppNexusRequestTimeoutInterval
                                  handler:^(NSError *error) {
         
     }];

    XCTAssertEqual(self.MAR_countOfCompletionSuccesses, 2);
    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, self.countOfRequestedAdUnits);
     
}

- (void)testDropAdUnitThatIsOutOfScopeDuringMARLoad
{
    TMARK();
    [self stubRequestWithResponse:@"testLoadTwoMARInstancesSimultaneously"];
    
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.bannerBanner,
                self.adUnitsForTest.bannerPlusNative,
                self.adUnitsForTest.bannerPlusVideo,
                nil ];
    self.countOfRequestedAdUnits  = 3;
    

    self.adUnitsForTest.bannerBanner.utRequestUUIDString = @"1";
      self.adUnitsForTest.bannerPlusNative.utRequestUUIDString = @"2";
      self.adUnitsForTest.bannerPlusVideo.utRequestUUIDString = @"3";

    
    [self addAdUnitWhileInInnerScopeAndStartMARLoad:self.countOfRequestedAdUnits];
    [self.mar load];
    
    
    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    
    
    [self waitForExpectationsWithTimeout:4 * kAppNexusRequestTimeoutInterval handler:nil];
    
    XCTAssertEqual(self.MAR_countOfCompletionSuccesses, 1);
    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses, self.countOfRequestedAdUnits);
     
}


- (void)testMARSuccessWithAdUnitNoBid
{
    
    
    
    self.bannerAd1 = [self setBannerAdUnit:CGRectMake(0, 50, 320, 50) size:CGSizeMake(320, 50)placement:@"18108595"];
    self.bannerAd1.delegate = self;
    
    self.nativeAdRequest1 = [self setNativeAdUnit:@"18108595"];
    self.nativeAdRequest1.delegate = self;
    
    [self stubRequestWithResponse:@"testMARSuccessWithAdUnitNoBid"];
    
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.bannerAd1,
                self.nativeAdRequest1,
                nil ];
    
    
    
        self.bannerAd1.utRequestUUIDString = @"1";
        self.nativeAdRequest1.utRequestUUIDString = @"2";

    
    
    
    self.countOfRequestedAdUnits  = 2;
    
    XCTAssertNotNil(self.mar);
    
    
    [self.mar load];
    
    
    // Wait for MAR load to complete.
    //
    self.expectationMARLoadCompletionOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationMARLoadCompletionOrFailure"];
    
    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    
    [self waitForExpectationsWithTimeout:3 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
    
    
    
    
    
    
    XCTAssertEqual(self.MAR_countOfCompletionSuccesses, 1);
    
    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, self.countOfRequestedAdUnits);
     
}
//
- (void)testMARFailureWithRequestError
{
    
    
    self.bannerAd1 = [self setBannerAdUnit:CGRectMake(0, 50, 320, 50) size:CGSizeMake(320, 50)placement:@"17982237"];
    self.bannerAd1.delegate = self;
    
    self.nativeAdRequest1 = [self setNativeAdUnit:@"17982237"];
    self.nativeAdRequest1.delegate = self;
    
    
    [self stubRequestWithResponse:@"testMARFailureWithRequestError"];
    
    
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.bannerAd1,
                self.nativeAdRequest1,
                nil ];
    
       self.bannerAd1.utRequestUUIDString = @"1";
       self.nativeAdRequest1.utRequestUUIDString = @"2";

    XCTAssertNotNil(self.mar);
    
    
    BOOL  initialLoadIsSuccessful  = [self.mar load];
    
    XCTAssertTrue(initialLoadIsSuccessful);
    
    
    // Wait for MAR load to complete.
    //
    self.expectationMARLoadCompletionOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationMARLoadCompletionOrFailure"];
    
    [self waitForExpectationsWithTimeout:3 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    XCTAssertEqual(self.MAR_countOfCompletionFailures, 1);
     
}

- (void)testMARSuccessWithSomeAdUnitErrors
{
    
    self.bannerAd1 = [self setBannerAdUnit:CGRectMake(0, 50, 320, 50) size:CGSizeMake(320, 50)placement:@"17982237"];
    self.bannerAd1.delegate = self;
    
    self.nativeAdRequest1 = [self setNativeAdUnit:@"17982237"];
    self.nativeAdRequest1.delegate = self;
    
    
    [self stubRequestWithResponse:@"testMARSuccessWithSomeAdUnitErrors"];
    
    
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.bannerAd1,
                self.nativeAdRequest1,
                nil ];
    
    self.bannerAd1.utRequestUUIDString = @"1";
    self.nativeAdRequest1.utRequestUUIDString = @"2";

    self.countOfRequestedAdUnits  = 2;
    
    XCTAssertNotNil(self.mar);
    
    
    BOOL  initialLoadIsSuccessful  = [self.mar load];
    
    XCTAssertTrue(initialLoadIsSuccessful);
    
    
    // Wait for MAR load to complete.
    //
    
    
    self.expectationMARLoadCompletionOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationMARLoadCompletionOrFailure"];
    
    [self waitForExpectationsWithTimeout:3 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
    XCTAssertEqual(self.MAR_countOfCompletionSuccesses, 1);
    
    
    
    
    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    
    
    [self waitForExpectationsWithTimeout:3 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
    
    
    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, self.countOfRequestedAdUnits);
     
}

// NB  https://en.wikipedia.org/wiki/Sophie_Germain_prime
//

- (void)testAutoRefreshTimerIsDisabledWhenBannerIsAssocia4tedWithMARInstance
{
    TMARK();
    NSUInteger  autoRefreshTimerInterval  = 15;
    
    self.bannerAd1 = [self setBannerAdUnit:CGRectMake(0, 50, 320, 50) size:CGSizeMake(320, 50)placement:@"17982237"];
    self.bannerAd1.delegate = self;
    //
    [self.bannerAd1 setAutoRefreshInterval:0];
    
    XCTAssertNil(self.bannerAd1.adFetcher.autoRefreshTimer);
    
    [self stubRequestWithResponse:@"bannerNative_basic_banner"];
    
    [self.bannerAd1 setAutoRefreshInterval:autoRefreshTimerInterval];
    [self.bannerAd1 loadAd];
    
    self.countOfRequestedAdUnits  = 1;
    
    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:3 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    XCTAssertNotNil(self.bannerAd1.adFetcher.autoRefreshTimer);
    
    [self.bannerAd1.adFetcher stopAutoRefreshTimer];
    
    [self stubRequestWithResponse:@"testMARCombinationSingleBanner"];
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                              andDelegate: self ];
    
    [self.mar addAdUnit:self.bannerAd1];
    self.bannerAd1.utRequestUUIDString = @"1";

    [self.mar load];
    
    self.expectationMARLoadCompletionOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationMARLoadCompletionOrFailure"];
    
    [self waitForExpectationsWithTimeout:3 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
        
    }];
    
    XCTAssertEqual(self.bannerAd1.autoRefreshInterval, autoRefreshTimerInterval);
    XCTAssertNil(self.bannerAd1.adFetcher.autoRefreshTimer);
     
}

// NB  https://en.wikipedia.org/wiki/Sophie_Germain_prime
//

- (void)testAdUnitCompletesNormallyWhenLoadingSimultaneouslyWithMARInstance
{
    TMARK();
    [self stubRequestWithResponse:@"testMARCombinationTwoRTBBanner"];

    
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.bannerBanner,
                nil ];
    
    
    self.adUnitsForTest.bannerBanner.utRequestUUIDString = @"1";

    //
    XCTAssertNil(self.adUnitsForTest.banner.contentView);
    
    self.countOfRequestedAdUnits  = 1;
    
    [self.mar load];
    [self.adUnitsForTest.bannerBanner loadAd];

    self.expectationMARLoadCompletionOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationMARLoadCompletionOrFailure"];
    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    self.expectationAdUnitLoadResponseOrFailure.expectedFulfillmentCount = 1;
    self.expectationAdUnitLoadResponseOrFailure.assertForOverFulfill = NO;
    
    [self waitForExpectationsWithTimeout:3 * kAppNexusRequestTimeoutInterval handler:nil];
    
    
    //
    XCTAssertEqual(self.MAR_countOfCompletionSuccesses, 1);
    XCTAssertTrue((self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures) >= 1);
    
    XCTAssertNotNil(self.adUnitsForTest.bannerBanner.contentView);
     
}


- (void)addAdUnitWhileInInnerScopeAndStartMARLoad:(NSUInteger)currentNumberOfTags
{
    ANBannerAdView  *anotherBanner  = [MARHelper createBannerInstanceWithType: MultiTagTypeBannerBannerOnly
                                                                  placementID: self.adUnitsForTest.pBannerBanner.placementID
                                                                   orMemberID: 0
                                                             andInventoryCode: nil
                                                                 withDelegate: (id<ANBannerAdViewDelegate>)self
                                                        andRootViewController: nil
                                                                        width: self.adUnitsForTest.pBannerBanner.width
                                                                       height: self.adUnitsForTest.pBannerBanner.height
                                                                 labelDetails: nil
                                                          dictionaryKeySuffix: self.adUnitsForTest.pBannerBanner.detailSuffix ];
    
    [self.mar addAdUnit:anotherBanner];
    
    NSDictionary  *jsonBody  = [MARHelper getJSONBodyFromMultiAdRequestInstance:self.mar];
    
    NSInteger  countOfTagsInInnerScope  = [jsonBody[@"tags"] count];
    
    XCTAssertEqual(countOfTagsInInnerScope, currentNumberOfTags + 1);
}



//Ad Request Builder

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

//#pragma mark - ANMultiAdRequestDelegate.
//
- (void)multiAdRequestDidComplete:(ANMultiAdRequest *)mar
{
    TMARK();
    [self.expectationMARLoadCompletionOrFailure fulfill];
    self.expectationMARLoadCompletionOrFailure = nil;
    self.MAR_countOfCompletionSuccesses += 1;
}

- (void)multiAdRequest:(nonnull ANMultiAdRequest *)mar  didFailWithError:(NSError *)error
{
    TMARKMESSAGE(@"%@", error.userInfo);

    [self.expectationMARLoadCompletionOrFailure fulfill];
    self.expectationMARLoadCompletionOrFailure = nil;
    self.MAR_countOfCompletionFailures += 1;
}




#pragma mark - ANAdProtocol.

- (void)adDidReceiveAd:(nonnull id)ad
{
    TINFO(@"%@", [MARHelper adunitDescription:ad]);
    self.AdUnit_countOfReceiveSuccesses += 1;
    
    if(self.countOfRequestedAdUnits == self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures){
        [self.expectationAdUnitLoadResponseOrFailure fulfill];
        self.expectationAdUnitLoadResponseOrFailure = nil;
        
    }
    
    
}

- (void)            ad: (nonnull id)loadInstance
    didReceiveNativeAd: (nonnull id)responseInstance
{
    TINFO(@"%@", [MARHelper adunitDescription:loadInstance]);
    
    self.AdUnit_countOfReceiveSuccesses += 1;
    if(self.countOfRequestedAdUnits == self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures){
        [self.expectationAdUnitLoadResponseOrFailure fulfill];
        self.expectationAdUnitLoadResponseOrFailure = nil;
    }
}


- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error withAdResponseInfo:(ANAdResponseInfo *)adResponseInfo{
    TERROR(@"%@ -- %@", [MARHelper adunitDescription:request], error.userInfo);
    self.AdUnit_countOfReceiveFailures += 1;
    if(self.countOfRequestedAdUnits == self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures){
        [self.expectationAdUnitLoadResponseOrFailure fulfill];
        self.expectationAdUnitLoadResponseOrFailure = nil;
    }
}

- (void)ad:(nonnull id)ad requestFailedWithError:(NSError *)error
{
    TERROR(@"%@ -- %@", [MARHelper adunitDescription:ad], error.userInfo);
    self.AdUnit_countOfReceiveFailures += 1;
    if(self.countOfRequestedAdUnits == self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures){
        [self.expectationAdUnitLoadResponseOrFailure fulfill];
        self.expectationAdUnitLoadResponseOrFailure = nil;
    }
}


- (void)adWasClicked:(nonnull id)ad
{
    TINFO(@"%@", [MARHelper adunitDescription:ad]);
}

- (void)adWasClicked:(nonnull id)ad withURLString:(NSString *)urlString
{
    TINFO(@"%@ -- \"%@\"", [MARHelper adunitDescription:ad], urlString);
}


- (void)adWillClose:(nonnull id)ad
{
    TINFO(@"%@", [MARHelper adunitDescription:ad]);
}

- (void)adDidClose:(nonnull id)ad
{
    TINFO(@"%@", [MARHelper adunitDescription:ad]);
}


- (void)adWillPresent:(nonnull id)ad
{
    TINFO(@"%@", [MARHelper adunitDescription:ad]);
}

- (void)adDidPresent:(nonnull id)ad
{
    TINFO(@"%@", [MARHelper adunitDescription:ad]);
}


- (void)adWillLeaveApplication:(nonnull id)ad
{
    TINFO(@"%@", [MARHelper adunitDescription:ad]);
}




#pragma mark - ANNativeAdRequestDelegate.

- (void)adRequest:(nonnull ANNativeAdRequest *)request didReceiveResponse:(nonnull ANNativeAdResponse *)response
{
    TINFO(@"%@", [MARHelper adunitDescription:request]);
    self.AdUnit_countOfReceiveSuccesses += 1;
    if(self.countOfRequestedAdUnits == self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures){
        [self.expectationAdUnitLoadResponseOrFailure fulfill];
        self.expectationAdUnitLoadResponseOrFailure = nil;
    }
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



@end
