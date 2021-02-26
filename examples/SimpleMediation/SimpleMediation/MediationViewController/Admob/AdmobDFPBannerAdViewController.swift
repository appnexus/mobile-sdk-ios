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

class AdmobDFPBannerAdViewController: UIViewController , ANBannerAdViewDelegate{
    var banner: ANBannerAdView?
    
    let kPlacementId = "18144580"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let adWidth: Int = 320
        let adHeight: Int = 50
        
        // We want to center our ad on the screen.
        let screenRect: CGRect = UIScreen.main.bounds
        let originX: CGFloat = (screenRect.size.width / 2) - CGFloat((adWidth / 2))
        let originY: CGFloat = (screenRect.size.height / 2) - CGFloat((adHeight / 2))
        // Needed for when we create our ad view.
        
        let rect = CGRect(origin: CGPoint(x: originX,y :originY), size: CGSize(width: adWidth, height: adHeight))
        
        let size = CGSize(width: adWidth, height: adHeight)
        
        // Make a banner ad view.
        let banner = ANBannerAdView(frame: rect, placementId: kPlacementId, adSize: size)
        banner.rootViewController = self
        banner.delegate = self
        banner.clickThroughAction = ANClickThroughAction.openSDKBrowser
        
        // Since this example is for testing, we'll turn on PSAs and verbose logging.
        banner.shouldServePublicServiceAnnouncements = false
        // Load an ad.
        banner.loadAd()
        view.addSubview(banner)
        
        Toast.show(message: "Loading Ad...!! Please wait", controller: self)
        
    }
    
    // MARK: - ANBannerAdViewDelegate
    func adDidReceiveAd(_ ad: Any) {
        Toast.show(message: "adDidReceiveAd", controller: self)
    }
    
    func ad(_ ad: Any, requestFailedWithError error: Error) {
        Toast.show(message: "adFailed", controller: self)
    }
}

