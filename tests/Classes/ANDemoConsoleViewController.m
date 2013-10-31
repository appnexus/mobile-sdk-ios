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

#import "ANDemoConsoleViewController.h"
#import "ANAdFetcher.h"
#import "ANAdResponse.h"
#import "ANGlobal.h"
#import "ANLogging.h"

@interface ANDemoConsoleViewController ()
- (void)adFetcherWillRequestAd:(NSNotification *)notification;
- (void)adFetcherDidReceiveResponse:(NSNotification *)notification;
@end

@implementation ANDemoConsoleViewController
@synthesize textView = __textView;

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.textView.font = [UIFont fontWithName:@"Courier" size:10];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adFetcherWillRequestAd:) name:kANAdFetcherWillRequestAdNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adFetcherDidReceiveResponse:) name:kANAdFetcherDidReceiveResponseNotification object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedANLogMessage:) name:kANLoggingNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)adFetcherWillRequestAd:(NSNotification *)notification
{
	NSURL *url = [[notification userInfo] objectForKey:kANAdFetcherAdRequestURLKey];
	self.textView.text = [self.textView.text stringByAppendingFormat:@"\n%@: Requesting ad from URL: %@\n", [NSDate date], url];
}

- (void)adFetcherDidReceiveResponse:(NSNotification *)notification
{
	id response = [[notification userInfo] objectForKey:kANAdFetcherAdResponseKey];
	self.textView.text = [self.textView.text stringByAppendingFormat:@"\n%@ Received response: %@\n", [NSDate date], response];
}

- (void)receivedANLogMessage:(NSNotification *)notification
{
//	id message = [[notification userInfo] objectForKey:kANLogMessageKey];
//	self.textView.text = [self.textView.text stringByAppendingFormat:@"\n%@ Received response: %@\n", [NSDate date], message];
}

- (IBAction)emailLogs:(id)sender
{
	if ([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
		controller.mailComposeDelegate = self;
		[controller setSubject:[NSString stringWithFormat:@"ANSDK Logs: %@", [NSDate date]]];
		[controller setMessageBody:self.textView.text isHTML:NO];
		[AppRootViewController() presentViewController:controller animated:YES completion:nil];
	}
	else
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device is not configured to send e-mail. Please configure an e-mail account and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
	[controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
