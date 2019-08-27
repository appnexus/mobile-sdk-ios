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
    ANUniversalTagAdServerResponse  *response    = [self responseWithJSONResource:kANAdResponseSuccessfulMRAID];
    ANStandardAd                    *standardAd  = [response.ads firstObject];

    XCTAssert(standardAd.mraid == YES);
    XCTAssert([standardAd.height isEqualToString:@"50"]);
    XCTAssert([standardAd.width isEqualToString:@"320"]);
    XCTAssertNotNil(standardAd.creativeId);
    XCTAssertNotNil(standardAd.content);

}


- (void)testLocalSuccessfulNativeStandardAdResponse
{
    ANUniversalTagAdServerResponse  *response    = [self responseWithJSONResource:kANAdSuccessfulNativeStandardAdResponse];
    ANStandardAd                    *standardAd  = [response.ads firstObject];
    XCTAssertNotNil(standardAd.creativeId);
    
}


- (void)testLocalSuccessfulANRTBVideoAdResponse
{
    ANUniversalTagAdServerResponse  *response    = [self responseWithJSONResource:kANAdSuccessfulANRTBVideoAdResponse];
    ANRTBVideoAd                    *rtbVideoAd  = [response.ads firstObject];
    
    XCTAssertNotNil(rtbVideoAd.creativeId);
    
}

- (void)testLocalSuccessfulStandardAdFromRTBObjectResponse
{
    ANUniversalTagAdServerResponse  *response    = [self responseWithJSONResource:kStandardAdFromRTBObjectResponse];
    ANNativeStandardAdResponse                    *nativeStandardAdResponse  = [response.ads firstObject];
    
    XCTAssertNotNil(nativeStandardAdResponse.creativeId);
    
}



- (void)testLocalSuccessfulNativeStandardAdWithoutCreativeIdResponse
{
    ANUniversalTagAdServerResponse  *response    = [self responseWithJSONResource:kANAdSuccessfulNativeStandardAdWithoutCreativeIdResponse];
    ANStandardAd                    *standardAd  = [response.ads firstObject];
    XCTAssertEqual(standardAd.creativeId.length, 0);

}


- (void)testLocalSuccessfulANRTBVideoAdWithoutCreativeIdResponse
{
    ANUniversalTagAdServerResponse  *response    = [self responseWithJSONResource:kANAdSuccessfulANRTBVideoAdWithoutCreativeIdResponse];
    ANRTBVideoAd                    *rtbVideoAd  = [response.ads firstObject];
    
    XCTAssertEqual(rtbVideoAd.creativeId.length, 0);

}

- (void)testLocalSuccessfulStandardAdFromRTBObjectWithoutCreativeIdResponse
{
    ANUniversalTagAdServerResponse  *response    = [self responseWithJSONResource:kStandardAdFromRTBObjectWithoutCreativeIdResponse];
    ANNativeStandardAdResponse                    *nativeStandardAdResponse  = [response.ads firstObject];
    
    XCTAssertEqual(nativeStandardAdResponse.creativeId.length, 0);

}


- (void)testLocalSuccessfulMediationResponse
{
    ANUniversalTagAdServerResponse *response = [self responseWithJSONResource:kANAdResponseSuccessfulMediation];
    XCTAssert([response.ads count] == 4);


    
    ANMediatedAd *firstMediatedAd = [response.ads objectAtIndex:0];
    ANMediatedAd *expectedFirstMediatedAd = [[ANMediatedAd alloc] init];
    expectedFirstMediatedAd.width = @"320";
    expectedFirstMediatedAd.height = @"50";
    expectedFirstMediatedAd.adId = @"/6925/Shazam_iPhoneAPP/Standard_Banners/My_Tags";
    expectedFirstMediatedAd.className = @"ANAdAdapterBannerDFP";
    [self mediatedAd:firstMediatedAd equalToMediatedAd:expectedFirstMediatedAd];
    XCTAssertNotNil(firstMediatedAd.responseURL);
    XCTAssertEqual(firstMediatedAd.creativeId.length, 0);


    
    ANMediatedAd *secondMediatedAd = [response.ads objectAtIndex:1];
    ANMediatedAd *expectedSecondMediatedAd = [[ANMediatedAd alloc] init];
    expectedSecondMediatedAd.width = @"320";
    expectedSecondMediatedAd.height = @"50";
    expectedSecondMediatedAd.className = @"ANAdAdapterBannerMillennialMedia";
    expectedSecondMediatedAd.adId = @"148502";
    [self mediatedAd:secondMediatedAd equalToMediatedAd:expectedSecondMediatedAd];
    XCTAssertNotNil(secondMediatedAd.responseURL);
    XCTAssertEqual(secondMediatedAd.creativeId.length, 0);


    
    ANMediatedAd *thirdMediatedAd = [response.ads objectAtIndex:2];
    ANMediatedAd *expectedThirdMediatedAd = [[ANMediatedAd alloc] init];
    expectedThirdMediatedAd.width = @"320";
    expectedThirdMediatedAd.height = @"50";
    expectedThirdMediatedAd.className = @"ANAdAdapterBannerAdMob";
    expectedThirdMediatedAd.adId = @"ca-app-pub-5668774179595841/1125462353";
    [self mediatedAd:thirdMediatedAd equalToMediatedAd:expectedThirdMediatedAd];
    XCTAssertNotNil(thirdMediatedAd.responseURL);
    XCTAssertEqual(thirdMediatedAd.creativeId.length, 0);


    
    ANMediatedAd *fourthMediatedAd = [response.ads objectAtIndex:3];
    ANMediatedAd *expectedFourthMediatedAd = [[ANMediatedAd alloc] init];
    expectedFourthMediatedAd.className = @"ANAdAdapterBanneriAd";
    [self mediatedAd:fourthMediatedAd equalToMediatedAd:expectedFourthMediatedAd];
    XCTAssertNotNil(fourthMediatedAd.responseURL);
    XCTAssertEqual(fourthMediatedAd.creativeId.length, 0);

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
