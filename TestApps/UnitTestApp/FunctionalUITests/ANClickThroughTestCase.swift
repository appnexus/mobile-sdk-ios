/*   Copyright 2019 APPNEXUS INC
 
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

import XCTest

class ANClickThroughTestCase: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testClickThruSettingsWithOpenSDKBrowserUITest() {
        
        let adObject = AdObject(adType: "Banner", accessibilityIdentifier: FunctionalTestConstants.BannerAdClickthru.testClickThruSettingsWithOpenSDKBrowserUITest, placement: "15740033")
        
        let bannerAdObject  =  BannerAdObject(isVideo: false, isNative: true, enableNativeRendering:  true ,  height: "480", width: "320", autoRefreshInterval: 60, adObject: adObject)
        
        let bannerAdObjectString =  AdObjectModel.encodeBannerObject(adObject: bannerAdObject)
        
        let app = XCUIApplication()
        app.launchArguments.append(FunctionalTestConstants.functionalTestClickThru)
        app.launchArguments.append(FunctionalTestConstants.BannerAdClickthru.testClickThruSettingsWithOpenSDKBrowserUITest)
        app.launchArguments.append(bannerAdObjectString)
        app.launch()
        
        // Asserts Ad Elemnts once ad Did Receive
        let webViewsQuery = app.webViews.element(boundBy: 0)
        wait(for: webViewsQuery, timeout: 30)
        XCUIScreen.main.screenshot()
        webViewsQuery.links["Native Renderer Campaign Native Renderer Campaign"].children(matching: .link).matching(identifier: "Native Renderer Campaign").element(boundBy: 0).staticTexts["Native Renderer Campaign"].tap()
        wait(for: app.toolbars["Toolbar"], timeout: 20)
        app.toolbars["Toolbar"].buttons["OK"].tap()
        XCTAssertEqual(webViewsQuery.frame.size.height, 480)
        XCTAssertEqual(webViewsQuery.frame.size.width, 320)
        XCGlobal.screenshotWithTitle(title: FunctionalTestConstants.BannerAdClickthru.testClickThruSettingsWithOpenSDKBrowserUITest)
        wait(2)
        
    }
    
    func testClickThruSettingsOpenInDeviceBrowserUITest() {
        
        let adObject = AdObject(adType: "Banner", accessibilityIdentifier: FunctionalTestConstants.BannerAdClickthru.testClickThruSettingsWithOpenDeviceBrowserUITest, placement: "15740033")
        
        let bannerAdObject  =  BannerAdObject(isVideo: false, isNative: true, enableNativeRendering:  true ,  height: "480", width: "320", autoRefreshInterval: 60, adObject: adObject)
        
        let bannerAdObjectString =  AdObjectModel.encodeBannerObject(adObject: bannerAdObject)
        
        let app = XCUIApplication()
        app.launchArguments.append(FunctionalTestConstants.functionalTestClickThru)
        app.launchArguments.append(FunctionalTestConstants.BannerAdClickthru.testClickThruSettingsWithOpenDeviceBrowserUITest)
        app.launchArguments.append(bannerAdObjectString)
        app.launch()
        
        // Asserts Ad Elemnts once ad Did Receive
        let webViewsQuery = app.webViews.element(boundBy: 0)
        wait(for: webViewsQuery, timeout: 30)
        XCUIScreen.main.screenshot()
        webViewsQuery.links["Native Renderer Campaign Native Renderer Campaign"].children(matching: .link).matching(identifier: "Native Renderer Campaign").element(boundBy: 0).staticTexts["Native Renderer Campaign"].tap()
        XCGlobal.screenshotWithTitle(title: FunctionalTestConstants.BannerAdClickthru.testClickThruSettingsWithOpenDeviceBrowserUITest)
        wait(2)
        app.activate()
        wait(2)
        XCTAssertTrue(webViewsQuery.exists)
        
    }
 
    func testClickThruSettingsWithReturnURLUITest() {
        
        let adObject = AdObject(adType: "Banner", accessibilityIdentifier: FunctionalTestConstants.BannerAdClickthru.testClickThruSettingsWithReturnURLUITest, placement: "15740033")
        
        let bannerAdObject  =  BannerAdObject(isVideo: false, isNative: true, enableNativeRendering:  true ,  height: "480", width: "320", autoRefreshInterval: 60, adObject: adObject)
        
        let bannerAdObjectString =  AdObjectModel.encodeBannerObject(adObject: bannerAdObject)
        
        let app = XCUIApplication()
        app.launchArguments.append(FunctionalTestConstants.functionalTestClickThru)
        app.launchArguments.append(FunctionalTestConstants.BannerAdClickthru.testClickThruSettingsWithReturnURLUITest)
        app.launchArguments.append(bannerAdObjectString)
        app.launch()
        
        // Asserts Ad Elemnts once ad Did Receive
        let webViewsQuery = app.webViews.element(boundBy: 0)
        wait(for: webViewsQuery, timeout: 30)
        XCUIScreen.main.screenshot()
        webViewsQuery.links["Native Renderer Campaign Native Renderer Campaign"].children(matching: .link).matching(identifier: "Native Renderer Campaign").element(boundBy: 0).staticTexts["Native Renderer Campaign"].tap()
        XCTAssertTrue(app.alerts["UITest"].exists)
        app.alerts["UITest"].buttons["OK"].tap()
        XCGlobal.screenshotWithTitle(title: FunctionalTestConstants.BannerAdClickthru.testClickThruSettingsWithReturnURLUITest)
        wait(2)

    }
 
}
