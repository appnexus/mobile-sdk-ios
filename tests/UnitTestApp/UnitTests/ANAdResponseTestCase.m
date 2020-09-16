/*   Copyright 2014 APPNEXUS INC
 
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TestGlobal.h"

#import "XCTestCase+ANAdResponse.h"
#import "XCTestCase+ANBannerAdView.h"

#import "ANMediatedAd.h"
#import "ANStandardAd.h"
#import "ANBannerAdView+ANTest.h"
#import "ANRTBVideoAd.h"
#import "ANNativeStandardAdResponse.h"



@interface ANUniversalTagAdServerResponse ()
+ (ANRTBVideoAd *)videoAdFromRTBObject:(NSDictionary *)rtbObject;
+ (ANStandardAd *)standardAdFromRTBObject:(NSDictionary *)rtbObject;
+ (ANNativeStandardAdResponse *)nativeAdFromRTBObject:(NSDictionary *)nativeObject;
@end



@interface ANAdResponseTestCase : XCTestCase
    //EMPTY
@end



@implementation ANAdResponseTestCase

#pragma mark - Local Tests

- (void)testLocalSuccessfulMRAIDResponse
{
    NSMutableArray<id>  *adsArray    = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:kANAdResponseSuccessfulMRAID]];
    ANStandardAd        *standardAd  = [adsArray firstObject];

    XCTAssert(standardAd.mraid == YES);
    XCTAssert([standardAd.height isEqualToString:@"50"]);
    XCTAssert([standardAd.width isEqualToString:@"320"]);
    XCTAssertNotNil(standardAd.creativeId);
    XCTAssertNotNil(standardAd.content);

}


- (void)testLocalSuccessfulNativeStandardAdResponse
{
    NSMutableArray<id>  *adsArray    = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:kANAdSuccessfulNativeStandardAdResponse]];
    ANStandardAd        *standardAd  = [adsArray firstObject];
    XCTAssertNotNil(standardAd.creativeId);
}


- (void)testLocalSuccessfulANRTBVideoAdResponse
{
    NSMutableArray<id>  *adsArray    = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:kANAdSuccessfulANRTBVideoAdResponse]];
    ANRTBVideoAd        *rtbVideoAd  = [adsArray firstObject];
    
    XCTAssertNotNil(rtbVideoAd.creativeId);
}

- (void)testLocalSuccessfulStandardAdFromRTBObjectResponse
{
    NSMutableArray<id>          *adsArray                  = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:kStandardAdFromRTBObjectResponse]];
    ANNativeStandardAdResponse  *nativeStandardAdResponse  = [adsArray firstObject];
    
    XCTAssertNotNil(nativeStandardAdResponse.creativeId);
}



- (void)testLocalSuccessfulNativeStandardAdWithoutCreativeIdResponse
{
    NSMutableArray<id>  *adsArray  =
        [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:kANAdSuccessfulNativeStandardAdWithoutCreativeIdResponse]];
    ANStandardAd        *standardAd  = [adsArray firstObject];

    XCTAssertEqual(standardAd.creativeId.length, 0);
}


- (void)testLocalSuccessfulANRTBVideoAdWithoutCreativeIdResponse
{
    NSMutableArray<id>  *adsArray    = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:kANAdSuccessfulANRTBVideoAdWithoutCreativeIdResponse]];
    ANRTBVideoAd        *rtbVideoAd  = [adsArray firstObject];
    
    XCTAssertEqual(rtbVideoAd.creativeId.length, 0);
}

- (void)testLocalSuccessfulStandardAdFromRTBObjectWithoutCreativeIdResponse
{
    NSMutableArray<id>          *adsArray  =
        [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:kStandardAdFromRTBObjectWithoutCreativeIdResponse]];
    ANNativeStandardAdResponse  *nativeStandardAdResponse  = [adsArray firstObject];
    
    XCTAssertEqual(nativeStandardAdResponse.creativeId.length, 0);

}


- (void)testLocalSuccessfulMediationResponse
{
    NSMutableArray<id>  *adsArray    = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:kANAdResponseSuccessfulMediation]];
    XCTAssert([adsArray count] == 3);

    ANMediatedAd *firstMediatedAd = [adsArray objectAtIndex:0];
    ANMediatedAd *expectedFirstMediatedAd = [[ANMediatedAd alloc] init];
    expectedFirstMediatedAd.width = @"320";
    expectedFirstMediatedAd.height = @"50";
    expectedFirstMediatedAd.adId = @"/6925/Shazam_iPhoneAPP/Standard_Banners/My_Tags";
    expectedFirstMediatedAd.className = @"ANAdAdapterBannerDFP";
    [self mediatedAd:firstMediatedAd equalToMediatedAd:expectedFirstMediatedAd];
    XCTAssertNotNil(firstMediatedAd.responseURL);
    XCTAssertEqual(firstMediatedAd.creativeId.length, 0);
    
    
    ANMediatedAd *secondMediatedAd = [adsArray objectAtIndex:1];
    ANMediatedAd *expectedThirdMediatedAd = [[ANMediatedAd alloc] init];
    expectedThirdMediatedAd.width = @"320";
    expectedThirdMediatedAd.height = @"50";
    expectedThirdMediatedAd.className = @"ANAdAdapterBannerAdMob";
    expectedThirdMediatedAd.adId = @"ca-app-pub-5668774179595841/1125462353";
    [self mediatedAd:secondMediatedAd equalToMediatedAd:expectedThirdMediatedAd];
    XCTAssertNotNil(secondMediatedAd.responseURL);
    XCTAssertEqual(secondMediatedAd.creativeId.length, 0);


    
    ANMediatedAd *thirdMediatedAd = [adsArray objectAtIndex:2];
    ANMediatedAd *expectedFourthMediatedAd = [[ANMediatedAd alloc] init];
    expectedFourthMediatedAd.className = @"ANAdAdapterBanneriAd";
    [self mediatedAd:thirdMediatedAd equalToMediatedAd:expectedFourthMediatedAd];
    XCTAssertNotNil(thirdMediatedAd.responseURL);
    XCTAssertEqual(thirdMediatedAd.creativeId.length, 0);

}



#pragma mark - Helper methods.

- (void)mediatedAd:(ANMediatedAd *)parsedMediatedAd equalToMediatedAd:(ANMediatedAd *)comparisonMediatedAd
{
    XCTAssertEqualObjects(parsedMediatedAd.width, comparisonMediatedAd.width);
    XCTAssertEqualObjects(parsedMediatedAd.height, comparisonMediatedAd.height);
    XCTAssertEqualObjects(parsedMediatedAd.className, comparisonMediatedAd.className);
    XCTAssertEqualObjects(parsedMediatedAd.adId, comparisonMediatedAd.adId);
}


@end
