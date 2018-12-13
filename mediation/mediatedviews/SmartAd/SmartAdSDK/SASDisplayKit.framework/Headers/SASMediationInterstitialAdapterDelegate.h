//
//  SASMediationInterstitialAdapterDelegate.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 05/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@protocol SASMediationInterstitialAdapter;

/**
 Protocol implemented by SASMediationInterstitialAdapter delegate.
 
 Use this protocol to provide information about the ad loading status or events to the Smart Display SDK.
 */
@protocol SASMediationInterstitialAdapterDelegate <NSObject>

@required

/**
 Notify the Smart Display SDK that an interstitial ad has been loaded successfully.
 
 @param adapter The mediation adapter.
 */
- (void)mediationInterstitialAdapterDidLoad:(id<SASMediationInterstitialAdapter>)adapter;

/**
 Notify the Smart Display SDK that an interstitial ad has failed to load.
 
 @param adapter The mediation adapter.
 @param error The error returned by the mediation SDK.
 @param noFill YES if the error is a 'no fill', NO in all other cases (network error, wrong placement, …). If you are unsure, send YES.
 */
- (void)mediationInterstitialAdapter:(id<SASMediationInterstitialAdapter>)adapter didFailToLoadWithError:(NSError *)error noFill:(BOOL)noFill;

/**
 Notify the Smart Display SDK that an interstitial ad has been displayed successfully.
 
 @warning You must call this method as soon as your ad is shown, no impression will be logged on Smart side if you don't.
 
 @param adapter The mediation adapter.
 */
- (void)mediationInterstitialAdapterDidShow:(id<SASMediationInterstitialAdapter>)adapter;

/**
 Notify the Smart Display SDK that an interstitial ad has failed to show.
 
 @note Since this error will always happen after a successfull loading, calling this delegate will simply forward the error to the app
 without attempting the loading of the next mediation ad.
 
 @param adapter The mediation adapter.
 @param error The error returned by the mediation SDK.
 */
- (void)mediationInterstitialAdapter:(id<SASMediationInterstitialAdapter>)adapter didFailToShowWithError:(NSError *)error;

/**
 Notify the Smart Display SDK that an interstitial ad will present a modal view, for instance after a click.
 
 @param adapter The mediation adapter.
 */
- (void)mediationInterstitialAdapterWillPresentModalView:(id<SASMediationInterstitialAdapter>)adapter;

/**
 Notify the Smart Display SDK that an interstitial ad will dismiss a modal view, for instance a post click modal view that was open before.
 
 @param adapter The mediation adapter.
 */
- (void)mediationInterstitialAdapterWillDismissModalView:(id<SASMediationInterstitialAdapter>)adapter;

/**
 Notify the Smart Display SDK that an interstitial has sent a click event.
 
 @param adapter The mediation adapter.
 */
- (void)mediationInterstitialAdapterDidReceiveAdClickedEvent:(id<SASMediationInterstitialAdapter>)adapter;

/**
 Notify the Smart Display SDK that the currently displayed interstitial has been closed.
 
 @param adapter The mediation adapter.
 */
- (void)mediationInterstitialAdapterDidClose:(id<SASMediationInterstitialAdapter>)adapter;

@end

NS_ASSUME_NONNULL_END
