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
@interface InterstitialViewabilityTrackerTests : XCTestCase

@end

@implementation InterstitialViewabilityTrackerTests

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
 testInterstitialOMIDEventSupportedIsYes: To test the OMID is supported tracker is fired by the Interstitial Ad.
 */
-(void)testInterstitialOMIDEventSupportedIsYes{
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:InterstitialViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"SupportedIsYes"];
    [app launch];
    XCUIElement *  result = app.tables.staticTexts[@"supported=yes"];
    [self waitForElementToAppear:result  withTimeout:30];
}

/*
 testInterstitialOMIDEventSessionStart: To test the OMID is Session Start & few related events are fired by the Interstitial Ad.
 */
-(void)testInterstitialOMIDEventSessionStart{
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:InterstitialViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"SessionStart"];
    [app launch];

    XCUIElement *  result = app.tables.staticTexts[@"environment=app"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"adSessionType=html"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"supports=[clid,vlid]"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"sessionStart"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"mediaType=display"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"partnerName=Appnexus"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"deviceInfo=iOS"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"impressionType=viewable"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"creativeType=htmlDisplay"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"omidJsInfo=serviceVersion,omidImplementer:omsdk"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"app={appId,libraryVersion}"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"verificationParameters=undefined"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"accessMode=limited"];
    [self waitForElementToAppear:result  withTimeout:30];
        
}

/*
 testInterstitialOMIDEventViewable100Percentage: To test the OMID is 100% Viewable
 */
- (void)testInterstitialOMIDEventViewable100Percentage {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:InterstitialViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"Viewable100Percentage"];
    [app launch];
    
    XCUIElement *result = app.tables.staticTexts[@"percentageInView=100"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"type=geometryChange"];
    [self waitForElementToAppear:result  withTimeout:30];
}
/*
 testInterstitialOMIDVersionEvent: To verify the OMID version
 */
- (void)testInterstitialOMIDVersionEvent {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:InterstitialViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"VersionEvent"];
    [app launch];
    
    XCUIElement *  result = app.tables.staticTexts[@"version="];
    [self waitForElementToAppear:result  withTimeout:40];

}

/*
 testInterstitialOMIDEventViewable0Percentage: To test the OMID is 0% Viewable
 */
- (void)testInterstitialOMIDEventViewable0Percentage {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:InterstitialViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"Viewable0Percentage"];
    [app launch];
    XCUIElement *result = app.tables.staticTexts[@"percentageInView=0"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"type=geometryChange"];
    [self waitForElementToAppear:result  withTimeout:30];

}
/*
 testInterstitialOMIDTypeImpression: To test the OMID Media Type and impressionType
 */
- (void)testInterstitialOMIDTypeImpression {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:InterstitialViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"TypeImpression"];
    [app launch];
    XCUIElement *  result = app.tables.staticTexts[@"type=impression"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"impressionType=viewable"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"mediaType=display"];
    [self waitForElementToAppear:result  withTimeout:30];
    result = app.tables.staticTexts[@"creativeType=htmlDisplay"];
    [self waitForElementToAppear:result  withTimeout:30];
}

/*
 testInterstitialOMIDSessionFinish: To verify Session finish getting fired
 */
- (void)testInterstitialOMIDSessionFinish {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:InterstitialViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"SessionFinish"];
    [app launch];
    XCUIElement * result = app.tables.staticTexts[@"type=sessionFinish"];
    [self waitForElementToAppear:result  withTimeout:30];
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
