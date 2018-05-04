/*   Copyright 2013 APPNEXUS INC
 
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
#import <WebKit/WebKit.h>

#import "ANAdConstants.h"



#pragma mark - Constants


#define AN_ERROR_DOMAIN @"com.appnexus.sdk"
#define AN_ERROR_TABLE @"errors"

#define AN_DEFAULT_PLACEMENT_ID		@"default_placement_id"
#define AN_SDK_VERSION                  @"4.7.1"

#define APPNEXUS_BANNER_SIZE		CGSizeMake(320, 50)
#define APPNEXUS_MEDIUM_RECT_SIZE	CGSizeMake(300, 250)
#define APPNEXUS_LEADERBOARD_SIZE	CGSizeMake(728, 90)
#define APPNEXUS_WIDE_SKYSCRAPER_SIZE	CGSizeMake(160, 600)

#define APPNEXUS_SIZE_UNDEFINED         CGSizeMake(-1, -1)



#define kAppNexusRequestTimeoutInterval 30.0
#define kAppNexusAnimationDuration 0.4f
#define kAppNexusMediationNetworkTimeoutInterval 15.0
#define kAppNexusMRAIDCheckViewableFrequency 1.0
#define kAppNexusBannerAdTransitionDefaultDuration 1.0
#define kAppNexusNativeAdImageDownloadTimeoutInterval 10.0
#define kAppNexusNativeAdCheckViewabilityForTrackingFrequency 0.25
#define kAppNexusNativeAdIABShouldBeViewableForTrackingDuration 1.0

#define kANAdSize1x1 CGSizeMake(1,1)


typedef NS_ENUM(NSUInteger, ANAllowedMediaType) {
    ANAllowedMediaTypeBanner        = 1,
    ANAllowedMediaTypeInterstitial  = 3,
    ANAllowedMediaTypeVideo         = 4,
    ANAllowedMediaTypeNative        = 12
};

typedef NS_ENUM(NSUInteger, ANVideoAdSubtype) {
    ANVideoAdSubtypeUnknown = 0,
    ANVideoAdSubtypeInstream,
    ANVideoAdSubtypeBannerVideo
};



extern NSString * const  ANInternalDelgateTagKeyPrimarySize;
extern NSString * const  ANInternalDelegateTagKeySizes;
extern NSString * const  ANInternalDelegateTagKeyAllowSmallerSizes;

extern NSString * const  kANUniversalAdFetcherWillRequestAdNotification;
extern NSString * const  kANUniversalAdFetcherAdRequestURLKey;
extern NSString * const  kANUniversalAdFetcherWillInstantiateMediatedClassNotification;
extern NSString * const  kANUniversalAdFetcherMediatedClassKey;

extern NSString * const  kANUniversalAdFetcherDidReceiveResponseNotification;
extern NSString * const  kANUniversalAdFetcherAdResponseKey;



#pragma mark - Banner AutoRefresh

// These constants control the default behavior of the ad view autorefresh (i.e.,
// how often the view will fetch a new ad).  Ads will only autorefresh
// when they are visible.

// DefaultAutorefreshInterval: By default, your ads will autorefresh
// at this interval.
#define kANBannerDefaultAutoRefreshInterval 30.0

// MinimumAutorefreshInterval: The minimum time between refreshes.
#define kANBannerMinimumAutoRefreshInterval 15.0

// AutorefreshThreshold: time value to disable autorefresh
#define kANBannerAutoRefreshThreshold 0.0

// Interstitial Close Button Delay
#define kANInterstitialDefaultCloseButtonDelay 10.0
#define kANInterstitialMaximumCloseButtonDelay 10.0

#define kANSDKResourcesBundleName @"ANSDKResources"


// Buffer Limit
#define kANPBBufferLimit 10

#pragma mark - Global functions.

NSString *ANDeviceModel(void);
BOOL ANAdvertisingTrackingEnabled(void);
BOOL ANIsFirstLaunch(void);
NSString *ANUDID(void);
NSString *ANErrorString(NSString *key);
NSError *ANError(NSString *key, NSInteger code, ...) NS_FORMAT_FUNCTION(1,3);
NSBundle *ANResourcesBundle(void);
NSString *ANPathForANResource(NSString *name, NSString *type);
NSString *ANConvertToNSString(id value);
CGRect ANAdjustAbsoluteRectInWindowCoordinatesForOrientationGivenRect(CGRect rect);
NSString *ANMRAIDBundlePath(void);
BOOL ANHasHttpPrefix(NSString *url);
void ANSetNotificationsEnabled(BOOL enabled);
void ANPostNotifications(NSString *name, id object, NSDictionary *userInfo);
CGRect ANPortraitScreenBounds(void);
NSURLRequest *ANBasicRequestWithURL(NSURL *URL);
NSNumber *ANiTunesIDForURL(NSURL *URL);
BOOL ANCanPresentFromViewController(UIViewController *viewController);



#pragma mark - Global class.

@interface ANGlobal : NSObject

+ (void) openURL: (NSString *)urlString;

+ (NSMutableDictionary<NSString *, NSString *> *)convertCustomKeywordsAsMapToStrings: (NSDictionary<NSString *, NSArray<NSString *> *> *)keywordsMap
                                                                 withSeparatorString: (NSString *)separatorString;

+ (id) valueOfGetterProperty: (NSString *)stringOfGetterProperty
                   forObject: (id)objectImplementingGetterProperty;

+ (ANAdType) adTypeStringToEnum:(NSString *)adTypeString;

+ (NSString *) getUserAgent;

@end
