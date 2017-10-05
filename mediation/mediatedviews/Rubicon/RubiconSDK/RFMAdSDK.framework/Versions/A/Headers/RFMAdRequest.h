//
//  RFMAdRequest.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 3/13/14.
//  Copyright © 2014 Rubicon Project. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFMAdProtocols.h"

/**
 * Parameters to be passed to RFM Ad Server while fetching an ad.
 */

@interface RFMAdRequest : NSObject

/** @name Account Configuration */


/**
 Initialize request parameters
 
 Initializer to create an instance of RFMAdRequest and set the required placement parameters.
 
 @param adServer RFM Ad Server. See rfmAdServer
 @param appId RFM App ID. Use the App  ID for your RFM placement. See rfmAdAppId
 @param pubId RFM Publisher ID. Use the Account ID for your RFM placement. See rfmAdPublisherId.
 
 @return A new instance of RFMAdRequest
*/
-(id)initRequestWithServer:(NSString *)adServer
                   andAppId:(NSString *)appId
                   andPubId:(NSString *)pubId;
/**
  RFM Ad Server
 
  Required property for setting the ad server URL. Please note this value should end with a trailing '/'.
 
      Ex: "http://mrp.rubiconproject.com/"
 
 */
@property (nonatomic, strong) NSString *rfmAdServer;

/**
 RFM Publisher ID

 Required property for setting the publisher ID. Use the Account ID for your RFM placement.
 
     Ex: adRequest.rfmAdPublisherId = @"111008"
 
 */
@property (nonatomic, strong) NSString *rfmAdPublisherId;

/**
 RFM Application ID
 
 Required property for setting the application ID. Use the App  ID for your RFM placement.
 
     Ex: adRequest.rfmAppId = @"01573C50497A0130031B123139244773"
 
 */
@property (nonatomic, strong) NSString *rfmAdAppId;

/** @name Optional Targeting */

/**
 Optional key-value targeting information

 To improve the applicability of ads rendered to your application, you may provide optional targeting information with each ad request. Targeting in the REVV for Mobile SDK is enabled by a set of optional key-value pairs.

 You can pass your own custom key-value strings as targeting parameters by appending the following parameter with your ad request: **&NBA_KV=key1=value1,key2=value2,key3=value3. For example, &NBA_KV=cnty=napa,region=west**. The ad serving platform allows you to set up key-value targeting with the relationships "equals to, belongs to, does not belong to." To classify a key-value pair as one that is eligible for "greater than, less than" targeting or to set up your key parameters in an auto-fill drop-down menu in your account, please contact your account manager.
 
     Ex: adRequest.targetingInfo =  @{@“key1”:@“val1”,
	@“NBA_KV”:@“=cnty=napa,region=west”};
 
 *
 */
@property (nonatomic, strong) NSDictionary *targetingInfo;

/**
 Optional location targeting information - latitude
 
 If your application uses CoreLocation you can provide the current coordinates. Providing this information will help select better targeted ads and improve monetization
 
     Ex: adRequest.locationLatitude = myCLLocationManager.location.coordinate.latitude;
 *
 */
@property (assign) double locationLatitude;

/**
 Optional location targeting information - longitude
 
 If your application uses CoreLocation you can provide the current coordinates. Providing this information will help select better targeted ads and improve monetization
 
 Ex: adRequest.locationLongitude = myCLLocationManager.location.coordinate.longitude;
 *
 */
@property (assign) double locationLongitude;

//Optional : Set string @"ip" for allowing ip based location detection.
@property (nonatomic, strong) NSString *allowLocationDetectType;

/** @name Controlling Ad Types */
/**
 Force interstitial or banner only ads
 
 Use this to specify if the ad is banner or interstitial. Default settings are banner if RFMAdView has been created with [RFMAdView createAdWithDelegate:], [RFMAdView createAdOfFrame:withCenter:withDelegate:] and [RFMAdView createAdOfFrame:withPortraitCenter:withLandscapeCenter:withDelegate:]; and interstitial if RFMAdView has been created with [RFMAdView createInterstitialAdWithDelegate:] method
 
 Allowed values are provided in RFMAdConstants. Set **RFM_ADTYPE_BANNER** for banner and **RFM_ADTYPE_INTERSTITIAL** for interstitial ads.

 */
@property (nonatomic, retain) NSString *rfmAdType;

/**
 Force video only ads
  
 Set this value to YES if you want video only ads for this request, regardless of the placement setup.
 Default is set to NO, i.e. Ad Server will consider all ads as eligible for serving.
 *
 **Note** Setting this to YES might reduce the fill rate depending on the availability of video demand for your setup.
 */
@property (assign) BOOL fetchOnlyVideoAds;

/** @name Landing View Configuration */

/**
 Landing view transparency
 
 When the ad is in landing view mode, you can choose the transparency with which your background application is visible along the edges and corners of the landing view. The default value for this setting is 0.6. You can set it as an optional request parameter on the RFMAdRequest  instance for your placement.
 
 */
@property (assign) CGFloat landingViewAlpha;


/**
 Fastlane
 
 This is a readonly value that is set to YES by calling preFetchAdWithParams:
 Default is set to NO, i.e. this is not a fastlane request.
 @see [RFMFastLane preFetchAdWithParams:]
 */
@property (nonatomic, assign, readonly) BOOL isFastLane;

/** @name Test Settings */

/**
 Set test mode
 
 This optional RFMAdRequest parameter specifies the mode in which requests are handled. The current supported values are as follows –
 * "test" – Test Mode, impressions are not counted
 
     Ex: adRequest.rfmAdMode = @"test";

 @warning Please make sure you do not set this parameter for a live app as ad impressions will not be counted in test mode.
 
 */
@property (nonatomic, strong) NSString *rfmAdMode;

/**
 Request specific ad
 
 This optional RFMAdRequest parameter only renders a specific ad. This setting should only be implemented for test accounts while testing the performance of a particular ad. Do not set this value, or set it to @"0" if you want this setting to be ignored by the SDK
 
     Ex: adRequest.rfmAdTestId = @"20000";
 
 @warning Please make sure you do not set this parameter for a live app.
 
 */
@property (nonatomic, strong) NSString *rfmAdTestAdId;

/**
 * Cue point position enumerator property, valid values include RFMCuePointPositionPreRoll, RFMCuePointPositionMidRoll, or RFMCuePointPositionPostRoll.
 */
@property (nonatomic, assign) RFMCuePointPosition cuePointPosition;

#pragma mark - Deprecated

/**
  Enable debug logs
 
  This optional RFMAdRequest parameter allows publishers to enable/disable debug console logs from RFM SDK. The default setting is to not print any RFM logs on console.

     Ex: adRequst.showDebugLogs = YES;
 
 @see [RFMAdSDK setLogLevel:]
 @warning Deprecated in RFM iOS SDK 3.2.0. Use [RFMAdSDK setLogLevel:] instead

*/
@property (assign) BOOL showDebugLogs DEPRECATED_ATTRIBUTE;

@end
