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
#import "ANLogging.h"
#import "UIWebView+ANCategory.h"

@interface ANBrowserViewController ()

@property (nonatomic, readwrite, strong) NSMutableURLRequest *urlRequest;
@property (nonatomic, readwrite, strong) UIActionSheet *openInSheet;
@property (nonatomic, readwrite, assign) BOOL isPresented;
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
    NSBundle *resBundle = ANResourcesBundle();
    if (!resBundle) {
        ANLogError(@"Resource not found. Make sure the AppNexusSDKResources bundle is included in project");
        return nil;
    }

    self = [super initWithNibName:NSStringFromClass([self class]) bundle:ANResourcesBundle()];
    if (self)
	{
		self.urlRequest = [[NSMutableURLRequest alloc] initWithURL:nil
                                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                   timeoutInterval:kAppNexusRequestTimeoutInterval];
        [self.urlRequest setValue:ANUserAgent() forHTTPHeaderField:@"User-Agent"];
    }
    
    self.isPresented = NO;
    [self.view description]; // A call to self.view (however trivial) is needed for our view to be created
    
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
    if ([self.delegate respondsToSelector:@selector(browserViewControllerShouldDismiss:)]) {
        [self.delegate browserViewControllerShouldDismiss:self];
    }
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
    [self.webView loadRequest:self.urlRequest];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!self.isPresented) {
        if ([self.delegate respondsToSelector:@selector(browserViewControllerWillNotPresent:)]) {
            [self.delegate browserViewControllerWillNotPresent:self];
        }
    }
    [__webView stopLoading];
}

- (void)refreshButtons
{
	self.backButton.enabled = [self.webView canGoBack];
	self.forwardButton.enabled = [self.webView canGoForward];
}

- (void)setWebView:(UIWebView *)webView {
    [webView setMediaProperties];
    __webView = webView;
}

- (void)dealloc
{
	__webView.delegate = nil;
	[__webView stopLoading];
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *URL = [request URL];
    if (!self.isPresented) ANLogDebug(@"%@ | Loading URL: %@", NSStringFromClass([self class]), URL);
    NSString *scheme = [URL scheme];
    BOOL schemeIsHttp = ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]);

    if (schemeIsHttp) {
        return YES;
    } else if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        if ([self.delegate respondsToSelector:@selector(browserViewControllerShouldDismiss:)]) {
            [self.delegate browserViewControllerShouldDismiss:self];
        }
        if ([self.delegate respondsToSelector:@selector(browserViewControllerWillLaunchExternalApplication)]) {
            [self.delegate browserViewControllerWillLaunchExternalApplication];
        }
        if (!self.isPresented) {
            ANLogDebug(@"%@ | Opening URL in external application: %@", NSStringFromClass([self class]), URL);
            if ([self.delegate respondsToSelector:@selector(browserViewControllerWillNotPresent:)]) {
                [self.delegate browserViewControllerWillNotPresent:self];
            }
        }
        [webView stopLoading];
        [[UIApplication sharedApplication] openURL:URL];
        return NO;
    } else {
        ANLogWarn([NSString stringWithFormat:ANErrorString(@"opening_url_failed"), URL]);
        return NO;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[self refreshButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[self refreshButtons];
    if (!self.isPresented) {
        if ([self.delegate respondsToSelector:@selector(browserViewControllerShouldPresent:)]) {
            [self.delegate browserViewControllerShouldPresent:self];
        }
        self.isPresented = YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    ANLogWarn(@"In-app browser failed with error: %@", error);
    if (!self.isPresented) {
        NSString *errorUrlString = [error.userInfo objectForKey:NSURLErrorFailingURLStringErrorKey];
        NSString *mainDocumentURL = [[webView.request mainDocumentURL] absoluteString];
        if (([errorUrlString isEqualToString:mainDocumentURL] || !mainDocumentURL) && ([error.domain isEqualToString:@"NSURLErrorDomain"] || [error.domain isEqualToString:@"WebKitErrorDomain"])) {
            if ([self.delegate respondsToSelector:@selector(browserViewControllerWillNotPresent:)]) {
                [self.delegate browserViewControllerWillNotPresent:self];
                [webView stopLoading];
            }
        }
    }
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		NSURL *URL = self.webView.request.URL;
		
		if ([[UIApplication sharedApplication] canOpenURL:URL])
		{
            if ([self.delegate respondsToSelector:@selector(browserViewControllerShouldDismiss:)]) {
                [self.delegate browserViewControllerShouldDismiss:self];
            }
            if ([self.delegate respondsToSelector:@selector(browserViewControllerWillLaunchExternalApplication)]) {
                [self.delegate browserViewControllerWillLaunchExternalApplication];
            }
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
