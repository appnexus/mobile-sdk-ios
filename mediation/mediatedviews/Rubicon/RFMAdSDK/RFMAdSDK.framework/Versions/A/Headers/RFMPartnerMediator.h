//
//  RFMPartnerMediator.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 10/21/15.
//  Copyright © 2015 Rubicon Project. All rights reserved.
//

#import <RFMAdSDK/RFMAdSDK.h>
#import "RFMBaseMediator.h"

/**
 * All partner mediator subclasses must conform to RFMPartnerMediatorProtocol
 *
 * Two methods, requestAdWithSize: cancelRequest, and  must be subclassed
 * in order for the SDK to properly pass control to a partner mediator
 * and maintain proper user experience.
 */

@protocol RFMPartnerMediatorProtocol <NSObject>

@required
/**
 * **Required** This method requests an ad
 *
 * @param size Expected width and height in cgsize of the ad.
 * @param adInfo Dictionary containing the ad properties, such as ad unit and mediation details
 * @see cancelRequest
 */
- (void)requestAdWithSize:(CGSize)size
                   adInfo:(NSDictionary*)adInfo;
/**
 * **Required** This method cancels an existing ad request.
 *
 * @see requestAdWithSize:adInfo:
 * @note No more ad events should be invoked after this method has been called.
 */

- (void)cancelRequest;

@end

/**
 * RFMPartnerMediatorDelegate is a base protocol, do not directly conform to this protocol
 *
 * These delegate methods allow the mediator to communicate back to the SDK to inform
 * the publisher when certain events have occurred or pass back required objects
 * needed by the mediator to properly display an ad.
 */

@protocol RFMPartnerMediatorDelegate <NSObject>

@required
/**
 * **Required** This method returns the presenting modal view controller.
 *
 * @return viewControllerForPresentingModalView The presenting modal view controller.
 */
- (UIViewController *)viewControllerForPresentingModalView;

/**
 * **Required** Delegate callback to inform the SDK that the mediation has failed to load.
 *
 * @param errorReason Error description in string form.
 * @see didFinishLoadingAd:
 */
- (void)didFailToLoadAdWithReason:(NSString *)errorReason;
/**
 * **Required** Delegate callback to inform the SDK that the mediation has finished loading.
 *
 * @param adView The instance of RFMAdView for which this callback has been triggered.
 * @see didFailToLoadAdWithReason:
 */
- (void)didFinishLoadingAd:(UIView *)adView;

@end

/**
 * Banner mediator subclasses must conform to RFMPartnerBannerDelegate
 *
 * These delegate methods allow the mediator to communicate back to the SDK to inform
 * the publisher when certain events have or will occurred. Even though these delegate
 * methods are optional, banner mediator subclasses must implement them.
 */

@protocol RFMPartnerBannerDelegate <RFMPartnerMediatorDelegate>

@optional
/**
 * **Optional** Delegate callback to inform the SDK that the banner mediation will present modal fullscreen.
 *
 * @see didPresentFullScreenModal
 */
- (void)willPresentFullScreenModal;

/**
 * **Optional** Delegate callback to inform the SDK that the banner mediation did present modal fullscreen.
 *
 * @see willPresentFullScreenModal
 */
- (void)didPresentFullScreenModal;

/**
 * **Optional** Delegate callback to inform the SDK that the banner mediation will dismiss modal fullscreen.
 *
 * @see didDismissFullScreenModal
 */
- (void)willDismissFullScreenModal;

/**
 * **Optional** Delegate callback to inform the SDK that the banner mediation did dismiss modal fullscreen.
 *
 * @see willDismissFullScreenModal
 */
- (void)didDismissFullScreenModal;

@end

/**
 * Interstitial mediator subclasses must conform to RFMPartnerInterstitialDelegate
 *
 * These delegate methods allow the mediator to communicate back to the SDK to inform
 * the publisher when certain events have or will occurred.  Even though these delegate
 * methods are optional, interstitial mediator subclasses must implement them.
 */

@protocol RFMPartnerInterstitialDelegate <RFMPartnerMediatorDelegate>

@optional
/**
 * **Optional** Delegate callback to inform the SDK that the interstitial mediation will dismiss the interstitial.
 *
 * @see didDismissInterstitial
 */
- (void)willDismissInterstitial;

/**
 * **Optional** Delegate callback to inform the SDK that the interstitial mediation did dismiss the interstitial.
 *
 * @see willDismissInterstitial
 */
- (void)didDismissInterstitial;

/**
 * **Optional** Delegate callback to inform the SDK that the interstitial mediation failed to display the ad.
 *
 * @param errorReason Error description in string form.
 * @see didDisplayAd:
 */
- (void)didFailToDisplayAdWithReason:(NSString *)errorReason;

/**
 * **Optional** Delegate callback to inform the SDK that the interstitial mediation did display the ad.
 *
 * @param adView The instance of RFMAdView for which this callback has been triggered.
 * @see didFailToDisplayAdWithReason:
 */
- (void)didDisplayAd:(UIView *)adView;

@end

/**
 * RFMPartnerMediator is meant to be used as an abstract and all partner mediators must
 * subclass this base class.
 *
 * Note: In the case of AdMob (DFP), MoPub, Millenial Media, InMobi, Facebook Ad network,
 * and iAd, mediator adapters are already provided and can be downloaded for use in your
 * project from our dev site.
 */

@interface RFMPartnerMediator : RFMBaseMediator

@property (nonatomic, weak) id<RFMPartnerBannerDelegate, RFMPartnerInterstitialDelegate> delegate;

@end
