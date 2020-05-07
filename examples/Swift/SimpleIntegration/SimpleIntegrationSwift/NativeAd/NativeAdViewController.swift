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

class NativeAdViewController: UIViewController , ANNativeAdRequestDelegate , ANNativeAdDelegate {
    
    
    
    
    var nativeAdRequest: ANNativeAdRequest?
    var nativeAdResponse: ANNativeAdResponse?
    var indicator = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Native Ad"
        
        // Do any additional setup after loading the view.
        
        nativeAdRequest = ANNativeAdRequest()
        nativeAdRequest!.placementId = "1281482"
        nativeAdRequest!.shouldLoadIconImage = true
        nativeAdRequest!.shouldLoadMainImage = true
        nativeAdRequest!.delegate = self
        nativeAdRequest!.loadAd()
    }
    
    
    func adRequest(_ request: ANNativeAdRequest, didReceive response: ANNativeAdResponse) {
        self.nativeAdResponse = response
        let adNib = UINib(nibName: "ANNativeAdView", bundle: Bundle.main)
        let array = adNib.instantiate(withOwner: self, options: nil)
        let nativeAdView = array.first as? ANNativeAdView
        nativeAdView?.titleLabel.text = nativeAdResponse?.title
        nativeAdView?.bodyLabel.text = nativeAdResponse?.body
        nativeAdView?.iconImageView.image = nativeAdResponse?.iconImage
        nativeAdView?.mainImageView.image = nativeAdResponse?.mainImage
        nativeAdView?.sponsoredLabel.text = nativeAdResponse?.sponsoredBy
        nativeAdView?.callToActionButton.setTitle(nativeAdResponse?.callToAction, for: .normal)
        nativeAdResponse?.delegate = self
        nativeAdResponse?.clickThroughAction = ANClickThroughAction.openSDKBrowser
        view.addSubview(nativeAdView!)
        do {
            try nativeAdResponse?.registerView(forTracking: nativeAdView!, withRootViewController: self, clickableViews: [nativeAdView?.callToActionButton! as Any, nativeAdView?.mainImageView! as Any])
        } catch {
            print("Failed to registerView for Tracking")
        }        
    }
    
    func adRequest(_ request: ANNativeAdRequest, didFailToLoadWithError error: Error, with adResponseInfo: ANAdResponseInfo?) {
        print("Ad request Failed With Error")
    }
}

