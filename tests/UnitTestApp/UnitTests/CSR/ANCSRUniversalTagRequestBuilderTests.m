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
#import "ANUniversalTagRequestBuilder.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "TestANCSRUniversalFetcher.h"


static NSTimeInterval    UTMODULETESTS_TIMEOUT  = 20.0;
static NSString  *PlacementID  = @"9924001";

@interface ANCSRUniversalTagRequestBuilderTests : XCTestCase

@end

@implementation ANCSRUniversalTagRequestBuilderTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testUTRequestWithoutTpuids
{
    
    TestANCSRUniversalFetcher  *adFetcher  = [[TestANCSRUniversalFetcher alloc] initWithPlacementId:PlacementID];
    
    
    NSURLRequest        *request        = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adFetcher.delegate];
    XCTestExpectation   *expectation    = [self expectationWithDescription:@"Dummy expectation"];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSError *error;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                        options:kNilOptions
                                                          error:&error];
        TESTTRACEM(@"jsonObject=%@", jsonObject);
        
        XCTAssertNil(error);
        XCTAssertNotNil(jsonObject);
        XCTAssertTrue([jsonObject isKindOfClass:[NSDictionary class]]);
        NSDictionary *jsonDict = (NSDictionary *)jsonObject;
        NSArray *tpuids = jsonDict[@"tpuids"];
        XCTAssertNil(tpuids);
        
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:UTMODULETESTS_TIMEOUT handler:nil];
}


@end
