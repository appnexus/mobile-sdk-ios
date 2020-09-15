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
//
//import XCTest
//
//class ANBannerNativeRenderingUITestCase: XCTestCase {
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
//
//    func initialiseBanner(){
//        let adObject = AdObject(adType: "Banner", accessibilityIdentifier: FunctionalTestConstants.BannerNativeAd.testBannerNativeRenderingSize, placement: "15740033")
//        
//        let bannerAdObject  =  BannerAdObject(isVideo: false, isNative: true, enableNativeRendering : true , height: "250", width: "300", autoRefreshInterval: 60, adObject: adObject)
//        
//        
//        let bannerAdObjectString =  AdObjectModel.encodeBannerObject(adObject: bannerAdObject)
//        
//        
//        app.launchArguments.append(FunctionalTestConstants.functionalTest)
//        app.launchArguments.append(FunctionalTestConstants.BannerNativeAd.testBannerNativeRenderingSize)
//        app.launchArguments.append(bannerAdObjectString)
//        
//    }
//    
//    func testBannerNativeRenderingAdSize() {
//        app.launch()
//        // Asserts Ad Elemnts once ad Did Receive
//        let webViewsQuery = app.webViews.element(boundBy: 0)
//        wait(for: webViewsQuery, timeout: 120)
//        takeScreenshot()
//        XCTAssertEqual(webViewsQuery.frame.size.height, 250)
//        XCTAssertEqual(webViewsQuery.frame.size.width, 300)
//        XCGlobal.screenshotWithTitle(title: FunctionalTestConstants.BannerNativeAd.testBannerNativeRenderingSize)
//        wait(2)
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
//
