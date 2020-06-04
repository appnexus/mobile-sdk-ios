/*   Copyright 2020 APPNEXUS INC
 
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
#import "ANCSRNativeAdController.h"
#import "ANNativeAdFetcher.h"
#import "ANLogging.h"
#import "NSString+ANCategory.h"
#import "NSObject+ANCategory.h"
#import "ANNativeAdResponse+PrivateMethods.h"
#import "ANNativeMediatedAdResponse+PrivateMethods.h"

@interface ANCSRNativeAdController () <ANNativeCustomAdapterRequestDelegate>

@property (nonatomic, readwrite, strong) ANCSRAd *csrAd;
@property (nonatomic, readwrite, strong) id<ANNativeCustomAdapter> currentAdapter;

@end



@implementation ANCSRNativeAdController
@synthesize adFetcher;
@synthesize adRequestDelegate;


+ (instancetype)initCSRAd: (ANCSRAd *)csrAd
                   withFetcher: (ANNativeAdFetcher *)adFetcher
             adRequestDelegate: (id<ANNativeAdFetcherDelegate>)adRequestDelegate
{
    ANCSRNativeAdController *controller = [[ANCSRNativeAdController alloc] initCSRAd: csrAd
                                                                                          withFetcher: adFetcher
                                                                                    adRequestDelegate: adRequestDelegate];
    if ([controller initializeRequest]) {
        return controller;
    } else {
        return nil;
    }

}

- (instancetype)initCSRAd: (ANCSRAd *)csrAd
                   withFetcher: (ANNativeAdFetcher *)adFetcher
             adRequestDelegate: (id<ANNativeAdFetcherDelegate>)adRequestDelegate
{
    self = [super init];
    if (self) {
        self.adFetcher  = adFetcher;
        self.adRequestDelegate = adRequestDelegate;
        self.csrAd = csrAd;
    }
    return self;
}


- (BOOL)initializeRequest {
    NSString *className = nil;
    NSString *errorInfo = nil;
    ANAdResponseCode errorCode = (ANAdResponseCode)ANDefaultCode;

    do {
        // check that the ad is non-nil
        if (!self.csrAd) {
            errorInfo = @"null csrAd ad object";
            errorCode = (ANAdResponseCode)ANAdResponseUnableToFill;
            break;
        }
        
        className = self.csrAd.className;
        ANLogDebug(@"instantiating_class %@", className);
        
        // notify that a csrAd class name was received
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
        
        // instance valid - request a csr ad
        id<ANNativeCustomAdapter> adapter = (id<ANNativeCustomAdapter>)adInstance;
        adapter.requestDelegate = self;
        self.currentAdapter = adapter;
        
        [self markLatencyStart];
        [self startTimeout];
        [self.currentAdapter requestAdwithPayload:self.csrAd.payload targetingParameters:[self targetingParameters]];
         
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
    if (![adInstance respondsToSelector:@selector(requestAdwithPayload:targetingParameters:)]) {
        return NO;
    }
    return YES;
}

#pragma mark - Timeout handler

- (void)startTimeout {
    if (self.timeoutCanceled) return;
    __weak ANCSRNativeAdController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                  kAppNexusMediationNetworkTimeoutInterval
                                  * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
                       ANCSRNativeAdController *strongSelf = weakSelf;
                       if (!strongSelf || strongSelf.timeoutCanceled) return;
                       ANLogWarn(@"mediation_timeout");
                       [strongSelf didFailToReceiveAd:(ANAdResponseCode)ANAdResponseInternalError];
                   });
}

#pragma mark - ANNativeCustomAdapterRequestDelegate

- (void)didLoadNativeAd:(nonnull ANNativeMediatedAdResponse *)response {
    // Add the AppNexusImpression trackers into the CSR response.
    response.impTrackers= [self.csrAd.impressionUrls copy];
    response.verificationScriptResource  = self.csrAd.verificationScriptResource;
    response.clickUrls = self.csrAd.clickUrls;
    [self didReceiveAd:response];
}

- (void)didFailToLoadNativeAd:(ANAdResponseCode)errorCode {
    [self didFailToReceiveAd:errorCode];
}


@end
