/*   Copyright 2014 APPNEXUS INC
 
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

#define kANAdWebViewControllerWebKitEnabled 1

#if kANAdWebViewControllerWebKitEnabled
#import <WebKit/WebKit.h>
#endif 

#import "ANAdWebViewController.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANMRAIDJavascriptUtil.h"
#import "ANMRAIDOrientationProperties.h"
#import "ANMRAIDExpandProperties.h"
#import "ANMRAIDResizeProperties.h"
#import "ANAdViewInternalDelegate.h"

#import "NSString+ANCategory.h"
#import "NSTimer+ANCategory.h"
#import "UIWebView+ANCategory.h"
#import "UIView+ANCategory.h"

#import "ANSDKSettings+PrivateMethods.h"
#import "ANAdConstants.h"



NSString *const kANWebViewControllerMraidJSFilename = @"mraid.js";



#if kANAdWebViewControllerWebKitEnabled
@interface ANAdWebViewController () <UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>
#else
@interface ANAdWebViewController () <UIWebViewDelegate>
#endif

@property (nonatomic, readwrite, strong)    UIView      *contentView;
@property (nonatomic, readwrite, weak)      UIWebView   *legacyWebView;

#if kANAdWebViewControllerWebKitEnabled
@property (nonatomic, readwrite, weak)      WKWebView   *modernWebView;
#endif

@property (nonatomic, readwrite, assign)  BOOL  isMRAID;
@property (nonatomic, readwrite, assign)  BOOL  completedFirstLoad;

@property (nonatomic, readwrite, strong)                        NSTimer     *viewabilityTimer;
@property (nonatomic, readwrite, assign, getter=isViewable)     BOOL         viewable;

@property (nonatomic, readwrite, assign)  CGRect  defaultPosition;
@property (nonatomic, readwrite, assign)  CGRect  currentPosition;
@property (nonatomic, readwrite, assign)  CGFloat  lastKnownExposedPercentage;
@property (nonatomic, readwrite, assign)  CGRect  lastKnownVisibleRect;

@property (nonatomic, readwrite, assign)  BOOL  rapidTimerSet;

@property (nonatomic, readwrite, strong)  ANAdWebViewControllerConfiguration  *configuration;

@property (nonatomic, readwrite, assign)  NSRunLoopMode  checkViewableRunLoopMode;

@property (nonatomic, readwrite, strong)  NSString  *videoXML;
@property (nonatomic, readwrite)          BOOL       appIsInBackground;

@end




@implementation ANAdWebViewController

- (instancetype)initWithConfiguration:(ANAdWebViewControllerConfiguration *)configuration
{
    if (self = [super init])
    {
        if (configuration) {
            _configuration = [configuration copy];
        } else {
            _configuration = [[ANAdWebViewControllerConfiguration alloc] init];
        }

        _checkViewableTimeInterval = kAppNexusMRAIDCheckViewableFrequency;
        _checkViewableRunLoopMode = NSDefaultRunLoopMode;

        _appIsInBackground = NO;
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)size
                         URL:(NSURL *)URL
              webViewBaseURL:(NSURL *)baseURL
{
    self = [self initWithSize:size
                          URL:URL
               webViewBaseURL:baseURL
                configuration:nil];
    return self;

}

- (instancetype)initWithSize:(CGSize)size
                         URL:(NSURL *)URL
              webViewBaseURL:(NSURL *)baseURL
               configuration:(ANAdWebViewControllerConfiguration *)configuration
{
    self = [self initWithConfiguration:configuration];
    if (!self)  { return nil; }

    //
#if kANAdWebViewControllerWebKitEnabled
    if ([WKWebView class])
    {
        [self loadModernWebViewWithSize: size
                                    URL: URL
                                baseURL: baseURL];
    } else
#endif
    {
        [self loadLegacyWebViewWithSize: size
                                    URL: URL
                                baseURL: baseURL];
    }

    //
    return self;
}

- (instancetype)initWithSize:(CGSize)size
                        HTML:(NSString *)html
              webViewBaseURL:(NSURL *)baseURL
{
    self = [self initWithSize:size
                         HTML:html
               webViewBaseURL:baseURL
                configuration:nil];
    return self;
}

- (instancetype)initWithSize:(CGSize)size
                        HTML:(NSString *)html
              webViewBaseURL:(NSURL *)baseURL
               configuration:(ANAdWebViewControllerConfiguration *)configuration
{
    self = [self initWithConfiguration:configuration];
    if (!self)  { return nil; }

    //
    NSRange      mraidJSRange   = [html rangeOfString:kANWebViewControllerMraidJSFilename];
    NSURL       *base           = baseURL;

    _isMRAID = (mraidJSRange.location != NSNotFound);

    if (!base) {
        base = [NSURL URLWithString:[[[ANSDKSettings sharedInstance] baseUrlConfig] webViewBaseUrl]];
    }


#if kANAdWebViewControllerWebKitEnabled
    if ([WKWebView class])
    {
        NSString  *htmlToLoad  = html;

        if (!_configuration.scrollingEnabled) {
            htmlToLoad = [[self class] prependViewportToHTML:html];
        }

        [self loadModernWebViewWithSize: size
                                   HTML: htmlToLoad
                                baseURL: base];
    } else
#endif
    {
        NSString *htmlWithScripts = [[self class] prependScriptsToHTML:html];

        [self loadLegacyWebViewWithSize: size
                                   HTML: htmlWithScripts
                                baseURL: base];
    }

    //
    return self;
}

- (instancetype) initWithSize: (CGSize)size
                     videoXML: (NSString *)videoXML;
{
#if !defined(kANAdWebViewControllerWebKitEnabled)
    ANLogError(@"Banner Video requires use of WKWebView.")
    return  nil;
#endif


    self = [self initWithConfiguration:nil];
    if (!self)  { return nil; }

    self.configuration.scrollingEnabled = NO;


    //
    _videoXML = videoXML;
    [self handleMRAIDURL:[NSURL URLWithString:@"mraid://enable"]];


    //
    WKWebView  *webView  = [[self class] defaultModernWebViewWithSize:size configuration:self.configuration];

    [webView.configuration.userContentController addScriptMessageHandler:self name:@"observe"];
    webView.configuration.allowsInlineMediaPlayback = YES;
    [webView.configuration.userContentController addScriptMessageHandler:self name:@"interOp"];

    webView.backgroundColor = [UIColor blackColor];

    [webView setNavigationDelegate:self];
    [webView setUIDelegate:self];


    _modernWebView  = webView;
    _contentView    = webView;


    // Load, then enable WKWebView in active window.
    //
    NSURL           *url      = [[[ANSDKSettings sharedInstance] baseUrlConfig] videoWebViewUrl];
    NSURLRequest    *request  = [NSURLRequest requestWithURL:url];

    [_modernWebView loadRequest:request];

    UIWindow  *currentWindow  = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:_modernWebView];
    [_modernWebView setHidden:true];


    //
    return  self;
}

- (void) dealloc
{
    [self deallocActions];
}

- (void) deallocActions
{
    [self stopWebViewLoadForDealloc];
    [self.viewabilityTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




#pragma mark - Scripts

+ (NSString *)mraidHTML {
    return [NSString stringWithFormat:@"<script type=\"text/javascript\">%@</script>", [[self class] mraidJS]];
}

+ (NSString *)anjamHTML {
    return [NSString stringWithFormat:@"<script type=\"text/javascript\">%@</script>", [[self class] anjamJS]];
}

+ (NSString *)mraidJS
{
    NSString *mraidPath = ANMRAIDBundlePath();
    if (!mraidPath) {
        return @"";
    }

    NSBundle    *mraidBundle    = [[NSBundle alloc] initWithPath:mraidPath];
    NSData      *data           = [NSData dataWithContentsOfFile:[mraidBundle pathForResource:@"mraid" ofType:@"js"]];
    NSString    *mraidString    = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    return  mraidString;
}

+ (NSString *)anjamJS
{
    NSString *sdkjsPath = ANPathForANResource(@"sdkjs", @"js");
    NSString *anjamPath = ANPathForANResource(@"anjam", @"js");
    if (!sdkjsPath || !anjamPath) {
        return @"";
    }

    NSData      *sdkjsData  = [NSData dataWithContentsOfFile:sdkjsPath];
    NSData      *anjamData  = [NSData dataWithContentsOfFile:anjamPath];
    NSString    *sdkjs      = [[NSString alloc] initWithData:sdkjsData encoding:NSUTF8StringEncoding];
    NSString    *anjam      = [[NSString alloc] initWithData:anjamData encoding:NSUTF8StringEncoding];

    NSString  *anjamString  = [NSString stringWithFormat:@"%@ %@", sdkjs, anjam];

    return  anjamString;
}

+ (NSString *)prependViewportToHTML:(NSString *)html
{
    return [NSString stringWithFormat:@"%@%@", @"<meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=no\">", html];
}

+ (NSString *)prependScriptsToHTML:(NSString *)html {
    return [NSString stringWithFormat:@"%@%@%@", [[self class] anjamHTML], [[self class] mraidHTML], html];
}




#pragma mark - UIWebView

+ (UIWebView *)defaultLegacyWebViewWithSize:(CGSize)size
                              configuration:(ANAdWebViewControllerConfiguration *)configuration {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    if (configuration.scrollingEnabled) {
        webView.scrollView.scrollEnabled = YES;
        webView.scrollView.bounces = YES;
        webView.scalesPageToFit = YES;
    } else {
        webView.scrollView.scrollEnabled = NO;
        webView.scrollView.bounces = NO;
        webView.scalesPageToFit = NO;
    }
    [webView an_setMediaProperties];
    return webView;
}

- (void)loadLegacyWebViewWithSize:(CGSize)size
                              URL:(NSURL *)URL
                          baseURL:(NSURL *)baseURL {
    UIWebView *webView = [[self class] defaultLegacyWebViewWithSize:size
                                                      configuration:self.configuration];
    webView.delegate = self;
    self.legacyWebView = webView;
    self.contentView = webView;
    __weak UIWebView *weakWebView = webView;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:ANBasicRequestWithURL(URL) completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UIWebView *strongWebView = weakWebView;
        if (strongWebView) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (html.length) {
                    NSString *htmlWithScripts = [[self class] prependScriptsToHTML:html];
                    [strongWebView loadHTMLString:htmlWithScripts baseURL:baseURL];
                }
            });
            
            
        }
    }] resume];
}

- (void)loadLegacyWebViewWithSize:(CGSize)size
                             HTML:(NSString *)html
                          baseURL:(NSURL *)baseURL {
    UIWebView *webView = [[self class] defaultLegacyWebViewWithSize:size
                                                      configuration:self.configuration];
    webView.delegate = self;
    [webView loadHTMLString:html
                    baseURL:baseURL];
    self.legacyWebView = webView;
    self.contentView = webView;
}




#pragma mark - WKWebView

#if kANAdWebViewControllerWebKitEnabled

+ (WKWebView *)defaultModernWebViewWithSize:(CGSize)size
                              configuration:(ANAdWebViewControllerConfiguration *)configuration
{
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)
                                            configuration:[[self class] defaultWebViewConfigurationWithConfiguration:configuration]];

    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;

    if (@available(iOS 11.0, *)) {
        webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    if (configuration.scrollingEnabled) {
        webView.scrollView.scrollEnabled = YES;
        webView.scrollView.bounces = YES;

    } else {
        webView.scrollView.scrollEnabled = NO;
        webView.scrollView.bounces = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:webView
                                                        name:UIKeyboardWillChangeFrameNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:webView
                                                        name:UIKeyboardDidChangeFrameNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:webView
                                                        name:UIKeyboardWillShowNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:webView
                                                        name:UIKeyboardWillHideNotification
                                                      object:nil];
    }
    return webView;
}

- (void)loadModernWebViewWithSize:(CGSize)size
                              URL:(NSURL *)URL
                          baseURL:(NSURL *)baseURL 
{
    WKWebView *webView = [[self class] defaultModernWebViewWithSize:size configuration:self.configuration];

    webView.navigationDelegate = self;
    webView.UIDelegate = self;

    self.modernWebView = webView;
    self.contentView = webView;

    __weak WKWebView  *weakWebView  = webView;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest: ANBasicRequestWithURL(URL)
                                     completionHandler: ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                        {
                                            __strong WKWebView  *strongWebView  = weakWebView;
                                            if (!strongWebView)  {
                                                ANLogError(@"COULD NOT ACQUIRE strongWebView.");
                                                return;
                                            }

                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                                                if (html.length) {
                                                    [strongWebView loadHTMLString:html baseURL:baseURL];
                                                }
                                            });
                                        }
      ] resume];
}

- (void)loadModernWebViewWithSize:(CGSize)size
                             HTML:(NSString *)html
                          baseURL:(NSURL *)baseURL
{
    WKWebView *webView = [[self class] defaultModernWebViewWithSize: size
                                                      configuration: self.configuration];

    webView.navigationDelegate  = self;
    webView.UIDelegate          = self;

    [webView loadHTMLString:html
                    baseURL:baseURL];

    self.modernWebView  = webView;
    self.contentView    = webView;
}

+ (WKWebViewConfiguration *)defaultWebViewConfigurationWithConfiguration:(ANAdWebViewControllerConfiguration *)webViewControllerConfig
{
    static dispatch_once_t   processPoolToken;
    static WKProcessPool    *anSdkProcessPool;

    dispatch_once(&processPoolToken, ^{
        anSdkProcessPool = [[WKProcessPool alloc] init];
    });

    WKWebViewConfiguration  *configuration  = [[WKWebViewConfiguration alloc] init];

    configuration.processPool                   = anSdkProcessPool;
    configuration.allowsInlineMediaPlayback     = YES;
    
    // configuration.allowsInlineMediaPlayback = YES is not respected
    // on iPhone on WebKit versions shipped with iOS 9 and below, the
    // video always loads in full-screen.
    // See: https://bugs.webkit.org/show_bug.cgi?id=147512
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        configuration.requiresUserActionForMediaPlayback = NO;

    } else {
        if (    [[NSProcessInfo processInfo] respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)]
             && [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){10,0,0}] )
        {
            configuration.requiresUserActionForMediaPlayback = NO;
        } else {
            configuration.requiresUserActionForMediaPlayback = YES;
        }
    }
    
    WKUserContentController  *controller  = [[WKUserContentController alloc] init];
    configuration.userContentController = controller;
    
    NSString *paddingJS = @"document.body.style.margin='0';document.body.style.padding = '0'";
    
    WKUserScript *mraidScript = [[WKUserScript alloc] initWithSource: [[self class] mraidJS]
                                                       injectionTime: WKUserScriptInjectionTimeAtDocumentStart
                                                    forMainFrameOnly: YES];

    WKUserScript *anjamScript = [[WKUserScript alloc] initWithSource: [[self class] anjamJS]
                                                       injectionTime: WKUserScriptInjectionTimeAtDocumentStart
                                                    forMainFrameOnly: YES];

    WKUserScript *paddingScript = [[WKUserScript alloc] initWithSource: paddingJS
                                                         injectionTime: WKUserScriptInjectionTimeAtDocumentEnd
                                                      forMainFrameOnly: YES];

    if (!webViewControllerConfig.userSelectionEnabled)
    {
        NSString *userSelectionSuppressionJS = @"document.documentElement.style.webkitUserSelect='none';";

        WKUserScript *userSelectionSuppressionScript = [[WKUserScript alloc] initWithSource: userSelectionSuppressionJS
                                                                              injectionTime: WKUserScriptInjectionTimeAtDocumentEnd
                                                                           forMainFrameOnly: NO];
        [controller addUserScript:userSelectionSuppressionScript];
    }

    [controller addUserScript:anjamScript];
    [controller addUserScript:mraidScript];
    [controller addUserScript:paddingScript];

    return configuration;
}

#endif  //kANAdWebViewControllerWebKitEnabled




# pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView an_removeDocumentPadding];
    [self processWebViewDidFinishLoad];
}

- (BOOL)                webView: (UIWebView *)webView
     shouldStartLoadWithRequest: (NSURLRequest *)request
                 navigationType: (UIWebViewNavigationType)navigationType
{
    NSURL *URL = [request URL];
    NSURL *mainDocumentURL = [request mainDocumentURL];
    NSString *scheme = [URL scheme];
    
    if ([scheme isEqualToString:@"anwebconsole"]) {
        [self printConsoleLogWithURL:URL];
        return NO;
    }

    ANLogDebug(@"Loading URL: %@", [[URL absoluteString] stringByRemovingPercentEncoding]);

    if ([scheme isEqualToString:@"appnexuspb"]) {
        [self.pitbullDelegate handlePitbullURL:URL];
        return NO;
    }

    if (self.completedFirstLoad) {
        if (ANHasHttpPrefix(scheme)) {
            if (self.isMRAID) {
                if ([[mainDocumentURL absoluteString] isEqualToString:[URL absoluteString]] && self.configuration.navigationTriggersDefaultBrowser) {
                    [self.browserDelegate openDefaultBrowserWithURL:URL];
                    return NO;
                }
            } else {
                if (([[mainDocumentURL absoluteString] isEqualToString:[URL absoluteString]] || navigationType == UIWebViewNavigationTypeLinkClicked)
                    && self.configuration.navigationTriggersDefaultBrowser) {
                    [self.browserDelegate openDefaultBrowserWithURL:URL];
                    return NO;
                }
            }
        } else if ([scheme isEqualToString:@"mraid"]) {
            [self handleMRAIDURL:URL];
            return NO;
        } else if ([scheme isEqualToString:@"anjam"]) {
            [self.anjamDelegate handleANJAMURL:URL];
            return NO;
        } else if ([scheme isEqualToString:@"about"]) {
            return NO;
        } else {
            if (self.configuration.navigationTriggersDefaultBrowser) {
                [self.browserDelegate openDefaultBrowserWithURL:URL];
                return NO;
            }
        }
    } else if ([scheme isEqualToString:@"mraid"] && [[URL host] isEqualToString:@"enable"]) {
        [self handleMRAIDURL:URL];
        return NO;
    }
    
    return YES;
}





#pragma mark - WKNavigationDelegate

#if kANAdWebViewControllerWebKitEnabled

-(void) webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    ANLogInfo(@"");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self processWebViewDidFinishLoad];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    ANLogDebug(@"%@ %@", NSStringFromSelector(_cmd), error);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    ANLogDebug(@"%@ %@", NSStringFromSelector(_cmd), error);
}

- (void)                    webView: (WKWebView *)webView
    decidePolicyForNavigationAction: (WKNavigationAction *)navigationAction
                    decisionHandler: (void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *URL = navigationAction.request.URL;
    NSURL *mainDocumentURL = navigationAction.request.mainDocumentURL;
    NSString *URLScheme = URL.scheme;
    
    if ([URLScheme isEqualToString:@"anwebconsole"]) {
        [self printConsoleLogWithURL:URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    ANLogDebug(@"Loading URL: %@", [[URL absoluteString] stringByRemovingPercentEncoding]);
    
    if ([URLScheme isEqualToString:@"appnexuspb"]) {
        [self.pitbullDelegate handlePitbullURL:URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    // For security reasons, test for fragment of path to vastVideo.html.
    //
    if ([URLScheme isEqualToString:@"file"])
    {
        NSString  *filePathContainsThisString  = @"/vastVideo.html";

        if ([[URL absoluteString] rangeOfString:filePathContainsThisString].location == NSNotFound) {
            return;
        }

        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }

    if (self.completedFirstLoad) {
        if (ANHasHttpPrefix(URLScheme)) {
            if (self.isMRAID) {
                if (([[mainDocumentURL absoluteString] isEqualToString:[URL absoluteString]]
                     || navigationAction.targetFrame == nil)
                    && self.configuration.navigationTriggersDefaultBrowser) {
                    [self.browserDelegate openDefaultBrowserWithURL:URL];
                    decisionHandler(WKNavigationActionPolicyCancel);
                    return;
                }
            } else {
                if (([[mainDocumentURL absoluteString] isEqualToString:[URL absoluteString]]
                     || navigationAction.navigationType == WKNavigationTypeLinkActivated
                     || navigationAction.targetFrame == nil)
                    && self.configuration.navigationTriggersDefaultBrowser) {
                    [self.browserDelegate openDefaultBrowserWithURL:URL];
                    decisionHandler(WKNavigationActionPolicyCancel);
                    return;
                }
            }
        } else if ([URLScheme isEqualToString:@"mraid"]) {
            [self handleMRAIDURL:URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        } else if ([URLScheme isEqualToString:@"anjam"]) {
            [self.anjamDelegate handleANJAMURL:URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        } else if ([URLScheme isEqualToString:@"about"]) {
            if (navigationAction.targetFrame && navigationAction.targetFrame.mainFrame == NO) {
                decisionHandler(WKNavigationActionPolicyAllow);
            } else {
                decisionHandler(WKNavigationActionPolicyCancel);
            }
            return;
        } else {
            if (self.configuration.navigationTriggersDefaultBrowser) {
                [self.browserDelegate openDefaultBrowserWithURL:URL];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }
    } else {
        if ([URLScheme isEqualToString:@"mraid"]) {
            if ([URL.host isEqualToString:@"enable"]) {
                [self handleMRAIDURL:URL];
            }
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        } else if ([URLScheme isEqualToString:@"anjam"]) {
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}



#pragma mark - WKUIDelegate

- (WKWebView *)         webView: (WKWebView *)webView
 createWebViewWithConfiguration: (WKWebViewConfiguration *)configuration
            forNavigationAction: (WKNavigationAction *)navigationAction
                 windowFeatures: (WKWindowFeatures *)windowFeatures
{
    if (navigationAction.targetFrame == nil) {
        [self.browserDelegate openDefaultBrowserWithURL:navigationAction.request.URL];
    }

    return nil;
}

#endif  //kANAdWebViewControllerWebKitEnabled




#pragma mark - WKScriptMessageHandler.

- (void) userContentController: (WKUserContentController *)userContentController
       didReceiveScriptMessage: (WKScriptMessage *)message
{
    if (!message)  { return; }

    NSString        *eventName          = @"";
    NSDictionary    *paramsDictionary   = [NSDictionary new];

    if ([message.body isKindOfClass:[NSString class]])
    {
        eventName = (NSString *)message.body;

    } else if ([message.body isKindOfClass:[NSDictionary class]]) {
        NSDictionary  *messageDictionary  = (NSDictionary *)message.body;

        if (messageDictionary.count > 0) {
            eventName           = [messageDictionary objectForKey:@"event"];
            paramsDictionary    = [messageDictionary objectForKey:@"params"];
        }
    }

    ANLogInfo(@"Event: %@", eventName);

    if ([eventName isEqualToString:@"adReady"])
    {
        if ([self.videoDelegate respondsToSelector:@selector(videoAdReady)]) {
            [self.videoDelegate videoAdReady];
        }

    } else if ([eventName isEqualToString:@"videoStart"] || [eventName isEqualToString:@"videoRewind"]) {
        [self.viewabilityTimer fire];

        if ([self.mraidDelegate respondsToSelector:@selector(isViewable)]) {
            [self updateViewability:[self.mraidDelegate isViewable]];
        }


    } else if([eventName isEqualToString:@"video-fullscreen-enter"]) {
        if ([self.videoDelegate respondsToSelector:@selector(videoAdPlayerFullScreenEntered:)]) {
            [self.videoDelegate videoAdPlayerFullScreenEntered:self];

        }

    } else if([eventName isEqualToString:@"video-fullscreen-exit"]) {
        if ([self.videoDelegate respondsToSelector:@selector(videoAdPlayerFullScreenExited:)]) {
            [self.videoDelegate videoAdPlayerFullScreenExited:self];
        }


    } else if([eventName isEqualToString:@"video-error"] || [eventName isEqualToString:@"Timed-out"]) {
        //we need to remove the webview to makesure we dont get any other response from the loaded index.html page
        [self deallocActions];

        if([self.videoDelegate respondsToSelector:@selector(videoAdError:)]){
            NSError *error = ANError(@"Timeout reached while parsing VAST", ANAdResponseInternalError);
            [self.videoDelegate videoAdError:error];
        }

        if ([self.loadingDelegate respondsToSelector:@selector(immediatelyRestartAutoRefreshTimerFromWebViewController:)]) {
            [self.loadingDelegate immediatelyRestartAutoRefreshTimerFromWebViewController:self];
        }


    } else if (      ([self.videoXML length] > 0)
                && (      [eventName isEqualToString:@"video-first-quartile"]
                       || [eventName isEqualToString:@"video-mid"]
                       || [eventName isEqualToString:@"video-third-quartile"]
                       || [eventName isEqualToString:@"video-complete"]
                       || [eventName isEqualToString:@"audio-mute"]
                       || [eventName isEqualToString:@"audio-unmute"]
                   )
               )
    {
            //EMPTY -- Silently ignore spurious VAST playback errors that might scare a client-dev into thinking something is wrong...

    } else {
        ANLogError(@"UNRECOGNIZED video event.  (%@)", eventName);
    }
}




# pragma mark - MRAID

- (void)processWebViewDidFinishLoad
{
    if (!self.completedFirstLoad)
    {
        self.completedFirstLoad = YES;
        // If it is VAST ad then donot call didCompleteFirstLoadFromWebViewController videoAdReady will call it later.
        if ([self.videoXML length] > 0)
        {
            @synchronized(self) {
                [self processVideoViewDidFinishLoad];
            }
        }else if ([self.loadingDelegate respondsToSelector:@selector(didCompleteFirstLoadFromWebViewController:)])
        {
            @synchronized(self) {
                [self.loadingDelegate didCompleteFirstLoadFromWebViewController:self];
            }
        }

        //
        if (self.isMRAID) {
            [self finishMRAIDLoad];
        }
    }
}

- (void)finishMRAIDLoad
{
    [self fireJavaScript:[ANMRAIDJavascriptUtil feature:@"sms"
                                            isSupported:[ANMRAIDUtil supportsSMS]]];
    [self fireJavaScript:[ANMRAIDJavascriptUtil feature:@"tel"
                                            isSupported:[ANMRAIDUtil supportsTel]]];
    [self fireJavaScript:[ANMRAIDJavascriptUtil feature:@"calendar"
                                            isSupported:[ANMRAIDUtil supportsCalendar]]];
    [self fireJavaScript:[ANMRAIDJavascriptUtil feature:@"inlineVideo"
                                            isSupported:[ANMRAIDUtil supportsInlineVideo]]];
    [self fireJavaScript:[ANMRAIDJavascriptUtil feature:@"storePicture"
                                            isSupported:[ANMRAIDUtil supportsStorePicture]]];
    
    [self updateWebViewOnOrientation];
    [self updateWebViewOnPositionAndViewabilityStatus];

    if (self.configuration.initialMRAIDState == ANMRAIDStateExpanded || self.configuration.initialMRAIDState == ANMRAIDStateResized)
    {
        [self setupRapidTimerForCheckingPositionAndViewability];
        self.rapidTimerSet = YES;
    } else {
        [self setupTimerForCheckingPositionAndViewability];
    }

    [self setupApplicationBackgroundNotifications];
    [self setupOrientationChangeNotification];
    
    if ([self.adViewDelegate adTypeForMRAID]) {
        [self fireJavaScript:[ANMRAIDJavascriptUtil placementType:[self.adViewDelegate adTypeForMRAID]]];
    }
    [self fireJavaScript:[ANMRAIDJavascriptUtil stateChange:self.configuration.initialMRAIDState]];
    [self fireJavaScript:[ANMRAIDJavascriptUtil readyEvent]];
}

- (void)setupApplicationBackgroundNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];

    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleApplicationDidBecomeActive:)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];

}

- (void)handleApplicationDidEnterBackground:(NSNotification *)notification
{
    self.viewable = NO;
    self.appIsInBackground = YES;

    if (self.videoDelegate) {
        [self updateViewability:NO];
    } else {
        [self fireJavaScript:[ANMRAIDJavascriptUtil isViewable:NO]];
    }
}

-(void)handleApplicationDidBecomeActive:(NSNotification *)notification
{
    self.appIsInBackground = NO;
}

- (void)setupOrientationChangeNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOrientationChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:[UIApplication sharedApplication]];
}

- (void)handleOrientationChange:(NSNotification *)notification {
    [self updateWebViewOnOrientation];
}

- (void)setupTimerForCheckingPositionAndViewability
{
    [self enableViewabilityTimerWithTimeInterval:self.checkViewableTimeInterval
                                            mode:self.checkViewableRunLoopMode];
}

- (void)setupRapidTimerForCheckingPositionAndViewability
{
    [self enableViewabilityTimerWithTimeInterval:0.1
                                            mode:NSRunLoopCommonModes];
}

- (void)setCheckViewableTimeInterval:(NSTimeInterval)timeInterval
{
    _checkViewableTimeInterval = timeInterval;
    _checkViewableRunLoopMode = NSRunLoopCommonModes;
    if (self.viewabilityTimer) {
        [self enableViewabilityTimerWithTimeInterval:_checkViewableTimeInterval
                                                mode:_checkViewableRunLoopMode];
    } // Otherwise will be enabled in finishMRAIDLoad method
}

- (void)enableViewabilityTimerWithTimeInterval:(NSTimeInterval)timeInterval mode:(NSRunLoopMode)mode
{
    ANLogDebug(@"");
    if (self.viewabilityTimer) {
        [self.viewabilityTimer invalidate];
    }
    __weak ANAdWebViewController *weakSelf = self;
    if (mode == NSRunLoopCommonModes) {
        self.viewabilityTimer = [NSTimer an_scheduledTimerWithTimeInterval:timeInterval
                                                                     block:^{
                                                                         ANAdWebViewController *strongSelf = weakSelf;
                                                                         [strongSelf updateWebViewOnPositionAndViewabilityStatus];
                                                                     }
                                                                   repeats:YES
                                                                      mode:mode];
    } else {
        self.viewabilityTimer = [NSTimer an_scheduledTimerWithTimeInterval:timeInterval
                                                                     block:^ {
                                                                         ANAdWebViewController *strongSelf = weakSelf;
                                                                         [strongSelf updateWebViewOnPositionAndViewabilityStatus];
                                                                     }
                                                                   repeats:YES];
    }
}

- (void)updateWebViewOnPositionAndViewabilityStatus
{
    CGRect updatedDefaultPosition = [self.mraidDelegate defaultPosition];
    if (!CGRectEqualToRect(self.defaultPosition, updatedDefaultPosition)) {
        ANLogDebug(@"Default position change: %@", NSStringFromCGRect(updatedDefaultPosition));
        self.defaultPosition = updatedDefaultPosition;
        [self fireJavaScript:[ANMRAIDJavascriptUtil defaultPosition:self.defaultPosition]];
    }
    
    CGRect updatedCurrentPosition = [self.mraidDelegate currentPosition];
    if (!CGRectEqualToRect(self.currentPosition, updatedCurrentPosition)) {
        ANLogDebug(@"Current position change: %@", NSStringFromCGRect(updatedCurrentPosition));
        self.currentPosition = updatedCurrentPosition;
        [self fireJavaScript:[ANMRAIDJavascriptUtil currentPosition:self.currentPosition]];
    }
    
    BOOL isCurrentlyViewable = (!self.appIsInBackground && [self.mraidDelegate isViewable]);

    if (self.isViewable != isCurrentlyViewable) {
        ANLogDebug(@"Viewablity change: %d", isCurrentlyViewable);
        self.viewable = isCurrentlyViewable;

        if (self.videoDelegate) {
            [self updateViewability:self.isViewable];
        } else {
            [self fireJavaScript:[ANMRAIDJavascriptUtil isViewable:self.isViewable]];
        }
    }
    
    CGFloat updatedExposedPercentage = [self.mraidDelegate exposedPercent]; // updatedExposedPercentage from MRAID Delegate
    CGRect updatedVisibleRectangle = [self.mraidDelegate visibleRect]; // updatedVisibleRectangle from MRAID Delegate

    // Send exposureChange Event only when there is an update from the previous.
    if(self.lastKnownExposedPercentage != updatedExposedPercentage || !CGRectEqualToRect(self.lastKnownVisibleRect,updatedVisibleRectangle)){
        self.lastKnownExposedPercentage = updatedExposedPercentage;
        self.lastKnownVisibleRect = updatedVisibleRectangle;
        [self fireJavaScript:[ANMRAIDJavascriptUtil exposureChangeExposedPercentage:self.lastKnownExposedPercentage visibleRectangle:self.lastKnownVisibleRect]];
    }
}

- (void)updateWebViewOnOrientation {
    [self fireJavaScript:[ANMRAIDJavascriptUtil screenSize:[ANMRAIDUtil screenSize]]];
    [self fireJavaScript:[ANMRAIDJavascriptUtil maxSize:[ANMRAIDUtil maxSize]]];
}

- (void)fireJavaScript:(NSString *)javascript {
#if kANAdWebViewControllerWebKitEnabled
    if (self.modernWebView) {
        [self.modernWebView evaluateJavaScript:javascript completionHandler:nil];
    } else
#endif
    {
        [self.legacyWebView stringByEvaluatingJavaScriptFromString:javascript];
    }
}

- (void)stopWebViewLoadForDealloc
{
#if kANAdWebViewControllerWebKitEnabled
    if (self.modernWebView)
    {
        [self.modernWebView stopLoading];

        [self.modernWebView setNavigationDelegate:nil];
        [self.modernWebView setUIDelegate:nil];

        [self.modernWebView removeFromSuperview];
        self.modernWebView = nil;

    } else
#endif
    {
        [self.legacyWebView loadHTMLString:@"" baseURL:nil];
        [self.legacyWebView stopLoading];

        self.legacyWebView.delegate = nil;

        [self.legacyWebView an_removeSubviews];
        [self.legacyWebView removeFromSuperview];
        self.legacyWebView = nil;
    }

    self.contentView = nil;
}

- (void)handleMRAIDURL:(NSURL *)URL {
    ANLogDebug(@"Received MRAID query: %@", URL);
    
    NSString *mraidCommand = [URL host];
    NSString *query = [URL query];
    NSDictionary *queryComponents = [query an_queryComponents];
    
    ANMRAIDAction action = [ANMRAIDUtil actionForCommand:mraidCommand];
    switch (action) {
        case ANMRAIDActionUnknown:
            ANLogDebug(@"Unknown MRAID action requested: %@", mraidCommand);
            return;
        case ANMRAIDActionExpand:
            [self.adViewDelegate adWasClicked];
            [self forwardExpandRequestWithQueryComponents:queryComponents];
            break;
        case ANMRAIDActionClose:
            [self forwardCloseAction];
            break;
        case ANMRAIDActionResize:
            [self.adViewDelegate adWasClicked];
            [self forwardResizeRequestWithQueryComponents:queryComponents];
            break;
        case ANMRAIDActionCreateCalendarEvent: {
            [self.adViewDelegate adWasClicked];
            NSString *w3cEventJson = [queryComponents[@"p"] description];
            [self forwardCalendarEventRequestWithW3CJSONString:w3cEventJson];
            break;
        }
        case ANMRAIDActionPlayVideo: {
            [self.adViewDelegate adWasClicked];
            NSString *uri = [queryComponents[@"uri"] description];
            [self.mraidDelegate adShouldPlayVideoWithUri:uri];
            break;
        }
        case ANMRAIDActionStorePicture: {
            [self.adViewDelegate adWasClicked];
            NSString *uri = [queryComponents[@"uri"] description];
            [self.mraidDelegate adShouldSavePictureWithUri:uri];
            break;
        }
        case ANMRAIDActionSetOrientationProperties:
            [self forwardOrientationPropertiesWithQueryComponents:queryComponents];
            break;
        case ANMRAIDActionSetUseCustomClose: {
            NSString *value = [queryComponents[@"value"] description];
            BOOL useCustomClose = [value isEqualToString:@"true"];
            [self.mraidDelegate adShouldSetUseCustomClose:useCustomClose];
            break;
        }
        case ANMRAIDActionOpenURI: {
            NSString *uri = [queryComponents[@"uri"] description];
            NSURL *URL = [NSURL URLWithString:uri];
            if (uri.length && URL) {
                [self.browserDelegate openDefaultBrowserWithURL:URL];
            }
            break;
        }
        case ANMRAIDActionEnable:
            if (self.isMRAID) return;
            self.isMRAID = YES;
            if (self.completedFirstLoad) [self finishMRAIDLoad];
            break;
        default:
            ANLogError(@"Known but unhandled MRAID action: %@", mraidCommand);
            break;
    }
}

- (void)forwardCloseAction {
    [self.mraidDelegate adShouldClose];
}

- (void)forwardResizeRequestWithQueryComponents:(NSDictionary *)queryComponents {
    ANMRAIDResizeProperties *resizeProperties = [ANMRAIDResizeProperties resizePropertiesFromQueryComponents:queryComponents];
    [self.mraidDelegate adShouldAttemptResizeWithResizeProperties:resizeProperties];
}

- (void)forwardExpandRequestWithQueryComponents:(NSDictionary *)queryComponents
{
    if (!self.rapidTimerSet) {
        [self setupRapidTimerForCheckingPositionAndViewability];
        self.rapidTimerSet = YES;
    }
    ANMRAIDExpandProperties *expandProperties = [ANMRAIDExpandProperties expandPropertiesFromQueryComponents:queryComponents];
    [self forwardOrientationPropertiesWithQueryComponents:queryComponents];
    [self.mraidDelegate adShouldExpandWithExpandProperties:expandProperties];
}

- (void)forwardOrientationPropertiesWithQueryComponents:(NSDictionary *)queryComponents {
    ANMRAIDOrientationProperties *orientationProperties = [ANMRAIDOrientationProperties orientationPropertiesFromQueryComponents:queryComponents];
    [self.mraidDelegate adShouldSetOrientationProperties:orientationProperties];
}

- (void)forwardCalendarEventRequestWithW3CJSONString:(NSString *)json {
    NSError *error;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:kNilOptions
                                                      error:&error];
    if (!error && [jsonObject isKindOfClass:[NSDictionary class]]) {
        [self.mraidDelegate adShouldOpenCalendarWithCalendarDict:(NSDictionary *)jsonObject];
    }
}

- (void)updatePlacementType:(NSString *)placementType {
    if (self.isMRAID) {
        [self fireJavaScript:[ANMRAIDJavascriptUtil placementType:placementType]];
    }
}




#pragma mark - MRAID Callbacks

- (void)adDidFinishExpand {
    [self fireJavaScript:[ANMRAIDJavascriptUtil stateChange:ANMRAIDStateExpanded]];
}

- (void)adDidFinishResize:(BOOL)success
              errorString:(NSString *)errorString
                isResized:(BOOL)isResized {
    if (success) {
        [self fireJavaScript:[ANMRAIDJavascriptUtil stateChange:ANMRAIDStateResized]];
    } else {
        [self fireJavaScript:[ANMRAIDJavascriptUtil error:errorString
                                              forFunction:@"mraid.resize()"]];
    }
}

- (void)adDidResetToDefault {
    [self fireJavaScript:[ANMRAIDJavascriptUtil stateChange:ANMRAIDStateDefault]];
}

- (void)adDidHide {
    [self fireJavaScript:[ANMRAIDJavascriptUtil stateChange:ANMRAIDStateHidden]];
    [self stopWebViewLoadForDealloc];
}

- (void)adDidFailCalendarEditWithErrorString:(NSString *)errorString {
    [self fireJavaScript:[ANMRAIDJavascriptUtil error:errorString
                                          forFunction:@"mraid.createCalendarEvent()"]];
}

- (void)adDidFailPhotoSaveWithErrorString:(NSString *)errorString {
    [self fireJavaScript:[ANMRAIDJavascriptUtil error:errorString
                                          forFunction:@"mraid.storePicture()"]];
}




#pragma mark - ANWebConsole

- (void)printConsoleLogWithURL:(NSURL *)URL {
    NSString *decodedString = [[URL absoluteString] stringByRemovingPercentEncoding];
    NSLog(@"------- %@", decodedString);
}




#pragma mark - ANAdViewInternalDelegate

- (void)setAdViewDelegate:(id<ANAdViewInternalDelegate>)adViewDelegate {
    _adViewDelegate = adViewDelegate;
    if (_adViewDelegate) {
        [self fireJavaScript:[ANMRAIDJavascriptUtil placementType:[_adViewDelegate adTypeForMRAID]]];
    }
}




#pragma mark - Banner Video.
        
- (void) processVideoViewDidFinishLoad
{
    NSString  *execTemplate    = @"createVastPlayerWithContent('%@', 'BANNER');";
    NSString  *exec            = [NSString stringWithFormat:execTemplate, self.videoXML];

    [self.modernWebView evaluateJavaScript:exec completionHandler:nil];
}

- (void) updateViewability:(BOOL)isViewable
{
    NSString  *exec  = [NSString stringWithFormat:@"viewabilityUpdate('%@');", isViewable ? @"true" : @"false"];
    [self.modernWebView evaluateJavaScript:exec completionHandler:nil];
}


@end   //ANAdWebViewController




#pragma mark - ANAdWebViewControllerConfiguration Implementation

@implementation ANAdWebViewControllerConfiguration

- (instancetype)init {
    if (self = [super init]) {
        _scrollingEnabled = NO;
        _navigationTriggersDefaultBrowser = YES;
        _initialMRAIDState = ANMRAIDStateDefault;
        _userSelectionEnabled = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ANAdWebViewControllerConfiguration *configurationCopy = [[ANAdWebViewControllerConfiguration alloc] init];
    configurationCopy.scrollingEnabled = self.scrollingEnabled;
    configurationCopy.navigationTriggersDefaultBrowser = self.navigationTriggersDefaultBrowser;
    configurationCopy.initialMRAIDState = self.initialMRAIDState;
    configurationCopy.userSelectionEnabled = self.userSelectionEnabled;
    return configurationCopy;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(scrollingEnabled: %d, navigationTriggersDefaultBrowser: %d, \
            initialMRAIDState: %lu, userSelectionEnabled: %d", self.scrollingEnabled,
            self.navigationTriggersDefaultBrowser, (long unsigned)self.initialMRAIDState,
            self.userSelectionEnabled];
}

@end   //ANAdWebViewControllerConfiguration
