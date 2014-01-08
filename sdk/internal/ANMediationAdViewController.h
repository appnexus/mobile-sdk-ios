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

#import "ANAdFetcher.h"

#import <Foundation/Foundation.h>

@interface ANMediationAdViewController : NSObject

- (void)startTimeout;
- (void)setAdapter:(id<ANCustomAdapter>)adapter;
- (void)clearAdapter;
- (void)setResultCBString:(NSString *)resultCBString;
- (BOOL)requestAd:(CGSize)size
 serverParameter:(NSString *)parameterString
        adUnitId:(NSString *)idString
           adView:(id<ANAdFetcherDelegate>)adView;

+ (ANMediationAdViewController *)initWithFetcher:(ANAdFetcher *)fetcher
                                   adViewDelegate:(id<ANAdViewDelegate>)adViewDelegate;

@end

@interface ANMediationAdViewController () <ANCustomAdapterBannerDelegate, ANCustomAdapterInterstitialDelegate>
@end
