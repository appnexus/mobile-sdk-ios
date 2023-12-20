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
#import <AppNexusSDK/ANSDKSettings.h>
@interface ANSDKSettingsTestCase : XCTestCase

@end

@implementation ANSDKSettingsTestCase

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSDKVersion {
    XCTAssertEqualObjects([[[NSBundle bundleForClass: [ANSDKSettings class]] infoDictionary] objectForKey:@"CFBundleShortVersionString"], ANSDKSettings.sharedInstance.sdkVersion);
}

- (void)testSDKBundleIdentifier {
    XCTAssertTrue([[[NSBundle bundleForClass: [ANSDKSettings class]] bundleIdentifier] isEqualToString:@"corp.appnexus.AppNexusSDK"]);
}

- (void)testOverrideCountryCode {
    ANSDKSettings.sharedInstance.geoOverrideCountryCode = @"US";
    XCTAssertEqual(@"US", ANSDKSettings.sharedInstance.geoOverrideCountryCode);
}

- (void)testOverrideZipCode {
    ANSDKSettings.sharedInstance.geoOverrideZipCode = @"226006";
    XCTAssertEqual(@"226006", ANSDKSettings.sharedInstance.geoOverrideZipCode);
}

- (void)testResetOverrideCountryCode {
    ANSDKSettings.sharedInstance.geoOverrideCountryCode = @"";
    XCTAssertTrue(ANSDKSettings.sharedInstance.geoOverrideCountryCode.length == 0);
}

- (void)testResetOverrideZipCode {
    ANSDKSettings.sharedInstance.geoOverrideZipCode = @"";
    XCTAssertTrue(ANSDKSettings.sharedInstance.geoOverrideCountryCode.length == 0);
}

- (void)testContentLanguage {
    ANSDKSettings.sharedInstance.contentLanguage = @"EN";
    XCTAssertEqual(@"EN", ANSDKSettings.sharedInstance.contentLanguage);
}

- (void)testResetContentLanguage {
    ANSDKSettings.sharedInstance.contentLanguage = @"";
    XCTAssertTrue(ANSDKSettings.sharedInstance.contentLanguage.length == 0);
}

@end
