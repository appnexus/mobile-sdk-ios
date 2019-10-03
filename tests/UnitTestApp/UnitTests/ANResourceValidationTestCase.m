/*
 *
 *    Copyright 2019 APPNEXUS INC
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */


#import <XCTest/XCTest.h>
#import "ANGlobal.h"


NSString * __nonnull const  ANANJAM  = @"anjam";
NSString * __nonnull const  ANMRAID  = @"ANMRAID";
NSString * __nonnull const  ASTMEDIATIONMANAGER  = @"ASTMediationManager";
NSString * __nonnull const  ANBROWSERVIEWCONTROLLER_SIZECLASSES  = @"ANBrowserViewController_SizeClasses";
NSString * __nonnull const  ANBROWSERVIEWCONTROLLER  = @"ANBrowserViewController";
NSString * __nonnull const  ANIMAGE  = @"an_arrow_left";
NSString * __nonnull const  ANINTERSTITIAL_CLOSEBOX  = @"interstitial_closebox";
NSString * __nonnull const  ANMOBILEVASTPLAYER  = @"MobileVastPlayer";
NSString * __nonnull const  ANNATIVERENDERER  = @"nativeRenderer";
NSString * __nonnull const  ANOMSDK  = @"omsdk";
NSString * __nonnull const  ANVASTVIDEO  = @"vastVideo";
NSString * __nonnull const  ANSDKJS  = @"sdkjs";
NSString * __nonnull const  ANOPTIONSPARSER  = @"optionsparser";
NSString * __nonnull const  ANNORESOURCE  = @"NoResource";





@interface ANResourceValidationTestCase : XCTestCase

@end

@implementation ANResourceValidationTestCase

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testResourceExists {
   
    NSString *pathAnjam = ANPathForANResource(ANANJAM, @"js");
    XCTAssertNotNil(pathAnjam);
    NSString *pathMRAID = ANPathForANResource(ANMRAID, @"bundle");
    XCTAssertNotNil(pathMRAID);
    NSString *pathASTMed = ANPathForANResource(ASTMEDIATIONMANAGER, @"js");
    XCTAssertNotNil(pathASTMed);
    NSString *pathANBrowserSizeClass = ANPathForANResource(ANBROWSERVIEWCONTROLLER_SIZECLASSES, @"nib");
    XCTAssertNotNil(pathANBrowserSizeClass);
    NSString *pathANBrowser = ANPathForANResource(ANBROWSERVIEWCONTROLLER, @"nib");
    XCTAssertNotNil(pathANBrowser);
    NSString *pathANImage = ANPathForANResource(ANIMAGE, @"png");
    XCTAssertNotNil(pathANImage);
    NSString *(pathANMVP) = ANPathForANResource(ANMOBILEVASTPLAYER, @"js");
    XCTAssertNotNil(pathANMVP);
    NSString *pathVASTVideo = ANPathForANResource(ANVASTVIDEO, @"html");
    XCTAssertNotNil(pathVASTVideo);
    NSString *pathNativeRenderer = ANPathForANResource(ANNATIVERENDERER, @"html");
    XCTAssertNotNil(pathNativeRenderer);
    NSString *pathSDKJS = ANPathForANResource(ANSDKJS, @"js");
    XCTAssertNotNil(pathSDKJS);
    NSString *pathOMSDK = ANPathForANResource(ANOMSDK, @"js");
    XCTAssertNotNil(pathOMSDK);
    NSString *pathOptionsparser = ANPathForANResource(ANOPTIONSPARSER, @"js");
    XCTAssertNotNil(pathOptionsparser);
    NSString *pathANInterstitial_closebox = ANPathForANResource(ANINTERSTITIAL_CLOSEBOX, @"png");
    XCTAssertNotNil(pathANInterstitial_closebox);
    
}


- (void)testResourceNotExists {
    
    NSString *pathANNoResource = ANPathForANResource(ANNORESOURCE, @"js");
    XCTAssertNil(pathANNoResource);
}


@end
