/*   Copyright 2016 APPNEXUS INC
 
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
#import "ANAdAdapterInterstitialSmartAd.h"
#import "ANLogging.h"
#import "ANAdAdapterSmartAdBase+PrivateMethods.h"

@interface ANAdAdapterInterstitialSmartAd ()
    
    @property (nonatomic, strong) SASInterstitialView *sasInterstitialAd;
    
@end

@implementation ANAdAdapterInterstitialSmartAd

    
@synthesize delegate;
    
- (void)requestInterstitialAdWithParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)idString
                       targetingParameters:(ANTargetingParameters *)targetingParameters {
    
    NSDictionary * adUnitDictionary = [self parseAdUnitParameters:idString];
    NSString *targetString;
    if(targetingParameters != nil){
        targetString = [super keywordsFromTargetingParameters:targetingParameters];
    }
    
    if(adUnitDictionary[SMARTAD_SITEID] == nil || [adUnitDictionary[SMARTAD_SITEID] isEqualToString:@""]){
        ANLogTrace(@"SmartAd mediation failed. siteId not provided in the adUnit dictionary");
        [self.delegate didFailToLoadAd:ANAdResponseMediatedSDKUnavailable];
        return;
    }else {
        NSString *pageId = adUnitDictionary[SMARTAD_PAGEID];
        NSString *formatIdString = adUnitDictionary[SMARTAD_FORMATID];
        self.sasInterstitialAd = [[SASInterstitialView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height) loader:NO];
        self.sasInterstitialAd.delegate = self;
        if(formatIdString != nil && ![formatIdString isEqualToString:@""]){
            [self.sasInterstitialAd loadFormatId:[formatIdString integerValue] pageId:pageId master:YES target:targetString];
        }else {
            ANLogTrace(@"SmartAd mediation failed. FormatId not provided in the adUnit dictionary");
            [self.delegate didFailToLoadAd:ANAdResponseMediatedSDKUnavailable];
            return;
        }
    }
}

- (void)presentFromViewController:(UIViewController *)viewController {
    self.sasInterstitialAd.modalParentViewController = viewController;
     [[self rootView] addSubview:self.sasInterstitialAd];
}

-(UIView *) rootView{
    return [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
}
    
#pragma mark - SASAdView delegate

- (void)adViewDidLoad:(SASAdView *)adView {
    ANLogTrace(@"");
    [self.delegate didLoadInterstitialAd:self];
    
}
    
    
- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error {
    ANLogTrace(@"");
    [self.delegate didFailToLoadAd:ANAdResponseUnableToFill];
   
}

- (void)adViewDidDisappear:(SASAdView *)adView {
    ANLogTrace(@"");
    [self.delegate didCloseAd];
    
}

- (BOOL)adView:(nonnull SASAdView *)adView shouldHandleURL:(nonnull NSURL *)URL{
    
    ANLogTrace(@"");
    [self.delegate adWasClicked];
    return YES;
    
}

@end
