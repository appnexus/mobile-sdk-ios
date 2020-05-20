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
#import "UIView+ANCategory.h"

#import "ANSDKSettings+PrivateMethods.h"
#import "ANAdConstants.h"

#import "ANOMIDImplementation.h"
#import "ANWebView.h"
#import "ANWarmupWebView.h"
#import "ANVideoPlayerSettings+ANCategory.h"

NSString *const kANWebViewControllerMraidJSFilename = @"mraid.js";



NSString * __nonnull const  kANUISupportedInterfaceOrientations   = @"UISupportedInterfaceOrientations";
NSString * __nonnull const  kANUIInterfaceOrientationPortrait     = @"UIInterfaceOrientationPortrait";
NSString * __nonnull const  kANUIInterfaceOrientationPortraitUpsideDown     = @"UIInterfaceOrientationPortraitUpsideDown";
NSString * __nonnull const  kANUIInterfaceOrientationLandscapeLeft     = @"UIInterfaceOrientationLandscapeLeft";
NSString * __nonnull const  kANUIInterfaceOrientationLandscapeRight     = @"UIInterfaceOrientationLandscapeRight";
NSString * __nonnull const  kANPortrait     = @"portrait";
NSString * __nonnull const  kANLandscape     = @"landscape";



@interface ANAdWebViewController () <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (nonatomic, readwrite, strong)    UIView      *contentView;
@property (nonatomic, readwrite, strong)    ANWebView      *webView;
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
@property (nonatomic, readwrite, assign)  ANVideoOrientation  videoAdOrientation;

@property (nonatomic, readwrite, strong) NSDate *processStart;
@property (nonatomic, readwrite, strong) NSDate *processEnd;

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
        _checkViewableRunLoopMode = NSRunLoopCommonModes;
        
        _appIsInBackground = NO;
        _processStart = [NSDate date];
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
    
    _webView = [[ANWebView alloc]initWithSize:(CGSize)size
                                   URL:(NSURL *)URL
                               baseURL:(NSURL *)baseURL];
    [self loadWebViewWithUserScripts];
    
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
    
    NSString  *htmlToLoad  = html;
      
    if (!_configuration.scrollingEnabled) {
        htmlToLoad = [[self class] prependViewportToHTML:htmlToLoad];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //self->_webView = [[ANWebView alloc] initWithSize:size content:htmlToLoad baseURL:base];
        self->_webView = [[ANWarmupWebView sharedInstance] fetchWarmedUpWebView];
        [self->_webView loadHTMLString:htmlToLoad baseURL:base];
        [self loadWebViewWithUserScripts];
    });
    
    return self;
}

- (instancetype) initWithSize: (CGSize)size
                     videoXML: (NSString *)videoXML;
{
    self = [self initWithConfiguration:nil];
    if (!self)  { return nil; }
    
    self.configuration.scrollingEnabled = NO;
    self.configuration.isVASTVideoAd = YES;
    
    //Encode videoXML to Base64String
    _videoXML = [[videoXML dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    
    [self handleMRAIDURL:[NSURL URLWithString:@"mraid://enable"]];
    
    _webView = [[ANWebView alloc] initWithSize:size URL:[[[ANSDKSettings sharedInstance] baseUrlConfig] videoWebViewUrl]];
    
    [self loadWebViewWithUserScripts];
    
    UIWindow  *currentWindow  = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:self.webView];
    [self.webView setHidden:true];
    
    //
    return  self;
}
    


- (void)stopOMIDAdSession {
    if(self.omidAdSession != nil){
        [[ANOMIDImplementation sharedInstance] stopOMIDAdSession:self.omidAdSession];
    }
}

- (void) dealloc
{
    [self deallocActions];
}

- (void) deallocActions
{
    [self stopOMIDAdSession];
    [self stopWebViewLoadForDealloc];
    [self.viewabilityTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Scripts

+ (NSString *)prependViewportToHTML:(NSString *)html
{
    return [NSString stringWithFormat:@"%@%@", @"<meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=no\">", html];
}

//+ (NSString *)prependScriptsToHTML:(NSString *)html {
//    return [NSString stringWithFormat:@"%@%@%@", [[self class] anjamHTML], [[self class] mraidHTML], html];
//}

#pragma mark - configure WKWebView
 
-(void) loadWebViewWithUserScripts {
    
    WKUserContentController  *controller  = self.webView.configuration.userContentController;
    
    [controller addUserScript:ANGlobal.anjamScript];
    [controller addUserScript:ANGlobal.mraidScript];
    
    if (!self.configuration.userSelectionEnabled)
    {
        NSString *userSelectionSuppressionJS = @"document.documentElement.style.webkitUserSelect='none';";
        
        WKUserScript *userSelectionSuppressionScript = [[WKUserScript alloc] initWithSource: userSelectionSuppressionJS
                                                                              injectionTime: WKUserScriptInjectionTimeAtDocumentEnd
                                                                           forMainFrameOnly: NO];
        [controller addUserScript:userSelectionSuppressionScript];
    }
    
    // Attach  OMID JS script to WKWebview for HTML Banner Ad's
    // This is used inplace of [OMIDScriptInjector injectScriptContent] because it scrambles the creative HTML. See MS-3707 for more details.
    if(!self.configuration.isVASTVideoAd){
        
        [controller addUserScript:ANGlobal.omidScript];
    }
    
    if (self.configuration.scrollingEnabled) {
        self.webView.scrollView.scrollEnabled = YES;
        self.webView.scrollView.bounces = YES;
        
    } else {
        self.webView.scrollView.scrollEnabled = NO;
        self.webView.scrollView.bounces = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self.webView
                                                        name:UIKeyboardWillChangeFrameNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self.webView
                                                        name:UIKeyboardDidChangeFrameNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self.webView
                                                        name:UIKeyboardWillShowNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self.webView
                                                        name:UIKeyboardWillHideNotification
                                                      object:nil];
    }
    if(self.configuration.isVASTVideoAd){
        [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"observe"];
        self.webView.configuration.allowsInlineMediaPlayback = YES;
        [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"interOp"];
        
        self.webView.backgroundColor = [UIColor blackColor];
    }
    [self.webView setNavigationDelegate:self];
    [self.webView setUIDelegate:self];
    
    self.contentView = self.webView;
}

#pragma mark - WKNavigationDelegate


-(void) webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    ANLogInfo(@"");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    self.processEnd = [NSDate date];
    NSTimeInterval executionTime = [self.processEnd timeIntervalSinceDate:self.processStart];
    NSLog(@"Updated Ad WebView controller at: %f", executionTime*1000);
    
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
        if(paramsDictionary.count > 0){
            self.videoAdOrientation = [ANGlobal parseVideoOrientation:[paramsDictionary objectForKey:kANAspectRatio]];
        }
        // For VideoAds's wait unitll adReady to create AdSession if not the adsession will run in limited access mode.
        self.omidAdSession = [[ANOMIDImplementation sharedInstance] createOMIDAdSessionforWebView:self.webView isVideoAd:true];
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
        
        
    }else if([eventName isEqualToString:@"video-complete"]) {
        
        [self stopOMIDAdSession];
        
    }else if (      ([self.videoXML length] > 0)
               && (      [eventName isEqualToString:@"video-first-quartile"]
                   || [eventName isEqualToString:@"video-mid"]
                   || [eventName isEqualToString:@"video-third-quartile"]
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
        if(!([self.videoXML length] > 0)){
             self.omidAdSession = [[ANOMIDImplementation sharedInstance] createOMIDAdSessionforWebView:self.webView isVideoAd:false];
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
    [self updateCurrentAppOrientation];

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
    [self fireJavaScript:[ANMRAIDJavascriptUtil maxSize:[ANMRAIDUtil maxSizeSafeArea]]];
}



- (void)updateCurrentAppOrientation {
    
    UIInterfaceOrientation currentAppOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    NSString *currentAppOrientationString = (UIInterfaceOrientationIsPortrait(currentAppOrientation)) ? kANPortrait : kANLandscape;
    
    NSArray *supportedOrientations = [[[NSBundle mainBundle] infoDictionary]
                                      objectForKey:kANUISupportedInterfaceOrientations];
    BOOL isPortraitOrientationSupported = ([supportedOrientations containsObject:kANUIInterfaceOrientationPortrait] || [supportedOrientations containsObject:kANUIInterfaceOrientationPortraitUpsideDown]);
    BOOL isLandscapeOrientationSupported  = ([supportedOrientations containsObject:kANUIInterfaceOrientationLandscapeLeft] || [supportedOrientations containsObject:kANUIInterfaceOrientationLandscapeRight]);
    
    BOOL lockedOrientation = !(isPortraitOrientationSupported && isLandscapeOrientationSupported);
    
    
    [self fireJavaScript:[ANMRAIDJavascriptUtil setCurrentAppOrientation:currentAppOrientationString lockedOrientation:lockedOrientation]];

}

- (void)fireJavaScript:(NSString *)javascript {
        [self.webView evaluateJavaScript:javascript completionHandler:nil];
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
    NSString *videoOptions = [[ANVideoPlayerSettings sharedInstance] fetchBannerSettings];
    
    NSString *exec_template = @"createVastPlayerWithContent('%@','%@');";
    NSString *exec = [NSString stringWithFormat:exec_template, self.videoXML,videoOptions];
    
    [self.webView evaluateJavaScript:exec completionHandler:nil];
}

- (void) updateViewability:(BOOL)isViewable
{
    NSString  *exec  = [NSString stringWithFormat:@"viewabilityUpdate('%@');", isViewable ? @"true" : @"false"];
    [self.webView evaluateJavaScript:exec completionHandler:nil];
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
        _isVASTVideoAd = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ANAdWebViewControllerConfiguration *configurationCopy = [[ANAdWebViewControllerConfiguration alloc] init];
    configurationCopy.scrollingEnabled = self.scrollingEnabled;
    configurationCopy.navigationTriggersDefaultBrowser = self.navigationTriggersDefaultBrowser;
    configurationCopy.initialMRAIDState = self.initialMRAIDState;
    configurationCopy.userSelectionEnabled = self.userSelectionEnabled;
    configurationCopy.isVASTVideoAd = self.isVASTVideoAd;
    return configurationCopy;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(scrollingEnabled: %d, navigationTriggersDefaultBrowser: %d, \
            initialMRAIDState: %lu, userSelectionEnabled: %d, isBannerVideo: %d", self.scrollingEnabled,
            self.navigationTriggersDefaultBrowser, (long unsigned)self.initialMRAIDState,
            self.userSelectionEnabled, self.isVASTVideoAd];
}

@end   //ANAdWebViewControllerConfiguration
