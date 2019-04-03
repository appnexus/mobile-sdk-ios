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
import AppNexusSDK

class ANGDPRSettingsTestCase: XCTestCase, ANBannerAdViewDelegate {
    
    var banner : ANBannerAdView!
    weak var loadAdSuccesfulException : XCTestExpectation?
    var timeoutForImpbusRequest: TimeInterval = 0.0
    private var placementID = "4019246"
    var request: URLRequest!
    var jsonRequestBody = [String : Any]()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        banner = nil
        timeoutForImpbusRequest = 10.0
        ANHTTPStubbingManager.shared().enable()
        ANHTTPStubbingManager.shared().ignoreUnstubbedRequests = true
        ANHTTPStubbingManager.shared().broadcastRequests = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestCompleted(_:)), name: NSNotification.Name.anhttpStubURLProtocolRequestDidLoad, object: nil)
        request = nil
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        ANHTTPStubbingManager.shared().disable()
        ANHTTPStubbingManager.shared().removeAllStubs()
        ANHTTPStubbingManager.shared().broadcastRequests = false
        ANSDKSettings.sharedInstance().httpsEnabled = false
        NotificationCenter.default.removeObserver(self)
        self.loadAdSuccesfulException = nil
    }
    
    func requestCompleted(_ notification: Notification?) {
        var incomingRequest = notification?.userInfo![kANHTTPStubURLProtocolRequest] as? URLRequest
        let requestString = incomingRequest?.url?.absoluteString
        let searchString = ANSDKSettings.sharedInstance().baseUrlConfig.utAdRequestBaseUrl()
        if request == nil && requestString?.range(of:searchString!) != nil{
            request = notification!.userInfo![kANHTTPStubURLProtocolRequest] as! URLRequest
            jsonRequestBody = ANHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: request) as! [String : Any]
        }
    }
    
    //MARK:- Test Methods
    //Test ANGDPRSettings for GDPR consent to true
    func test_TC58_ANGDPRSettingsForSetGDPRConsentTrue() {
        ANGDPRSettings.setConsentRequired(true)
        ANGDPRSettings.setConsentString("a390129402948384453")
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        stubRequestWithResponse("SuccessfulInstreamVideoAdResponse")
        loadAdSuccesfulException = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let dic = jsonRequestBody["gdpr_consent"] as? [String : Any], let consent_required = dic["consent_required"] as? Bool
        {
            XCTAssertTrue(consent_required)
        }
        if let dic = jsonRequestBody["gdpr_consent"] as? [String : Any], let consent_string = dic["consent_string"] as? String
        {
            XCTAssertNotNil(consent_string)
        }
    }
    
    //Test ANGDPRSettings for GDPR consent to false
    func test_TC59_ANGDPRSettingsForSetGDPRConsentFalse() {
        ANGDPRSettings.setConsentRequired(false)
        ANGDPRSettings.setConsentString("a390129402948384453")
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        stubRequestWithResponse("SuccessfulInstreamVideoAdResponse")
        loadAdSuccesfulException = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let dic = jsonRequestBody["gdpr_consent"] as? [String : Any], let consent_required = dic["consent_required"] as? Bool
        {
            XCTAssertFalse(consent_required)
        }
        if let dic = jsonRequestBody["gdpr_consent"] as? [String : Any], let consent_string = dic["consent_string"] as? String
        {
            XCTAssertNotNil(consent_string)
        }
    }
    
    //Test ANGDPRSettings for default GDPR Consent
    func test_TC60_ANGDPRSettingsForSetGDPRDefaultConsent() {
        ANGDPRSettings.reset()
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        stubRequestWithResponse("SuccessfulInstreamVideoAdResponse")
        loadAdSuccesfulException = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        XCTAssertNil(jsonRequestBody["gdpr_consent"] )
    }
    
    //Test ANGDPRSettings for request content type
    func test_TC61_ANGDPRSettingsRequestContentType() {
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        stubRequestWithResponse("SuccessfulInstreamVideoAdResponse")
        loadAdSuccesfulException = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        let contentType = request.value(forHTTPHeaderField: "content-type")
        XCTAssertNotNil(contentType)
        XCTAssertEqual("application/json", contentType)
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
        loadAdSuccesfulException?.fulfill()
    }
    
    func ad(_ ad: Any!, requestFailedWithError error: Error!) {
        loadAdSuccesfulException?.fulfill()
    }
}
