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

class UITestViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "UI Test Type"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let placementTestStoryboard =  UIStoryboard(name: "PlacementTest", bundle: nil)
        
        if ProcessInfo.processInfo.arguments.contains("testRTBBanner320x50") || ProcessInfo.processInfo.arguments.contains("testRTBBanner300x250") {
            let bannerAdViewController = placementTestStoryboard.instantiateViewController(withIdentifier: "BannerAdViewController") as! BannerAdViewController
            self.navigationController?.pushViewController(bannerAdViewController, animated: true)
        }
        else if ProcessInfo.processInfo.arguments.contains("testRTBBannerNative") {
            let bannerNativeAdViewController = placementTestStoryboard.instantiateViewController(withIdentifier: "BannerNativeAdViewController") as! BannerNativeAdViewController
            self.navigationController?.pushViewController(bannerNativeAdViewController, animated: true)
        }
        else if ProcessInfo.processInfo.arguments.contains("testBannerVideo") || ProcessInfo.processInfo.arguments.contains("testVPAIDBannerVideo") {
            let bannerVideoAdViewController = placementTestStoryboard.instantiateViewController(withIdentifier: "BannerVideoAdViewController") as! BannerVideoAdViewController
            self.navigationController?.pushViewController(bannerVideoAdViewController, animated: true)
        }
        else if ProcessInfo.processInfo.arguments.contains("testRTBInterstitial") {
            let interstitialAdViewController = placementTestStoryboard.instantiateViewController(withIdentifier: "InterstitialAdViewController") as! InterstitialAdViewController
            self.navigationController?.pushViewController(interstitialAdViewController, animated: true)
        }
        else  if ProcessInfo.processInfo.arguments.contains("testRTBNative") {
            let nativeAdViewController = placementTestStoryboard.instantiateViewController(withIdentifier: "NativeAdViewController") as! NativeAdViewController
            self.navigationController?.pushViewController(nativeAdViewController, animated: true)
        }
        else if ProcessInfo.processInfo.arguments.contains("testRTBVideo") || ProcessInfo.processInfo.arguments.contains("testVPAIDVideoAd"){
            let videoAdViewController = placementTestStoryboard.instantiateViewController(withIdentifier: "VideoAdViewController") as! VideoAdViewController
            self.navigationController?.pushViewController(videoAdViewController, animated: true)
            
        }
        
        
    }
}
