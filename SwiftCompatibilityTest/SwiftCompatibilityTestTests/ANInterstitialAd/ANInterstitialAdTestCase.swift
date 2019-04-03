/*
 *
 *    Copyright 2018 APPNEXUS INC
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

import XCTest

class ANInterstitialAdTestCase: XCTestCase, ANInterstitialAdDelegate {
    
    let kAppNexusRequestTimeoutInterval = 30.0
    var interstitial: ANInterstitialAd!
    var loadAdSuccesCloseDelay: XCTestExpectation!
    var loadAdSuccesfulException: XCTestExpectation!
    var closeAdSuccesfulException: XCTestExpectation!
    var loadIsReadyException: XCTestExpectation!
    var enableAutoDismissDelay = false
    var didAdClose = false
    var isReady = false
    var isCloseDelay = false
    var timeoutForImpbusRequest: TimeInterval = 0.0
    private var placementID = "13844652"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        timeoutForImpbusRequest = 10.0
        didAdClose = false
        isReady = false
        isCloseDelay = false
        enableAutoDismissDelay = false
        ANHTTPStubbingManager.shared().enable()
        ANHTTPStubbingManager.shared().ignoreUnstubbedRequests = true
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        ANHTTPStubbingManager.shared().disable()
        ANHTTPStubbingManager.shared().removeAllStubs()
        interstitial = nil
        self.loadAdSuccesfulException = nil
        self.loadAdSuccesCloseDelay = nil
        self.closeAdSuccesfulException = nil
        self.loadIsReadyException = nil
    }

    //Test interstitial ad with dismissOnClick
    func test_TC25_ANInterstitialWithDismissOnClickTrue() {
        interstitial = ANInterstitialAd(placementId: placementID)
        interstitial.delegate = self
        interstitial.dismissOnClick = true
        XCTAssertEqual(placementID, interstitial.placementId)
        XCTAssertTrue(interstitial.dismissOnClick)
    }

    //Test interstitial ad without dismissOnClick
    func test_TC26_ANInterstitialAdWithDismissOnClickFalse() {
        interstitial = ANInterstitialAd(placementId: placementID)
        interstitial.delegate = self
        interstitial.dismissOnClick = false
        XCTAssertEqual(placementID, interstitial.placementId)
        XCTAssertFalse(interstitial.dismissOnClick)

    }

    //Test interstitial ad with default dismissOnClick
    func test_TC27_ANInterstitialAdWithDefaultDismissOnClick() {
        interstitial = ANInterstitialAd(placementId: placementID)
        interstitial.delegate = self
        XCTAssertEqual(placementID, interstitial.placementId)
        XCTAssertFalse(interstitial.dismissOnClick)
    }
    
    //Test Interstitial ad with auto dismiss delay
    func test_TC28_ANInterstitialWithAutoDismissAdDelay() {
        interstitial = ANInterstitialAd(placementId: placementID)
        interstitial.delegate = self
        enableAutoDismissDelay = true
        stubRequestWithResponse("SuccessfulStandardAdFromRTBObjectResponse")
        interstitial.load()
        loadAdSuccesfulException = expectation(description: "Waiting for adDidReceiveAd to be received")
        waitForExpectations(timeout: 2 * kAppNexusRequestTimeoutInterval, handler: { error in
        })
        XCTAssertEqual(5, interstitial.controller.autoDismissAdDelay)
        closeAdSuccesfulException = expectation(description: "Waiting for adDidClose to be received")        
        waitForExpectations(timeout: 2 * kAppNexusRequestTimeoutInterval, handler: { error in
            
        })
        XCTAssertTrue(didAdClose)
    }
    
    //Test Interstitial ad without auto dismiss delay
    func test_TC29_ANInterstitialWithoutAutoDismissAdDelay() {
        interstitial = ANInterstitialAd(placementId: placementID)
        interstitial.delegate = self
        enableAutoDismissDelay = false
        stubRequestWithResponse("SuccessfulStandardAdFromRTBObjectResponse")
        interstitial.load()
        loadAdSuccesfulException = expectation(description: "Waiting for adDidReceiveAd to be received")
        waitForExpectations(timeout: 2 * kAppNexusRequestTimeoutInterval, handler: { error in
            
        })
        XCTAssertEqual(-1, interstitial.controller.autoDismissAdDelay)
        
        interstitial.controller.closeButton.sendActions(for: .touchUpInside)
        closeAdSuccesfulException = expectation(description: "Waiting for adDidClose to be received")
        waitForExpectations(timeout: 2 * kAppNexusRequestTimeoutInterval, handler: { error in
            
        })
        XCTAssertTrue(didAdClose)
        
    }
    
   // Test interstitial ad has been fetched and is ready to display
    func test_TC30_ANInterstitialWithIsReady() {

        interstitial = ANInterstitialAd(placementId: placementID)
        interstitial.delegate = self
        stubRequestWithResponse("SuccessfulStandardAdFromRTBObjectResponse")
        XCTAssertFalse(interstitial.isReady)
        loadIsReadyException = expectation(description: "\(#function)")
        interstitial.load()
        waitForExpectations(timeout: 2 * timeoutForImpbusRequest, handler: nil)
        XCTAssertTrue(isReady)

    }

    //Test delay between when an interstitial ad is displayed and when the close button appears to the user
    func test_TC31_ANInterstitialWithCloseDelay() {

        interstitial = ANInterstitialAd(placementId: placementID)
        interstitial.delegate = self
        interstitial.closeDelay = 1
        stubRequestWithResponse("SuccessfulStandardAdFromRTBObjectResponse")
        XCTAssertFalse(interstitial.isReady)
        loadAdSuccesCloseDelay = expectation(description: "\(#function)")
        interstitial.load()
        waitForTimeInterval(6)
        if let obj = self.interstitial.controller.closeButton
        {
          XCTAssertFalse(obj.isHidden)
        }
    }
    
    // MARK: - Stubbing
    func stubRequestWithResponse(_ responseName: String?) {
        let currentBundle = Bundle(for: type(of: self))
        let baseResponse = try? String(contentsOfFile: currentBundle.path(forResource: responseName, ofType: "json") ?? "", encoding: .utf8)
        let requestStub = ANURLConnectionStub()
        requestStub.requestURL = ANSDKSettings.sharedInstance().baseUrlConfig.utAdRequestBaseUrl()
        requestStub.responseCode = 200
        requestStub.responseBody = baseResponse
        
        ANHTTPStubbingManager.shared().add(requestStub)
    }
    @objc func fulfillExpectation(_ expectation: XCTestExpectation?) {
        expectation?.fulfill()
    }
    
    func waitForTimeInterval(_ delay: TimeInterval) {
        let expectation: XCTestExpectation = self.expectation(description: "wait")
        perform(#selector(self.fulfillExpectation(_:)), with: expectation, afterDelay: delay)
        
        waitForExpectations(timeout: TimeInterval(delay + 1), handler: nil)
    }
    
    // MARK: - ANAdDelegate
    func adDidReceiveAd(_ ad: Any!) {
        XCTAssertNotNil(ad)
       
        if loadAdSuccesfulException != nil
        {
           let controller = UIApplication.shared.keyWindow?.rootViewController
            if enableAutoDismissDelay {
                interstitial.display(from: controller, autoDismissDelay: 5)
            } else {
                interstitial.display(from: controller)
            }
            loadAdSuccesfulException.fulfill()
        }
        if loadIsReadyException != nil {
            isReady = true
            loadIsReadyException.fulfill()
        }
        if loadAdSuccesCloseDelay != nil
        {
            let controller = UIApplication.shared.keyWindow?.rootViewController
            interstitial.display(from: controller, autoDismissDelay: 6)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                self.loadAdSuccesCloseDelay.fulfill()
            })
        }

    }
    func adDidClose(_ ad: Any!) {
        didAdClose = true
        if closeAdSuccesfulException != nil
        {
          closeAdSuccesfulException.fulfill()
        }
    }
    func ad(_ ad: Any!, requestFailedWithError error: Error!) {
       
        if loadIsReadyException != nil {
             isReady = false
            loadIsReadyException.fulfill()
        }
    }
}
