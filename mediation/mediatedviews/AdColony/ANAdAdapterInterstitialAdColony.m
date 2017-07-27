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

    self.parameterString       = parameterStringValue;
    self.zoneID                = idStringValue;
    self.targettingParameters  = targetingParametersValue;

    self.interstitialAd  = nil;
    self.isAdShown       = NO;


    //
    __weak ANAdAdapterInterstitialAdColony  *weakSelf  = self;

    [ANAdAdapterBaseAdColony initializeAdColonySDKWithTargetingParameters: targetingParametersValue
                                                         completionAction: ^{
                                                             __strong ANAdAdapterInterstitialAdColony  *strongSelf  = weakSelf;
                                                             if (!strongSelf)  {
                                                                 ANLogDebug(@"CANNOT EVALUATE strongSelf.");
                                                                 return;
                                                             }

                                                             [strongSelf requestInterstitialFromSDK];
                                                         }
     ];
}

- (void) requestInterstitialFromSDK
{
ANLogMark();

    AdColonyZone  *zone  = [AdColony zoneForID:self.zoneID];

    if (!zone) {
        ANLogDebug(@"AdColony zoneID is INVALID.  (%@)", self.zoneID);
        [self.delegate didFailToLoadAd:ANAdResponseInvalidRequest];
        return;
    } else if (!zone.enabled) {
        ANLogDebug(@"AdColony zoneID is NOT ENABLED.  (%@)", self.zoneID);
        [self.delegate didFailToLoadAd:ANAdResponseInvalidRequest];
        return;
    }


    //
    __weak ANAdAdapterInterstitialAdColony  *weakSelf  = self;

    // ASSUMING nothing is lost by not setting AdColonyAdOptions because...
    // AdColonyAppOptions is set (and reset) in [ANAdAdapterBaseAdColony initializeAdColonySDKWithTargetingParameters:completionAction:].
    //
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
                                             [strongSelf.delegate didLoadInterstitialAd:strongSelf];
                                         }

                                failure: ^(AdColonyAdRequestError * _Nonnull error)
                                         {
                                             __strong ANAdAdapterInterstitialAdColony  *strongSelf  = weakSelf;
                                             if (!strongSelf) {
                                                 ANLogDebug(@"CANNOT EVALUATE strongSelf.");
                                                 return;
                                             }

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
                                             [strongSelf.delegate didFailToLoadAd:anAdResponseCode];
                                         }
     ];
}

- (void) configureAdColonyAdEventHandlers
{
    ANLogMark();

    __weak ANAdAdapterInterstitialAdColony  *weakSelf  = self;

    [self.interstitialAd setOpen:^{
        __strong ANAdAdapterInterstitialAdColony  *strongSelf  = weakSelf;
        if (!strongSelf) {
            ANLogDebug(@"CANNOT EVALUATE strongSelf.");
            return;
        }

        strongSelf.isAdShown = YES;
        [strongSelf.delegate didPresentAd];
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

        __strong ANAdAdapterInterstitialAdColony  *strongSelf  = weakSelf;
        if (!strongSelf) {
            ANLogDebug(@"CANNOT EVALUATE strongSelf.");
            return;
        }


        if (!strongSelf.isAdShown) {
            ANLogDebug(@"Refreshing interstitial ad...");

            [strongSelf requestInterstitialAdWithParameter: strongSelf.parameterString
                                                  adUnitId: strongSelf.zoneID
                                       targetingParameters: strongSelf.targettingParameters ];
        }
    }];

    [self.interstitialAd setClick:^{
        __strong ANAdAdapterInterstitialAdColony  *strongSelf  = weakSelf;
        if (!strongSelf) {
            ANLogDebug(@"CANNOT EVALUATE strongSelf.");
            return;
        }

        [strongSelf.delegate adWasClicked];
    }];

    [self.interstitialAd setLeftApplication:^{
        __strong ANAdAdapterInterstitialAdColony  *strongSelf  = weakSelf;
        if (!strongSelf) {
            ANLogDebug(@"CANNOT EVALUATE strongSelf.");
            return;
        }

        [strongSelf.delegate willLeaveApplication];
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
