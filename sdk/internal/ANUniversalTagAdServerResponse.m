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

static NSString *const kANUniversalTagAdServerResponseKeyNoBid = @"nobid";
static NSString *const kANUniversalTagAdServerResponseKeyTags = @"tags";
static NSString *const kANUniversalTagAdServerResponseKeyAd = @"ad";
static NSString *const kANUniversalTagAdServerResponseKeyAds = @"ads";

static NSString *const kANUniversalTagAdServerResponseKeyNotifyUrl = @"notify_url";

static NSString *const kANUniversalTagAdServerResponseKeyRTBObject = @"rtb";

static NSString *const kANUniversalTagAdServerResponseKeyVideo = @"video";
static NSString *const kANUniversalTagAdServerResponseVideoKeyContent = @"content";

static NSString *const kANUniversalTagAdServerResponseKeyBanner = @"banner";
static NSString *const kANUniversalTagAdServerResponseBannerKeyWidth = @"width";
static NSString *const kANUniversalTagAdServerResponseBannerKeyHeight = @"height";
static NSString *const kANUniversalTagAdServerResponseBannerKeyContent = @"content";

static NSString *const kANUniversalTagAdServerResponseMraidJSFilename = @"mraid.js";

// Mediated
static NSString *const kANUniversalTagAdServerResponseValueIOS = @"ios";
static NSString *const kANUniversalTagAdServerResponseKeyHandler = @"handler";
static NSString *const kANUniversalTagAdServerResponseKeyClass = @"class";
static NSString *const kANUniversalTagAdServerResponseKeyId = @"id";
static NSString *const kANUniversalTagAdServerResponseKeyParam = @"param";
static NSString *const kANUniversalTagAdServerResponseKeyResultCB = @"response_url";


// Standard
static NSString *const kANUniversalTagAdServerResponseKeyType = @"type";
static NSString *const kANUniversalTagAdServerResponseKeyWidth = @"width";
static NSString *const kANUniversalTagAdServerResponseKeyHeight = @"height";

@interface ANUniversalTagAdServerResponse ()

@property (nonatomic, readwrite, assign) BOOL containsAds;
@property (nonatomic, readwrite, strong) ANStandardAd *standardAd;
@property (nonatomic, readwrite, strong) NSMutableArray *standardAds;
@property (nonatomic, readwrite, strong) ANVideoAd *videoAd;
@property (nonatomic, readwrite, strong) NSMutableArray *videoAds;
@property (nonatomic, readwrite, strong) NSMutableArray *mediatedAds;

@property (nonatomic, readwrite, strong) NSMutableArray *ads;

@end

@implementation ANUniversalTagAdServerResponse

- (instancetype)initWithAdServerData:(NSData *)data {
    self = [super init];
    if (self) {
    #if kANANInterstitialAdFetcherUseUTV2
        [self processV2ResponseData:data];
    #else
        [self processResponseData:data];
    #endif
    }
    return self;
}

+ (ANUniversalTagAdServerResponse *)responseWithData:(NSData *)data {
    return [[ANUniversalTagAdServerResponse alloc] initWithAdServerData:data];
}

- (void)processResponseData:(NSData *)data {
    NSDictionary *jsonResponse = [[self class] jsonResponseFromData:data];
    if (jsonResponse) {
        NSArray *tags = [[self class] tagsFromJSONResponse:jsonResponse];
        for (NSDictionary *tag in tags) {
            if ([[self class] isNoBidTag:tag]) {
                continue;
            }
            NSDictionary *adObject = [[self class] adObjectFromTag:tag];
            if (adObject) {
                ANStandardAd *standardAd = [[self class] standardAdFromRTBObject:adObject];
                if (standardAd) {
                    [self.standardAds addObject:standardAd];
                }
                ANVideoAd *videoAd = [[self class] videoAdFromRTBObject:adObject];
                if (videoAd) {
                    videoAd.vastDataModel.notifyUrlString = [adObject[kANUniversalTagAdServerResponseKeyNotifyUrl] description];
                    [self.videoAds addObject:videoAd];
                }
            }
        }
    }
    self.standardAd = [self.standardAds firstObject];
    self.videoAd = [self.videoAds firstObject];
    if (self.standardAd || self.videoAd) {
        self.containsAds = YES;
    }
}

+ (BOOL)isNoBidTag:(NSDictionary *)tag {
    if (tag[kANUniversalTagAdServerResponseKeyNoBid]) {
        BOOL noBid = [tag[kANUniversalTagAdServerResponseKeyNoBid] boolValue];
        return noBid;
    }
    return NO;
}

+ (NSArray *)tagsFromJSONResponse:(NSDictionary *)jsonResponse {
    return [[self class] validDictionaryArrayForKey:kANUniversalTagAdServerResponseKeyTags
                                     inJSONResponse:jsonResponse];
}

+ (NSDictionary *)adObjectFromTag:(NSDictionary *)tag {
    if ([tag[kANUniversalTagAdServerResponseKeyAd] isKindOfClass:[NSDictionary class]]) {
        return tag[kANUniversalTagAdServerResponseKeyAd];
    }
    return nil;
}


#pragma mark - Universal Tag V2 Support

- (void)processV2ResponseData:(NSData *)data {
    NSDictionary *jsonResponse = [[self class] jsonResponseFromData:data];
    if (jsonResponse) {
        NSArray *tags = [[self class] tagsFromJSONResponse:jsonResponse];
        for (NSDictionary *tag in tags) {
            if ([[self class] isNoBidTag:tag]) {
                continue;
            }
            NSArray *adsArray = [[self class] adsArrayFromTag:tag];
            if (adsArray) {
                for (id adObject in adsArray) {
                    if (![adObject isKindOfClass:[NSDictionary class]]) {
                        continue;
                    }
                    // need trackers
                    NSDictionary *rtbObject = [[self class] rtbObjectFromAdObject:adObject];
                    if (rtbObject) {
                        ANStandardAd *standardAd = [[self class] standardAdFromRTBObject:rtbObject];
                        if (standardAd) {
                            [self.ads addObject:standardAd];
                        }
                        ANVideoAd *videoAd = [[self class] videoAdFromRTBObject:rtbObject];
                        if (videoAd) {
                            videoAd.vastDataModel.notifyUrlString = [adObject[kANUniversalTagAdServerResponseKeyNotifyUrl] description];
                            [self.ads addObject:videoAd];
                        }
                    }
                    NSDictionary *csmObject = [[self class] csmObjectFromAdObject:adObject];
                    if (csmObject) {
                        ANMediatedAd *mediatedAd = [[self class] mediatedAdFromCSMObject:csmObject];
                        if (mediatedAd) {
                            [self.ads addObject:mediatedAd];
                        }
                    }
                    NSDictionary *ssmObject = [[self class] ssmObjectFromAdObject:adObject];
                    if (ssmObject) {
                        // add ssm object to mediated array
                        // add notify url to ssm vast mediated object
                    }
                }
            }
        }
    }
    if (self.ads.count > 0) {
        self.containsAds = YES;
    }
}

+ (NSArray *)adsArrayFromTag:(NSDictionary *)tag {
    if ([tag[kANUniversalTagAdServerResponseKeyAds] isKindOfClass:[NSArray class]]) {
        return tag[kANUniversalTagAdServerResponseKeyAds];
    }
    return nil;
}

+ (NSDictionary *)rtbObjectFromAdObject:(NSDictionary *)adObject {
    if ([adObject[kANUniversalTagAdServerResponseKeyRTBObject] isKindOfClass:[NSDictionary class]]) {
        return adObject[kANUniversalTagAdServerResponseKeyRTBObject];
    }
    return nil;
}

+ (NSDictionary *)csmObjectFromAdObject:(NSDictionary *)adObject {
    if ([adObject[@"csm"] isKindOfClass:[NSDictionary class]]) {
        return adObject[@"csm"];
    }
    return nil;
}

+ (NSDictionary *)ssmObjectFromAdObject:(NSDictionary *)adObject {
    if ([adObject[@"ssm"] isKindOfClass:[NSDictionary class]]) {
        return adObject[@"ssm"];
    }
    return nil;
}

+ (ANStandardAd *)standardAdFromRTBObject:(NSDictionary *)rtbObject {
    if ([rtbObject[kANUniversalTagAdServerResponseKeyBanner] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *banner = rtbObject[kANUniversalTagAdServerResponseKeyBanner];
        ANStandardAd *standardAd = [[ANStandardAd alloc] init];
        standardAd.width = [banner[kANUniversalTagAdServerResponseBannerKeyWidth] description];
        standardAd.height = [banner[kANUniversalTagAdServerResponseBannerKeyHeight] description];
        standardAd.content = [banner[kANUniversalTagAdServerResponseBannerKeyContent] description];
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
    if ([rtbObject[kANUniversalTagAdServerResponseKeyVideo] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *video = rtbObject[kANUniversalTagAdServerResponseKeyVideo];
        ANVideoAd *videoAd = [[ANVideoAd alloc] init];
        videoAd.content = [video[kANUniversalTagAdServerResponseVideoKeyContent] description];
        videoAd.vastDataModel = [[ANVast alloc] initWithContent:videoAd.content];
        if (!videoAd.vastDataModel) {
            ANLogDebug(@"Invalid VAST content, unable to use");
            return nil;
        }
        videoAd.vastDataModel.impressionUrls = [[self class] impressionUrlsFromContentSourceObject:rtbObject];
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

+ (NSArray *)impressionUrlsFromContentSourceObject:(NSDictionary *)contentSourceObject {
    if ([contentSourceObject[@"trackers"] isKindOfClass:[NSArray class]]) {
        NSArray *trackers = contentSourceObject[@"trackers"];
        if ([[trackers firstObject] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *trackerDict = [trackers firstObject];
            if ([trackerDict[@"impression_urls"] isKindOfClass:[NSArray class]]) {
               return trackerDict[@"impression_urls"];
            }
        }
    }
    return nil;
}

#pragma mark - Helper Methods

- (NSMutableArray *)standardAds {
    if (!_standardAds) _standardAds = [[NSMutableArray alloc] init];
    return _standardAds;
}

- (NSMutableArray *)videoAds {
    if (!_videoAds) _videoAds = [[NSMutableArray alloc] init];
    return _videoAds;
}

- (NSMutableArray *)mediatedAds {
    if (!_mediatedAds) _mediatedAds = [[NSMutableArray alloc] init];
    return _mediatedAds;
}

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