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

#import "ANBrowserViewController.h"
#import "ANGlobal.h"

@interface ANBrowserViewController ()

@property (nonatomic, readwrite, strong) NSMutableURLRequest *urlRequest;
@property (nonatomic, readwrite, strong) UIActionSheet *openInSheet;

@end

@implementation ANBrowserViewController
@synthesize forwardButton = __forwardButton;
@synthesize backButton = __backButton;
@synthesize openInButton = __openInButton;
@synthesize doneButton = __doneButton;
@synthesize activityIndicatorView = __activityIndicatorView;
@synthesize webView = __webView;
@synthesize urlRequest = __urlRequest;
@synthesize openInSheet = __openInSheet;
@synthesize delegate = __delegate;

- (id)init
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self)
	{
		self.urlRequest = [[NSMutableURLRequest alloc] initWithURL:nil
                                                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                 timeoutInterval:kAppNexusRequestTimeoutInterval];
        [self.urlRequest setValue:ANUserAgent() forHTTPHeaderField:@"User-Agent"];
    }
    return self;
}

- (id)initWithURL:(NSURL *)url
{
	self = [self init];
	
	if (self != nil)
	{
		self.urlRequest.URL = url;
	}
	
	return self;
}

- (IBAction)closeAction:(id)sender
{
	[self.openInSheet dismissWithClickedButtonIndex:1 animated:NO];
	[self.delegate browserViewControllerShouldDismiss:self];
}

- (IBAction)forwardAction:(id)sender
{
	[self.webView goForward];
}

- (IBAction)backAction:(id)sender
{
	[self.webView goBack];
}

- (IBAction)openInAction:(id)sender
{
	self.openInSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Open In Browser", @"Title: Open in browser option") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Title: Cancel button") destructiveButtonTitle:nil otherButtonTitles:@"Open In External Browser", nil];
	
	[self.openInSheet showFromBarButtonItem:sender animated:YES];
}

- (void)viewDidLoad
{
	[self refreshButtons];
}

- (void)refreshButtons
{
	self.backButton.enabled = [self.webView canGoBack];
	self.forwardButton.enabled = [self.webView canGoForward];
}

- (void)viewDidAppear:(BOOL)animated
{
	[self.webView loadRequest:self.urlRequest];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[__webView stopLoading];
}

- (void)dealloc
{
	__webView.delegate = nil;
	[__webView stopLoading];
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[self refreshButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[self refreshButtons];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		NSURL *URL = self.webView.request.URL;
		
		if ([[UIApplication sharedApplication] canOpenURL:URL])
		{
			[[UIApplication sharedApplication] openURL:URL];
		}
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (actionSheet == self.openInSheet)
	{
		self.openInSheet = nil;
	}
}

@end
