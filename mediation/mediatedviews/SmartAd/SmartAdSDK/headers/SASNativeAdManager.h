//
//  SASNativeAdManager.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 02/09/2015.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SASNativeAdPlacement.h"
#import "SASNativeAd.h"


/**
 The completion block that will be called when the native ad request is finished.
 
 To use this block, you should test if the 'ad' object is not nil and use it. If the ad object is nil,
 you can optionally check the 'error' object to get the description of the issue.
 
 @param ad A valid SASNativeAd if the call was successful, nil otherwise.
 @param error A valid NSError if the call failed, nil otherwise.
 */
typedef void(^SASNativeRequestCompletionBlock)(SASNativeAd * _Nullable ad, NSError * _Nullable error);


/**
 A SASNativeAdManager instance can be used to request a native ad object from Smart AdServer delivery.
 
 Each SASNativeAdManager instance corresponds to a placement, represented by a configuration.
 */
@interface SASNativeAdManager : NSObject

/**
 Initializes a SASNativeAdManager object.
 
 @param placement Represents the placement's configuration that will be used by the SASNativeAdManager.
 
 @return An initialized instance of SASNativeAdManager.
 */
- (nonnull instancetype)initWithPlacement:(nonnull SASNativeAdPlacement *)placement;

/**
 Request a native ad from Smart AdServer.
 
 @warning You can request only one ad at the same time. If you try to request another ad before the call to
 the completion block, it will fail with an error.
 
 @param completionBlock The block that will be called when the ad request is finished.
 */
- (void)requestAd:(nonnull SASNativeRequestCompletionBlock)completionBlock;

/**
 Returns an initialized SASNativeAdManager object.
 
 @param placement Represents the placement's configuration that will be used by the SASNativeAdManager.
 
 @return An initialized instance of SASNativeAdManager.
 */
+ (nonnull instancetype)nativeAdManagerWithPlacement:(nonnull SASNativeAdPlacement *)placement;

/** Specifies the device's location. This object incorporates the geographical coordinates and altitude of the device’s location along with values indicating
 the accuracy of the measurements and when those measurements were made.
 
 Use this method if you want to provide geo-targeted advertisement.
 For example in your CLLocationManagerDelegate:
 
 - (void)locationManager:(CLLocationManager *)locationManager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
 [SASNativeAdManager setLocation:newLocation];
 }
 
 If used, this method should be called as often as possible in order to provide up to date geo-targeting.
 
 @warning *Important:* your application can be rejected by Apple if you use the device&rsquo;s location *only* for advertising.
 Your application needs to have a feature (other than advertising) using geo-location in order to be allowed to ask for the device&rsquo;s position.
 
 @param location The device's location.
 */

+ (void)setLocation:(nonnull CLLocation *)location;

@end
