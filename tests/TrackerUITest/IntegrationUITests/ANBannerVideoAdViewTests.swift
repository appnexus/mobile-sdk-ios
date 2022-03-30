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

class ANBannerVideoAdViewTests: XCTestCase {
    
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
   // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBannerVideo() {
        

        let adObject = AdObject(adType: "Banner", accessibilityIdentifier: PlacementTestConstants.BannerVideoAd.testBannerVideo, placement: "19065996")
        
        let bannerAdObject  =  BannerAdObject(isVideo: true, isNative: false, enableNativeRendering : nil , height: "250", width: "300", autoRefreshInterval: 0, adObject: adObject)
        
        let bannerAdObjectString =  AdObjectModel.encodeBannerObject(adObject: bannerAdObject)
                
        let app = XCUIApplication()
        app.launchArguments.append(PlacementTestConstants.BannerVideoAd.testBannerVideo)
        app.launchArguments.append(bannerAdObjectString)
        app.launch()
        

        let webViewsQuery = app.webViews

        let webview = webViewsQuery.firstMatch
        
        wait(for: webview, timeout: 25)
       
        wait(2)

        XCTAssertEqual(webview.exists, true)

        let adDuration = webViewsQuery.staticTexts["1:06"]
        XCTAssertEqual(adDuration.exists, true)

        
        let unmuteButton = webViewsQuery.buttons[" Unmute"]
        XCTAssertEqual(unmuteButton.exists, true)
        unmuteButton.tap()
        wait(2)
//
//        let muteButton = webViewsQuery.buttons[" Mute"]
//        XCTAssertEqual(muteButton.exists, true)
//        muteButton.tap()
//        wait(2)

        
//        let fullscreenButton =  webViewsQuery.buttons[" Fullscreen"]
//        XCTAssertEqual(fullscreenButton.exists, true)
//        fullscreenButton.tap()
//        wait(2)
    
//        let nonFullscreenButton = webViewsQuery.buttons[" Non-Fullscreen"]
//        XCTAssertEqual(nonFullscreenButton.exists, true)
//        nonFullscreenButton.tap()
//        print(webViewsQuery.debugDescription)

        wait(2)

//        let skipButton = webViewsQuery.buttons[" Skip"]
//        XCTAssertEqual(skipButton.exists, false)
//        wait(2)

//        let adLearnMoreStaticText = webViewsQuery.staticTexts["Ad - Learn More"]
//        XCTAssertEqual(adLearnMoreStaticText.exists, true)
//        XCGlobal.screenshotWithTitle(title: PlacementTestConstants.BannerVideoAd.testBannerVideo)
//        wait(2)
    }
}


