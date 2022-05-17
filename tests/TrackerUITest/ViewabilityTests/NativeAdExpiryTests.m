/*   Copyright 2022 APPNEXUS INC
 
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
#import "Constant.h"
@interface NativeAdExpiryTests : XCTestCase

@end

@implementation NativeAdExpiryTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testRTBNativeAdExpiry {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeAdExpiry];
    [app launch];

    
    XCUIElement *adWillExpire = app.tables.staticTexts[@"adWillExpire"];
    [self waitForElementToAppear:adWillExpire  withTimeout:280];
    
    XCUIElement *adDidExpire = app.tables.staticTexts[@"adDidExpire"];
    [self waitForElementToAppear:adDidExpire  withTimeout:300];

}


- (void)testRTBNativeAdExpiryBackground270 {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeAdExpiry];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeAdExpiry_270];
    [app launch];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [XCUIDevice.sharedDevice pressButton: XCUIDeviceButtonHome];
      });
      
    [self wait:270];

    [[XCUIApplication new] activate];
    XCUIElement *result = app.tables.staticTexts[@"adWillExpire"];
    [self waitForElementToAppear:result  withTimeout:295];

    result = app.tables.staticTexts[@"adDidExpire"];
    [self waitForElementToAppear:result  withTimeout:60];
}



- (void)testRTBNativeAdExpiryBackground300 {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeAdExpiry];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeAdExpiry_310];
    [app launch];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 100 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [XCUIDevice.sharedDevice pressButton: XCUIDeviceButtonHome];
      });
    
    [self wait:310];
    [[XCUIApplication new] activate];

     XCUIElement *adWillExpire = app.tables.staticTexts[@"adWillExpire"];
    [self waitForElementToAppear:adWillExpire  withTimeout:320];

    XCUIElement *adDidExpire = app.tables.staticTexts[@"adDidExpire"];
    [self waitForElementToAppear:adDidExpire  withTimeout:10];
}

/**
  Wait n amount of time for XCUIElement to appear on the screen
  @param element : XCUIElement that's required to appear.
  @param timeout : time for that UIElement wait for to appear.
 */
- (void)waitForElementToAppear:(XCUIElement *)element withTimeout:(NSTimeInterval)timeout
{
    
    NSPredicate *exists = [NSPredicate predicateWithFormat:@"exists == 1"];
    
    [self expectationForPredicate:exists evaluatedWithObject:element handler:nil];
    [self waitForExpectationsWithTimeout:timeout handler:nil];
}



- (void)wait:(NSUInteger)interval {

    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:interval handler:nil];
}
@end
