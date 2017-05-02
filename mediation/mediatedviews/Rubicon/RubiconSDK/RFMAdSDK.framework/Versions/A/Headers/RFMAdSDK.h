//
//  RFMAdSDK.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 5/19/14.
//  Copyright © 2014 Rubicon Project. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <RFMAdSDK/RFMAdConstants.h>
#import <RFMAdSDK/RFMAdView.h>
#import <RFMAdSDK/RFMAdRequest.h>
#import <RFMAdSDK/RFMAdDelegate.h>
#import <RFMAdSDK/RFMSupportedMediations.h>
#import <RFMAdSDK/RFMBaseMediator.h>
#import <RFMAdSDK/RFMMediationHelper.h>
#import <RFMAdSDK/RFMBaseMediatorDelegate.h>
#import <RFMAdSDK/RFMFastLane.h>
#import <RFMAdSDK/RFMRewardedVideo.h>
#import <RFMAdSDK/RFMNativeAd.h>
#import <RFMAdSDK/RFMNativeAdPlacer.h>
#import <RFMAdSDK/RFMAdsLoader.h>
#import <RFMAdSDK/RFMAdsLoaderDelegate.h>
#import <RFMAdSDK/RFMAVPlayerProgressObserver.h>
#import <RFMAdSDK/RFMVideoPlayerProgressObserver.h>
#import <RFMAdSDK/RFMAdSession.h>
#import <RFMAdSDK/RFMVideoAdSession.h>
#import <RFMAdSDK/RFMAdProtocols.h>
#import <RFMAdSDK/RFMPlayerControl.h>
#import <RFMAdSDK/NSValue+RFMCuePoint.h>

/**
 * Main interface for including RFMAdSDK headers
 */

@interface RFMAdSDK : NSObject

/**
 * Prepare or intialize SDK
 *
 * Use this method to prepare the SDK for use. This should be done during the startup
 * phase of the application and before any ad request objects are created.
 *
 * @param accountId The account ID used to initialize the SDK. Instance of NSString.
 */
+ (void)initWithAccountId:(NSString*)accountId;

/** @name Logging */

/**
 * Set log level
 *
 * Use this method to enable logging in RFMAdSDK. Logging is disabled by default ( kRFMSDKLogLevelOff ).
 *
 * @param logLevel See RFMSDKLogLevel for allowed logging levels.
 */
+(void)setLogLevel:(enum RFMSDKLogLevel)logLevel;

@end
