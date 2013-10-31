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
@end

@implementation ANInterstitialAdViewController
@synthesize contentView = __contentView;
@synthesize backgroundColor = __backgroundColor;

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	return self;
}

- (void)viewDidLoad
{
    if (!self.backgroundColor) {
        self.backgroundColor = [UIColor whiteColor]; // Default white color, clear color background doesn't work with interstitial modal view
    }
	self.progressView.hidden = YES;
//	self.closeButton.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	self.contentView.frame = CGRectMake((self.view.bounds.size.width - self.contentView.frame.size.width) / 2, (self.view.bounds.size.height - self.contentView.frame.size.height) / 2, self.contentView.frame.size.width, self.contentView.frame.size.height);
}

- (void)viewDidAppear:(BOOL)animated
{
	if (!self.viewed)
	{
		self.viewed = YES;
	}
}

- (void)startCountdownTimer
{
	self.progressView.hidden = NO;
	self.timerStartDate = [NSDate date];
	self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progressTimerDidFire:) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.progressTimer invalidate];
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
	
	if (timeShown >= [self.delegate interstitialAdViewControllerTimeToDismiss])
	{
		[timer invalidate];
		[self.delegate interstitialAdViewControllerShouldDismiss:self];
	}

	else
	{
		[self.progressView setProgress:timeShown / [self.delegate interstitialAdViewControllerTimeToDismiss] animated:NO];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	[UIView animateWithDuration:duration animations:^{
		self.contentView.frame = CGRectMake((self.view.bounds.size.width - self.contentView.frame.size.width) / 2, (self.view.bounds.size.height - self.contentView.frame.size.height) / 2, self.contentView.frame.size.width, self.contentView.frame.size.height);
	}];
}

- (void)setContentView:(UIView *)contentView
{
	if (contentView != __contentView)
	{
		if (contentView != nil)
		{
			if ([contentView isKindOfClass:[UIWebView class]])
			{
				[(UIWebView *)contentView removeDocumentPadding];
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

@end
