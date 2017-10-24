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

@interface ANAdResponseTestCase : XCTestCase

@end

@implementation ANAdResponseTestCase

#pragma mark - Local Tests

- (void)testLocalSuccessfulMRAIDResponse {
    ANUniversalTagAdServerResponse *response = [self responseWithJSONResource:kANAdResponseSuccessfulMRAID];
//    XCTAssert(response.isMraid == YES);
    ANStandardAd  *standardAd  = response.ads[0];

    XCTAssert([standardAd.type isEqualToString:@"banner"]);
    XCTAssert([standardAd.height isEqualToString:@"50"]);
    XCTAssert([standardAd.width isEqualToString:@"320"]);
    XCTAssertNotNil(standardAd.content);
}

- (void)testLocalSuccessfulMediationResponse {
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
    
    ANMediatedAd *secondMediatedAd = [response.ads objectAtIndex:1];
    ANMediatedAd *expectedSecondMediatedAd = [[ANMediatedAd alloc] init];
    expectedSecondMediatedAd.width = @"320";
    expectedSecondMediatedAd.height = @"50";
    expectedSecondMediatedAd.className = @"ANAdAdapterBannerMillennialMedia";
    expectedSecondMediatedAd.adId = @"148502";
    [self mediatedAd:secondMediatedAd equalToMediatedAd:expectedSecondMediatedAd];
    XCTAssertNotNil(secondMediatedAd.responseURL);

    ANMediatedAd *thirdMediatedAd = [response.ads objectAtIndex:2];
    ANMediatedAd *expectedThirdMediatedAd = [[ANMediatedAd alloc] init];
    expectedThirdMediatedAd.width = @"320";
    expectedThirdMediatedAd.height = @"50";
    expectedThirdMediatedAd.className = @"ANAdAdapterBannerAdMob";
    expectedThirdMediatedAd.adId = @"ca-app-pub-5668774179595841/1125462353";
    [self mediatedAd:thirdMediatedAd equalToMediatedAd:expectedThirdMediatedAd];
    XCTAssertNotNil(thirdMediatedAd.responseURL);
    
    ANMediatedAd *fourthMediatedAd = [response.ads objectAtIndex:3];
    ANMediatedAd *expectedFourthMediatedAd = [[ANMediatedAd alloc] init];
    expectedFourthMediatedAd.className = @"ANAdAdapterBanneriAd";
    [self mediatedAd:fourthMediatedAd equalToMediatedAd:expectedFourthMediatedAd];
    XCTAssertNotNil(fourthMediatedAd.responseURL);
}

- (void)mediatedAd:(ANMediatedAd *)parsedMediatedAd equalToMediatedAd:(ANMediatedAd *)comparisonMediatedAd {
    XCTAssertEqualObjects(parsedMediatedAd.width, comparisonMediatedAd.width);
    XCTAssertEqualObjects(parsedMediatedAd.height, comparisonMediatedAd.height);
    XCTAssertEqualObjects(parsedMediatedAd.className, comparisonMediatedAd.className);
    XCTAssertEqualObjects(parsedMediatedAd.adId, comparisonMediatedAd.adId);
}

@end
