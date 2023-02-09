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
#import "ANLocation.h"
#import "ANAdConstants.h"
#import "ANAdResponseInfo.h"
#import "ANAdResponseCode.h"

#if !APPNEXUS_NATIVE_MACOS_SDK
  #import <UIKit/UIKit.h>
#endif

@class ANLocation;


#pragma mark - ANAdProtocol partitions.
/**
 ANAdProtocol defines the properties and methods that are common to *all* ad types.
 It can be understood as a toolkit for implementing ad types.
 If you wanted to, you could implement your own ad type using this protocol.
 
 Currently, it is used in the implementation of banner and interstitial ads and instream video.
 */

@protocol ANAdProtocolFoundationCore <NSObject>

@required
/**
 An AppNexus member ID. A member ID is a numeric ID that's associated
 with the member that this app belongs to.
 */
@property (nonatomic, readonly, assign) NSInteger memberId;

/**
 * A publisher ID associates this member with a publisher.
 */
@property (nonatomic, readwrite, assign) NSInteger publisherId;


/**
 The user's location.  See ANLocation.h in this directory for
 details.
 */
@property (nonatomic, readwrite, strong, nullable) ANLocation *location;


/**
 The user's age.  This can contain a numeric age, a birth year, or a
 hyphenated age range.  For example, "56", "1974", or "25-35".
 */
@property (nonatomic, readwrite, strong, nullable) NSString *age;

/**
 The user's gender.  See the ANGender enumeration in ANAdConstants.h for details.
 */
@property (nonatomic, readwrite, assign) ANGender gender;


/**
 Set the user's current location.  This allows ad buyers to do location
 targeting, which can increase spend.
 */
- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      timestamp:(nullable NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy;

/**
 Set the user's current location rounded to the number of decimal places specified in "precision".
 Valid values are between 0 and 6 inclusive. If the precision is -1, no rounding will occur.
 */
- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      timestamp:(nullable NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy
                      precision:(NSInteger)precision;


/**
 * Add a custom keyword to the request URL for the ad.
 * This is used to set custom targeting parameters within the AppNexus platform.
 * You will be given the keys and values to use by your AppNexus account representative or your ad network.
 *
 * @param key   The key to add
 * @param value The value to add
 */
- (void)addCustomKeywordWithKey:(nonnull NSString *)key value:(nonnull NSString *)value;

/**
 * Remove a custom keyword from the request URL for the ad.
 * Use this to remove a keyword previously set using the
 * addCustomKeywordWithKey:value: method.
 *
 * @param key The key to remove
 */
- (void)removeCustomKeywordWithKey:(nonnull NSString *)key;

/**
 * Clear all custom keywords from the request URL.
 */
- (void)clearCustomKeywords;


@end   //ANAdProtocolFoundationCore



#pragma mark -

@protocol ANAdProtocolFoundation <ANAdProtocolFoundationCore>

@required
/**
 An AppNexus placement ID.  A placement ID is a numeric ID that's
 associated with a place where ads can be shown.  In our
 implementations of banner and interstitial ad views, we associate
 each ad view with a placement ID.
 */
@property (nonatomic, readwrite, strong, nullable) NSString *placementId;

/**
 An inventory code for a placement to represent a place where ads can
 be shown. In the presence of both placement and inventory code, AppNexus
 SDK favors inventory code over placement id. A member ID is required to request
 an ad using inventory code.
 */
@property (nonatomic, readonly, strong, nullable) NSString *inventoryCode;

/**
 Set AppNexus CreativeId that you want to display on this AdUnit for debugging/testing purpose.
 */
@property (nonatomic, readwrite, assign) NSInteger forceCreativeId;

/**
 The reserve price is the minimum bid amount you'll accept to show
 an ad.  Use this with caution, as it can drastically reduce fill
 rates (i.e., you will make less money).
 */
@property (nonatomic, readwrite, assign) CGFloat reserve;

/**
 Set the inventory code and member id for the place that ads will be shown.
 */
- (void)setInventoryCode:(nullable NSString *)inventoryCode memberId:(NSInteger)memberID;

/**
 Set the extInvCode, Specifies predefined value passed on the query string that can be used in reporting. The value must be entered into the system before it is logged.
*/

@property (nonatomic, readwrite, strong, nullable) NSString *extInvCode;


/**
Set the trafficSourceCode,  Specifies the third-party source of the impression.
*/
@property (nonatomic, readwrite, strong, nullable) NSString *trafficSourceCode;

@end   //ANAdProtocolFoundation



#pragma mark -

@protocol ANAdProtocolBrowser

/**
 Determines what action to take when the user clicks on an ad:
     . Open the click-through URL in the SDK browser;
     . Open the click-through URL in the external device browser;
     . Return the URL to the calling environment without opening any browser.

 Cases that open a browser will notify the caller via the delegate method adWasClicked.
 The case that returns the URL will notify via adWasClickedWithURL:(NSString *)urlString .
 When the urlString is returned it is ASSUMED that the caller will handle it appropriately,
   displaying its content to the user.
 */
@property (nonatomic, readwrite)  ANClickThroughAction  clickThroughAction;

/**
 Set whether the landing page should load in the background or in the foreground when an ad is clicked.
 If set to YES, when an ad is clicked the user is presented with an activity indicator view, and the in-app
 browser displays only after the landing page content has finished loading. If set to NO, the in-app
 browser displays immediately. The default is YES.

 Only used when clickThroughAction is set to ANClickThroughActionOpenSDKBrowser.
 */
@property (nonatomic, readwrite, assign) BOOL landingPageLoadsInBackground;

@end   //ANAdProtocolBrowser




#pragma mark -

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



#pragma mark - ANAdProtocol adunit combinations.

@protocol ANAdProtocol <ANAdProtocolFoundation, ANAdProtocolBrowser, ANAdProtocolPublicServiceAnnouncement>

/**
 * An AppNexus Single Unified object that will contain all the common fields of all the ads types
 *
 * adResponseInfo should be accessible from response Object only -- ANBannerAdView, ANInterstitialAd, ANInstreamVideoAd and ANNativeAdResponse).
 * It is placed into ANAdProtocol instead of ANAdProtocolFoundation to avoid adResponseInfo being accessed through ANNativeAdRequest.
 */
@property (nonatomic, readwrite, strong, nullable) ANAdResponseInfo *adResponseInfo;
// OpenMeasurement is not supported by macOS 
#if !APPNEXUS_NATIVE_MACOS_SDK

/*!
 * UI View which would consider to be part of the ad can be added as friendly obstruction
 * (all sub-views of the adView will be automatically treated as part of the ad)
 */
- (void)addOpenMeasurementFriendlyObstruction:(nonnull UIView *)obstructionView;

/*!
 * Remove friendly Obstruction from the list of FriendlyObstruction
 */
- (void)removeOpenMeasurementFriendlyObstruction:(nonnull UIView*)obstructionView;

/*!
 * Remove all friendly Obstruction
 */
- (void)removeAllOpenMeasurementFriendlyObstructions;
#endif
@end



@protocol ANNativeAdRequestProtocol <ANAdProtocolFoundation, ANAdProtocolPublicServiceAnnouncement>
    //EMPTY
@end

@protocol ANNativeAdResponseProtocol <ANAdProtocolBrowser>
    //EMPTY
@end



@protocol ANVideoAdProtocol <ANAdProtocol, ANAdProtocolVideo>
/**
 * Get the Orientation of the Video rendered using the BannerAdView
 *
 * @return Default VideoOrientation value ANUnknown, which indicates that aspectRatio can't be retrieved for the video.
 */
- (ANVideoOrientation) getVideoOrientation;

- (NSInteger) getVideoWidth;

- (NSInteger) getVideoHeight;


@end




#pragma mark - ANAdDelegate.

/**
 The definition of the `ANAdDelegate' protocol includes methods which can be implemented by either type of ad.
 Though these methods are listed here as optional, specific ad types may require them.
 For example, interstitial ads require that `adDidReceiveAd:' be implemented.
 */
@protocol ANAdDelegate <NSObject>


@optional
/**
 Sent when the ad content has been successfully retrieved from the server.
   adDidReceiveAd:          used with Banner, Interstitial and Instream Video.
   ad:didReceivNativeAd:    used to receive ANNativeAdReponse when that is returned from an ANBannerAdView request.
 */
- (void)adDidReceiveAd:(nonnull id)ad;
- (void)lazyAdDidReceiveAd:(nonnull id)ad;

- (void)ad:(nonnull id)loadInstance didReceiveNativeAd:(nonnull id)responseInstance;


/**
 Sent when the ad request to the server has failed.
 */
- (void)ad:(nonnull id)ad requestFailedWithError:(nonnull NSError *)error;


/**
 Sent when the ad is clicked by the user.
 */
- (void)adWasClicked:(nonnull id)ad;

/**
 Sent when the ad is clicked and the click-through URL is returned to the caller instead of being opened in a browser.
 */
- (void)adWasClicked:(nonnull id)ad withURL:(nonnull NSString *)urlString;

/**
 Sent when the ad logs Impression
 */
- (void)adDidLogImpression:(nonnull id)ad;

/**
 Sent when the ad view is about to close.
 */
- (void)adWillClose:(nonnull id)ad;

/**
 Sent when the ad view has finished closing.
 */
- (void)adDidClose:(nonnull id)ad;

/**
 Sent when the ad is clicked, and the SDK is about to open inside the in-SDK browser (a WebView).
 If you would prefer that ad clicks open the native browser instead,
   set clickThroughAction to ANClickThroughActionOpenDeviceBrowser.
 */
- (void)adWillPresent:(nonnull id)ad;

/**
 Sent when the ad has finished being viewed using the in-SDK
 browser.
 */
- (void)adDidPresent:(nonnull id)ad;

/**
 Sent when the ad is about to leave the app.
 This will happen in a number of cases, including when
   clickThroughAction is set to ANClickThroughActionOpenDeviceBrowser.
 */
- (void)adWillLeaveApplication:(nonnull id)ad;

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
- (void)          ad: (nonnull id<ANAdProtocol>)ad
  didReceiveAppEvent: (nonnull NSString *)name
            withData: (nonnull NSString *)data;

@end



