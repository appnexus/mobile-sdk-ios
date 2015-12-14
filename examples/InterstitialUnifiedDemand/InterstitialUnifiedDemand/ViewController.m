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
    [ANLogManager setANLogLevel:ANLogLevelOff];
    // VAST Placement
    self.interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:@"5778861"];
    // HTML Placement
//    self.interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:@"2140061"];
    self.interstitialAd.closeDelay = 5.0;
    self.interstitialAd.opensInNativeBrowser = NO;
    self.interstitialAd.shouldServePublicServiceAnnouncements = YES;
    self.interstitialAd.delegate = self;
    self.interstitialAd.videoAdDelegate = self;
    self.view.accessibilityLabel = @"interstitial";
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

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - VideoDelegates

- (void)adStartedPlayingVideo:(id<ANAdProtocol>)ad{
    NSLog(@"App: video started playing.");
}

- (void)adPausedVideo:(id<ANAdProtocol>)ad{
    NSLog(@"App: video paused.");
}

- (void)adResumedVideo:(id<ANAdProtocol>)ad{
    NSLog(@"App: video Resumed.");
}

- (void)adWasClicked:(id<ANAdProtocol>)ad{
    NSLog(@"App: video was clicked.");
}

- (void)adWillClose:(id<ANAdProtocol>)ad{
    NSLog(@"App: video will close.");
}

- (void)adDidClose:(id<ANAdProtocol>)ad{
    NSLog(@"App: video did close.");
}

- (void)adMuted:(BOOL)isMuted withAd:(id<ANAdProtocol>)ad{
    NSLog(@"App: video muted: %i", isMuted);
}

- (void)adSkippedVideo:(id<ANAdProtocol>)ad{
    NSLog(@"App: video Skipped.");
}

- (void)adFinishedPlayingCompleteVideo:(id<ANAdProtocol>)ad{
    NSLog(@"App: video finished playing.");
}

- (void)adFinishedQuartileEvent:(ANVideoEvent)videoEvent withAd:(id<ANAdProtocol>)ad{
    switch (videoEvent) {
        case ANVideoEventQuartileFirst:
            NSLog(@"App: First Quartile.");
            break;
        case ANVideoEventQuartileMidPoint:
            NSLog(@"App: MidPoint Quartile.");
            break;
        case ANVideoEventQuartileThird:
            NSLog(@"App: Third Quartile.");
            break;
        default:
            NSLog(@"App: Event not handled.");
            break;
    }
}

- (void)adWillLeaveApplication:(id<ANAdProtocol>)ad{
    NSLog(@"App: ad will leave application.");
}

@end