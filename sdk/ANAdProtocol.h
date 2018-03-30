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

#import "ANAdConstants.h"
#import "ANLocation.h"


@class ANLocation;



#pragma mark - ANAdProtocol partitions.

/**
 ANAdProtocol defines the properties and methods that are common to *all* ad types.
 It can be understood as a toolkit for implementing ad types.
 If you wanted to, you could implement your own ad type using this protocol.
 
 Currently, it is used in the implementation of banner and interstitial ads and instream video.
 */
@protocol ANAdProtocolFoundation <NSObject>

@required
/**
 An AppNexus placement ID.  A placement ID is a numeric ID that's
 associated with a place where ads can be shown.  In our
 implementations of banner and interstitial ad views, we associate
 each ad view with a placement ID.
 */
@property (nonatomic, readwrite, strong) NSString *placementId;

/**
 An AppNexus member ID. A member ID is a numeric ID that's associated
 with the member that this app belongs to.
 */
@property (nonatomic, readonly, assign) NSInteger memberId;

/**
 An inventory code for a placement to represent a place where ads can
 be shown. In the presence of both placement and inventory code, AppNexus
 SDK favors inventory code over placement id. A member ID is required to request
 an ad using inventory code.
 */
@property (nonatomic, readonly, strong) NSString *inventoryCode;

/**
 The user's location.  See ANLocation.h in this directory for
 details.
 */
@property (nonatomic, readwrite, strong) ANLocation *location;

/**
 The reserve price is the minimum bid amount you'll accept to show
 an ad.  Use this with caution, as it can drastically reduce fill
 rates (i.e., you will make less money).
 */
@property (nonatomic, readwrite, assign) CGFloat reserve;

/**
 The user's age.  This can contain a numeric age, a birth year, or a
 hyphenated age range.  For example, "56", "1974", or "25-35".
 */
@property (nonatomic, readwrite, strong) NSString *age;

/**
 The user's gender.  See the ANGender enumeration in ANAdConstants.h for details.
 */
@property (nonatomic, readwrite, assign) ANGender gender;

/**
 Report the Ad Type of the returned ad object.
 Not available until load is complete and successful.
 */
@property (nonatomic, readwrite)  ANAdType  adType;


/**
 Set the user's current location.  This allows ad buyers to do location
 targeting, which can increase spend.
 */
- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy;

/**
 Set the user's current location rounded to the number of decimal places specified in "precision".
 Valid values are between 0 and 6 inclusive. If the precision is -1, no rounding will occur.
 */
- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy
                      precision:(NSInteger)precision;


/**
 * Add a custom keyword to the request URL for the ad.
 * This is used to set custom targeting parameters within the AppNexus platform.
 * You will be given the keys and values to use by your AppNexus account representative or your ad network.
 *
 * @param key   The key to add
 * @param value The value to add
 */
- (void)addCustomKeywordWithKey:(NSString *)key value:(NSString *)value;

/**
 * Remove a custom keyword from the request URL for the ad.
 * Use this to remove a keyword previously set using the
 * addCustomKeywordWithKey:value: method.
 *
 * @param key The key to remove
 */
- (void)removeCustomKeywordWithKey:(NSString *)key;

/**
 * Clear all custom keywords from the request URL.
 */
- (void)clearCustomKeywords;


/**
 Set the inventory code and member id for the place that ads will be shown.
 */
- (void)setInventoryCode:(NSString *)inventoryCode memberId:(NSInteger)memberID;

@end   //ANAdProtocolFoundation



@protocol ANAdProtocolBrowser

@required

/**
 Determines whether the ad, when clicked, will open the device's
 native browser.
 */
@property (nonatomic, readwrite, assign) BOOL opensInNativeBrowser;

/**
 Set whether the landing page should load in the background or in the foreground when an ad is clicked.
 If set to YES, when an ad is clicked the user is presented with an activity indicator view, and the in-app
 browser displays only after the landing page content has finished loading. If set to NO, the in-app
 browser displays immediately. The default is YES.
 
 Has no effect if opensInNativeBrowser is set to YES.
 */
@property (nonatomic, readwrite, assign) BOOL landingPageLoadsInBackground;

@end   //ANAdProtocolBrowser




@protocol ANAdProtocolPublicServiceAnnouncement

@required

/**
 Whether the ad view should display PSAs if there are no ads
 available from the server.
 */
@property (nonatomic, readwrite, assign) BOOL shouldServePublicServiceAnnouncements;

@end

@protocol ANAdProtocolVideo

/**
 minimum duration for the creative.
 */
@property (nonatomic, readwrite, assign) NSUInteger minDuration;

/**
 maximum duration of the fetched creative.
 */
@property (nonatomic, readwrite, assign) NSUInteger maxDuration;

@end   //ANAdProtocolPublicServiceAnnouncement



#pragma mark - ANAdProtocol entrypoint combinations.

@protocol ANAdProtocol <ANAdProtocolFoundation, ANAdProtocolBrowser, ANAdProtocolPublicServiceAnnouncement>

/**
 An AppNexus creativeID for the current creative that is displayed
 */
// CreativeId should be accessible from response Object only(like. ANBannerAdView, ANInterstitialAd, ANInstreamVideoAd  and ANNativeAdResponse). It is placed into ANAdProtocol instead of ANAdProtocolFoundation to avoid creativeID being accessed through ANNativeAdRequest.
@property (nonatomic, readonly, strong) NSString *creativeId;


@end


@protocol ANNativeAdRequestProtocol <ANAdProtocolFoundation>
//EMPTY
@end

@protocol ANNativeAdResponseProtocol <ANAdProtocolBrowser>
//EMPTY
@end


@protocol ANVideoAdProtocol <ANAdProtocol, ANAdProtocolVideo>
//EMPTY
@end

#pragma mark - ANAdDelegate.

/**
 The definition of the `ANAdDelegate' protocol includes methods
 which can be implemented by either type of ad.  Though these
 methods are listed here as optional, specific ad types may require
 them.  For example, interstitial ads require that `adDidReceiveAd'
 be implemented.
 */
@protocol ANAdDelegate <NSObject>


@optional
/**
 Sent when the ad content has been successfully retrieved from the
 server.
 */
- (void)adDidReceiveAd:(id<ANAdProtocol>)ad;

/**
 Sent when the ad request to the server has failed.
 */
- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error;



/**
 Sent when the ad is clicked by the user.
 */
- (void)adWasClicked:(id<ANAdProtocol>)ad;

/**
 Sent when the ad view is about to close.
 */
- (void)adWillClose:(id<ANAdProtocol>)ad;

/**
 Sent when the ad view has finished closing.
 */
- (void)adDidClose:(id<ANAdProtocol>)ad;

/**
 Sent when the ad is clicked, and the SDK is about to open inside
 the in-SDK browser (a WebView).  If you would prefer that ad clicks
 open the native browser instead, set `opensInNativeBrowser' to
 true.
 */
- (void)adWillPresent:(id<ANAdProtocol>)ad;

/**
 Sent when the ad has finished being viewed using the in-SDK
 browser.
 */
- (void)adDidPresent:(id<ANAdProtocol>)ad;

/**
 Sent when the ad is about to leave the app; this can happen if you
 have `opensInNativeBrowser' set to true, for example.
 */
- (void)adWillLeaveApplication:(id<ANAdProtocol>)ad;

@end




#pragma mark - ANAppEventDelegate.

/**
 Delegate to receive app events from the ad.
 */
@protocol ANAppEventDelegate <NSObject>

/**
 Called when the ad has sent the app an event via the AppNexus
 Javascript API for Mobile
 */
- (void)          ad: (id<ANAdProtocol>)ad
  didReceiveAppEvent: (NSString *)name
            withData: (NSString *)data;

@end

