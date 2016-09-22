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

#import "ANAdFetcherResponse.h"
#import "ANAdProtocol.h"
#import "ANAdViewInternalDelegate.h"
#import "ANGlobal.h"
#import "ANCustomAdapter.h"

@class ANMRAIDAdWebViewController;
@class ANAdServerResponse;
@class ANLocation;
@protocol ANAdFetcherDelegate;

extern NSString *const kANAdFetcherWillRequestAdNotification;
extern NSString *const kANAdFetcherDidReceiveResponseNotification;
extern NSString *const kANAdFetcherAdRequestURLKey;
extern NSString *const kANAdFetcherAdResponseKey;
extern NSString *const kANAdFetcherWillInstantiateMediatedClassNotification;
extern NSString *const kANAdFetcherMediatedClassKey;

@interface ANAdFetcher : NSObject

@property (nonatomic, readwrite, weak) id<ANAdFetcherDelegate> delegate;
@property (nonatomic, readonly, getter = isLoading) BOOL loading;

- (void)stopAd;
- (void)requestAd;
- (void)requestAdWithURL:(NSURL *)URL;
- (void)startAutoRefreshTimer;
- (void)setupAutoRefreshTimerIfNecessary;
- (void)fireResultCB:(NSString *)resultCBString
              reason:(ANAdResponseCode)reason
            adObject:(id)adObject
           auctionID:(NSString *)auctionID;
- (void)processAdResponse:(ANAdServerResponse *)response;
- (void)processFinalResponse:(ANAdFetcherResponse *)response;
@end

@protocol ANAdFetcherDelegate <ANAdProtocol, ANAdViewInternalDelegate>

@optional
- (void)adFetcher:(ANAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdFetcherResponse *)response;
- (CGSize)requestedSizeForAdFetcher:(ANAdFetcher *)fetcher;
- (NSTimeInterval)autoRefreshIntervalForAdFetcher:(ANAdFetcher *)fetcher;
- (NSArray *)extraParameters; // An array of NSString
- (NSMutableDictionary<NSString *, NSArray<NSString *> *> *)customKeywordsMap;

@end
