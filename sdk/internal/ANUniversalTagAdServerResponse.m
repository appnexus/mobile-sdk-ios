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
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANMediatedAd.h"
#import "ANSSMStandardAd.h"
#import "ANSSMVideoAd.h"
#import "ANRTBVideoAd.h"
#import "ANCSMVideoAd.h"
#import "ANStandardAd.h"
#import "ANAdConstants.h"
#import "ANNativeStandardAdResponse.h"




static NSString *const kANUniversalTagAdServerResponseKeyNoBid = @"nobid";
static NSString *const kANUniversalTagAdServerResponseKeyTags = @"tags";

static NSString *const kANUniversalTagAdServerResponseKeyTagNoAdUrl = @"no_ad_url";
static NSString *const kANUniversalTagAdServerResponseKeyTagAds = @"ads";

static NSString *const kANUniversalTagAdServerResponseKeyAdsContentSource = @"content_source";
static NSString *const kANUniversalTagAdServerResponseKeyAdsAdType = @"ad_type";
static NSString *const kANUniversalTagAdServerResponseKeyAdsCreativeId = @"creative_id";

static NSString *const kANUniversalTagAdServerResponseKeyAdsCSMObject = @"csm";
static NSString *const kANUniversalTagAdServerResponseKeyAdsSSMObject = @"ssm";
static NSString *const kANUniversalTagAdServerResponseKeyAdsRTBObject = @"rtb";
static NSString *const kANUniversalTagAdServerResponseKeyAdsNotifyUrl = @"notify_url";


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

// Native
static NSString *const kANUniversalTagAdServerResponseKeyNativeObject = @"native";

static NSString *const kANUniversalTagAdServerResponseKeyNativeMediaType = @"type";
static NSString *const kANUniversalTagAdServerResponseKeyNativeTitle = @"title";
static NSString *const kANUniversalTagAdServerResponseKeyNativeDescription = @"description";
static NSString *const kANUniversalTagAdServerResponseKeyNativeFullText = @"full_text";
static NSString *const kANUniversalTagAdServerResponseKeyNativeContext = @"context";
static NSString *const kANUniversalTagAdServerResponseKeyNativeIconImageUrl = @"icon_img_url";
static NSString *const kANUniversalTagAdServerResponseKeyNativeMainMedia = @"main_media";
static NSString *const kANUniversalTagAdServerResponseKeyNativeMainMediaLabel = @"label";
static NSString *const kANUniversalTagAdServerResponseKeyNativeMainMediaDefaultLabel = @"default";
static NSString *const kANUniversalTagAdServerResponseKeyNativeMainMediaURL = @"url";
static NSString *const kANUniversalTagAdServerResponseKeyNativeCallToAction = @"cta";
static NSString *const kANUniversalTagAdServerResponseKeyNativeClickTrackArray = @"click_trackers";
static NSString *const kANUniversalTagAdServerResponseKeyNativeImpTrackArray = @"impression_trackers";
static NSString *const kANUniversalTagAdServerResponseKeyNativeClickUrl = @"click_url";
static NSString *const kANUniversalTagAdServerResponseKeyNativeClickFallbackUrl = @"click_url_fallback";
static NSString *const kANUniversalTagAdServerResponseKeyNativeRatingDict = @"rating";
static NSString *const kANUniversalTagAdServerResponseKeyNativeRatingValue = @"value";
static NSString *const kANUniversalTagAdServerResponseKeyNativeRatingScale = @"scale";
static NSString *const kANUniversalTagAdServerResponseKeyNativeCustomKeywordsDict = @"custom";
static NSString *const kANUniversalTagAdServerResponseKeyNativeSponsoredBy = @"sponsored_by";


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

@property (nonatomic, readwrite, strong) NSMutableArray *ads;
@property (nonatomic, readwrite, strong) NSString *noAdUrlString;

@end




@implementation ANUniversalTagAdServerResponse

#pragma mark - Lifecycle.

- (instancetype)initWithAdServerData:(NSData *)data {
    self = [super init];
    if (self) {
        [self processV2ResponseData:data];
    }
    return self;
}

+ (ANUniversalTagAdServerResponse *)responseWithData:(NSData *)data {
    return [[ANUniversalTagAdServerResponse alloc] initWithAdServerData:data];
}

- (instancetype)initWithContent:(NSString *)htmlContent
                          width:(NSInteger)width
                         height:(NSInteger)height
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



#pragma mark - Universal Tag V2 Support

- (void)processV2ResponseData:(NSData *)data
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
                                [self.ads addObject:standardAd];
                            }

                        // RTB - Video
                        } else if([adType isEqualToString:kANUniversalTagAdServerResponseKeyVideoObject]){
                            ANRTBVideoAd *videoAd = [[self class] videoAdFromRTBObject:rtbObject];
                            if (videoAd) {
                                videoAd.creativeId = creativeId;
                                videoAd.notifyUrlString = [adObject[kANUniversalTagAdServerResponseKeyAdsNotifyUrl] description];

                                [self.ads addObject:videoAd];
                            }

                        } else if([adType isEqualToString:kANUniversalTagAdServerResponseKeyNativeObject]) {
                            ANNativeStandardAdResponse  *nativeAd  = [[self class] nativeAdFromRTBObject:rtbObject];
                            if (nativeAd) {
                                nativeAd.creativeId = creativeId;
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
                        if (csmObject)
                        {
                            ANMediatedAd *mediatedAd = [[self class] mediatedAdFromCSMObject:csmObject];
                            
                            if ([adType isEqualToString:kANUniversalTagAdServerResponseKeyNativeObject]) {
                                mediatedAd.isAdTypeNative = YES;
                            }
                            
                            if (mediatedAd)
                            {
                                mediatedAd.creativeId = creativeId;
                                if (mediatedAd.className.length > 0) {
                                    [self.ads addObject:mediatedAd];
                                }
                            }
                        }
                    } else if([adType isEqualToString:kANUniversalTagAdServerResponseKeyVideoObject]) {
                        ANCSMVideoAd *csmVideoAd = [[self class] videoCSMAdFromCSMObject:adObject withTagObject:firstTag];
                        if(csmVideoAd){
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
                                ssmStandardAd.creativeId = creativeId;
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
                    baseAdObject.adType = [adType copy];
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
                    break;
                    
                } else {
                    ANLogError(@"UNRECOGNIZED CSM type.  (%@)", type);
                }
            }
        } //endfor -- handlerObject
        
        if (mediatedAd)
        {
            mediatedAd.responseURL        = [csmObject[kANUniversalTagAdServerResponseKeyResponseURL] description];
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
    NSDictionary *nativeContentFromRTBObject = nativeObject[kANUniversalTagAdServerResponseKeyNativeObject];
    
    if(nativeContentFromRTBObject == nil){
        ANLogDebug(@"Response from ad server in an unexpected format. Unable to find RTB native in nativeContentFromRTBObject: %@", nativeContentFromRTBObject);
        return nil;
    }
    
    NSDictionary *nativeRTBObject = [nativeContentFromRTBObject[kANUniversalTagAdServerResponseKeyNativeObject] firstObject];
    
    if([nativeRTBObject isKindOfClass:[NSDictionary class]]){
        ANNativeStandardAdResponse *nativeAd = [[ANNativeStandardAdResponse alloc] init];
        
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeMediaType] isKindOfClass:[NSString class]]) {
            nativeAd.adObjectMediaType = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeMediaType];
        }
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeTitle] isKindOfClass:[NSString class]]) {
            nativeAd.title = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeTitle];
        }
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeDescription] isKindOfClass:[NSString class]]) {
            nativeAd.body = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeDescription];
        }
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeFullText] isKindOfClass:[NSString class]]) {
            nativeAd.fullText = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeFullText];
        }
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeContext] isKindOfClass:[NSString class]]) {
            nativeAd.socialContext = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeContext];
        }
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeCallToAction] isKindOfClass:[NSString class]]) {
            nativeAd.callToAction = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeCallToAction];
        }
        
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeSponsoredBy] isKindOfClass:[NSString class]]) {
            nativeAd.sponsoredBy = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeSponsoredBy];
        }
        
        
        
        NSString *iconImageURLString = [nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeIconImageUrl] description];
        NSString *clickURLString = [nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeClickUrl] description];
        NSString *clickURLFallbackString = [nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeClickFallbackUrl] description];
        
        nativeAd.iconImageURL = [NSURL URLWithString:iconImageURLString];
        nativeAd.clickURL = [NSURL URLWithString:clickURLString];
        nativeAd.clickFallbackURL = [NSURL URLWithString:clickURLFallbackString];
        
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeMainMedia] isKindOfClass:[NSArray class]]) {
            NSArray *mainMedia = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeMainMedia];
            [mainMedia enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *mainImageData = obj;
                    NSString *labelValue = [mainImageData[kANUniversalTagAdServerResponseKeyNativeMainMediaLabel] description];
                    if ([labelValue isEqualToString:kANUniversalTagAdServerResponseKeyNativeMainMediaDefaultLabel]) {
                        NSString *mainImageURLString = [[mainImageData objectForKey:kANUniversalTagAdServerResponseKeyNativeMainMediaURL] description];
                        nativeAd.mainImageURL = [NSURL URLWithString:mainImageURLString];
                        *stop = YES;
                    }
                }
            }];
        }
        
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeClickTrackArray] isKindOfClass:[NSArray class]]) {
            NSArray *clickTrackArray = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeClickTrackArray];
            NSMutableArray *clickTrackURLs = [[NSMutableArray alloc] initWithCapacity:clickTrackArray.count];
            [clickTrackArray enumerateObjectsUsingBlock:^(id clickTrackElement, NSUInteger idx, BOOL *stop) {
                [clickTrackURLs addObject:[clickTrackElement description]];
            }];
            nativeAd.clickTrackers = [clickTrackURLs copy];
        }
        
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeImpTrackArray] isKindOfClass:[NSArray class]])
        {
            NSArray *impTrackerArray = nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeImpTrackArray];
            NSMutableArray *impTrackURLs = [[NSMutableArray alloc] initWithCapacity:impTrackerArray.count];
            [impTrackerArray enumerateObjectsUsingBlock:^(id impTrackerElement, NSUInteger idx, BOOL *stop) {
                [impTrackURLs addObject:[impTrackerElement description]];
            }];
            nativeAd.impTrackers = [impTrackURLs copy];
        }
        
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeCustomKeywordsDict] isKindOfClass:[NSDictionary class]]) {
            nativeAd.customElements = (NSDictionary *)nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeCustomKeywordsDict];
        }
        if ([nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeRatingDict] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *rating = (NSDictionary *)nativeRTBObject[kANUniversalTagAdServerResponseKeyNativeRatingDict];
            NSNumber *ratingScale = @(0);
            NSNumber *ratingValue = @(0);
            
            if ([rating[kANUniversalTagAdServerResponseKeyNativeRatingScale] isKindOfClass:[NSNumber class]]) {
                ratingScale = rating[kANUniversalTagAdServerResponseKeyNativeRatingScale];
            }
            if ([rating[kANUniversalTagAdServerResponseKeyNativeRatingValue] isKindOfClass:[NSNumber class]]) {
                ratingValue = rating[kANUniversalTagAdServerResponseKeyNativeRatingValue];
            }
            nativeAd.rating = [[ANNativeAdStarRating alloc] initWithValue:[ratingValue floatValue]
                                                                    scale:[ratingScale integerValue]];
        }
        
        return nativeAd;
    } else
    {
        ANLogDebug(@"Response from ad server in an unexpected format. Unable to find RTB native in nativeRTBObject: %@", nativeRTBObject);
        return nil;
    }
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

- (NSMutableArray *)ads {
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

