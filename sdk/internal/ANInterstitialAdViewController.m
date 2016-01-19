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
#import "ANCircularAnimationView.h"
#import "ANNativeImpressionTrackerManager.h"

@interface ANInterstitialAdViewController ()<ANCircularAnimationViewDelegate>
@property (nonatomic, readwrite, strong) NSTimer *progressTimer;
@property (nonatomic, readwrite, strong) NSDate *timerStartDate;
@property (nonatomic, readwrite, assign) BOOL viewed;
@property (nonatomic, readwrite, assign) BOOL originalHiddenState;
@property (nonatomic, readwrite, assign) UIInterfaceOrientation orientation;
@property (nonatomic, readwrite, assign, getter=isDismissing) BOOL dismissing;
@property (nonatomic, strong) ANCircularAnimationView *circularAnimationView;

@property (nonatomic, readwrite, assign) NSUInteger viewabilityValue;
@property (nonatomic, readwrite, assign) NSUInteger targetViewabilityValue;
@property (nonatomic, readwrite, strong) NSTimer *viewabilityTimer;
@property (nonatomic, readwrite, assign) BOOL impressionHasBeenTracked;

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
        self.backgroundColor = [UIColor blackColor];
    }
    if (self.contentView && !self.contentView.superview) {
        [self.view addSubview:self.contentView];
        [self.contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeCenterX
                                                 yAttribute:NSLayoutAttributeCenterY];
    }
    [self setupCloseButtonImageWithCustomClose:self.useCustomClose];
}

- (void)setupCircularView {
    CGSize closeButtonSize = APPNEXUS_INTERSTITIAL_CLOSE_BUTTON_VIEW_SIZE;
    [self.circularAnimationView removeFromSuperview];
    self.circularAnimationView = [[ANCircularAnimationView alloc] initWithFrame:CGRectMake(0, 0, closeButtonSize.width, closeButtonSize.height)];
    self.circularAnimationView.delegate = self;
    self.circularAnimationView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.circularAnimationView];
    [self.view bringSubviewToFront:self.circularAnimationView];
    [self.circularAnimationView an_constrainWithSize:closeButtonSize];
    [self.circularAnimationView an_alignToSuperviewWithXAttribute:NSLayoutAttributeRight
                                                       yAttribute:NSLayoutAttributeTop
                                                          offsetX:-17.0
                                                          offsetY:17.0];
    float skipOffSet = [self.delegate closeDelayForController];
    self.circularAnimationView.skipOffset = skipOffSet;
}

- (void)setupCloseButtonImageWithCustomClose:(BOOL)useCustomClose {
    if (useCustomClose) {
        // MRAID custom close
        self.closeButton.hidden = NO;
        [self.circularAnimationView removeFromSuperview];
    } else {
        self.closeButton.hidden = YES;
        [self setupCircularView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.originalHiddenState = [UIApplication sharedApplication].statusBarHidden;
    [self setStatusBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.viewed) {
        [self setupViewabilityTracker];
    }
    if (!self.viewed && ([self.delegate closeDelayForController] > 0.0)) {
        [self startCountdownTimer];
    } else {
        [self stopCountdownTimer];
    }
    self.viewed = YES;
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
    self.timerStartDate = [NSDate date];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progressTimerDidFire:) userInfo:nil repeats:YES];
}

- (void)stopCountdownTimer {
	[self.progressTimer invalidate];
}

- (void)progressTimerDidFire:(NSTimer *)timer {
    [self.circularAnimationView performCircularAnimationWithStartTime:[NSDate date]];
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

        [self.view addSubview:_contentView];
        [self.view insertSubview:_contentView
                    belowSubview:self.circularAnimationView];
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [_contentView an_constrainWithFrameSize];
        [_contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeCenterX
                                             yAttribute:NSLayoutAttributeCenterY];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.view.backgroundColor = _backgroundColor;
}

- (IBAction)closeAction:(id)sender {
    // This method is intended to fire only for MRAID custom close
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
    return NO;
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
    
#pragma ANCircularAnimationView Delegates
- (void)stopTimerForHTMLInterstitial{
    [self stopCountdownTimer];
}
    
- (void)closeButtonClicked{
    if ([self.progressTimer an_isScheduled]) {
        return;
    }
    self.dismissing = YES;
    [self.delegate interstitialAdViewControllerShouldDismiss:self];
}
    
#pragma mark - Impression Tracking

- (void)setupViewabilityTracker {
    __weak ANInterstitialAdViewController *weakSelf = self;
    NSInteger requiredAmountOfSimultaneousViewableEvents = lround(kAppNexusNativeAdIABShouldBeViewableForTrackingDuration
                                                                  / kAppNexusNativeAdCheckViewabilityForTrackingFrequency) + 1;
    self.targetViewabilityValue = lround(pow(2, requiredAmountOfSimultaneousViewableEvents) - 1);
    self.viewabilityTimer = [NSTimer an_scheduledTimerWithTimeInterval:kAppNexusNativeAdCheckViewabilityForTrackingFrequency
                                                                 block:^ {
                                                                     ANInterstitialAdViewController *strongSelf = weakSelf;
                                                                     [strongSelf checkViewability];
                                                                 }
                                                               repeats:YES];
}

- (void)checkViewability {
    self.viewabilityValue = (self.viewabilityValue << 1 | [self.view an_isAtLeastHalfViewable]) & self.targetViewabilityValue;
    BOOL isIABViewable = (self.viewabilityValue == self.targetViewabilityValue);
    if (isIABViewable) {
        [self trackImpression];
    }
}

- (void)trackImpression {
    if (!self.impressionHasBeenTracked) {
        ANLogDebug(@"Firing impression trackers");
        [self fireImpTrackers];
        [self.viewabilityTimer invalidate];
        self.impressionHasBeenTracked = YES;
    }
}

- (void)fireImpTrackers {
    if (self.impressionUrls) {
        NSMutableArray *impressionURLArray = [[NSMutableArray alloc] init];
        [self.impressionUrls enumerateObjectsUsingBlock:^(NSString *urlString, NSUInteger idx, BOOL *stop) {
            NSURL *URL = [NSURL URLWithString:urlString];
            if (URL) {
                [impressionURLArray addObject:URL];
            }
        }];
        [ANNativeImpressionTrackerManager fireImpressionTrackerURLArray:impressionURLArray];
    }
}

@end