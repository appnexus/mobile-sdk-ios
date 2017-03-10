//
//  AdViewController.m
//  SimpleVideo
//
//  Created by Punnaghai Puviarasu on 3/7/17.
//  Copyright © 2017 AppNexus. All rights reserved.
//

#import "AdViewController.h"


@interface AdViewController ()<ANInstreamVideoAdLoadDelegate, ANInstreamVideoAdPlayDelegate>

@end

@implementation AdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Modal View Presented");
    
    self.videoAd = [[ANInstreamVideoAd alloc] initWithPlacementId:@"9924001"];
    [self.videoAd loadAdWithDelegate:self];
    self.videoAd.opensInNativeBrowser = false;
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
}

-(BOOL) prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) adDidReceiveAd: (id<ANAdProtocol>)ad
{
    if(self.videoAd != nil){
        [self.videoAd playAdWithContainer:self.view withDelegate:self];
    }
}

- (void)                ad: (id<ANAdProtocol>)ad
    requestFailedWithError: (NSError *)error
{
    
}

//----------------------------- -o-
- (void) adCompletedFirstQuartile:(id<ANAdProtocol>)ad
{
    NSLog(@"adCompletedFirstQuartile");
}


//----------------------------- -o-
- (void) adCompletedMidQuartile:(id<ANAdProtocol>)ad
{
    NSLog(@"adCompletedMidQuartile");
}


//----------------------------- -o-
- (void) adCompletedThirdQuartile:(id<ANAdProtocol>)ad
{
    NSLog(@"adCompletedThirdQuartile");
}


//----------------------------- -o-
- (void) adWasClicked: (id<ANAdProtocol>)ad
{
    NSLog(@"adWasClicked");
}

//----------------------------- -o-
-(void) adMute: (id<ANAdProtocol>)ad
    withStatus: (BOOL)muteStatus
{
    NSLog(@"adMute");
    
}

-(void) adDidComplete:(id<ANAdProtocol>)ad withState:(ANInstreamVideoPlaybackStateType)state{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}


@end
