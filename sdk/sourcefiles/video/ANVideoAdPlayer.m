/*   Copyright 2016 APPNEXUS INC
 
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

#import "ANVideoAdPlayer.h"
#import "ANLogging.h"
#import "ANBrowserViewController.h"
#import "ANGlobal.h"
#import "UIView+ANCategory.h"
#import "ANAdConstants.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "ANOMIDImplementation.h"
#import "ANVideoPlayerSettings.h"
#import "ANVideoPlayerSettings+ANCategory.h"
#import "ANAdResponseCode.h"
static NSTimeInterval const kANWebviewNilDelayInSeconds = 0.5;

@interface ANVideoAdPlayer ()<ANBrowserViewControllerDelegate>

@property (strong,nonatomic)              WKWebView                *webView;
@property (nonatomic, readwrite, strong)  ANBrowserViewController  *browserViewController;
@property (nonatomic, strong)             NSString                 *vastContent;
@property (nonatomic, strong)             NSString                 *vastURL;
@property (nonatomic, strong)             NSString                 *jsonContent;
@property (nonatomic, strong)             NSString                 *creativeURL;
@property (nonatomic, assign)             NSUInteger                videoDuration;
@property (nonatomic, strong)             NSString                 *vastURLContent;
@property (nonatomic, strong)             NSString                 *vastXMLContent;
@property (nonatomic, readwrite, assign)  ANVideoOrientation  videoAdOrientation;

@property (nonatomic, readonly)  ANClickThroughAction   clickThroughAction;
@property (nonatomic, readonly)  BOOL                   landingPageLoadsInBackground;

@end




@implementation ANVideoAdPlayer

#pragma mark - Lifecycle.

-(instancetype) init
{
    self = [super init];
    if (!self)  { return nil; }
    _creativeURL = @"";
    _videoDuration = 0;
    _vastURLContent = @"";
    _vastXMLContent = @"";
    _videoAdOrientation     = ANUnknown;
    return self;
}

- (void) dealloc
{
    [self deregisterObserver];
}

-(void) registerObserver{
    [self deregisterObserver];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(resumeAdVideo)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(pauseAdVideo)
                                                name:UIApplicationWillResignActiveNotification
                                              object:nil];
}

-(void) deregisterObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) removePlayer{
    if(self.webView != nil){
        WKUserContentController *controller = self.webView.configuration.userContentController;
        [controller removeScriptMessageHandlerForName:@"observe"];
        [controller removeScriptMessageHandlerForName:@"interOp"];
        [self.webView setNavigationDelegate:nil];
        [self.webView setUIDelegate:nil];
        [self.webView removeFromSuperview];
        [self stopOMIDAdSession];
        
        // Delay is added to allow completion tracker to be fired successfully.
        // Setting up webView to nil immediately without adding any delay can cause failure of tracker
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kANWebviewNilDelayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if(self.webView != nil){
                self.webView = nil;
            }
        });
    }
}

- (void)stopOMIDAdSession {
    if(self.omidAdSession != nil){
        [[ANOMIDImplementation sharedInstance] stopOMIDAdSession:self.omidAdSession];
        self.omidAdSession = nil;
    }
}


#pragma mark - Getters/Setters.

- (BOOL) landingPageLoadsInBackground
{
    BOOL returnVal = YES;
    
    if ([self.delegate respondsToSelector:@selector(videoAdPlayerLandingPageLoadsInBackground)]) {
        returnVal = [self.delegate videoAdPlayerLandingPageLoadsInBackground];
    }
    
    return returnVal;
}

- (ANClickThroughAction) clickThroughAction
{
    ANClickThroughAction  returnVal  = NO;
    
    if ([self.delegate respondsToSelector:@selector(videoAdPlayerClickThroughAction)])  {
        returnVal = [self.delegate videoAdPlayerClickThroughAction];
    }
    
    return  returnVal;
}

- (ANVideoOrientation) getVideoOrientation {
    return _videoAdOrientation;
}


#pragma mark - Public methods.

-(void) loadAdWithVastContent:(nonnull NSString *) vastContent{
    //Encode videoXML to Base64String
     self.vastContent = [[vastContent dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    [self createVideoPlayer];
}

-(void) loadAdWithVastUrl:(nonnull NSString *) vastUrl {
    self.vastURL = vastUrl;
    [self createVideoPlayer];
}

-(void) loadAdWithJSONContent:(nonnull NSString *) jsonContent{
    self.jsonContent = jsonContent;
    [self createVideoPlayer];
}


-(void)playAdWithContainer:(nonnull UIView *) containerView
{
    if (!containerView)
    {
        if([self.delegate respondsToSelector:@selector(videoAdError:)]){
            NSError *error = ANError(@"containerView is nil.", ANAdResponseCode.INTERNAL_ERROR.code);
            [self.delegate videoAdError:error];
        }
        
        return;
    }
    
    
    //
    [self.webView removeFromSuperview];
    
    [self.webView setHidden:false];
    [containerView addSubview:self.webView];
    
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.webView an_constrainToSizeOfSuperview];
    [self.webView an_alignToSuperviewWithXAttribute:NSLayoutAttributeLeft yAttribute:NSLayoutAttributeTop];
    
    
    //
    NSString *exec = @"playAd();";
    [self.webView evaluateJavaScript:exec completionHandler:nil];
}

- (NSUInteger) getAdDuration {
    return self.videoDuration;
}
- (nullable NSString *) getCreativeURL {
    return self.creativeURL;
}

- (nullable NSString *) getVASTURL {
    return self.vastURLContent;
}

- (nullable NSString *) getVASTXML {
    return self.vastXMLContent;
}

-(NSUInteger) getAdPlayElapsedTime {
    NSString *exec_template = @"getCurrentPlayHeadTime();";
    NSString *returnString = [_webView stringByEvaluatingJavaScriptFromString:exec_template];
    return [returnString integerValue];
}



#pragma mark - Helper methods.

- (void) createVideoPlayer
{
    NSURL *url = [[[ANSDKSettings sharedInstance] baseUrlConfig] videoWebViewUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];//Creating a WKWebViewConfiguration object so a controller can be added to it.
    
    WKUserContentController *controller = [[WKUserContentController alloc] init];//Creating the WKUserContentController.
    [controller addScriptMessageHandler:self name:@"observe"];//Adding a script handler to the controller and setting the userContentController property on the configuration.
    configuration.userContentController = controller;
    configuration.allowsInlineMediaPlayback = YES;
    
    //this configuration setting has no effect on our vast videoplayer
    //configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    [configuration.userContentController addScriptMessageHandler:self name:@"interOp"];
    
    // Set HttpCookie for Webview
    [ANGlobal setWebViewCookie:self.webView];
 
    UIWindow *currentWindow = [ANGlobal getKeyWindow];
    //provide the width & height of the webview else the video wont be displayed ********
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,0,325,275) configuration:configuration];
    self.webView.scrollView.scrollEnabled = false;
    
    ANLogInfo(@"width = %f, height = %f", self.webView.frame.size.width, self.webView.frame.size.height);
    
    [self.webView setNavigationDelegate:self];
    [self.webView setUIDelegate:self];
    self.webView.opaque = false;
    self.webView.backgroundColor = [UIColor blackColor];
    
    
    [self.webView loadRequest:request];//Load up webView with the url and add it to the view.
    
    [currentWindow addSubview:self.webView];
    [self.webView setHidden:true];
    
}


-(void)resumeAdVideo{
    NSString *exec = @"playAd();";
    [self.webView evaluateJavaScript:exec completionHandler:nil];
}

-(void)pauseAdVideo{
    NSString *exec = @"pauseAd();";
    [self.webView evaluateJavaScript:exec completionHandler:nil];
}


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if(message == nil)
        return;
    NSString *eventName = @"";
    NSDictionary *paramsDictionary = [NSDictionary new];
    
    if([message.body isKindOfClass:[NSString class]]){
        eventName = (NSString *)message.body;
    }
    else if([message.body isKindOfClass:[NSDictionary class]]){
        NSDictionary *messageDictionary = (NSDictionary *)message.body;
        if(messageDictionary.count > 0){
            eventName = [messageDictionary objectForKey:@"event"];
            paramsDictionary = [messageDictionary objectForKey:@"params"];
        }
    }
    
    ANLogInfo(@"Parsed value %@",eventName);
    
    if ([eventName isEqualToString:@"video-complete"]) {
        ANLogInfo(@"video-complete");
        [self stopOMIDAdSession];
        if ([self.delegate respondsToSelector:@selector(videoAdImpressionListeners:)]) {
            [self.delegate videoAdImpressionListeners:ANVideoAdPlayerTrackerFourthQuartile];
        }
        
    } else if ([eventName isEqualToString:@"adReady"]) {
        ANLogInfo(@"adReady");
        self.omidAdSession = [[ANOMIDImplementation sharedInstance] createOMIDAdSessionforWebView:self.webView isVideoAd:true];
        if(paramsDictionary.count > 0){
            self.creativeURL = (NSString *)[paramsDictionary objectForKey:@"creativeUrl"];
            NSNumber *duration = [paramsDictionary objectForKey:@"duration"];
            self.vastURLContent = (NSString *)[paramsDictionary objectForKey:@"vastCreativeUrl"];
            self.vastXMLContent = (NSString *)[paramsDictionary objectForKey:@"vastXML"];
            self.videoAdOrientation = [ANGlobal parseVideoOrientation:[paramsDictionary objectForKey:kANAspectRatio]];
            if(duration > 0){
                self.videoDuration = [duration intValue];
            }
        }
        if ([self.delegate respondsToSelector:@selector(videoAdReady)]) {
            [self.delegate videoAdReady];
        }
        
    } else if ([eventName isEqualToString:@"videoStart"]) {
        ANLogInfo(@"%@", eventName);
        [self registerObserver];
        if ([self.delegate respondsToSelector:@selector(videoAdEventListeners:)]) {
            [self.delegate videoAdEventListeners:ANVideoAdPlayerEventPlay];
        }
        
    } else if ([eventName isEqualToString:@"video-first-quartile"]) {
        ANLogInfo(@"video-first-quartile");
        if ([self.delegate respondsToSelector:@selector(videoAdImpressionListeners:)]) {
            [self.delegate videoAdImpressionListeners:ANVideoAdPlayerTrackerFirstQuartile];
        }
    }else if ([eventName isEqualToString:@"video-mid"]) {
        ANLogInfo(@"video-mid");
        if ([self.delegate respondsToSelector:@selector(videoAdImpressionListeners:)]) {
            [self.delegate videoAdImpressionListeners:ANVideoAdPlayerTrackerMidQuartile];
        }
        
    }else if ([eventName isEqualToString:@"video-third-quartile"]) {
        ANLogInfo(@"video-third-quartile");
        if ([self.delegate respondsToSelector:@selector(videoAdImpressionListeners:)]) {
            [self.delegate videoAdImpressionListeners:ANVideoAdPlayerTrackerThirdQuartile];
        }
    }
    
    else if ([eventName isEqualToString:@"video-skip"]) {
        ANLogInfo(@"video-skip");
        [self stopOMIDAdSession];
        if ([self.delegate respondsToSelector:@selector(videoAdEventListeners:)]) {
            [self.webView removeFromSuperview];
            [self.delegate videoAdEventListeners:ANVideoAdPlayerEventSkip];
        }
    }
    
    else if([eventName isEqualToString:@"video-fullscreen"] || [eventName isEqualToString:@"video-fullscreen-enter"]){
        ANLogInfo(@"video-fullscreen");
        if ([self.delegate respondsToSelector:@selector(videoAdPlayerFullScreenEntered:)]) {
            [self.delegate videoAdPlayerFullScreenEntered:self];
            
        }
    }
    else if([eventName isEqualToString:@"video-fullscreen-exit"]){
        ANLogInfo(@"video-fullscreen-exit");
        if ([self.delegate respondsToSelector:@selector(videoAdPlayerFullScreenExited:)]) {
            [self.delegate videoAdPlayerFullScreenExited:self];
            
        }
    }
    else if([eventName isEqualToString:@"video-error"] || [eventName isEqualToString:@"Timed-out"]){
        
        //we need to remove the webview to makesure we dont get any other response from the loaded index.html page
        [self removePlayer];
        ANLogInfo(@"video player error");
        if([self.delegate respondsToSelector:@selector(videoAdLoadFailed:withAdResponseInfo:)]){
            NSError *error = ANError(@"Timeout reached while parsing VAST", ANAdResponseCode.INTERNAL_ERROR.code);
            [self.delegate videoAdLoadFailed:error withAdResponseInfo:nil];
        }
    }
    else if([eventName isEqualToString:@"audio-mute"]){
        ANLogInfo(@"video player mute");
        if ([self.delegate respondsToSelector:@selector(videoAdEventListeners:)]) {
            [self.delegate videoAdEventListeners:ANVideoAdPlayerEventMuteOn];
        }
    }
    else if ([eventName isEqualToString:@"audio-unmute"]){
        ANLogInfo(@"video player unmute");
        if ([self.delegate respondsToSelector:@selector(videoAdEventListeners:)]) {
            [self.delegate videoAdEventListeners:ANVideoAdPlayerEventMuteOff];
        }
    }
}

#pragma mark - WKNavigationDelegate.


- (WKWebView *)         webView: (WKWebView *)webView
 createWebViewWithConfiguration: (nonnull WKWebViewConfiguration *)inConfig
            forNavigationAction: (nonnull WKNavigationAction *)navigationAction
                 windowFeatures: (nonnull WKWindowFeatures *)windowFeatures
{
    if (navigationAction.targetFrame.isMainFrame)  { return nil; }
    
    //
    NSString *urlString = [[navigationAction.request URL] absoluteString];
    
    
    if (ANClickThroughActionReturnURL != self.clickThroughAction) {
        if ([self.delegate respondsToSelector:@selector(videoAdWasClicked)]) {
            [self.delegate videoAdWasClicked];
        }
    }
    
    switch (self.clickThroughAction) {
        case ANClickThroughActionReturnURL:
            [self resumeAdVideo];
            
            if ([self.delegate respondsToSelector:@selector(videoAdWasClickedWithURL:)]) {
                [self.delegate videoAdWasClickedWithURL:urlString];
            }
            
            ANLogDebug(@"ClickThroughURL=%@", urlString);
            break;
            
        case ANClickThroughActionOpenDeviceBrowser:
            if ([self.delegate respondsToSelector:@selector(videoAdWillLeaveApplication:)])  {
                [self.delegate videoAdWillLeaveApplication:self];
            }
            
            [ANGlobal openURL:urlString];
            break;
            
        case ANClickThroughActionOpenSDKBrowser:
            if (!self.browserViewController) {
                self.browserViewController = [[ANBrowserViewController alloc] initWithURL: [NSURL URLWithString:urlString]
                                                                                 delegate: self
                                                                 delayPresentationForLoad: self.landingPageLoadsInBackground ];
                
                if (!self.browserViewController) {
                    if([self.delegate respondsToSelector:@selector(videoAdError:)]){
                        NSError *error = ANError(@"ANBrowserViewController initialization FAILED.", ANAdResponseCode.INTERNAL_ERROR.code);
                        [self.delegate videoAdError:error];
                    }
                }
                
            } else {
                [self.browserViewController setUrl:[NSURL URLWithString:urlString]];
            }
            
            break;
            
        default:
            ANLogError(@"UNKNOWN ANClickThroughAction.  (%lu)", (unsigned long)self.clickThroughAction);
    }
    
    //
    return nil;
}


-(void) webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    ANLogInfo(@"web page loading started");
    
}

- (void) webView: (WKWebView *) webView didFinishNavigation: (WKNavigation *) navigation
{
    NSString *exec = @"";
    if([self.vastContent length] > 0){
        
        NSString *videoOptions = [[ANVideoPlayerSettings sharedInstance] fetchInStreamVideoSettings];

        NSString *exec_template = @"createVastPlayerWithContent('%@','%@');";
        exec = [NSString stringWithFormat:exec_template, self.vastContent,videoOptions];

        [self.webView evaluateJavaScript:exec completionHandler:nil];
        
    }else if([self.vastURL length] > 0){
        ANLogInfo(@"Not implemented");
    }else if([self.jsonContent length] > 0){
        NSString * mediationJsonString = [NSString stringWithFormat:@"processMediationAd('%@')",[self.jsonContent stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
        [self.webView evaluateJavaScript:mediationJsonString completionHandler:nil];
    }
    ANLogInfo(@"web page loading completed");
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *URL = navigationAction.request.URL;
    NSString *URLScheme = URL.scheme;
    
    if ([URLScheme isEqualToString:@"anwebconsole"]) {
        [self printConsoleLogWithURL:URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}




#pragma mark - ANBrowserViewControllerDelegate.

- (UIViewController *)rootViewControllerForDisplayingBrowserViewController:(ANBrowserViewController *)controller
{
    return [self.webView an_parentViewController] ;
}


- (void)browserViewController:(ANBrowserViewController *)controller
     couldNotHandleInitialURL:(NSURL *)url
{
    ANLogTrace(@"UNUSED.");
}


- (void)browserViewController:(ANBrowserViewController *)controller
             browserIsLoading:(BOOL)isLoading
{
    ANLogTrace(@"UNUSED.");
}


- (void)willPresentBrowserViewController:(ANBrowserViewController *)controller
{
    if ([self.delegate respondsToSelector:@selector(videoAdWillPresent:)]) {
        [self.delegate videoAdWillPresent:self];
    }
}


- (void)didPresentBrowserViewController:(ANBrowserViewController *)controller
{
    if ([self.delegate respondsToSelector:@selector(videoAdDidPresent:)]) {
        [self.delegate videoAdDidPresent:self];
    }
}


- (void)willDismissBrowserViewController:(ANBrowserViewController *)controller
{
    if ([self.delegate respondsToSelector:@selector(videoAdWillClose:)]) {
        [self.delegate videoAdWillClose:self];
    }
}


- (void)didDismissBrowserViewController:(ANBrowserViewController *)controller
{
    self.browserViewController = nil;
    [self resumeAdVideo];
}


- (void)willLeaveApplicationFromBrowserViewController:(ANBrowserViewController *)controller
{
    ANLogTrace(@"UNUSED.");
}

#pragma mark - ANWebConsole

- (void)printConsoleLogWithURL:(NSURL *)URL {
    NSString *decodedString = [[URL absoluteString] stringByRemovingPercentEncoding];
    ANLogDebug(@"%@", decodedString);
}
@end

