//
//  ANAdAdapterInterstitialSmartAd.m
//  ANSDK
//
//  Created by Punnaghai Puviarasu on 11/21/16.
//  Copyright © 2016 AppNexus. All rights reserved.
//

#import "ANAdAdapterInterstitialSmartAd.h"

@interface ANAdAdapterInterstitialSmartAd ()
    
    @property (nonatomic, strong) SASInterstitialView *sasInterstitialAd;
    
@end

@implementation ANAdAdapterInterstitialSmartAd

    
@synthesize delegate;
    
- (void)requestInterstitialAdWithParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)idString
                       targetingParameters:(ANTargetingParameters *)targetingParameters {
    
    
    self.sasInterstitialAd = [[SASInterstitialView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height) loader:NO];
    self.sasInterstitialAd.delegate = self;
    [SASAdView setSiteID:54522 baseURL:@"https://mobile.smartadserver.com"];
    [self.sasInterstitialAd loadFormatId:14514 pageId:@"401554" master:YES target:nil];
    
}

- (void)presentFromViewController:(UIViewController *)viewController {
    self.sasInterstitialAd.modalParentViewController = viewController;
     [[[[[[UIApplication sharedApplication] delegate] window] rootViewController] view] addSubview:self.sasInterstitialAd];
}
    
#pragma mark - SASAdView delegate

- (void)adViewDidLoad:(SASAdView *)adView {
    NSLog(@"Interstitial has been loaded");
    [self.delegate didLoadInterstitialAd:self];
    
    
}
    
    
- (void)adView:(SASAdView *)adView didFailToLoadWithError:(NSError *)error {
    NSLog(@"Interstitial has failed to load with error: %@", [error description]);
   
}
    
    
- (void)adViewDidDisappear:(SASAdView *)adView {
    NSLog(@"Interstitial has disappeared");
    
}

@end
