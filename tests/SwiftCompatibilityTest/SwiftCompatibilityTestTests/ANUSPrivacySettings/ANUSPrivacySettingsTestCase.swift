/*
*
*    Copyright 2019 APPNEXUS INC
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

class ANUSPrivacySettingsTestCase: XCTestCase, ANBannerAdViewDelegate {
    
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
        let incomingRequest = notification?.userInfo![kANHTTPStubURLProtocolRequest] as? URLRequest
        let requestString = incomingRequest?.url?.absoluteString
        let searchString = ANSDKSettings.sharedInstance().baseUrlConfig.utAdRequestBaseUrl()
        if request == nil && requestString?.range(of:searchString!) != nil{
            request = notification!.userInfo![kANHTTPStubURLProtocolRequest] as? URLRequest
            jsonRequestBody = ANHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: request) as! [String : Any]
        }
    }
    
    //MARK:- Test Methods
    //Test ANUSPrivacySettings for US Privacy String
    func test_TC64_UTRequestForSetUSPrivacyString() {
        ANUSPrivacySettings.setUSPrivacyString("1yn")
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        stubRequestWithResponse("SuccessfulInstreamVideoAdResponse")
        loadAdSuccesfulException = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let privacyString = jsonRequestBody["us_privacy"] as? String {
            XCTAssertNotNil(privacyString)
            XCTAssertEqual(privacyString, "1yn")
        } else {
            XCTFail("US Privacy String nil")
        }
    }
    
    //Test ANUSPrivacySettings for US Privacy Default String
    func test_TC65_UTRequestForSetUSPrivacyDefaultString() {
        ANUSPrivacySettings.reset()
        UserDefaults.standard.removeObject(forKey: "IABUSPrivacy_String")
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        stubRequestWithResponse("SuccessfulInstreamVideoAdResponse")
        loadAdSuccesfulException = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        XCTAssertNil(jsonRequestBody["us_privacy"] )
    }
    
    //Test ANUSPrivacySettings for IAB US Privacy String
    func test_TC66_testUTRequestCheckForIAB_USPrivacyString() {
        ANUSPrivacySettings.reset()
        UserDefaults.standard.set("1yn", forKey: "IABUSPrivacy_String")
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        stubRequestWithResponse("SuccessfulInstreamVideoAdResponse")
        loadAdSuccesfulException = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let privacyString = jsonRequestBody["us_privacy"] as? String {
            XCTAssertNotNil(privacyString)
            XCTAssertEqual(privacyString, "1yn")
        } else {
            XCTFail("US Privacy String nil")
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
    func adDidReceiveAd(_ ad: Any) {
        loadAdSuccesfulException?.fulfill()
    }
    
    func ad(_ ad: Any, requestFailedWithError error: Error) {
        loadAdSuccesfulException?.fulfill()
    }
}
