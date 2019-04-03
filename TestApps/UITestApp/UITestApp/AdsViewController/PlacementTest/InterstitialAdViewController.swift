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

class InterstitialAdViewController: UIViewController , ANInterstitialAdDelegate {
    var interstistial = ANInterstitialAd()
    var adKey  : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Interstitial Ad"
        if ProcessInfo.processInfo.arguments.contains("testRTBInterstitial") {
            adKey = "testRTBInterstitial"
            initialiseInterstitial()
        }
        // Do any additional setup after loading the view.
    }
    func initialiseInterstitial()  {
        
       
        let interstitialAdObject : InterstitialAdObject! = AdObjectModel.decodeInterstitialObject()
      
        if interstitialAdObject != nil {
            
            let interstistial = ANInterstitialAd(placementId: interstitialAdObject?.adObject.placement)
            interstistial?.delegate = self as ANInterstitialAdDelegate
            interstistial?.closeDelay = TimeInterval((interstitialAdObject?.closeDelay)!)
            // Since this example is for testing, we'll turn on PSAs and verbose logging.
            interstistial?.shouldServePublicServiceAnnouncements = true
            
            // Load an ad.
            interstistial?.load()
            self.interstistial = interstistial!
        }
    }
    func adDidReceiveAd(_ ad: Any!) {
        interstistial.display(from: self)
    }
    
    func ad(_ ad: Any!, requestFailedWithError error: Error!) {
        print("requestFailedWithError \(String(describing: error))")
    }
}
