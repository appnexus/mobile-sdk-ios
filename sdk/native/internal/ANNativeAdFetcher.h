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

#import "ANNativeCustomAdapter.h"
#import "ANGlobal.h"
#import "ANNativeAdTargetingProtocol.h"
#import "ANAdFetcherResponse.h"

static NSString *const kANNativeAdFetcherDefaultBaseUrlString = @"http://mediation.adnxs.com/mob";

@protocol ANNativeAdFetcherDelegate;

@interface ANNativeAdFetcher : NSObject

// Designated initializer
// Initializes a fetcher and begins loading an ad
- (instancetype)initWithDelegate:(id<ANNativeAdFetcherDelegate>)delegate;
- (instancetype)initWithDelegate:(id<ANNativeAdFetcherDelegate>)delegate
                   baseUrlString:(NSString *)baseUrlString;
- (void)stopAd;

@end

@protocol ANNativeAdFetcherDelegate <ANNativeAdTargetingProtocol>

- (void)adFetcher:(ANNativeAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdFetcherResponse *)response;

@end