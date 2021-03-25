/*   Copyright 2020 APPNEXUS INC
 
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
import AppNexusSDK
import GoogleMobileAds
class AdMobDFPNativeViewController: UIViewController , ANNativeAdRequestDelegate , ANNativeAdDelegate {
    
    var gadNativeAdView: GADUnifiedNativeAdView?
    var nativeAdRequest: ANNativeAdRequest?
    var nativeAdResponse: ANNativeAdResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        nativeAdRequest = ANNativeAdRequest()
        nativeAdRequest!.placementId = "18144598"
        nativeAdRequest!.shouldLoadIconImage = true
        nativeAdRequest!.shouldLoadMainImage = true
        nativeAdRequest!.delegate = self
        nativeAdRequest!.loadAd()
        Toast.show(message: "Loading Ad...!! Please wait", controller: self)

    }
    
    // MARK: - ANNativeAdRequestDelegate & ANNativeAdDelegate

    func adRequest(_ request: ANNativeAdRequest, didReceive response: ANNativeAdResponse) {
        self.nativeAdResponse = response
        self.nativeAdResponse?.delegate = self
        self.nativeAdResponse?.clickThroughAction = ANClickThroughAction.openSDKBrowser
        createGADNativeAdView()
        populateGADUnifiedNativeViewWithResponse()
        Toast.show(message:"Ad did receive ad", controller: self)
    }
    func createGADNativeAdView() {
        let adNib = UINib(nibName: "UnifiedNativeAdView", bundle: Bundle(for: type(of: self)))
        let array = adNib.instantiate(withOwner: self, options: nil)
        gadNativeAdView = (array.first as! GADUnifiedNativeAdView)
    }
    
    func populateGADUnifiedNativeViewWithResponse() {
        let nativeAdView = gadNativeAdView
        (nativeAdView?.headlineView as? UILabel)?.text = self.nativeAdResponse?.title
        
        (nativeAdView?.bodyView as? UILabel)?.text = self.nativeAdResponse?.body
        
        
        (nativeAdView?.callToActionView as? UIButton)?.setTitle(self.nativeAdResponse?.callToAction, for: .normal)
        
        (nativeAdView?.iconView as? UIImageView)?.image = self.nativeAdResponse?.iconImage
        
        // Main Image is automatically added by GoogleSDK in the MediaView
        
        (nativeAdView?.advertiserView as? UILabel)?.text = self.nativeAdResponse?.sponsoredBy
        
        
        self.view.addSubview(self.gadNativeAdView!)
        
        do {
            let rvc = (UIApplication.shared.keyWindow?.rootViewController)!
            
            try nativeAdResponse!.registerView(forTracking: self.gadNativeAdView!, withRootViewController: rvc, clickableViews: [(nativeAdView?.callToActionView) as Any])
        } catch {
            Toast.show(message: "Failed to registerView for Tracking", controller: self)
        }
    }
    
    func adRequest(_ request: ANNativeAdRequest, didFailToLoadWithError error: Error, with adResponseInfo: ANAdResponseInfo?) {
         Toast.show(message: "ad requestFailedWithError \(error)", controller: self)
     }
  
}


