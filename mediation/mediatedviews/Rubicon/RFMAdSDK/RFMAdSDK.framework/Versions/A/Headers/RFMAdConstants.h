//
//  RFMAdConstants.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 3/13/14.
//  Copyright © 2014 Rubicon Project. All rights reserved.
//

#ifndef RFMAdSDK_RFMAdConstants_h
#define RFMAdSDK_RFMAdConstants_h

#import <UIKit/UIKit.h>

/**
 * Convenience macros and constants
 */

#define RFM_AD_FRAME_OF_SIZE(w,h) CGRectMake(0,0,w,h)

#define RFM_AD_SET_CENTER(CENTER_X, CENTER_Y) CGPointMake(CENTER_X,CENTER_Y)

//#define RFM_AD_SET_CENTER(AD_WIDTH,AD_HEIGHT, WD_OFFSET, HT_OFFSET) CGPointMake(CGRectGetMidX([[UIScreen mainScreen] bounds])+WD_OFFSET,(AD_HEIGHT/2)+HT_OFFSET)

#define RFM_STATUS_BAR_OFFSET 20.0f

#pragma mark - RFM Ad Default Sizes
#define RFM_AD_IPHONE_DEFAULT_WIDTH 320
#define RFM_AD_IPHONE_DEFAULT_HEIGHT 50
#define RFM_AD_IPAD_DEFAULT_WIDTH 300
#define RFM_AD_IPAD_DEFAULT_HEIGHT 250

#pragma mark - RFM AdType information

extern NSString* const kRFMAdTypeBanner;
extern NSString* const kRFMAdTypeInterstitial;

#define RFM_ADTYPE_BANNER @"1"         //Type 1 = Banner
#define RFM_ADTYPE_INTERSTITIAL @"2"   //Type 2 = Interstitial

#define RFM_AD_MEDIATION_INFO_PLACEMENT_ID_KEY @"placementId"
#define RFM_AD_MEDIATION_INFO_ADUNIT_ID_KEY @"adUnitId"

#define RFM_AD_MEDIATION_INFO_KEY @"mediationInfo"

#pragma mark - Ad Forensics gesture recognizer default types

/**
 * Ad Forensics touch gestures
 *
 * Basic touch gestures that are provided for convenience. To be used for Ad Forensics reporting.
 */
typedef NS_ENUM(NSUInteger, RFMAdForensicsTouchGesture) {
    /**
     * A two-finger swipe in any direction
     */
    RFMAdForensicsSwipeWithTwoFingers = 0,
    
    /**
     * A two-finger tap
     */
    RFMAdForensicsTapWithTwoFingers,
    
    /**
     * A three-finger tap
     */
    RFMAdForensicsTapWithThreeFingers,
    
    /**
     * A drawing of the letter W with one finger
     */
    RFMAdForensicsDrawW,
    
    /**
     * A two-finger simultaneous press held for at least 5 seconds on each edge of the ad.
     * This gesture will be used as default if one is not set.
     */
    RFMAdForensicsLongPressWithTwoFingers
};

#pragma mark - RFMSDK Logging

/**
 * Logging Levels
 *
 * Log messages to be printed as NSLog messages. The levels increase in verbosity as you go down the list. We recommend turning all logs off in a production environment.
 */
typedef NS_ENUM(NSUInteger,RFMSDKLogLevel){
  /**
   * Log all RFMAdSDK log messages
   */
  kRFMSDKLogLevelOff = 0,
  
  /**
   * Log only error messages in console messages
   */
  kRFMSDKLogLevelError,
  
  /**
   * Log any warning messages
   */
  kRFMSDKLogLevelWarn,
  
  /**
   * Log informational messages about ad load status
   */
  kRFMSDKLogLevelInfo,
  
  /**
   * Log all debug messages related to ad content and ad interaction
   */
  kRFMSDKLogLevelDebug,
  
  /**
   * Log all possible messages printed by the SDK
   */
  kRFMSDKLogLevelTrace
};




#endif
