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
import CoreLocation
import AppNexusSDK

class ANSDKSettingsTestCase: XCTestCase, ANBannerAdViewDelegate {
    
    var banner: ANBannerAdView!
    var bannerSuperView: UIView!
    var loadAdSuccesfulException: XCTestExpectation!
    var placementID = "13653381"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ANSDKSettings.sharedInstance().httpsEnabled = true
        ANHTTPStubbingManager.shared().enable()
        ANHTTPStubbingManager.shared().ignoreUnstubbedRequests = true
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        ANHTTPStubbingManager.shared().disable()
        ANHTTPStubbingManager.shared().removeAllStubs()
        ANSDKSettings.sharedInstance().httpsEnabled = false
        ANSDKSettings.sharedInstance().locationEnabledForCreative = false
        self.banner.delegate = nil
        self.banner.appEventDelegate = nil
        self.banner.removeFromSuperview()
        self.banner = nil
        UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.dismiss(animated: false)
        self.loadAdSuccesfulException = nil
    }
    
    //Test Special ad sizes for which the content view should be constrained to the container view.
    //Note :- This testing process is still incomplete. Need to work on it.
    func test_TC53_SizesThatShouldConstrainToSuperview() {
        
        bannerSuperView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 430))
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(bannerSuperView)
        let rect = CGRect(x: 0, y: 0, width: bannerSuperView.frame.size.width, height: bannerSuperView.frame.size.height)
        let adWidth: Int = 10
        let adHeight: Int = 10
        let sizes = [NSValue(cgSize: CGSize(width: CGFloat(adWidth), height: CGFloat(adHeight)))]
        ANSDKSettings.sharedInstance().sizesThatShouldConstrainToSuperview = sizes
        let size = CGSize(width: CGFloat(adWidth), height: CGFloat(adHeight))
        setupBannerWithPlacement(placement: placementID, withFrame: rect, addSize: size)
        bannerSuperView.addSubview(banner)
        stubRequestWithResponse("SuccessfulAllowMagicSizeBannerObjectResponse")
        banner.loadAd()
        loadAdSuccesfulException = expectation(description: "Waiting for adDidReceiveAd to be received")
        waitForExpectations(timeout: 2 * kAppNexusRequestTimeoutInterval, handler: { error in
            
        })
        XCTAssertEqual(banner.frame.size.width, bannerSuperView.frame.size.width)
        XCTAssertEqual(banner.frame.size.height, bannerSuperView.frame.size.height)
        XCTAssertEqual(banner.loadedAdSize.width, 10)
        XCTAssertEqual(banner.loadedAdSize.height, 10)
        XCTAssertEqual(banner.adType, ANAdType.banner)
        XCTAssertEqual(banner.creativeId, "106954775")
        
    }
    
    //Test LocationEnabledForCreative false to block Location popup asked by Creative
    func test_TC54_BannerAdForLocationEnabledForCreativeFalse() {
        stubRequestWithResponse("SuccessfulLocationCreativeForBannerAdResponse")
        ANSDKSettings.sharedInstance().locationEnabledForCreative = false
        banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        banner.delegate = self
        banner.loadAd()
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(banner)
        loadAdSuccesfulException = expectation(description: "Waiting for adDidReceiveAd to be received")
        waitForExpectations(timeout: 5 * kAppNexusRequestTimeoutInterval, handler: { error in
            
        })
        waitForTimeInterval(8)
        XCTAssertFalse(isLocationPopupExist())
        XCTAssertEqual(banner.adSize.width, 300)
        XCTAssertEqual(banner.adSize.height, 250)
        XCTAssertEqual(banner.adType, ANAdType.banner)
        XCTAssertEqual(banner.creativeId, "106794309")
    }
    
    //Test LocationEnabledForCreative true to continue the default behaviour
    func test_TC55_BannerAdForLocationEnabledForCreativeTrue() {
        stubRequestWithResponse("SuccessfulLocationCreativeForBannerAdResponse")
        ANSDKSettings.sharedInstance().locationEnabledForCreative = true
        banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        banner.delegate = self
        banner.loadAd()
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(banner)
        loadAdSuccesfulException = expectation(description: "Waiting for adDidReceiveAd to be received")
        waitForExpectations(timeout: 10 * kAppNexusRequestTimeoutInterval, handler: { error in
            
        })
        waitForTimeInterval(8)
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            XCTAssertTrue(isLocationPopupExist())
        }
        else
        {
            XCTAssertFalse(isLocationPopupExist())
        }
        XCTAssertEqual(banner.loadedAdSize.width, 300)
        XCTAssertEqual(banner.loadedAdSize.height, 250)
        XCTAssertEqual(banner.adType, ANAdType.banner)
        XCTAssertEqual(banner.creativeId, "106794309")
    }
    
    //Test httpsEnabled true so SDK will make all requests in HTTPS
    func test_TC56_BannerAdForHTTPSEnabledTrue() {
        ANSDKSettings.sharedInstance().httpsEnabled = true
        banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        banner.delegate = self
        banner.loadAd()
        XCTAssertTrue(ANSDKSettings.sharedInstance().baseUrlConfig.utAdRequestBaseUrl().range(of:"https") != nil)
    }
    
    //Test httpsEnabled false so SDK will make all requests in HTTP
    func test_TC57_BannerAdForHTTPSEnabledFalse() {
        ANSDKSettings.sharedInstance().httpsEnabled = false
        banner = ANBannerAdView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250), placementId: placementID, adSize: CGSize(width: 300, height: 250))
        banner.delegate = self
        banner.loadAd()
        XCTAssertFalse(ANSDKSettings.sharedInstance().baseUrlConfig.utAdRequestBaseUrl().range(of:"https") != nil)
    }
    
    func setupBannerWithPlacement(placement: String, withFrame frame:CGRect, addSize size: CGSize )
    {
        self.banner = ANBannerAdView.init(frame: frame, placementId: placement, adSize: size)
        self.banner.accessibilityLabel = "AdView"
        self.banner.autoRefreshInterval = 0
        self.banner.delegate = self
    }
    
    func isLocationPopupExist() -> Bool {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if (rootViewController?.presentedViewController is UIAlertController) {
            rootViewController?.dismiss(animated: true)
            return true
        }
        return false
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
