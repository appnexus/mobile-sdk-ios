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
@testable import AppNexusSDK

class ANBannerAdTestCase: XCTestCase, ANBannerAdViewDelegate {
    
    var banner : ANBannerAdView!
    var nativeAd: ANNativeAdResponse?
    var standardAd: ANMRAIDContainerView?
    weak var expectationRequest: XCTestExpectation?
    weak var expectationResponse: XCTestExpectation?
    var timeoutForImpbusRequest: TimeInterval = 0.0
    var centerXConstraint: NSLayoutConstraint!
    var centerYConstraint: NSLayoutConstraint!
    var foundStandardAdResponseObject = false
    private var placementID = "4019246"
    var request: URLRequest!
    var jsonRequestBody = [String : Any]()
    
    // MARK: - Test lifecycle.
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ANGlobal.getUserAgent()
        ANLogManager.setANLogLevel(ANLogLevel.all)
        banner = nil
        nativeAd = nil
        standardAd = nil
        expectationRequest = nil
        expectationResponse = nil
        timeoutForImpbusRequest = 10.0
        foundStandardAdResponseObject = false
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
        cleanupRootViewController()
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
            print(jsonRequestBody)
        }
    }

    //MARK:- Test Methods
    // Test ANAllowedMediaType is Banner default by checking it's count to 1
    func test_TC12_IsBannerTypeDefault()
    {
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        XCTAssertEqual(self.banner.adAllowedMediaTypes().count , 1)
        XCTAssertTrue(self.banner.adAllowedMediaTypes().contains(NSNumber.init(integerLiteral: Int(ANAllowedMediaType.banner.rawValue))))
    }
    
    // Test ANAllowedMediaType is Banner and Video by checking it's count to 2
    func test_TC13_IsBannerVideoEnabled()
    {
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.shouldAllowVideoDemand = true
        XCTAssertEqual(self.banner.adAllowedMediaTypes().count , 2)
        XCTAssertTrue(self.banner.adAllowedMediaTypes().contains(NSNumber.init(integerLiteral: Int(ANAllowedMediaType.banner.rawValue))))
        XCTAssertTrue(self.banner.adAllowedMediaTypes().contains(NSNumber.init(integerLiteral: Int(ANAllowedMediaType.video.rawValue))))
        XCTAssertFalse(self.banner.adAllowedMediaTypes().contains(NSNumber.init(integerLiteral: Int(ANAllowedMediaType.native.rawValue))))
    }
    
    // Test ANAllowedMediaType is Banner and Native by checking it's count to 2
    func test_TC14_IsBannerNativeEnabled()
    {
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.shouldAllowNativeDemand = true
        XCTAssertEqual(self.banner.adAllowedMediaTypes().count , 2)
        XCTAssertTrue(self.banner.adAllowedMediaTypes().contains(NSNumber.init(integerLiteral: Int(ANAllowedMediaType.banner.rawValue))))
        XCTAssertFalse(self.banner.adAllowedMediaTypes().contains(NSNumber.init(integerLiteral: Int(ANAllowedMediaType.video.rawValue))))
        XCTAssertTrue(self.banner.adAllowedMediaTypes().contains(NSNumber.init(integerLiteral: Int(ANAllowedMediaType.native.rawValue))))
        
    }
    
    // Test ANAllowedMediaType is Banner, Native and Video by checking it's count to 3
    func test_TC15_IsBannerVideoNativeEnabled()
    {
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.shouldAllowVideoDemand = true
        self.banner.shouldAllowNativeDemand = true
        XCTAssertEqual(self.banner.adAllowedMediaTypes().count , 3)
        XCTAssertTrue(self.banner.adAllowedMediaTypes().contains(NSNumber.init(integerLiteral: Int(ANAllowedMediaType.banner.rawValue))))
        XCTAssertTrue(self.banner.adAllowedMediaTypes().contains(NSNumber.init(integerLiteral: Int(ANAllowedMediaType.video.rawValue))))
        XCTAssertTrue(self.banner.adAllowedMediaTypes().contains(NSNumber.init(integerLiteral: Int(ANAllowedMediaType.native.rawValue))))
        
    }

    //Test whether ads will resize to fit the container width in banner
    func test_TC16_ShouldResizeAdToFitContainer() {
        banner = ANBannerAdView(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: "3")
        banner.delegate = self
        banner.shouldResizeAdToFitContainer = true
        banner.adSize = CGSize(width: 300, height: 250)
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        stubRequestWithResponse("bannerNative_basic_banner")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest*2, handler: nil)
        XCTAssertTrue(banner.shouldResizeAdToFitContainer == true)
    }
    
    //Test Ad size and loaded ad size values with JSON request
    func test_TC17_AdSizeAndLoadedAdSizeInBanner() {
        let size = CGSize(width: 300, height: 250)
        banner = ANBannerAdView(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID)
        banner.delegate = self
        banner.adSize = size
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        stubRequestWithResponse("bannerNative_basic_banner")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        XCTAssertTrue(banner.adSize == size)
        XCTAssertTrue(banner.loadedAdSize == size)
        if let arrTags = jsonRequestBody["tags"] as? [Any], let dic = arrTags[0] as? [String : Any], let arrSizes = dic["sizes"] as? [Any]
        {
            for sizeDic in arrSizes
            {
                if let dicSize = sizeDic as? [String : Int]
                {
                    let size = CGSize(width: dicSize["width"]!, height: dicSize["height"]!)
                     XCTAssertEqual(banner.adSize , size)
                     XCTAssertEqual(banner.loadedAdSize , size)
                }
            }
        }
    }
    
    // Test AdSizes array contains passed ad size of the banner ad
    func test_TC18_AdSizesInBanner() {
        let size = CGSize(width: 300, height: 250)
        banner = ANBannerAdView(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID)
        banner.delegate = self
        banner.adSize = size
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        stubRequestWithResponse("bannerNative_basic_banner")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        XCTAssertTrue(banner.adSizes.contains(size as NSValue))
        
        
    }
    
    //Autorefresh interval value compare when it's passed in Banner
    func test_TC19_AutoRefreshIntervalInBanner() {
        banner = ANBannerAdView(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID)
        banner.autoRefreshInterval = 15
        banner.delegate = self
        banner.adSize = CGSize(width: 300, height: 250)
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        stubRequestWithResponse("bannerNative_basic_banner")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        XCTAssertTrue(banner.autoRefreshInterval == 15)
        XCTAssertNotNil(banner.universalAdFetcher.autoRefreshTimer)
    }
    
    //Test creative ID of banner is same with creativeId of ANNativeAdResponse with JSON response
    func test_TC20_CreativeIdIsStoredInBannerAdViewObject() {
        banner = ANBannerAdView(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: "4019246")
        banner.delegate = self
        banner.shouldAllowNativeDemand = true
        banner.adSize = CGSize(width: 300, height: 250)
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        stubRequestWithResponse("appnexus_standard_response")
        banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        XCTAssertNotNil(banner.creativeId)
        XCTAssertEqual(banner.creativeId, nativeAd?.creativeId)
    }
    
    // Test Fade transition of Banner
    func test_TC21_FadeTransition() {
        createBannerView()
        let bannerAdView = self.banner
        bannerAdView?.transitionType = ANBannerViewAdTransitionType.fade
        bannerAdView?.transitionDuration = 2.5
        // Adding Content View
        bannerAdView?.contentView = catContentView()
        XCTAssert(bannerAdView?.transitionInProgress.boolValue == true)
        if let aView = bannerAdView {
            keyValueObservingExpectation(for: aView, keyPath: "transitionInProgress", expectedValue: false)
        }
        waitForExpectations(timeout: (bannerAdView?.transitionDuration)! + 0.1, handler: { error in
            XCTAssert(bannerAdView?.transitionInProgress.boolValue == false)
            bannerAdView?.removeFromSuperview()
        })
    }
    
    // Test flip transition of banner
    func test_TC22_FlipTransition() {
        createBannerView()
        // Setup
        let bannerAdView = self.banner
        bannerAdView?.transitionType = ANBannerViewAdTransitionType.flip
        bannerAdView?.transitionDuration = 2.5
        
        // Adding first content view
        let catContentView: UIView? = self.catContentView()
        bannerAdView?.contentView = catContentView
        XCTestCase.delay(forTimeInterval: (bannerAdView?.transitionDuration)! + 0.1)
        XCTAssert(bannerAdView?.transitionInProgress.boolValue == false)
        XCTAssert(bannerAdView?.subviews.count == 1)
        XCTAssert(bannerAdView?.subviews.first == catContentView)
        
        // Adding second content view
        let dogContentView: UIView? = self.dogContentView()
        bannerAdView?.contentView = dogContentView
        XCTestCase.delay(forTimeInterval: (bannerAdView?.transitionDuration)! + 0.1)
        XCTAssert(bannerAdView?.transitionInProgress.boolValue == false)
        XCTAssert(bannerAdView?.subviews.count == 1)
        XCTAssert(bannerAdView?.subviews.first == dogContentView)
        
        bannerAdView?.removeFromSuperview()
    }
    
    func createBannerView() {
        let bannerAdView = self.bannerView(withFrameSize: CGSize(width: 300, height: 250))
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController!
        bannerAdView?.rootViewController = rootViewController
        if let aView = bannerAdView {
            rootViewController?.view.addSubview(aView)
        }
        
        centerXConstraint = NSLayoutConstraint(item: rootViewController?.view as Any, attribute: .centerX, relatedBy: .equal, toItem: bannerAdView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        centerYConstraint = NSLayoutConstraint(item: rootViewController?.view as Any, attribute: .centerY, relatedBy: .equal, toItem: bannerAdView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        rootViewController?.view.addConstraints([centerXConstraint, centerYConstraint])
        self.banner = bannerAdView
    }
    
    func cleanupRootViewController() {
        banner.rootViewController?.view.removeConstraints([centerXConstraint, centerYConstraint])
        centerXConstraint = nil
        centerYConstraint = nil
        banner.removeFromSuperview()
    }
    
    // Test ANBannerViewAdAlignment, ANBannerViewAdTransitionType and ANBannerViewAdTransitionDirection with passed values in banner object
    func test_TC23_BannerAlignmentTransitionDurationAndDirection() {
        createBannerView()
        let bannerAdView = self.banner
        bannerAdView?.transitionType = ANBannerViewAdTransitionType.fade
        bannerAdView?.transitionDuration = 2.5
        bannerAdView?.transitionDirection = .right
        bannerAdView?.alignment = .center
        // Adding Content View
        bannerAdView?.contentView = catContentView()
        if let aView = bannerAdView {
            keyValueObservingExpectation(for: aView, keyPath: "transitionInProgress", expectedValue: false)
        }
        waitForExpectations(timeout: (bannerAdView?.transitionDuration)! + 0.1, handler: { error in
            XCTAssert(bannerAdView?.transitionDuration == 2.5)
            XCTAssert(bannerAdView?.transitionDirection == .right)
            XCTAssert(bannerAdView?.alignment == .center)
            bannerAdView?.removeFromSuperview()
        })
    }
    
    // Test public facing APIs of ANNativeAdResponse
    func test_TC24_ReceiveNativeStandardReponseObject() {
        
        stubRequestWithResponse("appnexus_standard_response")
        self.banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        self.banner.delegate = self
        self.banner.shouldAllowNativeDemand = true
        expectationRequest = expectation(description: "\(#function)")
        expectationResponse = expectation(description: "\(#function)")
        self.banner.loadAd()
        waitForExpectations(timeout: timeoutForImpbusRequest, handler: nil)
        XCTAssertTrue(foundStandardAdResponseObject)
        validateGenericNativeAdObject()
    }
    
    func validateGenericNativeAdObject()
    {
        if nativeAd?.title != nil {
            XCTAssert(nativeAd?.title == "AppNexusSDKApp")
        }
        if nativeAd?.body != nil {
            XCTAssert(nativeAd?.body == "Showcases the AppNexus mobile SDK and all its features. Works with placements generated under a publisher in the AppNexus Console.")
        }
        if nativeAd?.callToAction != nil {
            XCTAssert(nativeAd?.callToAction == "Call-to-Action")
        }
        if nativeAd?.rating != nil {
            XCTAssert(nativeAd?.rating != nil)
        }
        if nativeAd?.sponsoredBy != nil {
            XCTAssert(nativeAd?.sponsoredBy == "AppNexus Sponsored")
        }
        if nativeAd?.mainImageURL != nil {
            XCTAssert(nativeAd?.mainImageURL != nil)
        }
        if nativeAd?.iconImageURL != nil {
            XCTAssert(nativeAd?.iconImageURL != nil)
        }
        if nativeAd?.customElements != nil {
            XCTAssert(nativeAd?.customElements != nil)
        }
        if nativeAd?.creativeId != nil {
            XCTAssert(nativeAd?.creativeId != nil)
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
        XCTAssertNotNil(ad)
        if (ad is ANBannerAdView) {
            standardAd = ad as? ANMRAIDContainerView
            foundStandardAdResponseObject = true
            expectationResponse?.fulfill()
        }
    }
    
    func ad(_ loadInstance: Any, didReceiveNativeAd responseInstance: Any) {
        XCTAssertNotNil(loadInstance)
        XCTAssertNotNil(responseInstance)
        if (responseInstance is ANNativeStandardAdResponse) {
            nativeAd = responseInstance as? ANNativeAdResponse
            foundStandardAdResponseObject = true
            expectationResponse?.fulfill()
        }
        if (responseInstance is ANNativeMediatedAdResponse) {
            nativeAd = responseInstance as? ANNativeAdResponse
            foundStandardAdResponseObject = true
            expectationResponse?.fulfill()
        }
    }
    
    func ad(_ ad: Any, requestFailedWithError error: Error) {
        expectationResponse?.fulfill()
        XCTAssertTrue(false)
    }

    
}
