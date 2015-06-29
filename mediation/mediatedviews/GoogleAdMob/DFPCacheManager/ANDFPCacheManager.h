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

#import <UIKit/UIKit.h>
#import "ANAdConstants.h"
#import "ANDFPCacheManagerTargeting.h"

/**
 This class facilitates the pre-caching of DFP ad slots which are used when possible
 by the DFP banner mediation adapter in order to decrease latency.
 
 During the loading of the DFP banner adapter within a mediation waterfall, the adapter 
 (ANAdAdapterBannerDFP) will request a cached ad slot for a certain ad unit ID & size
 configuration from the cache manager. If a cached ad slot is available, the DFP banner
 adapter will populate the banner view with that ad slot, resulting in decreased latency.
 
 In the following example, the cache manager will pre-cache an ad slot for the ad unit ID 
 @"/6499/example/banner" and the size 320x50.
 
 @code
 #import "ANDFPCacheManager.h"
 
 [ANDFPCacheManager cacheBannerWithDFPAdUnitId:@"/6499/example/banner"
                                        adSize:CGSizeMake(320.0,50.0)];
 
 @endcode
 
 If the mediation waterfall then asks for an ad slot with the ad unit ID @"/6499/example/banner"
 and the size 320x50, it will be provided with this pre-cached slot.
 
 @note Only DFP ad unit IDs which serve direct-sold and house campaigns should be cached 
 by the cache manager. It should not be used for backfill or third-party networks ads.
 
 If you need to return resources to the application, you can call resetCacheManager.
 
 @code
 [ANDFPCacheManager resetCacheManager];
 @endcode
 
 */
@interface ANDFPCacheManager : NSObject

/**
 Begin caching a fixed-size DFP ad slot.
 
 @note This method needs to be called only once per ad unit ID & size for the lifecycle of the
 application.
 
 
 @param adUnitId The DFP ad unit ID
 @param adSize The ad size of the ad slot
 */
+ (void)cacheBannerWithDFPAdUnitId:(NSString *)adUnitId
                            adSize:(CGSize)adSize;

/**
 Begin caching a "smart banner" DFP ad slot.
 
 @note This method needs to be called only once per ad unit ID for the lifecycle of the
 application.

 @param adUnitId The DFP ad unit ID.
 */
+ (void)cacheSmartBannerWithDFPAdUnitId:(NSString *)adUnitId;

/**
 Resets the cache manager to its original state. This removes all existing cached
 DFP ad slots and prevents any further caching of ad slots. 
 
 @note Caching can be re-enabled at any point by calling cacheBannerWithDFPAdUnitId:adSize:
 or cacheSmartBannerWithDFPAdUnitID: for the desired ad slot configurations.
 */
+ (void)resetCacheManager;

@end