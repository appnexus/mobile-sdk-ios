//
//  SASRewardedVideo.h
//  SmartAdServer
//
//  Created by Thomas Geley on 13/06/2017.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SASRewardedVideoPlacement, SASReward;
@protocol SASRewardedVideoDelegate;

@interface SASRewardedVideo : NSObject

/**
 Sets the delegate of all SASRewardedVideo events. See SASRewardedVideoDelegate documentation for available events.
 
 @param delegate A SASRewardedVideoDelegate compliant object that will be the receiver of all SASRewardedVideo events.
 */
+ (void)setDelegate:(nullable id <SASRewardedVideoDelegate>)delegate;


/**
 Loads a rewarded video ad for a given placement. 
 
 This method will not trigger the display of the ad, it will preload the video ad into a player and stay on hold until the showAdForPlacement:fromViewController: method is called for the same placement.
 
 @warning When an ad is loaded for a given placement it will not be reloaded until it is displayed or expired. Calling multiple loadAdForPlacement: without calling showAdForPlacement:fromViewController: is pointless.
 
 @param placement The placement for which you want to load a rewarded video ad.
 */
+ (void)loadAdForPlacement:(SASRewardedVideoPlacement *)placement;


/**
 Shows and plays a rewarded video ad for a given placement into the passed UIViewController.
 
 @warning You should not try to show/play the rewarded video unless isAdReadyForPlacement: indicates that an ad is ready for playing or the rewardedVideoDidLoadForPlacement: delegate's method has been called.
 
 @param placement The placement for which you want to show a rewarded video ad.
 @param controller The UIViewController instance that will present the rewarded video ad.
 */
+ (void)showAdForPlacement:(SASRewardedVideoPlacement *)placement fromViewController:(UIViewController *)controller;


/**
 Returns whether or not a rewarded video ad is ready to be displayed for a given placement. You should call this method before using the showAdForPlacement:fromViewController: method.
 
 @param placement The placement for which you want to know if a rewarded video ad is ready.
 
 @return YES if an rewarded video ad is ready to be displayed on this placement. NO otherwise.
 */
+ (BOOL)isAdReadyForPlacement:(SASRewardedVideoPlacement *)placement;


/**
 Returns the reward associated to a given placement. Call this method if you need to adapt your own behavior/UI depending on the reward amount or currency.
 
 @param placement The placement for which you want to know the reward.
 
 @return The reward associated to the placement. See SASReward documentation for available properties.
 */
+ (nullable SASReward *)rewardForPlacement:(SASRewardedVideoPlacement *)placement;

@end

NS_ASSUME_NONNULL_END
