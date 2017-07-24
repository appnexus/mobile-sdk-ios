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

#import <AdColony/AdColony.h>
#import <AdColony/AdColonyAdOptions.h>
#import <AdColony/AdColonyAdRequestError.h>
#import <AdColony/AdColonyAppOptions.h>
#import <AdColony/AdColonyInterstitial.h>
#import <AdColony/AdColonyOptions.h>
#import <AdColony/AdColonyTypes.h>
#import <AdColony/AdColonyUserMetadata.h>
#import <AdColony/AdColonyZone.h>

#import "ANAdAdapterBaseAdColony.h"
#import "ANAdAdapterBaseAdColony+PrivateMethods.h"
#import "ANAdAdapterInterstitialAdColony.h"

#import "ANLogging.h"



@interface ANAdAdapterInterstitialAdColony()

@property (nonatomic, readwrite, strong)  NSString              *zoneID;
@property (nonatomic, strong)             AdColonyInterstitial  *interstitialAd;

@end



@implementation ANAdAdapterInterstitialAdColony

#pragma mark - ANCustomAdapterInterstitial

@synthesize delegate = _delegate;

- (void)requestInterstitialAdWithParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)idString
                       targetingParameters:(ANTargetingParameters *)targetingParameters
{
    ANLogTrace(@"");

    [ANAdAdapterBaseAdColony setAdColonyTargetingWithTargetingParameters:targetingParameters];
    self.zoneID = idString;
    self.interstitialAd = nil;


    AdColonyZone  *zone  = [AdColony zoneForID:self.zoneID];

    if (![ANAdAdapterBaseAdColony isReadyToServeAds] || !zone.enabled) {
        ANLogDebug(@"AdColony interstitial unavailable.");
        [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
        return;
    }


    //
    __weak ANAdAdapterInterstitialAdColony  *weakSelf  = self;

    AdColonyAdOptions  *adOptions  = [[AdColonyAdOptions alloc] init];
    [AdColony requestInterstitialInZone: self.zoneID
                                options: adOptions

                                success: ^(AdColonyInterstitial * _Nonnull ad)
                                {
                                    __strong ANAdAdapterInterstitialAdColony  *strongSelf  = weakSelf;
                                    if (!strongSelf) {
                                        ANLogDebug(@"CANNOT EVALUATE pointer to self.");
                                        return;
                                    }

                                    strongSelf.interstitialAd = ad;
                                    [strongSelf configureAdColonyAdEventHandlers];

                                    //
                                    ANLogDebug(@"AdColony interstitial ad available.");
                                    [self.delegate didLoadInterstitialAd:self];
                                }

                                failure: ^(AdColonyAdRequestError * _Nonnull error)
                                {
                                    ANAdResponseCode  anAdResponseCode  = ANAdResponseInternalError;

                                            /* FIX  pointer to NS_ENUM?!
                                    switch (error) {
                                    case AdColonyRequestErrorInvalidRequest:
                                            anAdResponseCode = ANAdResponseInvalidRequest;
                                            break;
                                    case AdColonyRequestErrorSkippedRequest:
                                            anAdResponseCode = ANAdResponseUnableToFill;
                                            break;
                                    case AdColonyRequestErrorNoFillForRequest:
                                            anAdResponseCode = ANAdResponseUnableToFill;
                                            break;
                                    case AdColonyRequestErrorUnready:
                                            anAdResponseCode = ANAdResponseInternalError;
                                            break;
                                    }
                                                     */

                                    ANLogDebug(@"AdColony interstitial unavailable.");
                                    [self.delegate didFailToLoadAd:anAdResponseCode];
                                }
     ];
}

- (void) configureAdColonyAdEventHandlers
        //FIX HANDLE audio start/stop?
{
    ANLogMark();

    __weak ANAdAdapterInterstitialAdColony  *weakSelf  = self;

    [self.interstitialAd setOpen:^{
        [weakSelf.delegate didPresentAd];
    }];

    [self.interstitialAd setClose:^{
        __strong ANAdAdapterInterstitialAdColony  *strongSelf  = weakSelf;
        if (!strongSelf) {
            ANLogError(@"CANNOT EVALUATE pointer to self.");
            return;
        }

        [strongSelf.delegate willCloseAd];
        [strongSelf.delegate didCloseAd];
    }];

    [self.interstitialAd setExpire:^{
        ANLogDebug(@"Interstitial ad WILL EXPIRE in 5 seconds....");
    }];

    [self.interstitialAd setClick:^{
        [weakSelf.delegate adWasClicked];
    }];

    [self.interstitialAd setLeftApplication:^{
        [weakSelf.delegate willLeaveApplication];
    }];
}

- (BOOL)isReady
{
    ANLogTrace(@"");

    return  self.interstitialAd && !self.interstitialAd.expired;
}


- (void)presentFromViewController:(UIViewController *)viewController
{
    ANLogTrace(@"");

    if (![self isReady]) {
        ANLogDebug(@"failedToDisplayAd");
        [self.delegate failedToDisplayAd];
        return;
    }

    [self.delegate willPresentAd];
    [self.interstitialAd showWithPresentingViewController:viewController];
}


@end
