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

#import "ANTestResponses.h"
#import "ANMediatedAd.h"

NSString *const RESPONSE_TEMPLATE = @"{\"status\":\"%@\",\"ads\": %@,\"mediated\": %@}";
NSString *const ADS_ARRAY_TEMPLATE = @"[{ \"type\": \"%@\", \"width\": %i, \"height\": %i, \"content\": \"%@\" }]";
NSString *const MEDIATED_ARRAY_TEMPLATE = @"[{ \"handler\": [{\"type\":\"%@\",\"class\":\"%@\",\"param\":\"%@\",\"width\":\"%i\",\"height\":\"%i\",\"id\":\"%@\"}],\"result_cb\":\"%@\"}]";

NSString *const MEDIATED_AD_TEMPLATE = @"{\"type\":\"%@\",\"class\":\"%@\",\"param\":\"%@\",\"width\":\"%@\",\"height\":\"%@\",\"id\":\"%@\"}";

@interface ANMediatedAd (TestResponses)
@property (nonatomic, readwrite, strong) NSString *type;
- (NSString *)toJSON;
@end

@implementation ANTestResponses

#pragma mark View-specific Convenience functions

+ (NSString *)successfulBanner {
    return [ANTestResponses createAdsResponse:@"banner" withWidth:320 withHeight:50 withContent:@"HelloWorld"];
}

+ (NSString *)mediationSuccessfulBanner {
    return [ANTestResponses createMediatedBanner:@"ANSuccessfulBanner" withID:@"" withResultCB:@"http://result"];
}

+ (NSString *)mediationNoAdsBanner {
    return [ANTestResponses createMediatedBanner:@"ANAdAdapterBannerNoAds" withID:@"" withResultCB:@"http://result"];
}

#pragma mark Response Construction Convenience functions

+ (NSString *)createAdsResponse:(NSString *)type
                    withWidth:(int)width
                   withHeight:(int)height
                  withContent:(NSString *)content {
    NSString *statusField = @"ok";
    NSString *adsField = [NSString stringWithFormat:ADS_ARRAY_TEMPLATE, type, width, height, content];
    NSString *mediatedField = @"[]";
    return [ANTestResponses createResponseString:statusField withAds:adsField withMediated:mediatedField];
}

+ (NSString *)createMediatedBanner:(NSString *)className
                            withID:(NSString *)idString
                      withResultCB:(NSString *)resultCB {
    ANMediatedAd *mediatedAd = [ANMediatedAd new];
    mediatedAd.type = @"ios";
    mediatedAd.param = @"";
    mediatedAd.className = className;
    mediatedAd.width = @"320";
    mediatedAd.height = @"50";
    mediatedAd.adId = idString;
    
    NSMutableArray *mediatedAdsArray = [[NSMutableArray alloc] initWithObjects:mediatedAd, nil];
    NSString *handler = [ANTestResponses createHandlerObjectFromMediatedAds:mediatedAdsArray withResultCB:resultCB];

    NSString *mediatedField = [ANTestResponses createMediatedArrayFromHandlers:[[NSMutableArray alloc] initWithObjects:handler, nil]];
    return [ANTestResponses createMediatedResponse:mediatedField];
}

+ (NSString *)createMediatedResponse:(NSString *)type
                       withClassName:(NSString *)className
                           withParam:(NSString *)param
                           withWidth:(int)width
                          withHeight:(int)height
                              withID:(NSString *)idString
                        withResultCB:(NSString *)resultCB {
    NSString *statusField = @"ok";
    NSString *adsField = @"[]";
    NSString *mediatedField = [NSString stringWithFormat:MEDIATED_ARRAY_TEMPLATE, type, className,
            param, width, height, idString, resultCB];
    return [ANTestResponses createResponseString:statusField withAds:adsField withMediated:mediatedField];
}

+ (NSString *)createMediatedResponse:(NSString *)mediatedField {
    NSString *statusField = @"ok";
    NSString *adsField = @"[]";
    return [ANTestResponses createResponseString:statusField withAds:adsField withMediated:mediatedField];
}
            
#pragma mark Base functions

+ (NSString *)createResponseString:(NSString *)status
                           withAds:(NSString *)ads
                      withMediated:(NSString *)mediated {
    return [NSString stringWithFormat:RESPONSE_TEMPLATE, status, ads, mediated];
}

+ (NSString *)createAdsString:(NSString *)type
                    withWidth:(int)width
                   withHeight:(int)height
                  withContent:(NSString *)content {
    return [NSString stringWithFormat:ADS_ARRAY_TEMPLATE, type, width, height, content];
}

+ (NSString *)createMediatedString:(NSString *)type
                     withClassName:(NSString *)className
                         withParam:(NSString *)param
                         withWidth:(int)width
                         withHeight:(int)height
                            withID:(NSString *)idString
                      withResultCB:(NSString *)resultCB {
    return [NSString stringWithFormat:MEDIATED_ARRAY_TEMPLATE, type, className,
            param, width, height, idString, resultCB];
}

+ (NSString *)createMediatedArrayFromHandlers:(NSMutableArray *)handlers {
    NSString *mediatedArrayString = @"[";
    if ([handlers count] > 0) {
        NSString *handler = [handlers objectAtIndex:0];
        mediatedArrayString = [mediatedArrayString stringByAppendingString:handler];
        [handlers removeObjectAtIndex:0];
    }
    
    while ([handlers count] > 0) {
        mediatedArrayString = [mediatedArrayString stringByAppendingString:@","];
        NSString *handler = [handlers objectAtIndex:0];
        mediatedArrayString = [mediatedArrayString stringByAppendingString:handler];
        [handlers removeObjectAtIndex:0];
    }
    mediatedArrayString = [mediatedArrayString stringByAppendingString:@"]"];
    return mediatedArrayString;
}

+ (NSString *)createHandlerObjectFromMediatedAds:(NSMutableArray *)mediatedAds
                                    withResultCB:(NSString *)resultCB {
    NSString *mediatedAdString = @"{ \"handler\": [";
    while ([mediatedAds count] > 1) {
        ANMediatedAd *mediatedAd = [mediatedAds objectAtIndex:0];
        mediatedAdString = [mediatedAdString stringByAppendingString:[mediatedAd toJSON]];
        mediatedAdString = [mediatedAdString stringByAppendingString:@", "];
        [mediatedAds removeObjectAtIndex:0];
    }
    
    if ([mediatedAds count] > 0) {
        ANMediatedAd *mediatedAd = (ANMediatedAd *)[mediatedAds objectAtIndex:0];
        mediatedAdString = [mediatedAdString stringByAppendingString:[mediatedAd toJSON]];
        [mediatedAds removeObjectAtIndex:0];
    }
    
    mediatedAdString = [mediatedAdString stringByAppendingString:@"]"];
    
    if ([resultCB length] > 0) {
        NSString *resultCBString = [NSString stringWithFormat:@", \"result_cb\":\"%@\"", resultCB];
        mediatedAdString = [mediatedAdString stringByAppendingString:resultCBString];
    }
    
    mediatedAdString = [mediatedAdString stringByAppendingString:@"}"];

    return mediatedAdString;
}
@end

@implementation ANMediatedAd (TestResponses)

NSString *_type;

- (NSString *)toJSON {
    return [NSString stringWithFormat:MEDIATED_AD_TEMPLATE, self.type, self.className,
            self.param, self.width, self.height, self.adId];
}

- (void)setType:(NSString *)type {
    _type = type;
}

- (NSString *)type {
    return _type;
}

@end