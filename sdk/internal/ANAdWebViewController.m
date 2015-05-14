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
#import "UIWebView+ANCategory.h"
#import "UIView+ANCategory.h"

NSString *const kANWebViewControllerMraidJSFilename = @"mraid.js";

@interface ANAdWebViewController () <UIWebViewDelegate>

@property (nonatomic, readwrite, strong) UIView *contentView;
@property (nonatomic, readwrite, weak) UIWebView *legacyWebView;
@property (nonatomic, readwrite, assign) BOOL isMRAID;

@property (nonatomic, readwrite, assign) BOOL completedFirstLoad;

@property (nonatomic, readwrite, strong) NSTimer *viewabilityTimer;
@property (nonatomic, readwrite, assign, getter=isViewable) BOOL viewable;
@property (nonatomic, readwrite, assign) CGRect defaultPosition;
@property (nonatomic, readwrite, assign) CGRect currentPosition;
@property (nonatomic, readwrite, assign) BOOL rapidTimerSet;

@property (nonatomic, readwrite, strong) ANAdWebViewControllerConfiguration *configuration;

@end

@implementation ANAdWebViewController

- (instancetype)initWithConfiguration:(ANAdWebViewControllerConfiguration *)configuration {
    if (self = [super init]) {
        if (configuration) {
            _configuration = [configuration copy];
        } else {
            _configuration = [[ANAdWebViewControllerConfiguration alloc] init];
        }
    }
    return self;
}


- (instancetype)initWithSize:(CGSize)size
                         URL:(NSURL *)URL
              webViewBaseURL:(NSURL *)baseURL {
    self = [self initWithSize:size
                          URL:URL
               webViewBaseURL:baseURL
                configuration:nil];
    return self;

}

- (instancetype)initWithSize:(CGSize)size
                         URL:(NSURL *)URL
              webViewBaseURL:(NSURL *)baseURL
               configuration:(ANAdWebViewControllerConfiguration *)configuration {
    if (self = [self initWithConfiguration:configuration]) {
        [self loadLegacyWebViewWithSize:size
                                    URL:URL
                                baseURL:baseURL];
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)size
                        HTML:(NSString *)html
              webViewBaseURL:(NSURL *)baseURL {
    self = [self initWithSize:size
                         HTML:html
               webViewBaseURL:baseURL
                configuration:nil];
    return self;
}

- (instancetype)initWithSize:(CGSize)size
                        HTML:(NSString *)html
              webViewBaseURL:(NSURL *)baseURL
               configuration:(ANAdWebViewControllerConfiguration *)configuration {
    if (self = [self initWithConfiguration:configuration]) {
        NSRange mraidJSRange = [html rangeOfString:kANWebViewControllerMraidJSFilename];
        _isMRAID = (mraidJSRange.location != NSNotFound);
        NSURL *base = baseURL;
        if (!base) {
            base = [NSURL URLWithString:AN_BASE_URL];
        }
        NSString *htmlWithScripts = [[self class] prependScriptsToHTML:html];
        [self loadLegacyWebViewWithSize:size
                                   HTML:htmlWithScripts
                                baseURL:base];
    }
    return self;
}

#pragma mark - Scripts

+ (NSString *)mraidHTML {
    return [NSString stringWithFormat:@"<script type=\"text/javascript\">%@</script>",
            [[self class] mraidJS]];
}

+ (NSString *)anjamHTML {
    return [NSString stringWithFormat:@"<script type=\"text/javascript\">%@</script>",
            [[self class] anjamJS]];
}

+ (NSString *)mraidJS {
    NSString *mraidPath = ANMRAIDBundlePath();
    if (!mraidPath) {
        return @"";
    }
    NSBundle *mraidBundle = [[NSBundle alloc] initWithPath:mraidPath];
    NSData *data = [NSData dataWithContentsOfFile:[mraidBundle pathForResource:@"mraid" ofType:@"js"]];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSString *)anjamJS {
    NSString *sdkjsPath = ANPathForANResource(@"sdkjs", @"js");
    NSString *anjamPath = ANPathForANResource(@"anjam", @"js");
    if (!sdkjsPath || !anjamPath) {
        return @"";
    }
    NSData *sdkjsData = [NSData dataWithContentsOfFile:sdkjsPath];
    NSData *anjamData = [NSData dataWithContentsOfFile:anjamPath];
    NSString *sdkjs = [[NSString alloc] initWithData:sdkjsData encoding:NSUTF8StringEncoding];
    NSString *anjam  = [[NSString alloc] initWithData:anjamData encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"%@ %@", sdkjs, anjam];
}

+ (NSString *)prependViewportToHTML:(NSString *)html {
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
    webView.allowsInlineMediaPlayback = YES;
    webView.mediaPlaybackRequiresUserAction = NO;
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
    [NSURLConnection sendAsynchronousRequest:ANBasicRequestWithURL(URL)
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               UIWebView *strongWebView = weakWebView;
                               if (strongWebView) {
                                   NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   if (html.length) {
                                       NSString *htmlWithScripts = [[self class] prependScriptsToHTML:html];
                                       [strongWebView loadHTMLString:htmlWithScripts baseURL:baseURL];
                                   }
                               }
                           }];
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

# pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView an_removeDocumentPadding];
    [self processWebViewDidFinishLoad];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *URL = [request URL];
    NSURL *mainDocumentURL = [request mainDocumentURL];
    NSString *scheme = [URL scheme];
    
    if ([scheme isEqualToString:@"anwebconsole"]) {
        [self printConsoleLogWithURL:URL];
        return NO;
    }

    ANLogDebug(@"Loading URL: %@", [[URL absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);

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

# pragma mark - MRAID

- (void)processWebViewDidFinishLoad {
    if (!self.completedFirstLoad) {
        self.completedFirstLoad = YES;
        [self.loadingDelegate didCompleteFirstLoadFromWebViewController:self];
        if (self.isMRAID) {
            [self finishMRAIDLoad];
        }
    }
}

- (void)finishMRAIDLoad {
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
    [self updateWebViewOnPositionAndVisibilityStatus];
    if (self.configuration.initialMRAIDState == ANMRAIDStateExpanded || self.configuration.initialMRAIDState == ANMRAIDStateResized) {
        [self setupRapidTimerForCheckingPositionAndViewability];
        self.rapidTimerSet = YES;
    } else {
        [self setupTimerForCheckingPositionAndVisibility];
    }
    [self setupApplicationDidEnterBackgroundNotification];
    [self setupOrientationChangeNotification];
    
    if ([self.adViewDelegate adType]) {
        [self fireJavaScript:[ANMRAIDJavascriptUtil placementType:[self.adViewDelegate adType]]];
    }
    [self fireJavaScript:[ANMRAIDJavascriptUtil stateChange:self.configuration.initialMRAIDState]];
    [self fireJavaScript:[ANMRAIDJavascriptUtil readyEvent]];
}

- (void)setupApplicationDidEnterBackgroundNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
}

- (void)handleApplicationDidEnterBackground:(NSNotification *)notification {
    self.viewable = NO;
    [self fireJavaScript:[ANMRAIDJavascriptUtil isViewable:NO]];
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

- (void)setupTimerForCheckingPositionAndVisibility {
    ANLogDebug(@"%@", NSStringFromSelector(_cmd));
    if (self.viewabilityTimer) {
        [self.viewabilityTimer invalidate];
    }
    __weak ANAdWebViewController *weakSelf = self;
    self.viewabilityTimer = [NSTimer an_scheduledTimerWithTimeInterval:kAppNexusMRAIDCheckViewableFrequency
                                                                 block:^ {
                                                                     ANAdWebViewController *strongSelf = weakSelf;
                                                                     [strongSelf updateWebViewOnPositionAndVisibilityStatus];
                                                                 }
                                                               repeats:YES];
}

- (void)setupRapidTimerForCheckingPositionAndViewability {
    ANLogDebug(@"%@", NSStringFromSelector(_cmd));
    if (self.viewabilityTimer) {
        [self.viewabilityTimer invalidate];
    }
    __weak ANAdWebViewController *weakSelf = self;
    self.viewabilityTimer = [NSTimer an_scheduledTimerWithTimeInterval:0.1
                                                                 block:^ {
                                                                     ANAdWebViewController *strongSelf = weakSelf;
                                                                     [strongSelf updateWebViewOnPositionAndVisibilityStatus];
                                                                 }
                                                               repeats:YES];
}

- (void)updateWebViewOnPositionAndVisibilityStatus {
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
    
    BOOL isCurrentlyViewable = [self.mraidDelegate isViewable];
    if (self.isViewable != isCurrentlyViewable) {
        ANLogDebug(@"Viewable change: %d", isCurrentlyViewable);
        self.viewable = isCurrentlyViewable;
        [self fireJavaScript:[ANMRAIDJavascriptUtil isViewable:self.isViewable]];
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

- (void)stopWebViewLoadForDealloc {
#if kANAdWebViewControllerWebKitEnabled
    if (self.modernWebView) {
        [self.modernWebView stopLoading];
        self.modernWebView.navigationDelegate = nil;
    } else
#endif
    {
        [self.legacyWebView loadHTMLString:@""
                                   baseURL:nil];
        [self.legacyWebView stopLoading];
        self.legacyWebView.delegate = nil;
        [self.legacyWebView an_removeSubviews];
        [self.legacyWebView removeFromSuperview];
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

- (void)forwardExpandRequestWithQueryComponents:(NSDictionary *)queryComponents  {
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
    NSString *decodedString = [[URL absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ANLogDebug(@"%@", decodedString);
}

- (void)dealloc {
    [self stopWebViewLoadForDealloc];
    [self.viewabilityTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ANAdViewInternalDelegate

- (void)setAdViewDelegate:(id<ANAdViewInternalDelegate>)adViewDelegate {
    _adViewDelegate = adViewDelegate;
    if (_adViewDelegate) {
        [self fireJavaScript:[ANMRAIDJavascriptUtil placementType:[_adViewDelegate adType]]];
    }
}

@end

#pragma mark - ANAdWebViewControllerConfiguration Implementation

@implementation ANAdWebViewControllerConfiguration

- (instancetype)init {
    if (self = [super init]) {
        _scrollingEnabled = NO;
        _navigationTriggersDefaultBrowser = YES;
        _initialMRAIDState = ANMRAIDStateDefault;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ANAdWebViewControllerConfiguration *configurationCopy = [[ANAdWebViewControllerConfiguration alloc] init];
    configurationCopy.scrollingEnabled = self.scrollingEnabled;
    configurationCopy.navigationTriggersDefaultBrowser = self.navigationTriggersDefaultBrowser;
    configurationCopy.initialMRAIDState = self.initialMRAIDState;
    return configurationCopy;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(scrollingEnabled: %d, navigationTriggersDefaultBrowser: %d, initialMRAIDState: %lu",
            self.scrollingEnabled, self.navigationTriggersDefaultBrowser, (long unsigned)self.initialMRAIDState];
}

@end
