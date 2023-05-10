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

class BannerAdViewController: UIViewController , ANBannerAdViewDelegate{
    // MARK: IBOutlets
    @IBOutlet weak var adViewContainer: UIView!
    var banner: ANBannerAdView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ANLogManager.setANLogLevel(ANLogLevel.all)
        

        self.title = "Banner Ad"
        let adID = "17058950"
        
        
        // Make a banner ad view.
        banner = ANBannerAdView(frame: adViewContainer.bounds, placementId: adID)
        banner!.adSizes = [NSValue.init(cgSize: CGSize(width: 320, height: 250)),
                               NSValue.init(cgSize: CGSize(width: 400, height: 300))]
        banner!.forceCreativeId = 182434863 // for landscape video ad testing
        banner!.forceCreativeId = 414238306 // for potrait video ad testing
        banner!.rootViewController = self
        banner!.delegate = self
        
        //New API Option - 1 - start
        //banner!.shouldResizeVideoAdToFitContainer = true
        //New API Option - 1 - end
        
        //New API Option - 2 - start
        //banner!.shouldExpandVideoToFitScreenWidth = true
        //New API Option - 2 - end
        
        //New API Option - 3 - start
        ANVideoPlayerSettings.sharedInstance().landscapeBannerVideoPlayerSize = CGSize(width: 300, height: 250)
        ANVideoPlayerSettings.sharedInstance().portraitBannerVideoPlayerSize = CGSize(width: 300, height: 400)
        ANVideoPlayerSettings.sharedInstance().squareBannerVideoPlayerSize = CGSize(width: 200, height: 200)
        //New API Option - 3 - end
        
        
        adViewContainer.addSubview(banner!)
        banner!.loadAd()
        
    }
    
    func adDidReceiveAd(_ ad: Any) {
        print("Ad did receive ad")
        if(banner?.adResponseInfo?.adType == ANAdType.video){
            print("OutStream Ad Loaded")
            print("Banner:: Width= \(String(describing: banner?.loadedAdSize.width))")
            print("Banner:: Height= \(String(describing: banner?.loadedAdSize.height))")
            
            
            let videoOrientation = banner?.getVideoOrientation()
            switch (videoOrientation){
            case .portrait:
                print("Banner:: Video Orientation Portrait")
            case .landscape:
                print("Banner:: Video Orientation Landscape")
            case .square:
                print("Banner:: Video Orientation Square")
            case .unknown:
                print("Banner:: Video Orientation Unknown")
            default:
                    break
            }
            
            
            // New API Option  - 4 - start
            // Actual Width and Height of the video creative is exposed to publisher
            print("Banner:: Video Creative Width= \(String(describing: banner?.getVideoWidth()))")
            print("Banner:: Video Creative Height= \(String(describing: banner?.getVideoHeight()))")
            // New API Option  - 4 - end
        }
    
    }
  
    func ad(_ ad: Any, requestFailedWithError error: Error) {
        print("Ad request Failed With Error")
    }
}

