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
import AppTrackingTransparency
import AdSupport

class BannerAdViewController: UIViewController , ANBannerAdViewDelegate{
    var banner: ANBannerAdView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ANLogManager.setANLogLevel(ANLogLevel.all)
        requestPermission()


        self.title = "Banner Ad"

        let adWidth: Int = 300
        let adHeight: Int = 250
        let adID = "17058950"
        
        // We want to center our ad on the screen.
        let screenRect: CGRect = UIScreen.main.bounds
        let originX: CGFloat = (screenRect.size.width / 2) - CGFloat((adWidth / 2))
        let originY: CGFloat = (screenRect.size.height / 2) - CGFloat((adHeight / 2))
        // Needed for when we create our ad view.
        
        let rect = CGRect(origin: CGPoint(x: originX,y :originY), size: CGSize(width: adWidth, height: adHeight))
        
        let size = CGSize(width: adWidth, height: adHeight)
        
        // Make a banner ad view.
        let banner = ANBannerAdView(frame: rect, placementId: adID, adSize: size)
        banner.rootViewController = self
        banner.delegate = self
        view.addSubview(banner)
        // Load an ad.
        banner.loadAd()
        
    }
    
    func adDidReceiveAd(_ ad: Any) {
        print("Ad did receive ad")
    }
  
    func ad(_ ad: Any, requestFailedWithError error: Error) {
        print("Ad request Failed With Error")
    }
    
    
    func requestPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                    case .authorized:
                        print("enable tracking")
                    case .denied:
                        print("disable tracking")
                    default:
                        print("disable tracking")
                }
            }
        }

    }
    
}

