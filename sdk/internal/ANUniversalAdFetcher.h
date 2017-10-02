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

#import "ANVideoAdProcessor.h"
#import "ANTrackerInfo.h"
#import "ANUniversalTagAdServerResponse.h"
#import "ANAdFetcherResponse.h"
#import "ANLocation.h"
#import "ANAdConstants.h"
#import "ANAdViewInternalDelegate.h"
#import "ANAdProtocol.h"




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




#pragma mark - ANUniversalAdFetcherDelegate partitions.

@protocol  ANUniversalAdFetcherFoundationDelegate <ANAdProtocolFoundation>

- (void)       universalAdFetcher: (ANUniversalAdFetcher *)fetcher
     didFinishRequestWithResponse: (ANAdFetcherResponse *)response;

- (NSArray<NSValue *> *)adAllowedMediaTypes;

// NB  Represents lazy evaluation as a means to get most current value of primarySize (eg: from self.containerSize).
//     In addition, this method combines collection of all three size parameters to avoid synchronization issues.
//
- (NSDictionary *) internalDelegateUniversalTagSizeParameters;

- (NSMutableDictionary<NSString *, NSArray<NSString *> *> *)customKeywordsMap;

//FIX -- need custom keywords map.

@end


// NB  ANUniversalAdFetcherDelegate is sufficient for instream video entry point.
//
@protocol  ANUniversalAdFetcherDelegate <ANUniversalAdFetcherFoundationDelegate, ANAdProtocolBrowser, ANAdProtocolPublicServiceAnnouncement, ANAdViewInternalDelegate>

- (CGSize)requestedSizeForAdFetcher:(ANUniversalAdFetcher *)fetcher;

- (NSTimeInterval)autoRefreshIntervalForAdFetcher:(ANUniversalAdFetcher *)fetcher;

@end




#pragma mark - ANUniversalAdFetcherDelegate entrypoint combinations.

@protocol  ANUniversalAdInstreamVideoFetcherDelegate <ANUniversalAdFetcherFoundationDelegate, ANAdProtocolBrowser>
    //EMPTY
@end

@protocol  ANUniversalAdNativeFetcherDelegate <ANUniversalAdFetcherFoundationDelegate>   //ALIAS
    //EMPTY
@end

