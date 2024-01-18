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
#import "ANWebView.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "UIView+ANCategory.h"
#import "ANOpenInExternalBrowserActivity.h"
#import <StoreKit/StoreKit.h>

#import "ANSDKSettings.h"

@interface ANBrowserViewController () <SKStoreProductViewControllerDelegate,
WKNavigationDelegate, WKUIDelegate>
@property (nonatomic, readwrite, assign) BOOL completedInitialLoad;
@property (nonatomic, readwrite, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) ANWebView *webView;

@property (nonatomic, readwrite, strong) UIBarButtonItem *refreshIndicatorItem;
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
    }
    return self;
}

    - (void)initializeWebView {
        _webView = [[ANWebView alloc] initWithSize:[UIScreen mainScreen].bounds.size URL:_url];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;

}

- (void)setUrl:(NSURL *)url {
    if (![[url absoluteString] isEqualToString:[_url absoluteString]] || (!self.loading && !self.completedInitialLoad)) {
        _url = url;
        [self resetBrowser];
        [self initializeWebView];
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
    self.webView.navigationDelegate = nil;
    self.webView.UIDelegate = nil;
    self.iTunesStoreController.delegate = nil;
}

- (void)resetBrowser {
    self.completedInitialLoad = NO;
    self.loading = NO;
    self.receivedInitialRequest = NO;
    self.webView = nil;
}

- (void)stopLoading {
    if(self.webView){
        [self.webView stopLoading];
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
    if(self.webView){
        self.loading = self.webView.loading;
    }
    [self loadingStateDidChangeFromOldValue:oldValue toNewValue:self.loading];
    [self refreshToolbarActivityIndicator];
    [self refreshButtons];
}

- (void)updateLoadingStateForFinishLoad {
    BOOL oldValue = self.loading;
    if(self.webView){
        self.loading = self.webView.loading;
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
        if(self.webView){
            [self.webView stopLoading];
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
        if(self.webView){
            [self.webView stopLoading];
        }
        [ANGlobal openURL:[URL absoluteString]];
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
        CGSize statusBarFrameSize = ANStatusBarFrame().size;
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
    if (self.webView) {
        contentView = self.webView;
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
        self.okButton.tintColor = nil;
    }

    if (ANSDKSettings.sharedInstance.sdkBrowserDismissTitle) {
        self.okButton.title = ANSDKSettings.sharedInstance.sdkBrowserDismissTitle;
    } else {
        // Setting OK button Localized String
        self.okButton.title = NSLocalizedString(@"OK", @"LabelForInAppBrowserReturnButton");
    }
}

- (void)refreshButtons {
    if (self.webView) {
        self.backButton.enabled = self.webView.canGoBack;
        self.forwardButton.enabled = self.webView.canGoForward;
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
        UIActivityIndicatorView *indicator;
        if (@available(iOS 13.0, *))
        {
            indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
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
    if (self.webView) {
        [self.webView goForward];
    }
}

- (IBAction)backAction:(id)sender {
    if (self.webView) {
        [self.webView goBack];
    }
}

- (IBAction)openInAction:(id)sender {
    NSURL *webViewURL;
    if (self.webView) {
        webViewURL = self.webView.URL;
    }
    if (webViewURL.absoluteString.length) {
        NSArray *appActivities = @[[[ANOpenInExternalBrowserActivity alloc] init]];
        UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[webViewURL]
                                                                            applicationActivities:appActivities];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            
            UIPopoverPresentationController *popController = [share popoverPresentationController];
            popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            popController.barButtonItem = self.openInButton;
            
            
        }
        [self presentViewController:share
                               animated:YES
                             completion:nil];
        
    }
}

- (IBAction)refresh:(id)sender {
    if (self.webView) {
        [self.webView reload];
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
    [controllerToPresent setModalPresentationStyle:UIModalPresentationFullScreen];
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
            configuration.mediaTypesRequiringUserActionForPlayback = NO;
    } else {
            configuration.mediaTypesRequiringUserActionForPlayback = YES;
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
        [ANGlobal openURL:[url absoluteString]];
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
        [ANGlobal openURL:[navigationAction.request.URL absoluteString]];
    }
    
    return nil;
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
