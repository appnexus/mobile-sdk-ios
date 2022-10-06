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
#import "ANMultiAdRequest.h"
#import "ANMultiAdRequest+PrivateMethods.h"
#import "ANAdFetcher+ANTest.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANOMIDImplementation.h"


#pragma mark - Global private constants.

static NSString  *kLocalScope   = @"Scope is LOCAL.";
static NSString  *kGlobalScope  = @"Scope is GLOBAL.";




#pragma mark -

@interface MARGeneralUnitTests : XCTestCase <ANMultiAdRequestDelegate>

@property (nonatomic, readwrite, strong, nullable)  MARAdUnits          *adUnitsForTest;
@property (nonatomic, readwrite, strong)            ANMultiAdRequest    *mar;
@property (nonatomic, readwrite, strong)            ANMultiAdRequest    *mar2;


//
@property (nonatomic, readwrite)  NSUInteger  MAR_countOfCompletionSuccesses;
@property (nonatomic, readwrite)  NSUInteger  MAR_countOfCompletionFailures;
@property (nonatomic, readwrite)  NSUInteger  AdUnit_countOfReceiveSuccesses;
@property (nonatomic, readwrite)  NSUInteger  AdUnit_countOfReceiveFailures;

@end




#pragma mark -

@implementation MARGeneralUnitTests

#pragma mark Test lifecycle.

- (void)setUp
{
TMARK();
    [self clearCountsAndExpectations];
    self.adUnitsForTest = [[MARAdUnits alloc] initWithDelegate:self];
    ANSDKSettings.sharedInstance.disableIDFVUsage = YES;

}

- (void)clearCountsAndExpectations
{
    self.mar = nil;
    self.MAR_countOfCompletionSuccesses     = 0;
    self.MAR_countOfCompletionFailures      = 0;
    self.AdUnit_countOfReceiveSuccesses     = 0;
    self.AdUnit_countOfReceiveFailures      = 0;
}

- (void)tearDown
{
    [self clearCountsAndExpectations];
    ANSDKSettings.sharedInstance.disableIDFVUsage = NO; // Reset to default in Teardown
}




#pragma mark - Tests for ANMultiAdRequest.

- (void)testContainsNoAdUnits
{
    BOOL  returnValue  = [self.mar load];

    XCTAssertFalse(returnValue);
}

- (void)testRemoveAdUnitUsingPublicAPI
{
TMARK();
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.bannerBanner,
                                                           self.adUnitsForTest.bannerPlusNative,
                                                           self.adUnitsForTest.bannerPlusVideo,
                                                           nil ];
    NSUInteger  countOfRequestedAdUnits  = 3;


    // Assert current count of tags is equal to array input to initWithMemberId:... .
    //
    NSDictionary  *jsonBody  = [MARHelper getJSONBodyFromMultiAdRequestInstance:self.mar];

    NSInteger  initialCountOfTags  = [jsonBody[@"tags"] count];

    XCTAssertEqual(initialCountOfTags, countOfRequestedAdUnits);


    // Remove one AdUnit.
    // Assert current count of tags is one less than array input to initWithMembetId:... .
    //
    [self.mar removeAdUnit:self.adUnitsForTest.bannerBanner];

    jsonBody  = [MARHelper getJSONBodyFromMultiAdRequestInstance:self.mar];

    NSInteger  countOfTagsAfterRemoval  = [jsonBody[@"tags"] count];

    XCTAssertEqual(initialCountOfTags, countOfTagsAfterRemoval + 1);
}

- (void)testDropAdUnitThatIsOutOfScopeBeforeMARLoad
{
TMARK();
   ANMultiAdRequest *marObject = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.bannerBanner,
                                                           self.adUnitsForTest.bannerPlusNative,
                                                           self.adUnitsForTest.bannerPlusVideo,
                                                           nil ];
    NSUInteger  countOfRequestedAdUnits  = 3;

    marObject = [self addAdUnitWhileInInnerScope:countOfRequestedAdUnits andMAR:marObject];


    // Demonstrate that newly added AdUnit is cleared from MAR instance after a brief delay.
    //

    [TestGlobal waitForSeconds: kWaitOneSecond
              thenExecuteBlock: ^{
                NSDictionary  *jsonBody                     = [MARHelper getJSONBodyFromMultiAdRequestInstance:marObject];
                NSInteger      countOfTagsInOutsideScope    = [jsonBody[@"tags"] count];
                XCTAssertEqual(countOfTagsInOutsideScope, countOfRequestedAdUnits);
                } ];
}

- (ANMultiAdRequest *)addAdUnitWhileInInnerScope:(NSUInteger)currentNumberOfTags andMAR:(ANMultiAdRequest *)marObject
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

    [marObject addAdUnit:anotherBanner];

    NSDictionary  *jsonBody  = [MARHelper getJSONBodyFromMultiAdRequestInstance:marObject];

    NSInteger  countOfTagsInInnerScope  = [jsonBody[@"tags"] count];

    XCTAssertEqual(countOfTagsInInnerScope, currentNumberOfTags + 1);
    return marObject;
}


- (void)testSetLastAdUnitStrongPropertyToNil
{
    ANMultiAdRequest *marObject  = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.bannerBanner,
                                                           self.adUnitsForTest.bannerPlusNative,
                                                           self.adUnitsForTest.bannerPlusVideo,
                                                           nil ];
    NSUInteger  countOfEncapsulatedAdUnits  = 3;
    self.adUnitsForTest.bannerBanner = nil;


    // Demonstrate that newly added AdUnit is cleared from MAR instance after a brief delay.
    
    [TestGlobal waitForSeconds: kWaitOneSecond
              thenExecuteBlock: ^{
                    NSDictionary  *jsonBody                     = [MARHelper getJSONBodyFromMultiAdRequestInstance:marObject];
                    NSInteger      countOfTagsInOutsideScope    = [jsonBody[@"tags"] count];

                    XCTAssertEqual(countOfTagsInOutsideScope, countOfEncapsulatedAdUnits - 1);

                }];
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

// NB  https://en.wikipedia.org/wiki/Sophie_Germain_prime
//
- (void)testUserInfoInMARInstanceAndInAdUnit
{
    NSString    *aliceName      = @"Alice";
    NSUInteger   aliceGender    = ANGenderFemale;
    NSString    *aliceAge       = @"443";

    NSString    *bobName        = @"Bob";
    NSUInteger   bobGender      = ANGenderMale;
    NSString    *bobAge         = @"953";

    NSDictionary  *jsonBody     = nil;

    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.banner,
                                                           nil ];

    self.adUnitsForTest.banner.gender       = bobGender;
    self.adUnitsForTest.banner.age          = bobAge;

    jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.banner withMultiAdRequest:self.mar];

    XCTAssertNil(jsonBody[@"user"][@"external_uid"]);
    XCTAssertEqual([jsonBody[@"user"][@"gender"] integerValue], ANGenderUnknown);
    XCTAssertNil(jsonBody[@"user"][@"age"]);

    self.mar.gender       = aliceGender;
    self.mar.age          = aliceAge;

    jsonBody  = [MARHelper getJSONBodyFromMultiAdRequestInstance:self.mar];

    XCTAssertEqual([jsonBody[@"user"][@"gender"] integerValue], aliceGender);
    XCTAssertEqual([jsonBody[@"user"][@"age"] integerValue], [aliceAge integerValue]);

    jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.banner];

    XCTAssertEqual([jsonBody[@"user"][@"gender"] integerValue], bobGender);
    XCTAssertEqual([jsonBody[@"user"][@"age"] integerValue], [bobAge integerValue]);
}

- (void)testCustomKeywordsInMARInstanceAndInAdUnit
{
    NSString    *marKeywordOne          = @"marKeywordOne";
    NSString    *marValueOne            = @"marValueOne";

    NSString    *marKeywordTwo          = @"marKeywordTwo";
    NSString    *marValueTwo            = @"marValueTwo";

    NSString    *adunitKeywordThree     = @"adunitKeywordThree";
    NSString    *adunitValueThree       = @"adunitValueThree";

    NSDictionary  *jsonBody     = nil;
    NSDictionary  *dictionary   = nil;

    NSArray       *marCK     = nil;
    NSArray       *adunitCK  = nil;

    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.banner,
                                                           nil ];

    jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.banner withMultiAdRequest:self.mar];

    marCK       = jsonBody[@"keywords"];
    adunitCK    = jsonBody[@"tags"][0][@"keywords"];

    XCTAssertNil(marCK);
    XCTAssertNil(adunitCK);


    [self.mar addCustomKeywordWithKey:marKeywordOne value:marValueOne];
    [self.mar addCustomKeywordWithKey:marKeywordTwo value:marValueTwo];

    [self.adUnitsForTest.banner addCustomKeywordWithKey:adunitKeywordThree value:adunitValueThree];

    jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.banner withMultiAdRequest:self.mar];

    marCK       = jsonBody[@"keywords"];
    adunitCK    = jsonBody[@"tags"][0][@"keywords"];

    XCTAssertEqual([marCK count], 2);

    for (dictionary in marCK)
    {
        NSString  *value  = nil;

        if ([dictionary[@"key"] isEqualToString:marKeywordOne]) {
            value = marValueOne;
        } else {
            value = marValueTwo;
        }

        XCTAssertTrue([dictionary[@"value"][0] isEqualToString:value]);
    }


    XCTAssertEqual([adunitCK count], 1);

    dictionary  = adunitCK[0];
    XCTAssertTrue([dictionary[@"value"][0] isEqualToString:adunitValueThree]);


    //
    [self.mar removeCustomKeywordWithKey:marKeywordOne];

    jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.banner withMultiAdRequest:self.mar];
    marCK     = jsonBody[@"keywords"];

    XCTAssertEqual([marCK count], 1);


    //
    [self.mar clearCustomKeywords];

    jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.banner withMultiAdRequest:self.mar];
    marCK     = jsonBody[@"keywords"];

    XCTAssertNil(marCK);

    XCTAssertEqual([adunitCK count], 1);

    dictionary  = adunitCK[0];
    XCTAssertTrue([dictionary[@"value"][0] isEqualToString:adunitValueThree]);
}

- (void)testCannotAddNilPointerToMARInstance
{
TMARK();
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                              andDelegate: self ];

    ANBannerAdView  *nilBanner  = nil;

    BOOL  returnValue  = [self.mar addAdUnit:nilBanner];

    XCTAssertFalse(returnValue);
}

- (void)testCannotAddAdUnitWithMismatchedMemberIDToMARInstance
{
TMARK();
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                              andDelegate: self ];

    [self.adUnitsForTest.banner setInventoryCode:@"madeUpInventoryCode" memberId:99999999];

    BOOL  returnValue  = [self.mar addAdUnit:self.adUnitsForTest.banner];

    XCTAssertFalse(returnValue);
}

- (void)testCannotAddAdUnitThatIsAlreadyEncapsulatedByAnotherMARInstance
{
TMARK();
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.bannerBanner,
                                                           nil ];

    self.mar2 = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                               andDelegate: self ];

    BOOL  returnValue  = [self.mar2 addAdUnit:self.adUnitsForTest.bannerBanner];

    XCTAssertFalse(returnValue);
}

- (void)testCannotAddObjectsThatAreNotAdUnitsToMARInstance
{
TMARK();
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                              andDelegate: self ];

    NSString  *randomObject  = @"soVeryRandom";

    BOOL  returnValue  = [self.mar addAdUnit:(id<ANAdProtocolFoundationCore>)randomObject];

    XCTAssertFalse(returnValue);
}

- (void)testRemovingNilAdUnitDoesNotChangeMARInstance
{
TMARK();
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.bannerBanner,
                                                           nil ];
    ANBannerAdView  *nilBanner  = nil;

    XCTAssertEqual(self.mar.countOfAdUnits, 1);

    BOOL  returnValue  = [self.mar removeAdUnit:nilBanner];

    XCTAssertFalse(returnValue);

    XCTAssertEqual(self.mar.countOfAdUnits, 1);
}

- (void)testInitializingMARInstanceWillSetMemberIDInJSONRequestBody
{
TMARK();
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.bannerBanner,
                                                           nil ];

    NSDictionary  *jsonObject  = [MARHelper getJSONBodyFromMultiAdRequestInstance:self.mar];

    XCTAssertEqual([jsonObject[@"member_id"] integerValue], self.adUnitsForTest.memberIDGood);
}




#pragma mark - Tests for AdUnits in relation to ANMultiAdRequest.

- (void)testAdUnitMemberIDMayBeSetToZero
{
    [self.adUnitsForTest.banner setInventoryCode:nil memberId:0];

    XCTAssertEqual(self.adUnitsForTest.banner.memberId, 0);
}

// NB  https://en.wikipedia.org/wiki/Sophie_Germain_prime
//
- (void)testMaskingAndUnmaskingAdUnitNamespaceWithMARAssociation
{
    NSString    *aliceName      = @"Alice";
    NSUInteger   aliceGender    = ANGenderFemale;
    NSString    *aliceAge       = @"443";
    NSUInteger   aliceLatitude  = 11;

    NSString    *bobName        = @"Bob";
    NSUInteger   bobGender      = ANGenderMale;
    NSString    *bobAge         = @"953";
    NSUInteger   bobLatitude    = 22;

    NSDictionary  *jsonBody     = nil;

    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.banner,
                                                           nil ];

    self.adUnitsForTest.banner.gender       = bobGender;
    self.adUnitsForTest.banner.age          = bobAge;

    [self.adUnitsForTest.banner setLocationWithLatitude:bobLatitude longitude:0 timestamp:nil horizontalAccuracy:0];

    jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.banner withMultiAdRequest:self.mar];

    XCTAssertNil(jsonBody[@"user"][@"external_uid"]);
    XCTAssertEqual([jsonBody[@"user"][@"gender"] integerValue], ANGenderUnknown);
    XCTAssertNil(jsonBody[@"user"][@"age"]);
    XCTAssertNil(jsonBody[@"device"][@"geo"][@"latitude"]);


    self.mar.gender       = aliceGender;
    self.mar.age          = aliceAge;

    [self.mar setLocationWithLatitude:aliceLatitude longitude:0 timestamp:nil horizontalAccuracy:0];


    jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.banner withMultiAdRequest:self.mar];

    XCTAssertEqual([jsonBody[@"user"][@"gender"] integerValue], aliceGender);
    XCTAssertEqual([jsonBody[@"user"][@"age"] integerValue], [aliceAge integerValue]);
    XCTAssertEqual([jsonBody[@"device"][@"geo"][@"lat"] integerValue], aliceLatitude);

    //
    jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.banner];

    XCTAssertEqual([jsonBody[@"user"][@"gender"] integerValue], bobGender);
    XCTAssertEqual([jsonBody[@"user"][@"age"] integerValue], [bobAge integerValue]);
    XCTAssertEqual([jsonBody[@"device"][@"geo"][@"lat"] integerValue], bobLatitude);
}

//#pragma mark - ANMultiAdRequestDelegate.

- (void)multiAdRequestDidComplete:(ANMultiAdRequest *)mar
{
TMARK();
}

- (void)multiAdRequest:(nonnull ANMultiAdRequest *)mar  didFailWithError:(NSError *)error
{
TMARKMESSAGE(@"%@", error.userInfo);
}


- (void)testOMIDEnableAdUnitMARBannerAd
{
    [[ANSDKSettings sharedInstance] setEnableOpenMeasurement:YES];
    NSDictionary  *jsonBody     = nil;
    
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.banner,
                nil ];
    
    
    jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.banner withMultiAdRequest:self.mar];
    XCTAssertTrue([jsonBody[@"iab_support"][@"omidpn"] isEqualToString:AN_OMIDSDK_PARTNER_NAME]);
    XCTAssertEqualObjects(jsonBody[@"iab_support"][@"omidpv"],[ANSDKSettings sharedInstance].sdkVersion);
    
    NSArray *tags = jsonBody[@"tags"];
    XCTAssertNotNil(tags);
    XCTAssertEqualObjects(tags[0][@"banner_frameworks"],@[@(6)]);
    
    
    jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.banner withMultiAdRequest:self.mar];
    XCTAssertTrue([jsonBody[@"iab_support"][@"omidpn"] isEqualToString:AN_OMIDSDK_PARTNER_NAME]);
    XCTAssertEqualObjects(jsonBody[@"iab_support"][@"omidpv"],[ANSDKSettings sharedInstance].sdkVersion);
    
    tags = jsonBody[@"tags"];
    XCTAssertNotNil(tags);
    XCTAssertEqualObjects(tags[0][@"banner_frameworks"],@[@(6)]);
}

- (void)testOMIDEnableAdUnitMARBannerVideoAd
{
    [[ANSDKSettings sharedInstance] setEnableOpenMeasurement:YES];
    NSDictionary  *jsonBody     = nil;
    
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.banner, self.adUnitsForTest.instreamVideo,
                nil ];
    
    
    jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.banner withMultiAdRequest:self.mar];
    XCTAssertTrue([jsonBody[@"iab_support"][@"omidpn"] isEqualToString:AN_OMIDSDK_PARTNER_NAME]);
    XCTAssertEqualObjects(jsonBody[@"iab_support"][@"omidpv"],[ANSDKSettings sharedInstance].sdkVersion);
    
    NSArray *tags = jsonBody[@"tags"];
    XCTAssertNotNil(tags);
    XCTAssertEqualObjects(tags[0][@"banner_frameworks"],@[@(6)]);
    
    
    jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.instreamVideo withMultiAdRequest:self.mar];
    XCTAssertTrue([jsonBody[@"iab_support"][@"omidpn"] isEqualToString:AN_OMIDSDK_PARTNER_NAME]);
    XCTAssertEqualObjects(jsonBody[@"iab_support"][@"omidpv"],[ANSDKSettings sharedInstance].sdkVersion);
    
    tags = jsonBody[@"tags"];
    XCTAssertNotNil(tags);
    XCTAssertEqualObjects(tags[0][@"video_frameworks"],@[@(6)]);
}


- (void)testOMIDEnableAdUnitMARBannerVideoNativeAd
{
    [[ANSDKSettings sharedInstance] setEnableOpenMeasurement:YES];

    NSDictionary  *jsonBody     = nil;
    
    self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                 delegate: self
                                                  adUnits: self.adUnitsForTest.banner, self.adUnitsForTest.instreamVideo, self.adUnitsForTest.native,
                nil ];
    
    
    jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.banner withMultiAdRequest:self.mar];
    XCTAssertTrue([jsonBody[@"iab_support"][@"omidpn"] isEqualToString:AN_OMIDSDK_PARTNER_NAME]);
    XCTAssertEqualObjects(jsonBody[@"iab_support"][@"omidpv"],[ANSDKSettings sharedInstance].sdkVersion);
    
    NSArray *tags = jsonBody[@"tags"];
    XCTAssertNotNil(tags);
    XCTAssertEqualObjects(tags[0][@"banner_frameworks"],@[@(6)]);
    
    
    jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.instreamVideo withMultiAdRequest:self.mar];
    XCTAssertTrue([jsonBody[@"iab_support"][@"omidpn"] isEqualToString:AN_OMIDSDK_PARTNER_NAME]);
    XCTAssertEqualObjects(jsonBody[@"iab_support"][@"omidpv"],[ANSDKSettings sharedInstance].sdkVersion);
    
    tags = jsonBody[@"tags"];
    XCTAssertNotNil(tags);
    XCTAssertEqualObjects(tags[0][@"video_frameworks"],@[@(6)]);
    
    jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.native withMultiAdRequest:self.mar];
    XCTAssertTrue([jsonBody[@"iab_support"][@"omidpn"] isEqualToString:AN_OMIDSDK_PARTNER_NAME]);
    XCTAssertEqualObjects(jsonBody[@"iab_support"][@"omidpv"],[ANSDKSettings sharedInstance].sdkVersion);
    
    tags = jsonBody[@"tags"];
    XCTAssertNotNil(tags);
    XCTAssertEqualObjects(tags[0][@"native_frameworks"],@[@(6)]);
}


- (void)testOMIDDisableAdUnitMARBannerAd
{
    [[ANSDKSettings sharedInstance] setEnableOpenMeasurement:NO];
     NSDictionary  *jsonBody     = nil;

      self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                   delegate: self
                                                    adUnits: self.adUnitsForTest.banner,
                                                             nil ];


      jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.banner withMultiAdRequest:self.mar];
      XCTAssertNil(jsonBody[@"iab_support"]);
      XCTAssertNil(jsonBody[@"iab_support"][@"omidpn"] );
      XCTAssertNil(jsonBody[@"iab_support"][@"omidpv"]);


      jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.banner withMultiAdRequest:self.mar];
      XCTAssertNil(jsonBody[@"iab_support"]);
      XCTAssertNil(jsonBody[@"iab_support"][@"omidpn"] );
      XCTAssertNil(jsonBody[@"iab_support"][@"omidpv"]);

      NSArray *tags = jsonBody[@"tags"];
      XCTAssertNotNil(tags);
      XCTAssertNil(tags[0][@"banner_frameworks"]);
}

- (void)testOMIDDisableAdUnitMARBannerVideoNativeAd
{
    [[ANSDKSettings sharedInstance] setEnableOpenMeasurement:NO];
     NSDictionary  *jsonBody     = nil;

      self.mar = [[ANMultiAdRequest alloc] initWithMemberId: self.adUnitsForTest.memberIDGood
                                                   delegate: self
                                                    adUnits: self.adUnitsForTest.banner, self.adUnitsForTest.instreamVideo,
                                                             nil ];


      jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.banner withMultiAdRequest:self.mar];
      XCTAssertNil(jsonBody[@"iab_support"]);
      XCTAssertNil(jsonBody[@"iab_support"][@"omidpn"] );
      XCTAssertNil(jsonBody[@"iab_support"][@"omidpv"]);


      jsonBody  = [MARHelper getJSONBodyFromAdUnit:self.adUnitsForTest.banner withMultiAdRequest:self.mar];
      XCTAssertNil(jsonBody[@"iab_support"]);
      XCTAssertNil(jsonBody[@"iab_support"][@"omidpn"] );
      XCTAssertNil(jsonBody[@"iab_support"][@"omidpv"]);

      NSArray *tags = jsonBody[@"tags"];
      XCTAssertNotNil(tags);
      XCTAssertNil(tags[0][@"banner_frameworks"]);
}




@end
