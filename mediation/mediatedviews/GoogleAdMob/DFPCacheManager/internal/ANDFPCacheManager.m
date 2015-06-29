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

#import "ANDFPCacheManager+Internal.h"
#import "ANDFPBannerViewIdentifier.h"
#import "ANDFPBannerViewCacheInstance.h"
#import "ANLogging.h"

@interface ANDFPCacheManager ()

@property (nonatomic) BOOL cacheManagerEnabled;
@property (nonatomic) NSMutableSet *identifiers;
@property (nonatomic) NSMutableDictionary *cacheInstances;

@end

@implementation ANDFPCacheManager

+ (ANDFPCacheManager *)sharedManager {
    static dispatch_once_t sharedManagerToken;
    static ANDFPCacheManager *cacheManager;
    dispatch_once(&sharedManagerToken, ^{
        cacheManager = [[ANDFPCacheManager alloc] init];
    });
    return cacheManager;
}

+ (void)cacheBannerWithDFPAdUnitId:(NSString *)adUnitId
                            adSize:(CGSize)adSize {
    if (![adUnitId length] || CGSizeEqualToSize(adSize, CGSizeZero)) {
        ANLogError(@"%@: Invalid adUnitId or adSize", NSStringFromSelector(_cmd));
        return;
    }
    
    ANDFPBannerViewIdentifier *identifier = [[ANDFPBannerViewIdentifier alloc] init];
    identifier.adUnitId = adUnitId;
    identifier.adSize = adSize;
    identifier.orientation = ANDFPSmartBannerOrientationNone;
    [[ANDFPCacheManager sharedManager] cacheDFPBannerViewWithIdentifier:identifier];
}

+ (void)cacheSmartBannerWithDFPAdUnitId:(NSString *)adUnitId {
    if (![adUnitId length]) {
        ANLogError(@"%@: Invalid adUnitId", NSStringFromSelector(_cmd));
        return;
    }
    
    ANDFPBannerViewIdentifier *portraitIdentifier = [[ANDFPBannerViewIdentifier alloc] init];
    portraitIdentifier.adUnitId = adUnitId;
    portraitIdentifier.adSize = CGSizeZero;
    portraitIdentifier.orientation = ANDFPSmartBannerOrientationPortrait;
    [[ANDFPCacheManager sharedManager] cacheDFPBannerViewWithIdentifier:portraitIdentifier];
    
    ANDFPBannerViewIdentifier *landscapeIdentifier = [[ANDFPBannerViewIdentifier alloc] init];
    landscapeIdentifier.adUnitId = adUnitId;
    landscapeIdentifier.adSize = CGSizeZero;
    landscapeIdentifier.orientation = ANDFPSmartBannerOrientationLandscape;
    [[ANDFPCacheManager sharedManager] cacheDFPBannerViewWithIdentifier:landscapeIdentifier];
}

+ (void)resetCacheManager {
    [ANDFPCacheManager sharedManager].cacheManagerEnabled = NO;
}

- (NSMutableDictionary *)cacheInstances {
    if (!_cacheInstances) _cacheInstances = [[NSMutableDictionary alloc] init];
    return _cacheInstances;
}

- (NSMutableSet *)identifiers {
    if (!_identifiers) _identifiers = [[NSMutableSet alloc] init];
    return _identifiers;
}

- (void)setCacheManagerEnabled:(BOOL)cacheManagerEnabled {
    _cacheManagerEnabled = cacheManagerEnabled;
    if (!_cacheManagerEnabled) {
        self.identifiers = nil;
        self.cacheInstances = nil;
    }
}

- (void)cacheDFPBannerViewWithIdentifier:(ANDFPBannerViewIdentifier *)identifier {
    self.cacheManagerEnabled = YES;
    [self.identifiers addObject:identifier];
    if (!self.cacheInstances[identifier]) {
        ANDFPBannerViewCacheInstance *cacheInstance = [[ANDFPBannerViewCacheInstance alloc] initWithIdentifier:identifier];
        [cacheInstance startLoading];
        self.cacheInstances[identifier] = cacheInstance;
    }
}

- (ANDFPBannerViewCacheInstance *)DFPBannerViewCacheInstanceForIdentifier:(ANDFPBannerViewIdentifier *)identifier {
    if (self.cacheManagerEnabled) {
        ANDFPBannerViewCacheInstance *cacheInstance = self.cacheInstances[identifier];
        if (cacheInstance.loadingState == ANDFPBannerViewLoadingStatePending) {
            return nil;
        }
        [self.cacheInstances removeObjectForKey:identifier];
        if ([self.identifiers containsObject:identifier]) {
            [self cacheDFPBannerViewWithIdentifier:identifier];
        }
        return cacheInstance;
    }
    return nil;
}

@end