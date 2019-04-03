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

class BannerVideoAdViewController: UIViewController  , ANBannerAdViewDelegate {
    var banner : ANBannerAdView!
    var adKey  : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Banner Video Ad"
        BannerVideoAd()
        // Do any additional setup after loading the view.
    }
    
    func BannerVideoAd(){
        if ProcessInfo.processInfo.arguments.contains("testBannerVideo") {
            adKey = "testBannerVideo"
            RTBBannerVideo()
        }
        if ProcessInfo.processInfo.arguments.contains("testVPAIDBannerVideo") {
            adKey = "testVPAIDBannerVideo"
            RTBBannerVideo()
        }
    }
    
    func RTBBannerVideo(){
        
        let bannerAdObject : BannerAdObject! = AdObjectModel.decodeBannerObject()
        if bannerAdObject != nil {
            
            var width : CGFloat   = 1
            var height : CGFloat  = 1
            
            if let widthValue = bannerAdObject?.width {
                let widthValueInt : Int = Int(widthValue)!
                width = CGFloat(widthValueInt)
            }
            
            if let heightValue = bannerAdObject?.height {
                let heightValueInt : Int = Int(heightValue)!
                height = CGFloat(heightValueInt)
            }
            
            
            let centerX = self.view.frame.size.width/2
            let centerY = self.view.frame.size.height/2
            let size = CGSize(width: 1, height: 1)
            banner = ANBannerAdView(frame: CGRect(x: centerX-width/2, y: centerY-height/2, width: width, height: height), placementId: bannerAdObject?.adObject.placement)
            banner.adSize = size
            banner.delegate=self
            banner.accessibilityIdentifier = bannerAdObject?.adObject.accessibilityIdentifier
            banner.shouldAllowVideoDemand = bannerAdObject!.isVideo
            banner.landingPageLoadsInBackground = false;
            banner.clickThroughAction = ANClickThroughAction.openSDKBrowser;
            banner.loadAd()
        }
        
    }
    
    func adDidReceiveAd(_ ad: Any!) {
        if (ad is ANBannerAdView) {
            self.view.addSubview(banner)
        }
    }
    
    func ad(_ ad: Any!, requestFailedWithError error: Error!) {
        print("requestFailedWithError \(String(describing: error))")
        BannerVideoAd()
    }
    
}
