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
#import "Constant.h"
@interface NativeViewabilityTrackerTests : XCTestCase

@end

@implementation NativeViewabilityTrackerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

/*
 testNativeAdOMIDOmidSupportedIsYes: To test the OMID is supported tracker is fired by the Native Ad.
*/
- (void)testNativeAdOMIDOmidSupportedIsYes {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"OmidSupported"];
    [app launch];

    XCUIElement *  result = app.tables.staticTexts[@"OmidSupported=true"];
    [self waitForElementToAppear:result  withTimeout:30];
}
/*
 testNativeAdOMIDOmidSessionStart: To test the OMID is Session Start & few related events are fired by the Native Ad.
 */
- (void)testNativeAdOMIDOmidSessionStart {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"SessionStart"];
    [app launch];

    XCUIElement *  result = app.tables.staticTexts[@"sessionStart"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"accessMode=limited"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"partnerName=Appnexus"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"mediaType=display"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"creativeType=nativeDisplay"];
    [self waitForElementToAppear:result  withTimeout:30];
}

/*
 testNativeAdOMIDOmidTypeLoaded: To test the OMID is loaded with different events like impressionType,mediaType & creativeType
 */
- (void)testNativeAdOMIDOmidTypeLoaded {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"TypeLoaded"];
    [app launch];

    XCUIElement *  result = app.tables.staticTexts[@"type=loaded"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"impressionType=viewable"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"mediaType=display"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"creativeType=nativeDisplay"];
    [self waitForElementToAppear:result  withTimeout:30];
}
/*
 testNativeAdOMIDOmidPercentageInView0: To test the OMID is 0% Viewable
 */
- (void)testNativeAdOMIDOmidPercentageInView0 {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"OmidPercentageInView0"];
    [app launch];

    XCUIElement *  result = app.tables.staticTexts[@"percentageInView=0"];
    [self waitForElementToAppear:result  withTimeout:30];
}

/*
 testNativeAdOMIDOmidPercentageInView100: To test the OMID is 100% Viewable
 */
- (void)testNativeAdOMIDOmidPercentageInView100 {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"OmidPercentageInView100"];
    [app launch];

    XCUIElement *  result = app.tables.staticTexts[@"percentageInView=MoreThan0"];
    [self waitForElementToAppear:result  withTimeout:30];
}
/*
 testNativeAdOMIDOmidSessionFinish: To verify Session finish getting fired
 */
- (void)testNativeAdOMIDOmidSessionFinish {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"SessionFinish"];
    [app launch];

    XCUIElement *  result = app.tables.staticTexts[@"type=sessionFinish"];
    [self waitForElementToAppear:result  withTimeout:40];
}



/*
 testBannerEnableOMIDOptimization: To test the OMID is session finish get called after 100% Viewable
 */
- (void)testBannerEnableOMIDOptimization {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"EnableOMIDOptimization"];

    app.launchArguments = [app.launchArguments arrayByAddingObject:@"SessionFinish"];
    [app launch];

    XCUIElement *  result = app.tables.staticTexts[@"type=sessionFinish"];
    [self waitForElementToAppear:result  withTimeout:60];
    XCUIElement * enableOMIDOptimization = app.tables.staticTexts[@"EnableOMIDOptimization"];
    [self waitForElementToAppear:result  withTimeout:10];
    
    

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

@end
