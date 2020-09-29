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

#import "ANUniversalTagAdServerResponse.h"
#import "XCTestCase+ANCategory.h"
#import "ANMediatedAd.h"
#import "ANNativeStandardAdResponse.h"

@interface ANAdMediationTimeoutTestcase : XCTestCase

@end

@implementation ANAdMediationTimeoutTestcase

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testNativeMediationResponseTimeout {
    NSMutableArray<id>  *adsArray  = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:@"SuccessfulMediationResponse"]];

    XCTAssertEqual([adsArray count], 3);

    for (ANMediatedAd *mediatedAd in adsArray) {
        XCTAssertEqual(mediatedAd.networkTimeout,1500);
    }
}


- (void)testBannerMediationResponseTimeout {
    NSMutableArray<id>  *adsArray  = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:@"csm_bannerad"]];

    XCTAssertEqual([adsArray count], 1);

    for (ANMediatedAd *mediatedAd in adsArray) {
        XCTAssertEqual(mediatedAd.networkTimeout,3500);
    }
}



- (void)testMediationResponseDefaultTimeout {
    NSMutableArray<id>  *adsArray  = [TestGlobal adsArrayFromFirstTagInReponseData:[self dataWithJSONResource:@"SuccessfulMediationResponseDefaultTimeout"]];

    XCTAssertEqual([adsArray count], 3);

    for (ANMediatedAd *mediatedAd in adsArray) {
        XCTAssertEqual(mediatedAd.networkTimeout,15000);
    }
}
@end
