//
//  SASMediationRewardedVideoAdapterDelegate.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 05/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASReward.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SASMediationRewardedVideoAdapter;

/**
 Protocol implemented by SASMediationRewardedVideoAdapter delegate.
 
 Use this protocol to provide information about the ad loading status or events to the Smart Display SDK.
 */
@protocol SASMediationRewardedVideoAdapterDelegate <NSObject>

@required

/**
 Notify the Smart Display SDK that an rewarded video ad has been loaded successfully.
 
 @param adapter The mediation adapter.
 */
- (void)mediationRewardedVideoAdapterDidLoad:(id<SASMediationRewardedVideoAdapter>)adapter;

/**
 Notify the Smart Display SDK that an rewarded video ad has failed to load.
 
 @param adapter The mediation adapter.
 @param error The error returned by the mediation SDK.
 @param noFill YES if the error is a 'no fill', NO in all other cases (network error, wrong placement, …). If you are unsure, send YES.
 */
- (void)mediationRewardedVideoAdapter:(id<SASMediationRewardedVideoAdapter>)adapter didFailToLoadWithError:(NSError *)error noFill:(BOOL)noFill;

/**
 Notify the Smart Display SDK that an rewarded video ad has been displayed successfully.
 
 @warning You must call this method as soon as your ad is shown, no impression will be logged on Smart side if you don't.
 
 @param adapter The mediation adapter.
 */
- (void)mediationRewardedVideoAdapterDidShow:(id<SASMediationRewardedVideoAdapter>)adapter;

/**
 Notify the Smart Display SDK that a rewarded video ad has failed to show.
 
 @note Since this error will always happen after a successfull loading, calling this delegate will simply forward the error to the app
 without attempting the loading of the next mediation ad.
 
 @param adapter The mediation adapter.
 @param error The error returned by the mediation SDK.
 */
- (void)mediationRewardedVideoAdapter:(id<SASMediationRewardedVideoAdapter>)adapter didFailToShowWithError:(NSError *)error;

/**
 Notify the Smart Display SDK that a rewarded video ad will present a modal view, for instance after a click.
 
 @param adapter The mediation adapter.
 */
- (void)mediationRewardedVideoAdapterWillPresentModalView:(id<SASMediationRewardedVideoAdapter>)adapter;

/**
 Notify the Smart Display SDK that an rewarded video ad will dismiss a modal view, for instance a post click modal view that was open before.
 
 @param adapter The mediation adapter.
 */
- (void)mediationRewardedVideoAdapterWillDismissModalView:(id<SASMediationRewardedVideoAdapter>)adapter;

/**
 Notify the Smart Display SDK that an interstitial has sent a click event.
 
 @param adapter The mediation adapter.
 */
- (void)mediationRewardedVideoAdapterDidReceiveAdClickedEvent:(id<SASMediationRewardedVideoAdapter>)adapter;

/**
 Notify the Smart Display SDK that the currently displayed interstitial has been closed.
 
 @param adapter The mediation adapter.
 */
- (void)mediationRewardedVideoAdapterDidClose:(id<SASMediationRewardedVideoAdapter>)adapter;

/**
 Notify the Smart Display SDK that the rewarded video has yield a reward.
 
 This method can be called with an actual reward if provided by the third party SDK. It can also
 be called without reward: in this case, the reward set in the Smart insertion will be used.
 
 @note The reward will always be transfered to the app AFTER the rewarded video has been closed, no matter
 when you call this method.
 
 @param adapter The mediation adapter.
 @param reward The reward that has will be forwarded to the app, or nil to use the Smart server side reward instead.
 */
- (void)mediationRewardedVideoAdapter:(id<SASMediationRewardedVideoAdapter>)adapter didCollectReward:(nullable SASReward *)reward;

@end

NS_ASSUME_NONNULL_END
