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
@end

@implementation ANMRAIDViewController

- (id)init {
    self = [super init];
    if (self) {
        _allowOrientationChange = YES;
    }
    return self;
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
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self resetViewForRotations:toInterfaceOrientation];
}

- (void)resetViewForRotations:(UIInterfaceOrientation)orientation {
    if (!self.allowOrientationChange) {
        return;
    }
    
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGFloat portraitHeight = mainBounds.size.height;
        CGFloat portraitWidth = mainBounds.size.width;
        mainBounds.size.height = portraitWidth;
        mainBounds.size.width = portraitHeight;
    }
    
    [self.contentView setFrame:mainBounds];
}

// locking orientation in iOS 6+
- (BOOL)shouldAutorotate {
    return self.allowOrientationChange;
}

- (NSUInteger)supportedInterfaceOrientations {
    if (self.allowOrientationChange) {
        return [super supportedInterfaceOrientations];
    } else {
        switch (self.orientation) {
            case UIInterfaceOrientationPortrait:
                return UIInterfaceOrientationMaskPortrait;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                return UIInterfaceOrientationMaskPortraitUpsideDown;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                return UIInterfaceOrientationMaskLandscapeLeft;
                break;
            case UIInterfaceOrientationLandscapeRight:
                return UIInterfaceOrientationMaskLandscapeRight;
                break;
            default:
                return UIInterfaceOrientationMaskPortrait;
                break;
        }
    }
}

// locking orientation in pre-iOS 6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return self.allowOrientationChange;
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
