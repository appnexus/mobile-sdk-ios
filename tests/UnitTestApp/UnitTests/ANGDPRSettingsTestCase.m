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
#import "ANGDPRSettings.h"

NSString * const  ANGDPR_ConsentString = @"ANGDPR_ConsentString";
NSString * const  ANGDPR_ConsentRequired = @"ANGDPR_ConsentRequired";
NSString * const  ANGDPR_PurposeConsents = @"ANGDPR_PurposeConsents";

//TCF 2.0 variables
NSString * const  ANIABTCF_ConsentString = @"IABTCF_TCString";
NSString * const  ANIABTCF_SubjectToGDPR = @"IABTCF_gdprApplies";
NSString * const  ANIABTCF_PurposeConsents = @"IABTCF_PurposeConsents";
// Gpp TCF 2.0 variabled
NSString * const  ANIABGPP_TCFEU2_PurposeConsents = @"IABGPP_TCFEU2_PurposeConsents";
NSString * const  ANIABGPP_TCFEU2_SubjectToGDPR = @"IABGPP_TCFEU2_gdprApplies";

//TCF 1.1 variables
NSString * const  ANIABConsent_ConsentString = @"IABConsent_ConsentString";
NSString * const  ANIABConsent_SubjectToGDPR = @"IABConsent_SubjectToGDPR";

@interface ANGDPRSettingsTestCase : XCTestCase

@end

@implementation ANGDPRSettingsTestCase

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    [ANGDPRSettings reset];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ANIABTCF_ConsentString];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ANIABConsent_ConsentString];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ANIABTCF_SubjectToGDPR];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ANIABConsent_SubjectToGDPR];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ANIABTCF_PurposeConsents];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ANIABGPP_TCFEU2_PurposeConsents];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ANIABGPP_TCFEU2_SubjectToGDPR];
    
}

- (void)testGDPRConsentString
{
    [ANGDPRSettings setConsentString:@"BOMyQRvOMyQRvABABBAAABAAAAAAEA"];
    XCTAssertTrue([[ANGDPRSettings getConsentString] isEqualToString:@"BOMyQRvOMyQRvABABBAAABAAAAAAEA"]);
}

- (void)testGDPRConsentStringWithEmpty
{
    [ANGDPRSettings setConsentString:@""];
    XCTAssertTrue([[ANGDPRSettings getConsentString] isEqualToString:@""]);
}

- (void)testIABTCFConsentString
{
    [[NSUserDefaults standardUserDefaults] setObject:@"BOMyQRvOMyQRvABABBAAABAAAAAAEA" forKey:ANIABTCF_ConsentString];
    XCTAssertTrue([[ANGDPRSettings getConsentString] isEqualToString:@"BOMyQRvOMyQRvABABBAAABAAAAAAEA"]);
}

- (void)testIABTCFConsentStringWithEmpty
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:ANIABTCF_ConsentString];
    XCTAssertTrue([[ANGDPRSettings getConsentString] isEqualToString:@""]);
}

- (void)testIABConsentString
{
    [[NSUserDefaults standardUserDefaults] setObject:@"BOMyQRvOMyQRvABABBAAABAAAAAAEA" forKey:ANIABConsent_ConsentString];
    XCTAssertTrue([[ANGDPRSettings getConsentString] isEqualToString:@"BOMyQRvOMyQRvABABBAAABAAAAAAEA"]);
}

- (void)testIABConsentStringWithEmpty
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:ANIABConsent_ConsentString];
    XCTAssertTrue([[ANGDPRSettings getConsentString] isEqualToString:@""]);
}

- (void)testGDPRConsentRequiredTrue
{
    [ANGDPRSettings setConsentRequired:[NSNumber numberWithInt:1]];
    XCTAssertTrue([[ANGDPRSettings getConsentRequired] boolValue] == true);
}

- (void)testGDPRConsentRequiredFalse
{
    [ANGDPRSettings setConsentRequired:[NSNumber numberWithInt:0]];
    XCTAssertTrue([[ANGDPRSettings getConsentRequired] boolValue] == false);
}

- (void)testIABTCFConsentRequiredTrue
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:1] forKey:ANIABTCF_SubjectToGDPR];
    XCTAssertTrue([[ANGDPRSettings getConsentRequired] boolValue] == true);
}

- (void)testIABTCFConsentRequiredFalse
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:ANIABTCF_SubjectToGDPR];
    XCTAssertTrue([[ANGDPRSettings getConsentRequired] boolValue] == false);
}

- (void)testIABConsentRequiredTrue
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:1] forKey:ANIABConsent_SubjectToGDPR];
    XCTAssertTrue([[ANGDPRSettings getConsentRequired] boolValue] == true);
}

- (void)testIABConsentRequiredFalse
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:ANIABConsent_SubjectToGDPR];
    XCTAssertTrue([[ANGDPRSettings getConsentRequired] boolValue] == false);
}

- (void)testGDPRPurposeConsents
{
    [ANGDPRSettings setPurposeConsents:@"10101001"];
    XCTAssertTrue([[ANGDPRSettings getDeviceAccessConsent] isEqualToString:@"1"]);
}

- (void)testGDPRPurposeConsentsEmpty
{
    [ANGDPRSettings setPurposeConsents:@""];
    XCTAssertTrue([ANGDPRSettings getDeviceAccessConsent] == nil);
}

- (void)testIABTCFPurposeConsents
{
    [[NSUserDefaults standardUserDefaults] setObject:@"10101001" forKey:ANIABTCF_PurposeConsents];
    XCTAssertTrue([[ANGDPRSettings getDeviceAccessConsent] isEqualToString:@"1"]);
}

- (void)testIABTCFPurposeConsentsEmpty
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:ANIABTCF_PurposeConsents];
    XCTAssertTrue([ANGDPRSettings getDeviceAccessConsent] == nil);
}

- (void)testAccessDeviceData_PurposeConsentsEmpty_ConsentRequiredEmpty
{
    XCTAssertTrue([ANGDPRSettings canAccessDeviceData] == true);
}

- (void)testAccessDeviceData_PurposeConsentsEmpty_ConsentRequiredFalse
{
    [ANGDPRSettings setConsentRequired:[NSNumber numberWithInt:0]];
    XCTAssertTrue([ANGDPRSettings canAccessDeviceData] == true);
}

- (void)testAccessDeviceData_PurposeConsentsEmpty_IABTCFConsentRequiredFalse
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:ANIABTCF_SubjectToGDPR];
    XCTAssertTrue([ANGDPRSettings canAccessDeviceData] == true);
}

- (void)testAccessDeviceData_PurposeConsentsEmpty_IABConsentRequiredFalse
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:ANIABConsent_SubjectToGDPR];
    XCTAssertTrue([ANGDPRSettings canAccessDeviceData] == true);
}

- (void)testAccessDeviceData_PurposeConsentsEmpty_ConsentRequiredTrue
{
    [ANGDPRSettings setConsentRequired:[NSNumber numberWithInt:1]];
    XCTAssertTrue([ANGDPRSettings canAccessDeviceData] == false);
}

- (void)testAccessDeviceData_PurposeConsentsEmpty_IABTCFConsentRequiredTrue
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:1] forKey:ANIABTCF_SubjectToGDPR];
    XCTAssertTrue([ANGDPRSettings canAccessDeviceData] == false);
}

- (void)testAccessDeviceData_PurposeConsentsEmpty_IABConsentRequiredTrue
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:1] forKey:ANIABConsent_SubjectToGDPR];
    XCTAssertTrue([ANGDPRSettings canAccessDeviceData] == false);
}

- (void)testAccessDeviceData_GDPR_PurposeConsents_True
{
   [ANGDPRSettings setPurposeConsents:@"10101001"];
    XCTAssertTrue([ANGDPRSettings canAccessDeviceData] == true);
}

- (void)testAccessDeviceData_IABTCF_PurposeConsents_True
{
    [[NSUserDefaults standardUserDefaults] setObject:@"10101001" forKey:ANIABTCF_PurposeConsents];
    XCTAssertTrue([ANGDPRSettings canAccessDeviceData] == true);
}

- (void)testAccessDeviceData_GDPR_PurposeConsents_False
{
   [ANGDPRSettings setPurposeConsents:@"01010110"];
    XCTAssertTrue([ANGDPRSettings canAccessDeviceData] == false);
}

- (void)testAccessDeviceData_IABTCF_PurposeConsents_False
{
    [[NSUserDefaults standardUserDefaults] setObject:@"01010110" forKey:ANIABTCF_PurposeConsents];
    XCTAssertTrue([ANGDPRSettings canAccessDeviceData] == false);
}


- (void)testAccessDeviceData_IABGPP_TCFEU2_PurposeConsents_True
{
    [[NSUserDefaults standardUserDefaults] setObject:@"10101001" forKey:ANIABGPP_TCFEU2_PurposeConsents];
    XCTAssertTrue([ANGDPRSettings canAccessDeviceData] == true);
}


- (void)testAccessDeviceData_IABGPP_TCFEU2_PurposeConsents_False
{
    [[NSUserDefaults standardUserDefaults] setObject:@"01010110" forKey:ANIABGPP_TCFEU2_PurposeConsents];
    XCTAssertTrue([ANGDPRSettings canAccessDeviceData] == false);
}

@end
