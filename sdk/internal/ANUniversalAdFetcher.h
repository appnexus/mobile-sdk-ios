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
#import "ANGlobal.h"




@protocol ANUniversalAdFetcherDelegate;
@protocol ANUniversalNativeAdFetcherDelegate;



@interface ANUniversalAdFetcher : NSObject

- (instancetype)initWithDelegate: (id)delegate;

- (void)stopAdLoad;
- (void) requestAd;

- (void)processAdServerResponse:(ANUniversalTagAdServerResponse *)response;

- (void) startAutoRefreshTimer;
- (void) restartAutoRefreshTimer;
- (void) stopAutoRefreshTimer;

- (NSTimeInterval)getTotalLatency:(NSTimeInterval)stopTime;
- (CGSize)getWebViewSizeForCreativeWidth:(NSString *)width
                               andHeight:(NSString *)height;


- (void)fireResponseURL:(NSString *)responseURLString
                 reason:(ANAdResponseCode)reason
               adObject:(id)adObject
              auctionID:(NSString *)auctionID;


@end




#pragma mark - ANUniversalAdFetcherDelegate partitions.

@protocol  ANUniversalAdFetcherFoundationDelegate <ANAdProtocolFoundation>

@required

- (void)       universalAdFetcher: (ANUniversalAdFetcher *)fetcher
     didFinishRequestWithResponse: (ANAdFetcherResponse *)response;

- (NSArray<NSValue *> *)adAllowedMediaTypes;

// NB  Represents lazy evaluation as a means to get most current value of primarySize (eg: from self.containerSize).
//     In addition, this method combines collection of all three size parameters to avoid synchronization issues.
//
- (NSDictionary *) internalDelegateUniversalTagSizeParameters;


// customKeywords is shared between the entrypoints and the fetcher.
//
// NB  This definition of customKeywords should not be confused with the public facing ANTargetingParameters.customKeywords
//       which is shared between fetcher and the mediation adapters.
//     The version here is a dictionary of arrays of strings, the public facing version is simply a dictionary of strings.
//
@property (nonatomic, readwrite, strong)  NSMutableDictionary<NSString *, NSArray<NSString *> *>  *customKeywords;

@end

// NB  ANUniversalAdFetcherDelegate is sufficient for Banner, Interstitial entry point.
//
@protocol  ANUniversalAdFetcherDelegate <ANUniversalAdFetcherFoundationDelegate, ANAdProtocolBrowser, ANAdProtocolPublicServiceAnnouncement, ANAdViewInternalDelegate>

@required

- (CGSize)requestedSizeForAdFetcher:(ANUniversalAdFetcher *)fetcher;


@optional

// NB  autoRefreshIntervalForAdFetcher: and videoAdTypeForAdFetcher: are required for ANBannerAdView,
//       but are not used by any other entrypoint.
//
- (NSTimeInterval) autoRefreshIntervalForAdFetcher:(ANUniversalAdFetcher *)fetcher;
- (ANVideoAdSubtype) videoAdTypeForAdFetcher:(ANUniversalAdFetcher *)fetcher;

@end

// Note  ANUniversalRequestTagBuilderDelegate is the consolidated list of all protocols defined & used at multiple entry points.
// this protocol is used only by the tagBuilder so any protocol newly defined must be included in this protocol to be
// available for constucting the ut post body object
//

@protocol  ANUniversalRequestTagBuilderDelegate <ANUniversalAdFetcherFoundationDelegate, ANAdProtocolBrowser, ANAdProtocolPublicServiceAnnouncement, ANAdViewInternalDelegate, ANVideoAdProtocol>

@end


#pragma mark - ANUniversalAdFetcherDelegate entrypoint combinations.

@protocol  ANUniversalNativeAdFetcherDelegate  <ANUniversalAdFetcherFoundationDelegate, ANAdProtocolFoundation>
//EMPTY
@end

