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

class BannerAdViewController: UIViewController , ANBannerAdViewDelegate {
    var banner : ANBannerAdView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Banner Ad"
        
        if ProcessInfo.processInfo.arguments.contains("testRTBBanner320x50") || ProcessInfo.processInfo.arguments.contains("testRTBBanner300x250") {
            initialiseRTBBanner()
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    func initialiseRTBBanner()  {
        
        let bannerAdObject : BannerAdObject! = AdObjectModel.decodeBannerObject()
        if bannerAdObject != nil {
            let width : CGFloat   = CGFloat(Int(bannerAdObject.width)!)
            let height : CGFloat  = CGFloat(Int(bannerAdObject.height)!)
            
            let size = CGSize(width: width , height: height)
            let centerX = self.view.frame.size.width/2
            let centerY = self.view.frame.size.height/2
            
            banner = ANBannerAdView(frame: CGRect(x: centerX - width/2, y: centerY - height/2, width: width, height: height), placementId: bannerAdObject.adObject.placement)
            banner.adSize = size
            banner.accessibilityIdentifier = bannerAdObject.adObject.accessibilityIdentifier
            banner.delegate=self
            banner.loadAd()
        }
        
    }
    
    func adDidReceiveAd(_ ad: Any!) {
        if (ad is ANBannerAdView) {
            self.view.addSubview(banner)
        }
    }
}
