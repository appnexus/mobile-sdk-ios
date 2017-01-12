//
//  ANAdAdapterInterstitialSmartAd.m
//  ANSDK
//
//  Created by Punnaghai Puviarasu on 11/21/16.
//  Copyright © 2016 AppNexus. All rights reserved.
//

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
    
    if(adUnitDictionary[SMART_SITEID] == nil || [adUnitDictionary[SMART_SITEID] isEqualToString:@""]){
        ANLogTrace(@"SmartAd mediation failed. siteId not provided in the adUnit dictionary");
        [self.delegate didFailToLoadAd:ANAdResponseMediatedSDKUnavailable];
        return;
    }else {
        NSString *pageId = adUnitDictionary[SMART_PAGEID];
        NSString *formatIdString = adUnitDictionary[SMART_FORMATID];
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
