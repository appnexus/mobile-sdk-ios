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
#import "ANAdView+PrivateMethods.h"
#import "ANNativeAdRequest.h"
#import "ANMultiAdRequest.h"

#import "ANAdResponseElements.h"



@interface DefaultPlacementLogic : XCTestCase  <ANMultiAdRequestDelegate>

@property (nonatomic, readwrite, strong, nullable)  MARAdUnits              *adUnitsForTest;

@property (nonatomic, readwrite, strong, nullable)  ANAdResponseElements    *adResponseElements;

@property (nonatomic, strong, readwrite, nullable)  ANHTTPStubbingManager   *httpStubManager;


//
@property (nonatomic, readwrite, strong, nullable)  ANMultiAdRequest     *mar;

@property (nonatomic, readwrite, strong, nullable)  ANBannerAdView       *bannerAd1;
@property (nonatomic, readwrite, strong, nullable)  ANNativeAdRequest    *nativeAdRequest1;


//
@property (nonatomic, readwrite)  NSUInteger  MAR_countOfCompletionSuccesses;
@property (nonatomic, readwrite)  NSUInteger  MAR_countOfCompletionFailures;
@property (nonatomic, readwrite)  NSUInteger  AdUnit_countOfReceiveSuccesses;
@property (nonatomic, readwrite)  NSUInteger  AdUnit_countOfReceiveFailures;

@property (nonatomic, strong, readwrite, nullable)  XCTestExpectation  *expectationMARLoadCompletionOrFailure;
@property (nonatomic, strong, readwrite, nullable)  XCTestExpectation  *expectationAdUnitLoadResponseOrFailure;


//
@property (nonatomic, readwrite)          NSUInteger   publisherIDWithNobid;
@property (nonatomic, readwrite, strong)  NSString    *inventoryCodeWithNobidGood;
@property (nonatomic, readwrite, strong)  NSString    *inventoryCodeWithNobidBad;

@property (nonatomic, readwrite, strong)  NSString    *placementIDNobidResponseWhenAllIsCorrect;
@property (nonatomic, readwrite, strong)  NSString    *placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined;
@property (nonatomic, readwrite, strong)  NSString    *placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined;


//@property (nonatomic, readwrite)          NSUInteger   publisherIDWithSuccess;
//@property (nonatomic, readwrite, strong)  NSString    *inventoryCodeWithSuccessGood;
//@property (nonatomic, readwrite, strong)  NSString    *inventoryCodeWithSuccessBad;
//
//@property (nonatomic, readwrite, strong)  NSString    *placementIDSuccessResponseWhenAllIsCorrect;
//@property (nonatomic, readwrite, strong)  NSString    *placementIDSuccessResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined;
//@property (nonatomic, readwrite, strong)  NSString    *placementIDSuccessResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined;
                //FIX -- use these properties.

@property (nonatomic, readwrite)  NSUInteger  publisherIDWeirdMaskedValue;
@end




@implementation DefaultPlacementLogic

- (void)setUp
{
    self.publisherIDWithNobid        = 1456489;
    self.inventoryCodeWithNobidGood  = @"pascal_med_rect";
    self.inventoryCodeWithNobidBad   = @"this_is_a_badInventoryCode";

    self.placementIDNobidResponseWhenAllIsCorrect                                    = @"15712318";
    self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined     = @"15028015";
    self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined  = @"17383879";


//    self.publisherIDWithSuccess        = FIX;
//    self.inventoryCodeWithSuccessGood  = @"FIX";
//    self.inventoryCodeWithSuccessBad   = @"FIX";
//
//    self.placementIDSuccessResponseWhenAllIsCorrect                                    = @"FIX";
//    self.placementIDSuccessResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined     = @"FIX";
//    self.placementIDSuccessResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined  = @"FIX";

    self.publisherIDWeirdMaskedValue = 99009900;

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

- (void)testBannerAdUnitForDefaultTagIDResponseViaNobidWithAndWithoutMAR
{
TMARK();
    self.adUnitsForTest  = [[MARAdUnits alloc] initWithDelegate:self];

    ANBannerAdView  *banner  = self.adUnitsForTest.banner;
    banner.shouldServePublicServiceAnnouncements = NO;



    // ANBannerAdView, receiving nobid, without MAR association.
    //
    [banner setInventoryCode:self.inventoryCodeWithNobidGood memberId:self.adUnitsForTest.memberIDDefault];
    [banner loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([banner.adResponseElements.placementId isEqualToString:self.placementIDNobidResponseWhenAllIsCorrect]);

    //
    [self clearCounters];

    [banner setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [banner loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseElements.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined]);

    //
    [self clearCounters];

    [banner setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [banner setPublisherId:self.publisherIDWithNobid];
    [banner loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseElements.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined]);



    // ANBannerAdView, receiving nobid, associated with MAR, loaded via MAR.
    //
    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                                  delegate: self
                                                   adUnits: banner, nil];

    [self clearCounters];

    [banner setInventoryCode:self.inventoryCodeWithNobidGood memberId:self.adUnitsForTest.memberIDDefault];
    [self.mar load];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseElements.placementId isEqualToString:self.placementIDNobidResponseWhenAllIsCorrect]);

    //
    [self clearCounters];

    [banner setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [self.mar load];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseElements.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined]);

    //
    [self clearCounters];

    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                               publisherId: self.publisherIDWithNobid
                                                  delegate: self
                                                   adUnits: banner, nil];

    [banner setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [self.mar load];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseElements.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined]);



    // ANBannerAdView, receiving nobid, associated with MAR, loaded independently.
    //
    [self clearCounters];

    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                                  delegate: self
                                                   adUnits: banner, nil];

    [banner setInventoryCode:self.inventoryCodeWithNobidGood memberId:self.adUnitsForTest.memberIDDefault];
    [banner loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseElements.placementId isEqualToString:self.placementIDNobidResponseWhenAllIsCorrect]);

    //
    [self clearCounters];

    [banner setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [banner loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseElements.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined]);

    //
    [self clearCounters];

    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                               publisherId: self.publisherIDWithNobid
                                                  delegate: self
                                                   adUnits: banner, nil];

    [banner setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [banner loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseElements.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined]);
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


- (void)ad:(nonnull id)ad requestFailedWithError:(NSError *)error
{
TERROR(@"%@ -- %@", [MARHelper adunitDescription:ad], error.userInfo);

    if ([ad isKindOfClass:[ANAdView class]]) {
        ANAdView  *adview  = (ANAdView *)ad;
        self.adResponseElements = adview.adResponseElements;
    } else {
        ANNativeAdResponse  *nativead  = (ANNativeAdResponse *)ad;
        self.adResponseElements = nativead.adResponseElements;
    }

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
