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

#import "ANNativeAdRequestUrlBuilder.h"
#import "ANNativeAdFetcher.h"

#import "NSString+ANCategory.h"
#import "ANReachability.h"
#import "ANLogging.h"

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "ANNativeMediatedAdController.h"

static NSString *const kANNativeAdRequestUrlBuilderQueryStringSeparator = @"&";

@interface ANNativeAdRequestUrlBuilder ()
@property (nonatomic, readwrite, strong) NSString *baseUrlString;
@property (nonatomic, readwrite, weak) id<ANNativeAdFetcherDelegate> adRequestDelegate;
@end

@implementation ANNativeAdRequestUrlBuilder

- (instancetype)initWithAdRequestDelegate:(id<ANNativeAdFetcherDelegate>)delegate
                            baseUrlString:(NSString *)baseUrlString {
    self = [super init];
    if (self) {
        _adRequestDelegate = delegate;
        _baseUrlString = baseUrlString;
    }
    return self;
}

+ (NSURL *)requestUrlWithAdRequestDelegate:(id<ANNativeAdFetcherDelegate>)delegate
                             baseUrlString:(NSString *)baseUrlString {
    ANNativeAdRequestUrlBuilder *urlBuilder = [[ANNativeAdRequestUrlBuilder alloc] initWithAdRequestDelegate:delegate
                                                                                               baseUrlString:baseUrlString];
    return [urlBuilder requestUrl];
}

- (NSURL *)requestUrl {
    NSString *urlString = [self.baseUrlString stringByAppendingFormat:@"?%@", [self queryString]];
    return [NSURL URLWithString:urlString];
}

- (NSString *)queryString {
    NSMutableArray *queryStringParameters = [[NSMutableArray alloc] init];
    [queryStringParameters addObject:[self placementIdentifierParameter]];
    [queryStringParameters addObject:[self idfaParameter]];
    [queryStringParameters addObject:[self dontTrackEnabledParameter]];
    [queryStringParameters addObjectsFromArray:@[[self deviceMakeParameter], [self deviceModelParameter]]];
    [queryStringParameters addObject:[self carrierMccMncParameters]];
    [queryStringParameters addObject:[self applicationIdParameter]];
    [queryStringParameters addObject:[self firstLaunchParameter]];
    
    [queryStringParameters addObject:[self locationParameter]];
    [queryStringParameters addObject:[self userAgentParameter]];
    [queryStringParameters addObject:[self connectionTypeParameter]];
    [queryStringParameters addObject:[self devTimeParameter]];
    [queryStringParameters addObject:[self languageParameter]];
    
    [queryStringParameters addObject:[self reserveParameter]];
    [queryStringParameters addObjectsFromArray:@[[self ageParameter], [self genderParameter]]];
    
    [queryStringParameters addObject:[self nonetParameter]];
    
    [queryStringParameters addObject:[self jsonFormatParameter]];
    [queryStringParameters addObject:[self supplyTypeParameter]];
    [queryStringParameters addObject:[self sdkVersionParameter]];
    
    [queryStringParameters addObject:[self customKeywordsParameter]];
    [queryStringParameters addObject:[self sizeParameter]];
    
    [queryStringParameters removeObject:@""];
    return [queryStringParameters componentsJoinedByString:kANNativeAdRequestUrlBuilderQueryStringSeparator];
}

- (NSSet*)getParameterNames {
    NSSet* pNames = [NSSet setWithObjects:
                     @"id",
                     @"LimitAdTrackingEnabled",
                     @"devmake",
                     @"devmodel",
                     @"appid",
                     @"firstlaunch",
                     @"carrier",
                     @"mcc",
                     @"mnc",
                     @"connection_type",
                     @"loc",
                     @"loc_age",
                     @"loc_prec",
                     @"orientation",
                     @"ua",
                     @"language",
                     @"devtime",
                     @"format",
                     @"st",
                     @"sdkver",
                     @"size",
                     nil];
    return pNames;
}

- (BOOL)stringInParameterList:(NSString*)s {
    NSSet* pNames = [self getParameterNames];
    if([pNames containsObject:s]){
        return YES;
    }
    
    return NO;
}

- (NSString *)URLEncodingFrom:(NSString *)originalString {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)originalString,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]<>",
                                                                                 kCFStringEncodingUTF8);
}

- (NSString *)idfaParameter {
    NSString *idfa = ANUDID();
    if ([idfa isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
        ANLogInfo(@"IDFA is sentinel value, not sending to server");
        return @"";
    }
    return [NSString stringWithFormat:@"idfa=%@", [self URLEncodingFrom:idfa]];
}

- (NSString *)placementIdentifierParameter {
    NSString *invCode = [self.adRequestDelegate inventoryCode];
    NSInteger memberId = [self.adRequestDelegate memberId];
    if (memberId > 0 && invCode) {
        return [NSString stringWithFormat:@"member=%d&inv_code=%@", (int)memberId, [self URLEncodingFrom:invCode]];
    }
    NSString *placementId = [self.adRequestDelegate placementId];
    
    if ([placementId length] < 1) {
        return @"";
    }
    
    return [NSString stringWithFormat:@"id=%@", [self URLEncodingFrom:placementId]];
}

- (NSString *)dontTrackEnabledParameter {
    return ANAdvertisingTrackingEnabled() ? @"LimitAdTrackingEnabled=0" : @"LimitAdTrackingEnabled=1";
}

- (NSString *)deviceMakeParameter {
    return @"devmake=Apple";
}

- (NSString *)deviceModelParameter {
    return [NSString stringWithFormat:@"devmodel=%@", [self URLEncodingFrom:ANDeviceModel()]];
}

- (NSString *)applicationIdParameter {
    NSString *appId = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
    return [NSString stringWithFormat:@"appid=%@", appId];
}

- (NSString *)firstLaunchParameter {
    return ANIsFirstLaunch() ? @"firstlaunch=true" : @"";
}

- (NSString *)carrierMccMncParameters {
    NSMutableArray *param = [[NSMutableArray alloc] init];
    
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    
    if ([[carrier carrierName] length] > 0) {
        NSString *carrierNameParam = [NSString stringWithFormat:@"carrier=%@", [self URLEncodingFrom:[carrier carrierName]]];
        [param addObject:carrierNameParam];
    }
    
    if ([[carrier mobileCountryCode] length] > 0) {
        NSString *mccParam = [NSString stringWithFormat:@"mcc=%@", [self URLEncodingFrom:[carrier mobileCountryCode]]];
        [param addObject:mccParam];
    }
    
    if ([[carrier mobileNetworkCode] length] > 0) {
        NSString *mncParam = [NSString stringWithFormat:@"mnc=%@", [self URLEncodingFrom:[carrier mobileNetworkCode]]];
        [param addObject:mncParam];
    }
    
    return [param componentsJoinedByString:kANNativeAdRequestUrlBuilderQueryStringSeparator];
}

- (NSString *)connectionTypeParameter {
    ANReachability *reachability = [ANReachability reachabilityForInternetConnection];
    ANNetworkStatus status = [reachability currentReachabilityStatus];
    return status == ANNetworkStatusReachableViaWiFi ? @"connection_type=wifi" : @"connection_type=wan";
}

- (NSString *)locationParameter {
    ANLocation *location = [self.adRequestDelegate location];
    NSMutableArray *param = [[NSMutableArray alloc] init];

    if (location) {
        NSDate *locationTimestamp = location.timestamp;
        NSTimeInterval ageInSeconds = -1.0 * [locationTimestamp timeIntervalSinceNow];
        NSInteger ageInMilliseconds = (NSInteger)(ageInSeconds * 1000);
        
        if (location.precision >= 0) {
            [param addObject:[NSString stringWithFormat:@"loc=%.*f%%2C%.*f",
                              (int)location.precision, location.latitude, (int)location.precision, location.longitude]];
        } else {
            [param addObject:[NSString stringWithFormat:@"loc=%f%%2C%f",
                              location.latitude, location.longitude]];
        }
        
        [param addObject:[NSString stringWithFormat:@"loc_age=%ld",(long)ageInMilliseconds]];
        [param addObject:[NSString stringWithFormat:@"loc_prec=%f",location.horizontalAccuracy]];
    }
    
    return [param componentsJoinedByString:kANNativeAdRequestUrlBuilderQueryStringSeparator];
}

- (NSString *)userAgentParameter {
    return [NSString stringWithFormat:@"ua=%@",
            [self URLEncodingFrom:ANUserAgent()]];
}

- (NSString *)languageParameter {
    NSString *language = [NSLocale preferredLanguages][0];
    return ([language length] > 0) ? [NSString stringWithFormat:@"language=%@", [self URLEncodingFrom:language]] : @"";
}

- (NSString *)devTimeParameter {
    int timeInMiliseconds = (int) [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"devtime=%d", timeInMiliseconds];
}

- (NSString *)reserveParameter {
    CGFloat reserve = [self.adRequestDelegate reserve];
    if (reserve > 0.0f) {
        NSString *reserveParameter = [self URLEncodingFrom:[NSString stringWithFormat:@"%f", reserve]];
        return [NSString stringWithFormat:@"reserve=%@", reserveParameter];
    } else {
        return @"";
    }
}

- (NSString *)ageParameter {
    NSString *ageValue = [self.adRequestDelegate age];
    if ([ageValue length] < 1) {
        return @"";
    }
    
    return [NSString stringWithFormat:@"age=%@", [self URLEncodingFrom:ageValue]];
}

- (NSString *)genderParameter {
    ANGender genderValue = [self.adRequestDelegate gender];
    if (genderValue == ANGenderMale) {
        return @"gender=m";
    } else if (genderValue == ANGenderFemale) {
        return @"gender=f";
    } else {
        return @"";
    }
}

- (NSString *)customKeywordsParameter {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSMutableDictionary *customKeywords = [self.adRequestDelegate customKeywords];
#pragma clang diagnostic pop
    NSMutableDictionary<NSString *, NSArray<NSString *> *> *customKeywordsMap = [[self.adRequestDelegate customKeywordsMap] mutableCopy];
    
    [customKeywords enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        key = ANConvertToNSString(key);
        value = ANConvertToNSString(value);
        if (customKeywordsMap[key] == nil) {
            customKeywordsMap[key] = [[NSMutableArray alloc] init];
        }
        if (![customKeywordsMap[key] containsObject:value]) {
            NSMutableArray *valueArray = [customKeywordsMap[key] mutableCopy];
            [valueArray addObject:value];
            customKeywordsMap[key] = valueArray;
        }
    }];

    if ([customKeywordsMap count] < 1) {
        return @"";
    }
    
    NSMutableArray *param = [[NSMutableArray alloc] init];
    [customKeywordsMap enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray<NSString *> *valueArray, BOOL *stop) {
        if(![self stringInParameterList:key]){
            for (NSString *valueString in valueArray) {
                [param addObject:[NSString stringWithFormat:@"%@=%@",key,
                                  [self URLEncodingFrom:valueString]]];
            }
        } else {
            ANLogWarn(@"request_parameter_override_attempt %@", key);
        }
    }];
    
    return [param componentsJoinedByString:kANNativeAdRequestUrlBuilderQueryStringSeparator];
}

- (NSString *)nonetParameter {
    NSArray *invalidNetworks = [[ANNativeMediatedAdController invalidNetworks] allObjects];
    return [invalidNetworks count] ? [NSString stringWithFormat:@"nonet=%@", [invalidNetworks componentsJoinedByString:@"%2C"]] : @"";
}

- (NSString *)jsonFormatParameter {
    return @"format=json";
}

- (NSString *)supplyTypeParameter {
    return @"st=mobile_app";
}

- (NSString *)sdkVersionParameter {
    return [NSString stringWithFormat:@"sdkver=%@", AN_SDK_VERSION];
}

- (NSString *)sizeParameter {
    return @"size=1x1";
}

@end
