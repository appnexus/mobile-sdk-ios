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

#import "ANMediatedAd.h"
#import "ANAdProtocol.h"
#import "ANUniversalAdFetcher.h"



@protocol ANNativeMediationAdControllerDelegate;




@interface ANNativeMediatedAdController : NSObject

// Designated initializer
+ (instancetype)initMediatedAd:(ANMediatedAd *)mediatedAd
                   withFetcher:(ANUniversalAdFetcher *)adFetcher
             adRequestDelegate:(id<ANNativeAdRequestProtocol>)adRequestDelegate;

@property (nonatomic, readwrite, weak)  ANUniversalAdFetcher  *adFetcher;
@property (nonatomic, readwrite, weak)  id<ANUniversalNativeAdFetcherDelegate>     adRequestDelegate;

@end




@protocol ANNativeMediationAdControllerDelegate <NSObject>

@required

- (NSTimeInterval)getTotalLatency:(NSTimeInterval)stopTime;

@end
