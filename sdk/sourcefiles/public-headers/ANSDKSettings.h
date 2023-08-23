/*   Copyright 2016 APPNEXUS INC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "ANUserId.h"

typedef void (^sdkInitCompletion)(BOOL);

@interface ANSDKSettings : NSObject


/**
 If YES, the SDK will allow to perform Open-Measurement Optimisation  for viewability and verification measurement for ads served. Default is NO.
 */
@property (nonatomic, readwrite) BOOL enableOMIDOptimization;


/**
 If YES, the SDK will allow to support Open-Measurement for viewability and verification measurement for ads served. Default is YES.
 */
@property (nonatomic) BOOL enableOpenMeasurement;

/**
 Special ad sizes for which the content view should be constrained to the container view.
 */
@property (nonatomic, copy, nullable) BOOL (^shouldConstrainToSuperview)(NSValue* _Nonnull);

/**
 * Set false to block Location popup asked by Creative, Also notify creative that User denied the request for location.
 * Set True continue the default behaviour.
 * locationEnabledForCreative is turned on by default.
 */
@property (nonatomic) BOOL locationEnabledForCreative;

/**
 If provided, the SDK will use it instead of one fetched from a WebView
 */
@property (nonatomic, readwrite, strong, nullable) NSString *customUserAgent;

/**
Get AppNexus SDK Version
*/
@property (nonatomic, readonly, strong, nonnull) NSString *sdkVersion;

/*!
*  The amount of time, in milliseconds, to wait for a bidder to respond to a bid request, Default is zero
 */
@property (nonatomic, readwrite, assign) NSUInteger auctionTimeout;


/**
 * Sets whether or not AdRequests should be executed in Test Mode.
 * Setting this to YES will execute AdRequests in Test Mode.
 * This should be set to YES only during development/testing.
 * Enabling Test Mode in production will result in unintended consequences and will impact Monetization of your app. Use with caution.
 *
 * default is NO.
 */
@property (nonatomic) BOOL enableTestMode;


+ (nonnull instancetype)sharedInstance;

-(void) optionalSDKInitialization: (sdkInitCompletion _Nullable)success;

/**
   An AppNexus nativeAdAboutToExpireInterval. A nativeAdAboutToExpireInterval is a numeric value that is used to notify before ad is about to expire. Default value of aboutToExpireTimeInterval is 60(second).
 * nativeAdAboutToExpireInterval accept value in second.
 */
@property (nonatomic, readwrite, assign) NSInteger nativeAdAboutToExpireInterval;

/**
An AppNexus geoOverrideCountryCode  is a string value which allows publishers to override country code.
*/
@property (nonatomic, readwrite, strong, nullable) NSString *geoOverrideCountryCode;

/**
An AppNexus geoOverrideZipCode  is a string value which allows publishers to override zip code.
*/
@property (nonatomic, readwrite, strong, nullable) NSString *geoOverrideZipCode;

/**
An AppNexus disableIDFAUsage  is a boolean value which exclude the IDFA field in ad request. Default value of disableIDFAUsage is set to NO
*/
@property (nonatomic, readwrite) BOOL disableIDFAUsage;


/**
An AppNexus disableIDFVUsage  is a boolean value which exclude the IDFV field in ad request. Default value of disableIDFVUsage is set to NO and IDFV will be used in cases where both IDFA and Publisher First Party ID are not present for a given ad request.
*/
@property (nonatomic, readwrite) BOOL disableIDFVUsage;


/**
 Do not track flag. Set this to YES if you have information in the app about user opt out and want to disable tracking cookies for this auction.
 Default value  is set to NO.
*/
@property (nonatomic, readwrite) BOOL doNotTrack;


/**
 Specifies a string that corresponds to the Publishers  User ID for current application user.
*/
@property (nonatomic, readwrite, strong, nullable) NSString *publisherUserId;


/**
 A Dictionary containing objects that hold  UserId parameters.
 */
@property (nonatomic, readwrite, strong, nullable) NSArray<ANUserId *>  *userIdArray ;


/**
 Specifies a string that is used as the in-app browser dismiss button title.
*/
@property (nonatomic, readwrite, strong, nullable) NSString *sdkBrowserDismissTitle;


/**
NSRunLoopCommonModes  ensure that the timers can function in various run loop modes simultaneously
 */
@property (nonatomic) BOOL enableContinuousTracking;


@end
