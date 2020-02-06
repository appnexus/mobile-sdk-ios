/*   Copyright 2019 APPNEXUS INC
 
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

#import "ANAdFetcherResponse.h"
#import "ANAdProtocol.h"
#import "ANUniversalTagAdServerResponse.h"

#import "ANNativeAdRequest.h"
#import "ANMultiAdRequest.h"


@protocol  ANRequestTagBuilderCore

// customKeywords is shared between the adunits and the fetcher.
//
// NB  This definition of customKeywords should not be confused with the public facing ANTargetingParameters.customKeywords
//       which is shared between fetcher and the mediation adapters.
//     The version here is a dictionary of arrays of strings, the public facing version is simply a dictionary of strings.
//
@property (nonatomic, readwrite, strong, nullable)  NSMutableDictionary<NSString *, NSArray<NSString *> *>  *customKeywords;

@end


@protocol  ANMultiAdProtocol

@property (nonatomic, readwrite, weak, nullable)  ANMultiAdRequest                                    *marManager;


/**
 This property is only used with ANMultiAdRequest.
 It associates a unique identifier with each adunit per request, allowing ad objects in the UT Response to be
   matched with adunit elements of the UT Request.
 NB  This value is updated for each UT Request.  It does not persist across the lifecycle of the instance.
 */
@property (nonatomic, readwrite, strong, nonnull)  NSString  *utRequestUUIDString;

/*!
 * Used only in MultiAdRequest to pass ad object returned by impbus directly to the adunit though it was requested by MAR UT Request.
 */
- (void)ingestAdResponseTag: (nonnull id)tag
      totalLatencyStartTime: (NSTimeInterval)totalLatencyStartTime;

@end


@interface ANAdFetcherBase : NSObject

@property (nonatomic, readwrite, strong, nullable)  NSMutableArray<id>    *ads;
@property (nonatomic, readwrite, strong, nullable)  NSString              *noAdUrl;

@property (nonatomic, readwrite)                    BOOL  isFetcherLoading;
@property (nonatomic, readwrite, strong, nullable)  id    adObjectHandler;

@property (nonatomic, readwrite, weak, nullable)    id                  delegate;
@property (nonatomic, readwrite, weak, nullable)    ANMultiAdRequest   *fetcherMARManager;
@property (nonatomic, readwrite, weak, nullable)    ANMultiAdRequest   *adunitMARManager;

@property (nonatomic, readwrite, assign)  NSTimeInterval  totalLatencyStart;


//
- (nonnull instancetype)init;
- (nonnull instancetype)initWithDelegate:(nonnull id)delegate andAdUnitMultiAdRequestManager:(nonnull ANMultiAdRequest *)adunitMARManager;
- (nonnull instancetype)initWithMultiAdRequestManager:(nonnull ANMultiAdRequest *)marManager;
- (void)setup;
- (void)requestAd;

- (void)fireResponseURL:(nullable NSString *)responseURLString
                 reason:(ANAdResponseCode)reason
               adObject:(nonnull id)adObject;


- (void)prepareForWaterfallWithAdServerResponseTag: (nullable NSDictionary<NSString *, id> *)ads
                          andTotalLatencyStartTime: (NSTimeInterval)totalLatencyStartTime;

- (void) beginWaterfallWithAdObjects:(nonnull NSMutableArray<id> *)ads;


- (NSTimeInterval)getTotalLatency:(NSTimeInterval)stopTime;

@end


