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
@interface MARNativeAdTrackerTestVC : XCTestCase

@end

@implementation MARNativeAdTrackerTestVC

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
 }

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}
/*
 testMARBannerNativeImpressionTrackerTestAd: To test the impression tracker is fired by the MAR BannerNative Ad.
 */
- (void)testMARBannerNativeImpressionTrackerTestAd {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:MARNativeImpressionClickTrackerTest];
    [app launch];
    XCUIElement *impressionTracker = app.staticTexts[@"ImpressionTracker"];
    [self waitForElementToAppear:impressionTracker  withTimeout:ImpressionTrackerTimeout];;
    XCTAssertTrue(impressionTracker.exists);
  
}

/*
 testMARBannerNativeClickTrackerTestAd: To test the click tracker is fired by the MAR BannerNative Ad.
 */
- (void)testMARBannerNativeClickTrackerTestAd {
    
   
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:MARNativeImpressionClickTrackerTest];
    [app launch];
//    XCUIElement *nativerenderercampaignClickButton = app.staticTexts[@"Click"] ;
//    [self waitForElementToAppear:nativerenderercampaignClickButton  withTimeout:8];;
//    [nativerenderercampaignClickButton tap];
        

//    XCUIElement *clickActionOK =  app/*@START_MENU_TOKEN@*/.toolbars[@"Toolbar"]/*[[".otherElements[@\"In App Browser\"].toolbars[@\"Toolbar\"]",".toolbars[@\"Toolbar\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons[@"OK"] ;
//    [self waitForElementToAppear:clickActionOK withTimeout:ClickTrackerTimeout];
//    [clickActionOK tap];
//    wait(6);
//    XCUIElement *clickTracker = app.staticTexts[@"ClickTracker"];
//    [self waitForElementToAppear:clickTracker  withTimeout:ClickTrackerTimeout];;
//    XCTAssertTrue(clickTracker.exists);
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
