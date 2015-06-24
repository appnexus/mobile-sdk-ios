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
#import <StoreKit/StoreKit.h>

#import "ANGlobal.h"
#import "ANLogging.h"
#import "UIWebView+ANCategory.h"
#import "UIView+ANCategory.h"
#import "ANOpenInExternalBrowserActivity.h"

@interface ANBrowserViewController () <SKStoreProductViewControllerDelegate>
@property (nonatomic, readwrite, assign) BOOL completedInitialLoad;
@property (nonatomic, readwrite, assign, getter=isLoading) BOOL loading;
@property (nonatomic, readwrite, strong) UIWebView *webView;
@property (nonatomic, readwrite, strong) UIBarButtonItem *refreshIndicatorItem;
@property (nonatomic, readwrite, strong) UIPopoverController *activityPopover;
@property (nonatomic, readwrite, strong) SKStoreProductViewController *iTunesStoreController;

@property (nonatomic, readwrite, assign, getter=isPresented) BOOL presented;
@property (nonatomic, readwrite, assign, getter=isPresenting) BOOL presenting;
@property (nonatomic, readwrite, assign, getter=isDismissing) BOOL dismissing;
@property (nonatomic, readwrite, strong) NSOperation *postPresentingOperation;
@property (nonatomic, readwrite, strong) NSOperation *postDismissingOperation;

@property (nonatomic, readwrite, assign) BOOL userDidDismiss;
@property (nonatomic, readwrite, assign) BOOL receivedInitialRequest;

@end

@implementation ANBrowserViewController

- (instancetype)initWithURL:(NSURL *)url
                   delegate:(id<ANBrowserViewControllerDelegate>)delegate
   delayPresentationForLoad:(BOOL)shouldDelayPresentation {
    NSString *sizeClassesNib = @"ANBrowserViewController_SizeClasses";
    NSString *oldNib = @"ANBrowserViewController";
    NSString *nibName = sizeClassesNib;
    if (!ANPathForANResource(sizeClassesNib, @"nib")) {
        if (ANPathForANResource(oldNib, @"nib")) {
            nibName = oldNib;
        } else {
            ANLogError(@"Could not instantiate browser controller because of missing NIB file");
            return nil;
        }
    }
    self = [super initWithNibName:nibName
                           bundle:ANResourcesBundle()];
    if (self) {
        _url = url;
        _delegate = delegate;
        _delayPresentationForLoad = shouldDelayPresentation;
        [self.webView loadRequest:ANBasicRequestWithURL(url)];
    }
    return self;
}

- (void)setUrl:(NSURL *)url {
    if (![[url absoluteString] isEqualToString:[_url absoluteString]] || (!self.loading && !self.completedInitialLoad)) {
        _url = url;
        [self resetBrowser];
        [self.webView loadRequest:ANBasicRequestWithURL(url)];
    } else {
        ANLogWarn(@"In-app browser ignoring request to load - request is already loading");
    }
}

# pragma mark - Lifecycle callbacks

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshButtons];
    [self addWebViewToContainerView];
    [self setupToolbar];
}

- (void)dealloc {
    [self resetBrowser];
    self.webView.delegate = nil;
    self.iTunesStoreController.delegate = nil;
}

- (void)resetBrowser {
    self.completedInitialLoad = NO;
    self.loading = NO;
    self.receivedInitialRequest = NO;
    self.webView = nil;
}

- (void)setupToolbar {
    if (![self respondsToSelector:@selector(modalPresentationCapturesStatusBarAppearance)]) {
        UIImage *backArrow = [UIImage imageWithContentsOfFile:ANPathForANResource(@"UIButtonBarArrowLeft", @"png")];
        UIImage *forwardArrow = [UIImage imageWithContentsOfFile:ANPathForANResource(@"UIButtonBarArrowRight", @"png")];
        [self.backButton setImage:backArrow];
        [self.forwardButton setImage:forwardArrow];
        
        self.backButton.tintColor = [UIColor whiteColor];
        self.forwardButton.tintColor = [UIColor whiteColor];
        self.openInButton.tintColor = [UIColor whiteColor];
        self.refreshButton.tintColor = nil;
        self.doneButton.tintColor = nil;
    }
}

#pragma mark - Adjust for status bar

- (void)viewWillLayoutSubviews {
    CGFloat containerViewDistanceToTopOfSuperview;
    if ([self respondsToSelector:@selector(modalPresentationCapturesStatusBarAppearance)]) {
        CGSize statusBarFrameSize = [[UIApplication sharedApplication] statusBarFrame].size;
        containerViewDistanceToTopOfSuperview = statusBarFrameSize.height;
        if (statusBarFrameSize.height > statusBarFrameSize.width) {
            containerViewDistanceToTopOfSuperview = statusBarFrameSize.width;
        }
    } else {
        containerViewDistanceToTopOfSuperview = 0;
    }
    
    self.containerViewSuperviewTopConstraint.constant = containerViewDistanceToTopOfSuperview;
}

#pragma mark - User Actions

- (IBAction)closeAction:(id)sender {
    self.userDidDismiss = YES;
    [self rootViewControllerShouldDismissPresentedViewController];
}

- (IBAction)forwardAction:(id)sender {
    [self.webView goForward];
}

- (IBAction)backAction:(id)sender {
    [self.webView goBack];
}

- (IBAction)openInAction:(id)sender {
    NSURL *webViewURL = self.webView.request.URL;
    if (webViewURL.absoluteString.length) {
        NSArray *appActivities = @[[[ANOpenInExternalBrowserActivity alloc] init]];
        UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[webViewURL]
                                                                            applicationActivities:appActivities];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            self.activityPopover = [[UIPopoverController alloc] initWithContentViewController:share];
            [self.activityPopover presentPopoverFromBarButtonItem:self.openInButton
                                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                                         animated:YES];
        } else {
            [self presentViewController:share
                               animated:YES
                             completion:nil];
        }
    }
}

- (IBAction)refresh:(id)sender {
    [self.webView reload];
}

- (void)refreshButtons {
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

#pragma mark - Presentation Methods

- (void)rootViewControllerShouldPresentBrowserViewController {
    [self rootViewControllerShouldPresentViewController:self];
}

- (void)rootViewControllerShouldPresentStoreViewController {
    [self rootViewControllerShouldPresentViewController:self.iTunesStoreController];
}

- (void)rootViewControllerShouldPresentViewController:(UIViewController *)controllerToPresent {
    if (self.isPresenting || self.isPresented || self.userDidDismiss) {
        return;
    }
    if (self.isDismissing) {
        ANLogDebug(@"In-app browser dismissal in progress - will present after dismiss");
        __weak ANBrowserViewController *weakSelf = self;
        self.postDismissingOperation = [NSBlockOperation blockOperationWithBlock:^{
            ANBrowserViewController *strongSelf = weakSelf;
            [strongSelf rootViewControllerShouldPresentViewController:controllerToPresent];
        }];
        return;
    }
    
    UIViewController *rvc = [self.delegate rootViewControllerForDisplayingBrowserViewController:self];
    if (!ANCanPresentFromViewController(rvc)) {
        ANLogDebug(@"No root view controller provided, or root view controller view not attached to window - could not present in-app browser");
        return;
    }

    self.presenting = YES;
    if ([self.delegate respondsToSelector:@selector(willPresentBrowserViewController:)]) {
        [self.delegate willPresentBrowserViewController:self];
    }
    __weak ANBrowserViewController *weakSelf = self;
    [rvc presentViewController:controllerToPresent animated:YES completion:^{
        ANBrowserViewController *strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(didPresentBrowserViewController:)]) {
            [strongSelf.delegate didPresentBrowserViewController:strongSelf];
        }
        strongSelf.presenting = NO;
        strongSelf.presented = YES;
    }];
}

- (void)rootViewControllerShouldDismissPresentedViewController {
    if (self.isDismissing || (!self.isPresented && !self.isPresenting)) {
        return;
    }
    if (self.isPresenting) {
        ANLogDebug(@"In-app browser presentation in progress - will dismiss after present");
        __weak ANBrowserViewController *weakSelf = self;
        self.postPresentingOperation = [NSBlockOperation blockOperationWithBlock:^{
            ANBrowserViewController *strongSelf = weakSelf;
            [strongSelf rootViewControllerShouldDismissPresentedViewController];
        }];
        return;
    }
    
    UIViewController *controllerForDismissingModalView = self.iTunesStoreController.presentingViewController;
    if (self.presentingViewController) {
        controllerForDismissingModalView = self.presentingViewController;
    }
    
    if (self.activityPopover.popoverVisible) {
        [self.activityPopover dismissPopoverAnimated:NO];
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    self.dismissing = YES;
    if ([self.delegate respondsToSelector:@selector(willDismissBrowserViewController:)]) {
        [self.delegate willDismissBrowserViewController:self];
    }
    __weak ANBrowserViewController *weakSelf = self;
    [controllerForDismissingModalView dismissViewControllerAnimated:YES completion:^{
        ANBrowserViewController *strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(didDismissBrowserViewController:)]) {
            [strongSelf.delegate didDismissBrowserViewController:strongSelf];
        }
        strongSelf.dismissing = NO;
        strongSelf.presented = NO;
    }];
}

- (void)setPresenting:(BOOL)presenting {
    _presenting = presenting;
    if (!_presenting && self.postPresentingOperation) {
        [[NSOperationQueue mainQueue] addOperation:self.postPresentingOperation];
        self.postPresentingOperation = nil;
    }
}

- (void)setDismissing:(BOOL)dismissing {
    _dismissing = dismissing;
    if (!_dismissing && self.postDismissingOperation) {
        [[NSOperationQueue mainQueue] addOperation:self.postDismissingOperation];
        self.postDismissingOperation = nil;
    }
}

#pragma mark - UIWebViewDelegate

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        [_webView an_setMediaProperties];
    }
    return _webView;
}

- (void)addWebViewToContainerView {
    [self.webViewContainerView addSubview:self.webView];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.webView an_constrainToSizeOfSuperview];
    [self.webView an_alignToSuperviewWithXAttribute:NSLayoutAttributeLeft
                                         yAttribute:NSLayoutAttributeTop];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *URL = [request URL];
    NSNumber *iTunesId = ANiTunesIDForURL(URL);
    BOOL shouldStartLoadWithRequest = NO;
    
    if (iTunesId) {
        [webView stopLoading];
        [self loadAndPresentStoreControllerWithiTunesId:iTunesId];
    } else if (ANHasHttpPrefix([URL scheme])) {
        if (!self.presented && !self.presenting && !self.delayPresentationForLoad) {
            [self rootViewControllerShouldPresentBrowserViewController];
        }
        shouldStartLoadWithRequest = YES;
    } else if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        if (!self.completedInitialLoad) {
            [self rootViewControllerShouldDismissPresentedViewController];
        }
        if ([self.delegate respondsToSelector:@selector(willLeaveApplicationFromBrowserViewController:)]) {
            [self.delegate willLeaveApplicationFromBrowserViewController:self];
        }
        ANLogDebug(@"%@ | Opening URL in external application: %@", NSStringFromSelector(_cmd), URL);
        [webView stopLoading];
        [[UIApplication sharedApplication] openURL:URL];
    } else {
        ANLogWarn(@"opening_url_failed %@", URL);
        if (!self.receivedInitialRequest) {
            if ([self.delegate respondsToSelector:@selector(browserViewController:couldNotHandleInitialURL:)]) {
                [self.delegate browserViewController:self couldNotHandleInitialURL:URL];
            }
        }
    }
    
    if (shouldStartLoadWithRequest) {
        [self updateLoadingStateForStartLoad];
    }
    
    self.receivedInitialRequest = YES;
    
    return shouldStartLoadWithRequest;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self updateLoadingStateForStartLoad];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self updateLoadingStateForFinishLoad];
    if (!self.completedInitialLoad) {
        self.completedInitialLoad = YES;
        if (!self.presented) {
            [self rootViewControllerShouldPresentBrowserViewController];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    ANLogWarn(@"In-app browser received error: %@", error);
    [self updateLoadingStateForFinishLoad];
}

- (void)loadingStateDidChangeFromOldValue:(BOOL)oldValue toNewValue:(BOOL)newValue {
    if (oldValue != newValue) {
        if ([self.delegate respondsToSelector:@selector(browserViewController:browserIsLoading:)]) {
            [self.delegate browserViewController:self
                                browserIsLoading:newValue];
        }
    }
}

- (void)updateLoadingStateForStartLoad {
    BOOL oldValue = self.loading;
    self.loading = self.webView.loading;
    [self loadingStateDidChangeFromOldValue:oldValue toNewValue:self.loading];
    [self refreshToolbarActivityIndicator];
    [self refreshButtons];
}

- (void)updateLoadingStateForFinishLoad {
    BOOL oldValue = self.loading;
    self.loading = self.webView.loading;
    if (self.loading) {
        NSString *readyState = [self.webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
        if ([readyState isEqualToString:@"complete"]) {
            self.loading = NO;
        }
    }
    [self loadingStateDidChangeFromOldValue:oldValue toNewValue:self.loading];
    [self refreshToolbarActivityIndicator];
    [self refreshButtons];
}

- (void)refreshToolbarActivityIndicator {
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    NSUInteger refreshItemIndex = [toolbarItems indexOfObject:self.refreshButton];
    if (refreshItemIndex == NSNotFound) {
        refreshItemIndex = [toolbarItems indexOfObject:self.refreshIndicatorItem];
    }
    if (refreshItemIndex != NSNotFound) {
        if (self.loading) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            toolbarItems[refreshItemIndex] = self.refreshIndicatorItem;
        } else {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            toolbarItems[refreshItemIndex] = self.refreshButton;
        }
        [self.toolbar setItems:[toolbarItems copy] animated:NO];
    }
}

- (UIBarButtonItem *)refreshIndicatorItem {
    if (!_refreshIndicatorItem) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicator startAnimating];
        _refreshIndicatorItem = [[UIBarButtonItem alloc] initWithCustomView:indicator];
    }
    return _refreshIndicatorItem;
}

- (void)stopLoading {
    [self.webView stopLoading];
    [self updateLoadingStateForFinishLoad];
}

#pragma mark - SKStoreProductViewController

- (void)loadAndPresentStoreControllerWithiTunesId:(NSNumber *)iTunesId {
    if (iTunesId) {
        self.iTunesStoreController = [[SKStoreProductViewController alloc] init];
        self.iTunesStoreController.delegate = self;
        [self.iTunesStoreController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:iTunesId}
                                              completionBlock:nil];
        if (self.isPresenting) {
            self.postPresentingOperation = [NSBlockOperation blockOperationWithBlock:^{
                [self presentStoreViewController];
            }];
            return;
        } else if (self.isDismissing) {
            self.postDismissingOperation = [NSBlockOperation blockOperationWithBlock:^{
                [self presentStoreViewController];
            }];
            return;
        }
        [self presentStoreViewController];
    }
}

- (void)presentStoreViewController {
    if (self.isPresented) {
        [self presentViewController:self.iTunesStoreController
                           animated:YES
                         completion:nil];
    } else {
        [self rootViewControllerShouldPresentStoreViewController];
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    self.userDidDismiss = YES;
    [self rootViewControllerShouldDismissPresentedViewController];
}

@end