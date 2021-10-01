////
////  BannerAdOnePXScrollViewController.m
////  TrackerTests
////
////  Created by abhisheksharma on 05/03/21.
////  Copyright © 2021 Xandr. All rights reserved.
////
//
//#import <XCTest/XCTest.h>
//#import "Constant.h"
//
//@interface BannerAdOnePXScrollViewController : XCTestCase
//
//@end
//
//@implementation BannerAdOnePXScrollViewController
//
//- (void)setUp {
//    // Put setup code here. This method is called before the invocation of each test method in the class.
//    
//    // In UI tests it is usually best to stop immediately when a failure occurs.
//    self.continueAfterFailure = NO;
//
//    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
//    [[[XCUIApplication alloc] init] launch];
//
//    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
//}
//
//
///*
// testBannerImpressionTrackerTestAd: To test the impression tracker is fired by the Banner Ad.
// */
//- (void)testBannerImpressionTracker1PXTestAd {
//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    app.launchArguments = [app.launchArguments arrayByAddingObject:BannerImpression1PxTrackerTest];
//    [app launch];
//
//    XCUIElement *impressionTrackerNotFired = app.staticTexts[@"Not Fired"];
//    [self waitForElementToAppear:impressionTrackerNotFired  withTimeout:18];;
//    XCTAssertTrue(impressionTrackerNotFired.exists);
//
//    XCUIElement *impressionTracker = app.staticTexts[@"ImpressionTracker"];
//    [self waitForElementToAppear:impressionTracker  withTimeout:ImpressionTrackerTimeout];;
//    XCTAssertTrue(impressionTracker.exists);
//
//     
//}
//
///*
// testNativeImpressionTrackerTestAd: To test the impression tracker is fired by the Banner Ad.
// */
//- (void)testNativeImpressionTracker1PXTestAd {
//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    app.launchArguments = [app.launchArguments arrayByAddingObject:NativeImpression1PxTrackerTest];
//    [app launch];
//
//    XCUIElement *impressionTrackerNotFired = app.staticTexts[@"Not Fired"];
//    [self waitForElementToAppear:impressionTrackerNotFired  withTimeout:25];;
//    XCTAssertTrue(impressionTrackerNotFired.exists);
//
//    XCUIElement *impressionTracker = app.staticTexts[@"ImpressionTracker"];
//    [self waitForElementToAppear:impressionTracker  withTimeout:ImpressionTrackerTimeout];;
//    XCTAssertTrue(impressionTracker.exists);
//
//     
//}
//
//- (void)tearDown {
//    // Put teardown code here. This method is called after the invocation of each test method in the class.
//}
//
//
///**
//  Wait n amount of time for XCUIElement to appear on the screen
//  @param element : XCUIElement that's required to appear.
//  @param timeout : time for that UIElement wait for to appear.
// */
//- (void)waitForElementToAppear:(XCUIElement *)element withTimeout:(NSTimeInterval)timeout
//{
//    
//    NSPredicate *exists = [NSPredicate predicateWithFormat:@"exists == 1"];
//    [self expectationForPredicate:exists evaluatedWithObject:element handler:nil];
//    [self waitForExpectationsWithTimeout:timeout handler:nil];
//}
//
//@end
