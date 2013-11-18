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
#import "UIWebView+ANCategory.h"
#import "ANGlobal.h"

@interface ANInterstitialAdViewController ()
@property (nonatomic, readwrite, strong) NSTimer *progressTimer;
@property (nonatomic, readwrite, strong) NSDate *timerStartDate;
@property (nonatomic, readwrite, assign) BOOL viewed;
@property (nonatomic, readwrite, assign) BOOL originalHiddenState;
@property (nonatomic, readwrite, assign) UIInterfaceOrientation orientation;
@end

@implementation ANInterstitialAdViewController
@synthesize contentView = __contentView;
@synthesize backgroundColor = __backgroundColor;

- (id)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    self.originalHiddenState = NO;
    self.orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return self;
}

- (void)viewDidLoad {
    if (!self.backgroundColor) {
        self.backgroundColor = [UIColor whiteColor]; // Default white color, clear color background doesn't work with interstitial modal view
    }
    self.progressView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.originalHiddenState = [UIApplication sharedApplication].statusBarHidden;
    [self setStatusBarHidden:YES];
    [self centerContentView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewed = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setStatusBarHidden:self.originalHiddenState];
    [self.progressTimer invalidate];
}

- (void)startCountdownTimer
{
	self.progressView.hidden = NO;
	self.timerStartDate = [NSDate date];
	self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progressTimerDidFire:) userInfo:nil repeats:YES];
}

- (void)stopCountdownTimer
{
	[self.progressTimer invalidate];
	[self.progressView setHidden:YES];
	[self.closeButton setHidden:NO];
}

- (void)progressTimerDidFire:(NSTimer *)timer
{
	NSDate *timeNow = [NSDate date];
	NSTimeInterval timeShown = [timeNow timeIntervalSinceDate:self.timerStartDate];
	
	if (timeShown >= kAppNexusDefaultInterstitialCloseButtonInterval && self.closeButton.hidden == YES)
	{
		self.closeButton.hidden = NO;
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	[UIView animateWithDuration:duration animations:^{
        [self centerContentView];
	}];
}

- (void)centerContentView {
    CGFloat contentWidth = self.contentView.frame.size.width;
    CGFloat contentHeight = self.contentView.frame.size.height;
    CGFloat centerX = (self.view.bounds.size.width - contentWidth) / 2;
    CGFloat centerY = (self.view.bounds.size.height - contentHeight) / 2;
    
	self.contentView.frame = CGRectMake(centerX, centerY, contentWidth, contentHeight);
}

- (void)setContentView:(UIView *)contentView
{
	if (contentView != __contentView)
	{
		if (contentView != nil)
		{
			if ([contentView isKindOfClass:[UIWebView class]])
			{
                UIWebView *webView = (UIWebView *)contentView;
				[webView removeDocumentPadding];
				[webView setMediaProperties];
			}
			
			[self.view insertSubview:contentView belowSubview:self.closeButton];
		}
		
		[__contentView removeFromSuperview];
		
		if ([__contentView isKindOfClass:[UIWebView class]])
		{
			UIWebView *webView = (UIWebView *)__contentView;
			[webView setDelegate:nil];
			[webView stopLoading];
		}
		
		__contentView = contentView;
	}
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    __backgroundColor = backgroundColor;
    self.view.backgroundColor = __backgroundColor;
}

- (IBAction)closeAction:(id)sender
{
	[self.delegate interstitialAdViewControllerShouldDismiss:self];
}

// hiding the status bar in iOS 7
- (BOOL)prefersStatusBarHidden {
    return YES;
}

// hiding the status bar pre-iOS 7
- (void)setStatusBarHidden:(BOOL)hidden {
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationNone];
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

@end

