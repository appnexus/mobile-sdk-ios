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




@interface ANVideoAdPlayer ()<ANBrowserViewControllerDelegate>

    @property (strong,nonatomic)              WKWebView                *webView;
    @property (nonatomic, readwrite, strong)  ANBrowserViewController  *browserViewController;
    @property (nonatomic, strong)             NSString                 *vastContent;
    @property (nonatomic, strong)             NSString                 *vastURL;
    @property  (nonatomic, strong)            NSString                 *jsonContent;

    @property (nonatomic, readonly)  BOOL  opensInNativeBrowser;
    @property (nonatomic, readonly)  BOOL  landingPageLoadsInBackground;

@end




@implementation ANVideoAdPlayer

#pragma mark - Lifecycle.

-(instancetype) init
{
    self = [super init];
    if (!self)  { return nil; }

    //
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(resumeAdVideo)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) removePlayer{
    if(self.webView != nil){
        [self.webView setNavigationDelegate:nil];
        [self.webView setUIDelegate:nil];
        [self.webView removeFromSuperview];
        self.webView = nil;
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

- (BOOL) opensInNativeBrowser
{
    BOOL  returnVal  = NO;

    if ([self.delegate respondsToSelector:@selector(videoAdPlayerOpensInNativeBrowser)])  {
        returnVal = [self.delegate videoAdPlayerOpensInNativeBrowser];
    }

    return  returnVal;
}


#pragma mark - Public methods.

-(void) loadAdWithVastContent:(NSString *) vastContent{
    self.vastContent = vastContent;
    [self createVideoPlayer];
}

-(void) loadAdWithVastUrl:(NSString *) vastUrl {
    self.vastURL = vastUrl;
    [self createVideoPlayer];
}

-(void) loadAdWithJSONContent:(NSString *) jsonContent{
    self.jsonContent = jsonContent;
    [self createVideoPlayer];
}


-(void)playAdWithContainer:(UIView *) containerView
{
    if (!containerView)
    {
        if([self.delegate respondsToSelector:@selector(videoAdError:)]){
            NSError *error = ANError(@"containerView is nil.", ANAdResponseInternalError);
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

    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    //provide the width & height of the webview else the video wont be displayed ********
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,0,325,275) configuration:configuration];   //XXX
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


- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString *data = (NSString*)message.body;
    ANLogInfo(@"Parsed value %@",data);

    if ([data isEqualToString:@"video-complete"]) {
        ANLogInfo(@"video-complete");
        if ([self.delegate respondsToSelector:@selector(videoAdImpressionListeners:)]) {
            [self.delegate videoAdImpressionListeners:ANVideoAdPlayerTrackerFourthQuartile];
        }

    } else if ([data isEqualToString:@"adReady"]) {
        ANLogInfo(@"adReady");
        if ([self.delegate respondsToSelector:@selector(videoAdReady)]) {
            [self.delegate videoAdReady];
        }

    }else if ([data isEqualToString:@"video-first-quartile"]) {
        ANLogInfo(@"video-first-quartile");
        if ([self.delegate respondsToSelector:@selector(videoAdImpressionListeners:)]) {
            [self.delegate videoAdImpressionListeners:ANVideoAdPlayerTrackerFirstQuartile];
        }
    }else if ([data isEqualToString:@"video-mid"]) {
        ANLogInfo(@"video-mid");
        if ([self.delegate respondsToSelector:@selector(videoAdImpressionListeners:)]) {
            [self.delegate videoAdImpressionListeners:ANVideoAdPlayerTrackerMidQuartile];
        }

    }else if ([data isEqualToString:@"video-third-quartile"]) {
        ANLogInfo(@"video-third-quartile");
        if ([self.delegate respondsToSelector:@selector(videoAdImpressionListeners:)]) {
            [self.delegate videoAdImpressionListeners:ANVideoAdPlayerTrackerThirdQuartile];
        }
    }

    else if ([data isEqualToString:@"video-skip"]) {
        ANLogInfo(@"video-skip");
        if ([self.delegate respondsToSelector:@selector(videoAdEventListeners:)]) {
            [self.webView removeFromSuperview];
            [self.delegate videoAdEventListeners:ANVideoAdPlayerEventSkip];
        }
    }

    else if([data isEqualToString:@"video-fullscreen"] || [data isEqualToString:@"video-fullscreen-enter"]){
        ANLogInfo(@"video-fullscreen");
        if ([self.delegate respondsToSelector:@selector(videoAdPlayerFullScreenEntered:)]) {
            [self.delegate videoAdPlayerFullScreenEntered:self];

        }
    }
    else if([data isEqualToString:@"video-fullscreen-exit"]){
        ANLogInfo(@"video-fullscreen-exit");
        if ([self.delegate respondsToSelector:@selector(videoAdPlayerFullScreenExited:)]) {
            [self.delegate videoAdPlayerFullScreenExited:self];

        }
    }
    else if([data isEqualToString:@"video-error"] || [data isEqualToString:@"Timed-out"]){
        
        //we need to remove the webview to makesure we dont get any other response from the loaded index.html page
        [self removePlayer];
        ANLogInfo(@"video player error");
        if([self.delegate respondsToSelector:@selector(videoAdLoadFailed:)]){
            NSError *error = ANError(@"Timeout reached while parsing VAST", ANAdResponseInternalError);
            [self.delegate videoAdLoadFailed:error];
        }
    }
    else if([data isEqualToString:@"audio-mute"]){
        ANLogInfo(@"video player mute");
        if ([self.delegate respondsToSelector:@selector(videoAdEventListeners:)]) {
            [self.delegate videoAdEventListeners:ANVideoAdPlayerEventMuteOn];
        }
    }
    else if ([data isEqualToString:@"audio-unmute"]){
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
        if (!navigationAction.targetFrame.isMainFrame)
        {
            NSString *urlString = [[navigationAction.request URL] absoluteString];
            
            if ([self.delegate respondsToSelector:@selector(videoAdEventListeners:)]) {
                [self.delegate videoAdEventListeners:ANVideoAdPlayerEventClick];
            }

            if (self.opensInNativeBrowser)
            {
                if (self.delegate && [self.delegate respondsToSelector:@selector(videoAdWillLeaveApplication:)])  {
                    [self.delegate videoAdWillLeaveApplication:self];
                }

                [ANGlobal openURL:urlString];

            } else {
                if (!self.browserViewController) {
                    self.browserViewController = [[ANBrowserViewController alloc] initWithURL: [NSURL URLWithString:urlString]
                                                                                     delegate: self
                                                                     delayPresentationForLoad: self.landingPageLoadsInBackground ];

                    if (!self.browserViewController) {
                        if([self.delegate respondsToSelector:@selector(videoAdError:)]){
                            NSError *error = ANError(@"ANBrowserViewController initialization FAILED.", ANAdResponseInternalError);
                            [self.delegate videoAdError:error];
                        }
                    }

                } else {
                    [self.browserViewController setUrl:[NSURL URLWithString:urlString]];
                }
            }
        }
    
        return nil;
}

    
-(void) webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    ANLogInfo(@"web page loading started");
    
}

- (void) webView: (WKWebView *) webView didFinishNavigation: (WKNavigation *) navigation
{
    NSString *exec = @"";
    if([self.vastContent length] > 0){
        NSString *exec_template = @"createVastPlayerWithContent('%@');";
        exec = [NSString stringWithFormat:exec_template, self.vastContent];
        [_webView evaluateJavaScript:exec completionHandler:nil];

    }else if([self.vastURL length] > 0){
        NSString *exec_template = @"createVastPlayerWithURL('%@');";
        exec = [NSString stringWithFormat:exec_template, self.vastURL];
        [_webView evaluateJavaScript:exec completionHandler:nil];
    }else if([self.jsonContent length] > 0){
        NSString * mediationJsonString = [NSString stringWithFormat:@"processMediationAd('%@')",[self.jsonContent stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
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

    if ([self.delegate respondsToSelector:@selector(videoAdDidClose:)]) {
        [self.delegate videoAdDidClose:self];
    }


    //
    [self resumeAdVideo];
}


- (void)willLeaveApplicationFromBrowserViewController:(ANBrowserViewController *)controller
{
ANLogTrace(@"UNUSED.");
}

#pragma mark - ANWebConsole

- (void)printConsoleLogWithURL:(NSURL *)URL {
    NSString *decodedString = [[URL absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ANLogDebug(@"%@", decodedString);
}


@end

