/*   Copyright 2015 APPNEXUS INC
 
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

#import "ANUniversalTagAdServerResponse.h"
#import "ANNativeAdResponse.h"
#import "ANLogging.h"
#import "ANMediatedAd.h"
#import "ANSSMStandardAd.h"
#import "ANSSMVideoAd.h"
#import "ANRTBVideoAd.h"
#import "ANCSMVideoAd.h"
#import "ANStandardAd.h"
#import "ANAdConstants.h"
#import "ANNativeStandardAdResponse.h"
#import "ANNativeAdResponse+PrivateMethods.h"
#import "ANAdResponseInfo.h"
#import "ANGlobal.h"
#import "ANAdConstants.h"
#import "ANDSAResponseInfo.h"

#if !APPNEXUS_NATIVE_MACOS_SDK
#import "ANCSRAd.h"
#endif
#import "XandrAd.h"


#pragma mark - Public constants.

NSString *const  kANUniversalTagAdServerResponseKeyAdsTagId    = @"tag_id";
NSString *const  kANUniversalTagAdServerResponseKeyAdsAuctionId    = @"auction_id";
NSString *const  kANUniversalTagAdServerResponseKeyNoBid       = @"nobid";
NSString *const  kANUniversalTagAdServerResponseKeyTagNoAdUrl  = @"no_ad_url";
NSString *const  kANUniversalTagAdServerResponseKeyTagUUID     = @"uuid";



#pragma mark - Private constants.

static NSString *const kANUniversalTagAdServerResponseKeyTags = @"tags";

static NSString *const  kANUniversalTagAdServerResponseKeyTagAds      = @"ads";
static NSString *const  kANUniversalTagAdServerResponseKeyTagNoBid    = @"tagReceivedNoBid";

static NSString *const kANUniversalTagAdServerResponseKeyAdsContentSource = @"content_source";
static NSString *const kANUniversalTagAdServerResponseKeyAdsAdType = @"ad_type";
static NSString *const kANUniversalTagAdServerResponseKeyAdsCreativeId = @"creative_id";
static NSString *const kANUniversalTagAdServerResponseKeyAdsRendererUrl = @"renderer_url";
static NSString *const kANUniversalTagAdServerResponseKeyAdsBuyerMemberId = @"buyer_member_id";


static NSString *const kANUniversalTagAdServerResponseKeyAdsCPM = @"cpm";
static NSString *const kANUniversalTagAdServerResponseKeyAdsCPMPublisherCurrency = @"cpm_publisher_currency";
static NSString *const kANUniversalTagAdServerResponseKeyAdsPublisherCurrencyCode = @"publisher_currency_code";

// DSA
static NSString *const kANUniversalTagAdServerResponseKeyAdsDSA = @"dsa";

static NSString *const kANUniversalTagAdServerResponseKeyAdsCSMObject = @"csm";
static NSString *const kANUniversalTagAdServerResponseKeyAdsSSMObject = @"ssm";
static NSString *const kANUniversalTagAdServerResponseKeyAdsRTBObject = @"rtb";
static NSString *const kANUniversalTagAdServerResponseKeyAdsNotifyUrl = @"notify_url";

// viewability
static NSString *const kANUniversalTagAdServerResponseKeyViewabilityObject = @"viewability";

// Video
static NSString *const kANUniversalTagAdServerResponseKeyVideoObject = @"video";
static NSString *const kANUniversalTagAdServerResponseKeyVideoContent = @"content";
static NSString *const kANUniversalTagAdServerResponseKeyVideoAssetURL = @"asset_url";
static NSString *const kANUniversalTagAdServerResponseKeyVideoPlayerWidth = @"player_width";
static NSString *const kANUniversalTagAdServerResponseKeyVideoPlayerHeight = @"player_height";

// Banner
static NSString *const kANUniversalTagAdServerResponseKeyBannerObject = @"banner";
static NSString *const kANUniversalTagAdServerResponseKeyBannerWidth = @"width";
static NSString *const kANUniversalTagAdServerResponseKeyBannerHeight = @"height";
static NSString *const kANUniversalTagAdServerResponseKeyBannerContent = @"content";

static NSString *const kANUniversalTagAdServerResponseMraidJSFilename = @"mraid.js";

// SSM
static NSString *const kANUniversalTagAdServerResponseKeySSMHandlerUrl = @"url";

// CSM
static NSString *const kANUniversalTagAdServerResponseValueIOS = @"ios";
static NSString *const kANUniversalTagAdServerResponseKeyTimeout= @"timeout_ms";
static NSString *const kANUniversalTagAdServerResponseKeyHandler = @"handler";
static NSString *const kANUniversalTagAdServerResponseKeyClass = @"class";
static NSString *const kANUniversalTagAdServerResponseKeyId = @"id";
static NSString *const kANUniversalTagAdServerResponseKeyParam = @"param";
static NSString *const kANUniversalTagAdServerResponseKeyResponseURL = @"response_url";
static NSString *const kANUniversalTagAdServerResponseKeyType = @"type";
static NSString *const kANUniversalTagAdServerResponseKeyWidth = @"width";
static NSString *const kANUniversalTagAdServerResponseKeyHeight = @"height";

//CSR
static NSString *const kANUniversalTagAdServerResponseKeyAdsCSRObject = @"csr";
static NSString *const kANUniversalTagAdServerResponseKeyPayload = @"payload";
static NSString *const kANUniversalTagAdServerResponseKeyTrackersClick_urls = @"click_urls";

static NSString *const kANUniversalTagAdServerResponseKeySecondPrice = @"second_price";
static NSString *const kANUniversalTagAdServerResponseKeyOptimized = @"optimized";

// Native
static NSString *const kANUniversalTagAdServerResponseKeyNativeObject = @"native";

static NSString *const kANUniversalTagAdServerResponseKeyNativeMediaType = @"type";
static NSString *const kANUniversalTagAdServerResponseKeyNativeTitle = @"title";
static NSString *const kANUniversalTagAdServerResponseKeyNativeDescription = @"desc";
static NSString *const kANUniversalTagAdServerResponseKeyNativeMainMedia = @"main_img";
static NSString *const kANUniversalTagAdServerResponseKeyNativeIcon = @"icon";

static NSString *const kANUniversalTagAdServerResponseKeyNativeURL = @"url";
static NSString *const kANUniversalTagAdServerResponseKeyNativeCallToAction = @"ctatext";
static NSString *const kANUniversalTagAdServerResponseKeyNativeClickTrackArray = @"click_trackers";
static NSString *const kANUniversalTagAdServerResponseKeyNativeImpTrackArray = @"impression_trackers";
static NSString *const kANUniversalTagAdServerResponseKeyNativeLink = @"link";
static NSString *const kANUniversalTagAdServerResponseKeyNativeJavascriptTrackers = @"javascript_trackers";
static NSString *const kANUniversalTagAdServerResponseKeyNativeClickUrl = @"click_url";
static NSString *const kANUniversalTagAdServerResponseKeyNativeClickFallbackUrl = @"fallback_url";
static NSString *const kANUniversalTagAdServerResponseKeyNativeRatingDict = @"rating";
static NSString *const kANUniversalTagAdServerResponseKeyNativeRatingValue = @"value";
static NSString *const kANUniversalTagAdServerResponseKeyNativeRatingScale = @"scale";
static NSString *const kANUniversalTagAdServerResponseKeyNativeCustomKeywordsDict = @"custom";
static NSString *const kANUniversalTagAdServerResponseKeyNativeSponsoredBy = @"sponsored";
static NSString *const kANUniversalTagAdServerResponseKeyNativeAdditionalDescription = @"desc2";
static NSString *const kANUniversalTagAdServerResponseKeyNativeVideo = @"video";
static NSString *const kANUniversalTagAdServerResponseKeyNativeVideoContent = @"content";
static NSString *const kANUniversalTagAdServerResponseKeyNativePrivacyLink = @"privacy_link";

// Trackers
static NSString *const kANUniversalTagAdServerResponseKeyTrackers = @"trackers";

static NSString *const kANUniversalTagAdServerResponseKeyTrackersImpressionUrls = @"impression_urls";
static NSString *const kANUniversalTagAdServerResponseKeyTrackersErrorUrls = @"error_urls";
static NSString *const kANUniversalTagAdServerResponseKeyTrackersVideoClickUrls = @"video_click_urls";
static NSString *const kANUniversalTagAdServerResponseKeyTrackersVideoEvents = @"video_events";

static NSString *const kANUniversalTagAdServerResponseKeyVideoEventsStartUrls = @"start";
static NSString *const kANUniversalTagAdServerResponseKeyVideoEventsSkipUrls = @"skip";
static NSString *const kANUniversalTagAdServerResponseKeyVideoEventsFirstQuartileUrls = @"firstQuartile";
static NSString *const kANUniversalTagAdServerResponseKeyVideoEventsMidpointUrls = @"midpoint";
static NSString *const kANUniversalTagAdServerResponseKeyVideoEventsThirdQuartileUrls = @"thirdQuartile";
static NSString *const kANUniversalTagAdServerResponseKeyVideoEventsCompleteUrls = @"complete";



#pragma mark -

@implementation ANUniversalTagAdServerResponse

#pragma mark Inject creative content.

+ (nullable ANRTBVideoAd *)generateRTBVideoAdUnitFromVASTObject: (nonnull NSString *)vastContent
                                                          width: (NSInteger)width
                                                         height: (NSInteger)height
{
    ANRTBVideoAd  *rtbVideoAd  = [[ANRTBVideoAd alloc] init];
    if (!rtbVideoAd)  { return nil; }
    
    rtbVideoAd.width    = [NSString stringWithFormat:@"%ld", (long)width];
    rtbVideoAd.height   = [NSString stringWithFormat:@"%ld", (long)height];
    rtbVideoAd.content  = vastContent;

    return  rtbVideoAd;
}


+ (nullable ANStandardAd *)generateStandardAdUnitFromHTMLContent: (nonnull NSString *)htmlContent
                                                           width: (NSInteger)width
                                                          height: (NSInteger)height
{
    ANStandardAd  *standardAd  = [[ANStandardAd alloc] init];
    if (!standardAd)  { return nil; }
    
    standardAd.width    = [NSString stringWithFormat:@"%ld", (long)width];
    standardAd.height   = [NSString stringWithFormat:@"%ld", (long)height];
    standardAd.content  = htmlContent;

    return  standardAd;
}




#pragma mark - Universal Tag Support

+ (nullable NSArray<NSDictionary<NSString *, id> *> *)generateTagsFromResponseData:(nullable NSData *)data
{
    if (!data) {
        ANLogError(@"data is UNDEFINED.");
        return  nil;
    }

    NSDictionary<NSString *, id>  *jsonResponse  = [[self class] generateDictionaryFromJSONResponse:data];

    if (!jsonResponse) {
        ANLogError(@"FAILED to acquire JSON response from data.");
        return  nil;
    }

    ANLogDebug(@"jsonResponse=%@", [jsonResponse description]);

    if (! [jsonResponse[kANUniversalTagAdServerResponseKeyTags] isKindOfClass:[NSArray class]]) {
        ANLogError(@"FAILED to find an array of tags in UT Reponse data.");
        return  nil;
    }

    //
    NSArray<NSString *>                             *initialAdsArray   = (NSArray<NSString *> *)jsonResponse[kANUniversalTagAdServerResponseKeyTags];
    NSMutableArray<NSDictionary<NSString *, id> *>  *validtedAdsArray  = [[NSMutableArray<NSDictionary<NSString *, id> *> alloc] initWithCapacity:[initialAdsArray count]];

    [initialAdsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [validtedAdsArray addObject:obj];
            }
        } ];

    if (validtedAdsArray.count) {
        return [validtedAdsArray copy];
    }

    return nil;
}



+ (nonnull NSMutableArray<id> *)generateAdObjectInstanceFromJSONAdServerResponseTag:(nonnull NSDictionary<NSString *, id> *)tag
{
    NSArray             *arrayOfJSONAdObjects   = [[self class] adsArrayFromTag:tag];
    NSMutableArray<id>  *arrayOfAdUnits         = [[NSMutableArray<id> alloc] init];


    for (id adObject in arrayOfJSONAdObjects)
    {
        if (![adObject isKindOfClass:[NSDictionary class]]) {
            continue;
        }

        NSString  *contentSource  = [adObject[kANUniversalTagAdServerResponseKeyAdsContentSource] description];
        NSString  *adType         = [adObject[kANUniversalTagAdServerResponseKeyAdsAdType] description];
        NSString  *creativeId     = @"";

        if (adObject[kANUniversalTagAdServerResponseKeyAdsCreativeId] != nil)
        {
            creativeId  = [NSString stringWithFormat:@"%@",adObject[kANUniversalTagAdServerResponseKeyAdsCreativeId]];
        }

        if (!contentSource && !adType) {
            ANLogError(@"Response from ad server in an unexpected format content_source/ad_type UNDEFINED.  (adObject=%@)", adObject);
            continue;
        }
        
        NSString *placementId  = @"";
         if(tag[kANUniversalTagAdServerResponseKeyAdsTagId] != nil)
         {
             placementId  = [NSString stringWithFormat:@"%@",tag[kANUniversalTagAdServerResponseKeyAdsTagId]];
         }
         NSInteger memberId  = 0;
         if(adObject[kANUniversalTagAdServerResponseKeyAdsBuyerMemberId] != nil)
         {
           memberId  = [[NSString stringWithFormat:@"%@",adObject[kANUniversalTagAdServerResponseKeyAdsBuyerMemberId]] integerValue];
         }
        
        NSNumber *cpm  = @0.0;
        if(adObject[kANUniversalTagAdServerResponseKeyAdsCPM] != nil)
        {
            cpm  = [NSNumber numberWithFloat:[adObject[kANUniversalTagAdServerResponseKeyAdsCPM] floatValue]];
        }
        
        NSNumber *cpmPublisherCurrency  = @0.0;
        if(adObject[kANUniversalTagAdServerResponseKeyAdsCPMPublisherCurrency] != nil)
        {
            cpmPublisherCurrency  = [NSNumber numberWithFloat:[adObject[kANUniversalTagAdServerResponseKeyAdsCPMPublisherCurrency] floatValue]];
        }
        
        NSString *publisherCurrencyCode  = @"";
        if(adObject[kANUniversalTagAdServerResponseKeyAdsPublisherCurrencyCode] != nil)
        {
            publisherCurrencyCode  = [NSString stringWithFormat:@"%@",adObject[kANUniversalTagAdServerResponseKeyAdsPublisherCurrencyCode]];
        }
         
        
        NSString *auctionId  = @"";
        if(tag[kANUniversalTagAdServerResponseKeyAdsAuctionId] != nil)
        {
            auctionId  = [NSString stringWithFormat:@"%@",tag[kANUniversalTagAdServerResponseKeyAdsAuctionId]];
        }
        
        NSDictionary *dsaObject = adObject[kANUniversalTagAdServerResponseKeyAdsDSA];
         
         //Initialise AdResponse object to expose all the public facing APIs from the UTv3 response
         ANAdResponseInfo *adResponseInfo = [[ANAdResponseInfo alloc] init];
         adResponseInfo.creativeId = creativeId;
         adResponseInfo.placementId = placementId;
         adResponseInfo.adType = [ANGlobal adTypeStringToEnum:adType];
         adResponseInfo.contentSource = contentSource;
         adResponseInfo.memberId = memberId;
         adResponseInfo.auctionId = auctionId;
         adResponseInfo.cpm = cpm;
         adResponseInfo.cpmPublisherCurrency = cpmPublisherCurrency;
         adResponseInfo.publisherCurrencyCode = publisherCurrencyCode;
         adResponseInfo.publisherCurrencyCode = publisherCurrencyCode;
         adResponseInfo.dsaResponseInfo = [ANDSAResponseInfo dsaObjectFromAdObject: dsaObject];
        
#if !APPNEXUS_NATIVE_MACOS_SDK
        ANVerificationScriptResource *omidVerificationScriptResource;
        if([adType isEqualToString:kANUniversalTagAdServerResponseKeyNativeObject]){
            // Parsing viewability object to create measurement resources for OMID Native integration
            omidVerificationScriptResource = [[self class] anVerificationScriptFromAdObject:adObject];
        }
#endif

        // RTB
        if ([contentSource isEqualToString:kANUniversalTagAdServerResponseKeyAdsRTBObject])
        {
            NSDictionary  *rtbObject  = [[self class] rtbObjectFromAdObject:adObject];

            if (rtbObject) {
                // RTB Banner / Interstitial
                if ([adType isEqualToString:kANUniversalTagAdServerResponseKeyBannerObject]) {
                    ANStandardAd *standardAd = [[self class] standardAdFromRTBObject:rtbObject];
                    if (standardAd) {
                        standardAd.creativeId = creativeId;
                        [arrayOfAdUnits addObject:standardAd];
                    }

                // RTB - Video
                } else if([adType isEqualToString:kANUniversalTagAdServerResponseKeyVideoObject]){
                    ANRTBVideoAd *videoAd = [[self class] videoAdFromRTBObject:rtbObject];
                    if (videoAd) {
                        videoAd.creativeId = creativeId;
                        videoAd.notifyUrlString = [adObject[kANUniversalTagAdServerResponseKeyAdsNotifyUrl] description];

                        [arrayOfAdUnits addObject:videoAd];
                    }
                // RTB - Native
                } else if([adType isEqualToString:kANUniversalTagAdServerResponseKeyNativeObject]) {
                    ANNativeStandardAdResponse  *nativeAd  = [[self class] nativeAdFromRTBObject:rtbObject];
                    if (nativeAd) {
                        nativeAd.creativeId = creativeId;
                        nativeAd.adResponseInfo = adResponseInfo;
                        // Set Impression Type for NativeAd
                        if([XandrAd.sharedInstance isEligibleForViewableImpression:adResponseInfo.memberId]){
                            nativeAd.impressionType = ANViewableImpression;
                        }
                        if(adObject[kANUniversalTagAdServerResponseKeyAdsRendererUrl] != nil)
                        {
                        NSString * nativeRenderingUrl  = [NSString stringWithFormat:@"%@",adObject[kANUniversalTagAdServerResponseKeyAdsRendererUrl]];
                        NSString *nativeRenderingElements  =  [[self class] nativeRenderingJSON:rtbObject];
                         if(nativeRenderingUrl && nativeRenderingElements){
                            nativeAd.nativeRenderingObject =nativeRenderingElements;
                            nativeAd.nativeRenderingUrl = nativeRenderingUrl;
                         }
                        }
                    #if !APPNEXUS_NATIVE_MACOS_SDK
                        // Parsing viewability object to create measurement resources for OMID Native integration
                        if(omidVerificationScriptResource != nil){
                            nativeAd.verificationScriptResource = omidVerificationScriptResource;
                        }
                    #endif
                        [arrayOfAdUnits addObject:nativeAd];
                    }

                } else {
                    ANLogError(@"UNRECOGNIZED AD_TYPE in RTB.  (adType=%@  rtbObject=%@)", adType, rtbObject);
                }
            }


        // CSM
        } else if([contentSource isEqualToString:kANUniversalTagAdServerResponseKeyAdsCSMObject]){
            if([adType isEqualToString:kANUniversalTagAdServerResponseKeyBannerObject] || [adType isEqualToString:kANUniversalTagAdServerResponseKeyNativeObject]){
                NSDictionary *csmObject = [[self class] csmObjectFromAdObject:adObject];
                if (csmObject) {
                    ANMediatedAd *mediatedAd = [[self class] mediatedAdFromCSMObject:csmObject];
                    if (mediatedAd) {
                        if ([adType isEqualToString:kANUniversalTagAdServerResponseKeyNativeObject]) {
                            mediatedAd.isAdTypeNative = YES;
                            // Parsing viewability object to create measurement resources for OMID Native integration
#if !APPNEXUS_NATIVE_MACOS_SDK

                            if(omidVerificationScriptResource != nil){
                                mediatedAd.verificationScriptResource = omidVerificationScriptResource;
                            }
#endif

                        }

                        mediatedAd.creativeId = creativeId;
                        if (mediatedAd.className.length > 0) {
                            adResponseInfo.networkName = mediatedAd.className;
                            [arrayOfAdUnits addObject:mediatedAd];
                        }
                    }
                }
            } else if([adType isEqualToString:kANUniversalTagAdServerResponseKeyVideoObject]) {
                ANCSMVideoAd *csmVideoAd = [[self class] videoCSMAdFromCSMObject:adObject withTagObject:tag];
                if(csmVideoAd){
                    [arrayOfAdUnits addObject:csmVideoAd];
                }
            }else{
                ANLogError(@"UNRECOGNIZED AD_TYPE in CSM.  (adObject=%@)", adObject);
            }
        // CSR - Only for Facebook Native Banner is supported by CSR
        }else if([contentSource isEqualToString:kANUniversalTagAdServerResponseKeyAdsCSRObject]){
            if([adType isEqualToString:kANUniversalTagAdServerResponseKeyNativeObject]){
              
            #if !APPNEXUS_NATIVE_MACOS_SDK
                            NSDictionary *csrObject = [[self class] csrObjectFromAdObject:adObject];
                            if (csrObject) {
                                ANCSRAd *csrAd = [[self class] mediatedAdFromCSRObject:csrObject];
                                if (csrAd) {
                                    // Parsing viewability object to create measurement resources for OMID Native integration
                                    if(omidVerificationScriptResource != nil){
                                        csrAd.verificationScriptResource = omidVerificationScriptResource;
                                    }
                                    csrAd.creativeId = creativeId;
                                    adResponseInfo.networkName = csrAd.className;
                                    [arrayOfAdUnits addObject:csrAd];
                                }
                            }
            #endif
                
            }else{
                ANLogError(@"UNRECOGNIZED AD_TYPE in CSR.  (adObject=%@)", adObject);
            }
        // SSM - Only Banner and Interstitial are supported in SSM
        } else if([contentSource isEqualToString:kANUniversalTagAdServerResponseKeyAdsSSMObject]){
            if([adType isEqualToString:kANUniversalTagAdServerResponseKeyBannerObject]){
                NSDictionary *ssmObject = [[self class] ssmObjectFromAdObject:adObject];
                if (ssmObject) {
                    ANSSMStandardAd *ssmStandardAd = [[self class] standardSSMAdFromSSMObject:ssmObject];
                    if (ssmStandardAd) {
                        ssmStandardAd.creativeId = creativeId;
                        [arrayOfAdUnits addObject:ssmStandardAd];
                    }
                }
            }else{
                ANLogError(@"UNRECOGNIZED AD_TYPE in SSM.  (adObject=%@)", adObject);
            }
        }else{
            ANLogError(@"UNRECOGNIZED adObject.  (adObject=%@)", adObject);
        }


        // Store general attributes of UT Response into select ad objects.
        //
        id  lastAdsObject  = [arrayOfAdUnits lastObject];

        if ([lastAdsObject isKindOfClass:[ANBaseAdObject class]]) {
            ANBaseAdObject  *baseAdObject  = (ANBaseAdObject *)lastAdsObject;
            baseAdObject.adType = [adType copy];
            baseAdObject.adResponseInfo = adResponseInfo;
            // Set Impression Type for this AdObject
            if([XandrAd.sharedInstance isEligibleForViewableImpression:adResponseInfo.memberId]){
                baseAdObject.impressionType = ANViewableImpression;
            }
        }
    }


    //
    return  [arrayOfAdUnits mutableCopy];
}

+ (NSArray *)adsArrayFromTag:(NSDictionary *)tag {
    if ([tag[kANUniversalTagAdServerResponseKeyTagAds] isKindOfClass:[NSArray class]]) {
        return tag[kANUniversalTagAdServerResponseKeyTagAds];
    }else{
        ANLogError(@"Response from ad server in an unexpected format no ads array found in tag: %@", tag);
        return nil;
    }
}
#if !APPNEXUS_NATIVE_MACOS_SDK
+ (ANVerificationScriptResource *)anVerificationScriptFromAdObject:(NSDictionary *)adObject {
    if ([adObject[kANUniversalTagAdServerResponseKeyViewabilityObject] isKindOfClass:[NSDictionary class]]) {
        NSDictionary  *viewabilityObject  = adObject[kANUniversalTagAdServerResponseKeyViewabilityObject];
        ANVerificationScriptResource *verificationScriptResource = [[ANVerificationScriptResource alloc] init];
        [verificationScriptResource anVerificationScriptResource:viewabilityObject];
        return verificationScriptResource;
    }else{
        ANLogError(@"Response from ad server in an unexpected format. Expected Viewability in adObject: %@", adObject);
        return nil;
    }
}
#endif

+ (NSDictionary *)rtbObjectFromAdObject:(NSDictionary *)adObject {
    if ([adObject[kANUniversalTagAdServerResponseKeyAdsRTBObject] isKindOfClass:[NSDictionary class]]) {
        return adObject[kANUniversalTagAdServerResponseKeyAdsRTBObject];
    }else{
        ANLogError(@"Response from ad server in an unexpected format. Expected RTB in adObject: %@", adObject);
        return nil;
    }
}

+ (NSDictionary *)csmObjectFromAdObject:(NSDictionary *)adObject {
    if ([adObject[kANUniversalTagAdServerResponseKeyAdsCSMObject] isKindOfClass:[NSDictionary class]]) {
        return adObject[kANUniversalTagAdServerResponseKeyAdsCSMObject];
    }else{
        ANLogError(@"Response from ad server in an unexpected format. Expected CSM in adObject: %@", adObject);
        return nil;
    }
}

+ (NSDictionary *)ssmObjectFromAdObject:(NSDictionary *)adObject {
    if ([adObject[kANUniversalTagAdServerResponseKeyAdsSSMObject] isKindOfClass:[NSDictionary class]]) {
        return adObject[kANUniversalTagAdServerResponseKeyAdsSSMObject];
    }else{
        ANLogError(@"Response from ad server in an unexpected format. Expected SSM in rtbObject: %@", adObject);
        return nil;
    }
}


+ (NSDictionary *)csrObjectFromAdObject:(NSDictionary *)adObject {
    if ([adObject[kANUniversalTagAdServerResponseKeyAdsCSRObject] isKindOfClass:[NSDictionary class]]) {
        return adObject[kANUniversalTagAdServerResponseKeyAdsCSRObject];
    }else{
        ANLogError(@"Response from ad server in an unexpected format. Expected CSR in adObject: %@", adObject);
        return nil;
    }
}

+ (ANStandardAd *)standardAdFromRTBObject:(NSDictionary *)rtbObject
{
    if ([rtbObject[kANUniversalTagAdServerResponseKeyBannerObject] isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *banner = rtbObject[kANUniversalTagAdServerResponseKeyBannerObject];
        ANStandardAd *standardAd = [[ANStandardAd alloc] init];
        
        standardAd.width = [banner[kANUniversalTagAdServerResponseKeyBannerWidth] description];
        standardAd.height = [banner[kANUniversalTagAdServerResponseKeyBannerHeight] description];
        standardAd.content = [banner[kANUniversalTagAdServerResponseKeyBannerContent] description];
        standardAd.impressionUrls = [[self class] impressionUrlsFromContentSourceObject:rtbObject];
        
        if (!standardAd.content || [standardAd.content length] == 0) {
            ANLogError(@"blank_ad");
            return nil;
        }
        
        NSRange mraidJSRange = [standardAd.content rangeOfString:kANUniversalTagAdServerResponseMraidJSFilename];
        if (mraidJSRange.location != NSNotFound) {
            standardAd.mraid = YES;
        }
        return standardAd;
    }else{
        ANLogError(@"Response from ad server in an unexpected format. Expected RTB Banner in rtbObject: %@", rtbObject);
        return nil;
    }
}

+ (ANRTBVideoAd *)videoAdFromRTBObject:(NSDictionary *)rtbObject
{
    if (! [rtbObject[kANUniversalTagAdServerResponseKeyVideoObject] isKindOfClass:[NSDictionary class]])
    {
        ANLogError(@"Response from ad server in an unexpected format.  Expected RTB Video in rtbObject: %@", rtbObject);
        return nil;
    }

    NSDictionary  *videoAdObjectDictionary  = rtbObject[kANUniversalTagAdServerResponseKeyVideoObject];
    ANRTBVideoAd  *videoAd                  = [[ANRTBVideoAd alloc] init];

    videoAd.content   = [videoAdObjectDictionary[kANUniversalTagAdServerResponseKeyVideoContent] description];
    videoAd.assetURL  = [videoAdObjectDictionary[kANUniversalTagAdServerResponseKeyVideoAssetURL] description];
    videoAd.width     = [videoAdObjectDictionary[kANUniversalTagAdServerResponseKeyVideoPlayerWidth] description];
    videoAd.height    = [videoAdObjectDictionary[kANUniversalTagAdServerResponseKeyVideoPlayerHeight ] description];

    return videoAd;
}


+ (ANMediatedAd *)mediatedAdFromCSMObject:(NSDictionary *)csmObject
{
    if ([csmObject[kANUniversalTagAdServerResponseKeyHandler] isKindOfClass:[NSArray class]])
    {
        ANMediatedAd  *mediatedAd    = nil;
        NSArray       *handlerArray  = (NSArray *)csmObject[kANUniversalTagAdServerResponseKeyHandler];
        
        for (id handlerObject in handlerArray)
        {
            if ([handlerObject isKindOfClass:[NSDictionary class]])
            {
                NSDictionary  *handlerDict  = (NSDictionary *)handlerObject;
                NSString      *type         = [handlerDict[kANUniversalTagAdServerResponseKeyType] description];
                
                if ([type.lowercaseString isEqualToString:kANUniversalTagAdServerResponseValueIOS])
                {
                    NSString *className = [handlerDict[kANUniversalTagAdServerResponseKeyClass] description];
                    if ([className length] == 0) {
                        return nil;
                    }
                    
                    mediatedAd = [[ANMediatedAd alloc] init];
                    
                    mediatedAd.className  = className;
                    mediatedAd.param      = [handlerDict[kANUniversalTagAdServerResponseKeyParam] description];
                    mediatedAd.width      = [handlerDict[kANUniversalTagAdServerResponseKeyWidth] description];
                    mediatedAd.height     = [handlerDict[kANUniversalTagAdServerResponseKeyHeight] description];
                    mediatedAd.adId       = [handlerDict[kANUniversalTagAdServerResponseKeyId] description];

                    ANLogDebug(@"adId = %@", mediatedAd.adId);

                    //NB  mediatedAd.secondPrice = nil when Second Price auction is not being used.
                    //    Otherwise, this value contains the value of the Second Price in fractional units, represented as a string.
                    //    (Eg: US$ one dollar and fifty cents == @"1.50")
                    //
                    NSString  *secondPrice  = [handlerDict[kANUniversalTagAdServerResponseKeySecondPrice] description];

                    if ([secondPrice length] > 0)
                    {
                        NSMutableDictionary  *paramDict  = [[[self class]
                                                                 generateDictionaryFromJSONResponse:[mediatedAd.param dataUsingEncoding:NSUTF8StringEncoding]
                                                             ] mutableCopy ];

                        if (paramDict[kANUniversalTagAdServerResponseKeyOptimized])
                        {
                            [paramDict setObject:secondPrice forKey:kANUniversalTagAdServerResponseKeySecondPrice];

                            if ([NSJSONSerialization isValidJSONObject:paramDict]) {
                                NSData  *jsonData  = [NSJSONSerialization dataWithJSONObject:paramDict options:0 error:nil];
                                mediatedAd.param = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            }
                        }
                    }

                    break;
                    
                } else {
                    ANLogError(@"UNRECOGNIZED CSM type.  (%@)", type);
                }
            }
        } //endfor -- handlerObject
        
        if (mediatedAd)
        {
            mediatedAd.responseURL     = [csmObject[kANUniversalTagAdServerResponseKeyResponseURL] description];
            mediatedAd.impressionUrls  = [[self class] impressionUrlsFromContentSourceObject:csmObject];
            int timeout = [csmObject[kANUniversalTagAdServerResponseKeyTimeout] intValue];
            mediatedAd.networkTimeout = (timeout > 0 && timeout != 500) ? timeout :kAppNexusMediationNetworkTimeoutInterval * 1000;
            return  mediatedAd;
        }
    }
    ANLogError(@"Response from ad server in an unexpected format. Expected CSM in csmObject: %@", csmObject);
    return nil;
}

+(ANCSMVideoAd *)videoCSMAdFromCSMObject:(id) csmObject withTagObject:(NSDictionary *)tagDictionary{
    NSMutableDictionary *newTagDictionary = [NSMutableDictionary dictionaryWithDictionary:tagDictionary];
    NSMutableDictionary *csmObjectDictionary = [NSMutableDictionary dictionaryWithDictionary:csmObject];
    newTagDictionary[@"uuid"] = [NSString stringWithFormat:@"%@",  @(arc4random_uniform(65536))];
    newTagDictionary[@"ads"] = @[csmObjectDictionary];
    ANCSMVideoAd *videoAd = [[ANCSMVideoAd alloc] init];
    videoAd.adDictionary = newTagDictionary;
    return videoAd;
}

+ (ANSSMStandardAd *)standardSSMAdFromSSMObject:(NSDictionary *)ssmObject {
    if ([ssmObject[kANUniversalTagAdServerResponseKeyBannerObject] isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *banner = ssmObject[kANUniversalTagAdServerResponseKeyBannerObject];
        
        if ([ssmObject[kANUniversalTagAdServerResponseKeyHandler] isKindOfClass:[NSArray class]])
        {
            NSArray *handlerArray = (NSArray *)ssmObject[kANUniversalTagAdServerResponseKeyHandler];
            
            if ([[handlerArray firstObject] isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *handlerDict = (NSDictionary *)[handlerArray firstObject];
                
                ANSSMStandardAd *standardAd = [[ANSSMStandardAd alloc] init];
                standardAd.urlString = handlerDict[kANUniversalTagAdServerResponseKeySSMHandlerUrl];
                standardAd.responseURL        = [ssmObject[kANUniversalTagAdServerResponseKeyResponseURL] description];
                standardAd.impressionUrls = [[self class] impressionUrlsFromContentSourceObject:ssmObject];
                standardAd.width = [banner[kANUniversalTagAdServerResponseKeyBannerWidth] description];
                standardAd.height = [banner[kANUniversalTagAdServerResponseKeyBannerHeight] description];
                standardAd.content = nil;
                int timeout = [ssmObject[kANUniversalTagAdServerResponseKeyTimeout] intValue];
                standardAd.networkTimeout = (timeout > 0 && timeout != 500) ? timeout :kAppNexusMediationNetworkTimeoutInterval * 1000;
                return standardAd;
            }
        }
    }
    ANLogError(@"Response from ad server in an unexpected format. Unable to find SSM Banner in ssmObject: %@", ssmObject);
    return nil;
}
#if !APPNEXUS_NATIVE_MACOS_SDK
+ (ANCSRAd *)mediatedAdFromCSRObject:(NSDictionary *)csrObject
{
    if ([csrObject[kANUniversalTagAdServerResponseKeyHandler] isKindOfClass:[NSArray class]])
    {
        ANCSRAd  *csrAd    = nil;
        NSArray       *handlerArray  = (NSArray *)csrObject[kANUniversalTagAdServerResponseKeyHandler];

        for (id handlerObject in handlerArray)
        {
            if ([handlerObject isKindOfClass:[NSDictionary class]])
            {
                NSDictionary  *handlerDict  = (NSDictionary *)handlerObject;
                NSString      *type         = [handlerDict[kANUniversalTagAdServerResponseKeyType] description];

                if ([type.lowercaseString isEqualToString:kANUniversalTagAdServerResponseValueIOS])
                {
                    NSString *className = [handlerDict[kANUniversalTagAdServerResponseKeyClass] description];
                    if ([className length] == 0) {
                        return nil;
                    }
                    csrAd = [[ANCSRAd alloc] init];
                    csrAd.className  = className;
                    csrAd.payload      = [handlerDict[kANUniversalTagAdServerResponseKeyPayload] description];
                    csrAd.width      = [handlerDict[kANUniversalTagAdServerResponseKeyWidth] description];
                    csrAd.height     = [handlerDict[kANUniversalTagAdServerResponseKeyHeight] description];
                    break;

                } else {
                    ANLogError(@"UNRECOGNIZED CSR type.  (%@)", type);
                }
            }
        } //endfor -- handlerObject

        if (csrAd)
        {
            csrAd.responseURL     = [csrObject[kANUniversalTagAdServerResponseKeyResponseURL] description];
            csrAd.impressionUrls  = [[self class] impressionUrlsFromContentSourceObject:csrObject];
            csrAd.clickUrls  = [[self class] getClickUrlsFromContentSourceObject:csrObject];
            return  csrAd;
        }
    }
    ANLogError(@"Response from ad server in an unexpected format. Expected CSM in csmObject: %@", csrObject);
    return nil;
}
#endif

+ (NSDictionary *)nativeJson:(NSDictionary *)nativeRTBObject {
    
    NSMutableDictionary *nativeAd = [nativeRTBObject mutableCopy];
    [nativeAd removeObjectForKey:kANUniversalTagAdServerResponseKeyNativeImpTrackArray];

    // Converted nativeAdLink as Mutable Dictionary
    NSMutableDictionary *nativeAdLink = [nativeAd[kANUniversalTagAdServerResponseKeyNativeLink]  mutableCopy];

    // Remove click Trackers from nativeAd's Link
    [nativeAdLink removeObjectForKey:kANUniversalTagAdServerResponseKeyNativeClickTrackArray];
    // Remove link from nativeAd
    [nativeAd removeObjectForKey:kANUniversalTagAdServerResponseKeyNativeLink];
    // Remove javascript trackers from nativeAd
    [nativeAd removeObjectForKey:kANUniversalTagAdServerResponseKeyNativeJavascriptTrackers];
    // Re-add nativeAdLink into nativeAd without tracker
    [nativeAd setValue:nativeAdLink forKey:kANUniversalTagAdServerResponseKeyNativeLink];

    NSDictionary *nativeJSON = @{ kANNativeElementObject : [nativeAd copy]};
    return nativeJSON;
}

+ (NSString *)nativeRenderingJSON:(NSDictionary *)nativeRTBObject {

    NSMutableDictionary *nativeAd = [nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeObject] mutableCopy];
    [nativeAd removeObjectForKey:kANUniversalTagAdServerResponseKeyNativeImpTrackArray];
    [nativeAd removeObjectForKey:kANUniversalTagAdServerResponseKeyNativeJavascriptTrackers];
    NSData  *utResponseJSONData  = [NSJSONSerialization dataWithJSONObject:nativeAd
                                                                   options: NSJSONWritingPrettyPrinted
                                                                     error: nil ];
    NSString  *utResponseJSONString  = [[NSString alloc] initWithData:utResponseJSONData encoding:NSUTF8StringEncoding];
    return utResponseJSONString;
}

+ (ANNativeStandardAdResponse *)nativeAdFromRTBObject:(NSDictionary *)nativeObject
{
    if (!nativeObject) {
        ANLogError(@"nativeRTBObject is nil");
        return nil;
    }
    
    if (! [nativeObject[kANUniversalTagAdServerResponseKeyNativeObject] isKindOfClass:[NSDictionary class]]) {
        ANLogDebug(@"Response from ad server in an unexpected format. Unable to find RTB native in nativeObject: %@", nativeObject);
        return nil;
    }
    NSDictionary *nativeRTBObject = nativeObject[kANUniversalTagAdServerResponseKeyNativeObject];
    
    if(nativeRTBObject == nil){
        ANLogDebug(@"Response from ad server in an unexpected format. Unable to find RTB native in nativeContentFromRTBObject: %@", nativeRTBObject);
        return nil;
    }
    
    if([nativeRTBObject isKindOfClass:[NSDictionary class]]){
        ANNativeStandardAdResponse *nativeAd = [[ANNativeStandardAdResponse alloc] init];

        NSDictionary *nativeJson = [self nativeJson:nativeRTBObject];
        if(nativeJson){
            nativeAd.customElements = nativeJson;
        }
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeAdditionalDescription] isKindOfClass:[NSString class]]) {
            nativeAd.additionalDescription = [nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeAdditionalDescription] copy];
        }
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeMediaType] isKindOfClass:[NSString class]]) {
            nativeAd.adObjectMediaType = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeMediaType];
        }
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeTitle] isKindOfClass:[NSString class]]) {
            nativeAd.title = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeTitle];
        }
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeDescription] isKindOfClass:[NSString class]]) {
            nativeAd.body = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeDescription];
        }
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeCallToAction] isKindOfClass:[NSString class]]) {
            nativeAd.callToAction = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeCallToAction];
        }
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeSponsoredBy] isKindOfClass:[NSString class]]) {
            nativeAd.sponsoredBy = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeSponsoredBy];
        }
        
        
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeLink] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *nativeRTBObjectLink = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeLink];
            if ([nativeRTBObjectLink[kANUniversalTagAdServerResponseKeyNativeURL] isKindOfClass:[NSString class]]) {
                NSString *clickURLString = [nativeRTBObjectLink[kANUniversalTagAdServerResponseKeyNativeURL] description];
                nativeAd.clickURL = [NSURL URLWithString:clickURLString];

            }
            if ([nativeRTBObjectLink[kANUniversalTagAdServerResponseKeyNativeClickFallbackUrl] isKindOfClass:[NSString class]]) {
                NSString *clickURLFallbackString = [nativeRTBObjectLink[kANUniversalTagAdServerResponseKeyNativeClickFallbackUrl] description];
                nativeAd.clickFallbackURL = [NSURL URLWithString:clickURLFallbackString];
            }
            if ([nativeRTBObjectLink[kANUniversalTagAdServerResponseKeyNativeClickTrackArray] isKindOfClass:[NSArray class]]) {
                nativeAd.clickTrackers = [NSArray arrayWithArray:nativeRTBObjectLink[kANUniversalTagAdServerResponseKeyNativeClickTrackArray]];
            }
        }
        
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeIcon] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *iconImageData = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeIcon];
            nativeAd.iconImageURL = [[self class]  imageURLString:iconImageData];
            nativeAd.iconImageSize = [[self class]  imageSize:iconImageData];
        }
        
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeMainMedia] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *mainImageData = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeMainMedia];
            nativeAd.mainImageURL = [[self class]  imageURLString:mainImageData];
            nativeAd.mainImageSize = [[self class]  imageSize:mainImageData];
        }
        
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeImpTrackArray] isKindOfClass:[NSArray class]])
        {
            nativeAd.impTrackers = [NSArray arrayWithArray:nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeImpTrackArray]];

        }
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeRatingDict] isKindOfClass:[NSString class]]) {
            NSString *rating = [nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeRatingDict] description];
            // Rating->Scale is removed from ut/v3 and  -1 is outside the range of any normal value for scale.
            // Rating->Scale will be removed in future if not used by Mediation Adapters
            NSNumber *ratingScale = @(-1);
            nativeAd.rating = [[ANNativeAdStarRating alloc] initWithValue:[rating floatValue]
                                                                    scale:[ratingScale integerValue]];
        }
        
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeVideo] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *videoContent = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeVideo];
            if ([videoContent[kANUniversalTagAdServerResponseKeyNativeVideoContent] isKindOfClass:[NSString class]]) {
                nativeAd.vastXML = [videoContent[kANUniversalTagAdServerResponseKeyNativeVideoContent] copy];
            }
        }
        
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativePrivacyLink] isKindOfClass:[NSString class]]) {
            nativeAd.privacyLink = [nativeRTBObject[kANUniversalTagAdServerResponseKeyNativePrivacyLink] copy];
        }
        
        return nativeAd;
    } else
    {
        ANLogDebug(@"Response from ad server in an unexpected format. Unable to find RTB native in nativeRTBObject: %@", nativeRTBObject);
        return nil;
    }
}

+(CGSize) imageSize:(NSDictionary *)nativeAdImageData  {
    CGFloat width = [(nativeAdImageData[kANUniversalTagAdServerResponseKeyBannerWidth] ?: @0) floatValue];
    CGFloat height = [(nativeAdImageData[kANUniversalTagAdServerResponseKeyBannerHeight] ?: @0) floatValue];
    return CGSizeMake(width, height);
}

+(NSURL *) imageURLString:(NSDictionary *)nativeAdImageData  {
    NSString *imageURLString = [[nativeAdImageData objectForKey:kANUniversalTagAdServerResponseKeyNativeURL] description];
    return [NSURL URLWithString:imageURLString];
    
}



#pragma mark - Trackers

+ (NSDictionary *)trackerDictFromContentSourceObject:(NSDictionary *)contentSourceObject {
    if ([contentSourceObject[kANUniversalTagAdServerResponseKeyTrackers] isKindOfClass:[NSArray class]]) {
        NSArray *trackers = contentSourceObject[kANUniversalTagAdServerResponseKeyTrackers];
        if ([[trackers firstObject] isKindOfClass:[NSDictionary class]]) {
            return [trackers firstObject];
        }
    }
    return nil;
}


+ (NSArray *)impressionUrlsFromContentSourceObject:(NSDictionary *)contentSourceObject {
    NSDictionary *trackerDict = [[self class] trackerDictFromContentSourceObject:contentSourceObject];
    if ([trackerDict[kANUniversalTagAdServerResponseKeyTrackersImpressionUrls] isKindOfClass:[NSArray class]]) {
        return trackerDict[kANUniversalTagAdServerResponseKeyTrackersImpressionUrls];
    }
    return nil;
}

+ (NSArray *)getClickUrlsFromContentSourceObject:(NSDictionary *)contentSourceObject {
    NSDictionary *trackerDict = [[self class] trackerDictFromContentSourceObject:contentSourceObject];
    if ([trackerDict[kANUniversalTagAdServerResponseKeyTrackersClick_urls] isKindOfClass:[NSArray class]]) {
        return trackerDict[kANUniversalTagAdServerResponseKeyTrackersClick_urls];
    }
    return nil;
}



#pragma mark - Helper class methods (internal facing).

+ (nullable NSDictionary<NSString *, id> *)generateDictionaryFromJSONResponse:(NSData *)data
{
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (!responseString || ([responseString length] <= 0)) {
        ANLogDebug(@"Received empty response from ad server");
        return nil;
    }

    //
    NSError *jsonParsingError = nil;

    id responseDictionary = [NSJSONSerialization JSONObjectWithData: data
                                                            options: 0
                                                              error: &jsonParsingError];
    if (jsonParsingError) {
        ANLogError(@"response_json_error %@", jsonParsingError);
        return nil;

    } else if (![responseDictionary isKindOfClass:[NSDictionary class]]) {
        ANLogError(@"Response from ad server in an unexpected format: %@", responseDictionary);
        return nil;
    }

    return  (NSDictionary<NSString *, id> *)responseDictionary;
}

@end

