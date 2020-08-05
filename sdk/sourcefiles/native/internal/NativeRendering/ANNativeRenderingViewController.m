/*   Copyright 2018-2019 APPNEXUS INC
 
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

#import "ANNativeRenderingViewController.h"
#import "ANRTBNativeAdResponse.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANNativeAdResponse+PrivateMethods.h"
#import "UIView+ANCategory.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANBrowserViewController.h"
#import "ANAdViewInternalDelegate.h"
#import "ANClickOverlayView.h"
#import "ANWebView.h"

static NSString *const kANNativeResponseObject= @"AN_NATIVE_RENDERING_OBJECT";
static NSString *const kANNativeRenderingURL = @"AN_NATIVE_RENDERING_URL";
static NSString *const kANativeRenderingInvalidURL = @"invalidRenderingURL";
static NSString *const kANativeRenderingValidURL = @"validRenderingURL";

@interface ANNativeRenderingViewController()<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler , ANBrowserViewControllerDelegate>
@property (nonatomic, readwrite, strong)    ANWebView      *webView;

@property (nonatomic, readwrite, strong)    UIView      *contentView;
@property (nonatomic, readwrite) BOOL isAdLoaded;
@property (nonatomic, readwrite, assign)  BOOL  completedFirstLoad;
@property (nonatomic, readwrite, strong) ANBrowserViewController        *browserViewController;
@property (nonatomic, readwrite, strong) ANClickOverlayView *clickOverlay;


@end

@implementation ANNativeRenderingViewController

- (instancetype)initWithSize:(CGSize)size
                  BaseObject:(id)baseObject
{
    CGRect  initialRect  = CGRectMake(0, 0, size.width, size.height);
    self = [super initWithFrame:initialRect];
    if (!self)  { return nil; }
    self.backgroundColor = [UIColor clearColor];

    if([baseObject isKindOfClass:[ANRTBNativeAdResponse class]]) {
        [self setUpNativeRenderingContentWithSize:size BaseObject:baseObject];
    }
    return self;
}

- (void)setUpNativeRenderingContentWithSize:(CGSize)size
                                BaseObject:(id)baseObject
{
    
    
    ANRTBNativeAdResponse *baseAd = (ANRTBNativeAdResponse *)baseObject;
    
    NSURL     *nativeRenderingUrl   = [[[ANSDKSettings sharedInstance] baseUrlConfig] nativeRenderingUrl];
    NSString  *renderNativeAssetsHTML  = [NSString stringWithContentsOfURL: nativeRenderingUrl
                                                                  encoding: NSUTF8StringEncoding
                                                                     error: nil ];
    
    renderNativeAssetsHTML = [renderNativeAssetsHTML stringByReplacingOccurrencesOfString: kANNativeResponseObject
                                                                               withString: baseAd.nativeAdResponse.nativeRenderingObject];
    
    renderNativeAssetsHTML = [renderNativeAssetsHTML stringByReplacingOccurrencesOfString: kANNativeRenderingURL
                                                                               withString: baseAd.nativeAdResponse.nativeRenderingUrl];
    
    renderNativeAssetsHTML = [renderNativeAssetsHTML stringByReplacingOccurrencesOfString: kANativeRenderingValidURL withString: kANativeRenderingValidURL];
    
    renderNativeAssetsHTML = [renderNativeAssetsHTML stringByReplacingOccurrencesOfString: kANativeRenderingInvalidURL withString: kANativeRenderingInvalidURL];
    
     [self initANWebViewWithSize:size
                         HTML:renderNativeAssetsHTML];
}

- (void)initANWebViewWithSize:(CGSize)size
                        HTML:(NSString *)html
{
    NSURL  *base;
    
    if (!base) {
        base = [NSURL URLWithString:[[[ANSDKSettings sharedInstance] baseUrlConfig] webViewBaseUrl]];
    }
    
    _webView = [ANWebView fetchWebView];
    
    [_webView loadWithSize:size content:html baseURL:base];
    
    [self configureWebView];
}


-(void) configureWebView {

    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"rendererOp"];

    [self.webView setNavigationDelegate:self];
    [self.webView setUIDelegate:self];
    
    self.contentView = self.webView;
    
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self processWebViewDidFinishLoad];
}



- (void)                    webView: (WKWebView *)webView
    decidePolicyForNavigationAction: (WKNavigationAction *)navigationAction
                    decisionHandler: (void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *URL = navigationAction.request.URL;
    NSURL *mainDocumentURL = navigationAction.request.mainDocumentURL;
    NSString *URLScheme = URL.scheme;
    
    ANLogDebug(@"Loading URL: %@", [[URL absoluteString] stringByRemovingPercentEncoding]);
    
    if (self.completedFirstLoad) {
        if (ANHasHttpPrefix(URLScheme)) {
           
                if (([[mainDocumentURL absoluteString] isEqualToString:[URL absoluteString]]
                     || navigationAction.navigationType == WKNavigationTypeLinkActivated
                     || navigationAction.targetFrame == nil)) {
                    [self openDefaultBrowserWithURL:URL];
                    decisionHandler(WKNavigationActionPolicyCancel);
                    return;
                }
        }else {
                [self openDefaultBrowserWithURL:URL];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}



- (void)openDefaultBrowserWithURL:(NSURL *)URL
{
    if (!self.adViewDelegate) {
        ANLogDebug(@"Ignoring attempt to trigger browser on ad while not attached to a view.");
        return;
    }

    if (ANClickThroughActionReturnURL != [self.adViewDelegate clickThroughAction]) {
        [self.adViewDelegate adWasClicked];
    }
    
    switch ([self.adViewDelegate clickThroughAction])
    {
        case ANClickThroughActionReturnURL:
            [self.adViewDelegate adWasClickedWithURL:[URL absoluteString]];
            
            ANLogDebug(@"ClickThroughURL=%@", URL);
            break;
            
        case ANClickThroughActionOpenDeviceBrowser:
            if ([[UIApplication sharedApplication] canOpenURL:URL]) {
                [self.adViewDelegate adWillLeaveApplication];
                [ANGlobal openURL:[URL absoluteString]];
                
            } else {
                ANLogWarn(@"opening_url_failed %@", URL);
            }
            
            break;
            
        case ANClickThroughActionOpenSDKBrowser:
            [self openInAppBrowserWithURL:URL];
            break;
            
        default:
            ANLogError(@"UNKNOWN ANClickThroughAction.  (%lu)", (unsigned long)[self.adViewDelegate clickThroughAction]);
    }
}


- (void)openInAppBrowserWithURL:(NSURL *)URL {

    if (!self.browserViewController) {
        self.browserViewController = [[ANBrowserViewController alloc] initWithURL:URL
                                                                         delegate:self
                                                         delayPresentationForLoad:[self.adViewDelegate landingPageLoadsInBackground]];
        if (!self.browserViewController) {
            ANLogError(@"Browser controller did not instantiate correctly.");
            return;
        }
    } else {
        self.browserViewController.url = URL;
    }
}

-(void)setAdViewDelegate:(id<ANAdViewInternalDelegate>)adViewDelegate{
    _adViewDelegate = adViewDelegate;
}


#pragma mark - ANAdWebViewControllerLoadingDelegate

- (void)processWebViewDidFinishLoad
{
    if(!self.completedFirstLoad) {
        self.completedFirstLoad = YES;
    if (self.isAdLoaded && [self.loadingDelegate respondsToSelector:@selector(didCompleteFirstLoadFromNativeWebViewController:)])
    {
        // Attaching WKWebView to screen for an instant to allow it to fully load in the background
        //   before the call to [ANAdDelegate adDidReceiveAd:self].
        //
        
        __weak ANNativeRenderingViewController  *weakSelf  = self;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.15 * NSEC_PER_SEC), dispatch_get_main_queue(),
                       ^{
                           __strong ANNativeRenderingViewController  *strongSelf  = weakSelf;
                           if (!strongSelf)  {
                               ANLogError(@"COULD NOT ACQUIRE strongSelf.");
                               return;
                           }
                           
                           UIView  *contentView  = strongSelf.contentView;
                           
                           contentView.translatesAutoresizingMaskIntoConstraints = NO;
                           
                           [strongSelf addSubview:contentView];
                           strongSelf.contentView.hidden = NO;
                           
                           [contentView an_constrainToSizeOfSuperview];
                           [contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeLeft
                                                               yAttribute:NSLayoutAttributeTop];
                           
                           [strongSelf.loadingDelegate didCompleteFirstLoadFromNativeWebViewController:strongSelf];
                       });
        
        
    }else{
        [self.loadingDelegate didFailToLoadNativeWebViewController];
        }
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if (!message)  { return; }
    NSString        *eventName          = @"";
    if ([message.body isKindOfClass:[NSString class]])
    {
        eventName = (NSString *)message.body;
    }
    if (![eventName isEqualToString:kANativeRenderingInvalidURL]){
        self.isAdLoaded = YES;
    }else{
        self.isAdLoaded = NO;
    }
}

#pragma mark - ANBrowserViewControllerDelegate

- (UIViewController *)rootViewControllerForDisplayingBrowserViewController:(ANBrowserViewController *)controller
{
    return [self displayController];
}

- (void)didDismissBrowserViewController:(ANBrowserViewController *)controller
{
    self.browserViewController = nil;
 
}

- (void)willLeaveApplicationFromBrowserViewController:(ANBrowserViewController *)controller {
    [self.adViewDelegate adWillLeaveApplication];
}

#pragma mark - Helper methods.

- (UIViewController *)displayController {
    
    UIViewController *presentingVC = nil;
    
    presentingVC = [self.adViewDelegate displayController];
    
    if (ANCanPresentFromViewController(presentingVC)) {
        return presentingVC;
    }
    return nil;
}
- (void) willMoveToSuperview: (UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // UIView already added to superview.
    if (newSuperview != nil)  {
        return;
    }
    [self stopWebViewLoadForDealloc];
}

- (void)stopWebViewLoadForDealloc
{
    if (self.webView)
    {
        [self.webView stopLoading];
        
        [self.webView setNavigationDelegate:nil];
        [self.webView setUIDelegate:nil];
        
        [self.webView removeFromSuperview];
        self.webView = nil;
        
    }
    self.contentView = nil;
}


@end
