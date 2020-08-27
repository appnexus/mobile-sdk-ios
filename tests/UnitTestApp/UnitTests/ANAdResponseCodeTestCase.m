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
#import "ANAdResponseCode.h"

@interface ANAdResponseCodeTestCase : XCTestCase

@end

@implementation ANAdResponseCodeTestCase

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testAdResponseCodeErrorCodesAndMessages {
    ANAdResponseCode *code = ANAdResponseCode.DEFAULT;
    XCTAssert(code.code== -1);
    XCTAssert([code.message isEqualToString:@"DEFAULT"]);
    code = ANAdResponseCode.SUCCESS;
    XCTAssert(code.code== 0);
    XCTAssert([code.message isEqualToString:@"SUCCESS"]);
    code = ANAdResponseCode.INVALID_REQUEST;
    XCTAssert(code.code== 1);
    XCTAssert([code.message isEqualToString:@"invalid_request_error"]);
    code = ANAdResponseCode.UNABLE_TO_FILL;
    XCTAssert(code.code== 2);
    XCTAssert([code.message isEqualToString:@"response_no_ads"]);
    code = ANAdResponseCode.MEDIATED_SDK_UNAVAILABLE;
    XCTAssert(code.code== 3);
    XCTAssert([code.message isEqualToString:@"MEDIATED_SDK_UNAVAILABLE"]);
    code = ANAdResponseCode.NETWORK_ERROR;
    XCTAssert(code.code== 4);
    XCTAssert([code.message isEqualToString:@"ad_network_error"]);
    code = ANAdResponseCode.INTERNAL_ERROR;
    XCTAssert(code.code== 5);
    XCTAssert([code.message isEqualToString:@"ad_internal_error"]);
    code = ANAdResponseCode.REQUEST_TOO_FREQUENT;
    XCTAssert(code.code== 6);
    XCTAssert([code.message isEqualToString:@"ad_request_too_frequent_error"]);
    code = ANAdResponseCode.BAD_FORMAT;
    XCTAssert(code.code== 7);
    XCTAssert([code.message isEqualToString:@"BAD_FORMAT"]);
    code = ANAdResponseCode.BAD_URL;
    XCTAssert(code.code== 8);
    XCTAssert([code.message isEqualToString:@"BAD_URL"]);
    code = ANAdResponseCode.BAD_URL_CONNECTION;
    XCTAssert(code.code== 9);
    XCTAssert([code.message isEqualToString:@"BAD_URL_CONNECTION"]);
    code = ANAdResponseCode.NON_VIEW_RESPONSE;
    XCTAssert(code.code== 10);
    XCTAssert([code.message isEqualToString:@"NON_VIEW_RESPONSE"]);
    code = [ANAdResponseCode CUSTOM_ADAPTER_ERROR:@"CUSTOM_ADAPTER_ERROR"];
    XCTAssert(code.code== 11);
    XCTAssert([code.message isEqualToString:@"CUSTOM_ADAPTER_ERROR"]);
}

- (void)testAdResponseCodeCustomAdaptorError {
    ANAdResponseCode *code = [ANAdResponseCode CUSTOM_ADAPTER_ERROR:@"AdError::::::: CUSTOM_ADAPTER_ERROR"];
    XCTAssert(code.code== 11);
    XCTAssert([code.message isEqualToString:@"AdError::::::: CUSTOM_ADAPTER_ERROR"]);
}

- (void)testAdResponseCodeEquals {
    ANAdResponseCode *code1 = ANAdResponseCode.INTERNAL_ERROR;
    ANAdResponseCode *code2 = ANAdResponseCode.INTERNAL_ERROR;
    ANAdResponseCode *code3 = ANAdResponseCode.UNABLE_TO_FILL;
    XCTAssertTrue(code1.code== code2.code);
    XCTAssertFalse(code1.code== code3.code);
    XCTAssertFalse([code1 isEqual:code2]);
    XCTAssertFalse([code1 isEqual:code3]);
}

- (void)testAdResponseCodeShouldNotOverrideMessage {
    ANAdResponseCode *code = [ANAdResponseCode CUSTOM_ADAPTER_ERROR:@"AdError::::::: CUSTOM_ADAPTER_ERROR"];
    [self localScope];
    XCTAssert([code.message isEqualToString:@"AdError::::::: CUSTOM_ADAPTER_ERROR"]);
    
}

- (void)localScope {
    ANAdResponseCode *code = [ANAdResponseCode CUSTOM_ADAPTER_ERROR:@"AdError:localscope INTERNAL_ERROR"];
    XCTAssert([code.message isEqualToString:@"AdError:localscope INTERNAL_ERROR"]);
}

@end
