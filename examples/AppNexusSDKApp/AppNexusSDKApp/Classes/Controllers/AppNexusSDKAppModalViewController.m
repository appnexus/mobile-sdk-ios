//
//  AdSettingsHelpViewController.m
//  AppNexusSDKApp
//
//  Created by Jose Cabal-Ugaz on 2/7/14.
//  Copyright (c) 2014 AppNexus. All rights reserved.
//

#import "AppNexusSDKAppModalViewController.h"

@interface AppNexusSDKAppModalViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation AppNexusSDKAppModalViewController

#define APPNEXUSSDKAPP_HELP_BACKGROUND_COLOR_RED 77.0f
#define APPNEXUSSDKAPP_HELP_BACKGROUND_COLOR_GREEN 83.0f
#define APPNEXUSSDKAPP_HELP_BACKGROUND_COLOR_BLUE 78.0f
#define APPNEXUSSDKAPP_HELP_BACKGROUND_COLOR_ALPHA 0.5f

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:APPNEXUSSDKAPP_HELP_BACKGROUND_COLOR_RED / 255.0f
                                                green:APPNEXUSSDKAPP_HELP_BACKGROUND_COLOR_GREEN / 255.0f
                                                 blue:APPNEXUSSDKAPP_HELP_BACKGROUND_COLOR_BLUE / 255.0f
                                                alpha:APPNEXUSSDKAPP_HELP_BACKGROUND_COLOR_ALPHA];
}

- (NSUInteger)supportedInterfaceOrientations {
    switch (self.orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            return UIInterfaceOrientationMaskLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return UIInterfaceOrientationMaskLandscapeRight;
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIInterfaceOrientationMaskPortraitUpsideDown;
        default:
            return UIInterfaceOrientationMaskPortrait;
    }
}

- (IBAction)closeHelp:(UIButton *)sender {
    [self.delegate sdkAppModalViewControllerShouldDismiss:self];
}

@end