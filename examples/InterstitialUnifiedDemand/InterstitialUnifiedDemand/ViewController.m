//
//  ViewController.m
//  VASTInterstitialDemo
//
//  Created by Jose Cabal-Ugaz on 10/22/15.
//  Copyright © 2015 AppNexus. All rights reserved.
//

#import "ViewController.h"
#import "ANInterstitialAd.h"
#import "ANLogManager.h"

@interface ViewController () <ANInterstitialAdDelegate, ANVideoAdDelegate>

@property (nonatomic) ANInterstitialAd *interstitialAd;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [ANLogManager setANLogLevel:ANLogLevelAll];
    // VAST Placement
    self.interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:@"5778861"];
    // HTML Placement
//    self.interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:@"2140061"];
    self.interstitialAd.closeDelay = 5.0;
    self.interstitialAd.opensInNativeBrowser = NO;
    self.interstitialAd.shouldServePublicServiceAnnouncements = YES;
    self.interstitialAd.delegate = self;
    [self.interstitialAd loadAd];
}

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
    NSLog(@"adDidReceiveAd");
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error {
    NSLog(@"ad:requestFailedWithError:");
}

- (IBAction)onTap:(UITapGestureRecognizer *)sender {
    [self.interstitialAd displayAdFromViewController:self];
    [self.interstitialAd loadAd];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"view did appear");
}

- (void)videoAdPaused:(ANInterstitialAd *)ad {
    
}

- (void)videoAdStarted:(ANInterstitialAd *)ad {
    
}

- (void)videoAdFinishedPlaying:(ANInterstitialAd *)ad {
    
}

- (void)videoAdResumed:(ANInterstitialAd *)ad {
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end