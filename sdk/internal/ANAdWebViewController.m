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
#import "ANBrowserViewController.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANWebView.h"
#import "NSString+ANCategory.h"
#import "UIWebView+ANCategory.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MFMessageComposeViewController.h>

typedef enum _ANMRAIDState
{
    ANMRAIDStateLoading,
    ANMRAIDStateDefault,
    ANMRAIDStateExpanded,
    ANMRAIDStateHidden,
    ANMRAIDStateResized
} ANMRAIDState;

typedef enum _ANMRAIDOrientation
{
    ANMRAIDOrientationPortrait,
    ANMRAIDOrientationLandscape,
    ANMRAIDOrientationNone
} ANMRAIDOrientation;

@interface UIWebView (MRAIDExtensions)
- (void)fireReadyEvent;
- (void)setIsViewable:(BOOL)viewable;
- (ANMRAIDState)getMRAIDState;
- (void)fireStateChangeEvent:(ANMRAIDState)state;
- (void)firePlacementType:(NSString *)placementType;
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;
@end

@interface ANAdFetcher (ANAdWebViewController)
@property (nonatomic, readwrite, getter = isLoading) BOOL loading;
@end

@interface ANAdWebViewController ()
@property (nonatomic, readwrite, assign) BOOL completedFirstLoad;
@end

@implementation ANAdWebViewController
@synthesize adFetcher = __adFetcher;
@synthesize webView = __webView;
@synthesize completedFirstLoad = __completedFirstLoad;

- (void)setWebView:(UIWebView *)webView {
    [webView setMediaProperties];
    __webView = webView;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (self.completedFirstLoad)
	{
		NSURL *URL = [request URL];
		[self.adFetcher.delegate adFetcher:self.adFetcher adShouldOpenInBrowserWithURL:URL];
		
		return NO;
	}
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	if (!self.completedFirstLoad)
	{
		self.adFetcher.loading = NO;
		
		// If this is our first successful load, then send this to the delegate. Otherwise, ignore.
		self.completedFirstLoad = YES;
		
		ANAdResponse *response = [ANAdResponse adResponseSuccessfulWithAdObject:webView];
        [self.adFetcher processFinalResponse:response];
	}
}

- (void)dealloc
{
    [__webView stopLoading];
    __webView.delegate = nil;
    [__webView removeFromSuperview];
}

@end

@interface ANMRAIDAdWebViewController ()
@property (nonatomic, readwrite, assign) CGRect defaultFrame;
@property (nonatomic, readwrite, assign) BOOL allowOrientationChange;
@property (nonatomic, readwrite, assign) BOOL defaultHasBeenSet;
@property (nonatomic, assign) BOOL resized;
@end

@implementation ANMRAIDAdWebViewController

- (id)init {
    self = [super init];
    self.defaultHasBeenSet = NO;
    return self;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!self.completedFirstLoad) {
        //Set values for mraid.supports()
        [self setValuesForMRAIDSupportsFunction:webView];
        
        [webView firePlacementType:[self.mraidDelegate adType]];
        [webView setIsViewable:(BOOL)!webView.hidden];
        [webView fireStateChangeEvent:ANMRAIDStateDefault];
        [webView fireReadyEvent];
		
		self.adFetcher.loading = NO;
        self.completedFirstLoad = YES;
        ((ANWebView *)webView).safety = YES;
		
		ANAdResponse *response = [ANAdResponse adResponseSuccessfulWithAdObject:webView];
        [self.adFetcher processFinalResponse:response];

        //Set screen size
        [self setScreenSizeForMRAIDGetScreenSizeFunction:webView];
        
        //Set default position
        [self setDefaultPositionForMRAIDGetDefaultPositionFunction:webView];
        
        //Set max size
        [self setMaxSizeForMRAIDGetMaxSizeFunction:webView];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (self.completedFirstLoad) {
		NSURL *URL = [request URL];
		NSString *scheme = [URL scheme];
		
		if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
			[self.adFetcher.delegate adFetcher:self.adFetcher adShouldOpenInBrowserWithURL:URL];
		} else if ([scheme isEqualToString:@"mraid"]) {
			// Do MRAID actions
			[self dispatchNativeMRAIDURL:URL forWebView:webView];
		} else if ([scheme isEqualToString:@"anwebconsole"]) {
            [self printConsoleLog:URL];
        } else if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            [[UIApplication sharedApplication] openURL:URL];
        } else {
            ANLogWarn([NSString stringWithFormat:ANErrorString(@"opening_url_failed"), URL]);
        }
		
		return NO;
	}
    
    return YES;
}

- (void)setMaxSizeForMRAIDGetMaxSizeFunction:(UIWebView*) webView{
    UIApplication *application = [UIApplication sharedApplication];
    BOOL orientationIsPortrait = UIInterfaceOrientationIsPortrait([application statusBarOrientation]);
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    int screenWidth = floorf(screenSize.width + 0.5f);
    int screenHeight = floorf(screenSize.height + 0.5f);
    int orientedWidth = orientationIsPortrait ? screenWidth : screenHeight;
    int orientedHeight = orientationIsPortrait ? screenHeight : screenWidth;
    
    if (!application.statusBarHidden) {
        orientedHeight -= MIN(application.statusBarFrame.size.height, application.statusBarFrame.size.width);
    }
    
    [webView stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@"window.mraid.util.setMaxSize(%i, %i);",
      orientedWidth, orientedHeight]];
}

- (void)setScreenSizeForMRAIDGetScreenSizeFunction:(UIWebView*)webView{
    BOOL orientationIsPortrait = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    int w = floorf(screenSize.width + 0.5f);
    int h = floorf(screenSize.height + 0.5f);
    
    [webView stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@"window.mraid.util.setScreenSize(%i, %i);",
      orientationIsPortrait ? w : h, orientationIsPortrait ? h : w]];
}

- (void)setDefaultPositionForMRAIDGetDefaultPositionFunction:(UIWebView*)webView{
    CGRect bounds = [webView bounds];
    int x = floorf(bounds.origin.x +0.5f);
    int y = floorf(bounds.origin.y +0.5f);
    int w = floorf(bounds.size.width +0.5f);
    int h = floorf(bounds.size.height +0.5f);
    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.mraid.util.setCurrentPosition(%i, %i, %i, %i);",x,y,w,h]];
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.mraid.util.setDefaultPosition(%i, %i, %i, %i);",x,y,w,h]];
}

- (void)setValuesForMRAIDSupportsFunction:(UIWebView*)webView{
    NSString* sms = @"false";
    NSString* tel = @"false";
    NSString* cal = @"false";
    NSString* inline_video = @"true";
    NSString* store_picture = @"true";
#ifdef __IPHONE_4_0
    //SMS
    sms = [MFMessageComposeViewController canSendText] ? @"true" : @"false";
#else
    sms = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms://"]] ? @"true" : @"false";
#endif
    //TEL
    tel = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]] ? @"true" : @"false";
    
    //CAL
    EKEventStore *store = [[EKEventStore alloc] init];
    if([store respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        cal = @"true";
    }
    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.mraid.util.setSupportsTel(%@);", tel]];
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.mraid.util.setSupportsSMS(%@);", sms]];
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.mraid.util.setSupportsCalendar(%@);", cal]];
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.mraid.util.setSupportsStorePicture(%@);", store_picture]];
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.mraid.util.setSupportsInlineVideo(%@);", inline_video]];

    
}

- (void)dispatchNativeMRAIDURL:(NSURL *)mraidURL forWebView:(UIWebView *)webView {
    ANLogDebug(@"MRAID URL: %@", [mraidURL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    NSString *mraidCommand = [mraidURL host];
    NSString *query = [mraidURL query];
    NSDictionary *queryComponents = [query queryComponents];

    if ([mraidCommand isEqualToString:@"expand"]) {
        // do nothing if in hidden state
        if ([webView getMRAIDState] == ANMRAIDStateHidden) {
            return;
        }
        
        [self expandAction:webView queryComponents:queryComponents];
    }
    else if ([mraidCommand isEqualToString:@"close"]) {
        // do nothing if in hidden state
        if ([webView getMRAIDState] == ANMRAIDStateHidden) {
            return;
        }

        [self closeAction:self];
    } else if([mraidCommand isEqualToString:@"resize"]) {
        [self resizeAction:webView queryComponents:queryComponents];
    } else if([mraidCommand isEqualToString:@"createCalendarEvent"]) {
        NSString *w3cEventJson = [queryComponents objectForKey:@"p"];
        [self createCalendarEventFromW3CCompliantJSONObject:w3cEventJson];
    } else if([mraidCommand isEqualToString:@"playVideo"]) {
        [self playVideo:queryComponents];
    } else if([mraidCommand isEqualToString:@"storePicture"]) {
        NSString *uri = [queryComponents objectForKey:@"uri"];
        [self storePicture:uri];
    } else if([mraidCommand isEqualToString:@"setOrientationProperties"]) {
        [self setOrientationProperties:queryComponents];
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
        [self.mraidDelegate adShouldRemoveCloseButton];
        [self.mraidDelegate adShouldResetToDefault];
        
        [self.webView fireStateChangeEvent:ANMRAIDStateDefault];
        self.expanded = NO;
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
    
    if (!self.defaultHasBeenSet) {
        self.defaultFrame = webView.frame;
        self.defaultHasBeenSet = YES;
    }
    
    [self.mraidDelegate adShouldExpandToFrame:CGRectMake(0, 0, expandedWidth, expandedHeight)];
    
    self.expanded = YES;
    
    if ([useCustomClose isEqualToString:@"false"]) {
        // No custom close included, show our default one.
        [self.mraidDelegate adShouldShowCloseButtonWithTarget:self action:@selector(closeAction:)
                                                     position:ANMRAIDTopRight];
    }
    
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
    
    ANMRAIDState currentState = [webView getMRAIDState];
    
    if ((currentState == ANMRAIDStateDefault) || (currentState == ANMRAIDStateResized)) {
        if (currentState == ANMRAIDStateDefault) {
            self.defaultFrame = webView.frame;
        }

        [self.mraidDelegate adShouldResizeToFrame:CGRectMake(offsetX, offsetY, w, h) allowOffscreen:allowOffscreen];

        [self.mraidDelegate adShouldRemoveCloseButton];
        [self.mraidDelegate adShouldShowCloseButtonWithTarget:self action:@selector(closeAction:)
                                                     position:closePosition];
    }
    
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
    [self.controller presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
    [moviePlayerViewController.moviePlayer play];
}

- (void)moviePlayerDidFinish:(NSNotification *)notification
{
    ANLogInfo(@"Movie Player finished: %@", notification);
}

- (void)createCalendarEventFromW3CCompliantJSONObject:(NSString *)json{
    NSError* error;
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    
    //NSString* event_id = [jsonDict objectForKey:@"id"]; //Don't need it
    NSString* description = [jsonDict objectForKey:@"description"];
    NSString* location = [jsonDict objectForKey:@"location"];
    NSString* summary = [jsonDict objectForKey:@"summary"];
    NSString* start = [jsonDict objectForKey:@"start"];
    NSString* end = [jsonDict objectForKey:@"end"];
    NSString* status = [jsonDict objectForKey:@"status"];
    //NSString* transparency = [jsonDict objectForKey:@"transparency"]; //Not supported
    NSString* reminder = [jsonDict objectForKey:@"reminder"];
    
    EKEventStore* store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
        if(granted){
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
                }else{
                    event.endDate = [NSDate dateWithTimeIntervalSince1970:[end doubleValue]];
                }
                
                if([df1 dateFromString:reminder]!=nil){
                    [event addAlarm:[EKAlarm alarmWithAbsoluteDate:[df1 dateFromString:reminder]]];
                }else if([df2 dateFromString:reminder]!=nil){
                    [event addAlarm:[EKAlarm alarmWithAbsoluteDate:[df2 dateFromString:reminder]]];
                }else{
                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:[reminder doubleValue]]];
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
                    EKRecurrenceFrequency frequency_ios = [frequency isEqualToString:@"daily"] ? EKRecurrenceFrequencyDaily:
                                                          ([frequency isEqualToString:@"weekly"]? EKRecurrenceFrequencyWeekly:
                                                          ([frequency isEqualToString:@"monthly"]?EKRecurrenceFrequencyMonthly:
                                                          ([frequency isEqualToString:@"yearly"]? EKRecurrenceFrequencyYearly:-1)));
                    int interval = [[repeat objectForKey:@"interval"] intValue];
                    NSString* expires = [repeat objectForKey:@"expires"];
                    //expires
                    EKRecurrenceEnd* end;
                    if([df1 dateFromString:expires]!=nil){
                        end = [EKRecurrenceEnd recurrenceEndWithEndDate:[df1 dateFromString:expires]];
                    }else if([df2 dateFromString:expires]!=nil){
                        end = [EKRecurrenceEnd recurrenceEndWithEndDate:[df2 dateFromString:expires]];
                    }else if([NSDate dateWithTimeIntervalSince1970:[expires doubleValue]]!=nil){
                        end = [EKRecurrenceEnd recurrenceEndWithEndDate:[NSDate dateWithTimeIntervalSince1970:[expires doubleValue]]];
                    }
                    //NSArray* exceptionDates = [repeat objectForKey:@"exceptionDates"]; //Not supported
                    NSArray* daysInWeek = [repeat objectForKey:@"daysInWeek"];
                    NSArray* daysInMonth = [repeat objectForKey:@"daysInMonth"];
                    NSArray* daysInYear = [repeat objectForKey:@"daysInYear"];
                    NSArray* weeksInMonth = [repeat objectForKey:@"weeksInMonth"];
                    NSArray* monthsInYear = [repeat objectForKey:@"monthsInYear"];
                    

                    
                    EKRecurrenceRule* rrule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:frequency_ios interval:interval daysOfTheWeek:daysInWeek daysOfTheMonth:daysInMonth monthsOfTheYear:monthsInYear weeksOfTheYear:weeksInMonth daysOfTheYear:daysInYear setPositions:nil end:end];
                    
                    

                    
                    [event setRecurrenceRules:[NSArray arrayWithObjects:rrule, nil]];
                }
        
                
                NSError* error = nil;
                [store saveEvent:event span:EKSpanThisEvent error:&error];
                if (error) {
                    ANLogError(error.localizedDescription);
                }
            });
        }
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
    
    if(![allow boolValue]){
        switch(mraidOrientation)
        {
            case ANMRAIDOrientationNone:
                // do nothing
                return;
            case ANMRAIDOrientationLandscape:
                if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
                    [self.mraidDelegate forceOrientation:UIInterfaceOrientationLandscapeRight];
                    break;
                }
                [self.mraidDelegate forceOrientation:UIInterfaceOrientationLandscapeLeft];
                break;
            case ANMRAIDOrientationPortrait:
                [self.mraidDelegate forceOrientation:UIInterfaceOrientationPortrait];
                break;
        }
    } else {
        mraidOrientation = ANMRAIDOrientationNone;
    }
}

- (void)storePicture:(NSString*)uri
{
    //TODO check for URI scheme
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:uri];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if(data){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [[UIImage alloc] initWithData:data];
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            });
        }
    });
    
}

- (void)printConsoleLog:(NSURL *)URL {
    NSMutableString *urlString = [NSMutableString stringWithString:[URL absoluteString]];
    [urlString replaceOccurrencesOfString:@"%20"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [urlString length])];
    [urlString replaceOccurrencesOfString:@"%5B"
                               withString:@"["
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [urlString length])];
    [urlString replaceOccurrencesOfString:@"%5D"
                               withString:@"]"
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [urlString length])];
    ANLogDebug(urlString);
}

@end

@implementation ANWebView (MRAIDExtensions)

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (self.safety) {
        NSString* setCurrentPosition = [NSString stringWithFormat:@"window.mraid.util.setCurrentPosition(%i,%i,%i,%i);", (int)frame.origin.x, (int)frame.origin.y, (int)frame.size.width, (int)frame.size.height];
        [self stringByEvaluatingJavaScriptFromString:setCurrentPosition];
        NSString* setCurrentSize = [NSString stringWithFormat:@"window.mraid.util.sizeChangeEvent(%i,%i);", (int)frame.size.width, (int)frame.size.height];
        [self stringByEvaluatingJavaScriptFromString:setCurrentSize];
    }
}

- (void)firePlacementType:(NSString *)placementType {
    NSString* script = [NSString stringWithFormat:@"window.mraid.util.setPlacementType('%@');", placementType];
    [self stringByEvaluatingJavaScriptFromString:script];
}

- (void)fireReadyEvent {
    NSString* script = [NSString stringWithFormat:@"window.mraid.util.readyEvent();"];
    [self stringByEvaluatingJavaScriptFromString:script];
}

- (void)setIsViewable:(BOOL)viewable {
    NSString* script = [NSString stringWithFormat:@"window.mraid.util.setIsViewable(%@)", viewable ? @"true" : @"false"];
    [self stringByEvaluatingJavaScriptFromString:script];
}

- (ANMRAIDState)getMRAIDState {
    NSString *state = [self stringByEvaluatingJavaScriptFromString:@"window.mraid.getState()"];
    if ([state isEqualToString:@"loading"]) {
        return ANMRAIDStateLoading;
    } else if ([state isEqualToString:@"default"]) {
        return ANMRAIDStateDefault;
    } else if ([state isEqualToString:@"expanded"]) {
        return ANMRAIDStateExpanded;
    } else if ([state isEqualToString:@"hidden"]) {
        return ANMRAIDStateHidden;
    } else if ([state isEqualToString:@"resized"]) {
        return ANMRAIDStateResized;
    }
    
    ANLogError(@"Call to mraid.getState() returned invalid state.");
    return ANMRAIDStateDefault;
}

- (void)fireStateChangeEvent:(ANMRAIDState)state {
    NSString *stateString = @"";
    
    switch (state) {
        case ANMRAIDStateLoading:
            stateString = @"loading";
            break;
        case ANMRAIDStateDefault:
            stateString = @"default";
            break;
        case ANMRAIDStateExpanded:
            stateString = @"expanded";
            break;
        case ANMRAIDStateHidden:
            stateString = @"hidden";
            break;
        case ANMRAIDStateResized:
            stateString = @"resized";
            break;
        default:
            break;
    }
    
    NSString *script = [NSString stringWithFormat:@"window.mraid.util.stateChangeEvent('%@')", stateString];
    [self stringByEvaluatingJavaScriptFromString:script];
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:kAppNexusAnimationDuration animations:^{
            self.alpha = hidden ? 0.0f : 1.0f;
        } completion:^(BOOL finished) {
            self.hidden = hidden;
            self.alpha = 1.0f;
        }];
    }
    else {
        self.hidden = hidden;
    }
}

@end
