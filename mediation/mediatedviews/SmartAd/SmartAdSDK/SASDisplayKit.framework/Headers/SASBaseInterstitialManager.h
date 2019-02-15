//
//  SASBaseInterstitialManager.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 26/07/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SASAdStatus.h"

NS_ASSUME_NONNULL_BEGIN

@class SASAdPlacement;
@protocol SASBidderAdapterProtocol, SASBaseInterstitialManagerInternalDelegate;

/**
 Base interstitial manager class.
 
 This class provides methods used by manager classes handling interstitials.
 
 @note You should never instantiate this class yourself: use the subclass suitable
 for your use case instead.
 */
@interface SASBaseInterstitialManager : NSObject

/// The placement handled by this manager.
@property (nonatomic, readonly) SASAdPlacement *placement;

/// The status of the ad handled by the interstitial manager.
@property (nonatomic, readonly) SASAdStatus adStatus;

/// Internal SASBaseInterstitialManager delegate.
///
/// This delegate can be used to retrieve internal views and events of the SDK. It should only
/// be implemented to if you are using a third party SDK responsible to measure some stats on
/// your ads SDKs.
///
/// @warning Views and objects retrieved from these methods should never be used for anything else
/// than viewability and performance measurement. These internal objects might change without warning
/// in future SDK version.
@property (nonatomic, weak, nullable) id<SASBaseInterstitialManagerInternalDelegate> internalDelegate;

/**
 Loads an interstitial ad.
 
 You can use the isAdReady method to check if the interstitial ad is ready or register a delegate
 if the subclass allows it.
 */
- (void)load;

/**
 Loads an interstitial ad with a bidder adapter.
 
 You can use the adStatus property to check if the interstitial is ready or register a delegate
 if the subclass allows it.
 */
- (void)loadWithBidderAdapter:(nullable id <SASBidderAdapterProtocol>)bidderAdapter NS_SWIFT_NAME(load(bidderAdapter:));

/**
 Shows the loaded interstitial ad if possible. After being displayed, the current interstitial ad is
 unloaded and a new one must be fetched using the load method.
 
 This method will fails if there is no ad loaded.
 
 @warning: The manager must not be deallocated while the interstitial is showing, otherwise it will be
 closed immediately.
 */
- (void)showFromViewController:(UIViewController *)viewController;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
