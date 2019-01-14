//
//  SASRewardedVideoManager.h
//  SmartAdServer
//
//  Created by Thomas Geley on 13/06/2017.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SASRewardedVideoManagerDelegate.h"
#import "SASBaseInterstitialManager.h"

NS_ASSUME_NONNULL_BEGIN

@class SASAdPlacement;

/**
 Class used to load and display rewarded interstitial ads.
 */
@interface SASRewardedVideoManager : SASBaseInterstitialManager

/// An object implementing the SASRewardedVideoManagerDelegate protocol.
@property (nonatomic, weak, nullable) id<SASRewardedVideoManagerDelegate> delegate;

/**
 Initializes a new SASRewardedVideoManager instance.
 
 @param placement The placement that will be used to load rewarded interstitial ads.
 @param delegate An object implementing the SASRewardedVideoManagerDelegate protocol.
 
 @return An initialized instance of SASRewardedVideoManager.
 */
- (instancetype)initWithPlacement:(SASAdPlacement *)placement delegate:(nullable id<SASRewardedVideoManagerDelegate>)delegate;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
