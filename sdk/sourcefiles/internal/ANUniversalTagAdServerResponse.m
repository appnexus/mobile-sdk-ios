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
#import "ANCustomResponse.h"
#import "ANGlobal.h"


static NSString *const kANUniversalTagAdServerResponseKeyNoBid = @"nobid";
static NSString *const kANUniversalTagAdServerResponseKeyTags = @"tags";

static NSString *const kANUniversalTagAdServerResponseKeyTagNoAdUrl = @"no_ad_url";
static NSString *const kANUniversalTagAdServerResponseKeyTagAds = @"ads";

static NSString *const kANUniversalTagAdServerResponseKeyAdsContentSource = @"content_source";
static NSString *const kANUniversalTagAdServerResponseKeyAdsAdType = @"ad_type";
static NSString *const kANUniversalTagAdServerResponseKeyAdsCreativeId = @"creative_id";
static NSString *const kANUniversalTagAdServerResponseKeyAdsRendererUrl = @"renderer_url";
static NSString *const kANUniversalTagAdServerResponseKeyAdsTagId = @"tag_id";

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
static NSString *const kANUniversalTagAdServerResponseKeyHandler = @"handler";
static NSString *const kANUniversalTagAdServerResponseKeyClass = @"class";
static NSString *const kANUniversalTagAdServerResponseKeyId = @"id";
static NSString *const kANUniversalTagAdServerResponseKeyParam = @"param";
static NSString *const kANUniversalTagAdServerResponseKeyResponseURL = @"response_url";
static NSString *const kANUniversalTagAdServerResponseKeyType = @"type";
static NSString *const kANUniversalTagAdServerResponseKeyWidth = @"width";
static NSString *const kANUniversalTagAdServerResponseKeyHeight = @"height";

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




@interface ANUniversalTagAdServerResponse ()

@property (nonatomic, readwrite, strong, nullable) NSMutableArray *ads;
@property (nonatomic, readwrite, strong, nullable) NSString *noAdUrlString;

@end




@implementation ANUniversalTagAdServerResponse

#pragma mark - Lifecycle.

- (nullable instancetype)initWithAdServerData:(nullable NSData *)data {
    self = [super init];
    if (self) {
        [self processResponseData:data];
    }
    return self;
}
- (nullable instancetype)initWitXMLContent:(nonnull NSString *)vastContent
                                    width:(NSInteger)width
                                   height:(NSInteger)height
{
    self = [super init];
    if (!self)  { return nil; }
    
    ANRTBVideoAd  *rtbVideoAd  = [[ANRTBVideoAd alloc] init];
    if (!rtbVideoAd)  { return nil; }
    
    rtbVideoAd.width    = [NSString stringWithFormat:@"%ld", (long)width];
    rtbVideoAd.height   = [NSString stringWithFormat:@"%ld", (long)height];
    rtbVideoAd.content  = vastContent;
    
    [self.ads addObject:rtbVideoAd];
    
    return self;
}


+ (nullable ANUniversalTagAdServerResponse *)responseWithData:(nullable NSData *)data; {
    return [[ANUniversalTagAdServerResponse alloc] initWithAdServerData:data];
}

- (nullable instancetype)initWithContent: (nonnull NSString *)htmlContent
                                  width: (NSInteger)width
                                 height: (NSInteger)height
{
    self = [super init];
    if (!self)  { return nil; }
    
    ANStandardAd  *standardAd  = [[ANStandardAd alloc] init];
    if (!standardAd)  { return nil; }
    
    standardAd.width    = [NSString stringWithFormat:@"%ld", (long)width];
    standardAd.height   = [NSString stringWithFormat:@"%ld", (long)height];
    standardAd.content  = htmlContent;
    
    [self.ads addObject:standardAd];
    
    return self;
}

#pragma mark - Universal Tag Support

- (void)processResponseData:(NSData *)data
{
    NSDictionary *jsonResponse = [[self class] jsonResponseFromData:data];
    ANLogDebug(@"jsonResponse=%@", [jsonResponse description]);
    
    if (jsonResponse) {
        NSArray *tags = [[self class] tagsFromJSONResponse:jsonResponse];
        NSDictionary *firstTag = [tags firstObject];
        if ([[self class] isNoBidTag:firstTag]) {
            return;
        }
        // Only the first tag is supported today
        self.noAdUrlString = firstTag[kANUniversalTagAdServerResponseKeyTagNoAdUrl];
        NSArray *adsArray = [[self class] adsArrayFromTag:firstTag];
        if (adsArray)
        {
            
            for (id adObject in adsArray)
            {
                
                if (![adObject isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                NSString *contentSource = [adObject[kANUniversalTagAdServerResponseKeyAdsContentSource] description];
                NSString *adType = [adObject[kANUniversalTagAdServerResponseKeyAdsAdType] description];

                NSString *creativeId  = @"";
                if(adObject[kANUniversalTagAdServerResponseKeyAdsCreativeId] != nil)
                {
                    creativeId  = [NSString stringWithFormat:@"%@",adObject[kANUniversalTagAdServerResponseKeyAdsCreativeId]];
                }
                if(!contentSource && !adType){
                    ANLogError(@"Response from ad server in an unexpected format content_source/ad_type UNDEFINED.  (adObject=%@)", adObject);
                    continue;
                }
                NSString *tagId  = @"";
                if(firstTag[kANUniversalTagAdServerResponseKeyAdsTagId] != nil)
                {
                    tagId  = [NSString stringWithFormat:@"%@",firstTag[kANUniversalTagAdServerResponseKeyAdsTagId]];
                }
                
                ANCustomResponse *customResponse = [[ANCustomResponse alloc] init];
                customResponse.creativeId = creativeId;
                customResponse.tagId = tagId;
                customResponse.adType = [ANGlobal adTypeStringToEnum:adType];
                
                // RTB
                if ([contentSource isEqualToString:kANUniversalTagAdServerResponseKeyAdsRTBObject])
                {
                    NSDictionary  *rtbObject  = [[self class] rtbObjectFromAdObject:adObject];

                    if (rtbObject) {
                        // RTB Banner / Interstitial
                        if ([adType isEqualToString:kANUniversalTagAdServerResponseKeyBannerObject]) {
                            ANStandardAd *standardAd = [[self class] standardAdFromRTBObject:rtbObject];
                            if (standardAd) {
                                [self.ads addObject:standardAd];
                            }

                        // RTB - Video
                        } else if([adType isEqualToString:kANUniversalTagAdServerResponseKeyVideoObject]){
                            ANRTBVideoAd *videoAd = [[self class] videoAdFromRTBObject:rtbObject];
                            if (videoAd) {
                                videoAd.notifyUrlString = [adObject[kANUniversalTagAdServerResponseKeyAdsNotifyUrl] description];

                                [self.ads addObject:videoAd];
                            }
                        // RTB - Native
                        } else if([adType isEqualToString:kANUniversalTagAdServerResponseKeyNativeObject]) {
                            ANNativeStandardAdResponse  *nativeAd  = [[self class] nativeAdFromRTBObject:rtbObject];
                            if (nativeAd) {
                                nativeAd.customResponse = customResponse;
                                if(adObject[kANUniversalTagAdServerResponseKeyAdsRendererUrl] != nil)
                                {
                                NSString * nativeRenderingUrl  = [NSString stringWithFormat:@"%@",adObject[kANUniversalTagAdServerResponseKeyAdsRendererUrl]];
                                NSString *nativeRenderingElements  =  [[self class] nativeRenderingJSON:rtbObject];
                                 if(nativeRenderingUrl && nativeRenderingElements){
                                    nativeAd.nativeRenderingObject =nativeRenderingElements;
                                    nativeAd.nativeRenderingUrl = nativeRenderingUrl;
                                 }
                                }

                                // Parsing viewability object to create measurement resources for OMID Native integration
                                ANVerificationScriptResource *verificationScriptResource = [[self class] anVerificationScriptFromAdObject:adObject];
                                if (verificationScriptResource) {
                                    nativeAd.verificationScriptResource = verificationScriptResource;
                                }
                                [self.ads addObject:nativeAd];
                            }

                        } else {
                            ANLogError(@"UNRECOGNIZED AD_TYPE in RTB.  (adType=%@  rtbObject=%@)", adType, rtbObject);
                        }
                    }
                }

                // CSM
                else if([contentSource isEqualToString:kANUniversalTagAdServerResponseKeyAdsCSMObject]){
                    if([adType isEqualToString:kANUniversalTagAdServerResponseKeyBannerObject] || [adType isEqualToString:kANUniversalTagAdServerResponseKeyNativeObject]){
                        NSDictionary *csmObject = [[self class] csmObjectFromAdObject:adObject];
                        if (csmObject) {
                            ANMediatedAd *mediatedAd = [[self class] mediatedAdFromCSMObject:csmObject];
                            if (mediatedAd) {
                                if ([adType isEqualToString:kANUniversalTagAdServerResponseKeyNativeObject]) {
                                    mediatedAd.isAdTypeNative = YES;
                                    // Parsing viewability object to create measurement resources for OMID Native integration
                                    ANVerificationScriptResource *verificationScriptResource = [[self class] anVerificationScriptFromAdObject:adObject];
                                    if (verificationScriptResource) {
                                        mediatedAd.verificationScriptResource = verificationScriptResource;
                                    }
                                }
                                if (mediatedAd.className.length > 0) {
                                    [self.ads addObject:mediatedAd];
                                }
                            }
                        }
                    } else if([adType isEqualToString:kANUniversalTagAdServerResponseKeyVideoObject]) {
                        ANCSMVideoAd *csmVideoAd = [[self class] videoCSMAdFromCSMObject:adObject withTagObject:firstTag];
                        if(csmVideoAd){
                            csmVideoAd.customResponse = customResponse;
                            [self.ads addObject:csmVideoAd];
                        }
                    }else{
                        ANLogError(@"UNRECOGNIZED AD_TYPE in CSM.  (adObject=%@)", adObject);
                    }
                }

                // SSM - Only Banner and Interstitial are supported in SSM
                else if([contentSource isEqualToString:kANUniversalTagAdServerResponseKeyAdsSSMObject]){
                    if([adType isEqualToString:kANUniversalTagAdServerResponseKeyBannerObject]){
                        NSDictionary *ssmObject = [[self class] ssmObjectFromAdObject:adObject];
                        if (ssmObject) {
                            ANSSMStandardAd *ssmStandardAd = [[self class] standardSSMAdFromSSMObject:ssmObject];
                            if (ssmStandardAd) {
                                [self.ads addObject:ssmStandardAd];
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
                id  lastAdsObject  = [self.ads lastObject];

                if ([lastAdsObject isKindOfClass:[ANBaseAdObject class]]) {
                    ANBaseAdObject  *baseAdObject  = (ANBaseAdObject *)lastAdsObject;
                    baseAdObject.customResponse = customResponse;
                }

            } //endfor -- adObject
        }
    }
}


+ (NSArray *)tagsFromJSONResponse:(NSDictionary *)jsonResponse {
    return [[self class] validDictionaryArrayForKey:kANUniversalTagAdServerResponseKeyTags
                                     inJSONResponse:jsonResponse];
}

+ (BOOL)isNoBidTag:(NSDictionary *)tag {
    if (tag[kANUniversalTagAdServerResponseKeyNoBid]) {
        BOOL noBid = [tag[kANUniversalTagAdServerResponseKeyNoBid] boolValue];
        return noBid;
    }
    return NO;
}


+ (NSArray *)adsArrayFromTag:(NSDictionary *)tag {
    if ([tag[kANUniversalTagAdServerResponseKeyTagAds] isKindOfClass:[NSArray class]]) {
        return tag[kANUniversalTagAdServerResponseKeyTagAds];
    }else{
        ANLogError(@"Response from ad server in an unexpected format no ads array found in tag: %@", tag);
        return nil;
    }
}

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
                                                                 jsonResponseFromData:[mediatedAd.param dataUsingEncoding:NSASCIIStringEncoding]
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
                return standardAd;
            }
        }
    }
    ANLogError(@"Response from ad server in an unexpected format. Unable to find SSM Banner in ssmObject: %@", ssmObject);
    return nil;
}

+ (NSDictionary *)nativeJson:(NSDictionary *)nativeRTBObject {
    
    NSMutableDictionary *nativeAd = [nativeRTBObject mutableCopy];
    [nativeAd removeObjectForKey:kANUniversalTagAdServerResponseKeyNativeImpTrackArray];
    [nativeAd removeObjectForKey:kANUniversalTagAdServerResponseKeyNativeLink];
    [nativeAd removeObjectForKey:kANUniversalTagAdServerResponseKeyNativeJavascriptTrackers];
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
    NSString  *utResponseJSONString  = [[NSString alloc] initWithData:utResponseJSONData encoding:NSASCIIStringEncoding];
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

        NSDictionary *nativeJson  =  [self nativeJson:nativeRTBObject];
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




#pragma mark - Helper Methods

- (nullable NSMutableArray *)ads {
    if (!_ads) _ads = [[NSMutableArray alloc] init];
    return _ads;
}

+ (NSDictionary *)jsonResponseFromData:(NSData *)data {
    NSString *responseString = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
    if (!responseString || [responseString length] == 0) {
        ANLogDebug(@"Received empty response from ad server");
        return nil;
    }
    
    NSError *jsonParsingError = nil;
    id jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                      options:0
                                                        error:&jsonParsingError];
    if (jsonParsingError) {
        ANLogError(@"response_json_error %@", jsonParsingError);
        return nil;
    } else if (![jsonResponse isKindOfClass:[NSDictionary class]]) {
        ANLogError(@"Response from ad server in an unexpected format: %@", jsonResponse);
        return nil;
    }
    
    return (NSDictionary *)jsonResponse;
}

+ (NSArray *)validDictionaryArrayForKey:(NSString *)key
                         inJSONResponse:(NSDictionary *)jsonResponse {
    if ([jsonResponse[key] isKindOfClass:[NSArray class]]) {
        NSArray *adsArray = (NSArray *)jsonResponse[key];
        NSMutableArray *validAdsArray = [[NSMutableArray alloc] initWithCapacity:[adsArray count]];
        [adsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [validAdsArray addObject:obj];
            }
        }];
        if (validAdsArray.count) {
            return [validAdsArray copy];
        }
    }
    return nil;
}

@end

