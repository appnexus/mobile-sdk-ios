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
#import "ANLocation.h"

static CGFloat const kAppNexusNewYorkLocationLatitudeFull = 40.7418474;
static CGFloat const kAppNexusNewYorkLocationLongitudeFull = -73.99096229999998;
static CGFloat const kAppNexusNewYorkHorizontalAccuracy = 150;

static CGFloat const kAppNexusNewYorkLocationLatitudeTwoDecimalPlaces = 40.74;
static CGFloat const kAppNexusNewYorkLocationLongitudeTwoDecimalPlaces = -73.99;

static CGFloat const kAppNexusNewYorkLocationLatitudeOneDecimalPlace = 40.7;
static CGFloat const kAppNexusNewYorkLocationLongitudeOneDecimalPlace = -74.0;

static CGFloat const kAppNexusNewYorkLocationLatitudeNoDecimalPlaces = 41;
static CGFloat const kAppNexusNewYorkLocationLongitudeNoDecimalPlaces = -74;

@interface ANLocationTestCase : XCTestCase

@end

@implementation ANLocationTestCase

- (void)testPrecisionTwoDecimalPlaces {
    ANLocation *location = [ANLocation getLocationWithLatitude:kAppNexusNewYorkLocationLatitudeFull
                                                     longitude:kAppNexusNewYorkLocationLongitudeFull
                                                     timestamp:[NSDate date]
                                            horizontalAccuracy:kAppNexusNewYorkHorizontalAccuracy
                                                     precision:2];
    XCTAssertNotNil(location);
    XCTAssertEqual(location.latitude, kAppNexusNewYorkLocationLatitudeTwoDecimalPlaces);
    XCTAssertEqual(location.longitude, kAppNexusNewYorkLocationLongitudeTwoDecimalPlaces);
    XCTAssertEqual(location.horizontalAccuracy, kAppNexusNewYorkHorizontalAccuracy);
}

- (void)testPrecisionOneDecimalPlace {
    ANLocation *location = [ANLocation getLocationWithLatitude:kAppNexusNewYorkLocationLatitudeFull
                                                     longitude:kAppNexusNewYorkLocationLongitudeFull
                                                     timestamp:[NSDate date]
                                            horizontalAccuracy:kAppNexusNewYorkHorizontalAccuracy
                                                     precision:1];
    XCTAssertNotNil(location);
    XCTAssertEqual(location.latitude, kAppNexusNewYorkLocationLatitudeOneDecimalPlace);
    XCTAssertEqual(location.longitude, kAppNexusNewYorkLocationLongitudeOneDecimalPlace);
    XCTAssertEqual(location.horizontalAccuracy, kAppNexusNewYorkHorizontalAccuracy);
}

- (void)testPrecisionNoDecimalPlaces {
    ANLocation *location = [ANLocation getLocationWithLatitude:kAppNexusNewYorkLocationLatitudeFull
                                                     longitude:kAppNexusNewYorkLocationLongitudeFull
                                                     timestamp:[NSDate date]
                                            horizontalAccuracy:kAppNexusNewYorkHorizontalAccuracy
                                                     precision:0];
    XCTAssertNotNil(location);
    XCTAssertEqual(location.latitude, kAppNexusNewYorkLocationLatitudeNoDecimalPlaces);
    XCTAssertEqual(location.longitude, kAppNexusNewYorkLocationLongitudeNoDecimalPlaces);
    XCTAssertEqual(location.horizontalAccuracy, kAppNexusNewYorkHorizontalAccuracy);
}

- (void)testPrecisionWithNoPrecision {
    ANLocation *location = [ANLocation getLocationWithLatitude:kAppNexusNewYorkLocationLatitudeFull
                                                     longitude:kAppNexusNewYorkLocationLongitudeFull
                                                     timestamp:[NSDate date]
                                            horizontalAccuracy:kAppNexusNewYorkHorizontalAccuracy
                                                     precision:-1];
    XCTAssertNotNil(location);
    XCTAssertEqual(location.latitude, kAppNexusNewYorkLocationLatitudeFull);
    XCTAssertEqual(location.longitude, kAppNexusNewYorkLocationLongitudeFull);
    XCTAssertEqual(location.horizontalAccuracy, kAppNexusNewYorkHorizontalAccuracy);
}

- (void)testNegativePrecision {
    ANLocation *location = [ANLocation getLocationWithLatitude:kAppNexusNewYorkLocationLatitudeFull
                                                     longitude:kAppNexusNewYorkLocationLongitudeFull
                                                     timestamp:[NSDate date]
                                            horizontalAccuracy:kAppNexusNewYorkHorizontalAccuracy
                                                     precision:-3];
    XCTAssertEqual(location.latitude, kAppNexusNewYorkLocationLatitudeFull);
    XCTAssertEqual(location.longitude, kAppNexusNewYorkLocationLongitudeFull);
    XCTAssertEqual(location.horizontalAccuracy, kAppNexusNewYorkHorizontalAccuracy);
}

- (void)testNoPrecision {
    ANLocation *location = [ANLocation getLocationWithLatitude:kAppNexusNewYorkLocationLatitudeFull
                                                     longitude:kAppNexusNewYorkLocationLongitudeFull
                                                     timestamp:[NSDate date]
                                            horizontalAccuracy:kAppNexusNewYorkHorizontalAccuracy];
    XCTAssertNotNil(location);
    XCTAssertEqual(location.latitude, kAppNexusNewYorkLocationLatitudeFull);
    XCTAssertEqual(location.longitude, kAppNexusNewYorkLocationLongitudeFull);
    XCTAssertEqual(location.horizontalAccuracy, kAppNexusNewYorkHorizontalAccuracy);
}

@end
