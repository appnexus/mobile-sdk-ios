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
#import "ANAdServerResponse.h"
#import "XCTestCase+ANCategory.h"
#import "ANMediatedAd.h"

@interface ANUniversalTagAdServerResponseTestCase : XCTestCase
    //EMPTY
@end


@implementation ANUniversalTagAdServerResponseTestCase

- (void)testMediationResponse {
    ANAdServerResponse *response = [[ANAdServerResponse alloc] initWithAdServerData:[self dataWithJSONResource:@"SuccessfulMediationResponse"]];
    XCTAssertTrue(response.containsAds);
    XCTAssertEqual(response.mediatedAds.count, 4);
    for (ANMediatedAd *mediatedAd in response.mediatedAds) {
        XCTAssertNotNil(mediatedAd.resultCB);
        XCTAssertNotNil(mediatedAd.className);
    }
    XCTAssertNil(response.nativeAd);
}

- (void)testNativeResponse1 {
    ANAdServerResponse *response = [[ANAdServerResponse alloc] initWithAdServerData:[self dataWithJSONResource:@"nativeResponse1"]];
    XCTAssertTrue(response.containsAds);
    XCTAssertNotNil(response.nativeAd);
    XCTAssertNotNil(response.nativeAd.rating);
    XCTAssertEqual(response.nativeAd.rating.scale, 5);
    XCTAssertEqual(response.nativeAd.rating.value, 5.0);
    XCTAssertNotNil(response.nativeAd.title);
    XCTAssertNotNil(response.nativeAd.body);
    XCTAssertNotNil(response.nativeAd.iconImageURL);
    XCTAssertNotNil(response.nativeAd.mainImageURL);
}

# pragma mark - Invalid JSON

- (void)testNativeResponse2 {
    ANAdServerResponse *response = [[ANAdServerResponse alloc] initWithAdServerData:[self dataWithJSONResource:@"nativeResponse2"]];
    XCTAssertFalse(response.containsAds);
}

- (void)testNativeResponse3 {
    ANAdServerResponse *response = [[ANAdServerResponse alloc] initWithAdServerData:[self dataWithJSONResource:@"nativeResponse3"]];
    XCTAssertFalse(response.containsAds);
}

# pragma mark - Rating a string, not a object (dict)

- (void)testNativeResponse4 {
    ANAdServerResponse *response = [[ANAdServerResponse alloc] initWithAdServerData:[self dataWithJSONResource:@"nativeResponse4"]];
    XCTAssertTrue(response.containsAds);
    XCTAssertTrue(response.nativeAd.title);
    XCTAssertTrue(response.nativeAd.body);
    XCTAssertNil(response.nativeAd.rating);
}

#pragma mark - Invalid impression tracker array

- (void)testNativeResponse5 {
    ANAdServerResponse *response = [[ANAdServerResponse alloc] initWithAdServerData:[self dataWithJSONResource:@"nativeResponse5"]];
    XCTAssertTrue(response.containsAds);
    XCTAssertNotNil(response.nativeAd.clickTrackers);
    XCTAssertNil(response.nativeAd.impTrackers);
}

@end
