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


import Foundation
import AppNexusSDK
import UIKit

class MultiAdViewController: UITableViewController , ANMultiAdRequestDelegate  , ANBannerAdViewDelegate ,  ANInstreamVideoAdPlayDelegate , ANInterstitialAdDelegate , ANNativeAdRequestDelegate , ANNativeAdDelegate  , ANInstreamVideoAdLoadDelegate {
    
    
    
    
    var bannerAd: ANBannerAdView?
    var interstitialAd: ANInterstitialAd?
    var videoAd = ANInstreamVideoAd()
    var nativeAdRequest: ANNativeAdRequest?
    var nativeAdResponse: ANNativeAdResponse?
    
    var marAdRequest: ANMultiAdRequest?
    
    
    @IBOutlet weak var bannerAdView: UIView!
    @IBOutlet weak var videoAdView: UIView!
    @IBOutlet weak var nativeAdView: UIView!
    
    @IBOutlet weak var nativeIconImageView: UIImageView!
    @IBOutlet weak var nativeMainImageView: UIImageView!
    @IBOutlet weak var nativeTitleLabel: UILabel!
    @IBOutlet weak var nativeBodyLabel: UILabel!
    @IBOutlet weak var nativesponsoredLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Multi Ad Request"
        // Init ANMultiAdRequest
        marAdRequest = ANMultiAdRequest(memberId: 10094, andDelegate: self as ANMultiAdRequestDelegate)
        
        // Add Ad Units
        marAdRequest?.addAdUnit(createBannerAd(adView: bannerAdView))
        marAdRequest?.addAdUnit(createVideoAd(adView: videoAdView))
        marAdRequest?.addAdUnit(createInterstitialAd())
        marAdRequest?.addAdUnit(createNativeAd())
        
        // Load Ad Units
        marAdRequest?.load()
        
    }
    
    
    // Create InstreamVideo Ad Object
    func createVideoAd(adView : UIView) -> ANInstreamVideoAd {
        videoAd = ANInstreamVideoAd(placementId: "17058950")
        videoAd.loadDelegate = self
        return videoAd
    }
    
    
    // Create Interstitial Ad Object
    func createInterstitialAd()  -> ANInterstitialAd{
        interstitialAd = ANInterstitialAd(placementId: "17058950")
        interstitialAd!.delegate = self
        return interstitialAd!
    }
    
    // Create Native Ad Object
    func createNativeAd() -> ANNativeAdRequest{
        nativeAdRequest = ANNativeAdRequest()
        nativeAdRequest!.placementId = "17058950"
        nativeAdRequest!.shouldLoadIconImage = true
        nativeAdRequest!.shouldLoadMainImage = true
        nativeAdRequest!.delegate = self
        return nativeAdRequest!
    }
    // Create Banner Ad Object
    func createBannerAd(adView : UIView) -> ANBannerAdView {
        // Needed for when we create our ad view.
        let size = CGSize(width: 320, height: 50)
        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.bannerAdView.frame.size.width , height: self.bannerAdView.frame.size.height))
        
        // Make a banner ad view.
        self.bannerAd = ANBannerAdView(frame: rect, placementId: "17058950", adSize: size)
        self.bannerAd!.rootViewController = self
        self.bannerAd!.delegate = self
        self.bannerAd!.shouldResizeAdToFitContainer = true
        bannerAdView.addSubview(self.bannerAd!)
        return self.bannerAd!
    }
    
    // MARK: - ANMultiAdRequest Delegate
    func multiAdRequestDidComplete(_ mar: ANMultiAdRequest) {
        print("Multi Ad Request Did Complete")

    }
    func multiAdRequest(_ mar: ANMultiAdRequest, didFailWithError error: Error) {
        print("MultiAdRequest failed with error : \(error)")
    }
    
    // MARK: - Ad Delegate
    func adDidReceiveAd(_ ad: Any) {
        if(ad is ANInstreamVideoAd){
            print("Video Ad did Receive");
            videoAd.play(withContainer: videoAdView, with: self)
        }else if(ad is ANInterstitialAd && interstitialAd!.isReady){
            print("Interstitial Ad did Receive");
            interstitialAd!.display(from: self)
        }else if(ad is ANBannerAdView) {
            print("Banner Ad did Receive");
        }
    }
    
    func ad(_ ad: Any, requestFailedWithError error: Error) {
        print("requestFailedWithError \(error)")
    }
    
    // Native Ad delegate
    func adRequest(_ request: ANNativeAdRequest, didReceive response: ANNativeAdResponse) {
        print("Native Ad did Receive");
        self.nativeAdResponse = response
        self.nativeIconImageView.image = nativeAdResponse?.iconImage
        self.nativeMainImageView.image = nativeAdResponse?.mainImage
        self.nativeTitleLabel.text = nativeAdResponse?.title
        self.nativeBodyLabel.text = nativeAdResponse?.body
        self.nativesponsoredLabel.text = nativeAdResponse?.sponsoredBy
        do {
            try nativeAdResponse?.registerView(forTracking: nativeAdView!, withRootViewController: self, clickableViews: [ nativeAdView! as Any])
        } catch {
            print("Failed to registerView for Tracking")
        }
    }

    
    func adRequest(_ request: ANNativeAdRequest, didFailToLoadWithError error: Error, with adResponseInfo: ANAdResponseInfo?) {
        print("requestFailedWithError \(error)")
    }
    
    func adDidComplete(_ ad: ANAdProtocol, with state: ANInstreamVideoPlaybackStateType) {
        print("Video Ad did Complete")
    }
    
}

