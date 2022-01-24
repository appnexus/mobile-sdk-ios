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

class ANInstreamVideoAdTestCase: XCTestCase, ANInstreamVideoAdLoadDelegate {

    var instreamVideoAd: ANInstreamVideoAd!
    var expectationLoadVideoAd: XCTestExpectation!
    var request: URLRequest!
    var jsonRequestBody = [String : Any]()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        ANHTTPStubbingManager.shared().enable()
        ANHTTPStubbingManager.shared().ignoreUnstubbedRequests = true
        ANHTTPStubbingManager.shared().broadcastRequests = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestCompleted(_:)), name: NSNotification.Name.anhttpStubURLProtocolRequestDidLoad, object: nil)
        request = nil
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        instreamVideoAd = nil
        expectationLoadVideoAd = nil

        ANHTTPStubbingManager.shared().disable()
        ANHTTPStubbingManager.shared().removeAllStubs()
        ANHTTPStubbingManager.shared().broadcastRequests = false
        ANSDKSettings.sharedInstance().httpsEnabled = false
        NotificationCenter.default.removeObserver(self)
    }

    func requestCompleted(_ notification: Notification?) {
        var incomingRequest = notification?.userInfo![kANHTTPStubURLProtocolRequest] as? URLRequest
        let requestString = incomingRequest?.url?.absoluteString
        let searchString = ANSDKSettings.sharedInstance().baseUrlConfig.utAdRequestBaseUrl()
        if request == nil && requestString?.range(of:searchString!) != nil{
            request = notification!.userInfo![kANHTTPStubURLProtocolRequest] as? URLRequest
            jsonRequestBody = ANHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: request) as! [String : Any]
        }
    }

    // MARK: - Test methods.
    //Test video duration of InstreamVideoAd
    func test_TC32_AdDuration() {
        initializeInstreamVideoWithAllProperties()
        print("reached here")
        XCTAssertNotNil(instreamVideoAd)
        let duration = instreamVideoAd.getDuration()
        XCTAssertNotEqual(duration, 0)
    }

    //Test without setting the video duration of InstreamVideoAd
    func test_TC33_AdDurationNotSet() {
        initializeInstreamVideoWithNoProperties()
        XCTAssertNotNil(instreamVideoAd)
        let duration = instreamVideoAd.getDuration()
        XCTAssertEqual(duration, 0)
    }

    //Test vast url content of InstreamVideoAd
    func test_TC34_VastCreativeURL() {

        initializeInstreamVideoWithAllProperties()
        print("reached here")
        XCTAssertNotNil(instreamVideoAd)
        let vastcreativeTag = instreamVideoAd.getVastURL()
        XCTAssertNotNil(vastcreativeTag)
        XCTAssertNotEqual(vastcreativeTag?.count, 0)
        XCTAssertNotNil(vastcreativeTag)
        XCTAssertEqual(vastcreativeTag, "http://sampletag.com")
    }

    //Test without setting vast url content of InstreamVideoAd
    func test_TC35_VastCreativeValuesNotSet() {
        initializeInstreamVideoWithNoProperties()
        XCTAssertNotNil(instreamVideoAd)
        let vastcreativeTag = instreamVideoAd.getVastURL()
        XCTAssertEqual(vastcreativeTag?.count, 0)
    }

    //Test vast xml content of InstreamVideoAd
    func test_TC36_VastCreativeXML() {

        initializeInstreamVideoWithAllProperties()
        XCTAssertNotNil(instreamVideoAd)
        let vastcreativeXMLTag = instreamVideoAd.getVastXML()
        XCTAssertNotNil(vastcreativeXMLTag)
        XCTAssertNotEqual(vastcreativeXMLTag?.count, 0)
        XCTAssertNotNil(vastcreativeXMLTag)
        XCTAssertEqual(vastcreativeXMLTag, "http://sampletag.com")
    }

    //Test without setting the vast xml content of InstreamVideoAd
    func test_TC37_VastCreativeXMLValuesNotSet() {
        initializeInstreamVideoWithNoProperties()
        XCTAssertNotNil(instreamVideoAd)
        let vastcreativeXMLTag = instreamVideoAd.getVastXML()
        XCTAssertEqual(vastcreativeXMLTag?.count, 0)
    }

    //Test creative tag of InstreamVideoAd
    func test_TC38_CreativeTag() {
        initializeInstreamVideoWithAllProperties()
        XCTAssertNotNil(instreamVideoAd)
        let creativeTag = instreamVideoAd.getCreativeURL()
        XCTAssertNotEqual(creativeTag?.count, 0)
        XCTAssertNotNil(creativeTag)
        XCTAssertEqual(creativeTag, "http://sampletag.com")
    }

    //Test without setting the creative tag of InstreamVideoAd
    func test_TC39_CreativeValuesNotSet() {
        initializeInstreamVideoWithNoProperties()
        XCTAssertNotNil(instreamVideoAd)
        let creativeTag = instreamVideoAd.getCreativeURL()
        XCTAssertEqual(creativeTag?.count, 0)
    }

    //Test play head time for InstreamVideoAd
    func test_TC40_PlayHeadTimeForVideoSet() {
        initializeInstreamVideoWithNoProperties()
        XCTAssertNotNil(instreamVideoAd)
        let duration = instreamVideoAd.getPlayElapsedTime()
        XCTAssertNotEqual(duration, 0)
    }

    //Test creative tag of InstreamVideoAd
    func test_TC63_CustomKeywordsAdded() {
        instreamVideoAd = ANInstreamVideoAd(placementId: "12534678")
        instreamVideoAd.addCustomKeyword(withKey: "force_creative_id", value: "123456789")
        stubRequestWithResponse("SuccessfulInstreamVideoAdResponse")
        instreamVideoAd.load(with: self)
        expectationLoadVideoAd = expectation(description: "\(#function)")
        waitForExpectations(timeout: 30, handler: nil)
        XCTAssertEqual(instreamVideoAd.placementId, "12534678")
        if let arr = jsonRequestBody["keywords"] as? [Any], let dic = arr[0] as? [String : Any], let key = dic["key"] as? String
        {
            XCTAssertEqual(key, "force_creative_id")
        }
        if let arr = jsonRequestBody["keywords"] as? [Any], let dic = arr[0] as? [String : Any], let arr2 = dic["value"] as? [Any], let value = arr2[0] as? String
        {
            XCTAssertEqual(value, "123456789")
        }
    }

    // MARK: - Helper methods.
    func initializeInstreamVideoWithAllProperties() {
        instreamVideoAd = ANInstreamVideoAd()
        instreamVideoAd.adPlayer = ANVideoAdPlayer()
        instreamVideoAd.adPlayer.videoDuration = 10
        instreamVideoAd.adPlayer.creativeURL = "http://sampletag.com"
        instreamVideoAd.adPlayer.vastURLContent = "http://sampletag.com"
        instreamVideoAd.adPlayer.vastXMLContent = "http://sampletag.com"

    }

    func initializeInstreamVideoWithNoProperties() {
        instreamVideoAd = ANInstreamVideoAd()
        instreamVideoAd.adPlayer = ANVideoAdPlayer()
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

    // MARK: - ANInstreamVideoAdLoadDelegate.
    func adDidReceiveAd(_ ad: Any) {
        expectationLoadVideoAd.fulfill()
        expectationLoadVideoAd = nil;

    }
    func ad(_ ad: ANAdProtocol, requestFailedWithError error: Error) {
        print(error.localizedDescription)
    }
}
