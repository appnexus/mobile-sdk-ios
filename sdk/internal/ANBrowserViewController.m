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
#import "ANStoreProductViewController.h"
#import <WebKit/WebKit.h>

#import "ANGlobal.h"
#import "ANLogging.h"
#import "UIWebView+ANCategory.h"
#import "UIView+ANCategory.h"
#import "ANOpenInExternalBrowserActivity.h"

#import "ANSDKSettings.h"

@interface ANBrowserViewController () <SKStoreProductViewControllerDelegate,
WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, readwrite, assign) BOOL completedInitialLoad;
@property (nonatomic, readwrite, assign, getter=isLoading) BOOL loading;

@property (nonatomic, readwrite, strong) WKWebView *modernWebView;
@property (nonatomic, readwrite, strong) UIWebView *legacyWebView;

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
        [self initializeWebView];
        NSURLRequest *request = ANBasicRequestWithURL(url);
        if (self.modernWebView) {
            [self.modernWebView loadRequest:request];
        } else {
            [self.legacyWebView loadRequest:request];
        }
    }
    return self;
}

- (void)initializeWebView {
    if ([WKWebView class]) {
        self.modernWebView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame
                                                configuration:[ANBrowserViewController defaultWebViewConfiguration]];
        self.modernWebView.navigationDelegate = self;
        self.modernWebView.UIDelegate = self;
    } else {
        self.legacyWebView = [[UIWebView alloc] init];
        self.legacyWebView.delegate = self;
        self.legacyWebView.scalesPageToFit = YES;
        [self.legacyWebView an_setMediaProperties];
    }
}

- (void)setUrl:(NSURL *)url {
    if (![[url absoluteString] isEqualToString:[_url absoluteString]] || (!self.loading && !self.completedInitialLoad)) {
        _url = url;
        [self resetBrowser];
        [self initializeWebView];
        if (self.modernWebView) {
            [self.modernWebView loadRequest:ANBasicRequestWithURL(url)];
        } else {
            [self.legacyWebView loadRequest:ANBasicRequestWithURL(url)];
        }
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
    self.legacyWebView.delegate = nil;
    self.modernWebView.navigationDelegate = nil;
    self.modernWebView.UIDelegate = nil;
    self.iTunesStoreController.delegate = nil;
}

- (void)resetBrowser {
    self.completedInitialLoad = NO;
    self.loading = NO;
    self.receivedInitialRequest = NO;
    self.legacyWebView = nil;
    self.modernWebView = nil;
}

- (void)stopLoading {
    if (self.modernWebView) {
        [self.modernWebView stopLoading];
    } else {
        [self.legacyWebView stopLoading];
    }
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
    if (self.modernWebView) {
        self.loading = self.modernWebView.loading;
    } else {
        self.loading = self.legacyWebView.loading;
    }
    [self loadingStateDidChangeFromOldValue:oldValue toNewValue:self.loading];
    [self refreshToolbarActivityIndicator];
    [self refreshButtons];
}

- (void)updateLoadingStateForFinishLoad {
    BOOL oldValue = self.loading;
    if (self.modernWebView) {
        self.loading = self.modernWebView.loading;
    } else {
        self.loading = self.legacyWebView.loading;
        if (self.loading) {
            NSString *readyState = [self.legacyWebView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
            if ([readyState isEqualToString:@"complete"]) {
                self.loading = NO;
            }
        }
    }
    [self loadingStateDidChangeFromOldValue:oldValue toNewValue:self.loading];
    [self refreshToolbarActivityIndicator];
    [self refreshButtons];
}

- (BOOL)shouldStartLoadWithRequest:(NSURLRequest *)request {
    NSURL *URL = [request URL];
    NSNumber *iTunesId = ANiTunesIDForURL(URL);
    BOOL shouldStartLoadWithRequest = NO;

    ANLogDebug(@"Opening URL: %@", URL);
    
    if (iTunesId) {
        if (self.modernWebView) {
            [self.modernWebView stopLoading];
        } else {
            [self.legacyWebView stopLoading];
        }
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
        if (self.modernWebView) {
            [self.modernWebView stopLoading];
        } else {
            [self.legacyWebView stopLoading];
        }
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

#pragma - User Interface

- (void)addWebViewToContainerView {
    UIView *contentView;
    if (self.modernWebView) {
        contentView = self.modernWebView;
    } else {
        contentView = self.legacyWebView;
    }
    [self.webViewContainerView addSubview:contentView];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView an_constrainToSizeOfSuperview];
    [contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeLeft
                                        yAttribute:NSLayoutAttributeTop];
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

- (void)refreshButtons {
    if (self.modernWebView) {
        self.backButton.enabled = self.modernWebView.canGoBack;
        self.forwardButton.enabled = self.modernWebView.canGoForward;
    } else {
        self.backButton.enabled = self.legacyWebView.canGoBack;
        self.forwardButton.enabled = self.legacyWebView.canGoForward;
    }
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

#pragma mark - User Actions

- (IBAction)closeAction:(id)sender {
    self.userDidDismiss = YES;
    [self rootViewControllerShouldDismissPresentedViewController];
}

- (IBAction)forwardAction:(id)sender {
    if (self.modernWebView) {
        [self.modernWebView goForward];
    } else {
        [self.legacyWebView goForward];
    }
}

- (IBAction)backAction:(id)sender {
    if (self.modernWebView) {
        [self.modernWebView goBack];
    } else {
        [self.legacyWebView goBack];
    }
}

- (IBAction)openInAction:(id)sender {
    NSURL *webViewURL;
    if (self.modernWebView) {
        webViewURL = self.modernWebView.URL;
    } else {
        webViewURL = self.legacyWebView.request.URL;
    }
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
    if (self.modernWebView) {
        [self.modernWebView reload];
    } else {
        [self.legacyWebView reload];
    }
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

#pragma mark - WKWebView

+ (WKWebViewConfiguration *)defaultWebViewConfiguration {
    static dispatch_once_t processPoolToken;
    static WKProcessPool *anSdkProcessPool;
    dispatch_once(&processPoolToken, ^{
        anSdkProcessPool = [[WKProcessPool alloc] init];
    });
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.processPool = anSdkProcessPool;
    configuration.allowsInlineMediaPlayback = YES;
    
    // configuration.allowsInlineMediaPlayback = YES is not respected
    // on iPhone on WebKit versions shipped with iOS 9 and below, the
    // video always loads in full-screen.
    // See: https://bugs.webkit.org/show_bug.cgi?id=147512
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)] &&
        [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){10,0,0}]) {
        configuration.mediaPlaybackRequiresUserAction = NO;
    } else {
        configuration.mediaPlaybackRequiresUserAction = YES;
    }
    
    return configuration;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    BOOL shouldStartLoadWithRequest = [self shouldStartLoadWithRequest:navigationAction.request];
    
    if (shouldStartLoadWithRequest) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    ANLogTrace(@"%@", NSStringFromSelector(_cmd));
    [self updateLoadingStateForStartLoad];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    ANLogTrace(@"%@ %@", NSStringFromSelector(_cmd), error);
    [self updateLoadingStateForFinishLoad];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    ANLogTrace(@"%@ %@", NSStringFromSelector(_cmd), error);
    if ([error.domain isEqualToString:NSURLErrorDomain] && (error.code == NSURLErrorSecureConnectionFailed || error.code == NSURLErrorAppTransportSecurityRequiresSecureConnection)) {
        NSURL *url = error.userInfo[NSURLErrorFailingURLErrorKey];
        ANLogError(@"In-app browser attempted to load URL which is not compliant with App Transport Security.\
                   Opening the URL in the native browser. URL: %@", url);
        [[UIApplication sharedApplication] openURL:url];
    }
    [self updateLoadingStateForFinishLoad];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    ANLogTrace(@"%@", NSStringFromSelector(_cmd));
    [self updateLoadingStateForFinishLoad];
    if (!self.completedInitialLoad) {
        self.completedInitialLoad = YES;
        if (!self.presented) {
            [self rootViewControllerShouldPresentBrowserViewController];
        }
    }
}

#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (navigationAction.targetFrame == nil) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
    }
    
    return nil;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return [self shouldStartLoadWithRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self updateLoadingStateForStartLoad];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    ANLogWarn(@"In-app browser received error: %@", error);
    [self updateLoadingStateForFinishLoad];
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

#pragma mark - SKStoreProductViewController

- (void)loadAndPresentStoreControllerWithiTunesId:(NSNumber *)iTunesId {
    if (iTunesId) {
        self.iTunesStoreController = [[ANStoreProductViewController alloc] init];
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