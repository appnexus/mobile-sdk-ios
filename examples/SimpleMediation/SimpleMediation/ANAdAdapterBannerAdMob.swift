//
//  CustomAdapter.swift
//  SimpleMediation
//
//  Created by System on 17/05/22.
//  Copyright © 2022 Xandr. All rights reserved.
//

import Foundation
import AppNexusSDK
import GoogleMobileAds

@objc(ANAdAdapterBannerAdMob)
public class ANAdAdapterBannerAdMob : NSObject , ANCustomAdapterBanner , GADBannerViewDelegate {
//    public var adDelegate: ANCustomAdapterBannerDelegate?

    
    public var delegate: AnyObject?
    var bannerView: GADBannerView!

    public func requestAd(with size: CGSize, rootViewController: UIViewController?, serverParameter parameterString: String?, adUnitId idString: String?, targetingParameters: ANTargetingParameters?) {
     
        bannerView = GADBannerView(adSize: GADAdSizeBanner)

        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = rootViewController
        bannerView.delegate = self

        bannerView.load(GADRequest())

    }
    

      
    
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("bannerViewDidReceiveAd")
        self.delegate?.didLoadBannerAd(bannerView)
    }

    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        self.delegate?.didFail(toLoadAd: ANAdResponseCode.unable_TO_FILL())

    }

    public func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
        self.delegate?.adDidLogImpression()

    }

    public func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
        self.delegate?.willCloseAd()

    }

    public func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
        self.delegate?.adDidLogImpression()

    }

    public func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
        self.delegate?.didCloseAd()

    }
    
}
