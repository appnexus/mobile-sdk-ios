/*   Copyright 2017 APPNEXUS INC
 
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


#import "ANAdAdapterInterstitialAdMarvel.h"
#import "ANAdAdapterAdMarvelBase+PrivateMethods.h"
#import "AdMarvelView.h"
#import "ANLogging.h"

@interface ANAdAdapterInterstitialAdMarvel ()

@property (nonatomic, strong) AdMarvelView *adMarvelView;

@end

@implementation ANAdAdapterInterstitialAdMarvel

@synthesize delegate;

- (void)requestInterstitialAdWithParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)idString
                       targetingParameters:(ANTargetingParameters *)targetingParameters {
    ANLogDebug(@"Requesting AdMarvel interstitial");
    [self setSiteAndPartnerIdParameters:idString];
    
    [self setTargetingParameters:targetingParameters];
    
    self.adMarvelView = [AdMarvelView createAdMarvelViewWithDelegate:self];
    
    if (![self.adMarvelView isInterstitialReady])
    {
        [self startAdRequest];
    }
}

- (BOOL)isReady {
    return self.adMarvelView.isInterstitialReady;
}

- (void)dealloc {
    self.adMarvelView.delegate = nil;
}

- (void)presentFromViewController:(UIViewController *)viewController {
    [self setRootViewController:viewController];
    
    if (![self isReady]) {
        ANLogDebug(@"AdMarvel interstitial was unavailable");
        [self.delegate failedToDisplayAd];
        return;
    }
    
    [self.adMarvelView displayInterstitial];
}

#pragma mark Private methods

-(void) startAdRequest{
    [self.adMarvelView getInterstitialAd];
}

#pragma mark callback methods

- (void) handleAdMarvelSDKClick:(NSString *)urlString forAdMarvelView:(AdMarvelView *)adMarvelView
{
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate adWasClicked];

}

- (void) getInterstitialAdSucceeded:(AdMarvelView *)adMarvelView
{
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didLoadInterstitialAd:self];
    
}

- (void) getInterstitialAdFailed:(AdMarvelView *)adMarvelView
{
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
}

- (void) interstitialActivated:(AdMarvelView *)adMarvelView
{
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void) interstitialClosed:(AdMarvelView *)adMarvelView
{
    ANLogTrace(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
     [self.delegate didCloseAd];
}

@end
