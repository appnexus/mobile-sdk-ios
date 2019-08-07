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

class BannerNativeAdViewController: UIViewController  , ANBannerAdViewDelegate {
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewNative: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var callToActionButton: UIButton!
    @IBOutlet weak var sponsoredLabel: UILabel!
    
    
    var adWidth: CGFloat = 300
    var adHeight: CGFloat = 50
    var banner = ANBannerAdView()
    var adKey  : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Banner Native Ad"
        viewNative.isHidden = true
        if ProcessInfo.processInfo.arguments.contains(PlacementTestConstants.BannerNativeAd.testRTBBannerNative) || ProcessInfo.processInfo.arguments.contains(PlacementTestConstants.BannerNativeAd.testRTBBannerNativeRendering) {
            adKey = PlacementTestConstants.BannerNativeAd.testRTBBannerNative
            loadBannerNativeAd()
        }
        
    }
    
    func loadBannerNativeAd() {
        
        let bannerAdObject : BannerAdObject! = AdObjectModel.decodeBannerObject()
        if bannerAdObject != nil {
          if let placement = bannerAdObject?.adObject.placement{
            var width : CGFloat   = 1
            var height : CGFloat  = 1
            
            if let widthValue = bannerAdObject?.width {
                let widthValueInt : Int = Int(widthValue)!
                width = CGFloat(widthValueInt)
            }
            
            if let heightValue = bannerAdObject?.height{
                let heightValueInt : Int = Int(heightValue)!
                height = CGFloat(heightValueInt)
            }
            
            
            
            let screenRect:CGRect = UIScreen.main.bounds
            let originX = (screenRect.size.width / 2) - (width / 2)
            let originY = (screenRect.size.height / 2) - (height / 2)
            
            // Needed for when we create our ad view.
            let rect = CGRect(x: originX, y: originY, width: width, height: height)
            let size = CGSize(width: 1, height: 1)
            
            // Make a banner ad view
            let banner = ANBannerAdView(frame: rect, placementId: placement , adSize: size)
            banner.rootViewController = self
            banner.autoRefreshInterval = 60
            banner.delegate = self
            if ProcessInfo.processInfo.arguments.contains(PlacementTestConstants.BannerNativeAd.testRTBBannerNativeRendering)  {
                guard let enableNativeRendering = bannerAdObject.enableNativeRendering else {  print("enableNativeRendering not found");   return  }
                banner.enableNativeRendering = enableNativeRendering
                banner.shouldAllowNativeDemand = bannerAdObject!.isNative
            }else{
                banner.shouldAllowNativeDemand = bannerAdObject!.isNative
                
            }
            banner.clickThroughAction = ANClickThroughAction.openDeviceBrowser
            // Since this example is for testing, we'll turn on PSAs and verbose logging.
            banner.shouldServePublicServiceAnnouncements = true
            ANLogManager.setANLogLevel(ANLogLevel.debug)
            
            // Load an ad.
            banner.loadAd()
            self.banner = banner
          }
        }
    }
    
    func adDidReceiveAd(_ ad: Any) {
        activityIndicator.stopAnimating()

        if (ad is ANBannerAdView) {
            self.view.addSubview(banner)
        }
        
    }
    
    func ad(_ loadInstance: Any, didReceiveNativeAd responseInstance: Any) {
        viewNative.isHidden = false
        activityIndicator.stopAnimating()
        viewNative.alpha = 1
        var nativeAdResponse = ANNativeAdResponse()
        nativeAdResponse = responseInstance as! ANNativeAdResponse
        self.titleLabel.text = nativeAdResponse.title
        self.bodyLabel.text = nativeAdResponse.body
        self.sponsoredLabel.text = nativeAdResponse.sponsoredBy
        if let iconImageURL = nativeAdResponse.iconImageURL{
         self.iconImageView.downloaded(from : iconImageURL )
        }
        if let mainImageURL = nativeAdResponse.mainImageURL{
         self.mainImageView.downloaded(from : mainImageURL )
        }
        callToActionButton.setTitle(nativeAdResponse.callToAction, for: .normal)
        do {
            try nativeAdResponse.registerView(forTracking: self.viewNative, withRootViewController: self, clickableViews: [callToActionButton])
        } catch let error as NSError {
            print(error)
        }
    }
    
    func ad(_ ad: Any, requestFailedWithError error: Error) {
        print("requestFailedWithError \(String(describing: error))")
    }
    
}
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
