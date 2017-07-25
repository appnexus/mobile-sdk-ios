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

@property (nonatomic, readwrite, strong)  NSString               *parameterString;
@property (nonatomic, readwrite, strong)  NSString               *zoneID;   //Equal to idStringValue.
@property (nonatomic, readwrite, strong)  ANTargetingParameters  *targettingParameters;

@property (nonatomic, strong)             AdColonyInterstitial  *interstitialAd;
@property (nonatomic)                     BOOL                   isAdShown;



@end



@implementation ANAdAdapterInterstitialAdColony

#pragma mark - ANCustomAdapterInterstitial

@synthesize delegate = _delegate;

- (void)requestInterstitialAdWithParameter:(NSString *)parameterStringValue
                                  adUnitId:(NSString *)idStringValue
                       targetingParameters:(ANTargetingParameters *)targetingParametersValue
{
    ANLogTrace(@"");

    [ANAdAdapterBaseAdColony setAdColonyTargetingWithTargetingParameters:targetingParametersValue];

    self.parameterString       = parameterStringValue;
    self.zoneID                = idStringValue;
    self.targettingParameters  = targetingParametersValue;

    self.interstitialAd  = nil;
    self.isAdShown       = NO;


    //
//    [ANAdAdapterBaseAdColony initializeAdColonySDK:^{ [self requestInterstitialFromSDK]; }];
    [ANAdAdapterBaseAdColony initializeAdColonySDK:nil];

    [NSThread sleepForTimeInterval:5];

    if (! self.interstitialAd) {
        ANLogMarkMessage(@"NEED TO DO THIS AGAIN?");  //FIX  probably not...
        [self requestInterstitialFromSDK];
    }


                /*
    AdColonyZone  *zone  = [AdColony zoneForID:self.zoneID];

    if (!zone.enabled) {
        ANLogDebug(@"AdColony zoneID is NOT ENABLED.  (%@)", self.zoneID);
        [self.delegate didFailToLoadAd:ANAdResponseInvalidRequest];
        return;
    }


    //
    __weak ANAdAdapterInterstitialAdColony  *weakSelf  = self;

    [AdColony requestInterstitialInZone: self.zoneID
                                options: nil

                                success: ^(AdColonyInterstitial * _Nonnull ad)
                                {
                                    __strong ANAdAdapterInterstitialAdColony  *strongSelf  = weakSelf;
                                    if (!strongSelf) {
                                        ANLogDebug(@"CANNOT EVALUATE strongSelf.");
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

                                    switch (error.code) {
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
                                        default:
                                            ANLogDebug(@"AdColony FAILURE with UNKNOWN CODE.  (%@)", @(error.code));
                                    }

                                    ANLogDebug(@"AdColony interstitial unavailable.");
                                    [self.delegate didFailToLoadAd:anAdResponseCode];
                                }
     ];
                    */
}

- (void) requestInterstitialFromSDK
{
ANLogMark();

    AdColonyZone  *zone  = [AdColony zoneForID:self.zoneID];

    if (!zone.enabled) {
        ANLogDebug(@"AdColony zoneID is NOT ENABLED.  (%@)", self.zoneID);
        [self.delegate didFailToLoadAd:ANAdResponseInvalidRequest];
        return;
    }


    //
    __weak ANAdAdapterInterstitialAdColony  *weakSelf  = self;

    [AdColony requestInterstitialInZone: self.zoneID
                                options: nil

                                success: ^(AdColonyInterstitial * _Nonnull ad)
                                         {
                                             __strong ANAdAdapterInterstitialAdColony  *strongSelf  = weakSelf;
                                             if (!strongSelf) {
                                                 ANLogDebug(@"CANNOT EVALUATE strongSelf.");
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

                                             switch (error.code) {
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
                                                 default:
                                                     ANLogDebug(@"AdColony FAILURE with UNKNOWN CODE.  (%@)", @(error.code));
                                             }

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
        weakSelf.isAdShown = YES;
        [weakSelf.delegate didPresentAd];
    }];

    [self.interstitialAd setClose:^{
        __strong ANAdAdapterInterstitialAdColony  *strongSelf  = weakSelf;
        if (!strongSelf) {
            ANLogError(@"CANNOT EVALUATE strongSelf.");
            return;
        }

        [strongSelf.delegate willCloseAd];
        [strongSelf.delegate didCloseAd];
    }];

    [self.interstitialAd setExpire:^{
        ANLogDebug(@"Interstitial ad WILL EXPIRE in 5 seconds...");  //XXX

        if (!weakSelf.isAdShown) {
            ANLogDebug(@"Refreshing interstitial ad...");

            [weakSelf requestInterstitialAdWithParameter: weakSelf.parameterString
                                                adUnitId: weakSelf.zoneID
                                     targetingParameters: weakSelf.targettingParameters ];
        }
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
