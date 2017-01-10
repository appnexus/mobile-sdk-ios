//
//  OMWCustomInterstitialDelegate.h
//

#import <Foundation/Foundation.h>


@protocol OMWCustomInterstitialDelegate <NSObject>

/* Call this method when SDK connector has received ad from ad-network SDK. */
- (void)didRecieveInterstitialAd;

/* Call this method when SDK connector fails to receive an ad from ad-network SDK. This method must also be called whenever there is any error during the process of making an ad request to ad-network SDK. If ad-network provides an error object then send it as "error" parameter in this method or send nil. */
- (void)interstitialAdDidFailWithError:(NSError *)error;

/* Call this method when user interacts with the ad. This method is optional and should be called only when the ad-network provides a callback method for this event. */
- (void)interstitialAdWasClicked;

/* Call this method when interstitial ad has been displayed. This method is optional and should be called only when the ad-network provides a callback method for this event. */
- (void)interstitialAdDidPresent;

/* Call this method when user has closed interstitial ad. This method is optional and should be called only when the ad-network provides a callback method for this event. */
- (void)interstitialAdDidDismiss;

/* Call this method when user action has resulted in switching to another app on device. This method is optional and should be called only when the ad-network provides a callback method for this event. */
- (void)interstitialAdWillLeaveApplication;


@end
