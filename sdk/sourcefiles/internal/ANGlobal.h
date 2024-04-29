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


#if !APPNEXUS_NATIVE_MACOS_SDK
    #define AN_SDK_VERSION                  @"8.11.4"
#else
    #define AN_SDK_VERSION                  @"8.11.4-mac"
#endif




#define APPNEXUS_BANNER_SIZE		CGSizeMake(320, 50)
#define APPNEXUS_MEDIUM_RECT_SIZE	CGSizeMake(300, 250)
#define APPNEXUS_LEADERBOARD_SIZE	CGSizeMake(728, 90)
#define APPNEXUS_WIDE_SKYSCRAPER_SIZE	CGSizeMake(160, 600)

#define APPNEXUS_SIZE_UNDEFINED         CGSizeMake(-1, -1)


#define kAppNexusNativeAdAboutToExpireInterval 60
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
    ANAllowedMediaTypeHighImpact    = 11,
    ANAllowedMediaTypeNative        = 12
};

typedef NS_ENUM(NSUInteger, ANVideoAdSubtype) {
    ANVideoAdSubtypeUnknown = 0,
    ANVideoAdSubtypeInstream,
    ANVideoAdSubtypeBannerVideo
};

typedef NS_ENUM(NSUInteger, ANImpressionType) {
    ANBeginToRender, // When WebView starts to load the html content
    ANViewableImpression // When 1px of the Ad is Visible to user
};



extern NSString * __nonnull const  ANInternalDelgateTagKeyPrimarySize;
extern NSString * __nonnull const  ANInternalDelegateTagKeySizes;
extern NSString * __nonnull const  ANInternalDelegateTagKeyAllowSmallerSizes;

extern NSString * __nonnull const  kANUniversalAdFetcherWillRequestAdNotification;
extern NSString * __nonnull const  kANUniversalAdFetcherAdRequestURLKey;
extern NSString * __nonnull const  kANUniversalAdFetcherWillInstantiateMediatedClassNotification;
extern NSString * __nonnull const  kANUniversalAdFetcherMediatedClassKey;

extern NSString * __nonnull const  kANUniversalAdFetcherDidReceiveResponseNotification;
extern NSString * __nonnull const  kANUniversalAdFetcherAdResponseKey;                 

static NSString * __nonnull const kANCreativeId             = @"creativeId";
static NSString * __nonnull const kANImpressionUrls         = @"impressionUrls";
static NSString * __nonnull const kANAspectRatio            = @"aspectRatio";
static NSString * __nonnull const kANAdResponseInfo     = @"adResponseInfo";


#pragma mark - Banner AutoRefresh

// These constants control the default behavior of the ad view autorefresh (i.e.,
// how often the view will fetch a new ad).  Ads will only autorefresh
// when they are visible.

// Default autorefresh interval: By default, your ads will autorefresh
// at this interval.
#define kANBannerDefaultAutoRefreshInterval 30.0

// Minimum autorefresh interval: The minimum time between refreshes.
// kANBannerMinimumAutoRefreshInterval MUST be greater than kANBannerAutoRefreshThreshold.
//
#define kANBannerMinimumAutoRefreshInterval 15.0

// Autorefresh threshold: time value to disable autorefresh
#define kANBannerAutoRefreshThreshold 0.0

// Interstitial Close Button Delay
#define kANInterstitialDefaultCloseButtonDelay 10.0
#define kANInterstitialMaximumCloseButtonDelay 10.0


#pragma mark - Global functions.

NSString *__nonnull ANDeviceModel(void);
BOOL ANIsFirstLaunch(void);

NSString * __nonnull ANUUID(void);
NSString *__nullable ANAdvertisingIdentifier(void);
NSString *__nullable ANIdentifierForVendor(void);

NSString *__nonnull ANErrorString( NSString * __nonnull key);
NSError *__nonnull ANError(NSString *__nonnull key, NSInteger code, ...) NS_FORMAT_FUNCTION(1,3);
NSBundle *__nonnull ANResourcesBundle(void);
NSString *__nullable ANPathForANResource(NSString *__nullable name, NSString *__nullable type);
NSString *__nullable ANConvertToNSString(id __nullable value);
CGRect ANAdjustAbsoluteRectInWindowCoordinatesForOrientationGivenRect(CGRect rect);
NSString *__nullable ANMRAIDBundlePath(void);
BOOL ANHasHttpPrefix(NSString  * __nonnull url);

void ANPostNotifications(NSString * __nonnull name, id __nullable object, NSDictionary * __nullable userInfo);
CGRect ANPortraitScreenBounds(void);
CGRect ANPortraitScreenBoundsApplyingSafeAreaInsets(void);
NSMutableURLRequest * __nonnull ANBasicRequestWithURL(NSURL * __nonnull URL);
NSNumber * __nullable ANiTunesIDForURL(NSURL * __nonnull URL);
BOOL ANStatusBarHidden(void);
CGRect ANStatusBarFrame(void);
#if !APPNEXUS_NATIVE_MACOS_SDK
BOOL ANAdvertisingTrackingEnabled(void);
UIInterfaceOrientation ANStatusBarOrientation(void);
BOOL ANCanPresentFromViewController(UIViewController * __nullable viewController);
#endif

#pragma mark - Global class.

@interface ANGlobal : NSObject


+ (NSMutableDictionary<NSString *, NSString *> * __nonnull)convertCustomKeywordsAsMapToStrings: (NSDictionary<NSString *, NSArray<NSString *> *> * __nonnull)keywordsMap
                                                                 withSeparatorString: (nonnull NSString *)separatorString;

+ (nullable id) valueOfGetterProperty: (nonnull NSString *)stringOfGetterProperty
                   forObject: (nonnull id)objectImplementingGetterProperty;

+ (ANAdType) adTypeStringToEnum:(nonnull NSString *)adTypeString;

+ (nonnull NSString *) userAgent;
#if !APPNEXUS_NATIVE_MACOS_SDK
+ (void) openURL: (nonnull NSString *)urlString;

+ (nonnull UIWindow *) getKeyWindow;
#endif

+ (ANVideoOrientation) parseVideoOrientation:(nullable NSString *)aspectRatio;

+ (nullable NSMutableURLRequest *) adServerRequestURL;

+ (void) setWebViewCookie:(nonnull WKWebView*)webView;

+ (void) setANCookieToRequest:(nonnull NSMutableURLRequest *)request;

@end
