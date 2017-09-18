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

#import <Foundation/Foundation.h>
#import "ANAdFetcher.h"
#import "ANVideoAdProcessor.h"
#import "ANTrackerInfo.h"
#import "ANUniversalTagAdServerResponse.h"




static NSString *const  kANUniversalAdFetcherDefaultRequestUrlString  = @"http://mediation.adnxs.com/ut/v2";

extern NSString * const  ANInternalDelgateTagKeyPrimarySize;
extern NSString * const  ANInternalDelegateTagKeySizes;
extern NSString * const  ANInternalDelegateTagKeyAllowSmallerSizes;



@protocol ANUniversalAdFetcherDelegate;

@interface ANUniversalAdFetcher : NSObject

- (instancetype)initWithDelegate:(id<ANUniversalAdFetcherDelegate>)delegate;

- (void)stopAdLoad;
- (void) requestAd;

- (void)processAdServerResponse:(ANUniversalTagAdServerResponse *)response;

- (NSTimeInterval)getTotalLatency:(NSTimeInterval)stopTime;
- (CGSize)getWebViewSizeForCreativeWidth:(NSString *)width
                               andHeight:(NSString *)height;


- (void)fireResponseURL:(NSString *)urlString
                 reason:(ANAdResponseCode)reason
               adObject:(id)adObject
              auctionID:(NSString *)auctionID;

@end




// NB  ANUniversalAdFetcherDelegate is sufficient for instream video format.
//
@protocol  ANUniversalAdFetcherDelegate <ANAdFetcherDelegate>

- (CGSize)requestedSizeForAdFetcher:(ANUniversalAdFetcher *)fetcher;

- (void) universalAdFetcher: (ANUniversalAdFetcher *)fetcher
                 adResponse: (ANAdFetcherResponse *)response;

- (void)       universalAdFetcher: (ANUniversalAdFetcher *)fetcher
     didFinishRequestWithResponse: (ANAdFetcherResponse *)response;


//FIX -- need custom keywords map.

@end
