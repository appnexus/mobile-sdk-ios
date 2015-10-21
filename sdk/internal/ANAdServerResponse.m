/*   Copyright 2014 APPNEXUS INC
 
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

#import "ANAdServerResponse.h"
#import "ANLogging.h"
#import "ANGlobal.h"
#import "ANMediatedAd.h"

static NSString *const kANAdServerResponseKeyStatus = @"status";
static NSString *const kANAdServerResponseKeyType = @"type";
static NSString *const kANAdServerResponseKeyAds = @"ads";
static NSString *const kANAdServerResponseKeyMediatedAds = @"mediated";
static NSString *const kANAdServerResponseKeyNativeAds = @"native";
static NSString *const kANAdServerResponseValueError = @"error";

// Standard
static NSString *const kANAdServerResponseKeyWidth = @"width";
static NSString *const kANAdServerResponseKeyHeight = @"height";
static NSString *const kANAdServerResponseKeyContent = @"content";
static NSString *const kANAdServerResponseMraidJSFilename = @"mraid.js";

// Mediated
static NSString *const kANAdServerResponseValueIOS = @"ios";
static NSString *const kANAdServerResponseKeyHandler = @"handler";
static NSString *const kANAdServerResponseKeyClass = @"class";
static NSString *const kANAdServerResponseKeyId = @"id";
static NSString *const kANAdServerResponseKeyParam = @"param";
static NSString *const kANAdServerResponseKeyResultCB = @"result_cb";
static NSString *const kANAdServerResponseKeyAuctionInfo = @"auction_info";

// Native
static NSString *const kANAdServerResponseKeyNativeMediaType = @"type";
static NSString *const kANAdServerResponseKeyNativeTitle = @"title";
static NSString *const kANAdServerResponseKeyNativeDescription = @"description";
static NSString *const kANAdServerResponseKeyNativeFullText = @"full_text";
static NSString *const kANAdServerResponseKeyNativeContext = @"context";
static NSString *const kANAdServerResponseKeyNativeIconImageUrl = @"icon_img_url";
static NSString *const kANAdServerResponseKeyNativeMainMedia = @"main_media";
static NSString *const kANAdServerResponseKeyNativeMainMediaLabel = @"label";
static NSString *const kANAdServerResponseKeyNativeMainMediaDefaultLabel = @"default";
static NSString *const kANAdServerResponseKeyNativeMainMediaURL = @"url";
static NSString *const kANAdServerResponseKeyNativeCallToAction = @"cta";
static NSString *const kANAdServerResponseKeyNativeClickTrackArray = @"click_trackers";
static NSString *const kANAdServerResponseKeyNativeImpTrackArray = @"impression_trackers";
static NSString *const kANAdServerResponseKeyNativeClickUrl = @"click_url";
static NSString *const kANAdServerResponseKeyNativeClickFallbackUrl = @"click_url_fallback";
static NSString *const kANAdServerResponseKeyNativeRatingDict = @"rating";
static NSString *const kANAdServerResponseKeyNativeRatingValue = @"value";
static NSString *const kANAdServerResponseKeyNativeRatingScale = @"scale";
static NSString *const kANAdServerResponseKeyNativeCustomKeywordsDict = @"custom";

NSString *const kANAdFetcherDidReceiveResponseNotification = @"kANAdFetcherDidReceiveResponseNotification";
NSString *const kANAdFetcherAdResponseKey = @"kANAdFetcherAdResponseKey";

@interface ANAdServerResponse ()

@property (nonatomic, readwrite, assign) BOOL containsAds;
@property (nonatomic, readwrite, strong) ANStandardAd *standardAd;
@property (nonatomic, readwrite, strong) ANNativeStandardAdResponse *nativeAd;
@property (nonatomic, readwrite, strong) NSMutableArray *standardAds;
@property (nonatomic, readwrite, strong) NSMutableArray *mediatedAds;
@property (nonatomic, readwrite, strong) NSMutableArray *nativeAds;

@end

@implementation ANAdServerResponse

- (instancetype)initWithAdServerData:(NSData *)data {
    self = [super init];
    if (self) {
        [self processResponseData:data];
    }
    return self;
}

+ (ANAdServerResponse *)responseWithData:(NSData *)data {
    return [[ANAdServerResponse alloc] initWithAdServerData:data];
}

- (instancetype)initWithContent:(NSString *)htmlContent
                          width:(NSInteger)width
                         height:(NSInteger)height {
    self = [super init];
    if (self) {
        _standardAd = [[ANStandardAd alloc] init];
        _standardAd.width = [NSString stringWithFormat:@"%ld", (long)width];
        _standardAd.height = [NSString stringWithFormat:@"%ld", (long)height];
        _standardAd.content = htmlContent;
        _containsAds = YES;
    }
    return self;
}

- (void)processResponseData:(NSData *)data {
    NSDictionary *jsonResponse = [[self class] jsonResponseFromData:data];
    if (jsonResponse) {
        BOOL isError = [[self class] errorStatusForJSONResponse:jsonResponse];
        if (!isError) {
            self.standardAds = [[self class] standardAdsFromJSONResponse:jsonResponse];
            self.standardAd = [self.standardAds firstObject];
            self.mediatedAds = [[self class] mediatedAdsFromJSONResponse:jsonResponse];
            self.nativeAds = [[self class] nativeAdsFromJSONResponse:jsonResponse];
            self.nativeAd = [self.nativeAds firstObject];
            if (self.standardAd || self.mediatedAds.count || self.nativeAds.count) {
                self.containsAds = YES;
            }
        }
    }
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

+ (BOOL)errorStatusForJSONResponse:(NSDictionary *)jsonResponse {
    NSString *status = jsonResponse[kANAdServerResponseKeyStatus];
    if ([status isEqualToString:kANAdServerResponseValueError]) {
        ANLogError(@"response_error %@", jsonResponse);
        return YES;
    }
    return NO;
}

+ (NSMutableArray *)mediatedAdsFromJSONResponse:(NSDictionary *)jsonResponse {
    NSArray *mediatedAdDictArray = [[self class] validDictionaryArrayForKey:kANAdServerResponseKeyMediatedAds
                                                             inJSONResponse:jsonResponse];
    NSMutableArray *parsedMediatedAdObjects = [[NSMutableArray alloc] init];
    [mediatedAdDictArray enumerateObjectsUsingBlock:^(NSDictionary *mediatedAdDict, NSUInteger idx, BOOL *stop) {
        ANMediatedAd *mediatedAd = [[self class] parseMediatedAdFromDictionary:mediatedAdDict];
        if (mediatedAd) {
            [parsedMediatedAdObjects addObject:mediatedAd];
        }
    }];
    return parsedMediatedAdObjects;
}

+ (NSMutableArray *)standardAdsFromJSONResponse:(NSDictionary *)jsonResponse {
    NSArray *standardAdDictArray = [[self class] validDictionaryArrayForKey:kANAdServerResponseKeyAds
                                                             inJSONResponse:jsonResponse];
    NSMutableArray *parsedStandardAdObjects = [[NSMutableArray alloc] init];
    [standardAdDictArray enumerateObjectsUsingBlock:^(NSDictionary *standardAdDict, NSUInteger idx, BOOL *stop) {
        ANStandardAd *standardAd = [[self class] parseStandardAdFromDictionary:standardAdDict];
        if (standardAd) {
            [parsedStandardAdObjects addObject:standardAd];
        }
    }];
    return parsedStandardAdObjects;
}

+ (NSMutableArray *)nativeAdsFromJSONResponse:(NSDictionary *)jsonResponse {
    NSArray *nativeAdDictArray = [[self class] validDictionaryArrayForKey:kANAdServerResponseKeyNativeAds
                                                           inJSONResponse:jsonResponse];
    NSMutableArray *parsedNativeAdObjects = [[NSMutableArray alloc] init];
    [nativeAdDictArray enumerateObjectsUsingBlock:^(NSDictionary *nativeAdDict, NSUInteger idx, BOOL *stop) {
        ANNativeStandardAdResponse *nativeAd = [[self class] parseNativeAdFromDictionary:nativeAdDict];
        if (nativeAd) {
            [parsedNativeAdObjects addObject:nativeAd];
        }
    }];
    return parsedNativeAdObjects;
}

+ (NSMutableArray *)validDictionaryArrayForKey:(NSString *)key
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
            return validAdsArray;
        }
    }
    return nil;
}

+ (ANStandardAd *)parseStandardAdFromDictionary:(NSDictionary *)standardAdDict {
    if (standardAdDict) {
        ANStandardAd *ad = [[ANStandardAd alloc] init];
        ad.type = [standardAdDict[kANAdServerResponseKeyType] description];
        ad.width = [standardAdDict[kANAdServerResponseKeyWidth] description];
        ad.height = [standardAdDict[kANAdServerResponseKeyHeight] description];
        ad.content = [standardAdDict[kANAdServerResponseKeyContent] description];
        if (!ad.content || [ad.content length] == 0) {
            ANLogError(@"blank_ad");
            return nil;
        }
        NSRange mraidJSRange = [ad.content rangeOfString:kANAdServerResponseMraidJSFilename];
        if (mraidJSRange.location != NSNotFound) {
            ad.mraid = YES;
        }
        return ad;
    }
    return nil;
}

+ (ANMediatedAd *)parseMediatedAdFromDictionary:(NSDictionary *)mediatedAdDict {
    if ([mediatedAdDict[kANAdServerResponseKeyHandler] isKindOfClass:[NSArray class]]) {
        ANMediatedAd *mediatedAd;
        NSArray *handlerArray = (NSArray *)mediatedAdDict[kANAdServerResponseKeyHandler];
        for (id handlerObject in handlerArray) {
            if ([handlerObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *handlerDict = (NSDictionary *)handlerObject;
                NSString *type = [handlerDict[kANAdServerResponseKeyType] description];
                if ([type.lowercaseString isEqualToString:kANAdServerResponseValueIOS]) {
                    NSString *className = [handlerDict[kANAdServerResponseKeyClass] description];
                    if ([className length] == 0) {
                        return nil;
                    }
                    mediatedAd = [[ANMediatedAd alloc] init];
                    mediatedAd.className = className;
                    mediatedAd.param = [handlerDict[kANAdServerResponseKeyParam] description];
                    mediatedAd.width = [handlerDict[kANAdServerResponseKeyWidth] description];
                    mediatedAd.height = [handlerDict[kANAdServerResponseKeyHeight] description];
                    mediatedAd.adId = [handlerDict[kANAdServerResponseKeyId] description];
                    break;
                }
            }
        }
        mediatedAd.resultCB = [mediatedAdDict[kANAdServerResponseKeyResultCB] description];
        mediatedAd.auctionInfo = [mediatedAdDict[kANAdServerResponseKeyAuctionInfo] description];
        return mediatedAd;
    }
    return nil;
}

+ (ANNativeStandardAdResponse *)parseNativeAdFromDictionary:(NSDictionary *)nativeAdDict {
    if (nativeAdDict) {
        ANNativeStandardAdResponse *nativeAd = [[ANNativeStandardAdResponse alloc] init];
        
        if ([nativeAdDict[kANAdServerResponseKeyNativeMediaType] isKindOfClass:[NSString class]]) {
            nativeAd.mediaType = nativeAdDict[kANAdServerResponseKeyNativeMediaType];
        }
        if ([nativeAdDict[kANAdServerResponseKeyNativeTitle] isKindOfClass:[NSString class]]) {
            nativeAd.title = nativeAdDict[kANAdServerResponseKeyNativeTitle];
        }
        if ([nativeAdDict[kANAdServerResponseKeyNativeDescription] isKindOfClass:[NSString class]]) {
            nativeAd.body = nativeAdDict[kANAdServerResponseKeyNativeDescription];
        }
        if ([nativeAdDict[kANAdServerResponseKeyNativeFullText] isKindOfClass:[NSString class]]) {
            nativeAd.fullText = nativeAdDict[kANAdServerResponseKeyNativeFullText];
        }
        if ([nativeAdDict[kANAdServerResponseKeyNativeContext] isKindOfClass:[NSString class]]) {
            nativeAd.socialContext = nativeAdDict[kANAdServerResponseKeyNativeContext];
        }
        if ([nativeAdDict[kANAdServerResponseKeyNativeCallToAction] isKindOfClass:[NSString class]]) {
            nativeAd.callToAction = nativeAdDict[kANAdServerResponseKeyNativeCallToAction];
        }

        NSString *iconImageURLString = [nativeAdDict[kANAdServerResponseKeyNativeIconImageUrl] description];
        NSString *clickURLString = [nativeAdDict[kANAdServerResponseKeyNativeClickUrl] description];
        NSString *clickURLFallbackString = [nativeAdDict[kANAdServerResponseKeyNativeClickFallbackUrl] description];

        nativeAd.iconImageURL = [NSURL URLWithString:iconImageURLString];
        nativeAd.clickURL = [NSURL URLWithString:clickURLString];
        nativeAd.clickFallbackURL = [NSURL URLWithString:clickURLFallbackString];
        
        if ([nativeAdDict[kANAdServerResponseKeyNativeMainMedia] isKindOfClass:[NSArray class]]) {
            NSArray *mainMedia = nativeAdDict[kANAdServerResponseKeyNativeMainMedia];
            [mainMedia enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *mainImageData = obj;
                    NSString *labelValue = [mainImageData[kANAdServerResponseKeyNativeMainMediaLabel] description];
                    if ([labelValue isEqualToString:kANAdServerResponseKeyNativeMainMediaDefaultLabel]) {
                        NSString *mainImageURLString = [[mainImageData objectForKey:kANAdServerResponseKeyNativeMainMediaURL] description];
                        nativeAd.mainImageURL = [NSURL URLWithString:mainImageURLString];
                        *stop = YES;
                    }
                }
            }];
        }
        
        if ([nativeAdDict[kANAdServerResponseKeyNativeClickTrackArray] isKindOfClass:[NSArray class]]) {
            NSArray *clickTrackArray = nativeAdDict[kANAdServerResponseKeyNativeClickTrackArray];
            NSMutableArray *clickTrackURLs = [[NSMutableArray alloc] initWithCapacity:clickTrackArray.count];
            [clickTrackArray enumerateObjectsUsingBlock:^(id clickTrackElement, NSUInteger idx, BOOL *stop) {
                NSURL *clickURL = [NSURL URLWithString:[clickTrackElement description]];
                if (clickURL) {
                    [clickTrackURLs addObject:clickURL];
                }
            }];
            nativeAd.clickTrackers = [clickTrackURLs copy];
        }
        if ([nativeAdDict[kANAdServerResponseKeyNativeImpTrackArray] isKindOfClass:[NSArray class]]) {
            NSArray *impTrackerArray = nativeAdDict[kANAdServerResponseKeyNativeImpTrackArray];
            NSMutableArray *impTrackURLs = [[NSMutableArray alloc] initWithCapacity:impTrackerArray.count];
            [impTrackerArray enumerateObjectsUsingBlock:^(id impTrackerElement, NSUInteger idx, BOOL *stop) {
                NSURL *impURL = [NSURL URLWithString:[impTrackerElement description]];
                if (impURL) {
                    [impTrackURLs addObject:impURL];
                }
            }];
            nativeAd.impTrackers = [impTrackURLs copy];
        }
        if ([nativeAdDict[kANAdServerResponseKeyNativeCustomKeywordsDict] isKindOfClass:[NSDictionary class]]) {
            nativeAd.customElements = (NSDictionary *)nativeAdDict[kANAdServerResponseKeyNativeCustomKeywordsDict];
        }
        if ([nativeAdDict[kANAdServerResponseKeyNativeRatingDict] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *rating = (NSDictionary *)nativeAdDict[kANAdServerResponseKeyNativeRatingDict];
            NSNumber *ratingScale = @(0);
            NSNumber *ratingValue = @(0);
            
            if ([rating[kANAdServerResponseKeyNativeRatingScale] isKindOfClass:[NSNumber class]]) {
                ratingScale = rating[kANAdServerResponseKeyNativeRatingScale];
            }
            if ([rating[kANAdServerResponseKeyNativeRatingValue] isKindOfClass:[NSNumber class]]) {
                ratingValue = rating[kANAdServerResponseKeyNativeRatingValue];
            }
            nativeAd.rating = [[ANNativeAdStarRating alloc] initWithValue:[ratingValue floatValue]
                                                                    scale:[ratingScale integerValue]];
        }
        return nativeAd;
    }
    return nil;
}

@end