/*   Copyright 2013 APPNEXUS INC
 
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

#import "ANAdRequestUrl.h"

#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANReachability.h"
#import "NSString+ANCategory.h"

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "ANMediationAdViewController.h"
#import "ANBannerAdView.h"
#import "ANInterstitialAd.h"

@interface ANAdRequestUrl()
@property (nonatomic, readwrite, weak) id<ANAdFetcherDelegate> adFetcherDelegate;
@end



@implementation ANAdRequestUrl

- (NSSet*)getParameterNames{
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
                     @"native_browser",
                     @"psa",
                     @"format",
                     @"st",
                     @"sdkver",
                     nil];
    
    return pNames;
}

- (BOOL) stringInParameterList:(NSString*)s{
    NSSet* pNames = [self getParameterNames];
    if([pNames containsObject:s]){
        return YES;
    }
    
    return NO;
}

+ (NSURL *)buildRequestUrlWithAdFetcherDelegate:(id<ANAdFetcherDelegate>)adFetcherDelegate
                                  baseUrlString:(NSString *)baseUrlString {
    ANAdRequestUrl *adRequestUrl = [[[self class] alloc] init];
    adRequestUrl.adFetcherDelegate = adFetcherDelegate;
    return [adRequestUrl buildRequestUrlWithBaseUrlString:baseUrlString];
}

- (NSURL *)buildRequestUrlWithBaseUrlString:(NSString *)baseUrlString {
    baseUrlString = [baseUrlString stringByAppendingString:@"?"];
    baseUrlString = [baseUrlString stringByAppendingString:[self placementIdentifierParameter]];
    NSString *idfa = ANUDID();
    if ([idfa isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
        ANLogInfo(@"IDFA is sentinel value, not sending to server");
    } else {
        baseUrlString = [baseUrlString an_stringByAppendingUrlParameter:@"idfa" value:ANUDID()];
    }
    baseUrlString = [baseUrlString stringByAppendingString:[self dontTrackEnabledParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self deviceMakeParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self deviceModelParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self carrierMccMncParameters]];
    baseUrlString = [baseUrlString stringByAppendingString:[self applicationIdParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self firstLaunchParameter]];
    
    baseUrlString = [baseUrlString stringByAppendingString:[self locationParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self userAgentParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self connectionTypeParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self devTimeParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self languageParameter]];
    
    baseUrlString = [baseUrlString stringByAppendingString:[self nativeBrowserParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self psaAndReserveParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self ageParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self genderParameter]];
    
    baseUrlString = [baseUrlString stringByAppendingString:[self nonetParameter]];

    baseUrlString = [baseUrlString stringByAppendingString:[self jsonFormatParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self supplyTypeParameter]];
    baseUrlString = [baseUrlString stringByAppendingString:[self sdkVersionParameter]];
    
    baseUrlString = [baseUrlString stringByAppendingString:[self extraParameters]];
    baseUrlString = [baseUrlString stringByAppendingString:[self customKeywordsParameter]];
    
	return [NSURL URLWithString:baseUrlString];
}

- (NSString *)URLEncodingFrom:(NSString *)originalString {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)originalString,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]<>",
                                                                                 kCFStringEncodingUTF8);
}

- (NSString *)placementIdentifierParameter {
    NSString *invCode = [self.adFetcherDelegate inventoryCode];
    NSInteger memberId = [self.adFetcherDelegate memberId];
    if (memberId > 0 && invCode) {
        return [NSString stringWithFormat:@"member=%d&inv_code=%@", (int)memberId, [self URLEncodingFrom:invCode]];
    }
    NSString *placementId = [self.adFetcherDelegate placementId];
    if ([placementId length] < 1) {
        return @"";
    }
    
    return [NSString stringWithFormat:@"id=%@", [self URLEncodingFrom:placementId]];
}

- (NSString *)dontTrackEnabledParameter {
    return ANAdvertisingTrackingEnabled() ? @"&LimitAdTrackingEnabled=0" : @"&LimitAdTrackingEnabled=1";
}

- (NSString *)deviceMakeParameter {
    return @"&devmake=Apple";
}

- (NSString *)deviceModelParameter {
    return [NSString stringWithFormat:@"&devmodel=%@", [self URLEncodingFrom:ANDeviceModel()]];
}

- (NSString *)applicationIdParameter {
    NSString *appId = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
    return [NSString stringWithFormat:@"&appid=%@", appId];
}

- (NSString *)firstLaunchParameter {
    return ANIsFirstLaunch() ? @"&firstlaunch=true" : @"";
}

- (NSString *)carrierMccMncParameters {
    NSString *param = @"";
    
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    
    if ([[carrier carrierName] length] > 0) {
        param = [param stringByAppendingString:
                 [NSString stringWithFormat:@"&carrier=%@",
                  [self URLEncodingFrom:[carrier carrierName]]]];
    }
    
    if ([[carrier mobileCountryCode] length] > 0) {
        param = [param stringByAppendingString:
                 [NSString stringWithFormat:@"&mcc=%@",
                  [self URLEncodingFrom:[carrier mobileCountryCode]]]];
    }
    
    if ([[carrier mobileNetworkCode] length] > 0) {
        param = [param stringByAppendingString:
                 [NSString stringWithFormat:@"&mnc=%@",
                  [self URLEncodingFrom:[carrier mobileNetworkCode]]]];
    }
    
    return param;
}

- (NSString *)connectionTypeParameter {
    ANReachability *reachability = [ANReachability reachabilityForInternetConnection];
    ANNetworkStatus status = [reachability currentReachabilityStatus];
    return status == ANNetworkStatusReachableViaWiFi ? @"&connection_type=wifi" : @"&connection_type=wan";
}

- (NSString *)locationParameter {
    ANLocation *location = [self.adFetcherDelegate location];
    NSString *locationParameter = @"";
    
    if (location) {
        NSDate *locationTimestamp = location.timestamp;
        NSTimeInterval ageInSeconds = -1.0 * [locationTimestamp timeIntervalSinceNow];
        NSInteger ageInMilliseconds = (NSInteger)(ageInSeconds * 1000);
        
        if (location.precision >= 0) {
            locationParameter = [NSString stringWithFormat:@"&loc=%.*f%%2C%.*f",
                                 (int)location.precision, location.latitude, (int)location.precision, location.longitude];
        } else {
            locationParameter = [NSString stringWithFormat:@"&loc=%f%%2C%f",
                                 location.latitude, location.longitude];
        }
        
        locationParameter = [locationParameter stringByAppendingFormat:@"&loc_age=%ld&loc_prec=%f",
         (long)ageInMilliseconds, location.horizontalAccuracy];
    }
    
    return locationParameter;
}

- (NSString *)userAgentParameter {
    return [NSString stringWithFormat:@"&ua=%@",
            [self URLEncodingFrom:ANUserAgent()]];
}

- (NSString *)languageParameter {
    NSString *language = [NSLocale preferredLanguages][0];
    return ([language length] > 0) ? [NSString stringWithFormat:@"&language=%@", [self URLEncodingFrom:language]] : @"";
}

- (NSString *)devTimeParameter {
    int timeInMiliseconds = (int) [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"&devtime=%d", timeInMiliseconds];
}

- (NSString *)nativeBrowserParameter {
    return [NSString stringWithFormat:@"&native_browser=%d", self.adFetcherDelegate.opensInNativeBrowser];
}

- (NSString *)psaAndReserveParameter {
    BOOL shouldServePsas = [self.adFetcherDelegate shouldServePublicServiceAnnouncements];
    CGFloat reserve = [self.adFetcherDelegate reserve];
    if (reserve > 0.0f) {
        NSString *reserveParameter = [self URLEncodingFrom:[NSString stringWithFormat:@"%f", reserve]];
        return [NSString stringWithFormat:@"&psa=0&reserve=%@", reserveParameter];
    } else {
        return shouldServePsas ? @"&psa=1" : @"&psa=0";
    }
}

- (NSString *)ageParameter {
    NSString *ageValue = [self.adFetcherDelegate age];
    if ([ageValue length] < 1) {
        return @"";
    }
    
    return [NSString stringWithFormat:@"&age=%@", [self URLEncodingFrom:ageValue]];
}

- (NSString *)genderParameter {
    ANGender genderValue = [self.adFetcherDelegate gender];
    if (genderValue == ANGenderMale) {
        return @"&gender=m";
    } else if (genderValue == ANGenderFemale) {
        return @"&gender=f";
    } else {
        return @"";
    }
}

- (NSString *)customKeywordsParameter {
    __block NSString *customKeywordsParameter = @"";
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSMutableDictionary *customKeywords = [self.adFetcherDelegate customKeywords];
#pragma clang diagnostic pop
    NSMutableDictionary<NSString *, NSArray<NSString *> *> *customKeywordsMap = [[self.adFetcherDelegate customKeywordsMap] mutableCopy];

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

    [customKeywordsMap enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray<NSString *> *valueArray, BOOL *stop) {
        if(![self stringInParameterList:key]){
            for (NSString *valueString in valueArray) {
                customKeywordsParameter = [customKeywordsParameter stringByAppendingString:
                                           [NSString stringWithFormat:@"&%@=%@",
                                            key,
                                            [self URLEncodingFrom:valueString]]];
            }
        } else {
            ANLogWarn(@"request_parameter_override_attempt %@", key);
        }
    }];
    
    return customKeywordsParameter;
}

- (NSString *)extraParameters {
    NSString *extraString = @"";
    if ([self.adFetcherDelegate respondsToSelector:@selector(extraParameters)]) {
        NSArray *extraParameters = [self.adFetcherDelegate extraParameters];
        
        for (NSString *param in extraParameters) {
            extraString = [extraString stringByAppendingString:param];
        }
    }
    
    return extraString;
}

- (NSString *)nonetParameter {
    NSArray *invalidNetworks;
    if ([self.adFetcherDelegate isKindOfClass:[ANBannerAdView class]]) {
        invalidNetworks = [[ANMediationAdViewController bannerInvalidNetworks] allObjects];
    } else if ([self.adFetcherDelegate isKindOfClass:[ANInterstitialAd class]]) {
        invalidNetworks = [[ANMediationAdViewController interstitialInvalidNetworks] allObjects];
    } else {
        ANLogDebug(@"Could not find nonet list for %@ ad view", self.adFetcherDelegate);
        invalidNetworks = nil;
    }
    
    return invalidNetworks.count ? [NSString stringWithFormat:@"&nonet=%@", [invalidNetworks componentsJoinedByString:@"%2C"]] : @"";
}

- (NSString *)jsonFormatParameter {
    return @"&format=json";
}

- (NSString *)supplyTypeParameter {
    return @"&st=mobile_app";
}

- (NSString *)sdkVersionParameter {
    return [NSString stringWithFormat:@"&sdkver=%@", AN_SDK_VERSION];
}

@end
