//
//  SASMediationRewardedVideoAdapter.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 05/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASMediationRewardedVideoAdapterDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol that must be implemented by mediation adapters that load and return rewarded video ads.
 */
@protocol SASMediationRewardedVideoAdapter <NSObject>

@required

/**
 Initialize a new instance of the rewarded video adapter with an adapter delegate.
 
 @param delegate An instance of the delegate you will use to provide information to Smart Display SDK.
 @return An initialized instance of the rewarded video adapter.
 */
- (instancetype)initWithDelegate:(id<SASMediationRewardedVideoAdapterDelegate>)delegate;

/**
 Requests a mediated rewarded video ad asynchronously.
 
 Use the delegate provided in the init method to inform the Smart Display SDK about the loading status of the ad.
 
 @param serverParameterString A string containing all needed parameters (as returned by Smart ad delivery) to make the mediation ad call.
 @param clientParameters Additional client-side parameters (see SASMediationAdapterConstants.h for an exhaustive list).
 */
- (void)requestRewardedVideoWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters;

/**
 Requests the adapter to show the currently loaded rewarded video.
 
 @param viewController The view controller the rewarded video will be displayed into.
 */
- (void)showRewardedVideoFromViewController:(UIViewController *)viewController;

/**
 Return whether the rewarded video is ready to be displayed or not.
 
 @return YES if the rewarded video is ready to be displayed, NO otherwise.
 */
- (BOOL)isRewardedVideoReady;

@end

NS_ASSUME_NONNULL_END
