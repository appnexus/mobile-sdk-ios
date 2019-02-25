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
#import "ANSDKSettings.h"
#import "ANGlobal.h"

@interface ANSDKSettingsTestCase : XCTestCase

@end

@implementation ANSDKSettingsTestCase

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}


-(void)testCustomUserAgentSet{
    NSString *customUserAgentValue =  @"Mozilla/5.0 (iPhone; CPU iPhone OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12B411 Appended Custom User Agent";
    ANSDKSettings.sharedInstance.customUserAgent = customUserAgentValue;
    XCTAssertEqual([ANGlobal getUserAgent], customUserAgentValue);
    
}

-(void)testCustomUserAgentSetEmpryString{
    NSString *customUserAgentValue =  @"";
    ANSDKSettings.sharedInstance.customUserAgent = customUserAgentValue;
    XCTAssertNotEqual([ANGlobal getUserAgent], @"");
    
}


-(void)testCustomUserAgentSetNil{
    NSString *customUserAgentValue =  nil;
    ANSDKSettings.sharedInstance.customUserAgent = customUserAgentValue;
    XCTAssertNotNil([ANGlobal getUserAgent]);
    
}

-(void)testCustomUserAgentNotSet{
    NSString *customUserAgentValue =  nil;
    ANSDKSettings.sharedInstance.customUserAgent = customUserAgentValue;
    XCTAssertNotNil([ANGlobal getUserAgent]);
}

@end
