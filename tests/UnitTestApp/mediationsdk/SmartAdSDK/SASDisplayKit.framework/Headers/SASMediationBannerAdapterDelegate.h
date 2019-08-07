//
//  SASMediationBannerAdapterDelegate.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 05/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SASMediationBannerAdapter;

/**
 Protocol implemented by SASMediationBannerAdapter delegate.
 
 Use this protocol to provide information about the ad loading status or events to the Smart Display SDK.
 */
@protocol SASMediationBannerAdapterDelegate <NSObject>

@required

/**
 Notify the Smart Display SDK that a banner ad has been loaded successfully.
 
 @param adapter The mediation adapter.
 @param bannerView The banner view that has been loaded.
 */
- (void)mediationBannerAdapter:(id<SASMediationBannerAdapter>)adapter didLoadBanner:(UIView *)bannerView;

/**
 Notify the Smart Display SDK that a banner ad has failed to load.
 
 @param adapter The mediation adapter.
 @param error The error returned by the mediation SDK.
 @param noFill YES if the error is a 'no fill', NO in all other cases (network error, wrong placement, …). If you are unsure, send YES.
 */
- (void)mediationBannerAdapter:(id<SASMediationBannerAdapter>)adapter didFailToLoadWithError:(NSError *)error noFill:(BOOL)noFill;

/**
 Notify the Smart Display SDK that a banner ad will present a modal view, for instance after a click.
 
 @param adapter The mediation adapter.
 */
- (void)mediationBannerAdapterWillPresentModalView:(id<SASMediationBannerAdapter>)adapter;

/**
 Notify the Smart Display SDK that a banner ad will dismiss a modal view, for instance a post click modal view that was open before.
 
 @param adapter The mediation adapter.
 */
- (void)mediationBannerAdapterWillDismissModalView:(id<SASMediationBannerAdapter>)adapter;

/**
 Notify the Smart Display SDK that a banner has sent a click event.
 
 @param adapter The mediation adapter.
 */
- (void)mediationBannerAdapterDidReceiveAdClickedEvent:(id<SASMediationBannerAdapter>)adapter;

@end

NS_ASSUME_NONNULL_END
