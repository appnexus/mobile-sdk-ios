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

#import "ANNativeAdFetcher.h"
#import "ANUniversalTagRequestBuilder.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANLogging.h"

#import "ANStandardAd.h"
#import "ANRTBVideoAd.h"
#import "ANCSMVideoAd.h"
#import "ANSSMStandardAd.h"
#import "ANNativeStandardAdResponse.h"
#import "ANMediatedAd.h"
#import "ANNativeMediatedAdController.h"
#import "ANTrackerInfo.h"
#import "ANTrackerManager.h"
#import "NSTimer+ANCategory.h"

@interface ANNativeAdFetcher()

@property (nonatomic, readwrite, strong)  ANNativeMediatedAdController      *nativeMediationController;
@end

@implementation ANNativeAdFetcher

- (instancetype)initWithDelegate:(id)delegate{
    if (self = [self init]) {
        self.delegate = delegate;
        [self setup];
    }
    return self;
}

- (void)clearMediationController {
    /*
     * Ad fetcher gets cleared, in the event the mediation controller lives beyond the ad fetcher.  The controller maintains a weak reference to the
     * ad fetcher delegate so that messages to the delegate can proceed uninterrupted.  Currently, the controller will only live on if it is still
     * displaying inside a banner ad view (in which case it will live on until the individual ad is destroyed).
     */
    self.nativeMediationController.adFetcher = nil;
    self.nativeMediationController = nil;

}



#pragma mark - UT ad response processing methods
- (void)finishRequestWithError:(NSError *)error
{
    self.loading = NO;
    ANLogInfo(@"No ad received. Error: %@", error.localizedDescription);
    ANAdFetcherResponse *response = [ANAdFetcherResponse responseWithError:error];
    [self processFinalResponse:response];
}

- (void)processFinalResponse:(ANAdFetcherResponse *)response
{
    self.ads = nil;
    self.loading = NO;
    
    if ([self.delegate respondsToSelector:@selector(didFinishRequestWithResponse:)]) {
        [self.delegate didFinishRequestWithResponse:response];
    }
}

//NB  continueWaterfall is co-functional the ad handler methods.
//    The loop of the waterfall lifecycle is managed by methods calling one another
//      until a valid ad object is found OR when the waterfall runs out.
//
- (void)continueWaterfall
{
    // stop waterfall if delegate reference (adview) was lost
    if (!self.delegate) {
        self.loading = NO;
        return;
    }
    
    BOOL adsLeft = (self.ads.count > 0);
    
    if (!adsLeft) {
        ANLogWarn(@"response_no_ads");
        if (self.noAdUrl) {
            ANLogDebug(@"(no_ad_url, %@)", self.noAdUrl);
            [ANTrackerManager fireTrackerURL:self.noAdUrl];
        }
        [self finishRequestWithError:ANError(@"response_no_ads", ANAdResponseUnableToFill)];
        return;
    }
    
    
    //
    id nextAd = [self.ads firstObject];
    [self.ads removeObjectAtIndex:0];
    
    self.adObjectHandler = nextAd;
    
    
    if ( [nextAd isKindOfClass:[ANMediatedAd class]] ) {
        [self handleCSMSDKMediatedAd:nextAd];
    } else if ( [nextAd isKindOfClass:[ANNativeStandardAdResponse class]] ) {
        [self handleNativeStandardAd:nextAd];
    }else {
        ANLogError(@"Implementation error: Unspported ad in native ads waterfall.  (class=%@)", [nextAd class]);
        [self continueWaterfall]; // skip this ad an jump to next ad
    }
}

- (void)restartAutoRefreshTimer
{
    // Implemented only by ANUniversalAdFetcher
}

#pragma mark - Ad handlers.

- (void)handleCSMSDKMediatedAd:(ANMediatedAd *)mediatedAd
{
    if (mediatedAd.isAdTypeNative)
    {
        self.nativeMediationController = [ANNativeMediatedAdController initMediatedAd: mediatedAd
                                                                          withFetcher: self
                                                                    adRequestDelegate: self.delegate ];
    } else {
        // TODO: should do something here
    }
}

- (void)handleNativeStandardAd:(ANNativeStandardAdResponse *)nativeStandardAd
{
    
    ANAdFetcherResponse  *fetcherResponse  = [ANAdFetcherResponse responseWithAdObject:nativeStandardAd andAdObjectHandler:nil];
    [self processFinalResponse:fetcherResponse];
}


@end
