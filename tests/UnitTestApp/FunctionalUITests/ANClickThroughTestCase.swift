///*   Copyright 2019 APPNEXUS INC
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// */
//
//import XCTest
//
//class ANClickThroughTestCase: XCTestCase {
//
//    var app: XCUIApplication!
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//        super.setUp()
//        continueAfterFailure = false
//        app = XCUIApplication()
//        initialiseBanner()
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//        let screenshot = XCUIScreen.main.screenshot()
//        let fullScreenshotAttachment = XCTAttachment(screenshot: screenshot)
//        fullScreenshotAttachment.lifetime = .deleteOnSuccess
//        add(fullScreenshotAttachment)
//    }
//    
//    func initialiseBanner(){
//        let adObject = AdObject(adType: "Banner", accessibilityIdentifier: FunctionalTestConstants.BannerAdClickthru.testClickThruSettingsWithOpenSDKBrowserUITest, placement: "15740033")
//
//        let bannerAdObject  =  BannerAdObject(isVideo: false, isNative: true, enableNativeRendering:  true ,  height: "480", width: "320", autoRefreshInterval: 60, adObject: adObject)
//
//        let bannerAdObjectString =  AdObjectModel.encodeBannerObject(adObject: bannerAdObject)
//
//        app.launchArguments.append(FunctionalTestConstants.functionalTestClickThru)
//        app.launchArguments.append(FunctionalTestConstants.BannerAdClickthru.testClickThruSettingsWithOpenSDKBrowserUITest)
//        app.launchArguments.append(bannerAdObjectString)
//        
//    }
//
//    func testClickThruSettingsWithOpenSDKBrowserUITest() {
//        app.launch()
//
//        let webViewsQuery = app.webViews.element(boundBy: 0)
//        wait(for: webViewsQuery, timeout: 120)
//        takeScreenshot()
//        webViewsQuery.links["Native Renderer Campaign Native Renderer Campaign"].children(matching: .link).matching(identifier: "Native Renderer Campaign").element(boundBy: 0).staticTexts["Native Renderer Campaign"].tap()
//        wait(for: app.toolbars["Toolbar"], timeout: 20)
//        app.toolbars["Toolbar"].buttons["OK"].tap()
//        wait(1)
//
//        XCTAssertEqual(webViewsQuery.frame.size.height, 480)
//        XCTAssertEqual(webViewsQuery.frame.size.width, 320)
//        wait(1)
//
//    }
//
//    func takeScreenshot() {
//      let fullScreenshot = XCUIScreen.main.screenshot()
//      let screenshot = XCTAttachment(screenshot: fullScreenshot)
//
//      screenshot.lifetime = .deleteOnSuccess
//      add(screenshot)
//    }
//}
