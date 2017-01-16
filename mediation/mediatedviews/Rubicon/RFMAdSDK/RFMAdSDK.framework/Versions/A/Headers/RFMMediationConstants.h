//
//  RFMMediationConstants.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 3/17/14.
//  Copyright © 2014 Rubicon Project. All rights reserved.
//

#ifndef RFMAdSDK_RFMMediationConstants_h
#define RFMAdSDK_RFMMediationConstants_h

#define kAdParamsAdFrameKey @"adFrame"
#define kAdParamsAdContentKey @"rspData"
#define kAdParamsCreativeApiKey @"creativeApiType"
#define kAdParamsBaseUrlKey @"adurl"
#define kAdParamsAdContentTypeKey @"adContentType"
#define kAdParamsClickUrlKey @"clickURL"
#define kAdParamsAdViewInfoKey @"adViewInfo"
#define kAdParamsAdRequestKey @"adRequest"
#define kAdParamsVastPlaybackKey @"vastPlayback"
#define kAdParamsAdPartnerTimeoutKey @"timeout"
#define kAdParamsResponseTimeoutKey @"responseTimeout"
#define kAdParamsCacheExpiryKey @"expiry"

#define kAdParamsNativeLayoutKey @"layout"
#define kAdParamsNativeAdChoicesImgUrlKey @"adChoicesImgUrl"
#define kAdParamsNativeAdChoicesOptOutUrlKey @"adChoicesOptUrl"

#define kAdParamsMediationExtensionKey @"ext"
#define kAdParamsId @"id"
#define kAdParamsName @"name"

#define kAdParamsVastSkipKey @"vastSkip"
#define kAdParamsVastSkipOffsetKey @"vastSkipOffset"

#define kAdParamsShowVideoCounterKey @"showVideoCounter"

#define kAdParamsAdPreCacheKey @"shouldPrecache"

#define AdViewInfoFullScreen @"fullScreen"
#define AdViewInfoSizePortraitWidth @"pwd"
#define AdViewInfoSizePortraitHeight @"pht"
#define AdViewInfoSizeLandscapeWidth @"lwd"
#define AdViewInfoSizeLandscapeHeight @"lht"

#define AdViewInfoShouldPrecache kAdParamsAdPreCacheKey

#define AdViewInfoCtInc @"ctInc"
#define AdviewInfoVastVideoPosition @"videopos"

#define kAdContentTypeHtml @"html"
#define kAdContentTypeJson @"json"
#define kAdContentTypeJavascript @"js"

/**
 * Mediation names
 */
#define kMediationTypeRfm @"rfm"
#define kMediationTypeMraid @"MRAID"
#define kMediationTypeRfmCaching @"cache"
#define kMediationTypeVast @"VAST"
#define kMediationTypePartner @"partner"
#define kMediationTypeNative @"native"

/**
 * Third-party mediation names
 */
#define kMediationTypeAdmob @"adm"
#define kMediationTypeDFP   @"dfp"
#define kMediationTypeiAd   @"iAd"

/**
 * Mediation class names
 */
#define kMediationClassNameRfm @"RFMMediator"
#define kMediationClassNameMraid @"RFMMraidMediator"
#define kMediationClassNameVast @"RFMVastMediator"
#define kMediationClassNamePartner @"RFMPartnerMediator"
#define kMediationClassNameNative @"RFMNativeMediator"

/**
 * Status enums for the AdView
 */
typedef NS_ENUM(NSUInteger, adLoadingStatusTypes) {
    /**
     * Ad has been initialized
     */
    AD_INIT = 0,
    
    /**
     * Banner has been requested
     */
    AD_BANNER_REQUESTED,
    
    /**
     * Banner has been displayed
     */
    AD_BANNER_DISPLAYED,
    
    /**
     * Landing view has been displayed
     */
    AD_LANDING_DISPLAYED,
    
    /**
     * Modal landing view has been displayed
     */
    AD_MODAL_LANDING_DISPLAYED,
    
    /**
     * Interstitial has been requested
     */
    AD_INTERSTITIAL_REQUESTED,
    
    /**
     * Interstitial has been displayed
     */
    AD_INTERSTITIAL_DISPLAYED,
    
    /**
     * Ad has been precached
     */
    AD_PRECACHED,
    
    /**
     * Ad is ready to display
     */
    AD_READY_TO_DISPLAY
};


#endif
