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
@property (nonatomic, readwrite, strong) UIActionSheet *openInSheet;
@property (nonatomic, readwrite, assign) BOOL completedInitialLoad;
@property (nonatomic, readwrite, assign, getter=isLoading) BOOL loading;
@end

@implementation ANBrowserViewController

- (instancetype)initWithURL:(NSURL *)url {
    NSBundle *resBundle = ANResourcesBundle();
    if (!resBundle) {
        ANLogError(@"Resource not found. Make sure the AppNexusSDKResources bundle is included in project");
        return nil;
    }
    
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:ANResourcesBundle()];
    if (self) {
        _url = url;
        [self.view description]; // A call to self.view is needed for the webView to be created and the load to begin
    }
    
	return self;
}

+ (NSURLRequest *)requestForURL:(NSURL *)URL {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                            timeoutInterval:kAppNexusRequestTimeoutInterval];
    [request setValue:ANUserAgent() forHTTPHeaderField:@"User-Agent"];
    return [request copy];
}

+ (void)launchURL:(NSURL *)url withDelegate:(id<ANBrowserViewControllerDelegate>)delegate {
    ANBrowserViewController *controller = [[ANBrowserViewController alloc] initWithURL:url];
    controller.delegate = delegate;
    if ([controller.delegate respondsToSelector:@selector(browserViewControllerShouldPresent:)]) {
        [controller.delegate browserViewControllerShouldPresent:controller];
    }
}

- (IBAction)closeAction:(id)sender {
	[self.openInSheet dismissWithClickedButtonIndex:1 animated:NO];
    if ([self.delegate respondsToSelector:@selector(browserViewControllerShouldDismiss:)]) {
        [self.delegate browserViewControllerShouldDismiss:self];
    }
}

- (IBAction)forwardAction:(id)sender {
	[self.webView goForward];
}

- (IBAction)backAction:(id)sender {
	[self.webView goBack];
}

- (IBAction)openInAction:(id)sender {
	self.openInSheet = [[UIActionSheet alloc]
                        initWithTitle:NSLocalizedString(@"Open In Browser", @"Title: Open in browser option")
                        delegate:self
                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Title: Cancel button")
                        destructiveButtonTitle:nil
                        otherButtonTitles:@"Open In External Browser", nil];
	
	[self.openInSheet showFromBarButtonItem:sender animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self refreshButtons];
    [self.webView loadRequest:[[self class] requestForURL:self.url]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
}

- (void)refreshButtons {
	self.backButton.enabled = [self.webView canGoBack];
	self.forwardButton.enabled = [self.webView canGoForward];
}

- (void)setWebView:(UIWebView *)webView {
    _webView = webView;
    [webView setMediaProperties];
}

- (void)dealloc {
	self.webView.delegate = nil;
	[self.webView stopLoading];
}

- (void)setUrl:(NSURL *)url {
    if (![[url absoluteString] isEqualToString:[_url absoluteString]] || (!self.loading && !self.completedInitialLoad)) {
        _url = url;
        [self.webView stopLoading];
        self.completedInitialLoad = NO;
        [self.webView loadRequest:[[self class] requestForURL:url]];
    } else {
        ANLogWarn(@"In-app browser ignoring request to load - request is already loading");
    }
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    [self handleWebViewLoadingChange];
    NSURL *URL = [request URL];

    if (hasHttpPrefix([URL scheme])) {
        return YES;
    } else if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        if ([self.delegate respondsToSelector:@selector(browserViewControllerShouldDismiss:)]) {
            [self.delegate browserViewControllerShouldDismiss:self];
        }
        if ([self.delegate respondsToSelector:@selector(browserViewControllerWillLaunchExternalApplication)]) {
            [self.delegate browserViewControllerWillLaunchExternalApplication];
        }
        ANLogDebug(@"%@ | Opening URL in external application: %@", NSStringFromSelector(_cmd), URL);
        [webView stopLoading];
        [[UIApplication sharedApplication] openURL:URL];
        return NO;
    } else {
        ANLogWarn([NSString stringWithFormat:ANErrorString(@"opening_url_failed"), URL]);
        return NO;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self handleWebViewLoadingChange];
	[self refreshButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self handleWebViewLoadingChange];
    if (!self.completedInitialLoad) {
        self.completedInitialLoad = YES;
        if ([self.delegate respondsToSelector:@selector(browserViewControllerShouldPresent:)]) {
            [self.delegate browserViewControllerShouldPresent:self];
        }
    }
	[self refreshButtons];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self handleWebViewLoadingChange];
    [self refreshButtons];
    ANLogWarn(@"In-app browser failed with error: %@", error);
}

- (void)handleWebViewLoadingChange {
    BOOL oldValue = self.loading;
    self.loading = self.webView.loading;
    if (oldValue != self.loading && [self.delegate respondsToSelector:@selector(browserViewController:browserIsLoading:)]) {
        [self.delegate browserViewController:self
                            browserIsLoading:self.loading];
    }
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		NSURL *URL = self.webView.request.URL;
		
		if ([[UIApplication sharedApplication] canOpenURL:URL]) {
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

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (actionSheet == self.openInSheet) {
		self.openInSheet = nil;
	}
}

@end
