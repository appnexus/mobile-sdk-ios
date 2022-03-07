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
@interface VideoViewabilityTrackerTests : XCTestCase

@end

@implementation VideoViewabilityTrackerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

//
//- (void)testVideoAd {
//    // Use recording to get started writing UI tests.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    [app launch];
//
//    XCUIElement *impressionTrackersButton = app.tables.staticTexts[@"ViewabilityTrackersTest"];
//    [self waitForElementToAppear:impressionTrackersButton  withTimeout:8];;
//    [impressionTrackersButton tap];
//
//    XCUIElement *bannerButton = app.tables.staticTexts[@"Video"];
//    [self waitForElementToAppear:bannerButton  withTimeout:8];;
//
//    [bannerButton tap];
//
//
//    XCUIElementQuery *webViewsQuery = app.webViews.webViews.webViews;
//
//
//    XCUIElement *mute  =  webViewsQuery.buttons[@" Mute"];
//    [self waitForElementToAppear:mute  withTimeout:10];
//    [mute tap];
//
//    XCUIElement *unmute  = webViewsQuery.buttons[@" Unmute"];
//    [self waitForElementToAppear:unmute  withTimeout:10];
//    [unmute tap];
//
//
////
////    XCUIElement *fullscreen  =  webViewsQuery.buttons[@" Fullscreen"];
////    [self waitForElementToAppear:fullscreen  withTimeout:10];;
////    [fullscreen tap];
////
////    XCUIElement *nonfullscreen  =  webViewsQuery.buttons[@" Non-Fullscreen"];
////    [self waitForElementToAppear:nonfullscreen  withTimeout:10];;
////    [nonfullscreen tap];
//
//    sleep(5);
//
//    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeLeft;
//    sleep(5);
//
//    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
//
//
//    XCUIElement *learnMore  =  webViewsQuery.buttons[@"Learn More - Ad"];
//    [self waitForElementToAppear:learnMore  withTimeout:10];;
//    [learnMore tap];
//
//    XCUIElement *okButton  = app.toolbars[@"Toolbar"].buttons[@"OK"];
//    [self waitForElementToAppear:okButton withTimeout:25];
//    [okButton tap];
//
//
//    XCUIElement *  result = app.tables.staticTexts[@"version=1.0.2-dev"];
//    [self waitForElementToAppear:result  withTimeout:35];
//
//    XCUIElement *viewabilityBanneradNavigationBar = app.navigationBars[@"Viewability VideoAd"];
//    [self waitForElementToAppear:viewabilityBanneradNavigationBar  withTimeout:8];;
//    [viewabilityBanneradNavigationBar.buttons[@"Delete"] tap];
//
//    result = app.tables.staticTexts[@"supported=yes"];
//    [self waitForElementToAppear:result  withTimeout:8];
//
//    result = app.tables.staticTexts[@"sessionStart"];
//    [self waitForElementToAppear:result  withTimeout:8];
//
////    result = app.tables.staticTexts[@"percentageInView=0"];
////    [self waitForElementToAppear:result  withTimeout:8];
//
//    result = app.tables.staticTexts[@"type=loaded skippable=false position=In-Video"];
//    [self waitForElementToAppear:result  withTimeout:8];
//
//    result = app.tables.staticTexts[@"type=start"];
//    [self waitForElementToAppear:result  withTimeout:8];
//
//    result = app.tables.staticTexts[@"type=volumeChange mediaPlayerVolume=1 videoPlayerVolume =1"];
//    [self waitForElementToAppear:result  withTimeout:8];
//
//    result = app.tables.staticTexts[@"type=volumeChange mediaPlayerVolume=1 videoPlayerVolume =0"];
//    [self waitForElementToAppear:result  withTimeout:8];
//
//    result = app.tables.staticTexts[@"type=impression impressionType=beginToRender"];
//    [self waitForElementToAppear:result  withTimeout:8];
//
//    result = app.tables.staticTexts[@"type=pause"];
//    [self waitForElementToAppear:result  withTimeout:8];
//
//    result = app.tables.staticTexts[@"type=resume"];
//    [self waitForElementToAppear:result  withTimeout:8];
//    result = app.tables.staticTexts[@"type=firstQuartile"];
//    [self waitForElementToAppear:result  withTimeout:8];
////    result = app.tables.staticTexts[@"type=playerStateChange state=normal"];
////    [self waitForElementToAppear:result  withTimeout:8];
//    result = app.tables.staticTexts[@"type=midpoint"];
//    [self waitForElementToAppear:result  withTimeout:8];
//    result = app.tables.staticTexts[@"type=thirdQuartile"];
//    [self waitForElementToAppear:result  withTimeout:8];
//    result = app.tables.staticTexts[@"type=complete"];
//    [self waitForElementToAppear:result  withTimeout:8];
//    result = app.tables.staticTexts[@"type=resume"];
//    [self waitForElementToAppear:result  withTimeout:8];
//
//    result = app.tables.staticTexts[@"type=sessionFinish"];
//    [self waitForElementToAppear:result  withTimeout:8];
//}
//
//
//

/*
 testVideoSkipTestAd: Verify OMID SKIP event.
 */
- (void)testVideoSkipTestAd {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:VideoViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"SKIP"];

    [app launch];

   
    XCUIElementQuery *webViewsQuery = app.webViews.webViews.webViews;
    XCUIElement *skipAction  =  webViewsQuery.buttons[@"SKIP"];
    [self waitForElementToAppear:skipAction  withTimeout:40];
    wait(200);
    [skipAction tap];
    XCUIElement *result = app.tables.staticTexts[@"type=skipped"];
    [self waitForElementToAppear:result  withTimeout:20];
}


/*
 testVideoAdOMIDSessionFinish: Verify OMID Session Finish event.
 */
- (void)testVideoAdOMIDSessionFinish {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:VideoViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"SessionFinish"];
    [app launch];
    XCUIElement *result = app.tables.staticTexts[@"type=sessionFinish"];
    [self waitForElementToAppear:result  withTimeout:60];
}
/*
 testVideoAdOMIDQuartileEvent: Verify OMID Quartile event.
 */
- (void)testVideoAdOMIDQuartileEvent {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:VideoViewabilityTrackerTest];
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
 testVideoAdOMIDSessionStart: Verify OMID Session Finish.
 */
- (void)testVideoAdOMIDSessionStart {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:VideoViewabilityTrackerTest];
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
 testVideoAdOMIDVolumeChange: Verify OMID Volume Change.
 */
- (void)testVideoAdOMIDVolumeChange {
    
    
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:VideoViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"OMIDVolumeChange"];
    [app launch];
    XCUIElementQuery *webViewsQuery = app.webViews;
    XCUIElement *mute  =  webViewsQuery.buttons[@" Mute"];
    [self waitForElementToAppear:mute  withTimeout:30];
    [mute tap];

    XCUIElement *unmute  = webViewsQuery.buttons[@" Unmute"];
    [self waitForElementToAppear:unmute  withTimeout:30];
    [unmute tap];
   
    sleep(5);
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeLeft;
    sleep(5);
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    XCUIElement *result  = app.tables.staticTexts[@"type=volumeChange"];
    [self waitForElementToAppear:result  withTimeout:40];
    result = app.tables.staticTexts[@"mediaPlayerVolume=1"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result = app.tables.staticTexts[@"videoPlayerVolume =1"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result = app.tables.staticTexts[@"type=volumeChange"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result = app.tables.staticTexts[@"mediaPlayerVolume=1"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    result = app.tables.staticTexts[@"videoPlayerVolume =0"];
    [self waitForElementToAppear:result  withTimeout:8];
    
    
}

/*
 testVideoAdOMIDSupportedIsYes: Verify OMID is supported or not.
 */
- (void)testVideoAdOMIDSupportedIsYes {
    
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:VideoViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"SupportedIsYes"];
    [app launch];
    XCUIElement *  result = app.tables.staticTexts[@"version="];
    [self waitForElementToAppear:result  withTimeout:40];
    result = app.tables.staticTexts[@"supported=yes"];
    [self waitForElementToAppear:result  withTimeout:20];
    
}

/*
 testVideoAdOMIDBeginToRenderer: Verify OMID BeginToRenderer, with new additional events .
 */
- (void)testVideoAdOMIDBeginToRenderer {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:VideoViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"OMIDBeginToRenderer"];
    [app launch];
    XCUIElement *  result = app.tables.staticTexts[@"type=loaded"];
    [self waitForElementToAppear:result  withTimeout:60];
    
    
    result = app.tables.staticTexts[@"skippable=true"];
    [self waitForElementToAppear:result  withTimeout:40];

    
    result = app.tables.staticTexts[@"position=In-Video"];
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
    
    result = app.tables.staticTexts[@"type=impression"];
    
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
 testVideoAdOMIDViewablity: Verify OMID visisble Percentage from zero to 100%   .
 */
- (void)testVideoAdOMIDViewablity {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    app.launchArguments = [app.launchArguments arrayByAddingObject:VideoViewabilityTrackerTest];
    app.launchArguments = [app.launchArguments arrayByAddingObject:@"OmidPercentageInView"];
    [app launch];

 
    
    XCUIElement *  result = app.tables.staticTexts[@"percentageInView=0"];
    [self waitForElementToAppear:result  withTimeout:60];
    
    result = app.tables.staticTexts[@"percentageInView=100"];
    [self waitForElementToAppear:result  withTimeout:8];
    
}


///*
// testVideoEnableOMIDOptimization: To test the OMID is session finish get called after 100% Viewable
// */
//- (void)testVideoEnableOMIDOptimization {
//    // Use recording to get started writing UI tests.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    app.launchArguments = [app.launchArguments arrayByAddingObject:VideoViewabilityTrackerTest];
//    app.launchArguments = [app.launchArguments arrayByAddingObject:@"EnableOMIDOptimization"];
//    [app launch];
//    XCUIElement * result = app.tables.staticTexts[@"type=sessionFinish"];
//    [self waitForElementToAppear:result  withTimeout:20];
//    XCUIElement * enableOMIDOptimization = app.tables.staticTexts[@"EnableOMIDOptimization"];
//    [self waitForElementToAppear:enableOMIDOptimization  withTimeout:10];
//
//}

- (void)wait:(NSUInteger)interval {

    XCTestExpectation *expectation = [self expectationWithDescription:@"wait"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:interval handler:nil];
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
