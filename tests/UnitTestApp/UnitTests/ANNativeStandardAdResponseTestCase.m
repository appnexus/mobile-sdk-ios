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

#import "ANUniversalTagAdServerResponse.h"
#import "XCTestCase+ANCategory.h"
#import "ANMediatedAd.h"
#import "ANNativeStandardAdResponse.h"



@interface ANUniversalTagAdServerResponseTestCase : XCTestCase
    //EMPTY
@end


@implementation ANUniversalTagAdServerResponseTestCase

- (void)testMediationResponse {
    NSMutableArray<id>  *adsArray  = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:@"SuccessfulMediationResponse"]];

    XCTAssertEqual([adsArray count], 3);

    for (ANMediatedAd *mediatedAd in adsArray) {
        XCTAssertNotNil(mediatedAd.responseURL);
        XCTAssertNotNil(mediatedAd.className);
    }
}

// Native Video
- (void)testNativeVideoResponse {
    NSMutableArray<id>  *adsArray  = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:@"native_videoResponse"]];

    XCTAssertTrue([adsArray count] > 0);
    
    ANNativeStandardAdResponse  *nativeAd  = (ANNativeStandardAdResponse *)adsArray[0];
    
    XCTAssertNotNil(nativeAd);
    XCTAssertNotNil(nativeAd.rating);
    XCTAssertEqual(nativeAd.rating.scale, -1);
    XCTAssertEqual(nativeAd.rating.value, 9);
    XCTAssertNotNil(nativeAd.body);
    XCTAssertEqualObjects(nativeAd.title, @"CatsTitle2");
    XCTAssertEqualObjects(nativeAd.iconImageURL, [NSURL URLWithString:@"http://vcdn.adnxs.com/p/creative-image/fe/11/65/cb/fe1165cb-a0bf-4860-b9a9-d97990f250c3.png"]);
     XCTAssertEqualObjects(nativeAd.mainImageURL, [NSURL URLWithString:@"http://vcdn.adnxs.com/p/creative-image/40/c3/f0/78/40c3f078-d2da-4350-802a-cca04a96fc4f.jpg"]);
    XCTAssertEqualObjects(nativeAd.creativeId, @"123017179");
    XCTAssertEqual(nativeAd.iconImageSize.width, 144);
    XCTAssertEqual(nativeAd.iconImageSize.height, 160);
    // Native Video
    XCTAssertNotNil(nativeAd.vastXML);
    XCTAssertEqualObjects(nativeAd.privacyLink, @"https://www.appnexus.com/platform-privacy-policy");
}

- (void)testNativeResponse {
    NSMutableArray<id>  *adsArray  = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:@"appnexus_standard_response"]];

    XCTAssertTrue([adsArray count] > 0);

    ANNativeStandardAdResponse  *nativeAd  = (ANNativeStandardAdResponse *)adsArray[0];

    XCTAssertNotNil(nativeAd);
    XCTAssertNotNil(nativeAd.rating);
    XCTAssertEqual(nativeAd.rating.scale, -1);
    XCTAssertEqual(nativeAd.rating.value, 5.0);
    XCTAssertEqualObjects(nativeAd.title, @"AppNexusSDKApp");
    XCTAssertNotNil(nativeAd.body);
    XCTAssertEqualObjects(nativeAd.iconImageURL, [NSURL URLWithString:@"http://vcdn.adnxs.com/p/creative-image/17/3d/33/81/173d3381-9364-4b4a-8303-da65cae1c6f0.png"]);
    XCTAssertEqualObjects(nativeAd.mainImageURL, [NSURL URLWithString:@"http://vcdn.adnxs.com/p/creative-image/64/3a/13/fc/643a13fc-290d-40a2-b1f8-e8a8161234e5.png"]);
    XCTAssertEqualObjects(nativeAd.creativeId, @"111796070");
    XCTAssertEqual(nativeAd.iconImageSize.width, 600);
    XCTAssertEqual(nativeAd.iconImageSize.height, 500);
    XCTAssertNil(nativeAd.privacyLink);
    XCTAssertNil(nativeAd.vastXML);

}





# pragma mark - Invalid JSON

- (void)testNativeResponseInvalid1 {
    NSMutableArray<id>  *adsArray  = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:@"nativeResponse1"]];
    XCTAssertFalse([adsArray count] > 0);
}

- (void)testNativeResponseInvalid2 {
    NSMutableArray<id>  *adsArray  = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:@"nativeResponse2"]];
    XCTAssertFalse([adsArray count] > 0);
}


- (void)testNativeNoImpTrackers {
    NSMutableArray<id>  *adsArray  = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:@"nativeResponseWithoutImpTrackers"]];
    XCTAssertTrue([adsArray count] > 0);

    ANNativeStandardAdResponse  *nativeAd  = (ANNativeStandardAdResponse *)adsArray[0];

    XCTAssertTrue(nativeAd.title);
    XCTAssertTrue(nativeAd.body);
    XCTAssertNil(nativeAd.rating);
    XCTAssertNotNil(nativeAd.clickTrackers);
    XCTAssertNil(nativeAd.impTrackers);
}


@end
