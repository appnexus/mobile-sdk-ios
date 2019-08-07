//
//  SASMediationNativeAdAdapterDelegate.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 05/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASMediationNativeAdInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SASMediationNativeAdAdapter;

/**
 Protocol implemented by SASMediationNativeAdAdapter delegate.
 
 Use this protocol to provide information about the ad loading status or events to the Smart Display SDK.
 */
@protocol SASMediationNativeAdAdapterDelegate <NSObject>

@required

/**
 Notify the Smart Display SDK that a native ad has been loaded successfully.
 
 When a native ad is fetched using a third party SDK, you must convert it into a SASMediationNativeAdInfo object so the
 Smart SDK is able to use it.
 
 @param adapter The mediation adapter.
 @param adInfo An instance of SASMediationNativeAdInfo that will hold native ad information retrieved from the third party SDK.
 */
- (void)mediationNativeAdAdapter:(id<SASMediationNativeAdAdapter>)adapter didLoadAdInfo:(SASMediationNativeAdInfo *)adInfo;

/**
 Notify the Smart Display SDK that the native ad has failed to load.
 
 @param adapter The mediation adapter.
 @param error The error returned by the mediation SDK.
 @param noFill YES if the error is a 'no fill', NO in all other cases (network error, wrong placement, …). If you are unsure, send YES.
 */
- (void)mediationNativeAdAdapter:(id<SASMediationNativeAdAdapter>)adapter didFailToLoadWithError:(NSError *)error noFill:(BOOL)noFill;

/**
 Notify the Smart Display SDK that a native ad has sent a click event.
 
 @param adapter The mediation adapter.
 */
- (void)mediationNativeAdAdapterDidReceiveAdClickedEvent:(id<SASMediationNativeAdAdapter>)adapter;

@end

NS_ASSUME_NONNULL_END
