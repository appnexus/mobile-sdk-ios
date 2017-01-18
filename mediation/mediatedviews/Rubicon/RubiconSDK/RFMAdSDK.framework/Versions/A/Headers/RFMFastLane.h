//
//  RFMFastLane.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 12/8/15.
//  Copyright © 2015 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFMAdRequest.h"

@class RFMAdView;

/**
 * FastLane protocol for the receiving of fastlane callbacks or notifications.
 *
 * The fastlane delegate should conform to this protocol.
 */
@protocol RFMFastLaneDelegate <NSObject>

/**
 * Delegate callback when an ad has been successfully prefetched.
 *
 * @param adInfo dictionary that contains information pertaining to ad, 
 *          such as fastlane bid range
 * @param rfmAppId application ID associated to fastlane request
 * @see didFailToReceiveFastLaneAdWithReason:rfmAppId:
 */
- (void)didReceiveFastLaneAdInfo:(NSDictionary *)adInfo rfmAppId:(NSString*)rfmAppId;

/**
 * **Optional** Delegate callback when the SDK failed to prefetch an ad.
 *
 * @param errorReason The reason for failure to load an ad
 * @param rfmAppId application ID associated to fastlane request
 * @see didReceiveFastLaneAdInfo:rfmAppId:
 */
- (void)didFailToReceiveFastLaneAdWithReason:(NSString *)errorReason rfmAppId:(NSString*)rfmAppId;

@optional
#pragma mark - DEPRECATED METHODS

/**
 * Delegate callback when an ad has been successfully prefetched.
 *
 * @param adInfo dictionary that contains information pertaining to ad,
 *          such as fastlane bid range
 * @see didReceiveFastLaneAdInfo:rfmAppId:
 * @warning **Deprecated in RFM iOS SDK 5.1.0**
 */
- (void)didReceiveFastLaneAdInfo:(NSDictionary *)adInfo DEPRECATED_ATTRIBUTE;

/**
 * **Optional** Delegate callback when the SDK failed to prefetch an ad.
 *
 * @param errorReason The reason for failure to load an ad
 * @see didFailToReceiveFastLaneAdWithReason:rfmAppId:
 * @warning **Deprecated in RFM iOS SDK 5.1.0**
 */
- (void)didFailToReceiveFastLaneAdWithReason:(NSString *)errorReason DEPRECATED_ATTRIBUTE;

@end

/**
 * RFMFastLane class that handles fastlane prefetching and callbacks.
 *
 * After creating an instance of RFMFastLane, make a call to prefetch an ad.
 * It is recommended to move the primary SDK request call into the didReceiveFastLaneAdInfo: method.
 */
@interface RFMFastLane : NSObject

/**
 * RFM Application ID
 *
 * Read-only property for application ID.  
 * This is nil until preFetchAdWithParams: method is called.
 */
@property (nonatomic, strong, readonly) NSString *rfmAppId;

/**
 * Fastlane delegate
 *
 * A delegate that should conform to the RFMFastLaneDelegate protocol.
 */
@property (nonatomic, weak) id <RFMFastLaneDelegate> delegate;

/**
 * Create an instance of RFMFastLane.
 *
 * @param adView The adView that will be used to initialize the fastlane request
 * @param delegate The delegate that conforms to RFMFastLaneDelegate
 * @see preFetchAdWithParams:
 */
- (id)initWithAdView:(UIView*)adView
            delegate:(id<RFMFastLaneDelegate>)delegate;

/**
 * Create an instance of RFMFastLane.
 *
 * @param size The size of the adview that will be used for the fastlane request
 * @param delegate The delegate that conforms to RFMFastLaneDelegate
 * @see preFetchAdWithParams:
 */
- (id)initWithSize:(CGSize)size
          delegate:(id<RFMFastLaneDelegate>)delegate;

/**
 * Prefetch ad for fastlane.
 *
 * @param requestParams The request parameters associated with the fastlane request
 * @see initWithAdView:delegate:
 */
- (BOOL)preFetchAdWithParams:(RFMAdRequest *)requestParams;

@end
