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
#import <UIKit/UIKit.h>

// Production
#define AN_BASE_URL @"http://mediation.adnxs.com/"
#define AN_MOBILE_HOSTNAME @"mediation.adnxs.com/mob"
#define AN_MOBILE_HOSTNAME_INSTALL @"mediation.adnxs.com/install"

// Client Testing
#define AN_BASE_URL_CTEST @"http://ib.client-testing.adnxs.net/"
#define AN_MOBILE_HOSTNAME_CTEST @"ib.client-testing.adnxs.net/mob"
#define AN_MOBILE_HOSTNAME_INSTALL_CTEST @"ib.client-testing.adnxs.net/install"

//Sandbox
#define AN_BASE_URL_SAND @"http://ib.sand-08.adnxs.net/"
#define AN_MOBILE_HOSTNAME_SAND @"ib.sand-08.adnxs.net/mob"
#define AN_MOBILE_HOSTNAME_INSTALL_SAND @"ib.sand-08.adnxs.net/install"

#define AN_ERROR_DOMAIN @"com.appnexus.sdk"
#define AN_ERROR_TABLE @"errors"

#define AN_DEFAULT_PLACEMENT_ID		@"default_placement_id"
#define AN_SDK_VERSION              @"2.0"

#define APPNEXUS_BANNER_SIZE			CGSizeMake(320, 50)
#define APPNEXUS_MEDIUM_RECT_SIZE		CGSizeMake(300, 250)
#define APPNEXUS_LEADERBOARD_SIZE		CGSizeMake(728, 90)
#define APPNEXUS_WIDE_SKYSCRAPER_SIZE	CGSizeMake(160, 600)

#pragma mark Constants

#define kAppNexusRequestTimeoutInterval 30.0
#define kAppNexusAnimationDuration 0.4f
#define kAppNexusMediationNetworkTimeoutInterval 15.0
#define kAppNexusMRAIDCheckViewableFrequency 1.0
#define kAppNexusBannerAdTransitionDefaultDuration 1.0
#define kAppNexusNativeAdImageDownloadTimeoutInterval 10.0

// Banner AutoRefresh

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

// Buffer Limit
#define kANPBBufferLimit 10

typedef NS_ENUM(NSUInteger, ANMobileEndpoint) {
    ANMobileEndpointProduction = 0,
    ANMobileEndpointClientTesting,
    ANMobileEndpointSandbox
};

NSString *ANUserAgent(void);
NSString *ANDeviceModel(void);
BOOL ANAdvertisingTrackingEnabled(void);
BOOL isFirstLaunch(void);
NSString *ANUDID(void);
NSString *ANErrorString(NSString *key);
NSError *ANError(NSString *key, NSInteger code, ...) NS_FORMAT_FUNCTION(1,3);
NSBundle *ANResourcesBundle();
NSString *ANPathForANResource(NSString *name, NSString *type);
NSString *convertToNSString(id value);
CGRect adjustAbsoluteRectInWindowCoordinatesForOrientationGivenRect(CGRect rect);
NSString *ANMRAIDBundlePath();
BOOL hasHttpPrefix(NSString *url);
NSMutableSet *ANInvalidNetworks();
void ANAddInvalidNetwork(NSString *network);
void ANSetNotificationsEnabled(BOOL enabled);
void ANPostNotifications(NSString *name, id object, NSDictionary *userInfo);
CGRect ANPortraitScreenBounds();
