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
#import "ANWebView.h"
#import "NSString+ANCategory.h"
#import "UIWebView+ANCategory.h"
#import "NSTimer+ANCategory.h"

#import <EventKit/EventKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface ANAdFetcher (ANMRAIDAdWebViewController)
@property (nonatomic, readwrite, getter = isLoading) BOOL loading;
@end

@interface ANMRAIDAdWebViewController ()
@property (nonatomic, readwrite, assign) BOOL completedFirstLoad;
@property (nonatomic, readwrite, assign) BOOL expanded;
@property (nonatomic, readwrite, assign) BOOL resized;
@property (nonatomic, readwrite, assign) NSTimer *viewabilityTimer;
@property (nonatomic, readwrite) BOOL isViewable;
@property (nonatomic, readwrite) CGRect defaultPosition;
@property (nonatomic, readwrite) CGRect currentPosition;
@property (nonatomic, readwrite, assign) CGPoint resizeOffset;

- (void)delegateShouldOpenInBrowser:(NSURL *)URL;

@end

@implementation ANMRAIDAdWebViewController

- (void)delegateShouldOpenInBrowser:(NSURL *)URL {
    if ([self.adFetcher.delegate respondsToSelector:@selector(adFetcher:adShouldOpenInBrowserWithURL:)]) {
        [self.adFetcher.delegate adFetcher:self.adFetcher adShouldOpenInBrowserWithURL:URL];
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
    self.isViewable = [self getWebViewVisible];
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
    BOOL isCurrentlyViewable = [self getWebViewVisible];
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
    [self.webView stopLoading];
    self.webView.delegate = nil;
    [self.webView removeFromSuperview];
    [self.viewabilityTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)getWebViewVisible {    
    BOOL isHidden = self.webView.hidden;
    if (isHidden) return NO;
    
    BOOL isAttachedToWindow = self.webView.window ? YES : NO;
    if (!isAttachedToWindow) return NO;
    
    BOOL isInHiddenSuperview = NO;
    UIView *ancestorView = self.webView.superview;
    while (ancestorView) {
        if (ancestorView.hidden) {
            isInHiddenSuperview = YES;
            break;
        }
        ancestorView = ancestorView.superview;
    }
    if (isInHiddenSuperview) return NO;
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGRect newBounds = [self.webView convertRect:self.webView.bounds toView:nil];
    BOOL isOnScreen = CGRectIntersectsRect(newBounds, screenBounds);
    if (!isOnScreen) return NO;

    return YES;
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
            [ANANJAMImplementation handleUrl:URL forWebView:webView forDelegate:self.adFetcher.delegate];
        } else if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            [[UIApplication sharedApplication] openURL:URL];
        } else {
            ANLogWarn([NSString stringWithFormat:ANErrorString(@"opening_url_failed"), URL]);
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
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    int orientedWidth = orientationIsPortrait ? screenSize.width : screenSize.height;
    int orientedHeight = orientationIsPortrait ? screenSize.height : screenSize.width;
    
    if (!application.statusBarHidden) {
        orientedHeight -= MIN(application.statusBarFrame.size.height, application.statusBarFrame.size.width);
    }

    [webView setMaxSize:CGSizeMake(orientedWidth, orientedHeight)];
}

- (void)setScreenSizeForMRAIDGetScreenSizeFunction:(UIWebView*)webView{
    BOOL orientationIsPortrait = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
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
        [self.adFetcher.delegate adWasClicked];
        [self expandAction:webView queryComponents:queryComponents];
    }
    else if ([mraidCommand isEqualToString:@"close"]) {
        // hidden state handled by mraid.js
        [self closeAction:self];
    } else if([mraidCommand isEqualToString:@"resize"]) {
        [self.adFetcher.delegate adWasClicked];
        [self resizeAction:webView queryComponents:queryComponents];
    } else if([mraidCommand isEqualToString:@"createCalendarEvent"]) {
        [self.adFetcher.delegate adWasClicked];
        NSString *w3cEventJson = [queryComponents objectForKey:@"p"];
        [self createCalendarEventFromW3CCompliantJSONObject:w3cEventJson];
    } else if([mraidCommand isEqualToString:@"playVideo"]) {
        [self.adFetcher.delegate adWasClicked];
        [self playVideo:queryComponents];
    } else if([mraidCommand isEqualToString:@"storePicture"]) {
        [self.adFetcher.delegate adWasClicked];
        NSString *uri = [queryComponents objectForKey:@"uri"];
        [self storePicture:uri];
    } else if([mraidCommand isEqualToString:@"setOrientationProperties"]) {
        [self setOrientationProperties:queryComponents];
    } else if([mraidCommand isEqualToString:@"open"]){
        NSString *uri = [queryComponents objectForKey:@"uri"];
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
    NSInteger expandedHeight = [[queryComponents objectForKey:@"h"] integerValue];
    NSInteger expandedWidth = [[queryComponents objectForKey:@"w"] integerValue];
    NSString *useCustomClose = [queryComponents objectForKey:@"useCustomClose"];
    NSString *url = [queryComponents objectForKey:@"url"];

    [self setOrientationProperties:queryComponents];
    
    // If no custom close included, show our default one.
    UIButton *closeButton = [useCustomClose isEqualToString:@"true"] ? nil : [self expandCloseButton];
    
    [self.mraidDelegate adShouldExpandToFrame:CGRectMake(0, 0, expandedWidth, expandedHeight)
                                  closeButton:closeButton];
    
    self.expanded = YES;
    
    if ([url length] > 0) {
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
}

- (void)resizeAction:(UIWebView *)webView queryComponents:(NSDictionary *)queryComponents {
    int w = [[queryComponents objectForKey:@"w"] intValue];
    int h = [[queryComponents objectForKey:@"h"] intValue];
    int offsetX = [[queryComponents objectForKey:@"offset_x"] intValue];
    int offsetY = [[queryComponents objectForKey:@"offset_y"] intValue];
    NSString* customClosePosition = [queryComponents objectForKey:@"custom_close_position"];
    BOOL allowOffscreen = [[queryComponents objectForKey:@"allow_offscreen"] boolValue];
    
    ANMRAIDCustomClosePosition closePosition = [self getCustomClosePositionFromString:customClosePosition];
    
    [self.mraidDelegate adShouldResizeToFrame:CGRectMake(offsetX, offsetY, w, h) allowOffscreen:allowOffscreen closeButton:[self resizeCloseButton] closePosition:closePosition];
    
    self.resized = YES;
}

- (void)playVideo:(NSDictionary *)queryComponents {
    NSString *uri = [queryComponents objectForKey:@"uri"];
    NSURL *url = [NSURL URLWithString:uri];
    
    MPMoviePlayerViewController *moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    moviePlayerViewController.moviePlayer.fullscreen = YES;
    moviePlayerViewController.moviePlayer.shouldAutoplay = YES;
    moviePlayerViewController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    moviePlayerViewController.moviePlayer.view.frame = [[UIScreen mainScreen] bounds];
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

- (void)createCalendarEventFromW3CCompliantJSONObject:(NSString *)json{
    NSError* error;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    ANLogDebug(@"%@ %@ | NSDictionary from JSON Calendar Object: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), jsonDict);
    
    NSString* description = [jsonDict objectForKey:@"description"];
    NSString* location = [jsonDict objectForKey:@"location"];
    NSString* summary = [jsonDict objectForKey:@"summary"];
    NSString* start = [jsonDict objectForKey:@"start"];
    NSString* end = [jsonDict objectForKey:@"end"];
    NSString* status = [jsonDict objectForKey:@"status"];
    /* 
     * iOS Not supported
     * NSString* transparency = [jsonDict objectForKey:@"transparency"];
     */
    NSString* reminder = [jsonDict objectForKey:@"reminder"];
    
    EKEventStore* store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
        if(! granted) {
            if (error != nil) {
                ANLogWarn(error.localizedDescription);
            } else {
                ANLogWarn(@"Unable to create calendar event");
            }
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            EKEvent *event = [EKEvent eventWithEventStore:store];
            NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
            NSDateFormatter *df2 = [[NSDateFormatter alloc] init];
            [df1 setDateFormat:@"yyyy-MM-dd'T'HH:mmZZZ"];
            [df2 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
                
            event.title=description;
            event.notes=summary;
            event.location=location;
            event.calendar = [store defaultCalendarForNewEvents];
            
            if (start) {
                if([df1 dateFromString:start]!=nil){
                    event.startDate = [df1 dateFromString:start];
                }else if([df2 dateFromString:start]!=nil){
                    event.startDate = [df2 dateFromString:start];
                }else{
                    event.startDate = [NSDate dateWithTimeIntervalSince1970:[start doubleValue]];
                }
                
                if([df1 dateFromString:end]!=nil){
                    event.endDate = [df1 dateFromString:end];
                }else if([df2 dateFromString:end]!=nil){
                    event.endDate = [df2 dateFromString:end];
                }else if (end) {
                    event.endDate = [NSDate dateWithTimeIntervalSince1970:[end doubleValue]];
                } else {
                    ANLogDebug(@"%@ %@ | No end date provided, defaulting to 60 minutes", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
                    event.endDate = [event.startDate dateByAddingTimeInterval:3600]; // default to 60 mins
                }

                ANLogDebug(@"%@ %@ | Event Start Date: %@, End Date: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), event.startDate, event.endDate);
            } else {
                ANLogWarn(@"%@ %@ | Cannot create calendar event, no start date provided", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
                return;
            }
            
            if([df1 dateFromString:reminder]!=nil){
                [event addAlarm:[EKAlarm alarmWithAbsoluteDate:[df1 dateFromString:reminder]]];
            }else if([df2 dateFromString:reminder]!=nil){
                [event addAlarm:[EKAlarm alarmWithAbsoluteDate:[df2 dateFromString:reminder]]];
            } else if (reminder) {
                [event addAlarm:[EKAlarm alarmWithRelativeOffset:
                                    ([reminder doubleValue] / 1000.0)]]; // milliseconds to seconds conversion
            }
                
            if([status isEqualToString:@"pending"]){
                [event setAvailability:EKEventAvailabilityNotSupported];
            }else if([status isEqualToString:@"tentative"]){
                [event setAvailability:EKEventAvailabilityTentative];
            }else if([status isEqualToString:@"confirmed"]){
                [event setAvailability:EKEventAvailabilityBusy];
            }else if([status isEqualToString:@"cancelled"]){
                [event setAvailability:EKEventAvailabilityFree];
            }
                
                
            NSDictionary* repeat = [jsonDict objectForKey:@"recurrence"];
            if ([repeat isKindOfClass:[NSDictionary class]]) {
                NSString* frequency = [repeat objectForKey:@"frequency"];
                EKRecurrenceFrequency frequency_ios;
                
                if ([frequency isEqualToString:@"daily"]) frequency_ios = EKRecurrenceFrequencyDaily;
                else if ([frequency isEqualToString:@"weekly"]) frequency_ios = EKRecurrenceFrequencyWeekly;
                else if ([frequency isEqualToString:@"monthly"]) frequency_ios = EKRecurrenceFrequencyMonthly;
                else if ([frequency isEqualToString:@"yearly"]) frequency_ios = EKRecurrenceFrequencyYearly;
                else {
                    ANLogWarn(@"%@ %@ | Invalid W3 frequency passed in: %@. Acceptable values are 'daily','weekly','monthly', and 'yearly'", NSStringFromClass([self class]), NSStringFromSelector(_cmd), frequency);
                    return;
                }

                int interval = [[repeat objectForKey:@"interval"] intValue];
                if (interval < 1) {
                    interval = 1;
                }
                    
                NSString* expires = [repeat objectForKey:@"expires"];
                //expires
                EKRecurrenceEnd* end;
                if([df1 dateFromString:expires]!=nil){
                    end = [EKRecurrenceEnd recurrenceEndWithEndDate:[df1 dateFromString:expires]];
                }else if([df2 dateFromString:expires]!=nil){
                    end = [EKRecurrenceEnd recurrenceEndWithEndDate:[df2 dateFromString:expires]];
                } else if(expires && [NSDate dateWithTimeIntervalSince1970:[expires doubleValue]]){
                    end = [EKRecurrenceEnd recurrenceEndWithEndDate:[NSDate dateWithTimeIntervalSince1970:[expires doubleValue]]];
                } // default is to never expire
                    
                /*
                 * iOS Not supported
                 * NSArray* exceptionDates = [repeat objectForKey:@"exceptionDates"];
                 */
                
                NSMutableArray* daysInWeek = [[repeat objectForKey:@"daysInWeek"] mutableCopy]; // Need a mutable copy of the array in order to transform NSNumber => EKRecurrenceDayOfWeek
                
                for (NSInteger daysInWeekIndex=0; daysInWeekIndex < [daysInWeek count]; daysInWeekIndex++) {
                    NSInteger dayInWeekValue = [daysInWeek[daysInWeekIndex] integerValue]; // W3 value should be between 0 and 6 inclusive.
                    if (dayInWeekValue >= 0 && dayInWeekValue <= 6) {
                        daysInWeek[daysInWeekIndex] = [EKRecurrenceDayOfWeek dayOfWeek:dayInWeekValue+1]; // Apple expects day of week value to be between 1 and 7 inclusive.
                    } else {
                        ANLogWarn(@"%@ %@ | Invalid W3 day of week passed in: %d. Value should be between 0 and 6 inclusive.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), dayInWeekValue);
                        return;
                    }
                }

                NSMutableArray* daysInMonth = nil; // Only valid for EKRecurrenceFrequencyMonthly
                if (frequency_ios == EKRecurrenceFrequencyMonthly) {
                    NSMutableArray* daysInMonth = [[repeat objectForKey:@"daysInMonth"] mutableCopy];
                    
                    for (NSInteger daysInMonthIndex=0; daysInMonthIndex < [daysInMonth count]; daysInMonthIndex++) {
                        NSInteger dayInMonthValue = [daysInMonth[daysInMonthIndex] integerValue]; // W3 value should be between -30 and 31 inclusive.
                        if (dayInMonthValue >= -30 && dayInMonthValue <= 31) {
                            if (dayInMonthValue <= 0) { // W3 reverse values from 0 to -30, Apple reverse values from -1 to -31 (0 and -1 meaning last day of month respectively)
                                daysInMonth[daysInMonthIndex] = [NSNumber numberWithInteger:dayInMonthValue-1];
                            }
                        } else {
                            ANLogWarn(@"%@ %@ | Invalid W3 day of month passed in: %d. Value should be between -30 and 31 inclusive.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), dayInMonthValue);
                            return;
                        }
                    }
                    
                    NSArray* weeksInMonth = [repeat objectForKey:@"weeksInMonth"]; // Need to implement W3 weeksInMonth for monthly occurrences
                    NSMutableArray *updatedDaysInWeek = [[NSMutableArray alloc] init];
                    
                    for (NSNumber* weekNumber in weeksInMonth) {
                        NSInteger weekNumberValue = [weekNumber integerValue];
                        if (weekNumberValue >= -3 && weekNumberValue <= 4) { // W3 value should be between -3 and 4 inclusive.
                            for (EKRecurrenceDayOfWeek* day in daysInWeek) {
                                if (weekNumberValue <= 0) { // W3 reverse values from 0 to -3, Apple reverse values from -1 to -4
                                    weekNumberValue--;
                                }
                                ANLogDebug(@"%@ %@ | Adding EKRecurrenceDayOfWeek object with day number %d and week number %d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), day.dayOfTheWeek, weekNumberValue);
                                [updatedDaysInWeek addObject:[EKRecurrenceDayOfWeek dayOfWeek:day.dayOfTheWeek weekNumber:weekNumberValue]];
                            }
                        } else {
                            ANLogWarn(@"%@ %@ | Invalid W3 week of month passed in: %d. Value should be between -3 and 4 inclusive.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), weekNumberValue);
                            return;
                        }
                    }
                    
                    daysInWeek = updatedDaysInWeek;
                }

                NSArray *monthsInYear = nil;
                NSMutableArray* daysInYear = nil;

                if (frequency_ios == EKRecurrenceFrequencyYearly) {
                    monthsInYear = [repeat objectForKey:@"monthsInYear"]; // Apple & W3 valid values from 1 to 12, inclusive.
                    
                    for (NSNumber *monthInYear in monthsInYear) {
                        NSInteger monthInYearValue = [monthInYear integerValue];
                        if (monthInYearValue < 0 && monthInYearValue > 12) {
                            ANLogWarn(@"%@ %@ | Invalid W3 month passed in: %d. Value should be between 1 and 12 inclusive.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), monthInYearValue);
                            return;
                        }
                    }
                    
                    daysInYear = [[repeat objectForKey:@"daysInYear"] mutableCopy];
                    
                    for (NSInteger daysInYearIndex=0; daysInYearIndex < [daysInYear count]; daysInYearIndex++) {
                        NSInteger dayInYearValue = [daysInYear[daysInYearIndex] integerValue]; // W3 value should be between -364 and 365 inclusive. (W3 doesn't care about leap years?)
                        if (dayInYearValue >= -364 && dayInYearValue <= 365) {
                            if (dayInYearValue <= 0) { // W3 reverse values from 0 to -364, Apple reverse values from -1 to -366
                                daysInYear[daysInYearIndex] = [NSNumber numberWithInteger:dayInYearValue-1];
                            }
                        } else {
                            ANLogWarn(@"%@ %@ | Invalid W3 day of year passed in: %d. Value should be between -364 and 365 inclusive.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), dayInYearValue);
                            return;
                        }
                    }
                }
                
                EKRecurrenceRule* rrule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:frequency_ios
                                                                                       interval:interval
                                                                                  daysOfTheWeek:daysInWeek
                                                                                 daysOfTheMonth:daysInMonth
                                                                                monthsOfTheYear:monthsInYear
                                                                                 weeksOfTheYear:nil
                                                                                  daysOfTheYear:daysInYear
                                                                                   setPositions:nil
                                                                                            end:end];
                
                if (rrule) { // EKRecurrenceRule will return nil if invalid values are passed in
                    [event setRecurrenceRules:[NSArray arrayWithObjects:rrule, nil]];
                    ANLogDebug(@"%@ %@ | Created Recurrence Rule: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), rrule);
                } else {
                    ANLogWarn(@"%@ %@ | Invalid EKRecurrenceRule Values Passed In.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
                }
            }
        
            NSError* error = nil;
            [store saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
            if (error) {
                ANLogWarn(error.localizedDescription);
            }
        });
    }];
}



- (void)setOrientationProperties:(NSDictionary *)queryComponents
{
    NSString *allow = [queryComponents objectForKey:@"allow_orientation_change"];
    NSString *forcedOrientation = [queryComponents objectForKey:@"force_orientation"];
    
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
    ANLogDebug(decodedString);
}

// expand close button for non-custom close is provided by SDK
- (UIButton *)expandCloseButton {
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton addTarget:self
                    action:@selector(closeAction:)
          forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *closeButtonImage = [UIImage imageNamed:@"interstitial_closebox"];
    [closeButton setImage:closeButtonImage forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"interstitial_closebox_down"] forState:UIControlStateHighlighted];
    
    // setFrame here in order to pass the size dimensions along
    [closeButton setFrame:CGRectMake(0, 0, closeButtonImage.size.width, closeButtonImage.size.height)];
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

@end

