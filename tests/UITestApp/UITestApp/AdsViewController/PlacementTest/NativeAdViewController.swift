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
import AppNexusSDK

class NativeAdViewController: UIViewController , ANNativeAdRequestDelegate, ANNativeAdDelegate {

    

    
    var nativeAdRequest = ANNativeAdRequest()
    var nativeAdResponse = ANNativeAdResponse()
    var adKey  : String = ""

    // MARK: IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewNative: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var callToActionButton: UIButton!
    @IBOutlet weak var sponsoredLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Native Ad"
        if ProcessInfo.processInfo.arguments.contains(PlacementTestConstants.NativeAd.testRTBNative) {
            adKey = PlacementTestConstants.NativeAd.testRTBNative
            initialiseNative()
        }
        // Do any additional setup after loading the view.
    }
    func initialiseNative()  {
        let nativeAdObject : NativeAdObject! = AdObjectModel.decodeNativeObject()
        if nativeAdObject != nil {
            
        viewNative.isHidden = true
        nativeAdRequest = ANNativeAdRequest()
        
        nativeAdRequest.placementId = nativeAdObject?.adObject.placement
            nativeAdRequest.shouldLoadIconImage = (nativeAdObject?.shouldLoadIconImage)!
            nativeAdRequest.shouldLoadMainImage = (nativeAdObject?.shouldLoadMainImage)!
        nativeAdRequest.delegate = self
        nativeAdRequest.loadAd()
        }
    }

    // MARK: ANNativeAdRequestDelegate
    func adRequest(_ request: ANNativeAdRequest, didReceive response: ANNativeAdResponse) {
        activityIndicator.stopAnimating()
        viewNative.alpha = 1
        viewNative.isHidden = false
        self.nativeAdResponse = response
        self.titleLabel.text = self.nativeAdResponse.title
        self.sponsoredLabel.text = self.nativeAdResponse.sponsoredBy
        self.bodyLabel.text = self.nativeAdResponse.body
        self.iconImageView.image = self.nativeAdResponse.iconImage
        self.mainImageView.image = self.nativeAdResponse.mainImage
        callToActionButton.setTitle(self.nativeAdResponse.callToAction, for: .normal)
        nativeAdResponse.delegate = self
        do {
            try nativeAdResponse.registerView(forTracking: self.viewNative, withRootViewController: self, clickableViews: [callToActionButton])
        } catch let error as NSError {
            print(error)
        }
    }
    
    func adRequest(_ request: ANNativeAdRequest, didFailToLoadWithError error: Error, with adResponseInfo: ANAdResponseInfo?) {
        print("requestFailedWithError \(String(describing: error))")
    }

}
