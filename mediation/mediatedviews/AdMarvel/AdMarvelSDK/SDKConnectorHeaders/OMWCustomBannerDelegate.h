//
//  OMWCustomBannerDelegate.h
//

#import <Foundation/Foundation.h>

@protocol OMWCustomBanner;

@protocol OMWCustomBannerDelegate <NSObject>

/* Use this view controller object for persenting any full screen modal view. */
@property(nonatomic, readonly) UIViewController *viewControllerForPresentingModalView;

/* Call this method when SDK connector has received ad from ad-network SDK. Here adView is the ad object of ad-network and this must not be nil.*/
- (void)didRecieveBannerAd:(UIView *)view;

/* Call this method when SDK connector fails to receive an ad from ad-network SDK. This method must also be called whenever there is any error during the process of making an ad request to ad-network SDK. If ad-network provides an error object then send it as "error" parameter in the method or send nil.*/
- (void)bannerAdDidFailWithError:(NSError *)error;

/* Call this method when user interacts with the ad. This is optional and should be called only when the ad-network provides a callback methods for this event. */
- (void)bannerAdWasClicked;

/* Call this method when user interaction has resulted in opening a fullscreen modal view. This method is optional and should only be called when the ad-network provides a callback method for this event. */
- (void)bannerAdDidPresentModal;

/* Call this method when user has closed the fullscreen modal view. This method is optional and should only be called only when the ad-network provides a callback method for this event. */
- (void)bannerAdDidDismissModal;

/* Call this method when user action has resulted in switching to another app on device. This method is optional and should only be called only when the ad-network provides a callback method for this event. */
- (void)bannerAdWillLeaveApplication;



@end
