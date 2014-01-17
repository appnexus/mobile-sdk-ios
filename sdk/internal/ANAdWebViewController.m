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

#import <EventKitUI/EventKitUI.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface ANAdFetcher (ANAdWebViewController)
@property (nonatomic, readwrite, getter = isLoading) BOOL loading;
@end

@interface ANAdWebViewController ()

- (void)delegateShouldOpenInBrowser:(NSURL *)URL;

@property (nonatomic, readwrite, assign) BOOL completedFirstLoad;

@end

@implementation ANAdWebViewController

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.completedFirstLoad) {
        NSURL *URL = [request URL];
        NSURL *mainDocumentURL = [request mainDocumentURL];
        
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
        
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!self.completedFirstLoad) {
        self.adFetcher.loading = NO;
        
        // If this is our first successful load, then send this to the delegate. Otherwise, ignore.
        self.completedFirstLoad = YES;
        
        ANAdResponse *response = [ANAdResponse adResponseSuccessfulWithAdObject:webView];
        [self.adFetcher processFinalResponse:response];
    }
}

- (void)delegateShouldOpenInBrowser:(NSURL *)URL {
    if ([self.adFetcher.delegate respondsToSelector:@selector(adFetcher:adShouldOpenInBrowserWithURL:)]) {
        [self.adFetcher.delegate adFetcher:self.adFetcher adShouldOpenInBrowserWithURL:URL];
    }
}

- (void)dealloc {
    [self.webView stopLoading];
    self.webView.delegate = nil;
    [self.webView removeFromSuperview];
}

@end

@interface ANMRAIDAdWebViewController ()
@property (nonatomic, readwrite, assign) CGRect defaultFrame;
@property (nonatomic, readwrite, assign) BOOL expanded;
@property (nonatomic, readwrite, assign) BOOL resized;
@end

@implementation ANMRAIDAdWebViewController

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!self.completedFirstLoad) {
		self.adFetcher.loading = NO;
        self.completedFirstLoad = YES;
		
		ANAdResponse *response = [ANAdResponse adResponseSuccessfulWithAdObject:webView];
        [self.adFetcher processFinalResponse:response];

        // set initial values for MRAID getters
        [self setValuesForMRAIDSupportsFunction:webView];
        [self setScreenSizeForMRAIDGetScreenSizeFunction:webView];
        [self setDefaultPositionForMRAIDGetDefaultPositionFunction:webView];
        [self setMaxSizeForMRAIDGetMaxSizeFunction:webView];
        
        // remember frame for default state
        [self setDefaultFrame:webView.frame];

        [webView setPlacementType:[self.mraidDelegate adType]];
        [webView setIsViewable:(BOOL)!webView.hidden];
        [webView fireStateChangeEvent:ANMRAIDStateDefault];
        [webView fireReadyEvent];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (self.completedFirstLoad) {
		NSURL *URL = [request URL];
        NSURL *mainDocumentURL = [request mainDocumentURL];
		NSString *scheme = [URL scheme];
		
		if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {            
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

- (void)setDefaultPositionForMRAIDGetDefaultPositionFunction:(UIWebView *)webView{
    CGRect bounds = [webView bounds];
    [webView setDefaultPosition:bounds];
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
    if ([store respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
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
    UIButton *closeButton = [useCustomClose isEqualToString:@"false"] ? [self expandCloseButton] : nil;
    
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

- (void)adDidChangePosition:(CGRect)frame {
    [self.webView fireNewCurrentPositionEvent:frame];
}

- (void)adDidResetToDefault {
    [self.webView fireStateChangeEvent:ANMRAIDStateDefault];
}

@end

