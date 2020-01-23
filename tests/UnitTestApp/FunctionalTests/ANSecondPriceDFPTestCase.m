/*   Copyright 2018 APPNEXUS INC
 
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
#import "XCTestCase+ANCategory.h"

#import "ANMediatedAd.h"
#import "ANStandardAd.h"
#import "ANBannerAdView+ANTest.h"
#import "ANRTBVideoAd.h"
#import "ANNativeStandardAdResponse.h"
#import "ANUniversalTagAdServerResponse.h"




@interface ANUniversalTagAdServerResponse ()

+ (ANRTBVideoAd *)videoAdFromRTBObject:(NSDictionary *)rtbObject;
+ (ANStandardAd *)standardAdFromRTBObject:(NSDictionary *)rtbObject;
+ (ANNativeStandardAdResponse *)nativeAdFromRTBObject:(NSDictionary *)nativeObject;

@end



@interface ANSecondPriceDFPTestCase : XCTestCase
    //EMPTY
@end



@implementation ANSecondPriceDFPTestCase

- (void)testSecondPriceForDFPSuccess
{
    NSMutableArray<id>  *adsArray    = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:kSecondPriceForDFPSuccess]];
    XCTAssert([adsArray count] == 2);
    
    ANMediatedAd  *mediatedAd          = [adsArray objectAtIndex:0];
    ANMediatedAd  *expectedMediatedAd  = [[ANMediatedAd alloc] init];

    expectedMediatedAd.width        = @"300";
    expectedMediatedAd.height       = @"250";
    expectedMediatedAd.adId         = @"/19968336/second-price-dfp-ad-unit";
    expectedMediatedAd.className    = @"ANAdAdapterBannerDFP";
    expectedMediatedAd.param        = @"{\"second_price\":\"5.01\",\"optimized\":true}";

    [self mediatedAd:mediatedAd equalToMediatedAd:expectedMediatedAd];
    XCTAssertNotNil(mediatedAd.responseURL);
}

- (void)testSecondPriceForDFPParamIsUnset
{
    NSMutableArray<id>  *adsArray    = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:kSecondPriceForDFPParamIsUnset]];
    XCTAssert([adsArray count] == 2);

    ANMediatedAd  *mediatedAd          = [adsArray objectAtIndex:0];
    ANMediatedAd  *expectedMediatedAd  = [[ANMediatedAd alloc] init];

    expectedMediatedAd.width        = @"300";
    expectedMediatedAd.height       = @"250";
    expectedMediatedAd.adId         = @"/19968336/second-price-dfp-ad-unit";
    expectedMediatedAd.className    = @"ANAdAdapterBannerDFP";
    expectedMediatedAd.param        = @"#{PARAM}";

    [self mediatedAd:mediatedAd equalToMediatedAd:expectedMediatedAd];
    XCTAssertNotNil(mediatedAd.responseURL);
}




#pragma mark - Helper methods.

- (void)mediatedAd:(ANMediatedAd *)parsedMediatedAd equalToMediatedAd:(ANMediatedAd *)comparisonMediatedAd
{
    XCTAssertEqualObjects(parsedMediatedAd.width,       comparisonMediatedAd.width);
    XCTAssertEqualObjects(parsedMediatedAd.height,      comparisonMediatedAd.height);
    XCTAssertEqualObjects(parsedMediatedAd.className,   comparisonMediatedAd.className);
    XCTAssertEqualObjects(parsedMediatedAd.adId,        comparisonMediatedAd.adId);
    XCTAssertEqualObjects(parsedMediatedAd.param,       comparisonMediatedAd.param);
}


@end
