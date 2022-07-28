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
import AppNexusNativeSDK
import FBAudienceNetwork
class FacebookCSRNativeBanner: UIViewController , ANNativeAdRequestDelegate , ANNativeAdDelegate {
    
    @IBOutlet var adCoverMediaView: FBMediaView!
    @IBOutlet var adTitleLabel: UILabel!
    @IBOutlet var adCallToActionButton: UIButton!
    @IBOutlet var sponsoredLabel: UILabel!
    @IBOutlet var adOptionsView: FBAdOptionsView!
    
    @IBOutlet weak var adUIView: UIStackView!
    
    var nativeAdRequest: ANNativeAdRequest?
    var nativeAdResponse: ANNativeAdResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
        
        nativeAdRequest = ANNativeAdRequest()
        nativeAdRequest!.placementId = "1906599"
        nativeAdRequest!.shouldLoadIconImage = true
        nativeAdRequest!.shouldLoadMainImage = true
        nativeAdRequest!.delegate = self
        nativeAdRequest!.loadAd()
    }
    
    
    func adRequest(_ request: ANNativeAdRequest, didReceive response: ANNativeAdResponse) {
        Toast.show(message: "adDidReceiveAd", controller: self)
        adUIView.isHidden = false
        self.nativeAdResponse = response
        
        
        Toast.show(message: "Native ad was loaded, constructing native UI...", controller: self)
        
        // Render native ads onto UIView
        adTitleLabel.text = self.nativeAdResponse?.title
        sponsoredLabel.text = self.nativeAdResponse?.sponsoredBy
        self.adCallToActionButton.setTitle(self.nativeAdResponse?.callToAction, for: .normal)
        if self.nativeAdResponse?.customElements![kANNativeCSRObject] != nil && self.nativeAdResponse?.customElements![kANNativeCSRObject] != nil {
            print("Register CSR Ad for tracking...")
            
            if let fbNativeBanner = self.nativeAdResponse?.customElements![kANNativeCSRObject] as? ANAdAdapterCSRNativeBannerFacebook {
                fbNativeBanner.registerView(  forTracking: adUIView,  withRootViewController: self,  iconView: self.adCoverMediaView, clickableViews: [self.adUIView!])
            }
            // CSR registerViewForTracking (see example below)
        }else{
            //  Non CSR registerViewForTracking
            //  See native ad examples here: https://wiki.xandr.com/display/sdk/Show+Native+Ads+on+iOS
            Toast.show(message: "Non CSR Native ad was loaded", controller: self)
            
        }
    }
    
    
    func adRequest(_ request: ANNativeAdRequest, didFailToLoadWithError error: Error, with adResponseInfo: ANAdResponseInfo?) {
        Toast.show(message: "ad requestFailedWithError \(error)", controller: self)
    }
    
}

