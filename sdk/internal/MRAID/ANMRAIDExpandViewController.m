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

#import "ANMRAIDExpandViewController.h"
#import "ANMRAIDExpandProperties.h"
#import "ANMRAIDOrientationProperties.h"
#import "ANGlobal.h"
#import "ANLogging.h"

#import "UIView+ANCategory.h"

@interface ANMRAIDExpandViewController ()

@property (nonatomic, readwrite, assign) BOOL originalStatusBarHiddenState;

@property (nonatomic, readwrite, strong) UIView *contentView;
@property (nonatomic, readwrite, strong) ANMRAIDExpandProperties *expandProperties;

@property (nonatomic, readwrite, weak) UIButton *closeButton;

@end

@implementation ANMRAIDExpandViewController

- (instancetype)initWithContentView:(UIView *)contentView
                   expandProperties:(ANMRAIDExpandProperties *)expandProperties {
    if (self = [super init]) {
        _contentView = contentView;
        _expandProperties = expandProperties;
        _orientationProperties = [[ANMRAIDOrientationProperties alloc] initWithAllowOrientationChange:YES
                                                                                     forceOrientation:ANMRAIDOrientationNone];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createCloseButton];
    [self attachContentView];
}

- (void)createCloseButton {
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [closeButton addTarget:self
                    action:@selector(closeButtonWasTapped)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    [closeButton an_constrainWithSize:CGSizeMake(kANMRAIDExpandViewControllerCloseRegionWidth, kANMRAIDExpandViewControllerCloseRegionHeight)];
    [closeButton an_alignToSuperviewWithXAttribute:NSLayoutAttributeRight
                                     yAttribute:NSLayoutAttributeTop];
    if (!self.expandProperties.useCustomClose) {
        BOOL atLeastiOS7 = [self respondsToSelector:@selector(modalPresentationCapturesStatusBarAppearance)];
        NSString *closeboxImageName = @"interstitial_flat_closebox";
        if (!atLeastiOS7) {
            closeboxImageName = @"interstitial_closebox";
        }
        UIImage *closeboxImage = [UIImage imageWithContentsOfFile:ANPathForANResource(closeboxImageName, @"png")];
        [closeButton setImage:closeboxImage
                     forState:UIControlStateNormal];
    }
    self.closeButton = closeButton;
}

- (void)closeButtonWasTapped {
    [self.delegate closeButtonWasTappedOnExpandViewController:self];
}

- (void)attachContentView {
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView removeConstraints:self.contentView.constraints];
    [self.contentView an_removeSizeConstraintToSuperview];
    [self.contentView an_removeAlignmentConstraintsToSuperview];
    
    [self.view insertSubview:self.contentView
                belowSubview:self.closeButton];
    if (self.expandProperties.width == -1 && self.expandProperties.height == -1) {
        [self.contentView an_constrainToSizeOfSuperview];
    } else {
        CGRect orientedScreenBounds = ANAdjustAbsoluteRectInWindowCoordinatesForOrientationGivenRect(ANPortraitScreenBounds());
        CGFloat expandedWidth = self.expandProperties.width;
        CGFloat expandedHeight = self.expandProperties.height;
        
        if (expandedWidth == -1) {
            expandedWidth = orientedScreenBounds.size.width;
        }
        if (expandedHeight == -1) {
            expandedHeight = orientedScreenBounds.size.height;
        }
        [self.contentView an_constrainWithSize:CGSizeMake(expandedWidth, expandedHeight)];
    }
    
    [self.contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeLeft
                                             yAttribute:NSLayoutAttributeTop];
}

- (UIView *)detachContentView {
    UIView *contentView = self.contentView;
    [contentView removeConstraints:contentView.constraints];
    [contentView an_removeSizeConstraintToSuperview];
    [contentView an_removeAlignmentConstraintsToSuperview];
    [contentView removeFromSuperview];
    self.contentView = nil;
    return contentView;
}

- (void)setOrientationProperties:(ANMRAIDOrientationProperties *)orientationProperties {
    _orientationProperties = orientationProperties;
    if ([self.view an_isViewable]) {
        if (orientationProperties.allowOrientationChange && orientationProperties.forceOrientation == ANMRAIDOrientationNone) {
            [UIViewController attemptRotationToDeviceOrientation];
        } else {
            [self.delegate dismissAndPresentAgainForPreferredInterfaceOrientationChange];
        }
    }
}

#if __IPHONE_9_0
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
#else
- (NSUInteger)supportedInterfaceOrientations {
#endif
    if (self.orientationProperties.allowOrientationChange) {
        return UIInterfaceOrientationMaskAll;
    } else {
        switch (self.orientationProperties.forceOrientation) {
            case ANMRAIDOrientationPortrait:
                return UIInterfaceOrientationMaskPortrait;
            case ANMRAIDOrientationLandscape:
                return UIInterfaceOrientationMaskLandscape;
            default:
                return UIInterfaceOrientationMaskAll;
        }
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    switch (self.orientationProperties.forceOrientation) {
        case ANMRAIDOrientationPortrait:
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown) {
                return UIInterfaceOrientationPortraitUpsideDown;
            }
            return UIInterfaceOrientationPortrait;
        case ANMRAIDOrientationLandscape:
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
                return UIInterfaceOrientationLandscapeRight;
            }
            return UIInterfaceOrientationLandscapeLeft;
        default: {
            UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
            return currentOrientation;
        }
    }   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        self.originalStatusBarHiddenState = [UIApplication sharedApplication].statusBarHidden;
        
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.orientationProperties.allowOrientationChange) {
        _orientationProperties = [[ANMRAIDOrientationProperties alloc] initWithAllowOrientationChange:YES
                                                                                     forceOrientation:ANMRAIDOrientationNone];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
   
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
    
// Allow WKWebView to present WKActionSheet
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if (self.presentedViewController) {
        [self.presentedViewController presentViewController:viewControllerToPresent
                                                   animated:flag
                                                 completion:completion];
    } else {
        [super presentViewController:viewControllerToPresent
                            animated:flag
                          completion:completion];
    }
}

@end
