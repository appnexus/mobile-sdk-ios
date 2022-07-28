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

#import "ANAdResponseInfo.h"
#import "XandrAd.h"



@interface DefaultPlacementLogic : XCTestCase  <ANMultiAdRequestDelegate, ANNativeAdRequestDelegate>

@property (nonatomic, readwrite, strong, nullable)  MARAdUnits              *adUnitsForTest;

@property (nonatomic, readwrite, strong, nullable)  ANAdResponseInfo    *adResponseInfo;

@property (nonatomic, strong, readwrite, nullable)  ANHTTPStubbingManager   *httpStubManager;


//
@property (nonatomic, readwrite, strong, nullable)  ANMultiAdRequest     *mar;

@property (nonatomic, readwrite, strong, nullable)  ANNativeAdResponse   *nativeResponse;

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


@end




@implementation DefaultPlacementLogic

- (void)setUp
{
    [super setUp];
    self.adUnitsForTest  = [[MARAdUnits alloc] initWithDelegate:self];

    self.adUnitsForTest.banner.shouldServePublicServiceAnnouncements = NO;


    //
    self.publisherIDWithNobid        = 1456489;
    self.inventoryCodeWithNobidGood  = @"pascal_med_rect";
    self.inventoryCodeWithNobidBad   = @"this_is_a_badInventoryCode";

    self.placementIDNobidResponseWhenAllIsCorrect                                    = @"15712318";
    self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined     = @"15028015";
    self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined  = @"14305745";


    //
    self.httpStubManager = [ANHTTPStubbingManager sharedStubbingManager];
    self.httpStubManager.ignoreUnstubbedRequests = YES;
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];

}

- (void)tearDown
{
    [super tearDown];
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

    self.nativeResponse = nil;

    self.adResponseInfo = nil;
    
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}



#pragma mark - Tests.

- (void)testBannerAdUnitForDefaultTagIDResponseViaNobidWithoutMAR
{
TMARK();
    ANBannerAdView  *banner  = self.adUnitsForTest.banner;


    // ANBannerAdView, receiving nobid, without MAR association.
    //
    [banner setInventoryCode:self.inventoryCodeWithNobidGood memberId:self.adUnitsForTest.memberIDDefault];
    [banner loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([banner.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenAllIsCorrect]);

    //
    [self clearCounters];

    [banner setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [banner loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined]);

    //
    [self clearCounters];

    [banner setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [banner setPublisherId:self.publisherIDWithNobid];
    [banner loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined]);
    
    [self clearCounters];
}

- (void)testBannerAdUnitForDefaultTagIDResponseViaNobidWithMARLoadedByMAR
{
    ANBannerAdView  *banner  = self.adUnitsForTest.banner;


    // ANBannerAdView, receiving nobid, associated with MAR, loaded via MAR.
    //
    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                                  delegate: self
                                                   adUnits: self.adUnitsForTest.banner, nil];

    [banner setInventoryCode:self.inventoryCodeWithNobidGood memberId:self.adUnitsForTest.memberIDDefault];
    [self.mar load];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenAllIsCorrect]);

    //
    [self clearCounters];

    [banner setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [self.mar load];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + _AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined]);

    //
    [self clearCounters];
    [self.mar removeAdUnit:self.adUnitsForTest.banner];

    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                               publisherId: self.publisherIDWithNobid
                                                  delegate: self
                                                   adUnits: self.adUnitsForTest.banner, nil];

    [banner setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [self.mar load];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined]);
    
    [self clearCounters];
}

- (void)testBannerAdUnitForDefaultTagIDResponseViaNobidWithMARLoadedIndepdently
{
    ANBannerAdView  *banner  = self.adUnitsForTest.banner;

    
    // ANBannerAdView, receiving nobid, associated with MAR, loaded independently.
    //
    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                                  delegate: self
                                                   adUnits: self.adUnitsForTest.banner, nil];

    [banner setInventoryCode:self.inventoryCodeWithNobidGood memberId:self.adUnitsForTest.memberIDDefault];
    [banner loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenAllIsCorrect]);

    //
    [self clearCounters];

    [banner setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [banner loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined]);

    //
    [self clearCounters];
    [self.mar removeAdUnit:self.adUnitsForTest.banner];

    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                               publisherId: self.publisherIDWithNobid
                                                  delegate: self
                                                   adUnits: self.adUnitsForTest.banner, nil];

    [self.adUnitsForTest.banner setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [self.adUnitsForTest.banner loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined]);
    [self clearCounters];
}


- (void)testInterstitialAdUnitForDefaultTagIDResponseViaNobidWithoutMAR
{
TMARK();
    ANInterstitialAd  *interstitial  = self.adUnitsForTest.interstitial;


    // ANInterstitialAd, receiving nobid, without MAR association.
    //
    [interstitial setInventoryCode:self.inventoryCodeWithNobidGood memberId:self.adUnitsForTest.memberIDDefault];
    [interstitial loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([interstitial.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenAllIsCorrect]);

    //
    [self clearCounters];

    [interstitial setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [interstitial loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined]);

    //
    [self clearCounters];

    [interstitial setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [interstitial setPublisherId:self.publisherIDWithNobid];
    [interstitial loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined]);
    [self clearCounters];
}

- (void)testInterstitialAdUnitForDefaultTagIDResponseViaNobidWithMARLoadedByMAR
{
    ANInterstitialAd  *interstitial  = self.adUnitsForTest.interstitial;


    // ANInterstitialAd, receiving nobid, associated with MAR, loaded via MAR.
    //
    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                                  delegate: self
                                                   adUnits: self.adUnitsForTest.interstitial, nil];

    [interstitial setInventoryCode:self.inventoryCodeWithNobidGood memberId:self.adUnitsForTest.memberIDDefault];
    [self.mar load];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:2* kWaitVeryLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenAllIsCorrect]);

    //
    [self clearCounters];

    [interstitial setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [self.mar load];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + _AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined]);

    //
    [self clearCounters];
    [self.mar removeAdUnit:self.adUnitsForTest.interstitial];

    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                               publisherId: self.publisherIDWithNobid
                                                  delegate: self
                                                   adUnits: self.adUnitsForTest.interstitial, nil];

    [interstitial setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [self.mar load];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined]);
    [self clearCounters];
}

- (void)testInterstitialAdUnitForDefaultTagIDResponseViaNobidWithMARLoadedIndepdently
{
    ANInterstitialAd  *interstitial  = self.adUnitsForTest.interstitial;


    // ANInterstitialAd, receiving nobid, associated with MAR, loaded independently.
    //
    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                                  delegate: self
                                                   adUnits: self.adUnitsForTest.interstitial, nil];

    [interstitial setInventoryCode:self.inventoryCodeWithNobidGood memberId:self.adUnitsForTest.memberIDDefault];
    [interstitial loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenAllIsCorrect]);

    //
    [self clearCounters];

    [interstitial setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [interstitial loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined]);

    //
    [self clearCounters];
    [self.mar removeAdUnit:self.adUnitsForTest.interstitial];

    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                               publisherId: self.publisherIDWithNobid
                                                  delegate: self
                                                   adUnits: self.adUnitsForTest.interstitial, nil];

    [self.adUnitsForTest.interstitial setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [self.adUnitsForTest.interstitial loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined]);
    [self clearCounters];
}

- (void)testVideoAdUnitForDefaultTagIDResponseViaNobidWithoutMAR
{
TMARK();
    ANInstreamVideoAd  *instreamVideo  = self.adUnitsForTest.instreamVideo;


    // ANInstreamVideoAd, receiving nobid, without MAR association.
    //
    [instreamVideo setInventoryCode:self.inventoryCodeWithNobidGood memberId:self.adUnitsForTest.memberIDDefault];
    [instreamVideo loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([instreamVideo.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenAllIsCorrect]);

    //
    [self clearCounters];

    [instreamVideo setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [instreamVideo loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined]);

    //
    [self clearCounters];

    [instreamVideo setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [instreamVideo setPublisherId:self.publisherIDWithNobid];
    [instreamVideo loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined]);
    [self clearCounters];
}

- (void)testVideoAdUnitForDefaultTagIDResponseViaNobidWithMARLoadedByMAR
{
    ANInstreamVideoAd  *instreamVideo  = self.adUnitsForTest.instreamVideo;


    // ANInstreamVideoAd, receiving nobid, associated with MAR, loaded via MAR.
    //
    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                                  delegate: self
                                                   adUnits: self.adUnitsForTest.instreamVideo, nil];

    [instreamVideo setInventoryCode:self.inventoryCodeWithNobidGood memberId:self.adUnitsForTest.memberIDDefault];
    [self.mar load];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenAllIsCorrect]);

    //
    [self clearCounters];

    [instreamVideo setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [self.mar load];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + _AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined]);

    //
    [self clearCounters];
    [self.mar removeAdUnit:self.adUnitsForTest.instreamVideo];

    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                               publisherId: self.publisherIDWithNobid
                                                  delegate: self
                                                   adUnits: self.adUnitsForTest.instreamVideo, nil];

    [instreamVideo setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [self.mar load];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined]);
    [self clearCounters];
}

- (void)testVideoAdUnitForDefaultTagIDResponseViaNobidWithMARLoadedIndepdently
{
    ANInstreamVideoAd  *instreamVideo  = self.adUnitsForTest.instreamVideo;


    // ANInstreamVideoAd, receiving nobid, associated with MAR, loaded independently.
    //
    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                                  delegate: self
                                                   adUnits: self.adUnitsForTest.instreamVideo, nil];

    [instreamVideo setInventoryCode:self.inventoryCodeWithNobidGood memberId:self.adUnitsForTest.memberIDDefault];
    [instreamVideo loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenAllIsCorrect]);

    //
    [self clearCounters];

    [instreamVideo setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [instreamVideo loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined]);

    //
    [self clearCounters];
    [self.mar removeAdUnit:self.adUnitsForTest.instreamVideo];

    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                               publisherId: self.publisherIDWithNobid
                                                  delegate: self
                                                   adUnits: self.adUnitsForTest.instreamVideo, nil];

    [self.adUnitsForTest.instreamVideo setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [self.adUnitsForTest.instreamVideo loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined]);
    [self clearCounters];
}

- (void)testNativeAdUnitForDefaultTagIDResponseViaNobidWithoutMAR
{
TMARK();
    ANNativeAdRequest  *native  = self.adUnitsForTest.native;


    // ANNativeAdRequest, receiving nobid, without MAR association.
    //
    [native setInventoryCode:self.inventoryCodeWithNobidGood memberId:self.adUnitsForTest.memberIDDefault];
    [native loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenAllIsCorrect]);

    //
    [self clearCounters];

    [native setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [native loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined]);

    //
    [self clearCounters];

    [native setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [native setPublisherId:self.publisherIDWithNobid];
    [native loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined]);
    [self clearCounters];
}

- (void)testNativeAdUnitForDefaultTagIDResponseViaNobidWithMARLoadedByMAR
{
    ANNativeAdRequest  *native  = self.adUnitsForTest.native;


    // ANNativeAdRequest, receiving nobid, associated with MAR, loaded via MAR.
    //
    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                                  delegate: self
                                                   adUnits: self.adUnitsForTest.native, nil];

    [native setInventoryCode:self.inventoryCodeWithNobidGood memberId:self.adUnitsForTest.memberIDDefault];
    [self.mar load];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenAllIsCorrect]);

    //
    [self clearCounters];

    [native setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [self.mar load];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + _AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined]);

    //
    [self clearCounters];
    [self.mar removeAdUnit:self.adUnitsForTest.native];

    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                               publisherId: self.publisherIDWithNobid
                                                  delegate: self
                                                   adUnits: self.adUnitsForTest.native, nil];

    [native setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [self.mar load];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, 1);

    if (self.adResponseInfo) {
        XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined]);
    } else {
        XCTAssertTrue([self.nativeResponse.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined]);
    }
    [self clearCounters];
}

- (void)testNativeAdUnitForDefaultTagIDResponseViaNobidWithMARLoadedIndepdently
{
    ANNativeAdRequest  *native  = self.adUnitsForTest.native;


    // ANNativeAdRequest, receiving nobid, associated with MAR, loaded independently.
    //
    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                                  delegate: self
                                                   adUnits: self.adUnitsForTest.native, nil];

    [native setInventoryCode:self.inventoryCodeWithNobidGood memberId:self.adUnitsForTest.memberIDDefault];
    [native loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveFailures, 1);
    XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenAllIsCorrect]);

    //
    [self clearCounters];

    [native setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [native loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, 1);

    if (self.adResponseInfo) {
        XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined]);
    } else {
        XCTAssertTrue([self.nativeResponse.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsNOTDefined]);
    }

    //
    [self clearCounters];
    [self.mar removeAdUnit:self.adUnitsForTest.native];

    self.mar  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDDefault
                                               publisherId: self.publisherIDWithNobid
                                                  delegate: self
                                                   adUnits: self.adUnitsForTest.native, nil];

    [self.adUnitsForTest.native setInventoryCode:self.inventoryCodeWithNobidBad memberId:self.adUnitsForTest.memberIDDefault];
    [self.adUnitsForTest.native loadAd];

    self.expectationAdUnitLoadResponseOrFailure = [self expectationWithDescription:@"EXPECTATION: expectationAdUnitLoadResponseOrFailure"];
    [self waitForExpectationsWithTimeout:kWaitLong handler:nil];

    XCTAssertEqual(self.AdUnit_countOfReceiveSuccesses + self.AdUnit_countOfReceiveFailures, 1);

    if (self.adResponseInfo) {
        XCTAssertTrue([self.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined]);
    } else {
        XCTAssertTrue([self.nativeResponse.adResponseInfo.placementId isEqualToString:self.placementIDNobidResponseWhenInventoryCodeIsWrongAndPublisherIDIsDefined]);
    }
    [self clearCounters];
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

    ANAdView  *adview  = (ANAdView *)ad;
    self.adResponseInfo = adview.adResponseInfo;

    self.AdUnit_countOfReceiveSuccesses += 1;
    [self.expectationAdUnitLoadResponseOrFailure fulfill];
}

- (void)            ad: (nonnull id)loadInstance
    didReceiveNativeAd: (nonnull id)responseInstance
{
    TINFO(@"%@", [MARHelper adunitDescription:loadInstance]);

    ANNativeAdResponse  *nativead  = (ANNativeAdResponse *)loadInstance;
    self.adResponseInfo = nativead.adResponseInfo;

    self.AdUnit_countOfReceiveSuccesses += 1;
    [self.expectationAdUnitLoadResponseOrFailure fulfill];
}


- (void)ad:(nonnull id)ad requestFailedWithError:(NSError *)error
{
TERROR(@"%@ -- %@", [MARHelper adunitDescription:ad], error.userInfo);

    if ([ad isKindOfClass:[ANAdView class]]) {
        ANAdView  *adview  = (ANAdView *)ad;
        self.adResponseInfo = adview.adResponseInfo;
    } else {
        ANNativeAdResponse  *nativead  = (ANNativeAdResponse *)ad;
        self.adResponseInfo = nativead.adResponseInfo;
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

    self.nativeResponse = response;

    self.AdUnit_countOfReceiveSuccesses += 1;
    [self.expectationAdUnitLoadResponseOrFailure fulfill];
}

- (void)adRequest:(nonnull ANNativeAdRequest *)request didFailToLoadWithError:(nonnull NSError *)error withAdResponseInfo:(nullable ANAdResponseInfo *)adResponseInfo
{
    TERROR(@"%@ -- %@", [MARHelper adunitDescription:request], error.userInfo);

    self.adResponseInfo = adResponseInfo;

    self.AdUnit_countOfReceiveFailures += 1;
    [self.expectationAdUnitLoadResponseOrFailure fulfill];
}


@end
