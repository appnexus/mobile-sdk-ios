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

#import "ANDemoAdsViewController.h"
#import "ANInterstitialAd.h"

NSString *ANDemoAdsViewControllerSavedSizeKey = @"ANDemoAdsViewControllerSavedSizeKey";
NSString *ANDemoAdsViewControllerSavedTagKey = @"ANDemoAdsViewControllerSavedTagKey";

@interface ANDemoAdsViewController () <ANInterstitialAdDelegate, ANBannerAdViewDelegate>

@property (nonatomic, readwrite, strong) ANInterstitialAd *interstitialAd;
@property (nonatomic, readwrite, strong) NSArray *sizesArray;
@property (nonatomic, readwrite, weak) UITextField *activeTextField;

@end

@implementation ANDemoAdsViewController
@synthesize sizeTextField = __sizeTextField;
@synthesize refreshTextField = __refreshTextField;
@synthesize tagTextField = __tagTextField;
@synthesize pickerInputView = __pickerInputView;
@synthesize pickerView = __pickerView;
@synthesize segmentedControl = __segmentedControl;
@synthesize interstitialAd = __interstitialAd;
@synthesize sizesArray = __sizesArray;

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillBeHidden:)
												 name:UIKeyboardWillHideNotification object:nil];
	
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
	
	CGFloat kbHeight = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? kbSize.height : kbSize.width - 44.0;
	
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbHeight, 0.0);
	self.scrollView.contentInset = contentInsets;
	self.scrollView.scrollIndicatorInsets = contentInsets;
	
	// If active text field is hidden by keyboard, scroll it so it's visible
	// Your application might not need or want this behavior.
	CGRect aRect = self.view.frame;
	aRect.size.height -= kbHeight;
	
	CGPoint activeTextFieldOrigin = [self.controlsView convertPoint:self.activeTextField.frame.origin toView:self.containerView];
	CGPoint activeTextFieldOriginInViewCoordinates = [self.controlsView convertPoint:self.activeTextField.frame.origin toView:self.view];
	
	if (!CGRectContainsPoint(aRect, activeTextFieldOriginInViewCoordinates))
	{
		CGPoint scrollPoint = CGPointMake(0.0, activeTextFieldOrigin.y - kbHeight + 44.0);
		[self.scrollView setContentOffset:scrollPoint animated:YES];
	}
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
	[UIView animateWithDuration:kAppNexusAnimationDuration animations:^{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
	self.scrollView.contentInset = contentInsets;
		self.scrollView.scrollIndicatorInsets = contentInsets;
	}];
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Do any additional setup after loading the view from its nib.
	self.sizesArray = [NSArray arrayWithObjects:
					   [NSValue valueWithCGSize:CGSizeMake(300, 50)],
					   [NSValue valueWithCGSize:CGSizeMake(320, 50)],
					   [NSValue valueWithCGSize:CGSizeMake(300, 250)],
					   [NSValue valueWithCGSize:CGSizeMake(728, 90)],
					   [NSValue valueWithCGSize:CGSizeMake(320, 480)], nil];
	
	CGSize size = [[self.sizesArray objectAtIndex:0] CGSizeValue];	
	self.sizeTextField.text = [self formattedSizeStringForSize:size];
	
	NSString *savedTag = [[NSUserDefaults standardUserDefaults] objectForKey:ANDemoAdsViewControllerSavedTagKey];
	
	if ([savedTag length] > 0)
	{
		self.tagTextField.text = savedTag;
	}
	
	[self registerForKeyboardNotifications];
}

- (void)viewWillLayoutSubviews
{
	[self refreshViewLayout];
}

- (void)refreshViewLayout
{
	CGRect frame = self.bannerAdView.frame;
	frame.origin.x = self.view.center.x - (frame.size.width / 2);
	self.bannerAdView.frame = frame;
	
	frame = self.controlsView.frame;
	frame.origin.y = self.bannerAdView.frame.size.height;
	self.controlsView.frame = frame;
	
	frame = self.containerView.frame;
	frame.size.height = self.bannerAdView.frame.size.height + self.controlsView.frame.size.height;
	self.containerView.frame = frame;
	
	self.scrollView.contentSize = self.containerView.frame.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pickerInputViewDone:(id)sender
{
	NSInteger selectedRowOfPicker = [self.pickerView selectedRowInComponent:0];
	NSString *selectedRowTitle = [self pickerView:self.pickerView titleForRow:selectedRowOfPicker forComponent:0];
	
	[self.sizeTextField setText:selectedRowTitle];
	
	[self.sizeTextField resignFirstResponder];
}

- (IBAction)loadAd:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:self.tagTextField.text forKey:ANDemoAdsViewControllerSavedTagKey];
	
	[self.sizeTextField resignFirstResponder];
	[self.refreshTextField resignFirstResponder];
	[self.tagTextField resignFirstResponder];
	
	// Load the ad
	
	// Decide which kind of ad we're loading, 0 for banner, 1 for interstitial
	NSInteger adKind = [self.segmentedControl selectedSegmentIndex];
	NSString *placementId = self.tagTextField.text;

	if (adKind == 0)
	{
		NSInteger selectedRowOfPicker = [self.pickerView selectedRowInComponent:0];
		CGSize requestedSize = [[self.sizesArray objectAtIndex:selectedRowOfPicker] CGSizeValue];
		CGRect frame = self.bannerAdView.frame;
		CGRect newFrame = CGRectMake(frame.origin.x - (requestedSize.width - frame.size.width) / 2, frame.origin.y, requestedSize.width, requestedSize.height);
		
		self.bannerAdView.frame = newFrame;
		self.bannerAdView.adSize = requestedSize;
		
		[self refreshViewLayout];
		
		self.bannerAdView.placementId = placementId;
		self.bannerAdView.delegate = self;
	}
	else if (adKind == 1)
	{
		self.interstitialAd.placementId = placementId;
		self.interstitialAd.delegate = self;
        // change background color here
        self.interstitialAd.backgroundColor = [UIColor redColor];
		[self.interstitialAd loadAd];
	}
}

- (IBAction)segementedControlDidChange:(id)sender
{
	// Only enable the size and refresh text fields for banner ads
	self.sizeTextField.enabled = ([sender selectedSegmentIndex] == 0);
	self.refreshTextField.enabled = ([sender selectedSegmentIndex] == 0);
}

- (ANInterstitialAd *)interstitialAd
{
	if (__interstitialAd == nil)
	{
		__interstitialAd = [[ANInterstitialAd alloc] init];
	}
	
	return __interstitialAd;
}

- (NSString *)formattedSizeStringForSize:(CGSize)size
{
	return [NSString stringWithFormat:@"%d x %d", (int)size.width, (int)size.height];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if (textField == self.sizeTextField)
	{
		textField.inputView = self.pickerInputView;
		
		return YES;
	}
	
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	self.activeTextField = nil;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	if (textField == self.refreshTextField)
	{
		NSString *textFieldTextFormatted = [NSString stringWithFormat:@"%d", [textField.text integerValue]];
		textField.text = textFieldTextFormatted;
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	return YES;
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	CGSize size = [[self.sizesArray objectAtIndex:row] CGSizeValue];
	
	return [self formattedSizeStringForSize:size];
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [self.sizesArray count];
}

#pragma mark ANAdDelegate

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad;
{
	if (ad == self.interstitialAd)
	{
		[self.interstitialAd displayAdFromViewController:self.parentViewController];
	}
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
	ANLogDebug(@"ad %@ failed to load with error %@", ad, error);
}

#pragma mark ANBannerAdViewDelegate

- (void)bannerAdView:(ANBannerAdView *)adView willResizeToFrame:(CGRect)frame
{
	[UIView beginAnimations:@"resizeAnimation" context:NULL];
}

- (void)bannerAdViewDidResize:(ANBannerAdView *)adView
{
	[self refreshViewLayout];
	[UIView commitAnimations];
}

#pragma mark ANInterstitialAdDelegate
- (void)adFailedToDisplay:(ANInterstitialAd *)ad {
    
}

- (void)adDidClose:(ANInterstitialAd *)ad
{
	self.interstitialAd = nil;
}


@end
