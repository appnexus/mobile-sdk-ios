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
#import "ANNativeAdFetcher.h"
#import "ANTargetingParameters.h"
#import "ANNativeCustomAdapter.h"
@protocol ANNativeMediationAdControllerDelegate;




@interface ANNativeMediatedAdController : NSObject

// variables for measuring latency.
@property (nonatomic, readwrite, assign) NSTimeInterval latencyStart;
@property (nonatomic, readwrite, assign) NSTimeInterval latencyStop;

@property (nonatomic, readwrite, assign) BOOL hasSucceeded;
@property (nonatomic, readwrite, assign) BOOL hasFailed;
@property (nonatomic, readwrite, assign) BOOL timeoutCanceled;


@property (nonatomic, readwrite, weak)  ANNativeAdFetcher  *adFetcher;
@property (nonatomic, readwrite, weak)  id<ANNativeAdFetcherDelegate>     adRequestDelegate;

// Designated initializer for CSM Mediation
+ (instancetype)initMediatedAd:(ANMediatedAd *)mediatedAd
                   withFetcher: (ANNativeAdFetcher *)adFetcher
             adRequestDelegate:(id<ANNativeAdRequestProtocol>)adRequestDelegate;



// Adapter helper methods
- (ANTargetingParameters *)targetingParameters;
- (NSString *)createResponseURLRequest:(NSString *)baseString reason:(int)reasonCode;
- (void)didReceiveAd:(id)adObject;
- (BOOL)checkIfMediationHasResponded;
- (void)setAdapter:(id<ANNativeCustomAdapter>)adapter;
- (void)clearAdapter;
- (void)didFailToReceiveAd:(ANAdResponseCode *)errorCode;


// Adapter Error Handling
- (void)finish:(ANAdResponseCode *)errorCode withAdObject:(id)adObject;
- (void)handleInstantiationFailure:(NSString *)className errorCode:(ANAdResponseCode *)errorCode errorInfo:(NSString *)errorInfo;


// Adapter Latency Measurement
- (void)markLatencyStart;
- (void)markLatencyStop;
- (NSTimeInterval)getLatency;

// Adapter Timeout handler
- (void)startTimeout;
- (void)cancelTimeout;

@end

