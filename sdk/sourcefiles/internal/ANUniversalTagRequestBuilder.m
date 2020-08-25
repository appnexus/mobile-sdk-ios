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

#import "ANUniversalTagRequestBuilder.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANReachability.h"
#import "ANUniversalAdFetcher.h"
#import "ANAdViewInternalDelegate.h"
#import "ANGDPRSettings.h"
#import "ANUSPrivacySettings.h"
#import "ANCarrierObserver.h"
#import "ANMultiAdRequest+PrivateMethods.h"
#import "ANSDKSettings.h"
#import "ANOMIDImplementation.h"

#pragma mark - Private constants.


#pragma mark -

// This protocol definition meant for local use only, to simplify typecasting of MAR Manager objects.
//
@protocol  ANUniversalTagRequestBuilderFetcherDelegate  <ANUniversalRequestTagBuilderDelegate, ANAdProtocolFoundation,
                                                            ANAdProtocolVideo, ANAdProtocolPublicServiceAnnouncement >
    //EMPTY
@end




#pragma mark -

@interface ANUniversalTagRequestBuilder()

// NB  adFetcherDelegate and marManager are mutually exclusive in initialization methods.
//
@property (nonatomic, readwrite, weak)  id<ANUniversalTagRequestBuilderFetcherDelegate>  adFetcherDelegate;

@property (nonatomic, readwrite, weak)  ANMultiAdRequest    *fetcherMARManager;
@property (nonatomic, readwrite, weak)  ANMultiAdRequest    *adunitMARManager;

@end




#pragma mark -

@implementation ANUniversalTagRequestBuilder

#pragma mark Lifecycle.

// NB  Protocol type of adFetcherDelegate can be ANUniversalAdFetcherDelegate or ANUniversalNativeAdFetcherDelegate.
// NB  marManager is defined when this class is involed by MultiAdRequest, otherwise it is nil.
//
+ (nullable NSURLRequest *)buildRequestWithAdFetcherDelegate: (nonnull id)adFetcherDelegate
{
    ANUniversalTagRequestBuilder *requestBuilder = [[ANUniversalTagRequestBuilder alloc] initWithAdFetcherDelegate: adFetcherDelegate
                                                                         optionallyWithAdunitMultiAdRequestManager: nil
                                                                                           orMultiAdRequestManager: nil];
    return [requestBuilder request];
}

+ (nullable NSURLRequest *)buildRequestWithAdFetcherDelegate: (nonnull id)adFetcherDelegate
                                 adunitMultiAdRequestManager: (nonnull ANMultiAdRequest *)adunitMARManager
{
    ANUniversalTagRequestBuilder *requestBuilder = [[ANUniversalTagRequestBuilder alloc] initWithAdFetcherDelegate: adFetcherDelegate
                                                                         optionallyWithAdunitMultiAdRequestManager: adunitMARManager
                                                                                           orMultiAdRequestManager: nil];
    return [requestBuilder request];
}

+ (nullable NSURLRequest *)buildRequestWithMultiAdRequestManager: (nonnull ANMultiAdRequest *)marManager
{
    ANUniversalTagRequestBuilder *requestBuilder =
        [[ANUniversalTagRequestBuilder alloc] initWithAdFetcherDelegate: (id<ANUniversalRequestTagBuilderDelegate>)marManager
                              optionallyWithAdunitMultiAdRequestManager: nil
                                                orMultiAdRequestManager: marManager];
    return [requestBuilder request];
}


- (instancetype)initWithAdFetcherDelegate: (nullable id)adFetcherDelegate
optionallyWithAdunitMultiAdRequestManager: (nullable ANMultiAdRequest *)adunitMARManager
                  orMultiAdRequestManager: (nullable ANMultiAdRequest *)fetcherMARManager
{
    self = [super init];
    if (!self)  { return nil; }


    //
    _adFetcherDelegate  = adFetcherDelegate;
    _fetcherMARManager  = fetcherMARManager;
    _adunitMARManager   = adunitMARManager;
    return self;
}




#pragma mark - UT Request builder methods.

- (NSURLRequest *)request
{
    NSMutableURLRequest  *mutableRequest  = [ANGlobal adServerRequestURL];
    
    NSError       *error       = nil;
    NSData        *postData    = nil;
    NSDictionary  *jsonObject  = [self requestBody];

    if (!jsonObject)
    {
        NSDictionary  *userInfo  = @{ NSLocalizedDescriptionKey : @"[ANUniversalTagRequestBuilder requestBody] returned nil." };
        error = [NSError errorWithDomain:AN_ERROR_DOMAIN code:ANAdResponseCode.INTERNAL_ERROR.code userInfo:userInfo];
    }

    if (!error) {
        postData = [NSJSONSerialization dataWithJSONObject: jsonObject
                                                   options: kNilOptions
                                                     error: &error ];
    }

    if (error) {
        ANLogError(@"Error formulating Universal Tag request: %@", error);
        return nil;
    }

    //
    NSString  *jsonString  = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];

    ANLogDebug(@"Post JSON: %@", jsonString);
    ANLogDebug(@"[self requestBody] = %@", jsonObject);   //DEBUG

    [mutableRequest setHTTPBody:postData];
    return [mutableRequest copy];
}


- (NSDictionary *)requestBody
{
    NSMutableDictionary<NSString *, id>  *requestDict  = [[NSMutableDictionary<NSString *, id> alloc] init];

    
    // Set tags node array.
    //
    NSMutableArray<NSDictionary<NSString *, id> *>  *arrayOfTags  = [[NSMutableArray<NSDictionary<NSString *, id> *> alloc] init];

    if (!self.fetcherMARManager)
    {
        NSDictionary<NSString *, id>  *singleTag =  [self tag:requestDict];

        if (singleTag) {
            arrayOfTags = [@[singleTag] mutableCopy];
        }

    } else {
        NSPointerArray  *arrayOfAdUnits  = [self.fetcherMARManager internalGetAdUnits];

        //
        for (id au in arrayOfAdUnits)
        {
            if (!au) {
                ANLogWarn(@"IGNORING nil ELEMENT in array of AdUnits.");
                continue;
            }
            
            self.adFetcherDelegate = au;

            NSDictionary<NSString *, id>  *tagFromAdUnit  = [self tag:requestDict];

            if (tagFromAdUnit) {
                [arrayOfTags addObject:tagFromAdUnit];
            }
        }

        self.adFetcherDelegate = (id<ANUniversalTagRequestBuilderFetcherDelegate>)self.fetcherMARManager;
    }

    if (arrayOfTags.count > 0) {
        requestDict[@"tags"] = arrayOfTags;
    } else {
        ANLogError(@"FAILED TO GENERATE AT LEAST ONE TAG for this UT Request.");
        return  nil;
    }


    // If the festcher is loading an individual AdUnit that is encapsulated by MultiAdRequest,
    //   begin using the MultiAdRequest context to define page global fields.
    //
    if (!self.fetcherMARManager && self.adunitMARManager) {
        self.fetcherMARManager = self.adunitMARManager;
        self.adFetcherDelegate = (id<ANUniversalTagRequestBuilderFetcherDelegate>)self.adunitMARManager;
    }


    // For MultiAdRequest (AdUnit is encapsulated in MAR): set nodes for member_id and/or publisher_id.
    //   Compare to similar case in [self tag:].
    //
    if (self.fetcherMARManager)
    {
        if (self.fetcherMARManager.memberId > 0) {
            requestDict[@"member_id"] = @(self.fetcherMARManager.memberId);
        }

        if (self.fetcherMARManager.publisherId > 0) {
            requestDict[@"publisher_id"]  = @(self.fetcherMARManager.publisherId);
        }
    }


    // Set remaining page global nodes (user, device, app, keywords, sdk) and other fields.
    //
    NSDictionary<NSString *, id> *user = [self user];
    if (user) {
        requestDict[@"user"] = user;
    }
    
    NSDictionary<NSString *, id> *device = [self device];
    if (device) {
        requestDict[@"device"] = device;
    }
    
    NSDictionary<NSString *, id> *app = [self app];
    if (app) {
        requestDict[@"app"] = app;
    }

    if (self.fetcherMARManager) {
        NSArray<NSSet<NSString *> *>  *keywords  = [self keywords];
        if (keywords) {
            requestDict[@"keywords"] = keywords;
        }
    }
    
    NSDictionary<NSString *, id>  *sdk  = [self sdk];
    if (sdk) {
        requestDict[@"sdk"] = sdk;
    }
    
    requestDict[@"sdkver"] = AN_SDK_VERSION;  //LEGACY.  Replaced by sdk object.
    
    requestDict[@"supply_type"] = @"mobile_app";
    
    
    if(ANSDKSettings.sharedInstance.enableOpenMeasurement){
        requestDict[@"iab_support"]  = [self getIABSupport];
    }

    
    // add GDPR Consent
    NSDictionary *gdprConsent = [self getGDPRConsentObject];
    if (gdprConsent) {
        requestDict[@"gdpr_consent"] = gdprConsent;
    }
    
    // add Facebook bidder token if available
    NSArray *tpuids = [self appendFBToken];
    if(tpuids != nil){
        requestDict[@"tpuids"] = tpuids;
    }
    
    // add USPrivacy String
    NSString *privacyString = [ANUSPrivacySettings getUSPrivacyString];
    if (privacyString.length != 0) {
        requestDict[@"us_privacy"] = privacyString;
    }
    
    NSUInteger auctionTimeout  = [[ANSDKSettings sharedInstance] auctionTimeout];
    if (auctionTimeout > 0 &&  auctionTimeout < NSIntegerMax) {
        requestDict[@"auction_timeout_ms"] = @(auctionTimeout);
    }
    
    
    return [requestDict copy];
}

-(NSString *)getFacebookBidderToken{
    // check to see if an instance of this class exists
    Class csrClass = NSClassFromString(@"ANFBSettings");
    if (!csrClass) {
        ANLogDebug(@"ANFBSettings Class not found");
        return nil;
    }
    SEL  getterMethod  = NSSelectorFromString(@"getBidderToken");
    if ([csrClass respondsToSelector:getterMethod]) {
        IMP methodIMP = [csrClass methodForSelector:getterMethod];
        NSString* (*func)(id,SEL) = (NSString* (*)(id,SEL))methodIMP;
        ANLogDebug(@"FacebookBidderToken : %@",(func)(csrClass, getterMethod));
        return (func)(csrClass, getterMethod);
    }
    return nil;
}

-(NSArray *)appendFBToken{
    NSString *token = [self getFacebookBidderToken];
    if(token != nil){
        NSDictionary *fan = @{
            @"provider"  : @"audienceNetwork",
            @"user_id"   : token
        };
        return @[fan];
    }
    return nil;
}

- (NSDictionary *)tag:(NSMutableDictionary *)requestDict
{
    NSMutableDictionary<NSString *, id>  *tagDict  = [[NSMutableDictionary<NSString *, id> alloc] init];

    
    //
    [self.adFetcherDelegate internalUTRequestUUIDStringReset];

    tagDict[@"uuid"] = [self.adFetcherDelegate internalGetUTRequestUUIDString];

    // For AdUnit (MultiAdRequest is not active): set nodes for member_id and/or publisher_id.
    //   Compare to similar case in [self requestbody].
    //
    NSInteger   placementId  = [[self.adFetcherDelegate placementId] integerValue];
    NSInteger   publisherId  = [self.adFetcherDelegate publisherId];
    NSInteger   memberId     = [self.adFetcherDelegate memberId];
    NSString   *invCode      = [self.adFetcherDelegate inventoryCode];

    if (invCode && memberId>0)
    {
        tagDict[@"code"] = invCode;

        if (!self.fetcherMARManager)
        {
            if (memberId > 0) {
                requestDict[@"member_id"]     = @(memberId);
            }

            if (publisherId > 0) {
                requestDict[@"publisher_id"]  = @(publisherId);
            }
        }

    } else {
        tagDict[@"id"] = @(placementId);
    }
    
    
    // Set nodes for primary_size, sizes, allow_smaller_sizes.
    //
    NSDictionary<NSString *, id>  *delegateReturnDictionary  = [self.adFetcherDelegate internalDelegateUniversalTagSizeParameters];
    
    CGSize                    primarySize         = [[delegateReturnDictionary  objectForKey:ANInternalDelgateTagKeyPrimarySize] CGSizeValue];
    NSMutableSet<NSValue *>  *sizes               = [delegateReturnDictionary   objectForKey:ANInternalDelegateTagKeySizes];
    BOOL                      allowSmallerSizes   = [[delegateReturnDictionary  objectForKey:ANInternalDelegateTagKeyAllowSmallerSizes] boolValue];
    
    tagDict[@"primary_size"] = @{
                                     @"width"  : @(primarySize.width),
                                     @"height" : @(primarySize.height)
                                 };
    
    NSMutableArray<NSDictionary<NSString *, id> *>  *sizesArray  = [[NSMutableArray alloc] init];
    
    for (id sizeElement in sizes)
    {
        if ([sizeElement isKindOfClass:[NSValue class]])
        {
            CGSize  sizeValue  = [sizeElement CGSizeValue];

            [sizesArray addObject: @{
                                         @"width"  : @(sizeValue.width),
                                         @"height" : @(sizeValue.height)
                                     } ];
        }
    }

    tagDict[@"sizes"] = sizesArray;
    
    tagDict[@"allow_smaller_sizes"] = [NSNumber numberWithBool:allowSmallerSizes];
    
    
    //
    tagDict[@"allowed_media_types"] = [self.adFetcherDelegate adAllowedMediaTypes];

    if ([self.adFetcherDelegate respondsToSelector:@selector(forceCreativeId)]){
        NSInteger   forceCreativeId  = [self.adFetcherDelegate forceCreativeId];
        if (forceCreativeId > 0) {
            tagDict[@"force_creative_id"] = @(forceCreativeId);
        }
    }
    
    if(ANSDKSettings.sharedInstance.enableOpenMeasurement){
        [self getAdFramework:tagDict];
    }

    //
    if ([self.adFetcherDelegate respondsToSelector:@selector(shouldServePublicServiceAnnouncements)]) {
        tagDict[@"disable_psa"] = [NSNumber numberWithBool:![self.adFetcherDelegate shouldServePublicServiceAnnouncements]];
    } else {
        tagDict[@"disable_psa"] = [NSNumber numberWithBool:YES];
        
    }
    
    //
    tagDict[@"require_asset_url"] = [NSNumber numberWithBool:0];
    
    NSDictionary<NSString *, id>  *nativeRendererRequest  = [self nativeRendererRequest];
    if (nativeRendererRequest) {
        tagDict[@"native"] = nativeRendererRequest;
    }
    
    NSDictionary *video = [self video];
    if(video){
        tagDict[@"video"] = video;
    }
    
    //
    CGFloat  reservePrice  = [self.adFetcherDelegate reserve];
    if (reservePrice > 0)  {
        tagDict[@"reserve"] = @(reservePrice);
    }

    //
    NSArray<NSSet<NSString *> *>  *keywords  = [self keywords];
    if (keywords) {
        tagDict[@"keywords"] = keywords;
    }

    //
    return [tagDict copy];
}

-(void)getAdFramework:(NSMutableDictionary *)tag{
    
    NSArray *mediaTypes = [self.adFetcherDelegate adAllowedMediaTypes];
    for(int mediaTypeIndex = 0; mediaTypeIndex < mediaTypes.count; mediaTypeIndex++) {
        ANAllowedMediaType mediaType = [mediaTypes[mediaTypeIndex] intValue];
        switch(mediaType)
        {
            case ANAllowedMediaTypeBanner:
            case ANAllowedMediaTypeInterstitial:
                tag[@"banner_frameworks"] =  @[@(6)];
                break;
            case ANAllowedMediaTypeNative:
                tag[@"native_frameworks"] =  @[@(6)];
                break;
            case ANAllowedMediaTypeVideo:
                tag[@"video_frameworks"] =  @[@(6)];
                break;
        }
    }
}

- (NSDictionary<NSString *, id> *)nativeRendererRequest
{
    if ([self.adFetcherDelegate respondsToSelector:@selector(nativeAdRendererId)])
    {
        NSInteger   rendererId              = [self.adFetcherDelegate nativeAdRendererId];
        NSArray    *adAllowedMediaTypes     = [self.adFetcherDelegate adAllowedMediaTypes];

        if ((rendererId != 0) && [adAllowedMediaTypes containsObject:@(ANAllowedMediaTypeNative)])
        {
            return @{
                         @"renderer_id": [NSNumber numberWithInteger:rendererId]
                     };
        }
    }

    return nil;
}


- (NSDictionary<NSString *, id> *) video
{
    NSMutableDictionary<NSString *, id>  *videoDict  = [[NSMutableDictionary alloc] init];

    if ([self.adFetcherDelegate respondsToSelector:@selector(minDuration)])
    {
        NSUInteger minDurationValue = [self.adFetcherDelegate minDuration];

        if (minDurationValue > 0) {
            videoDict[@"minduration"] = @(minDurationValue);
        }
    }

    if ([self.adFetcherDelegate respondsToSelector:@selector(maxDuration)])
    {
        NSUInteger maxDurationValue = [self.adFetcherDelegate maxDuration];

        if (maxDurationValue > 0) {
            videoDict[@"maxduration"] = @(maxDurationValue);
        }
    }

    if ([videoDict count] > 0) {
        return videoDict;
    } else {
        return nil;
    }
}


- (NSDictionary<NSString *, id> *)user
{
    NSMutableDictionary<NSString *, id>  *userDict  = [[NSMutableDictionary<NSString *, id> alloc] init];


    //
    NSInteger ageValue = [[self.adFetcherDelegate age] integerValue];   // TBDFIX  Fails for hyphenated age range.
    if (ageValue > 0) {
        userDict[@"age"] = @(ageValue);
    }


    //
    ANGender    genderValue  = [self.adFetcherDelegate gender];
    NSUInteger  gender;

    switch (genderValue)
    {
        case ANGenderMale:
            gender = 1;
            break;
        case ANGenderFemale:
            gender = 2;
            break;
        default:
            gender = 0;
            break;
    }
    userDict[@"gender"] = @(gender);


    //
    NSString *language = [NSLocale preferredLanguages][0];
    if (language.length) {
        userDict[@"language"] = language;
    }
    
    
    //
    NSString *externalUid = [self.adFetcherDelegate externalUid];
    if (externalUid) {
        userDict[@"external_uid"] = externalUid;
    }


    //
    return [userDict copy];
}

- (NSDictionary<NSString *, id> *)device
{
    NSMutableDictionary<NSString *, id>  *deviceDict  = [[NSMutableDictionary<NSString *, id> alloc] init];


    //
    NSString *userAgent = [ANGlobal getUserAgent];
    if (userAgent) {
        deviceDict[@"useragent"] = userAgent;
    }


    //
    NSDictionary<NSString *, id> *geo = [self geo];
    if (geo) {
        deviceDict[@"geo"] = geo;
    }


    //
    deviceDict[@"make"] = @"Apple";
    
    NSString *deviceModel = ANDeviceModel();
    if (deviceModel) {
        deviceDict[@"model"] = deviceModel;
    }


    //
    ANCarrierObserver   *carrierObserver    = ANCarrierObserver.shared;
    ANCarrierMeta       *carrierMeta        = carrierObserver.carrierMeta;

    if (carrierMeta.name.length > 0) {
        deviceDict[@"carrier"] = carrierMeta.name;
    }
    
    if (carrierMeta.countryCode.length > 0) {
        deviceDict[@"mcc"] = @([carrierMeta.countryCode integerValue]);
    }
    
    if (carrierMeta.networkCode.length > 0) {
        deviceDict[@"mnc"] = @([carrierMeta.networkCode integerValue]);
    }
    
    ANReachability      *reachability    = [ANReachability sharedReachabilityForInternetConnection];
    ANNetworkStatus      status          = [reachability currentReachabilityStatus];
    NSUInteger           connectionType  = 0;

    switch (status) {
        case ANNetworkStatusReachableViaWiFi:
            connectionType = 1;
            break;
        case ANNetworkStatusReachableViaWWAN:
            connectionType = 2;
            break;
        default:
            connectionType = 0;
            break;
    }

    deviceDict[@"connectiontype"] = @(connectionType);


    //
    deviceDict[@"limit_ad_tracking"] = [NSNumber numberWithBool:!ANAdvertisingTrackingEnabled()];
    
    NSDictionary<NSString *, id> *deviceId = [self deviceId];
    if (deviceId) {
        deviceDict[@"device_id"] = deviceId;
    }

    //
    NSInteger timeInMiliseconds = (NSInteger)[[NSDate date] timeIntervalSince1970];
    deviceDict[@"devtime"] = @(timeInMiliseconds);


    //
    return [deviceDict copy];
}

- (NSDictionary<NSString *, id> *)geo
{
    ANLocation  *location  = [self.adFetcherDelegate location];

    if (!location)  { return nil; }
    
    NSMutableDictionary<NSString *, id>  *geoDict  = [[NSMutableDictionary<NSString *, id> alloc] init];


    //
    if (location)
    {
        CGFloat  latitude   = location.latitude;
        CGFloat  longitude  = location.longitude;
        
        if (location.precision >= 0)
        {
            NSNumberFormatter *nf = [[self class] precisionNumberFormatter];

            nf.maximumFractionDigits = location.precision;
            nf.minimumFractionDigits = location.precision;

            geoDict[@"lat"] = [nf numberFromString:[NSString stringWithFormat:@"%f", location.latitude]];
            geoDict[@"lng"] = [nf numberFromString:[NSString stringWithFormat:@"%f", location.longitude]];

        } else {
            geoDict[@"lat"] = @(latitude);
            geoDict[@"lng"] = @(longitude);
        }
        
        NSDate          *locationTimestamp      = location.timestamp;
        NSTimeInterval   ageInSeconds           = -1.0 * [locationTimestamp timeIntervalSinceNow];
        NSInteger        ageInMilliseconds      = (NSInteger)(ageInSeconds * 1000);
        
        geoDict[@"loc_age"]         = @(ageInMilliseconds);
        geoDict[@"loc_precision"]   = @((NSInteger)location.horizontalAccuracy);
    }


    //
    return [geoDict copy];
}

- (NSDictionary<NSString *, id> *)deviceId
{
    if([ANGDPRSettings canAccessDeviceData]){
        return [self fetchAdvertisingIdentifier];
    }
    
    return nil;
}

-(NSDictionary<NSString *, id> *) fetchAdvertisingIdentifier {
    NSString *idfa = ANAdvertisingIdentifier();

    if (idfa) {
        return  @{ @"idfa" : idfa };
    } else {
        return  nil;
    }
}


- (NSDictionary<NSString *, id> *)app
{
    NSString  *appId  = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];

    if (appId) {
        return  @{ @"appid" : appId };
    } else {
        return  nil;
    }
}


// RETURN:  NSArray of NSDictionaries containing key/value pairs where the value is an NSArray of NSString.
//
- (NSArray<NSSet<NSString *> *> *)keywords
{
    NSDictionary<NSString *, NSArray<NSString *> *>  *customKeywords  = [self.adFetcherDelegate customKeywords];

    if ([customKeywords count] <= 0)  { return nil; }


    //
    NSMutableArray<NSDictionary<NSString *, id> *>  *kvSegmentsArray  = [[NSMutableArray<NSDictionary<NSString *, id> *> alloc] init];

    for (NSString *key in customKeywords)
    {
        NSArray<NSString *>  *valueArray  = [customKeywords objectForKey:key];

        if ([valueArray count] <= 0)  {
            ANLogWarn(@"DISCARDING entry with values that are empty arrays.  (%@)", key);
            continue;
        }

        NSSet<NSString *>  *setOfUniqueArrayValues  = [NSSet setWithArray:valueArray];

        [kvSegmentsArray addObject:@{
                                         @"key"      : key,
                                         @"value"    : [setOfUniqueArrayValues allObjects]
                                     } ];
    }

    //
    return [kvSegmentsArray copy];
}


- (NSDictionary *)sdk {
    return  @{
              @"source" : @"ansdk",
              @"version" : AN_SDK_VERSION
              };
}

- (NSDictionary *)getGDPRConsentObject
{
    NSString  *gdprConsent   = [ANGDPRSettings getConsentString];
    NSNumber  *gdprRequired  = [ANGDPRSettings getConsentRequired];
    
    if (gdprRequired != nil)
    {
        return  @{
                     @"consent_required"  : gdprRequired,
                     @"consent_string"    : gdprConsent
                 };

    } else {
        return  nil;
    }
}

- (NSDictionary *)getIABSupport
{
    return  @{
        @"omidpn"  : AN_OMIDSDK_PARTNER_NAME,
        @"omidpv"    : [[ANSDKSettings sharedInstance] sdkVersion]
    };
}



#pragma mark - Class methods.

+ (NSNumberFormatter *)precisionNumberFormatter
{
    static  NSNumberFormatter  *precisionNumberFormatter;
    static  dispatch_once_t     precisionNumberFormatterToken;

    dispatch_once(&precisionNumberFormatterToken, ^{
        precisionNumberFormatter         = [[NSNumberFormatter alloc] init];
        precisionNumberFormatter.locale  = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    });

    return  precisionNumberFormatter;
}

@end
