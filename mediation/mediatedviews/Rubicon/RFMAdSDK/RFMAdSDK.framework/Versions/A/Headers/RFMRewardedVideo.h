//
//  RFMRewardedVideo.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 6/8/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFMAdRequest.h"
#import "RFMReward.h"

@class RFMRewardedVideo;

/**
 * Rewarded video protocol for the receiving of rewarded video callbacks or notifications.
 *
 * The rewarded video delegate should conform to this protocol.
 */
@protocol RFMRewardedVideoDelegate <NSObject>

/**
 * **Optional** Rewarded video has been successfully fetched from the ad server and loaded. If
 * cacheable rewarded video was requested this delegate will be triggered once caching is successful
 * and rewarded video is ready to be displayed.
 *
 * @param rewardedVideo The instance of RFMRewardedVideo for which this callback has been triggered.
 * @see didFailToReceiveRewardedVideo:reason:
 */
- (void)didReceiveRewardedVideo:(RFMRewardedVideo *)rewardedVideo;

/**
 * **Optional** SDK failed to receive and load rewarded video. If cacheable rewarded video was requested
 * this delegate will be triggered if caching was not successful.
 *
 * @param rewardedVideo The instance of RFMRewardedVideo for which this callback has been triggered.
 * @param errorReason The reason for failure to load rewarded video.
 * @see didReceiveRewardedVideo:
 */
- (void)didFailToReceiveRewardedVideo:(RFMRewardedVideo *)rewardedVideo reason:(NSString *)errorReason;

/**
 * **Optional** Rewarded video is about to appear.
 *
 * @param rewardedVideo The instance of RFMRewardedVideo for which this callback has been triggered.
 */
- (void)rewardedVideoWillAppear:(RFMRewardedVideo *)rewardedVideo;

/**
 * **Optional** Rewarded video has appeared.
 *
 * @param rewardedVideo The instance of RFMRewardedVideo for which this callback has been triggered.
 */
- (void)rewardedVideoDidAppear:(RFMRewardedVideo *)rewardedVideo;

/**
 * **Optional** Started playing rewarded video.
 *
 * @param rewardedVideo The instance of RFMRewardedVideo for which this callback has been triggered.
 */
- (void)didStartRewardedVideoPlayback:(RFMRewardedVideo *)rewardedVideo;

/**
 * **Optional** There was a playback error that occured for the rewarded video.
 *
 * @param rewardedVideo The instance of RFMRewardedVideo for which this callback has been triggered.
 * @param errorReason The reason for failure to play rewarded video.
 */
- (void)didFailToPlayRewardedVideo:(RFMRewardedVideo *)rewardedVideo reason:(NSString *)errorReason;

/**
 * **Optional** SDK completed playing rewarded video ad to its entirety. The reward information
 * specified for this placement will be provided to the publisher at this time.
 *
 * @param rewardedVideo The instance of RFMRewardedVideo for which this callback has been triggered.
 * @param rfmReward An instance of RFMReward containing reward information for this placement.
 */
- (void)didCompleteRewardedVideoPlayback:(RFMRewardedVideo *)rewardedVideo reward:(RFMReward *)rfmReward;

/**
 * **Optional** Rewarded video is about to disappear.
 *
 * @param rewardedVideo The instance of RFMRewardedVideo for which this callback has been triggered.
 */
- (void)rewardedVideoWillDisappear:(RFMRewardedVideo *)rewardedVideo;

/**
 * **Optional** Rewarded video has disappeared.
 *
 * @param rewardedVideo The instance of RFMRewardedVideo for which this callback has been triggered.
 */
- (void)rewardedVideoDidDisappear:(RFMRewardedVideo *)rewardedVideo;

/**
 * **Optional** SuperView of RFMRewardedVideo.
 *
 * Set this delegate method for optimum user experience with rich media ads that need to modify the
 * view to non-standard sizes during user interaction.
 *
 * @return The superview of RFMRewardedVideo instance.
 */
- (UIView *)rfmAdSuperView;

/**
 * **Optional** View controller to present full screen modals.
 *
 * The view controller which will be the parent controller for full screen modals. Full screen modals
 * are used by RFM Ad SDK to load post click in-app browsers.
 * For best results, please return the view controller whose content view covers full screen (apart
 * from tab bar, nav bar and status bar). If the view controller that requested for ads does not have
 * full screen access then return the parent view controller that does have full screen access.
 *
 * @return The UIViewController instance that will be the parent for full screen modals.
 */
- (UIViewController *)viewControllerForRFMModalView;


/**
 * **Optional** Delegate callback when app is pushed to background while the rewarded video was loading.
 *
 * This callback is triggered if the application will enter background while the rewarded video is still
 * loading due to the user clicking home button, the user clicking a button that triggers another
 * application and sends the current application into background, etc. Prior to calling this function,
 * RFMAdSDK will stop loading the rewarded video.
 *
 * @param rewardedVideo The instance of RFMRewardedVideo for which this callback has been triggered.
 */
- (void)rewardedVideoDidStopLoadingAndEnteredBackground:(RFMRewardedVideo *)rewardedVideo;

@end


/**
 * RFMRewardedVideo class that handles rewarded video fetching and callbacks.
 *
 * After creating an instance of RFMRewardedVideo, make a call to request a fresh rewarded video ad or
 * request a cacheable rewarded video.
 */
@interface RFMRewardedVideo : NSObject

@property (assign, readonly) BOOL shouldPrecache;

/**
 * Create an instance of RFMRewardedVideo.
 *
 * @param delegate The delegate that conforms to RFMRewardedVideoDelegate.
 */
- (id)initWithDelegate:(id<RFMRewardedVideoDelegate>)delegate;

/**
 * Request a fresh rewarded video from RFM ad server.
 *
 * @param requestParams Request parameters for this call. Instance of RFMAdRequest.
 */
- (BOOL)requestFreshRewardedVideoWithParams:(RFMAdRequest *)requestParams;

/**
 * Request a new cacheable rewarded video from RFM ad server.
 *
 * @param requestParams Request parameters for this call. Instance of RFMAdRequest.
 */
- (BOOL)requestCachedRewardedVideoWithParams:(RFMAdRequest *)requestParams;

/**
 * Check if a cacheable rewarded video is ready for display.
 */
- (BOOL)canDisplayRewardedVideo;

/**
 * Display a rewarded video.
 */
- (BOOL)showRewardedVideo;

/**
 * Invalidates the current rewarded video and removes it from cache
 */
- (void)invalidate;

@end