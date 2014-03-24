/*   Copyright 2013 APPNEXUS INC
 
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

#import "AdSettingsViewController.h"

@interface AdSettingsViewController ()

@end

@implementation AdSettingsViewController

- (IBAction)loadPreviewTVC:(id)sender {
    // passback to AppNexusSDKAppViewController
    [self.previewLoader forceLoadPreviewVCWithReset];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[AppNexusSDKAppModalViewController class]]) {
        AppNexusSDKAppModalViewController *help = (AppNexusSDKAppModalViewController *)[segue destinationViewController];
        help.orientation = [UIApplication sharedApplication].statusBarOrientation;
        [UIApplication sharedApplication].keyWindow.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        help.delegate = self;
    }
}

- (void)sdkAppModalViewControllerShouldDismiss:(AppNexusSDKAppModalViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^{
        [UIApplication sharedApplication].keyWindow.rootViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    }];
}

@end
