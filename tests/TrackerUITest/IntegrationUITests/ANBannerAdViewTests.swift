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

class ANBannerAdViewTests: XCTestCase {
    

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    
    func testRTBBanner320x50() {
        
        let adObject = AdObject(adType: "Banner", accessibilityIdentifier: PlacementTestConstants.BannerAd.testRTBBanner320x50, placement: "19065996")
       
        let bannerAdObject  =  BannerAdObject(isVideo: false, isNative: false, enableNativeRendering : nil ,   height: "50", width: "320", autoRefreshInterval: 60, adObject: adObject)
        let bannerAdObjectString =  AdObjectModel.encodeBannerObject(adObject: bannerAdObject)
        
        let app = XCUIApplication()
        app.launchArguments.append(PlacementTestConstants.BannerAd.testRTBBanner320x50)
        app.launchArguments.append(bannerAdObjectString)
        app.launch()

        // Asserts Ad Elemnts once ad Did Receive
        let webViewsQuery = app.webViews.element(boundBy: 0)
        wait(for: webViewsQuery, timeout: 60)
        XCUIScreen.main.screenshot()

        XCTAssertEqual(webViewsQuery.exists, true)
        XCTAssertEqual(webViewsQuery.frame.size.height, 50)
        XCTAssertEqual(webViewsQuery.frame.size.width, 320)

        XCGlobal.screenshotWithTitle(title: PlacementTestConstants.BannerAd.testRTBBanner320x50)
        wait(2)
        
    }
    

    func testRTBBanner300x250() {
        
        let adObject = AdObject(adType: "Banner", accessibilityIdentifier: PlacementTestConstants.BannerAd.testRTBBanner300x250, placement: "19065996")
        
        let bannerAdObject  =  BannerAdObject(isVideo: false, isNative: false, enableNativeRendering : nil ,  height: "250", width: "300", autoRefreshInterval: 60, adObject: adObject)

        
        let bannerAdObjectString =  AdObjectModel.encodeBannerObject(adObject: bannerAdObject)

        
        let app = XCUIApplication()
        app.launchArguments.append(PlacementTestConstants.BannerAd.testRTBBanner300x250)
        app.launchArguments.append(bannerAdObjectString)
        app.launch()

    
        // Asserts Ad Elemnts once ad Did Receive
        let webViewsQuery = app.webViews.element(boundBy: 0)
        wait(for: webViewsQuery, timeout: 50)
        XCUIScreen.main.screenshot()

        let webViewsSizeText = app.staticTexts["Size = 300 x 250"]
        XCTAssertEqual(webViewsSizeText.exists, true)
        let webViewsBannerText = app.staticTexts["Banner"]
        XCTAssertEqual(webViewsBannerText.exists, true)
        XCTAssertEqual(webViewsQuery.frame.size.height, 250)
        XCTAssertEqual(webViewsQuery.frame.size.width, 300)
        XCGlobal.screenshotWithTitle(title: PlacementTestConstants.BannerAd.testRTBBanner300x250)
        wait(2)
    }
}

