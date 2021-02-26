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
import AppNexusSDK

class ANBannerVideoAdViewTests: XCTestCase, ANBannerAdViewDelegate {
    
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
   // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testVPAIDBannerVideo() {


        
        let adObject = AdObject(adType: "Banner", accessibilityIdentifier: PlacementTestConstants.BannerVideoAd.testVPAIDBannerVideo, placement: "16392991")
        
        let bannerAdObject  =  BannerAdObject(isVideo: true, isNative: false, enableNativeRendering : nil  ,height: "250", width: "300", autoRefreshInterval: 60, adObject: adObject)
        
        let bannerAdObjectString =  AdObjectModel.encodeBannerObject(adObject: bannerAdObject)
        
        
        let app = XCUIApplication()
        app.launchArguments.append(PlacementTestConstants.BannerVideoAd.testVPAIDBannerVideo)
        app.launchArguments.append(bannerAdObjectString)
        app.launch()
        
        let webViewsQuery = app.webViews.element(boundBy: 0)

        wait(for: webViewsQuery, timeout: 15)

        let customInteractionStaticText = webViewsQuery.staticTexts["custom interaction"]
        XCTAssertEqual(customInteractionStaticText.exists, true)
        customInteractionStaticText.tap()
        
        let pauseStaticText = webViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["pause"]/*[[".otherElements[\"ebBannerIFrame_23227072_3747381026391887\"].staticTexts[\"pause\"]",".staticTexts[\"pause\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertEqual(pauseStaticText.exists, true)
        pauseStaticText.tap()
        
        let adStaticText = webViewsQuery.staticTexts["Ad"]
        XCTAssertEqual(adStaticText.exists, true)
        
        
        let adDuration = webViewsQuery.staticTexts["0:17"]
        XCTAssertEqual(adDuration.exists, true)
        
        
        
        let unmuteStaticText = webViewsQuery.staticTexts["unmute"]
        XCTAssertEqual(unmuteStaticText.exists, true)
        unmuteStaticText.tap()
        
        let muteStaticText = webViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["mute"]/*[[".otherElements[\"ebBannerIFrame_23227072_3747381026391887\"].staticTexts[\"mute\"]",".staticTexts[\"mute\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertEqual(muteStaticText.exists, true)
        muteStaticText.tap()
      
        let clickthroughStaticText = webViewsQuery.staticTexts["clickthrough"]
        XCTAssertEqual(clickthroughStaticText.exists, true)
        clickthroughStaticText.tap()
        app.toolbars["Toolbar"].buttons["OK"].tap()
        
        wait(2)

        let unmuteButton = webViewsQuery.buttons[" Unmute"]
        XCTAssertEqual(unmuteButton.exists, true)
        unmuteButton.tap()
        wait(2)
        
        let muteButton = webViewsQuery.buttons[" Mute"]
        XCTAssertEqual(muteButton.exists, true)
        muteButton.tap()
        wait(2)
        
        let fullscreenButton =  webViewsQuery.buttons[" Fullscreen"]
        XCTAssertEqual(fullscreenButton.exists, true)
        fullscreenButton.tap()
        wait(2)
        
        let skipAdButton = webViewsQuery.staticTexts["skip ad"]
        XCTAssertEqual(skipAdButton.exists, true)
        
        let nonFullscreenButton = webViewsQuery.buttons[" Non-Fullscreen"]
        XCTAssertEqual(nonFullscreenButton.exists, true)
        nonFullscreenButton.tap()
        print(webViewsQuery.debugDescription)
        XCGlobal.screenshotWithTitle(title: PlacementTestConstants.BannerVideoAd.testVPAIDBannerVideo)
        wait(2)
    }
    
    func testBannerVideo() {
        

        let adObject = AdObject(adType: "Banner", accessibilityIdentifier: PlacementTestConstants.BannerVideoAd.testBannerVideo, placement: "16392991")
        
        let bannerAdObject  =  BannerAdObject(isVideo: true, isNative: false, enableNativeRendering : nil , height: "250", width: "300", autoRefreshInterval: 0, adObject: adObject)
        
        let bannerAdObjectString =  AdObjectModel.encodeBannerObject(adObject: bannerAdObject)
                
        let app = XCUIApplication()
        app.launchArguments.append(PlacementTestConstants.BannerVideoAd.testBannerVideo)
        app.launchArguments.append(bannerAdObjectString)
        app.launch()
        

        let webViewsQuery = app.webViews

        let webview = webViewsQuery.otherElements["2 minutes 48 seconds"]
        
        wait(for: webview, timeout: 15)
       
        wait(2)

        XCTAssertEqual(webview.exists, true)

        let adDuration = webViewsQuery.staticTexts["2:48"]
        XCTAssertEqual(adDuration.exists, true)

        
        let unmuteButton = webViewsQuery.buttons[" Unmute"]
        XCTAssertEqual(unmuteButton.exists, true)
        unmuteButton.tap()
        wait(2)

        let muteButton = webViewsQuery.buttons[" Mute"]
        XCTAssertEqual(muteButton.exists, true)
        muteButton.tap()
        wait(2)

        
        let fullscreenButton =  webViewsQuery.buttons[" Fullscreen"]
        XCTAssertEqual(fullscreenButton.exists, true)
        fullscreenButton.tap()
        wait(2)
    
        let nonFullscreenButton = webViewsQuery.buttons[" Non-Fullscreen"]
        XCTAssertEqual(nonFullscreenButton.exists, true)
        nonFullscreenButton.tap()
        print(webViewsQuery.debugDescription)

        wait(2)

        let skipButton = webViewsQuery.buttons[" Skip"]
        XCTAssertEqual(skipButton.exists, false)
        wait(2)

        let adLearnMoreStaticText = webViewsQuery.staticTexts["Ad - Learn More"]
        XCTAssertEqual(adLearnMoreStaticText.exists, true)
        XCGlobal.screenshotWithTitle(title: PlacementTestConstants.BannerVideoAd.testBannerVideo)
        wait(2)
    }
}


