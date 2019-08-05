//
//  SASMediationBannerAdapter.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 05/09/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "SASMediationBannerAdapterDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol that must be implemented by mediation adapters that load and return banner ads.
 */
@protocol SASMediationBannerAdapter <NSObject>

@required

/**
 Initialize a new instance of the banner adapter with an adapter delegate.
 
 @param delegate An instance of the delegate you will use to provide information to Smart SDK.
 @return An initialized instance of the banner adapter.
 */
- (instancetype)initWithDelegate:(id<SASMediationBannerAdapterDelegate>)delegate;

/**
 Requests a mediated banner ad asynchronously.
 
 Use the delegate provided in the init method to inform the SDK about the loading status of the ad.
 
 @param serverParameterString A string containing all needed parameters (as returned by Smart ad delivery) to make the mediation ad call.
 @param clientParameters Additional client-side parameters (see SASMediationAdapterConstants.h for an exhaustive list).
 @param viewController The view controller currently displayed on screen, in which the banner will be displayed.
 */
- (void)requestBannerWithServerParameterString:(NSString *)serverParameterString clientParameters:(NSDictionary *)clientParameters viewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
