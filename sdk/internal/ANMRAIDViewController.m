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

#import "ANMRAIDViewController.h"

@interface ANMRAIDViewController ()
@property (nonatomic, readwrite, assign) BOOL originalHiddenState;
@property (nonatomic, readwrite, assign) CGSize originalSize;
@end

@implementation ANMRAIDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.originalSize = self.view.frame.size;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.originalHiddenState = [UIApplication sharedApplication].statusBarHidden;
    [self setStatusBarHidden:YES];

    [self resetViewForRotations:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setStatusBarHidden:self.originalHiddenState];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self resetViewForRotations:toInterfaceOrientation];
}

- (void)resetViewForRotations:(UIInterfaceOrientation)orientation {
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGFloat portraitHeight = mainBounds.size.height;
        CGFloat portraitWidth = mainBounds.size.width;
        mainBounds.size.height = portraitWidth;
        mainBounds.size.width = portraitHeight;
    }
    
    [self.contentView setFrame:mainBounds];
}

// hiding the status bar in iOS 7
- (BOOL)prefersStatusBarHidden {
    return YES;
}

// hiding the status bar pre-iOS 7
- (void)setStatusBarHidden:(BOOL)hidden {
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationNone];
}

@end
