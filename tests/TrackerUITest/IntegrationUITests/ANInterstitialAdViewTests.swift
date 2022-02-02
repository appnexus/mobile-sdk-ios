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

class ANInterstitialAdViewTests: XCTestCase {
    
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        continueAfterFailure = false
        
 }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testRTBInterstitial() {
       
        
        let adObject = AdObject(adType: "Interstitial", accessibilityIdentifier: PlacementTestConstants.InterstitialAd.testRTBInterstitial, placement: InterstitialPlacementId)

        let interstitialAdObject =  InterstitialAdObject(closeDelay: 5, adObject: adObject)
        
        let interstitialAdObjectString =  AdObjectModel.encodeInterstitialObject(adObject: interstitialAdObject)

        let app = XCUIApplication()
        app.launchArguments.append(PlacementTestConstants.InterstitialAd.testRTBInterstitial)
        app.launchArguments.append(interstitialAdObjectString)
        app.launch()
        
     
        // Asserts Ad Elemnts once ad Did Receive
        let interstitialAd = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
       

        wait(for: interstitialAd, timeout: 10)

        XCGlobal.screenshotWithTitle(title: PlacementTestConstants.InterstitialAd.testRTBInterstitial)

        XCTAssertEqual(interstitialAd.exists, true)
        wait(30)
        let closeButton = app.buttons["interstitial flat closebox"]
        XCTAssertEqual(closeButton.exists, true)
        closeButton.tap()
        wait(1)
 
        let element = app.otherElements.containing(.navigationBar, identifier:"Interstitial Ad").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        // No Ad on Screen
        XCTAssertEqual(element.exists, true)
        wait(2)

    }
    

 
}



