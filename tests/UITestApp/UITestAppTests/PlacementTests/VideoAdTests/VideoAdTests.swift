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

class VideoAdTests: XCTestCase {


    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
      
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testVastVideoAd(){
        
        let adObject = AdObject(adType: "Video", accessibilityIdentifier: PlacementTestConstants.VideoAd.testRTBVideo, placement: "16392991")
        
        let videoAdObject = VideoAdObject(isVideo: false , adObject: adObject)

        let videoAdObjectString =  AdObjectModel.encodeVideoObject(adObject: videoAdObject)

        let app = XCUIApplication()
        app.launchArguments.append(PlacementTestConstants.VideoAd.testRTBVideo)
        app.launchArguments.append(videoAdObjectString)
        app.launch()
        
        let webViewsQuery = app.webViews.element(boundBy: 0)
        
        wait(for: webViewsQuery, timeout: 15)
        wait(2)
        
        let webview = webViewsQuery.otherElements["2 minutes 48 seconds"]
        XCTAssertEqual(webview.exists, true)
        
        let adDuration = webViewsQuery.staticTexts["2:48"]
        XCTAssertEqual(adDuration.exists, true)
        
        let muteButton = webViewsQuery.buttons[" Mute"]
        XCTAssertEqual(muteButton.exists, true)
        muteButton.tap()
        wait(2)
        
        let unmuteButton = webViewsQuery.buttons[" Unmute"]
        XCTAssertEqual(unmuteButton.exists, true)
        unmuteButton.tap()
        wait(2)
     
        
        let adLearnMoreStaticText = app/*@START_MENU_TOKEN@*/.webViews/*[[".otherElements[\"testBannerVideo\"].webViews",".webViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.staticTexts["Learn More - Ad"]
        XCTAssertEqual(adLearnMoreStaticText.exists, true)
        
       
        let skipText = webViewsQuery.staticTexts["SKIP"]
        XCTAssertEqual(skipText.exists, true)
        XCGlobal.screenshotWithTitle(title: PlacementTestConstants.VideoAd.testRTBVideo)
        wait(2)
        
    }
    
    
    func testVPAIDVideoAd(){
      
        let adObject = AdObject(adType: "Video", accessibilityIdentifier: PlacementTestConstants.VideoAd.testVPAIDVideoAd, placement: "16392991")
        let videoAdObject = VideoAdObject(isVideo: false , adObject: adObject)
     
        let videoAdObjectString =  AdObjectModel.encodeVideoObject(adObject: videoAdObject)

        
        let app = XCUIApplication()
        app.launchArguments.append(PlacementTestConstants.VideoAd.testVPAIDVideoAd)
        app.launchArguments.append(videoAdObjectString)
        app.launch()
        

        let webViewsQuery = app.webViews.element(boundBy: 0)
        wait(for: webViewsQuery, timeout: 155)
        

        wait(8)
        
        let skipAdButton = webViewsQuery.staticTexts["skip ad"]
        XCTAssertEqual(skipAdButton.exists, true)
        
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
        
        let muteStaticText = webViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["mute"]/*[[".otherElements[\"ebBannerIFrame_23227072_3747381026391887\"].staticTexts[\"mute\"]",".staticTexts[\"mute\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertEqual(muteStaticText.exists, true)
        muteStaticText.tap()
        
        
        let unmuteStaticText = webViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["unmute"]/*[[".otherElements[\"ebBannerIFrame_23227072_3747381026391887\"].staticTexts[\"unmute\"]",".staticTexts[\"unmute\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertEqual(unmuteStaticText.exists, true)
        unmuteStaticText.tap()
     
        let clickthroughStaticText = webViewsQuery.staticTexts["clickthrough"]
        XCTAssertEqual(clickthroughStaticText.exists, true)
        
        wait(1)
        
        let muteButton = webViewsQuery.buttons[" Mute"]
        XCTAssertEqual(muteButton.exists, true)
        muteButton.tap()
        
        wait(1)
        let unmuteButton = webViewsQuery.buttons[" Unmute"]
        XCTAssertEqual(unmuteButton.exists, true)
        unmuteButton.tap()
     
        XCGlobal.screenshotWithTitle(title: PlacementTestConstants.VideoAd.testVPAIDVideoAd)
        wait(2)
        
        
    }
}
