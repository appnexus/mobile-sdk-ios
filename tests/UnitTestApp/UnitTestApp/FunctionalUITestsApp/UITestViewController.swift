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

        if ProcessInfo.processInfo.arguments.contains(FunctionalTestConstants.functionalTest)  {
            let placementTestStoryboard =  UIStoryboard(name: FunctionalTestConstants.functionalTest, bundle: nil)
            if ProcessInfo.processInfo.arguments.contains(FunctionalTestConstants.BannerNativeAd.testBannerNativeRenderingClickThrough) || ProcessInfo.processInfo.arguments.contains(FunctionalTestConstants.BannerNativeAd.testBannerNativeRenderingSize)  {
                let bannerAdViewController = placementTestStoryboard.instantiateViewController(withIdentifier: "BannerAdFunctionalViewController") as! BannerAdFunctionalViewController
                if #available(iOS 13.0, *) {
                    bannerAdViewController.modalPresentationStyle = .fullScreen;
                }
                self.present(bannerAdViewController, animated: true, completion: nil)
            }
        }
    }
    
}
