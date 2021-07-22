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
class UITestViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "UI Test Type"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        ANHTTPStubbingManager.shared().disable()
        ANHTTPStubbingManager.shared().removeAllStubs()
        ANStubManager.sharedInstance().enableStubbing()
        ANStubManager.sharedInstance().disableStubbing()
        
            let placementTestStoryboard =  UIStoryboard(name: PlacementTestConstants.PlacementTest, bundle: nil)
            if ProcessInfo.processInfo.arguments.contains(PlacementTestConstants.BannerAd.testRTBBanner320x50) || ProcessInfo.processInfo.arguments.contains(PlacementTestConstants.BannerAd.testRTBBanner300x250) {
                let bannerAdViewController = placementTestStoryboard.instantiateViewController(withIdentifier: "BannerAdViewController") as! BannerAdViewController
                self.navigationController?.pushViewController(bannerAdViewController, animated: true)
            }
            else if ProcessInfo.processInfo.arguments.contains(PlacementTestConstants.BannerNativeAd.testRTBBannerNative) || ProcessInfo.processInfo.arguments.contains(PlacementTestConstants.BannerNativeAd.testRTBBannerNativeRendering){
                let bannerNativeAdViewController = placementTestStoryboard.instantiateViewController(withIdentifier: "BannerNativeAdViewController") as! BannerNativeAdViewController
                self.navigationController?.pushViewController(bannerNativeAdViewController, animated: true)
            }
            else if ProcessInfo.processInfo.arguments.contains(PlacementTestConstants.BannerVideoAd.testBannerVideo) || ProcessInfo.processInfo.arguments.contains(PlacementTestConstants.BannerVideoAd.testVPAIDBannerVideo) {
                let bannerVideoAdViewController = placementTestStoryboard.instantiateViewController(withIdentifier: "BannerVideoAdViewController") as! BannerVideoAdViewController
                self.navigationController?.pushViewController(bannerVideoAdViewController, animated: true)
            }
            else if ProcessInfo.processInfo.arguments.contains(PlacementTestConstants.InterstitialAd.testRTBInterstitial) {
                let interstitialAdViewController = placementTestStoryboard.instantiateViewController(withIdentifier: "InterstitialAdViewController") as! InterstitialAdViewController
                self.navigationController?.pushViewController(interstitialAdViewController, animated: true)
            }
            else  if ProcessInfo.processInfo.arguments.contains(PlacementTestConstants.NativeAd.testRTBNative) {
                let nativeAdViewController = placementTestStoryboard.instantiateViewController(withIdentifier: "NativeAdViewController") as! NativeAdViewController
                self.navigationController?.pushViewController(nativeAdViewController, animated: true)
            }
            else if ProcessInfo.processInfo.arguments.contains(PlacementTestConstants.VideoAd.testRTBVideo) || ProcessInfo.processInfo.arguments.contains(PlacementTestConstants.VideoAd.testVPAIDVideoAd){
                let videoAdViewController = placementTestStoryboard.instantiateViewController(withIdentifier: "VideoAdViewController") as! VideoAdViewController
                self.navigationController?.pushViewController(videoAdViewController, animated: true)
                
            }
            
        if ProcessInfo.processInfo.arguments.contains(BannerImpressionClickTrackerTest) || ProcessInfo.processInfo.arguments.contains(BannerNativeImpressionClickTrackerTest) || ProcessInfo.processInfo.arguments.contains(BannerNativeRendererImpressionClickTrackerTest) || ProcessInfo.processInfo.arguments.contains(BannerVideoImpressionClickTrackerTest) {
            self.openViewController("BannerNativeVideoTrackerTestVC")
        }
        if ProcessInfo.processInfo.arguments.contains(InterstitialImpressionClickTrackerTest) {
            self.openViewController("InterstitialAdTrackerTestVC")
        } else if ProcessInfo.processInfo.arguments.contains(VideoImpressionClickTrackerTest) {
            self.openViewController("VideoAdTrackerTestVC")
        } else if ProcessInfo.processInfo.arguments.contains(NativeImpressionClickTrackerTest) {
            self.openViewController("NativeAdTrackerTestVC")
        }else if ProcessInfo.processInfo.arguments.contains(MARBannerImpressionClickTrackerTest) || ProcessInfo.processInfo.arguments.contains(MARNativeImpressionClickTrackerTest) || ProcessInfo.processInfo.arguments.contains(MARBannerNativeRendererImpressionClickTrackerTest) {
            self.openViewController("MARBannerNativeRendererAdTrackerTestVC")
        }
        else if ProcessInfo.processInfo.arguments.contains(BannerImpression1PxTrackerTest) || ProcessInfo.processInfo.arguments.contains(NativeImpression1PxTrackerTest) {
            self.openViewController("ScrollViewController")
        }
        
    }
    func openViewController(_ viewController: String) {
        let sb = UIStoryboard(name: viewController, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: viewController)
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)

    }
    
}

