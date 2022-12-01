/*   Copyright 2019 APPNEXUS INC

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
#import "ANGPPSettings.h"

NSString * const  AN_IABGPP_HDR_GppString = @"IABGPP_HDR_GppString";
NSString * const  AN_IABGPP_GppSID = @"IABGPP_GppSID";

@interface ANGPPSettingsTestCase : XCTestCase

@end

@implementation ANGPPSettingsTestCase

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:AN_IABGPP_HDR_GppString];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:AN_IABGPP_GppSID];
}


- (void)testIABGPP_HDR_GppStringString
{
    [[NSUserDefaults standardUserDefaults] setObject:@"DBACNYA~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA~1YNN" forKey:AN_IABGPP_HDR_GppString];
    XCTAssertTrue([[ANGPPSettings getGPPString] isEqualToString:@"DBACNYA~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA~1YNN"]);
}

- (void)testIABTCFConsentStringWithEmpty
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:AN_IABGPP_HDR_GppString];
    XCTAssertTrue([[ANGPPSettings getGPPString] isEqualToString:@""]);
}


- (void)testIABGPP_GppSID
{
    [[NSUserDefaults standardUserDefaults] setObject:@"2_6" forKey:AN_IABGPP_GppSID];
    NSArray *gppSideArray = @[@2, @6];
    XCTAssertTrue([[ANGPPSettings getGPPSIDArray] isEqualToArray:gppSideArray]);
}

- (void)testIABGPP_GppSID_singleValueArray
{
    [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:AN_IABGPP_GppSID];
    NSArray *gppSideArray = @[@2];
    XCTAssertTrue([[ANGPPSettings getGPPSIDArray] isEqualToArray:gppSideArray]);
}

- (void)testIABGPP_GppSIDWithEmpty
{
    XCTAssertTrue([ANGPPSettings getGPPSIDArray] == nil);
}

@end

