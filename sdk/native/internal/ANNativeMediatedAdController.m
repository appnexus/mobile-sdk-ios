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

#import "ANNativeMediatedAdController.h"
#import "ANNativeCustomAdapter.h"
#import "ANUniversalAdFetcher.h"
#import "ANLogging.h"
#import "NSString+ANCategory.h"
#import "NSObject+ANCategory.h"



@interface ANNativeMediatedAdController () <ANNativeCustomAdapterRequestDelegate>

@property (nonatomic, readwrite, strong) ANMediatedAd *mediatedAd;

@property (nonatomic, readwrite, strong) id<ANNativeCustomAdapter> currentAdapter;
@property (nonatomic, readwrite, assign) BOOL hasSucceeded;
@property (nonatomic, readwrite, assign) BOOL hasFailed;
@property (nonatomic, readwrite, assign) BOOL timeoutCanceled;

// variables for measuring latency.
@property (nonatomic, readwrite, assign) NSTimeInterval latencyStart;
@property (nonatomic, readwrite, assign) NSTimeInterval latencyStop;

@end



@implementation ANNativeMediatedAdController

+ (instancetype)initMediatedAd: (ANMediatedAd *)mediatedAd
                   withFetcher: (ANUniversalAdFetcher *)adFetcher
             adRequestDelegate: (id<ANUniversalNativeAdFetcherDelegate>)adRequestDelegate
{
    ANNativeMediatedAdController *controller = [[ANNativeMediatedAdController alloc] initMediatedAd: mediatedAd
                                                                                          withFetcher: adFetcher
                                                                                    adRequestDelegate: adRequestDelegate];
    if ([controller initializeRequest]) {
        return controller;
    } else {
        return nil;
    }

}

- (instancetype)initMediatedAd: (ANMediatedAd *)mediatedAd
                   withFetcher: (ANUniversalAdFetcher *)adFetcher
             adRequestDelegate: (id<ANUniversalNativeAdFetcherDelegate>)adRequestDelegate
{
    self = [super init];
    if (self) {
        _adFetcher = adFetcher;
        _adRequestDelegate = adRequestDelegate;
        _mediatedAd = mediatedAd;
    }
    return self;
}

- (BOOL)initializeRequest {
    NSString *className = nil;
    NSString *errorInfo = nil;
    ANAdResponseCode errorCode = (ANAdResponseCode)ANDefaultCode;

    do {
        // check that the ad is non-nil
        if (!self.mediatedAd) {
            errorInfo = @"null mediated ad object";
            errorCode = (ANAdResponseCode)ANAdResponseUnableToFill;
            break;
        }
        
        className = self.mediatedAd.className;
        ANLogDebug(@"instantiating_class %@", className);
        
        // notify that a mediated class name was received
        ANPostNotifications(kANUniversalAdFetcherWillInstantiateMediatedClassNotification, self,
                            @{kANUniversalAdFetcherMediatedClassKey: className});

        // check to see if an instance of this class exists
        Class adClass = NSClassFromString(className);
        if (!adClass) {
            errorInfo = @"ClassNotFoundError";
            errorCode = (ANAdResponseCode)ANAdResponseMediatedSDKUnavailable;
            break;
        }
        
        id adInstance = [[adClass alloc] init];
        if (![self validAdInstance:adInstance]) {
            errorInfo = @"InstantiationError";
            errorCode = (ANAdResponseCode)ANAdResponseMediatedSDKUnavailable;
            break;
        }
        
        // instance valid - request a mediated ad
        id<ANNativeCustomAdapter> adapter = (id<ANNativeCustomAdapter>)adInstance;
        adapter.requestDelegate = self;
        self.currentAdapter = adapter;
        
        [self markLatencyStart];
        [self startTimeout];
        
        [self.currentAdapter requestNativeAdWithServerParameter:self.mediatedAd.param
                                                       adUnitId:self.mediatedAd.adId
                                            targetingParameters:[self targetingParameters]];
    } while (false);

    if (errorCode != (ANAdResponseCode)ANDefaultCode) {
        [self handleInstantiationFailure:className
                               errorCode:errorCode
                               errorInfo:errorInfo];
        return NO;
    }
    
    return YES;
}

- (BOOL)validAdInstance:(id)adInstance {
    if (!adInstance) {
        return NO;
    }
    if (![adInstance conformsToProtocol:@protocol(ANNativeCustomAdapter)]) {
        return NO;
    }
    if (![adInstance respondsToSelector:@selector(setRequestDelegate:)]) {
        return NO;
    }
    if (![adInstance respondsToSelector:@selector(requestNativeAdWithServerParameter:adUnitId:targetingParameters:)]) {
        return NO;
    }
    return YES;
}

- (void)handleInstantiationFailure:(NSString *)className
                         errorCode:(ANAdResponseCode)errorCode
                         errorInfo:(NSString *)errorInfo
{
    if ([errorInfo length] > 0) {
        ANLogError(@"mediation_instantiation_failure %@", errorInfo);
    }

    [self didFailToReceiveAd:errorCode];
}

- (void)setAdapter:(id<ANNativeCustomAdapter>)adapter {
    self.currentAdapter = adapter;
}

- (void)clearAdapter {
    if (self.currentAdapter)
        self.currentAdapter.requestDelegate = nil;
    self.currentAdapter = nil;
    self.hasSucceeded = NO;
    self.hasFailed = YES;
    [self cancelTimeout];
    ANLogInfo(@"mediation_finish");
}

- (ANTargetingParameters *)targetingParameters
{
    ANTargetingParameters *targetingParameters = [[ANTargetingParameters alloc] init];
    
    NSMutableDictionary<NSString *, NSString *>  *customKeywordsAsStrings  = [ANGlobal convertCustomKeywordsAsMapToStrings: self.adRequestDelegate.customKeywords
                                                                                                       withSeparatorString: @"," ];

    targetingParameters.customKeywords    = customKeywordsAsStrings;
    targetingParameters.age               = self.adRequestDelegate.age;
    targetingParameters.gender            = self.adRequestDelegate.gender;
    targetingParameters.externalUid       = self.adRequestDelegate.externalUid;
    targetingParameters.location          = self.adRequestDelegate.location;
    targetingParameters.idforadvertising  = ANUDID();

    return targetingParameters;
}

#pragma mark - helper methods

- (BOOL)checkIfHasResponded {
    // we received a callback from mediation adaptor, cancel timeout
    [self cancelTimeout];
    // don't succeed or fail more than once per mediated ad
    return (self.hasSucceeded || self.hasFailed);
}

- (void)didReceiveAd:(id)adObject {
    if ([self checkIfHasResponded]) return;
    if (!adObject) {
        [self didFailToReceiveAd:(ANAdResponseCode)ANAdResponseInternalError];
        return;
    }
    self.hasSucceeded = YES;
    [self markLatencyStop];
    
    ANLogDebug(@"received an ad from the adapter");
    
    [self finish:(ANAdResponseCode)ANAdResponseSuccessful withAdObject:adObject];
}

- (void)didFailToReceiveAd:(ANAdResponseCode)errorCode {
    if ([self checkIfHasResponded]) return;
    [self markLatencyStop];
    self.hasFailed = YES;
    [self finish:errorCode withAdObject:nil];
}

- (void)finish:(ANAdResponseCode)errorCode withAdObject:(id)adObject
{
    // use queue to force return
    [self runInBlock:^(void) {
        NSString *responseURLString = [self createResponseURLRequest: self.mediatedAd.responseURL
                                                              reason: errorCode ];

        // fireResulCB will clear the adapter if fetcher exists
        if (!self.adFetcher) {
            [self clearAdapter];
        }

        [self.adFetcher fireResponseURL:responseURLString reason:errorCode adObject:adObject auctionID:nil];
    } ];
}

- (NSString *)createResponseURLRequest:(NSString *)baseString reason:(int)reasonCode {
    if ([baseString length] < 1) {
        return @"";
    }
    
    // append reason code
    NSString *responseURLString = [baseString an_stringByAppendingUrlParameter: @"reason"
                                                                         value: [NSString stringWithFormat:@"%d",reasonCode]];
    
    // append latency measurements
    NSTimeInterval latency = [self getLatency] * 1000; // secs to ms
    NSTimeInterval totalLatency = [self getTotalLatency] * 1000; // secs to ms
    
    if (latency > 0) {
        responseURLString = [responseURLString an_stringByAppendingUrlParameter: @"latency"
                                                                          value: [NSString stringWithFormat:@"%.0f", latency]];
    }
    if (totalLatency > 0) {
        responseURLString = [responseURLString an_stringByAppendingUrlParameter: @"total_latency"
                                                                          value: [NSString stringWithFormat:@"%.0f", totalLatency]];
    }

ANLogDebug(@"responseURLString=%@", responseURLString);
    return responseURLString;
}

#pragma mark - Timeout handler

- (void)startTimeout {
    if (self.timeoutCanceled) return;
    __weak ANNativeMediatedAdController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 kAppNexusMediationNetworkTimeoutInterval
                                 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
                       ANNativeMediatedAdController *strongSelf = weakSelf;
                       if (!strongSelf || strongSelf.timeoutCanceled) return;
                       ANLogWarn(@"mediation_timeout");
                       [strongSelf didFailToReceiveAd:(ANAdResponseCode)ANAdResponseInternalError];
                   });
}

- (void)cancelTimeout {
    self.timeoutCanceled = YES;
}

# pragma mark - Latency Measurement

/**
 * Should be called immediately after mediated SDK returns
 * from `requestAd` call.
 */
- (void)markLatencyStart {
    self.latencyStart = [NSDate timeIntervalSinceReferenceDate];
}

/**
 * Should be called immediately after mediated SDK
 * calls either of `onAdLoaded` or `onAdFailed`.
 */
- (void)markLatencyStop {
    self.latencyStop = [NSDate timeIntervalSinceReferenceDate];
}

/**
 * The latency of the call to the mediated SDK.
 */
- (NSTimeInterval)getLatency {
    if ((self.latencyStart > 0) && (self.latencyStop > 0)) {
        return (self.latencyStop - self.latencyStart);
    }
    // return -1 if invalid.
    return -1;
}

/**
 * The running total latency of the ad call.
 */
- (NSTimeInterval)getTotalLatency {
    if (self.adFetcher && (self.latencyStop > 0)) {
        return [self.adFetcher getTotalLatency:self.latencyStop];
    }
    // return -1 if invalid.
    return -1;
}

#pragma mark - ANNativeCustomAdapterRequestDelegate

- (void)didLoadNativeAd:(ANNativeMediatedAdResponse *)response {
    [self didReceiveAd:response];
}

- (void)didFailToLoadNativeAd:(ANAdResponseCode)errorCode {
    [self didFailToReceiveAd:errorCode];
}

@end
