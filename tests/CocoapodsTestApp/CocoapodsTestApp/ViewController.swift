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

class ViewController: UIViewController  , ANBannerAdViewDelegate {
    var banner : ANBannerAdView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Banner Ad"
        initialiseRTBBanner()
        // Do any additional setup after loading the view.
    }
    
    func initialiseRTBBanner()  {
        
        let width : CGFloat   = CGFloat(300)
        let height : CGFloat  = CGFloat(250)
        
        let size = CGSize(width: width , height: height)
        let centerX = self.view.frame.size.width/2
        let centerY = self.view.frame.size.height/2
        
        banner = ANBannerAdView(frame: CGRect(x: centerX - width/2, y: centerY - height/2, width: width, height: height), placementId: "19213468")
        banner.adSize = size
        banner.forceCreativeId = 270957916
        banner.delegate=self
        banner.loadAd()
    }
    
    func adDidReceiveAd(_ ad: Any) {
        if (ad is ANBannerAdView) {
            self.view.addSubview(banner)
            self.navigationController?.title = "Ad Loaded"
            
        }
    }
    
    func ad(_ ad: Any, requestFailedWithError error: Error) {
        print("error===> \(error)")
        self.navigationController?.title = "Ad Failed"
    }
}


