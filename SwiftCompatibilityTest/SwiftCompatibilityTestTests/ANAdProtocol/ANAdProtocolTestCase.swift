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

class ANAdProtocolTestCase: XCTestCase, ANBannerAdViewDelegate {
    
    var banner : ANBannerAdView!
    weak var expectationRequest: XCTestExpectation?
    weak var expectationResponse: XCTestExpectation?
    var nativeAd: ANNativeAdResponse?
    var timeoutForImpbusRequest: TimeInterval = 0.0
    var placementID = "1"
    var memberID: Int = 958
    var inventoryCode = "trucksmash"
    let kAppNexusNewYorkLocationLatitudeFull: CGFloat = 40.7418474
    let kAppNexusNewYorkLocationLongitudeFull: CGFloat = -73.99096229999998
    let kAppNexusNewYorkHorizontalAccuracy: CGFloat = 150
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
        expectationRequest = nil
        expectationResponse = nil
    }
    
    func requestCompleted(_ notification: Notification?) {
        if (expectationRequest != nil) {
            expectationRequest?.fulfill()
            expectationRequest = nil
        }
        var incomingRequest = notification?.userInfo![kANHTTPStubURLProtocolRequest] as? URLRequest
        let requestString = incomingRequest?.url?.absoluteString
        let searchString = ANSDKSettings.sharedInstance().baseUrlConfig.utAdRequestBaseUrl()
        if request == nil && requestString?.range(of:searchString!) != nil{
            request = notification!.userInfo![kANHTTPStubURLProtocolRequest] as? URLRequest
            jsonRequestBody = ANHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: request) as! [String : Any]
        }
    }
    
    //MARK:- Test Methods
    //Test to verify Placement ID by comparing it with JSON request.
    func test_TC1_InitializeWithPlacementID() {

        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        stubRequestWithResponse("SuccessfulInstreamVideoAdResponse")
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        XCTAssertEqual(self.banner?.placementId, placementID)
        if let arrTags = jsonRequestBody["tags"] as? [Any], let dic = arrTags[0] as? [String : Any], let id = dic["id"] as? Int
        {
            XCTAssertEqual(id, Int(placementID))
        }
        
    }
    
    //Test to verify Member ID and Inventory Code by comparing them with JSON request.
    func test_TC2_InitializeWithMemberIDAndCode() {
        
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), memberId: memberID, inventoryCode: inventoryCode, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        stubRequestWithResponse("SuccessfulInstreamVideoAdResponse")
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        //
        XCTAssertEqual(self.banner?.memberId, memberID)
        XCTAssertEqual(self.banner?.inventoryCode, inventoryCode)
        if let memberId = jsonRequestBody["member_id"] as? Int
        {
            XCTAssertEqual(memberId, memberID)
        }
        if let arrTags = jsonRequestBody["tags"] as? [Any], let dic = arrTags[0] as? [String : Any], let id = dic["code"] as? String
        {
            XCTAssertEqual(id, inventoryCode)
        }
    }
    
    // Test Location by comparing  with JSON request.
    func test_TC3_LocationInBanner() {
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), memberId: memberID, inventoryCode: inventoryCode, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        self.banner.location = ANLocation.getWithLatitude(kAppNexusNewYorkLocationLatitudeFull, longitude: kAppNexusNewYorkLocationLongitudeFull, timestamp: Date(), horizontalAccuracy: kAppNexusNewYorkHorizontalAccuracy)
        stubRequestWithResponse("SuccessfulInstreamVideoAdResponse")
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let deviceDic = jsonRequestBody["device"] as? [String : Any], let geoDic = deviceDic["geo"] as? [String : Any]
        {
            XCTAssertNotNil(banner.location)
            XCTAssertEqual(banner.location?.latitude, kAppNexusNewYorkLocationLatitudeFull)
            XCTAssertEqual(banner.location?.longitude, kAppNexusNewYorkLocationLongitudeFull)
            XCTAssertEqual(banner.location?.horizontalAccuracy, kAppNexusNewYorkHorizontalAccuracy)
            if let lat = geoDic["lat"] as? CGFloat
            {
              XCTAssertEqual(lat, kAppNexusNewYorkLocationLatitudeFull)
            }
            if let lng = geoDic["lng"] as? CGFloat
            {
                XCTAssertEqual(lng, kAppNexusNewYorkLocationLongitudeFull)
            }
            if let loc_precision = geoDic["loc_precision"] as? CGFloat
            {
                XCTAssertEqual(loc_precision, kAppNexusNewYorkHorizontalAccuracy)
            }
        }
    }
    
    // Test Reserve price by comparing  with JSON request.
    func test_TC4_ReservePriceInBanner() {
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), memberId: memberID, inventoryCode: inventoryCode, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        self.banner.reserve = 100.0
        stubRequestWithResponse("SuccessfulInstreamVideoAdResponse")
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let arrTags = jsonRequestBody["tags"] as? [Any], let dic = arrTags[0] as? [String : Any], let reserve = dic["reserve"] as? CGFloat
        {
            XCTAssertEqual(banner.reserve , reserve)
        }
    }
    
    // Test Age by comparing them with JSON request.
    func test_TC5_AgeInBanner() {
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), memberId: memberID, inventoryCode: inventoryCode, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        self.banner.age = "25"
        stubRequestWithResponse("SuccessfulInstreamVideoAdResponse")
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let dic = jsonRequestBody["user"] as? [String : Any],let id = dic["age"] as? Int
        {
            XCTAssertTrue(Int(banner.age) == id)
        }
    }
    
    // Test Gender by comparing with JSON request.
    func test_TC6_GenderInBanner() {
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), memberId: memberID, inventoryCode: inventoryCode, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        self.banner.gender = .male
        stubRequestWithResponse("SuccessfulInstreamVideoAdResponse")
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let dic = jsonRequestBody["user"] as? [String : Any],let id = dic["gender"] as? Int
        {
            XCTAssertTrue(banner.gender.rawValue == id)
        }
    }

    // Test externalUid by comparing it with JSON request.
    func test_TC7_ExternalUidInBanner() {
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), memberId: memberID, inventoryCode: inventoryCode, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        self.banner.externalUid = "AppNexus"
        stubRequestWithResponse("SuccessfulInstreamVideoAdResponse")
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let dic = jsonRequestBody["user"] as? [String : Any],let id = dic["external_uid"] as? String
        {
            XCTAssertTrue(banner.externalUid == id)
        }
        
    }
    //Test Ad Type of the passed banner object is Native
    func test_TC8_AdTypeValueInNative() {
        stubRequestWithResponse("appnexus_standard_response")
        banner = ANBannerAdView(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID)
        banner.delegate = self
        banner.shouldAllowNativeDemand = true
        banner.adSize = CGSize(width: 300, height: 250)
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest*2, handler: nil)
        XCTAssertTrue(ANAdType.native.rawValue == banner.adType.rawValue)
    }
    
    //Test Ad Type of the passed banner object is Banner
    func test_TC9_AdTypeValueInBanner() {
        stubRequestWithResponse("bannerNative_basic_banner")
        banner = ANBannerAdView(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID)
        banner.delegate = self
        banner.adSize = CGSize(width: 300, height: 250)
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        XCTAssertTrue(ANAdType.banner.rawValue == banner.adType.rawValue)
    }
    
    //Test browser settings are passed in banner native object by verifying with JSON response
    func test_TC10_BrowserSettingsArePassedToNativeAdObject() {
        stubRequestWithResponse("appnexus_standard_response")
        banner = ANBannerAdView(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID)
        banner.delegate = self
        banner.shouldAllowNativeDemand = true
        banner.adSize = CGSize(width: 300, height: 250)
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        XCTAssertEqual(banner.clickThroughAction, nativeAd?.clickThroughAction)
        XCTAssertEqual(banner.landingPageLoadsInBackground, nativeAd?.landingPageLoadsInBackground)
    }
    
    // Test PSAs value by comparing it with JSON request.
    func test_TC11_ShouldServePublicServiceAnnouncements() {
        stubRequestWithResponse("appnexus_standard_response")
        banner = ANBannerAdView(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID)
        banner.delegate = self
        banner.shouldServePublicServiceAnnouncements = true
        banner.adSize = CGSize(width: 300, height: 250)
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let arrTags = jsonRequestBody["tags"] as? [Any], let dic = arrTags[0] as? [String : Any], let id = dic["disable_psa"] as? Bool
        {
            XCTAssertFalse(id)
        }
    }
    
    //Test to verify RendererId by comparing it with JSON request.
    func test_TC62_BannerNativeVideoUsingRendererIdObject() {
        
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), memberId: memberID, inventoryCode: inventoryCode, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        self.banner.setAllowNativeDemand(true, withRendererId: 127)
        stubRequestWithResponse("native_videoResponse")
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        //
        XCTAssertEqual(self.banner?.nativeAdRendererId, 127)
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
        if (ad is ANBannerAdView) {
            expectationResponse?.fulfill()
        }

    }
    
    func ad(_ loadInstance: Any!, didReceiveNativeAd responseInstance: Any!) {
        XCTAssertNotNil(loadInstance)
        XCTAssertNotNil(responseInstance)
        if (responseInstance is ANNativeStandardAdResponse) {
            nativeAd = responseInstance as? ANNativeAdResponse
            expectationResponse?.fulfill()
        }
        if (responseInstance is ANNativeMediatedAdResponse) {
            nativeAd = responseInstance as? ANNativeAdResponse
            expectationResponse?.fulfill()
        }
    }
    
    func ad(_ ad: Any!, requestFailedWithError error: Error!) {
        expectationResponse?.fulfill()
        XCTAssertTrue(false)
    }

}
