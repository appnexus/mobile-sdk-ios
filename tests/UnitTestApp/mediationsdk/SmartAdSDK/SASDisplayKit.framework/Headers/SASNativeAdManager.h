//
//  SASNativeAdManager.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 02/09/2015.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SASAdPlacement.h"
#import "SASNativeAd.h"

NS_ASSUME_NONNULL_BEGIN

/// The completion block that will be called when the native ad request is finished.
///
/// - If the ad loading is successful, the ad object will be non null and can be used.
/// - If the ad loading fails, the ad object will be nil and the error object will be defined for a description of the loading issue.
typedef void(^SASNativeRequestCompletionBlock)(SASNativeAd * _Nullable ad, NSError * _Nullable error);

/**
 A SASNativeAdManager instance can be used to request a native ad object from Smart delivery.
 
 Each SASNativeAdManager instance corresponds to a placement, represented by a configuration.
 
 @warning When a native ad is retrieved through a manager, this native ad must be used then discarded before
 releasing the manager or loading a new ad. Failing to do so can lead to several issues, like the ad becoming
 non clickable.
 */
@interface SASNativeAdManager : NSObject

/**
 Initializes a new SASNativeAdManager instance.
 
 @param placement Represents the placement's configuration that will be used by the SASNativeAdManager.
 @return An initialized instance of SASNativeAdManager.
 */
- (instancetype)initWithPlacement:(SASAdPlacement *)placement;

/**
 Requests a native ad from Smart.
 
 @note You can request only one ad at the same time. If you try to request another ad before the call to
 the completion block, it will fail with an error.
 
 @param completionBlock The block that will be called when the ad request is finished.
 */
- (void)requestAd:(SASNativeRequestCompletionBlock)completionBlock;

/**
 Returns an initialized SASNativeAdManager object.
 
 @param placement Represents the placement's configuration that will be used by the SASNativeAdManager.
 @return An initialized instance of SASNativeAdManager.
 */
+ (instancetype)nativeAdManagerWithPlacement:(SASAdPlacement *)placement;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
