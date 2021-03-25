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
import FBAudienceNetwork
class FacebookNativeViewController: UIViewController , ANNativeAdRequestDelegate , ANNativeAdDelegate {
    
    @IBOutlet var adIconView: FBMediaView!
    @IBOutlet var adCoverMediaView: FBMediaView!
    @IBOutlet var adTitleLabel: UILabel!
    @IBOutlet var adBodyLabel: UILabel!
    @IBOutlet var adCallToActionButton: UIButton!
    @IBOutlet var adSocialContextLabel: UILabel!
    @IBOutlet var sponsoredLabel: UILabel!
    @IBOutlet var adOptionsView: FBAdOptionsView!
    @IBOutlet var adUIView: UIView!
    var nativeAd: FBNativeAd?
    
    
    var nativeAdRequest: ANNativeAdRequest?
    var nativeAdResponse: ANNativeAdResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ANSDKSettings.sharedInstance().httpsEnabled = true
        
        FBAdSettings.addTestDevice(FBAdSettings.testDeviceHash())
        
        nativeAdRequest = ANNativeAdRequest()
        nativeAdRequest!.placementId = "18596931"
        nativeAdRequest!.shouldLoadIconImage = true
        nativeAdRequest!.shouldLoadMainImage = true
        nativeAdRequest!.delegate = self
        nativeAdRequest!.loadAd()
    }
    
    
    func adRequest(_ request: ANNativeAdRequest, didReceive response: ANNativeAdResponse) {
       Toast.show(message: "adDidReceiveAd", controller: self)
        adUIView.isHidden = false
        self.nativeAdResponse = response
        let nativeAd = response.customElements![kANNativeElementObject] as? FBNativeAd
        facebookNativeAdDidLoad(nativeAd)
    }
    
    func facebookNativeAdDidLoad(_ nativeAd: FBNativeAd?) {
        
        Toast.show(message: "Native ad was loaded, constructing native UI...", controller: self)

        if (nativeAd != nil) {
            nativeAd!.unregisterView()
        }
                
        // Render native ads onto UIView
        adTitleLabel.text = nativeAd?.advertiserName
        adBodyLabel.text = nativeAd?.bodyText
        adSocialContextLabel.text = nativeAd?.socialContext
        sponsoredLabel.text = nativeAd?.sponsoredTranslation
        
        self.adCallToActionButton.titleLabel?.text = nativeAd?.callToAction
        // set the frame of the adBodyLabel depending on whether to show to call to action button
        let gapToBorder: CGFloat = 9.0
        let gapToCTAButton: CGFloat = 8.0
        var adBodyLabelFrame = adBodyLabel.frame
        if !(nativeAd!.callToAction != nil) {
            adBodyLabelFrame.size.width = adCoverMediaView.bounds.size.width - gapToBorder * 2
        } else {
            adBodyLabelFrame.size.width = adCoverMediaView.bounds.size.width - gapToCTAButton - gapToBorder - (adCoverMediaView.bounds.size.width - adCallToActionButton.frame.origin.x)
        }
        adBodyLabel.frame = adBodyLabelFrame
        print("Register UIView for impression and click...")
        // Specify the clickable areas. Views you were using to set ad view tags should be clickable.
        let clickableViews = [
            adIconView,
            adTitleLabel,
            adBodyLabel,
            adSocialContextLabel,
            adCallToActionButton,
            adCoverMediaView
        ]
        do {
            try nativeAdResponse!.registerView(forTracking: adUIView, withRootViewController: self, clickableViews: clickableViews as [Any])
        } catch let registerError {
            print(registerError)
        }
        
    }
    func adRequest(_ request: ANNativeAdRequest, didFailToLoadWithError error: Error, with adResponseInfo: ANAdResponseInfo?) {
        Toast.show(message: "ad requestFailedWithError \(error)", controller: self)
    }
    
}

