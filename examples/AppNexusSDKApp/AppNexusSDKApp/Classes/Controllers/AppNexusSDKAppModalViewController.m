/*   Copyright 2014 APPNEXUS INC
 
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