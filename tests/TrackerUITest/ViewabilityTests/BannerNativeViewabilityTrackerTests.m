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
@interface BannerNativeViewabilityTrackerTests : XCTestCase

@end

@implementation BannerNativeViewabilityTrackerTests

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
 testBannerNativeAdOMIDOmidSupportedIsYes: To test the OMID is supported tracker is fired by the Banner Native Ad.
*/
- (void)testBannerNativeAdOMIDOmidSupportedIsYes {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerNativeViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"OmidSupported"];
    [app launch];

    XCUIElement *  result = app.tables.staticTexts[@"OmidSupported=true"];
    [self waitForElementToAppear:result  withTimeout:30];
}
/*
 testBannerNativeAdOMIDOmidSessionStart: To test the OMID is Session Start & few related events are fired by the BannerNative Ad.
 */
- (void)testBannerNativeAdOMIDOmidSessionStart {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerNativeViewabilityTrackerTest];
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
 testBannerNativeAdOMIDOmidTypeLoaded: To test the OMID is loaded with different events like impressionType,mediaType & creativeType
 */
- (void)testBannerNativeAdOMIDOmidTypeLoaded {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerNativeViewabilityTrackerTest];
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
 testBannerNativeAdOMIDOmidPercentageInView0: To test the OMID is 0% Viewable
 */
- (void)testBannerNativeAdOMIDOmidPercentageInView0 {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerNativeViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"OmidPercentageInView0"];
    [app launch];

    XCUIElement *  result = app.tables.staticTexts[@"percentageInView=0"];
    [self waitForElementToAppear:result  withTimeout:30];
}

/*
 testBannerNativeAdOMIDOmidPercentageInView100: To test the OMID is 100% Viewable
 */
- (void)testBannerNativeAdOMIDOmidPercentageInView100 {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerNativeViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"OmidPercentageInView100"];
    [app launch];

    XCUIElement *  result = app.tables.staticTexts[@"percentageInView=MoreThan0"];
    [self waitForElementToAppear:result  withTimeout:30];
}

/*
 testBannerNativeAdOMIDOmidSessionFinish: To verify Session finish getting fired
 */
- (void)testBannerNativeAdOMIDOmidSessionFinish {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerNativeViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"SessionFinish"];
    [app launch];

    XCUIElement *  result = app.tables.staticTexts[@"type=sessionFinish"];
    [self waitForElementToAppear:result  withTimeout:30];
}



/*
 testBannerEnableOMIDOptimization: To test the OMID is session finish get called after 100% Viewable
 */
- (void)testBannerNativeEnableOMIDOptimization {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerNativeViewabilityTrackerTest];
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

/*
 testBannerNativeRendererAdOMIDOmidSupportedIsYes: To test the OMID is supported tracker is fired by the Banner Native Renderer Ad.
*/
- (void)testBannerNativeRendererAdOMIDOmidSupportedIsYes {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerNativeRendererViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"OmidSupported"];
    [app launch];

    XCUIElement *  result = app.tables.staticTexts[@"OmidSupported=true"];
    [self waitForElementToAppear:result  withTimeout:30];
}
/*
 testBannerNativeAdOMIDOmidSessionStart: To test the OMID is Session Start & few related events are fired by the Banner Native Renderer Ad.
 */
- (void)testBannerNativeRendererAdOMIDOmidSessionStart {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerNativeRendererViewabilityTrackerTest];
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
 testBannerNativeRendererAdOMIDOmidTypeLoaded: To test the OMID is loaded with different events like impressionType,mediaType & creativeType
 */
- (void)testBannerNativeRendererAdOMIDOmidTypeLoaded {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerNativeRendererViewabilityTrackerTest];
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
 testBannerNativeRendererAdOMIDOmidPercentageInView0: To test the OMID is 0% Viewable
 */
- (void)testBannerNativeRendererAdOMIDOmidPercentageInView0 {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerNativeRendererViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"OmidPercentageInView0"];
    [app launch];

    XCUIElement *  result = app.tables.staticTexts[@"percentageInView=0"];
    [self waitForElementToAppear:result  withTimeout:30];
}


/*
 testBannerNativeRendererAdOMIDOmidPercentageInView100: To test the OMID is 100% Viewable
 */
- (void)testBannerNativeRendererAdOMIDOmidPercentageInView100 {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerNativeRendererViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"OmidPercentageInView100"];
    [app launch];

    XCUIElement *  result = app.tables.staticTexts[@"percentageInView=MoreThan0"];
    [self waitForElementToAppear:result  withTimeout:30];
}

/*
 testBannerNativeRendererAdOMIDOmidSessionFinish: To verify Session finish getting fired
 */
- (void)testBannerNativeRendererAdOMIDOmidSessionFinish {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerNativeRendererViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"SessionFinish"];
    [app launch];

    XCUIElement *  result = app.tables.staticTexts[@"type=sessionFinish"];
    [self waitForElementToAppear:result  withTimeout:30];
}


- (void)testBannerNativeRendererEnableOMIDOptimization {
   // Use recording to get started writing UI tests.
   // Use XCTAssert and related functions to verify your tests produce the correct results.
   
   XCUIApplication *app = [[XCUIApplication alloc] init];
   app.launchArguments = [app.launchArguments arrayByAddingObject:BannerNativeRendererViewabilityTrackerTest];
   app.launchArguments = [app.launchArguments arrayByAddingObject:@"EnableOMIDOptimization"];

   app.launchArguments = [app.launchArguments arrayByAddingObject:@"SessionFinish"];
   [app launch];

   XCUIElement *  result = app.tables.staticTexts[@"type=sessionFinish"];
   [self waitForElementToAppear:result  withTimeout:60];
   XCUIElement * enableOMIDOptimization = app.tables.staticTexts[@"EnableOMIDOptimization"];
   [self waitForElementToAppear:result  withTimeout:10];
   
   

}

//
//
//- (void)testBannerNativeRendererAd {
//    // Use recording to get started writing UI tests.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    [app launch];
//
//    XCUIElement *impressionTrackersButton = app.tables.staticTexts[@"ViewabilityTrackersTest"];
//    [self waitForElementToAppear:impressionTrackersButton  withTimeout:8];;
//    [impressionTrackersButton tap];
//
//    XCUIElement *bannerButton = app.tables.staticTexts[@"Banner Native Renderer"];
//    [self waitForElementToAppear:bannerButton  withTimeout:8];;
//
//    [bannerButton tap];
//    XCUIElement *viewabilityBanneradNavigationBar = app.navigationBars[@"ViewabilityBannerNativeRenderer"];
//    [self waitForElementToAppear:viewabilityBanneradNavigationBar  withTimeout:8];;
//
//    XCUIElement *hideShowAdButton = viewabilityBanneradNavigationBar.buttons[@"Hide/Show Ad"];
//    [self waitForElementToAppear:hideShowAdButton  withTimeout:8];;
//
//    [hideShowAdButton tap];
//    sleep(5);
//    [hideShowAdButton tap];
//    sleep(5);
//    [viewabilityBanneradNavigationBar.buttons[@"Delete"] tap];
//
//    XCUIElement *  result = app.tables.staticTexts[@"OmidSupported=true"];
//    [self waitForElementToAppear:result  withTimeout:8];
//
//    result = app.tables.staticTexts[@"sessionStart"];
//    [self waitForElementToAppear:result  withTimeout:8];
//
//    result = app.tables.staticTexts[@"accessMode=limited"];
//    [self waitForElementToAppear:result  withTimeout:8];
//
//    result = app.tables.staticTexts[@"partnerName=Appnexus"];
//    [self waitForElementToAppear:result  withTimeout:8];
//
//    result = app.tables.staticTexts[@"mediaType=display"];
//    [self waitForElementToAppear:result  withTimeout:8];
//
//    result = app.tables.staticTexts[@"creativeType=nativeDisplay"];
//    [self waitForElementToAppear:result  withTimeout:8];
//
//    result = app.tables.staticTexts[@"impressionType=viewable"];
//    [self waitForElementToAppear:result  withTimeout:8];
//
////    result = app.tables.staticTexts[@"percentageInView=0"];
////    [self waitForElementToAppear:result  withTimeout:8];
////
//
//
//    result = app.tables.staticTexts[@"type=sessionFinish"];
//    [self waitForElementToAppear:result  withTimeout:8];
//}

@end
