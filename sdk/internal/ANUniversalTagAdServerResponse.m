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
#import "ANLogging.h"
#import "ANInterstitialAdFetcher.h"
#import "ANMediatedAd.h"
#import "ANSSMStandardAd.h"
#import "ANSSMVideoAd.h"

static NSString *const kANUniversalTagAdServerResponseKeyNoBid = @"nobid";
static NSString *const kANUniversalTagAdServerResponseKeyTags = @"tags";

static NSString *const kANUniversalTagAdServerResponseKeyTagNoAdUrl = @"no_ad_url";
static NSString *const kANUniversalTagAdServerResponseKeyTagAds = @"ads";

static NSString *const kANUniversalTagAdServerResponseKeyAdsAdType = @"ad_type";
static NSString *const kANUniversalTagAdServerResponseKeyAdsCSMObject = @"csm";
static NSString *const kANUniversalTagAdServerResponseKeyAdsSSMObject = @"ssm";
static NSString *const kANUniversalTagAdServerResponseKeyAdsRTBObject = @"rtb";
static NSString *const kANUniversalTagAdServerResponseKeyAdsNotifyUrl = @"notify_url";

static NSString *const kANUniversalTagAdServerResponseKeyVideoObject = @"video";
static NSString *const kANUniversalTagAdServerResponseKeyVideoContent = @"content";

static NSString *const kANUniversalTagAdServerResponseKeyBannerObject = @"banner";
static NSString *const kANUniversalTagAdServerResponseKeyBannerWidth = @"width";
static NSString *const kANUniversalTagAdServerResponseKeyBannerHeight = @"height";
static NSString *const kANUniversalTagAdServerResponseKeyBannerContent = @"content";

NSString *const kANUniversalTagAdServerResponseMraidJSFilename = @"mraid.js";

// SSM

static NSString *const kANUniversalTagAdServerResponseKeySSMHandlerUrl = @"url";


// CSM
static NSString *const kANUniversalTagAdServerResponseValueIOS = @"ios";
static NSString *const kANUniversalTagAdServerResponseKeyHandler = @"handler";
static NSString *const kANUniversalTagAdServerResponseKeyClass = @"class";
static NSString *const kANUniversalTagAdServerResponseKeyId = @"id";
static NSString *const kANUniversalTagAdServerResponseKeyParam = @"param";
static NSString *const kANUniversalTagAdServerResponseKeyResultCB = @"response_url";
static NSString *const kANUniversalTagAdServerResponseKeyType = @"type";
static NSString *const kANUniversalTagAdServerResponseKeyWidth = @"width";
static NSString *const kANUniversalTagAdServerResponseKeyHeight = @"height";

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

#pragma mark - Universal Tag V2 Support

- (void)processV2ResponseData:(NSData *)data {
    NSDictionary *jsonResponse = [[self class] jsonResponseFromData:data];
    if (jsonResponse) {
        NSArray *tags = [[self class] tagsFromJSONResponse:jsonResponse];
        NSDictionary *firstTag = [tags firstObject];
        if ([[self class] isNoBidTag:firstTag]) {
            return;
        }
        // Only the first tag is supported today
        self.noAdUrlString = firstTag[kANUniversalTagAdServerResponseKeyTagNoAdUrl];
        NSArray *adsArray = [[self class] adsArrayFromTag:firstTag];
        if (adsArray) {
            for (id adObject in adsArray) {
                if (![adObject isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                NSDictionary *rtbObject = [[self class] rtbObjectFromAdObject:adObject];
                if (rtbObject) {
                    ANStandardAd *standardAd = [[self class] standardAdFromRTBObject:rtbObject];
                    if (standardAd) {
                        [self.ads addObject:standardAd];
                    }
                    ANVideoAd *videoAd = [[self class] videoAdFromRTBObject:rtbObject];
                    if (videoAd) {
                        videoAd.notifyUrlString = [adObject[kANUniversalTagAdServerResponseKeyAdsNotifyUrl] description];
                        [self.ads addObject:videoAd];
                    }
                }
                NSDictionary *csmObject = [[self class] csmObjectFromAdObject:adObject];
                if (csmObject) {
                    ANMediatedAd *mediatedAd = [[self class] mediatedAdFromCSMObject:csmObject];
                    // Ignore non-supported CSM (e.g. web CSM, video CSM)
                    if (mediatedAd && mediatedAd.className.length > 0) {
                        [self.ads addObject:mediatedAd];
                    }
                }
                NSDictionary *ssmObject = [[self class] ssmObjectFromAdObject:adObject];
                if (ssmObject) {
                    ANSSMStandardAd *standardAd = [[self class] standardSSMAdFromSSMObject:ssmObject];
                    if (standardAd) {
                        [self.ads addObject:standardAd];
                    }
                    ANSSMVideoAd *videoAd = [[self class] videoSSMAdFromSSMObject:ssmObject];
                    if (videoAd) {
                        videoAd.notifyUrlString = [adObject[kANUniversalTagAdServerResponseKeyAdsNotifyUrl] description];
                        [self.ads addObject:videoAd];
                    }
                }
            }
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
    }
    return nil;
}

+ (NSDictionary *)rtbObjectFromAdObject:(NSDictionary *)adObject {
    if ([adObject[kANUniversalTagAdServerResponseKeyAdsRTBObject] isKindOfClass:[NSDictionary class]]) {
        return adObject[kANUniversalTagAdServerResponseKeyAdsRTBObject];
    }
    return nil;
}

+ (NSDictionary *)csmObjectFromAdObject:(NSDictionary *)adObject {
    if ([adObject[kANUniversalTagAdServerResponseKeyAdsCSMObject] isKindOfClass:[NSDictionary class]]) {
        return adObject[kANUniversalTagAdServerResponseKeyAdsCSMObject];
    }
    return nil;
}

+ (NSDictionary *)ssmObjectFromAdObject:(NSDictionary *)adObject {
    if ([adObject[kANUniversalTagAdServerResponseKeyAdsSSMObject] isKindOfClass:[NSDictionary class]]) {
        return adObject[kANUniversalTagAdServerResponseKeyAdsSSMObject];
    }
    return nil;
}

+ (ANStandardAd *)standardAdFromRTBObject:(NSDictionary *)rtbObject {
    if ([rtbObject[kANUniversalTagAdServerResponseKeyBannerObject] isKindOfClass:[NSDictionary class]]) {
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
    }
    return nil;
}

+ (ANVideoAd *)videoAdFromRTBObject:(NSDictionary *)rtbObject {
    if ([rtbObject[kANUniversalTagAdServerResponseKeyVideoObject] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *video = rtbObject[kANUniversalTagAdServerResponseKeyVideoObject];
        ANVideoAd *videoAd = [[ANVideoAd alloc] init];
        videoAd.content = [video[kANUniversalTagAdServerResponseKeyVideoContent] description];
        return videoAd;
    }
    return nil;
}

+ (ANMediatedAd *)mediatedAdFromCSMObject:(NSDictionary *)csmObject {
    if ([csmObject[kANUniversalTagAdServerResponseKeyHandler] isKindOfClass:[NSArray class]]) {
        ANMediatedAd *mediatedAd;
        NSArray *handlerArray = (NSArray *)csmObject[kANUniversalTagAdServerResponseKeyHandler];
        for (id handlerObject in handlerArray) {
            if ([handlerObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *handlerDict = (NSDictionary *)handlerObject;
                NSString *type = [handlerDict[kANUniversalTagAdServerResponseKeyType] description];
                if ([type.lowercaseString isEqualToString:kANUniversalTagAdServerResponseValueIOS]) {
                    NSString *className = [handlerDict[kANUniversalTagAdServerResponseKeyClass] description];
                    if ([className length] == 0) {
                        return nil;
                    }
                    mediatedAd = [[ANMediatedAd alloc] init];
                    mediatedAd.className = className;
                    mediatedAd.param = [handlerDict[kANUniversalTagAdServerResponseKeyParam] description];
                    mediatedAd.width = [handlerDict[kANUniversalTagAdServerResponseKeyWidth] description];
                    mediatedAd.height = [handlerDict[kANUniversalTagAdServerResponseKeyHeight] description];
                    mediatedAd.adId = [handlerDict[kANUniversalTagAdServerResponseKeyId] description];
                    break;
                }
            }
        }
        mediatedAd.resultCB = [csmObject[kANUniversalTagAdServerResponseKeyResultCB] description];
        mediatedAd.impressionUrls = [[self class] impressionUrlsFromContentSourceObject:csmObject];
        return mediatedAd;
    }
    return nil;
}

+ (ANSSMStandardAd *)standardSSMAdFromSSMObject:(NSDictionary *)ssmObject {
    if ([ssmObject[kANUniversalTagAdServerResponseKeyBannerObject] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *banner = ssmObject[kANUniversalTagAdServerResponseKeyBannerObject];
        if ([ssmObject[kANUniversalTagAdServerResponseKeyHandler] isKindOfClass:[NSArray class]]) {
            NSArray *handlerArray = (NSArray *)ssmObject[kANUniversalTagAdServerResponseKeyHandler];
            if ([[handlerArray firstObject] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *handlerDict = (NSDictionary *)[handlerArray firstObject];
                ANSSMStandardAd *standardAd = [[ANSSMStandardAd alloc] init];
                standardAd.urlString = handlerDict[kANUniversalTagAdServerResponseKeySSMHandlerUrl];
                standardAd.impressionUrls = [[self class] impressionUrlsFromContentSourceObject:ssmObject];
                standardAd.width = [banner[kANUniversalTagAdServerResponseKeyBannerWidth] description];
                standardAd.height = [banner[kANUniversalTagAdServerResponseKeyBannerHeight] description];
                return standardAd;
            }
        }
    }
    return nil;
}

+ (ANSSMVideoAd *)videoSSMAdFromSSMObject:(NSDictionary *)ssmObject {
    if ([ssmObject[kANUniversalTagAdServerResponseKeyVideoObject] isKindOfClass:[NSDictionary class]]) {
        if ([ssmObject[kANUniversalTagAdServerResponseKeyHandler] isKindOfClass:[NSArray class]]) {
            NSArray *handlerArray = (NSArray *)ssmObject[kANUniversalTagAdServerResponseKeyHandler];
            if ([[handlerArray firstObject] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *handlerDict = (NSDictionary *)[handlerArray firstObject];
                ANSSMVideoAd *videoAd = [[ANSSMVideoAd alloc] init];
                videoAd.urlString = handlerDict[kANUniversalTagAdServerResponseKeySSMHandlerUrl];
                videoAd.impressionUrls = [[self class] impressionUrlsFromContentSourceObject:ssmObject];
                videoAd.errorUrls = [[self class] errorUrlsFromContentSourceObject:ssmObject];
                videoAd.videoClickUrls = [[self class] videoClickUrlsFromContentSourceObject:ssmObject];
                NSMutableDictionary *videoEventTrackers = [[NSMutableDictionary alloc] init];
                NSArray *startTrackers = [[self class] videoStartUrlsFromContentSourceObject:ssmObject];
                if (startTrackers) {
                    videoEventTrackers[@(ANVideoEventStart)] = startTrackers;
                }
                NSArray *skipTrackers = [[self class] videoSkipUrlsFromContentSourceObject:ssmObject];
                if (skipTrackers) {
                    videoEventTrackers[@(ANVideoEventSkip)] = skipTrackers;
                }
                NSArray *firstQuartileTrackers = [[self class] videoFirstQuartileUrlsFromContentSourceObject:ssmObject];
                if (firstQuartileTrackers) {
                    videoEventTrackers[@(ANVideoEventQuartileFirst)] = firstQuartileTrackers;
                }
                NSArray *midpointTrackers = [[self class] videoMidpointUrlsFromContentSourceObject:ssmObject];
                if (midpointTrackers) {
                    videoEventTrackers[@(ANVideoEventQuartileMidPoint)] = midpointTrackers;
                }
                NSArray *thirdQuartileTrackers = [[self class] videoThirdQuartileUrlsFromContentSourceObject:ssmObject];
                if (thirdQuartileTrackers) {
                    videoEventTrackers[@(ANVideoEventQuartileThird)] = thirdQuartileTrackers;
                }
                NSArray *videoCompleteTrackers = [[self class] videoCompleteUrlsFromContentSourceObject:ssmObject];
                if (videoCompleteTrackers) {
                    videoEventTrackers[@(ANVideoEventQuartileComplete)] = videoCompleteTrackers;
                }
                videoAd.videoEventTrackers = [videoEventTrackers copy];
                return videoAd;
            }
        }
    }
    return nil;
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

+ (NSDictionary *)videoEventsDictFromTrackerDict:(NSDictionary *)trackerDict {
    if ([trackerDict[kANUniversalTagAdServerResponseKeyTrackersVideoEvents] isKindOfClass:[NSDictionary class]]) {
        return trackerDict[kANUniversalTagAdServerResponseKeyTrackersVideoEvents];
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

+ (NSArray *)errorUrlsFromContentSourceObject:(NSDictionary *)contentSourceObject {
    NSDictionary *trackerDict = [[self class] trackerDictFromContentSourceObject:contentSourceObject];
    if ([trackerDict[kANUniversalTagAdServerResponseKeyTrackersErrorUrls] isKindOfClass:[NSArray class]]) {
        return trackerDict[kANUniversalTagAdServerResponseKeyTrackersErrorUrls];
    }
    return nil;
}

+ (NSArray *)videoClickUrlsFromContentSourceObject:(NSDictionary *)contentSourceObject {
    NSDictionary *trackerDict = [[self class] trackerDictFromContentSourceObject:contentSourceObject];
    if ([trackerDict[kANUniversalTagAdServerResponseKeyTrackersVideoClickUrls] isKindOfClass:[NSArray class]]) {
        return trackerDict[kANUniversalTagAdServerResponseKeyTrackersVideoClickUrls];
    }
    return nil;
}

+ (NSArray *)videoStartUrlsFromContentSourceObject:(NSDictionary *)contentSourceObject {
    NSDictionary *trackerDict = [[self class] trackerDictFromContentSourceObject:contentSourceObject];
    NSDictionary *videoEventsDict = [[self class] videoEventsDictFromTrackerDict:trackerDict];
    if ([videoEventsDict[kANUniversalTagAdServerResponseKeyVideoEventsStartUrls] isKindOfClass:[NSArray class]]) {
        return videoEventsDict[kANUniversalTagAdServerResponseKeyVideoEventsStartUrls];
    }
    return nil;
}

+ (NSArray *)videoSkipUrlsFromContentSourceObject:(NSDictionary *)contentSourceObject {
    NSDictionary *trackerDict = [[self class] trackerDictFromContentSourceObject:contentSourceObject];
    NSDictionary *videoEventsDict = [[self class] videoEventsDictFromTrackerDict:trackerDict];
    if ([videoEventsDict[kANUniversalTagAdServerResponseKeyVideoEventsSkipUrls] isKindOfClass:[NSArray class]]) {
        return videoEventsDict[kANUniversalTagAdServerResponseKeyVideoEventsSkipUrls];
    }
    return nil;
}

+ (NSArray *)videoFirstQuartileUrlsFromContentSourceObject:(NSDictionary *)contentSourceObject {
    NSDictionary *trackerDict = [[self class] trackerDictFromContentSourceObject:contentSourceObject];
    NSDictionary *videoEventsDict = [[self class] videoEventsDictFromTrackerDict:trackerDict];
    if ([videoEventsDict[kANUniversalTagAdServerResponseKeyVideoEventsFirstQuartileUrls] isKindOfClass:[NSArray class]]) {
        return videoEventsDict[kANUniversalTagAdServerResponseKeyVideoEventsFirstQuartileUrls];
    }
    return nil;
}

+ (NSArray *)videoMidpointUrlsFromContentSourceObject:(NSDictionary *)contentSourceObject {
    NSDictionary *trackerDict = [[self class] trackerDictFromContentSourceObject:contentSourceObject];
    NSDictionary *videoEventsDict = [[self class] videoEventsDictFromTrackerDict:trackerDict];
    if ([videoEventsDict[kANUniversalTagAdServerResponseKeyVideoEventsMidpointUrls] isKindOfClass:[NSArray class]]) {
        return videoEventsDict[kANUniversalTagAdServerResponseKeyVideoEventsMidpointUrls];
    }
    return nil;
}

+ (NSArray *)videoThirdQuartileUrlsFromContentSourceObject:(NSDictionary *)contentSourceObject {
    NSDictionary *trackerDict = [[self class] trackerDictFromContentSourceObject:contentSourceObject];
    NSDictionary *videoEventsDict = [[self class] videoEventsDictFromTrackerDict:trackerDict];
    if ([videoEventsDict[kANUniversalTagAdServerResponseKeyVideoEventsThirdQuartileUrls] isKindOfClass:[NSArray class]]) {
        return videoEventsDict[kANUniversalTagAdServerResponseKeyVideoEventsThirdQuartileUrls];
    }
    return nil;
}

+ (NSArray *)videoCompleteUrlsFromContentSourceObject:(NSDictionary *)contentSourceObject {
    NSDictionary *trackerDict = [[self class] trackerDictFromContentSourceObject:contentSourceObject];
    NSDictionary *videoEventsDict = [[self class] videoEventsDictFromTrackerDict:trackerDict];
    if ([videoEventsDict[kANUniversalTagAdServerResponseKeyVideoEventsCompleteUrls] isKindOfClass:[NSArray class]]) {
        return videoEventsDict[kANUniversalTagAdServerResponseKeyVideoEventsCompleteUrls];
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