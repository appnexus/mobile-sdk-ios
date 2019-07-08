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

class ANNativeAdRequestTestCase: XCTestCase, ANNativeAdRequestDelegate {
    
    var adRequest: ANNativeAdRequest!
    var requestExpectation: XCTestExpectation?
    var delegateCallbackExpectation: XCTestExpectation?
    var successfulAdCall = false
    var adResponse: ANNativeAdResponse!
    var adRequestError: Error!
    var request: URLRequest!
    var jsonRequestBody = [String : Any]()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        adRequest = ANNativeAdRequest()
        adRequest?.delegate = self
        ANHTTPStubbingManager.shared().enable()
        ANHTTPStubbingManager.shared().ignoreUnstubbedRequests = true
        ANHTTPStubbingManager.shared().broadcastRequests = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.requestCompleted(_:)), name: NSNotification.Name.anhttpStubURLProtocolRequestDidLoad, object: nil)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        adRequest = nil
        delegateCallbackExpectation = nil
        successfulAdCall = false
        adResponse = nil
        adRequestError = nil
        
        ANHTTPStubbingManager.shared().broadcastRequests = false
        ANHTTPStubbingManager.shared().removeAllStubs()
        ANHTTPStubbingManager.shared().disable()
        NotificationCenter.default.removeObserver(self)
    }

    func requestCompleted(_ notification: Notification?) {
        if (requestExpectation != nil) {
            request = notification?.userInfo![kANHTTPStubURLProtocolRequest] as? URLRequest
            requestExpectation?.fulfill()
            requestExpectation = nil
        }
        var incomingRequest = notification?.userInfo![kANHTTPStubURLProtocolRequest] as? URLRequest
        let requestString = incomingRequest?.url?.absoluteString
        let searchString = ANSDKSettings.sharedInstance().baseUrlConfig.utAdRequestBaseUrl()
        if request == nil && requestString?.range(of:searchString!) != nil{
            request = notification!.userInfo![kANHTTPStubURLProtocolRequest] as? URLRequest
            jsonRequestBody = ANHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: request) as! [String : Any]
        }
    }
    
    //Test load of main image  with NativeAdRequest
    func test_TC41_NativeAdRequestWithMainImageLoad() {
        adRequest.shouldLoadMainImage = true
        stubRequestWithResponse("appnexus_standard_response")
        adRequest.loadAd()
        delegateCallbackExpectation = expectation(description: NSStringFromSelector(#function))
        waitForExpectations(timeout: 2 * kAppNexusRequestTimeoutInterval, handler: { error in
            
        })
        validateGenericNativeAdObject()
        
        XCTAssertEqual(adResponse.networkCode, ANNativeAdNetworkCode.appNexus)
        XCTAssertNil(adResponse.iconImage)
        XCTAssertNotNil(adResponse.mainImage)
    }

    //Test load of icon image  with NativeAdRequest
    func test_TC42_NativeAdRequestWithIconImageLoad() {
        adRequest.shouldLoadIconImage = true
        stubRequestWithResponse("appnexus_standard_response")
        adRequest.loadAd()
        delegateCallbackExpectation = expectation(description: NSStringFromSelector(#function))
        waitForExpectations(timeout: 2 * kAppNexusRequestTimeoutInterval, handler: { error in
            
        })
        validateGenericNativeAdObject()
        
        XCTAssertEqual(adResponse.networkCode, ANNativeAdNetworkCode.appNexus)
        XCTAssertNotNil(adResponse.iconImage)
        XCTAssertNil(adResponse.mainImage)
    }
    
    // MARK: - Helper methods.
    func validateGenericNativeAdObject()
    {
        if adResponse.title != nil {
          XCTAssert(adResponse.title != nil)
        }
        if adResponse.body != nil {
            XCTAssert(adResponse.body != nil)
        }
        if adResponse.callToAction != nil {
            XCTAssert(adResponse.callToAction != nil)
        }
        if adResponse.rating != nil {
            XCTAssert(adResponse.rating != nil)
        }
        if adResponse.mainImageURL != nil {
            XCTAssert(adResponse.mainImageURL != nil)
        }
        if adResponse.iconImageURL != nil {
            XCTAssert(adResponse.iconImageURL != nil)
        }
        if adResponse.customElements != nil {
            XCTAssert(adResponse.customElements != nil)
        }
        if adResponse.creativeId != nil {
            XCTAssert(adResponse.creativeId != nil)
        }
    }
    
    // MARK: - ANNativeAdRequestDelegate
    func adRequest(_ request: ANNativeAdRequest, didReceive response: ANNativeAdResponse) {
        adResponse = response
        successfulAdCall = true
        delegateCallbackExpectation?.fulfill()
    }
    
    func adRequest(_ request: ANNativeAdRequest, didFailToLoadWithError error: Error) {
        adRequestError = error
        successfulAdCall = false
        delegateCallbackExpectation?.fulfill()
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
}
