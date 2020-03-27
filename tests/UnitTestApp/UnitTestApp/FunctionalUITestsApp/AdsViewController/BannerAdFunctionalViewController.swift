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


import UIKit

class BannerAdFunctionalViewController: UIViewController , ANBannerAdViewDelegate {
    var banner : ANBannerAdView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Banner Native Rendering Ad"
        
        initStubbing()
        
        if ProcessInfo.processInfo.arguments.contains(FunctionalTestConstants.BannerNativeAd.testBannerNativeRenderingSize) || ProcessInfo.processInfo.arguments.contains(FunctionalTestConstants.BannerNativeAd.testBannerNativeRenderingClickThrough) {
            initialiseBannerNativeRendering()
            
        }        
        // Do any additional setup after loading the view.
    }
    func initStubbing() {
    ANHTTPStubbingManager.shared().enable()
    ANHTTPStubbingManager.shared().ignoreUnstubbedRequests = true
    ANHTTPStubbingManager.shared().broadcastRequests = true

    }
    
    func deinitStubbing() {
        ANHTTPStubbingManager.shared().disable()
        ANHTTPStubbingManager.shared().removeAllStubs()
        ANHTTPStubbingManager.shared().broadcastRequests = false
    }
    func initialiseBannerNativeRendering()  {
        
        let bannerAdObject : BannerAdObject! = AdObjectModel.decodeBannerObject()
        if bannerAdObject != nil {
            let width : CGFloat   = CGFloat(Int(bannerAdObject.width)!)
            let height : CGFloat  = CGFloat(Int(bannerAdObject.height)!)
            
            let size = CGSize(width: width , height: height)
            let centerX = self.view.frame.size.width/2
            let centerY = self.view.frame.size.height/2
            stubRequestWithResponse("appnexus_bannerNative_rendering")
            banner = ANBannerAdView(frame: CGRect(x: centerX - width/2, y: centerY - height/2, width: width, height: height), placementId: bannerAdObject.adObject.placement)
            banner.adSize = size
            
            guard let enableNativeRendering = bannerAdObject.enableNativeRendering else {  print("enableNativeRendering not found");   return  }
            banner.shouldResizeAdToFitContainer = false
            banner.enableNativeRendering = enableNativeRendering
            banner.shouldAllowNativeDemand = bannerAdObject.isNative
            banner.accessibilityIdentifier = bannerAdObject.adObject.accessibilityIdentifier
            banner.delegate=self
            banner.loadAd()
        }
        
    }
    
    func adDidReceiveAd(_ ad: Any) {
        if (ad is ANBannerAdView) {
            self.view.addSubview(banner)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        deinitStubbing()
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
