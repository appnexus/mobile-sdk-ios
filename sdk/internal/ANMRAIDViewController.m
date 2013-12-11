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
@property (nonatomic, readwrite, assign) UIInterfaceOrientation orientation;
@property (nonatomic, readwrite, assign) BOOL originalHiddenState;
@end

@implementation ANMRAIDViewController

- (id)init {
    self = [super init];
    if (self) {
        self.orientation = [[UIApplication sharedApplication] statusBarOrientation];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.originalHiddenState = [UIApplication sharedApplication].statusBarHidden;
    [self setStatusBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setStatusBarHidden:self.originalHiddenState];
}

// locking orientation in iOS 6+
- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return self.orientation;
}

// locking orientation in pre-iOS 6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
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
