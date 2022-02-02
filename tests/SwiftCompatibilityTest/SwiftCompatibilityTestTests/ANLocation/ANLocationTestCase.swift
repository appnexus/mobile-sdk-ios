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

class AANLocationTestCase: XCTestCase, ANBannerAdViewDelegate {
    
    let kAppNexusNewYorkLocationLatitudeFull: CGFloat = 40.7418474
    let kAppNexusNewYorkLocationLongitudeFull: CGFloat = -73.99096229999998
    let kAppNexusNewYorkHorizontalAccuracy: CGFloat = 150
    let kAppNexusNewYorkLocationLatitudeTwoDecimalPlaces: CGFloat = 40.74
    let kAppNexusNewYorkLocationLongitudeTwoDecimalPlaces: CGFloat = -73.99
    let kAppNexusNewYorkLocationLatitudeOneDecimalPlace: CGFloat = 40.7
    let kAppNexusNewYorkLocationLongitudeOneDecimalPlace: CGFloat = -74.0
    let kAppNexusNewYorkLocationLatitudeNoDecimalPlaces: CGFloat = 41
    let kAppNexusNewYorkLocationLongitudeNoDecimalPlaces: CGFloat = -74
    let kAppNexusNewYorkLocationLatitudeInvalid: CGFloat = 100
    let kAppNexusNewYorkLocationLongitudeInvalid: CGFloat = 200
    var banner : ANBannerAdView!
    var loadAdSuccesfulException : XCTestExpectation?
    var timeoutForImpbusRequest: TimeInterval = 0.0
    var placementID = "4019246"
    var request: URLRequest!
    var jsonRequestBody = [String : Any]()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        banner = nil
        timeoutForImpbusRequest = 20.0
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
        request = nil
        banner = nil

    }
    func requestCompleted(_ notification: Notification?) {
        var incomingRequest = notification?.userInfo![kANHTTPStubURLProtocolRequest] as? URLRequest
        let requestString = incomingRequest?.url?.absoluteString
        let searchString = ANSDKSettings.sharedInstance().baseUrlConfig.utAdRequestBaseUrl()
        if request == nil && requestString?.range(of:searchString!) != nil{
            request = notification!.userInfo![kANHTTPStubURLProtocolRequest] as! URLRequest
            jsonRequestBody = ANHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: request) as! [String : Any]
            print(jsonRequestBody)
        }
    }
    // Test ANLocation with valid latitude
    func test_TC43_LocationWithValidLatitude() {
        let location = ANLocation.getWithLatitude(kAppNexusNewYorkLocationLatitudeFull, longitude: kAppNexusNewYorkLocationLongitudeFull, timestamp: Date(), horizontalAccuracy: kAppNexusNewYorkHorizontalAccuracy)
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        self.banner.location = location
        stubRequestWithResponse("SuccessfulLocationCreativeForBannerAdResponse")
        loadAdSuccesfulException = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let deviceDic = jsonRequestBody["device"] as? [String : Any], let geoDic = deviceDic["geo"] as? [String : Any]
        {
            XCTAssertNotNil(banner.location)
            XCTAssertEqual(banner.location?.latitude, kAppNexusNewYorkLocationLatitudeFull)
            if let lat = geoDic["lat"] as? CGFloat
            {
                XCTAssertEqual(lat, kAppNexusNewYorkLocationLatitudeFull)
            }
        }
    }
    
    // Test ANLocation with invalid latitude
    func test_TC44_LocationWithInvalidLatitude() {
        let location = ANLocation.getWithLatitude(kAppNexusNewYorkLocationLatitudeInvalid, longitude: kAppNexusNewYorkLocationLongitudeFull, timestamp: Date(), horizontalAccuracy: kAppNexusNewYorkHorizontalAccuracy)
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        self.banner.location = location
        stubRequestWithResponse("SuccessfulLocationCreativeForBannerAdResponse")
        loadAdSuccesfulException = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let deviceDic = jsonRequestBody["device"] as? [String : Any]
        {
            XCTAssertNil(location)
            XCTAssertNotEqual(location?.latitude, kAppNexusNewYorkLocationLatitudeInvalid)
            XCTAssertNil(deviceDic["geo"])
            
        }
        
    }
    
    // Test ANLocation with valid longitude
    func test_TC45_LocationWithValidLongitude() {
        let location = ANLocation.getWithLatitude(kAppNexusNewYorkLocationLatitudeFull, longitude: kAppNexusNewYorkLocationLongitudeFull, timestamp: Date(), horizontalAccuracy: kAppNexusNewYorkHorizontalAccuracy)
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        self.banner.location = location
        stubRequestWithResponse("SuccessfulLocationCreativeForBannerAdResponse")
        loadAdSuccesfulException = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let deviceDic = jsonRequestBody["device"] as? [String : Any], let geoDic = deviceDic["geo"] as? [String : Any]
        {
            XCTAssertNotNil(location)
            XCTAssertEqual(location?.longitude, kAppNexusNewYorkLocationLongitudeFull)
            if let lng = geoDic["lng"] as? CGFloat
            {
                XCTAssertEqual(lng, kAppNexusNewYorkLocationLongitudeFull)
            }
        }
    }
    
    // Test ANLocation with invalid longitude
    func test_TC46_LocationWithInvalidLongitude() {
        let location = ANLocation.getWithLatitude(kAppNexusNewYorkLocationLatitudeFull, longitude: kAppNexusNewYorkLocationLongitudeInvalid, timestamp: Date(), horizontalAccuracy: kAppNexusNewYorkHorizontalAccuracy)
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        self.banner.location = location
        stubRequestWithResponse("SuccessfulLocationCreativeForBannerAdResponse")
        loadAdSuccesfulException = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest*2, handler: nil)
        if let deviceDic = jsonRequestBody["device"] as? [String : Any]
        {
            XCTAssertNil(location)
            XCTAssertNotEqual(location?.longitude, kAppNexusNewYorkLocationLongitudeFull)
            XCTAssertNil(deviceDic["geo"])
            
        }
    }
    
    // Test ANLocation with passed timestamp
    func test_TC47_LocationWithTimeStamp() {
        let date = Date()
        let location = ANLocation.getWithLatitude(kAppNexusNewYorkLocationLatitudeFull, longitude: kAppNexusNewYorkLocationLongitudeFull, timestamp: date, horizontalAccuracy: kAppNexusNewYorkHorizontalAccuracy)
        XCTAssertNotNil(location)
        XCTAssertEqual(location?.timestamp, date)
    }
    
    // Test ANLocation with horizontalAccuracy
    func test_TC48_LocationWithHorizontalAccuracy() {
        let location = ANLocation.getWithLatitude(kAppNexusNewYorkLocationLatitudeFull, longitude: kAppNexusNewYorkLocationLongitudeFull, timestamp: Date(), horizontalAccuracy: kAppNexusNewYorkHorizontalAccuracy)
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        self.banner.location = location
        stubRequestWithResponse("SuccessfulLocationCreativeForBannerAdResponse")
        loadAdSuccesfulException = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let deviceDic = jsonRequestBody["device"] as? [String : Any], let geoDic = deviceDic["geo"] as? [String : Any]
        {
            XCTAssertNotNil(location)
            XCTAssertEqual(location?.horizontalAccuracy, kAppNexusNewYorkHorizontalAccuracy)
            if let loc_precision = geoDic["loc_precision"] as? CGFloat
            {
                XCTAssertEqual(loc_precision, kAppNexusNewYorkHorizontalAccuracy)
            }
        }
    }
    
    // Test ANLocation with precision upto two Decimal Places
    func test_TC49_LocationWithPrecisionTwoDecimalPlaces() {
        let location = ANLocation.getWithLatitude(kAppNexusNewYorkLocationLatitudeFull, longitude: kAppNexusNewYorkLocationLongitudeFull, timestamp: Date(), horizontalAccuracy: kAppNexusNewYorkHorizontalAccuracy, precision: 2)
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        self.banner.location = location
        stubRequestWithResponse("SuccessfulLocationCreativeForBannerAdResponse")
        loadAdSuccesfulException = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let deviceDic = jsonRequestBody["device"] as? [String : Any], let geoDic = deviceDic["geo"] as? [String : Any]
        {
            XCTAssertNotNil(location)
            XCTAssertEqual(location?.latitude, kAppNexusNewYorkLocationLatitudeTwoDecimalPlaces)
            XCTAssertEqual(location?.longitude, kAppNexusNewYorkLocationLongitudeTwoDecimalPlaces)
            XCTAssertEqual(location?.horizontalAccuracy, kAppNexusNewYorkHorizontalAccuracy)
            if let lat = geoDic["lat"] as? CGFloat
            {
                XCTAssertEqual(lat, kAppNexusNewYorkLocationLatitudeTwoDecimalPlaces)
            }
            if let lng = geoDic["lng"] as? CGFloat
            {
                XCTAssertEqual(lng, kAppNexusNewYorkLocationLongitudeTwoDecimalPlaces)
            }
        }
    }
    
    // Test ANLocation with precision upto one Decimal Places
    func test_TC50_PrecisionOneDecimalPlace() {
        let location = ANLocation.getWithLatitude(kAppNexusNewYorkLocationLatitudeFull, longitude: kAppNexusNewYorkLocationLongitudeFull, timestamp: Date(), horizontalAccuracy: kAppNexusNewYorkHorizontalAccuracy, precision: 1)
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        self.banner.location = location
        stubRequestWithResponse("SuccessfulLocationCreativeForBannerAdResponse")
        loadAdSuccesfulException = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let deviceDic = jsonRequestBody["device"] as? [String : Any], let geoDic = deviceDic["geo"] as? [String : Any]
        {
            XCTAssertNotNil(location)
            XCTAssertEqual(location?.latitude, kAppNexusNewYorkLocationLatitudeOneDecimalPlace)
            XCTAssertEqual(location?.longitude, kAppNexusNewYorkLocationLongitudeOneDecimalPlace)
            XCTAssertEqual(location?.horizontalAccuracy, kAppNexusNewYorkHorizontalAccuracy)
            if let lat = geoDic["lat"] as? CGFloat
            {
                XCTAssertEqual(lat, kAppNexusNewYorkLocationLatitudeOneDecimalPlace)
            }
            if let lng = geoDic["lng"] as? CGFloat
            {
                XCTAssertEqual(lng, kAppNexusNewYorkLocationLongitudeOneDecimalPlace)
            }
        }
    }
    
    // Test ANLocation with precision upto zero Decimal Places
    func test_TC51_PrecisionNoDecimalPlaces() {
        let location = ANLocation.getWithLatitude(kAppNexusNewYorkLocationLatitudeFull, longitude: kAppNexusNewYorkLocationLongitudeFull, timestamp: Date(), horizontalAccuracy: kAppNexusNewYorkHorizontalAccuracy, precision: 0)
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        self.banner.location = location
        stubRequestWithResponse("SuccessfulLocationCreativeForBannerAdResponse")
        loadAdSuccesfulException = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let deviceDic = jsonRequestBody["device"] as? [String : Any], let geoDic = deviceDic["geo"] as? [String : Any]
        {
            XCTAssertNotNil(location)
            XCTAssertEqual(location?.latitude, kAppNexusNewYorkLocationLatitudeNoDecimalPlaces)
            XCTAssertEqual(location?.longitude, kAppNexusNewYorkLocationLongitudeNoDecimalPlaces)
            XCTAssertEqual(location?.horizontalAccuracy, kAppNexusNewYorkHorizontalAccuracy)
            if let lat = geoDic["lat"] as? CGFloat
            {
                XCTAssertEqual(lat, kAppNexusNewYorkLocationLatitudeNoDecimalPlaces)
            }
            if let lng = geoDic["lng"] as? CGFloat
            {
                XCTAssertEqual(lng, kAppNexusNewYorkLocationLongitudeNoDecimalPlaces)
            }
        }
    }

    // Test ANLocation without precision
    func test_TC52_PrecisionWithNoPrecision() {
        let location = ANLocation.getWithLatitude(kAppNexusNewYorkLocationLatitudeFull, longitude: kAppNexusNewYorkLocationLongitudeFull, timestamp: Date(), horizontalAccuracy: kAppNexusNewYorkHorizontalAccuracy, precision: -1)
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        self.banner.location = location
        stubRequestWithResponse("SuccessfulLocationCreativeForBannerAdResponse")
        loadAdSuccesfulException = expectation(description: "\(#function)")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        if let deviceDic = jsonRequestBody["device"] as? [String : Any], let geoDic = deviceDic["geo"] as? [String : Any]
        {
            XCTAssertNotNil(location)
            XCTAssertEqual(location?.latitude, kAppNexusNewYorkLocationLatitudeFull)
            XCTAssertEqual(location?.longitude, kAppNexusNewYorkLocationLongitudeFull)
            XCTAssertEqual(location?.horizontalAccuracy, kAppNexusNewYorkHorizontalAccuracy)
            if let lat = geoDic["lat"] as? CGFloat
            {
                XCTAssertEqual(lat, kAppNexusNewYorkLocationLatitudeFull)
            }
            if let lng = geoDic["lng"] as? CGFloat
            {
                XCTAssertEqual(lng, kAppNexusNewYorkLocationLongitudeFull)
            }
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
        XCTAssertNotNil(ad)
        loadAdSuccesfulException = nil;

    }
    
    func ad(_ ad: Any, requestFailedWithError error: Error) {
        loadAdSuccesfulException?.fulfill()
        XCTAssertTrue(false)
        loadAdSuccesfulException = nil;

    }
}
