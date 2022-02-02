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
@interface NativeAdTrackerTestVC : XCTestCase

@end

@implementation NativeAdTrackerTestVC

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}
/*
 testNativeImpressionTrackerTestAd: To test the impression tracker is fired by the Native Ad.
 */
- (void)testNativeImpressionTrackerTestAd {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeImpressionClickTrackerTest];
    [app launch];
    XCUIElement *impressionTracker = app.staticTexts[@"ImpressionTracker"];
    [self waitForElementToAppear:impressionTracker  withTimeout:ImpressionTrackerTimeout];;
    XCTAssertTrue(impressionTracker.exists);

    
}



/*
 testNativeClickTrackerTestAd: To test the click tracker is fired by the Native Ad.
 */
- (void)testNativeClickTrackerTestAd {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeImpressionClickTrackerTest];
    [app launch];
    XCUIElement *nativerenderercampaignClickButton = app.buttons[@"clickElements"] ;
    [self waitForElementToAppear:nativerenderercampaignClickButton  withTimeout:18];;
    [nativerenderercampaignClickButton tap];
    XCUIElement *clickActionOK =  app/*@START_MENU_TOKEN@*/.toolbars[@"Toolbar"]/*[[".otherElements[@\"In App Browser\"].toolbars[@\"Toolbar\"]",".toolbars[@\"Toolbar\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons[@"OK"] ;
    [self waitForElementToAppear:clickActionOK withTimeout:ClickTrackerTimeout];
    [clickActionOK tap];
    XCUIElement *clickTracker = app.staticTexts[@"ClickTracker"];
    [self waitForElementToAppear:clickTracker  withTimeout:ClickTrackerTimeout];;
    XCTAssertTrue(clickTracker.exists);

    
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


/*
 testNativeImpressionTrackerTestAd: To test the impression tracker is fired by the Native Ad.
 */
- (void)testNativeMultipleImpressionTrackerTestAd {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeImpressionClickTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeMultiImpressionTrackerTest];
    [app launch];
    XCUIElement *impressionTracker = app.staticTexts[@"MultiImpressionTracker"];
    [self waitForElementToAppear:impressionTracker  withTimeout:ImpressionTrackerTimeout*2];;
    XCTAssertTrue(impressionTracker.exists);

    
}



/*
 testNativeImpressionTrackerTestAd: To test the impression tracker is fired by the Native Ad.
 */
- (void)testNativeMultipleClickTrackerTestAd {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeImpressionClickTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeMultiClickTrackerTest];
    [app launch];
    XCUIElement *clickTracker = app.staticTexts[@"MultiClickTracker"];
    [self waitForElementToAppear:clickTracker  withTimeout:ImpressionTrackerTimeout*2];;
    XCTAssertTrue(clickTracker.exists);

    
}

@end
