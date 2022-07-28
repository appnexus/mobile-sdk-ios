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

@objc(ANAdAdapterNativeAdMob)
public class ANAdAdapterNativeAdMob : NSObject , ANNativeCustomAdapter , GADNativeAdLoaderDelegate, GADNativeAdDelegate {    
    
    
    var nativeAdLoader: GADAdLoader!
    var proxyViewController : ANProxyViewController!
    var nativeAd: GADNativeAd?
    
    override init() {
        super.init()
//        hasExpired = true
        proxyViewController = ANProxyViewController()
    }
    
    public func requestNativeAd(
        withServerParameter parameterString: String?,
        adUnitId: String?,
        targetingParameters: ANTargetingParameters?
    ) {
        nativeAdLoader = GADAdLoader(  adUnitID: adUnitId!,
                                       rootViewController: proxyViewController as? UIViewController,  adTypes: [GADAdLoaderAdType.native],
                                       options: [])
        nativeAdLoader.delegate = self
        nativeAdLoader.load(GADRequest())
        
    }
    
    public var requestDelegate: ANNativeCustomAdapterRequestDelegate?
//    @nonobjc public var hasExpired: Bool?
    public var nativeAdDelegate: ANNativeCustomAdapterAdDelegate?
    public var expired: ObjCBool?

    public func hasExpired() -> DarwinBoolean{
        return false
    }
    public func registerView(forImpressionTrackingAndClickHandling view: UIView, withRootViewController rvc: UIViewController, clickableViews: [Any]?) {
        
        print("registerView by Ab")
    
//    public func registerView(forImpressionTrackingAndClickHandling view: UIView, withRootViewController rvc: UIViewController, clickableViews: [Any]?) {
        proxyViewController.rootViewController = rvc
        proxyViewController.adView = view
        if (nativeAd != nil) {
            if view is GADNativeAdView {
                let nativeContentAdView = view as? GADNativeAdView
                nativeContentAdView?.nativeAd = nativeAd
            }


            return;
        }
    }
    
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
//        self.hasExpired = false

        
        let response = ANNativeMediatedAdResponse(
            customAdapter: self,
            networkCode: ANNativeAdNetworkCode.adMob)
        nativeAd.delegate = self
        response?.title = nativeAd.headline
        response?.body = nativeAd.body
        response?.iconImageURL = nativeAd.icon?.imageURL
        response?.iconImageURL = nativeAd.icon?.imageURL
        response?.mainImageURL = (nativeAd.images?.first)?.imageURL
        response?.callToAction = nativeAd.callToAction
        response?.rating = ANNativeAdStarRating(
            value: CGFloat(nativeAd.starRating?.floatValue ?? 0.0),
            scale: Int(5.0))
        response?.customElements = [
            kANNativeElementObject: nativeAd
        ]
        requestDelegate?.didLoadNativeAd!(response!)
    }
    
    public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        requestDelegate?.didFail!(toLoadNativeAd: ANAdResponseCode.unable_TO_FILL())
        
    }
    
    
    
    public func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
      // The native ad was shown.
        self.nativeAdDelegate?.adDidLogImpression!()
    }

    public func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
      // The native ad was clicked on.
        self.nativeAdDelegate?.adWasClicked!()

    }

    public func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
      // The native ad will present a full screen view.
        self.nativeAdDelegate?.didPresentAd!()

    }

    public func nativeAdWillDismissScreen(_ nativeAd: GADNativeAd) {
      // The native ad will dismiss a full screen view.
        self.nativeAdDelegate?.willCloseAd!()

    }

    public func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
      // The native ad did dismiss a full screen view.
        self.nativeAdDelegate?.didCloseAd!()

    }

    public func nativeAdWillLeaveApplication(_ nativeAd: GADNativeAd) {
      // The native ad will cause the application to become inactive and
      // open a new application.
        self.nativeAdDelegate?.willLeaveApplication!()

    }
 
//    public func hasExpired() -> Bool {
//        return true
//    }
 
    
    
}
