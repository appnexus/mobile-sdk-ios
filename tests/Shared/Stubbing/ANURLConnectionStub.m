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

#import "ANURLConnectionStub.h"
#import "ANGlobal.h"
#import "ANSDKSettings+PrivateMethods.h"




@implementation ANURLConnectionStub

- (id)copyWithZone:(NSZone *)zone {
    ANURLConnectionStub *newStub = [[ANURLConnectionStub alloc] init];
    newStub.requestURLRegexPatternString = self.requestURLRegexPatternString;
    newStub.responseCode = self.responseCode;
    newStub.responseBody = self.responseBody;
    return newStub;
}

- (BOOL)isEqual:(ANURLConnectionStub *)object {
    BOOL sameRequestURLString = [self.requestURLRegexPatternString isEqualToString:object.requestURLRegexPatternString];
    BOOL sameResponseCode = self.responseCode = object.responseCode;
    BOOL sameResponseBody = [self.responseBody isEqualToString:object.responseBody];
    return sameRequestURLString && sameResponseBody && sameResponseCode;
}

- (NSUInteger)hash {
    NSMutableString *description = [[NSMutableString alloc] init];
    [description appendString:self.requestURLRegexPatternString];
    [description appendString:[NSString stringWithFormat:@"%ld", (long)self.responseCode]];
    [description appendString:self.responseBody];
    return [description hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"NSURLConnectionStub: \n\
    Request URL Pattern: %@,\n\
    Response Code: %ld,\n\
    Response Body: %@",self.requestURLRegexPatternString, (long)self.responseCode, self.responseBody];

}




#pragma mark - Pre-Initialized Stubbers

+ (ANURLConnectionStub *)stubForStandardBannerWithAdSize:(CGSize)adSize
                                     contentFromResource:(NSString *)resource
                                                  ofType:(NSString *)type {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:resource
                                                         ofType:type];
    NSString *content = [[NSString alloc] initWithContentsOfFile:filePath
                                                        encoding:NSUTF8StringEncoding
                                                           error:nil];
    return [ANURLConnectionStub stubForStandardBannerWithAdSize:adSize
                                                        content:content];
}

+ (ANURLConnectionStub *)stubForStandardBannerWithAdSize:(CGSize)adSize
                                                 content:(NSString *)content {
    ANURLConnectionStub *stub = [[ANURLConnectionStub alloc] init];
    stub.requestURLRegexPatternString = [[ANSDKSettings sharedInstance].baseUrlConfig adRequestBaseUrl];
    stub.responseCode = 200;
    stub.responseBody = [NSJSONSerialization dataWithJSONObject:[[self class] responseForStandardBannerWithAdSize:adSize
                                                                                                          content:content]
                                                        options:0
                                                          error:nil];
    return stub;
}

+ (ANURLConnectionStub *)stubForMraidFile {
    ANURLConnectionStub *stub = [[ANURLConnectionStub alloc] init];
    stub.requestURLRegexPatternString = [[[ANSDKSettings sharedInstance].baseUrlConfig webViewBaseUrl] stringByAppendingString:@"mraid.js"];
    stub.responseBody = @"";
    stub.responseCode = 200;
    return stub;
}

+ (ANURLConnectionStub *)stubForResource:(NSString *)resource
                                  ofType:(NSString *)type {
    return [ANURLConnectionStub stubForResource:resource
                                         ofType:type
               withRequestURLRegexPatternString:resource
                                       inBundle:[NSBundle mainBundle]];
}

+ (ANURLConnectionStub *)stubForResource:(NSString *)resource
                                  ofType:(NSString *)type
        withRequestURLRegexPatternString:(NSString *)pattern {
    return [ANURLConnectionStub stubForResource:resource
                                         ofType:type
               withRequestURLRegexPatternString:pattern
                                       inBundle:[NSBundle mainBundle]];
}

+ (ANURLConnectionStub *)stubForResource:(NSString *)resource
                                  ofType:(NSString *)type
        withRequestURLRegexPatternString:(NSString *)pattern
                                inBundle:(NSBundle *)bundle {
    ANURLConnectionStub *stub = [[ANURLConnectionStub alloc] init];
    stub.responseCode = 200;
    stub.requestURLRegexPatternString = pattern;
    stub.responseBody = [NSData dataWithContentsOfFile:[bundle pathForResource:resource
                                                                        ofType:type]];
    return stub;
}

+ (NSDictionary *)responseForStandardBannerWithAdSize:(CGSize)adSize
                                              content:(NSString *)content {
    NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
    response[@"status"] = @"ok";
    NSDictionary *adElement = [[self class] adElementForAdType:@"banner"
                                                        adSize:adSize
                                                       content:content];
    response[@"ads"] = @[adElement];
    return [response copy];
}

+ (NSDictionary *)adElementForAdType:(NSString *)type
                              adSize:(CGSize)adSize
                             content:(NSString *)content {
    NSMutableDictionary *adElement = [[NSMutableDictionary alloc] init];
    adElement[@"type"] = type;
    adElement[@"width"] = [@(adSize.width) description];
    adElement[@"height"] = [@(adSize.height) description];
    adElement[@"content"] = content;
    return [adElement copy];
}

@end
