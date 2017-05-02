//
//  RFMNativeAd.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 8/16/16.
//  Copyright © 2016 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFMAdRequest.h"
#import "RFMNativeAdResponse.h"

@class RFMNativeAd;

/**
 * Native ad protocol for receiving native ad callbacks and notifications.
 *
 * The native ad delegate should conform to this protocol.
 */
@protocol RFMNativeAdDelegate <NSObject>

@optional

/**
 * **Optional** Delegate callback when native ad request has been sent to server.
 *
 * This callback is triggered when a native ad request has been successfully sent to the ad server. Please
 * note that this does not signify that a response has been received from the ad server. This callback
 * is useful for checking the request URL that is actually sent to the ad server.
 *
 * @param nativeAd The instance of RFMNativeAd for which this callback has been triggered.
 * @param requestUrlString The request URL for the request sent to RFM ad server.
 */
- (void)didRequestNativeAd:(RFMNativeAd *)nativeAd withUrl:(NSString *)requestUrlString;

/**
 * **Optional** Native ad has been successfully fetched from the ad server and cached. Native assets are
 * returned in this callback.
 *
 * @param nativeResponse The instance of RFMNativeAdResponse for which this callback has been triggered.
 * @param nativeAd The instance of RFMNativeAd for which this callback has been triggered.
 * @see didFailToReceiveNativeAd:reason:
 */
- (void)didReceiveResponse:(RFMNativeAdResponse *)nativeResponse nativeAd:(RFMNativeAd *)nativeAd;

/**
 * **Optional** SDK failed to receive and cache native ad.
 *
 * @param nativeAd The instance of RFMNativeAd for which this callback has been triggered.
 * @param errorReason The reason for failure to receive and cache native ad.
 * @see didReceiveResponse:nativeAd:
 */
- (void)didFailToReceiveNativeAd:(RFMNativeAd *)nativeAd reason:(NSString *)errorReason;

@end


/**
 * RFMNativeAd class that handles native ad fetching and callbacks.
 *
 * After creating an instance of RFMNativeAd, make a call to request a cacheable native ad.
 */
@interface RFMNativeAd : NSObject

@property (nonatomic, weak, setter = setDelegate:) id<RFMNativeAdDelegate> delegate;

/**
 * Create an instance of RFMNativeAd.
 *
 * @param delegate The delegate that conforms to RFMNativeAdDelegate.
 */
- (id)initWithDelegate:(id<RFMNativeAdDelegate>)delegate;

/**
 * Request a new cacheable native ad from RFM ad server.
 *
 * @param requestParams Request parameters for this call. Instance of RFMAdRequest.
 */
- (BOOL)requestCachedNativeAdWithParams:(RFMAdRequest *)requestParams;

/**
 * Register native ad view to enable SDK handling of impressions and click tracking.
 *
 * @param nativeView The parent native ad view.
 * @param viewController The view controller for which you are using this method.
 */
- (BOOL)registerViewForInteraction:(UIView *)nativeView viewController:(UIViewController *)viewController;

/**
 * Fetches cached assets to use at a later time.
 */
- (RFMNativeAdResponse *)retrieveCachedAssets;

/**
 * Invalidates the current native ad and removes it from cache.
 */
- (void)invalidate;

@end
