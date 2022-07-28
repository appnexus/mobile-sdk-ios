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

class SmartAdInterstitialAdViewController: UIViewController , ANInterstitialAdDelegate {
    
    var interstitialAd: ANInterstitialAd?
    let kPlacementId = "25047629"
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        interstitialAd = ANInterstitialAd(placementId: kPlacementId)
        interstitialAd!.delegate = self
        interstitialAd!.clickThroughAction = ANClickThroughAction.openSDKBrowser
        interstitialAd!.load()
        
        Toast.show(message: "Loading Ad...!! Please wait", controller: self)
    }
    
    // MARK: - ANInterstitialAdDelegate
    func adDidReceiveAd(_ ad: Any) {
        Toast.show(message: "adDidReceiveAd", controller: self)
        interstitialAd!.display(from: self)
    }
    
    func ad(_ ad: Any, requestFailedWithError error: Error) {
        Toast.show(message: "adFailed", controller: self)
    }
}
