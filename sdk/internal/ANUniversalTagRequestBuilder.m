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
#import "ANInterstitialAdFetcher.h"

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface ANUniversalTagRequestBuilder()

@property (nonatomic, readwrite, weak) id<ANAdFetcherDelegate> adFetcherDelegate;
@property (nonatomic) NSString *baseURLString;

@end

@implementation ANUniversalTagRequestBuilder

+ (NSURLRequest *)buildRequestWithAdFetcherDelegate:(id<ANAdFetcherDelegate>)adFetcherDelegate
                                      baseUrlString:(NSString *)baseUrlString {
    ANUniversalTagRequestBuilder *requestBuilder = [[ANUniversalTagRequestBuilder alloc] initWithAdFetcherDelegate:adFetcherDelegate
                                                                                                     baseUrlString:baseUrlString];
    return [requestBuilder request];
}

- (instancetype)initWithAdFetcherDelegate:(id<ANAdFetcherDelegate>)adFetcherDelegate
                            baseUrlString:(NSString *)baseUrlString {
    if (self = [super init]) {
        _adFetcherDelegate = adFetcherDelegate;
        _baseURLString = baseUrlString;
    }
    return self;
}

- (NSURLRequest *)request {
    NSURL *URL = [NSURL URLWithString:self.baseURLString];
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:URL
                                                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                   timeoutInterval:kAppNexusRequestTimeoutInterval];
    [mutableRequest setValue:ANUserAgent() forHTTPHeaderField:@"User-Agent"];
    [mutableRequest setHTTPMethod:@"POST"];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:[self requestBody]
                                                       options:kNilOptions
                                                         error:&error];
    if (!error) {
        NSString *jsonString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        ANLogDebug(@"Post JSON: %@", jsonString);
        [mutableRequest setHTTPBody:postData];
        return [mutableRequest copy];
    } else {
        ANLogError(@"Error formulating Universal Tag request: %@", error);
        return nil;
    }
}

- (NSDictionary *)requestBody {
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    NSDictionary *tags = [self tag:requestDict];
    if (tags) {
        requestDict[@"tags"] = @[tags];
    }
    NSDictionary *user = [self user];
    if (user) {
        requestDict[@"user"] = user;
    }
    NSDictionary *device = [self device];
    if (device) {
        requestDict[@"device"] = device;
    }
    NSDictionary *app = [self app];
    if (app) {
        requestDict[@"app"] = app;
    }
    NSArray *keywords = [self keywords];
    if (keywords) {
        requestDict[@"keywords"] = keywords;
    }
    
    return [requestDict copy];
}

- (NSArray *)keywords {
    NSDictionary *customKeywords = [self.adFetcherDelegate customKeywords];
    if (customKeywords.count < 1) {
        return nil;
    }
    
    NSMutableArray *kvSegmentsArray = [[NSMutableArray alloc] init];
    [customKeywords enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *stringKey = ANConvertToNSString(key);
        NSString *stringValue = ANConvertToNSString(value);
        if (stringKey.length > 0 && stringValue.length > 0) {
            [kvSegmentsArray addObject:@{@"key":stringKey, @"value":stringValue}];
        }
    }];
    return [kvSegmentsArray copy];
}

- (NSDictionary *)tag:(NSMutableDictionary *) requestDict {
    NSMutableDictionary *tagDict = [[NSMutableDictionary alloc] init];
    NSInteger placementId = [[self.adFetcherDelegate placementId] integerValue];

    NSString *invCode = [self.adFetcherDelegate inventoryCode];
    NSInteger memberId = [self.adFetcherDelegate memberId];
    if(invCode && memberId>0){
        tagDict[@"code"] = invCode;
        requestDict[@"member_id"] = @(memberId);
    }else {
        tagDict[@"id"] = @(placementId);
    }
    
    if ([self.adFetcherDelegate conformsToProtocol:@protocol(ANInterstitialAdFetcherDelegate)]) {
        id<ANInterstitialAdFetcherDelegate> interstitialDelegate = (id<ANInterstitialAdFetcherDelegate>)self.adFetcherDelegate;
        NSMutableSet *allowedSizes = [[interstitialDelegate allowedAdSizes] mutableCopy];
        if (allowedSizes == nil) {
            allowedSizes = [[NSMutableSet alloc] init];
        }
        [allowedSizes addObject:[NSValue valueWithCGSize:interstitialDelegate.screenSize]];
        [allowedSizes addObject:[NSValue valueWithCGSize:CGSizeMake(1, 1)]];
        NSMutableArray *sizeObjectArray = [[NSMutableArray alloc] init];
        for (id sizeValue in allowedSizes) {
            if ([sizeValue isKindOfClass:[NSValue class]]) {
                CGSize size = [sizeValue CGSizeValue];
                [sizeObjectArray addObject:@{@"width":@(size.width),
                                             @"height":@(size.height)}];
            }
        }
        tagDict[@"sizes"] = sizeObjectArray;
    }
    tagDict[@"allowed_media_types"] = @[@(1),@(3),@(4)];
    tagDict[@"disable_psa"] = @(![self.adFetcherDelegate shouldServePublicServiceAnnouncements]);
    return [tagDict copy];
}

- (NSDictionary *)user {
    NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
    
    NSInteger ageValue = [[self.adFetcherDelegate age] integerValue]; // Invalid value for hyphenated age
    if (ageValue > 0) {
        userDict[@"age"] = @(ageValue);
    }
    
    ANGender genderValue = [self.adFetcherDelegate gender];
    NSUInteger gender;
    switch (genderValue) {
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
    
    NSString *language = [NSLocale preferredLanguages][0];
    if (language.length) {
        userDict[@"language"] = language;
    }
    
    return [userDict copy];
}

- (NSDictionary *)device {
    NSMutableDictionary *deviceDict = [[NSMutableDictionary alloc] init];
    
    NSString *userAgent = ANUserAgent();
    if (userAgent) {
        deviceDict[@"useragent"] = userAgent;
    }
    
    NSDictionary *geo = [self geo];
    if (geo) {
        deviceDict[@"geo"] = geo;
    }
    
    deviceDict[@"make"] = @"Apple";
    
    NSString *deviceModel = ANDeviceModel();
    if (deviceModel) {
        deviceDict[@"model"] = deviceModel;
    }
    
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    
    if (carrier.carrierName.length > 0) {
        deviceDict[@"carrier"] = carrier.carrierName;
    }
    
    ANReachability *reachability = [ANReachability reachabilityForInternetConnection];
    ANNetworkStatus status = [reachability currentReachabilityStatus];
    NSUInteger connectionType = 0;
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
    
    if (carrier.mobileCountryCode.length > 0) {
        deviceDict[@"mcc"] = @([carrier.mobileCountryCode integerValue]);
    }
    if (carrier.mobileNetworkCode.length > 0) {
        deviceDict[@"mnc"] = @([carrier.mobileNetworkCode integerValue]);
    }
    
    
    deviceDict[@"limit_ad_tracking"] = @(!ANAdvertisingTrackingEnabled());
    
    NSDictionary *deviceId = [self deviceId];
    if (deviceId) {
        deviceDict[@"device_id"] = deviceId;
    }
    
    NSInteger timeInMiliseconds = (NSInteger)[[NSDate date] timeIntervalSince1970];
    deviceDict[@"devtime"] = @(timeInMiliseconds);
    
    return [deviceDict copy];
}

- (NSDictionary *)deviceId {
    NSString *idfa = ANUDID();
    if (idfa) {
        return @{@"idfa":idfa};
    } else {
        return nil;
    }
}

- (NSDictionary *)geo {
    ANLocation *location = [self.adFetcherDelegate location];
    if (location) {
        NSMutableDictionary *geoDict = [[NSMutableDictionary alloc] init];
        
        CGFloat latitude = location.latitude;
        CGFloat longitude = location.longitude;
        
        if (location.precision >= 0) {
            NSNumberFormatter *nf = [[self class] precisionNumberFormatter];
            nf.maximumFractionDigits = location.precision;
            nf.minimumFractionDigits = location.precision;
            geoDict[@"lat"] = [nf numberFromString:[NSString stringWithFormat:@"%f", location.latitude]];
            geoDict[@"lng"] = [nf numberFromString:[NSString stringWithFormat:@"%f", location.longitude]];
        } else {
            geoDict[@"lat"] = @(latitude);
            geoDict[@"lng"] = @(longitude);
        }
        
        NSDate *locationTimestamp = location.timestamp;
        NSTimeInterval ageInSeconds = -1.0 * [locationTimestamp timeIntervalSinceNow];
        NSInteger ageInMilliseconds = (NSInteger)(ageInSeconds * 1000);
        
        geoDict[@"loc_age"] = @(ageInMilliseconds);
        geoDict[@"loc_precision"] = @((NSInteger)location.horizontalAccuracy);
        
        return [geoDict copy];
    } else {
        return nil;
    }
}

+ (NSNumberFormatter *)precisionNumberFormatter {
    static dispatch_once_t precisionNumberFormatterToken;
    static NSNumberFormatter *precisionNumberFormatter;
    dispatch_once(&precisionNumberFormatterToken, ^{
        precisionNumberFormatter = [[NSNumberFormatter alloc] init];
        precisionNumberFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    });
    return precisionNumberFormatter;
}

- (NSDictionary *)app {
    NSString *appId = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
    if (appId) {
        return @{@"appid":appId};
    } else {
        return nil;
    }
}

@end