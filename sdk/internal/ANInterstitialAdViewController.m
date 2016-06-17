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

#import "ANInterstitialAdViewController.h"

#import "ANGlobal.h"
#import "ANLogging.h"
#import "UIView+ANCategory.h"
#import "UIWebView+ANCategory.h"
#import "ANMRAIDOrientationProperties.h"
#import "NSTimer+ANCategory.h"
#import "ANMRAIDContainerView.h"

@interface ANInterstitialAdViewController ()
@property (nonatomic, readwrite, strong) NSTimer *progressTimer;
@property (nonatomic, readwrite, strong) NSDate *timerStartDate;
@property (nonatomic, readwrite, assign) BOOL viewed;
@property (nonatomic, readwrite, assign) BOOL originalHiddenState;
@property (nonatomic, readwrite, assign) UIInterfaceOrientation orientation;
@property (nonatomic, readwrite, assign, getter=isDismissing) BOOL dismissing;
@property (nonatomic, readwrite, assign) BOOL responsiveAd;
@end

@implementation ANInterstitialAdViewController

- (instancetype)init {
    if (!ANPathForANResource(NSStringFromClass([self class]), @"nib")) {
        ANLogError(@"Could not instantiate interstitial controller because of missing NIB file");
        return nil;
    }
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:ANResourcesBundle()];
    self.originalHiddenState = NO;
    self.orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.backgroundColor) {
        self.backgroundColor = [UIColor whiteColor]; // Default white color, clear color background doesn't work with interstitial modal view
    }
    self.progressView.hidden = YES;
    self.closeButton.hidden = YES;
    if (self.contentView && !self.contentView.superview) {
        [self.view addSubview:self.contentView];
        [self.view insertSubview:self.contentView
                    belowSubview:self.progressView];
        [self.contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeCenterX
                                                 yAttribute:NSLayoutAttributeCenterY];
    }
    [self setupCloseButtonImageWithCustomClose:self.useCustomClose];
}

- (void)setupCloseButtonImageWithCustomClose:(BOOL)useCustomClose {
    if (useCustomClose) {
        [self.closeButton setImage:nil
                          forState:UIControlStateNormal];
        return;
    }
    BOOL atLeastiOS7 = [self respondsToSelector:@selector(modalPresentationCapturesStatusBarAppearance)];
    NSString *closeboxImageName = @"interstitial_flat_closebox";
    if (!atLeastiOS7) {
        closeboxImageName = @"interstitial_closebox";
    }
    UIImage *closeboxImage = [UIImage imageWithContentsOfFile:ANPathForANResource(closeboxImageName, @"png")];
    [self.closeButton setImage:closeboxImage
                      forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.originalHiddenState = [UIApplication sharedApplication].statusBarHidden;
    [self setStatusBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.viewed && ([self.delegate closeDelayForController] > 0.0)) {
        [self startCountdownTimer];
        self.viewed = YES;
    } else {
        [self stopCountdownTimer];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setStatusBarHidden:self.originalHiddenState];
    [self.progressTimer invalidate];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.dismissing = NO;
}

- (void)startCountdownTimer {
    self.progressView.hidden = NO;
    self.closeButton.hidden = YES;
    self.timerStartDate = [NSDate date];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progressTimerDidFire:) userInfo:nil repeats:YES];
}

- (void)stopCountdownTimer {
	[self.progressTimer invalidate];
    self.progressView.hidden = YES;
    self.closeButton.hidden = NO;
}

- (void)progressTimerDidFire:(NSTimer *)timer {
	NSDate *timeNow = [NSDate date];
	NSTimeInterval timeShown = [timeNow timeIntervalSinceDate:self.timerStartDate];
    NSTimeInterval closeDelay = [self.delegate closeDelayForController];
	[self.progressView setProgress:(timeShown / closeDelay)];
    
	if (timeShown >= closeDelay && self.closeButton.hidden == YES) {
        [self stopCountdownTimer];
	}
}

- (void)setContentView:(UIView *)contentView {
	if (contentView != _contentView) {
        if ([_contentView isKindOfClass:[UIWebView class]]) {
            UIWebView *webView = (UIWebView *)_contentView;
            [webView stopLoading];
            [webView setDelegate:nil];
        }
        
        [_contentView removeFromSuperview];
        _contentView = contentView;
        
        [self.view insertSubview:_contentView
                    belowSubview:self.progressView];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        if ([_contentView isKindOfClass:[ANMRAIDContainerView class]]) {
            if (((ANMRAIDContainerView *) _contentView).isResponsiveAd) {
                self.responsiveAd = YES;
            }
        }
        
        if (self.responsiveAd) {
            [_contentView an_constrainToSizeOfSuperview];
            [_contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeLeft
                                                 yAttribute:NSLayoutAttributeTop];
        } else {
            [_contentView an_constrainWithFrameSize];
            [_contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeCenterX
                                                 yAttribute:NSLayoutAttributeCenterY];
        }
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.view.backgroundColor = _backgroundColor;
}

- (IBAction)closeAction:(id)sender {
    if ([self.progressTimer an_isScheduled]) {
        return;
    }
    self.dismissing = YES;
	[self.delegate interstitialAdViewControllerShouldDismiss:self];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setStatusBarHidden:(BOOL)hidden {
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationNone];
}

- (BOOL)shouldAutorotate {
    return self.responsiveAd;
}

#if __IPHONE_9_0
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
#else
- (NSUInteger)supportedInterfaceOrientations {
#endif
    if (self.orientationProperties) {
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
    
    if (self.responsiveAd) {
        return UIInterfaceOrientationMaskAll;
    }

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

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.orientationProperties) {
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
            default:
                break;
        }
    }
    return self.orientation;
}

- (void)viewWillLayoutSubviews {
    CGFloat buttonDistanceToSuperview;
    if ([self respondsToSelector:@selector(modalPresentationCapturesStatusBarAppearance)]) {
        CGSize statusBarFrameSize = [[UIApplication sharedApplication] statusBarFrame].size;
        buttonDistanceToSuperview = statusBarFrameSize.height;
        if (statusBarFrameSize.height > statusBarFrameSize.width) {
            buttonDistanceToSuperview = statusBarFrameSize.width;
        }
    } else {
        buttonDistanceToSuperview = 0;
    }
    
    self.buttonTopToSuperviewConstraint.constant = buttonDistanceToSuperview;
    
    if (!self.isDismissing) {
        CGRect normalizedContentViewFrame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
        if (!CGRectContainsRect(self.view.frame, normalizedContentViewFrame)) {
            CGRect rotatedNormalizedContentViewFrame = CGRectMake(0, 0, CGRectGetHeight(self.contentView.frame), CGRectGetWidth(self.contentView.frame));
            if (CGRectContainsRect(self.view.frame, rotatedNormalizedContentViewFrame)) {
                [self.contentView an_constrainWithSize:CGSizeMake(CGRectGetHeight(self.contentView.frame), CGRectGetWidth(self.contentView.frame))];
            }
        }
    }
}

- (void)setUseCustomClose:(BOOL)useCustomClose {
    if (_useCustomClose != useCustomClose) {
        _useCustomClose = useCustomClose;
        [self setupCloseButtonImageWithCustomClose:useCustomClose];
    }
}

- (void)setOrientationProperties:(ANMRAIDOrientationProperties *)orientationProperties {
    _orientationProperties = orientationProperties;
    if ([self.view an_isViewable]) {
        if (orientationProperties.allowOrientationChange && orientationProperties.forceOrientation == ANMRAIDOrientationNone) {
            [UIViewController attemptRotationToDeviceOrientation];
        } else if ([UIApplication sharedApplication].statusBarOrientation != [self preferredInterfaceOrientationForPresentation]) {
            [self.delegate dismissAndPresentAgainForPreferredInterfaceOrientationChange];
        }
    }
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