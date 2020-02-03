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

#import "TestGlobal.h"
#import "MARHelper.h"
#import "ANHTTPStubbingManager.h"

#import "ANBannerAdView.h"
#import "ANNativeAdRequest.h"
#import "ANMultiAdRequest.h"

#import "ANAdResponseElements.h"



@interface DefaultPlacementLogic : XCTestCase

@property (nonatomic, readwrite, strong, nullable)  MARAdUnits          *adUnitsForTest;

@property (nonatomic, readwrite, strong, nullable)            ANMultiAdRequest    *mar;
//@property (nonatomic, readwrite, strong)            ANMultiAdRequest    *mar2;


//
@property (nonatomic, readwrite, strong, nullable)  ANBannerAdView       *bannerAd1;
//@property (nonatomic, readwrite, strong)  ANBannerAdView        *bannerAd2;

//@property (strong, nonatomic) ANInterstitialAd *interstitialAd1;
//
@property (nonatomic, readwrite, strong, nullable) ANNativeAdRequest *nativeAdRequest1;
//@property (nonatomic,readwrite,strong) ANNativeAdResponse *nativeAdResponse1;
//
//@property (strong, nonatomic)  ANInstreamVideoAd  *videoAd1;

@property (strong, nonatomic, nullable)  ANAdResponseElements  *adResponseElements;


//
@property (nonatomic, readwrite)  NSUInteger  MAR_countOfCompletionSuccesses;
@property (nonatomic, readwrite)  NSUInteger  MAR_countOfCompletionFailures;
@property (nonatomic, readwrite)  NSUInteger  AdUnit_countOfReceiveSuccesses;
@property (nonatomic, readwrite)  NSUInteger  AdUnit_countOfReceiveFailures;

//@property (nonatomic, strong) XCTestExpectation *loadAdResponseReceivedExpectation;
//@property (nonatomic, strong) XCTestExpectation *loadAdResponseFailedExpectation;

@property (nonatomic, strong, readwrite, nullable)  XCTestExpectation  *expectationMARLoadCompletionOrFailure;
@property (nonatomic, strong, readwrite, nullable)  XCTestExpectation  *expectationAdUnitLoadResponseOrFailure;
//@property (nonatomic, strong, readwrite, nullable)  XCTestExpectation  *expectationBackgroundBlockIsComplete;
//


//
@property (nonatomic, strong, readwrite, nullable)  ANHTTPStubbingManager  *httpStubManager;
@property (nonatomic, readwrite)  NSUInteger  countOfRequestedAdUnits;


//
@property (nonatomic, readwrite)          NSUInteger   publisherID;
@property (nonatomic, readwrite, strong)  NSString    *inventoryCodeGood;
@property (nonatomic, readwrite, strong)  NSString    *inventoryCodeBad;

@property (nonatomic, readwrite, strong)  NSString    *placementIDResponseWhenAllIsCorrect;
@property (nonatomic, readwrite, strong)  NSString    *placementIDResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined;
@property (nonatomic, readwrite, strong)  NSString    *placementIDResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined;

@end




@implementation DefaultPlacementLogic

- (void)setUp
{
    self.publisherID        = 1456489;
    self.inventoryCodeGood  = @"pascal_med_rect";
    self.inventoryCodeBad   = @"this_is_a_badInventoryCode";

    self.placementIDResponseWhenAllIsCorrect                                    = @"15712318";
    self.placementIDResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined     = @"15028015";
    self.placementIDResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined  = @"17383879";

    //
    self.httpStubManager = [ANHTTPStubbingManager sharedStubbingManager];
    self.httpStubManager.ignoreUnstubbedRequests = YES;
}

- (void)tearDown
{
    [self clearCounters];
}

- (void)clearCounters
{
    self.MAR_countOfCompletionSuccesses     = 0;
    self.MAR_countOfCompletionFailures      = 0;
    self.AdUnit_countOfReceiveSuccesses     = 0;
    self.AdUnit_countOfReceiveFailures      = 0;

    self.expectationMARLoadCompletionOrFailure   = nil;
    self.expectationAdUnitLoadResponseOrFailure  = nil;

    self.adResponseElements = nil;
}



#pragma mark - Tests.

- (void)testBannerAdUnitForDefaultTagIDResponseWithAndWithoutMAR
{
TMARK();
    self.adUnitsForTest  = [[MARAdUnits alloc] initWithDelegate:self];

    ANMultiAdRequest  *mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                                             andDelegate: self ];

    ANBannerAdView  *banner  = self.adUnitsForTest.banner;


    //
    [banner setInventoryCode:self.inventoryCodeGood memberId:self.adUnitsForTest.memberIDDefault];
    [banner loadAd];


    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, 1);
    if (banner.adResponseElements) {
        XCTAssertTrue([banner.adResponseElements.placementId isEqualToString:self.placementIDResponseWhenAllIsCorrect]);

    } else if (self.adResponseElements) {
        XCTAssertTrue([self.adResponseElements.placementId isEqualToString:self.placementIDResponseWhenAllIsCorrect]);

    } else {
        TERROR(@"FAILED to acquire adResponseElements.");
        XCTAssertTrue(false);
    }



    //

    [self clearCounters];
    //    XCTAssertEqual(self.MAR_countOfCompletionSuccesses, 1);



}




#pragma mark - ANMultiAdRequestDelegate.

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
    [self.expectationAdUnitLoadResponseOrFailure fulfill];
}

- (void)            ad: (nonnull id)loadInstance
    didReceiveNativeAd: (nonnull id)responseInstance
{
    TINFO(@"%@", [MARHelper adunitDescription:loadInstance]);

    self.AdUnit_countOfReceiveSuccesses += 1;
    [self.expectationAdUnitLoadResponseOrFailure fulfill];
}


- (void)ad:(nonnull id)ad requestFailedWithError:(NSError *)error andAdResponseElements:(ANAdResponseElements *)adResponseElements
{
TERROR(@"%@ -- %@", [MARHelper adunitDescription:ad], error.userInfo);

    self.adResponseElements = adResponseElements;
    
    self.AdUnit_countOfReceiveFailures += 1;
    [self.expectationAdUnitLoadResponseOrFailure fulfill];
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
    [self.expectationAdUnitLoadResponseOrFailure fulfill];
}

- (void)adRequest:(nonnull ANNativeAdRequest *)request didFailToLoadWithError:(nonnull NSError *)error
{
    TERROR(@"%@ -- %@", [MARHelper adunitDescription:request], error.userInfo);

    self.AdUnit_countOfReceiveFailures += 1;
    [self.expectationAdUnitLoadResponseOrFailure fulfill];
}


@end
