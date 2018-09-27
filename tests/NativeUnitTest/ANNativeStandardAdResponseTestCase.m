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

#import "ANUniversalTagAdServerResponse.h"
#import "XCTestCase+ANCategory.h"
#import "ANMediatedAd.h"
#import "ANNativeStandardAdResponse.h"



@interface ANUniversalTagAdServerResponseTestCase : XCTestCase
    //EMPTY
@end


@implementation ANUniversalTagAdServerResponseTestCase

- (void)testMediationResponse {
    ANUniversalTagAdServerResponse *response = [[ANUniversalTagAdServerResponse alloc] initWithAdServerData:[self dataWithJSONResource:@"SuccessfulMediationResponse"]];

    XCTAssertEqual([response.ads count], 4);

    for (ANMediatedAd *mediatedAd in response.ads) {
        XCTAssertNotNil(mediatedAd.responseURL);
        XCTAssertNotNil(mediatedAd.className);
    }
}

- (void)testNativeResponse1 {
    ANUniversalTagAdServerResponse *response = [[ANUniversalTagAdServerResponse alloc] initWithAdServerData:[self dataWithJSONResource:@"nativeResponse1"]];
    XCTAssertTrue([response.ads count] > 0);

    ANNativeStandardAdResponse  *nativeAd  = (ANNativeStandardAdResponse *)response.ads[0];

    XCTAssertNotNil(nativeAd);
    XCTAssertNotNil(nativeAd.rating);
    XCTAssertEqual(nativeAd.rating.scale, 5);
    XCTAssertEqual(nativeAd.rating.value, 5.0);
    XCTAssertNotNil(nativeAd.title);
    XCTAssertNotNil(nativeAd.body);
    XCTAssertNotNil(nativeAd.iconImageURL);
    XCTAssertNotNil(nativeAd.mainImageURL);
    XCTAssertEqualObjects(nativeAd.creativeId, @"108");
}

# pragma mark - Invalid JSON

- (void)testNativeResponse2 {
    ANUniversalTagAdServerResponse *response = [[ANUniversalTagAdServerResponse alloc] initWithAdServerData:[self dataWithJSONResource:@"nativeResponse2"]];
    XCTAssertFalse([response.ads count] > 0);
}

- (void)testNativeResponse3 {
    ANUniversalTagAdServerResponse *response = [[ANUniversalTagAdServerResponse alloc] initWithAdServerData:[self dataWithJSONResource:@"nativeResponse3"]];
    XCTAssertFalse([response.ads count] > 0);
}

# pragma mark - Rating a string, not a object (dict)

- (void)testNativeResponse4 {
    ANUniversalTagAdServerResponse *response = [[ANUniversalTagAdServerResponse alloc] initWithAdServerData:[self dataWithJSONResource:@"nativeResponse4"]];
    XCTAssertTrue([response.ads count] > 0);

    ANNativeStandardAdResponse  *nativeAd  = (ANNativeStandardAdResponse *)response.ads[0];

    XCTAssertTrue(nativeAd.title);
    XCTAssertTrue(nativeAd.body);
    XCTAssertNil(nativeAd.rating);
}

#pragma mark - Invalid impression tracker array

- (void)testNativeResponse5 {
    ANUniversalTagAdServerResponse *response = [[ANUniversalTagAdServerResponse alloc] initWithAdServerData:[self dataWithJSONResource:@"nativeResponse5"]];
    XCTAssertTrue([response.ads count] > 0);

    ANNativeStandardAdResponse  *nativeAd  = (ANNativeStandardAdResponse *)response.ads[0];

    XCTAssertNotNil(nativeAd.clickTrackers);
    XCTAssertNil(nativeAd.impTrackers);
}

@end
