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

@objc(ANAdAdapterInterstitialAdMob)
public class ANAdAdapterInterstitialAdMob : NSObject , ANCustomAdapterInterstitial , GADFullScreenContentDelegate {
    
    
    public var delegate: AnyObject?
    private var interstitial: GADInterstitialAd?
    
    
    public func requestAd(withParameter parameterString: String?, adUnitId idString: String?, targetingParameters: ANTargetingParameters?) {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-3940256099942544/4411468910",
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            
            interstitial = ad
            
            if interstitial != nil {
                self.delegate?.didLoadInterstitialAd(self)
                interstitial?.fullScreenContentDelegate = self;
                
            } else {
                self.delegate?.didFail(toLoadAd: ANAdResponseCode.unable_TO_FILL())
                print("Ad wasn't ready")
            }
        }
        )
    }
    
    public func present(from viewController: UIViewController?) {
        //        if (interstitial != nil) && try! interstitial?.canPresent(fromRootViewController: viewController!) != nil {
        interstitial!.present(fromRootViewController: viewController!)
        //        }
    }
    
    
    /// Tells the delegate that the ad failed to present full screen content.
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        self.delegate?.failedToDisplayAd()
    }
    
    /// Tells the delegate that the ad will present full screen content.
    public func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
        self.delegate?.willPresentAd()
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        self.delegate?.didCloseAd()
    }
    
    public func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.delegate?.willCloseAd()
    }
    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        self.delegate?.adWasClicked()
        
    }
    
    public func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        self.delegate?.adDidLogImpression()
        
    }
}
