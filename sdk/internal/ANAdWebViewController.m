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

#import "ANAdWebViewController.h"

#import "ANAdFetcher.h"
#import "ANANJAMImplementation.h"
#import "ANBrowserViewController.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANPBBuffer.h"
#import "ANWebView.h"
#import "NSString+ANCategory.h"
#import "UIWebView+ANCategory.h"
#import "NSTimer+ANCategory.h"
#import "UIView+ANCategory.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "ANCalendarManager.h"

@interface ANAdFetcher (ANMRAIDAdWebViewController)
@property (nonatomic, readwrite, getter = isLoading) BOOL loading;
@end

@interface ANMRAIDAdWebViewController () <ANCalendarManagerDelegate>
@property (nonatomic, readwrite, assign) BOOL completedFirstLoad;
@property (nonatomic, readwrite, assign) BOOL expanded;
@property (nonatomic, readwrite, assign) BOOL resized;
@property (nonatomic, readwrite, strong) NSTimer *viewabilityTimer;
@property (nonatomic, readwrite) BOOL isViewable;
@property (nonatomic, readwrite) CGRect defaultPosition;
@property (nonatomic, readwrite) CGRect currentPosition;
@property (nonatomic, readwrite, assign) CGPoint resizeOffset;
@property (nonatomic, readwrite, strong) NSMutableArray *pitbullCaptureURLQueue;
@property (nonatomic, readwrite, strong) ANCalendarManager *calendarManager;

- (void)delegateShouldOpenInBrowser:(NSURL *)URL;

@property (nonatomic, readwrite, assign) BOOL isRegisteredForPitbullScreenCaptureNotifications;

@end

@implementation ANMRAIDAdWebViewController

- (void)delegateShouldOpenInBrowser:(NSURL *)URL {
    if ([self.adFetcherDelegate respondsToSelector:@selector(adFetcher:adShouldOpenInBrowserWithURL:)]) {
        [self.adFetcherDelegate adFetcher:self.adFetcher adShouldOpenInBrowserWithURL:URL];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!self.completedFirstLoad) {
		self.adFetcher.loading = NO;
        
        // If this is our first successful load, then send this to the delegate. Otherwise, ignore.
        self.completedFirstLoad = YES;
		
		ANAdResponse *response = [ANAdResponse adResponseSuccessfulWithAdObject:webView];
        [self.adFetcher processFinalResponse:response];

        if (self.isMRAID) [self finishMRAIDLoad:webView];
    }
}

- (void)finishMRAIDLoad:(UIWebView *)webView {
    // set initial values for MRAID getters
    [self setValuesForMRAIDSupportsFunction:webView];
    [self setScreenSizeForMRAIDGetScreenSizeFunction:webView];
    [self setMaxSizeForMRAIDGetMaxSizeFunction:webView];
    
    // setup rotation detection support
    [self processDidChangeStatusBarOrientationNotifications];
    
    // setup viewability support
    [self viewabilitySetup];
    
    [webView setPlacementType:[self.mraidDelegate adType]];
    [webView fireStateChangeEvent:ANMRAIDStateDefault];
    [webView fireReadyEvent];
}

- (void)viewabilitySetup {
    self.isViewable = [self.webView an_isViewable];
    [self.webView setIsViewable:self.isViewable];
    ANLogDebug(@"%@ | viewableChange: isViewable=%d", NSStringFromSelector(_cmd), self.isViewable);
    [self updatePosition];
    if (CGRectEqualToRect(self.currentPosition, CGRectZero)) {
        self.currentPosition = CGRectMake(CGPointZero.x, CGPointZero.y, self.webView.bounds.size.width, self.webView.bounds.size.height);
        self.defaultPosition = self.currentPosition;
        [self.webView fireNewCurrentPositionEvent:self.currentPosition];
        ANLogDebug(@"%@ | current position origin (%d, %d) size %dx%d", NSStringFromSelector(_cmd),
                   (int)self.currentPosition.origin.x, (int)self.currentPosition.origin.y,
                   (int)self.currentPosition.size.width, (int)self.currentPosition.size.height);
        [self.webView setDefaultPosition:self.defaultPosition];
        ANLogDebug(@"%@ | default position origin (%d, %d) size %dx%d", NSStringFromSelector(_cmd),
                   (int)self.defaultPosition.origin.x, (int)self.defaultPosition.origin.y,
                   (int)self.defaultPosition.size.width, (int)self.defaultPosition.size.height);
    }
    
    __weak ANMRAIDAdWebViewController *weakANMRAIDAdWebViewController = self;
    self.viewabilityTimer = [NSTimer scheduledTimerWithTimeInterval:kAppNexusMRAIDCheckViewableFrequency
                                                              block:^ {
                                                                  ANMRAIDAdWebViewController *strongANMRAIDAdWebViewController = weakANMRAIDAdWebViewController;
                                                                  [strongANMRAIDAdWebViewController checkViewability];
                                                              }
                                                            repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
}

- (void)checkViewability {
    BOOL isCurrentlyViewable = [self.webView an_isViewable];
    if (self.isViewable != isCurrentlyViewable) {
        self.isViewable = isCurrentlyViewable;
        [self.webView setIsViewable:self.isViewable];
        ANLogDebug(@"%@ | viewableChange: isViewable=%d", NSStringFromSelector(_cmd), self.isViewable);
    }
    [self updatePosition];
}

- (void)updatePosition {
    if (self.isViewable) {
        CGRect newPosition = [self webViewPositionInWindowCoordinatesForWebView:self.webView];
        if (!CGRectEqualToRect(newPosition, self.currentPosition)) {
            self.currentPosition = newPosition;
            if (!self.expanded) {
                if (self.resized) {
                    self.defaultPosition = CGRectMake(self.currentPosition.origin.x - self.resizeOffset.x, self.currentPosition.origin.y - self.resizeOffset.y,
                                                      self.defaultPosition.size.width, self.defaultPosition.size.height);
                    [self.webView setDefaultPosition:self.defaultPosition];
                } else if (!self.resized && (CGSizeEqualToSize(self.defaultPosition.size, self.currentPosition.size) ||
                            CGRectEqualToRect(self.defaultPosition, CGRectZero))) {
                    self.defaultPosition = self.currentPosition;
                    [self.webView setDefaultPosition:self.defaultPosition];
                }
            }
            [self.webView fireNewCurrentPositionEvent:self.currentPosition];
            ANLogDebug(@"%@ | current position origin (%d, %d) size %dx%d", NSStringFromSelector(_cmd),
                       (int)self.currentPosition.origin.x, (int)self.currentPosition.origin.y,
                       (int)self.currentPosition.size.width, (int)self.currentPosition.size.height);
            ANLogDebug(@"%@ | default position origin (%d, %d) size %dx%d", NSStringFromSelector(_cmd),
                       (int)self.defaultPosition.origin.x, (int)self.defaultPosition.origin.y,
                       (int)self.defaultPosition.size.width, (int)self.defaultPosition.size.height);
        }
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    self.isViewable = NO;
    [self.webView setIsViewable:self.isViewable];
    ANLogDebug(@"%@ | viewableChange: isViewable=%d", NSStringFromSelector(_cmd), self.isViewable);
}

- (void)dealloc {
    [self unregisterFromPitbullScreenCaptureNotifications];
    [self.webView stopLoading];
    self.webView.delegate = nil;
    [self.viewabilityTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)processDidChangeStatusBarOrientationNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRotation:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:[UIApplication sharedApplication]];
}

- (void)handleRotation:(NSNotification *)notification {
    [self setMaxSizeForMRAIDGetMaxSizeFunction:self.webView];
    [self setScreenSizeForMRAIDGetScreenSizeFunction:self.webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *URL = [request URL];
    NSURL *mainDocumentURL = [request mainDocumentURL];
    NSString *scheme = [URL scheme];
    
    if ([scheme isEqualToString:@"anwebconsole"]) {
        [self printConsoleLog:URL];
        return NO;
    }
    
    ANLogDebug(@"Loading URL: %@", [[URL absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    
    if ([scheme isEqualToString:@"appnexuspb"]) {
        if ([self.adFetcherDelegate respondsToSelector:@selector(transitionInProgress)]) {
            if ([URL.host isEqualToString:@"capture"]) {
                NSNumber *transitionInProgress = [self.adFetcherDelegate performSelector:@selector(transitionInProgress)];
                if ([transitionInProgress boolValue] == YES) {
                    if (![self.pitbullCaptureURLQueue count]) {
                        [self registerForPitbullScreenCaptureNotifications];
                    }
                    [self.pitbullCaptureURLQueue addObject:URL];
                    return NO;
                }
            } else if ([URL.host isEqualToString:@"web"]) {
                [self dispatchPitbullScreenCaptureCalls];
                [self unregisterFromPitbullScreenCaptureNotifications];
            }
        }

        UIView *view = self.webView;
        if ([self.adFetcherDelegate respondsToSelector:@selector(containerView)]) {
            view = [self.adFetcherDelegate containerView];
        }
        [ANPBBuffer handleUrl:URL forView:view];
        return NO;
    }
    
    if (self.completedFirstLoad) {
        if (hasHttpPrefix(scheme)) {
            if (self.isMRAID) {
                /*
                 The mainDocumentURL will be equal to the URL whenever a URL has requested to load in a new window/tab,
                 or move away from the existing page. This does not apply for links coming from inside an iFrame unless
                 window.open was explicitly written (even if these links are present inside an <a> tag). The assumption
                 here is that MRAID creatives should be using mraid.open to break out of the ad.
                 */
                
                if ([[mainDocumentURL absoluteString] isEqualToString:[URL absoluteString]]) {
                    [self delegateShouldOpenInBrowser:URL];
                } else {
                    return YES; /* Let the link load in the webView */
                }
            } else {
                /*
                 The mainDocumentURL will be equal to the URL whenever a URL has requested to load in a new window/tab,
                 or move away from the existing page. This does not apply for links coming from inside an iFrame unless
                 window.open was explicitly written (even if these links are present inside an <a> tag). However, the
                 assumption here is that any user clicks should break out of the ad. This fix will catch both <a> tags
                 embedded in iFrames as well as asynchronous loads which occur after the first instance of webViewDidFinishLoad:.
                 Any creatives loading iFrames which desire clicks to continue displaying in the iFrame should be flagged as MRAID.
                 */
                
                if ([[mainDocumentURL absoluteString] isEqualToString:[URL absoluteString]] || navigationType == UIWebViewNavigationTypeLinkClicked) {
                    [self delegateShouldOpenInBrowser:URL];
                } else {
                    return YES; /* Let the link load in the webView */
                }
            }
        } else if ([scheme isEqualToString:@"mraid"]) {
            // Do MRAID actions
            [self dispatchNativeMRAIDURL:URL forWebView:webView];
        } else if ([scheme isEqualToString:@"anjam"]) {
            [ANANJAMImplementation handleUrl:URL forWebView:webView forDelegate:self.adFetcherDelegate];
        } else if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            [[UIApplication sharedApplication] openURL:URL];
        } else {
            ANLogWarn(@"opening_url_failed %@", URL);
        }
        
        return NO;
	} else if ([scheme isEqualToString:@"mraid"] && [[URL host] isEqualToString:@"enable"]) {
        [self dispatchNativeMRAIDURL:URL forWebView:webView];
        return NO;
    }
    
    return YES;
}

- (void)setMaxSizeForMRAIDGetMaxSizeFunction:(UIWebView*) webView{
    UIApplication *application = [UIApplication sharedApplication];
    BOOL orientationIsPortrait = UIInterfaceOrientationIsPortrait([application statusBarOrientation]);
    CGSize screenSize = ANPortraitScreenBounds().size;
    int orientedWidth = orientationIsPortrait ? screenSize.width : screenSize.height;
    int orientedHeight = orientationIsPortrait ? screenSize.height : screenSize.width;
    
    if (!application.statusBarHidden) {
        orientedHeight -= MIN(application.statusBarFrame.size.height, application.statusBarFrame.size.width);
    }

    [webView setMaxSize:CGSizeMake(orientedWidth, orientedHeight)];
}

- (void)setScreenSizeForMRAIDGetScreenSizeFunction:(UIWebView*)webView{
    
    BOOL orientationIsPortrait = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    CGSize screenSize = ANPortraitScreenBounds().size;
    int orientedWidth = orientationIsPortrait ? screenSize.width : screenSize.height;
    int orientedHeight = orientationIsPortrait ? screenSize.height : screenSize.width;
    
    [webView setScreenSize:CGSizeMake(orientedWidth, orientedHeight)];
}

- (CGRect)webViewPositionInWindowCoordinatesForWebView:(UIWebView *)webView {
    CGRect webViewAbsoluteFrame = [webView convertRect:webView.bounds toView:nil];
    CGRect bounds = adjustAbsoluteRectInWindowCoordinatesForOrientationGivenRect(webViewAbsoluteFrame);
    UIApplication *application = [UIApplication sharedApplication];
    if (!application.statusBarHidden) {
        bounds.origin.y -= MIN(application.statusBarFrame.size.height, application.statusBarFrame.size.width);
    }
    return bounds;
}

- (void)setValuesForMRAIDSupportsFunction:(UIWebView*)webView{
    BOOL sms = NO;
    BOOL tel = NO;
    BOOL cal = NO;
    BOOL inline_video = YES;
    BOOL store_picture = YES;
    
#ifdef __IPHONE_4_0
    //SMS
    sms = [MFMessageComposeViewController canSendText];
#else
    sms = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms://"]];
#endif
    //TEL
    tel = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]];
    
    //CAL
    EKEventStore *store = [[EKEventStore alloc] init];
    if ([store respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        cal = YES;
    }
    
    [webView setSupports:@"sms" isSupported:sms];
    [webView setSupports:@"tel" isSupported:tel];
    [webView setSupports:@"calendar" isSupported:cal];
    [webView setSupports:@"inlineVideo" isSupported:inline_video];
    [webView setSupports:@"storePicture" isSupported:store_picture];
}

- (void)dispatchNativeMRAIDURL:(NSURL *)mraidURL forWebView:(UIWebView *)webView {
    NSString *mraidCommand = [mraidURL host];
    NSString *query = [mraidURL query];
    NSDictionary *queryComponents = [query queryComponents];

    if ([mraidCommand isEqualToString:@"expand"]) {
        // hidden state handled by mraid.js
        [self.adFetcherDelegate adWasClicked];
        [self expandAction:webView queryComponents:queryComponents];
    }
    else if ([mraidCommand isEqualToString:@"close"]) {
        // hidden state handled by mraid.js
        [self closeAction:self];
    } else if([mraidCommand isEqualToString:@"resize"]) {
        [self.adFetcherDelegate adWasClicked];
        [self resizeAction:webView queryComponents:queryComponents];
    } else if([mraidCommand isEqualToString:@"createCalendarEvent"]) {
        [self.adFetcherDelegate adWasClicked];
        NSString *w3cEventJson = queryComponents[@"p"];
        [self createCalendarEventFromW3CCompliantJSONObject:w3cEventJson];
    } else if([mraidCommand isEqualToString:@"playVideo"]) {
        [self.adFetcherDelegate adWasClicked];
        [self playVideo:queryComponents];
    } else if([mraidCommand isEqualToString:@"storePicture"]) {
        [self.adFetcherDelegate adWasClicked];
        NSString *uri = queryComponents[@"uri"];
        [self storePicture:uri];
    } else if([mraidCommand isEqualToString:@"setOrientationProperties"]) {
        [self setOrientationProperties:queryComponents];
    } else if([mraidCommand isEqualToString:@"open"]){
        NSString *uri = queryComponents[@"uri"];
        [self open:uri];
    } else if ([mraidCommand isEqualToString:@"enable"]) {
        if (self.isMRAID) return;
        self.isMRAID = YES;
        if (self.completedFirstLoad) [self finishMRAIDLoad:webView];
    }
}

- (void)open:(NSString *)url {
    if ([url length] > 0) {
        [self delegateShouldOpenInBrowser:[NSURL URLWithString:url]];
    }
}

- (ANMRAIDCustomClosePosition)getCustomClosePositionFromString:(NSString *)value {
    // default value is top-right
    ANMRAIDCustomClosePosition position = ANMRAIDTopRight;
    if ([value isEqualToString:@"top-left"]) {
        position = ANMRAIDTopLeft;
    } else if ([value isEqualToString:@"top-center"]) {
        position = ANMRAIDTopCenter;
    } else if ([value isEqualToString:@"top-right"]) {
        position = ANMRAIDTopRight;
    } else if ([value isEqualToString:@"center"]) {
        position = ANMRAIDCenter;
    } else if ([value isEqualToString:@"bottom-left"]) {
        position = ANMRAIDBottomLeft;
    } else if ([value isEqualToString:@"bottom-center"]) {
        position = ANMRAIDBottomCenter;
    } else if ([value isEqualToString:@"bottom-right"]) {
        position = ANMRAIDBottomRight;
    }
    
    return position;
}

- (IBAction)closeAction:(id)sender {
    if (self.expanded || self.resized) {
        [self.mraidDelegate adShouldResetToDefault];
        
        [self.webView fireStateChangeEvent:ANMRAIDStateDefault];
        self.expanded = NO;
        self.resized = NO;
    }
    else {
        // Clear the ad out
        [self.webView setHidden:YES animated:YES];
        self.webView = nil;
    }
}

- (void)setExpanded:(BOOL)expanded {
    if (expanded != _expanded) {
        _expanded = expanded;
        if (_expanded) {
            [self.adFetcher stopAd];
        }
        else {
            [self.adFetcher setupAutoRefreshTimerIfNecessary];
            [self.adFetcher startAutoRefreshTimer];
        }
    }
}

- (void)expandAction:(UIWebView *)webView queryComponents:(NSDictionary *)queryComponents {
    NSInteger expandedHeight = [queryComponents[@"h"] integerValue];
    NSInteger expandedWidth = [queryComponents[@"w"] integerValue];
    NSString *useCustomClose = queryComponents[@"useCustomClose"];
    NSString *url = queryComponents[@"url"];

    [self setOrientationProperties:queryComponents];
    
    BOOL needDefaultCloseButton = ![useCustomClose isEqualToString:@"true"];
    UIButton *closeButton = nil;
    if (needDefaultCloseButton) {
        closeButton = [self expandCloseButton];
    } else {
        closeButton = [self expandCloseButtonForCustomClose];
    }
    
    if (!closeButton) {
        ANLogError(@"Terminating MRAID expand due to invalid close button.");
        return;
    }

    [self.mraidDelegate adShouldExpandToFrame:CGRectMake(0, 0, expandedWidth, expandedHeight)
                                  closeButton:closeButton];
    
    self.expanded = YES;
    
    if ([url length] > 0) {
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
}

- (void)resizeAction:(UIWebView *)webView queryComponents:(NSDictionary *)queryComponents {
    int w = [queryComponents[@"w"] intValue];
    int h = [queryComponents[@"h"] intValue];
    int offsetX = [queryComponents[@"offset_x"] intValue];
    int offsetY = [queryComponents[@"offset_y"] intValue];
    NSString* customClosePosition = queryComponents[@"custom_close_position"];
    BOOL allowOffscreen = [queryComponents[@"allow_offscreen"] boolValue];
    
    ANMRAIDCustomClosePosition closePosition = [self getCustomClosePositionFromString:customClosePosition];
    
    [self.mraidDelegate adShouldResizeToFrame:CGRectMake(offsetX, offsetY, w, h)
                               allowOffscreen:allowOffscreen
                                  closeButton:[self resizeCloseButton]
                                closePosition:closePosition];
    self.resized = YES;
}

- (void)playVideo:(NSDictionary *)queryComponents {
    NSString *uri = queryComponents[@"uri"];
    NSURL *url = [NSURL URLWithString:uri];
    
    MPMoviePlayerViewController *moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    moviePlayerViewController.moviePlayer.fullscreen = YES;
    moviePlayerViewController.moviePlayer.shouldAutoplay = YES;
    moviePlayerViewController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    moviePlayerViewController.moviePlayer.view.frame = ANPortraitScreenBounds();
    moviePlayerViewController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayerViewController.moviePlayer];
    
    [moviePlayerViewController.moviePlayer prepareToPlay];
    [[self.mraidDelegate displayController] presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
    [moviePlayerViewController.moviePlayer play];
}

- (void)moviePlayerDidFinish:(NSNotification *)notification
{
    ANLogInfo(@"Movie Player finished: %@", notification);
}

- (void)createCalendarEventFromW3CCompliantJSONObject:(NSString *)json {
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:kNilOptions
                                                               error:&error];
    if (!error) {
        self.calendarManager = [[ANCalendarManager alloc] initWithCalendarDictionary:jsonDict
                                                                            delegate:self];
    }
}

- (UIViewController *)rootViewControllerForPresentationForCalendarManager:(ANCalendarManager *)calendarManager {
    return [self.mraidDelegate displayController];
}

- (void)setOrientationProperties:(NSDictionary *)queryComponents
{
    NSString *allow = queryComponents[@"allow_orientation_change"];
    NSString *forcedOrientation = queryComponents[@"force_orientation"];
    
    ANMRAIDOrientation mraidOrientation = ANMRAIDOrientationNone;
    if ([forcedOrientation isEqualToString:@"none"]) {
        mraidOrientation = ANMRAIDOrientationNone;
    } else if ([forcedOrientation isEqualToString:@"portrait"]) {
        mraidOrientation = ANMRAIDOrientationPortrait;
    } else if ([forcedOrientation isEqualToString:@"landscape"]) {
        mraidOrientation = ANMRAIDOrientationLandscape;
    }
    
    [self.mraidDelegate allowOrientationChange:[allow boolValue]
                         withForcedOrientation:mraidOrientation];
}

- (void)storePicture:(NSString*)uri
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:uri];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if(data){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [[UIImage alloc] initWithData:data];
                if (image) {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                }
            });
        }
    });
    
}

- (void)printConsoleLog:(NSURL *)URL {
    NSString *decodedString = [[URL absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ANLogDebug(@"%@", decodedString);
}

// expand close button for non-custom close is provided by SDK
- (UIButton *)expandCloseButton {
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton addTarget:self
                    action:@selector(closeAction:)
          forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *closeboxImage = [UIImage imageWithContentsOfFile:ANPathForANResource(@"interstitial_closebox", @"png")];
    if (!closeboxImage) {
        ANLogError(@"Could not create MRAID expand close button.");
        return nil;
    }
    [closeButton setImage:closeboxImage
                 forState:UIControlStateNormal];
    
    UIImage *closeboxDown = [UIImage imageWithContentsOfFile:ANPathForANResource(@"interstitial_closebox_down", @"png")];
    if (closeboxDown) {
        [closeButton setImage:closeboxDown
                     forState:UIControlStateHighlighted];
    }
    
    // setFrame here in order to pass the size dimensions along
    [closeButton setFrame:CGRectMake(0, 0, closeboxImage.size.width, closeboxImage.size.height)];
    return closeButton;
}

- (UIButton *)expandCloseButtonForCustomClose {
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton addTarget:self
                    action:@selector(closeAction:)
          forControlEvents:UIControlEventTouchUpInside];
    [closeButton setFrame:CGRectMake(0, 0, 50.0, 50.0)];
    return closeButton;
}

// resize close button is a transparent region
- (UIButton *)resizeCloseButton {
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton addTarget:self
                    action:@selector(closeAction:)
          forControlEvents:UIControlEventTouchUpInside];
    return closeButton;
}

#pragma mark ANMRAIDEventReceiver

- (void)adDidFinishExpand {
    [self.webView fireStateChangeEvent:ANMRAIDStateExpanded];
}

- (void)adDidFinishResize:(BOOL)success errorString:(NSString *)errorString {
    if (success) {
        [self.webView fireStateChangeEvent:ANMRAIDStateResized];
    } else {
        self.resized = NO;
        [self.webView fireErrorEvent:errorString
                            function:@"mraid.resize()"];
    }
}

- (void)adDidResetToDefault {
    [self.webView fireStateChangeEvent:ANMRAIDStateDefault];
}

- (void)adDidChangeResizeOffset:(CGPoint)offset {
    self.resizeOffset = offset;
}

#pragma mark - Pitbull Image Capture Transition Adjustments

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.adFetcherDelegate) {
        NSNumber *transitionInProgress = change[NSKeyValueChangeNewKey];
        if ([transitionInProgress boolValue] == NO) {
            [self unregisterFromPitbullScreenCaptureNotifications];
            [self dispatchPitbullScreenCaptureCalls];
        }
    }
}

- (void)registerForPitbullScreenCaptureNotifications {
    if (!self.isRegisteredForPitbullScreenCaptureNotifications) {
        NSObject *object = self.adFetcherDelegate;
        [object addObserver:self
                 forKeyPath:@"transitionInProgress"
                    options:NSKeyValueObservingOptionNew
                    context:nil];
        self.isRegisteredForPitbullScreenCaptureNotifications = YES;
    }
}

- (void)unregisterFromPitbullScreenCaptureNotifications {
    NSObject *bannerObject = self.adFetcherDelegate;
    if (self.isRegisteredForPitbullScreenCaptureNotifications) {
        @try {
            [bannerObject removeObserver:self
                              forKeyPath:@"transitionInProgress"];
        }
        @catch (NSException * __unused exception) {}
        self.isRegisteredForPitbullScreenCaptureNotifications = NO;
    }
}

- (void)dispatchPitbullScreenCaptureCalls {
    for (NSURL *URL in self.pitbullCaptureURLQueue) {
        UIView *view = self.webView;
        if ([self.adFetcherDelegate respondsToSelector:@selector(containerView)]) {
            view = [self.adFetcherDelegate containerView];
        }
        [ANPBBuffer handleUrl:URL forView:view];
    }
    self.pitbullCaptureURLQueue = nil;
}

- (NSMutableArray *)pitbullCaptureURLQueue {
    if (!_pitbullCaptureURLQueue) _pitbullCaptureURLQueue = [[NSMutableArray alloc] initWithCapacity:5];
    return _pitbullCaptureURLQueue;
}

@end

