//
//  SASMediationInterstitialAdapter.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 05/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASMediationInterstitialAdapterDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol that must be implemented by mediation adapters that load and return interstitial ads.
 */
@protocol SASMediationInterstitialAdapter <NSObject>

@required

/**
 Initialize a new instance of the interstitial adapter with an adapter delegate.
 
 @param delegate An instance of the delegate you will use to provide information to Smart SDK.
 @return An initialized instance of the interstitial adapter.
 */
- (instancetype)initWithDelegate:(id<SASMediationInterstitialAdapterDelegate>)delegate;

/**
 Requests a mediated interstitial ad asynchronously.
 
 Use the delegate provided in the init method to inform the SDK about the loading status of the ad.
 
 @param serverParameterString A string containing all needed parameters (as returned by Smart ad delivery) to make the mediation ad call.
 @param clientParameters Additional client-side parameters (see SASMediationAdapterConstants.h for an exhaustive list)..
 */
- (void)requestInterstitialWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters;

/**
 Requests the adapter to show the currently loaded interstitial.
 
 @param viewController The view controller the interstitial will be displayed into.
 */
- (void)showInterstitialFromViewController:(UIViewController *)viewController;

/**
 Return whether the interstitial is ready to be displayed or not.
 
 @return YES if the interstitial is ready to be displayed, NO otherwise.
 */
- (BOOL)isInterstitialReady;

@end

NS_ASSUME_NONNULL_END
