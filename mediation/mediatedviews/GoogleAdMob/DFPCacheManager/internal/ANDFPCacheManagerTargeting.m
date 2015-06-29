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

#import "ANDFPCacheManagerTargeting.h"

@implementation ANDFPCacheManagerTargeting

+ (ANDFPCacheManagerTargeting *)sharedTargeting {
    static dispatch_once_t sharedTargetingToken;
    static ANDFPCacheManagerTargeting *sharedTargeting;
    dispatch_once(&sharedTargetingToken, ^{
        sharedTargeting = [[ANDFPCacheManagerTargeting alloc] init];
    });
    return sharedTargeting;
}

- (NSMutableDictionary *)customKeywords {
    if (!_customKeywords) _customKeywords = [[NSMutableDictionary alloc] init];
    return _customKeywords;
}

- (void)addCustomKeywordWithKey:(NSString *)key
                          value:(NSString *)value {
    if (([key length] < 1) || !value) {
        return;
    }
    
    [self.customKeywords setValue:value
                           forKey:key];
}

- (void)removeCustomKeywordWithKey:(NSString *)key {
    if (([key length] < 1)) {
        return;
    }
    
    [self.customKeywords removeObjectForKey:key];
}

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy {
    self.location = [ANLocation getLocationWithLatitude:latitude
                                              longitude:longitude
                                              timestamp:timestamp
                                     horizontalAccuracy:horizontalAccuracy];
}

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy
                      precision:(NSInteger)precision {
    self.location = [ANLocation getLocationWithLatitude:latitude
                                              longitude:longitude
                                              timestamp:timestamp
                                     horizontalAccuracy:horizontalAccuracy
                                              precision:precision];
}

@end