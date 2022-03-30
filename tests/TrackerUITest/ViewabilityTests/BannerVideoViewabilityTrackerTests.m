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
@interface BannerVideoViewabilityTrackerTests : XCTestCase

@end

@implementation BannerVideoViewabilityTrackerTests

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
 testBannerVideoAdOMIDSessionFinish: Verify OMID Session Finish event.
 */
- (void)testBannerVideoAdOMIDSessionFinish {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerVideoViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"SessionFinish"];
    [app launch];
    XCUIElement *result = app.tables.staticTexts[@"type=sessionFinish"];
    [self waitForElementToAppear:result  withTimeout:60];
}
/*
 testBannerVideoAdOMIDQuartileEvent: Verify OMID Quartile event.
 */
- (void)testBannerVideoAdOMIDQuartileEvent {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerVideoViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"QuartileEvent"];
    [app launch];
    XCUIElement *result = app.tables.staticTexts[@"type=firstQuartile"];
    [self waitForElementToAppear:result  withTimeout:60];
    result = app.tables.staticTexts[@"type=midpoint"];
    [self waitForElementToAppear:result  withTimeout:8];
    result = app.tables.staticTexts[@"type=thirdQuartile"];
    [self waitForElementToAppear:result  withTimeout:8];
    result = app.tables.staticTexts[@"type=complete"];
    [self waitForElementToAppear:result  withTimeout:8];
}

/*
 testBannerVideoAdOMIDSessionStart: Verify OMID Session Finish.
 */
- (void)testBannerVideoAdOMIDSessionStart {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerVideoViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"SessionStart"];
    [app launch];
    
    XCUIElement *result = app.tables.staticTexts[@"sessionStart"];
    [self waitForElementToAppear:result  withTimeout:60];
    result = app.tables.staticTexts[@"partnerName=Appnexus"];
    [self waitForElementToAppear:result  withTimeout:8];
    result = app.tables.staticTexts[@"omidImplementer=omsdk"];
    [self waitForElementToAppear:result  withTimeout:8];
    result = app.tables.staticTexts[@"accessMode=limited"];
    [self waitForElementToAppear:result  withTimeout:8];
    result = app.tables.staticTexts[@"partnerVersion"];
    [self waitForElementToAppear:result  withTimeout:8];
    result = app.tables.staticTexts[@"supports=[clid,vlid]"];
    [self waitForElementToAppear:result  withTimeout:8];
    result = app.tables.staticTexts[@"adSessionType=html"];
    [self waitForElementToAppear:result  withTimeout:8];
    result = app.tables.staticTexts[@"impressionType=definedByJavaScript"];
    [self waitForElementToAppear:result  withTimeout:8];
    result = app.tables.staticTexts[@"mediaType=video"];
    [self waitForElementToAppear:result  withTimeout:8];
    result = app.tables.staticTexts[@"creativeType=definedByJavaScript"];
    [self waitForElementToAppear:result  withTimeout:8];
    result = app.tables.staticTexts[@"supportsLoadedEvent=true"];
    [self waitForElementToAppear:result  withTimeout:8];
    result = app.tables.staticTexts[@"verificationParameters=iabtechlab-appnexus"];
    [self waitForElementToAppear:result  withTimeout:8];
    result = app.tables.staticTexts[@"deviceInfo=iOS"];
    [self waitForElementToAppear:result  withTimeout:8];
    result = app.tables.staticTexts[@"environment=app"];
    [self waitForElementToAppear:result  withTimeout:8];
    
}
/*
 testBannerVideoAdOMIDVolumeChange: Verify OMID Volume Change.
 */

- (void)testBannerVideoAdOMIDVolumeChange {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerVideoViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"OMIDVolumeChange"];
    [app launch];
    XCUIElementQuery *webViewsQuery = app.webViews;
    XCUIElement *unmute  = webViewsQuery.buttons[@" Unmute"];
    [self waitForElementToAppear:unmute  withTimeout:30];
    [unmute tap];
    XCUIElement *mute  =  webViewsQuery.buttons[@" Mute"];
    [self waitForElementToAppear:mute  withTimeout:30];
    [mute tap];
    sleep(5);
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeLeft;
    sleep(5);
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    XCUIElement *result  = app.tables.staticTexts[@"type=volumeChange"];
    [self waitForElementToAppear:result  withTimeout:40];
    
    result  = app.tables.staticTexts[@"mediaPlayerVolume=0"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result  = app.tables.staticTexts[@"videoPlayerVolume =0"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result  = app.tables.staticTexts[@"type=volumeChange"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result  = app.tables.staticTexts[@"mediaPlayerVolume=1"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result = app.tables.staticTexts[@"videoPlayerVolume =1"];
    [self waitForElementToAppear:result  withTimeout:8];
}

/*
 testBannerVideoAdOMIDScreenEvent: Verify OMID Screen Events like Full Screen & Non Full Screen.
 */
//- (void)testBannerVideoAdOMIDScreenEvent {
//    // Use recording to get started writing UI tests.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//    
//    
//    
//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    
//    
//    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerVideoViewabilityTrackerTest];
//    app.launchArguments = [app.launchArguments arrayByAddingObject:@"OMIDScreenEvent"];
//    [app launch];
//    
//    XCUIElementQuery *webViewsQuery = app.webViews.webViews.webViews;
//    XCUIElement *fullscreen  =  webViewsQuery.buttons[@" Fullscreen"];
//    [self waitForElementToAppear:fullscreen  withTimeout:30];;
//    [fullscreen tap];
////    XCUIElement *nonfullscreen  =  webViewsQuery.buttons[@" Non-Fullscreen"];
////    [self waitForElementToAppear:nonfullscreen  withTimeout:30];;
////    [nonfullscreen tap];
//    sleep(5);
//    
//    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeLeft;
//    sleep(5);
//    
//    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
//    XCUIElement *  result = app.tables.staticTexts[@"type=playerStateChange state=fullscreen"];
//    [self waitForElementToAppear:result  withTimeout:60];
//    result = app.tables.staticTexts[@"type=playerStateChange state=normal"];
//    [self waitForElementToAppear:result  withTimeout:8];
//    
//    result = app.tables.staticTexts[@"type=pause"];
//    [self waitForElementToAppear:result  withTimeout:8];
//    
//    result = app.tables.staticTexts[@"type=resume"];
//}


/*
 testBannerVideoAdOMIDSupportedIsYes: Verify OMID is supported or not.
 */
- (void)testBannerVideoAdOMIDSupportedIsYes {
    
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerVideoViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"SupportedIsYes"];
    [app launch];
    XCUIElement *  result = app.tables.staticTexts[@"version="];
    [self waitForElementToAppear:result  withTimeout:40];
    result = app.tables.staticTexts[@"supported=yes"];
    [self waitForElementToAppear:result  withTimeout:8];
    
}
/*
 testBannerVideoAdOMIDBeginToRenderer: Verify OMID BeginToRenderer, with new additional events .
 */
- (void)testBannerVideoAdOMIDBeginToRenderer {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerVideoViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"OMIDBeginToRenderer"];
    [app launch];
    XCUIElement *  result = app.tables.staticTexts[@"type=loaded"];
    [self waitForElementToAppear:result  withTimeout:60];
    
    
    result = app.tables.staticTexts[@"skippable=false"];
    [self waitForElementToAppear:result  withTimeout:40];
    
    
    result = app.tables.staticTexts[@"position=In-Banner"];
    [self waitForElementToAppear:result  withTimeout:40];
    result = app.tables.staticTexts[@"impressionType=beginToRender"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result = app.tables.staticTexts[@"mediaType=video"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result = app.tables.staticTexts[@"creativeType=video"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result = app.tables.staticTexts[@"autoPlay=true"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result = app.tables.staticTexts[@"type=start"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result = app.tables.staticTexts[@"impressionType=beginToRender"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result = app.tables.staticTexts[@"duration=32.23"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result = app.tables.staticTexts[@"mediaPlayerVolume=1"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result = app.tables.staticTexts[@"deviceVolume"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result = app.tables.staticTexts[@"videoPlayerVolume"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result = app.tables.staticTexts[@"duration=32.23"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result = app.tables.staticTexts[@"mediaPlayerVolume=1"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result = app.tables.staticTexts[@"deviceVolume"];
    [self waitForElementToAppear:result  withTimeout:8];
}
/*
 testBannerVideoAdOMIDViewablity: Verify OMID visisble Percentage from zero to 100%   .
 */
- (void)testBannerVideoAdOMIDViewablity {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerVideoViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"OmidPercentageInView"];
    [app launch];

    XCUIElement *  result = app.tables.staticTexts[@"percentageInView=0"];
    [self waitForElementToAppear:result  withTimeout:60];
    
    result = app.tables.staticTexts[@"percentageInView=100"];
    [self waitForElementToAppear:result  withTimeout:8];
    
}

/*
 testBannerEnableOMIDOptimization: To test the OMID is session finish get called after 100% Viewable
 */
- (void)testBannerVideoEnableOMIDOptimization {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerVideoViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"EnableOMIDOptimization"];
    [app launch];
    XCUIElement * result = app.tables.staticTexts[@"type=sessionFinish"];
    [self waitForElementToAppear:result  withTimeout:20];
    XCUIElement * enableOMIDOptimization = app.tables.staticTexts[@"EnableOMIDOptimization"];
    [self waitForElementToAppear:enableOMIDOptimization  withTimeout:10];

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
