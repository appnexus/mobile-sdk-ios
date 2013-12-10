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

#import "ANAdFetcher.h"
#import "ANAdWebViewController.h"
#import "ANAdResponse.h"
#import "ANAdView.h"
#import "NSString+ANCategory.h"
#import "ANBrowserViewController.h"
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
		[self.adFetcher.delegate adFetcher:self.adFetcher didFinishRequestWithResponse:response];
		[self.adFetcher startAutorefreshTimer];
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
@property (nonatomic, readwrite, assign, getter = isExpanded) BOOL expanded;
@property (nonatomic, readwrite, assign) CGSize defaultSize;
@property (nonatomic, readwrite, assign) BOOL allowOrientationChange;
@end

@implementation ANMRAIDAdWebViewController
@synthesize expanded = __expanded;
@synthesize defaultSize = __defaultSize;

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!self.completedFirstLoad)
    {
        
        //Set values for mraid.supports()
        [self setValuesForMRAIDSupportsFunction:webView];
        
        //Set screen size
        [self setScreenSizeForMRAIDGetScreenSizeFunction:webView];
        
        //Set default position
        [self setDefaultPositionForMRAIDGetDefaultPositionFunction:webView];
        
        //Set max size
        [self setMaxSizeForMRAIDGetMaxSizeFunction:webView];
        
        [webView firePlacementType:[self.adFetcher.delegate placementTypeForAdFetcher:self.adFetcher]];
        [webView setIsViewable:(BOOL)!webView.hidden];
        [webView fireStateChangeEvent:ANMRAIDStateDefault];
        [webView fireReadyEvent];
		
		self.adFetcher.loading = NO;
        self.completedFirstLoad = YES;
		
		ANAdResponse *response = [ANAdResponse adResponseSuccessfulWithAdObject:webView];
		[self.adFetcher.delegate adFetcher:self.adFetcher didFinishRequestWithResponse:response];
		[self.adFetcher startAutorefreshTimer];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // prevent pop-ups from showing
    [webView stringByEvaluatingJavaScriptFromString:@"window.alert=function(){};"];
	if (self.completedFirstLoad)
	{
		NSURL *URL = [request URL];
		NSString *scheme = [URL scheme];
		
		if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"])
		{
			[self.adFetcher.delegate adFetcher:self.adFetcher adShouldOpenInBrowserWithURL:URL];
		}
		else if ([scheme isEqualToString:@"mraid"])
		{
			// Do MRAID actions
			[self dispatchNativeMRAIDURL:URL forWebView:webView];
		}
		
		return NO;
	}
    
    return YES;
}

- (void)setMaxSizeForMRAIDGetMaxSizeFunction:(UIWebView*) webView{ //TODO: Setting to screen size because IDK what to doooo
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    int w = floorf(screenRect.size.width +0.5f);
    int h = floorf(screenRect.size.height +0.5f);
    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.mraid.util.setMaxSize(%i, %i);",w,h]];
}

- (void)setScreenSizeForMRAIDGetScreenSizeFunction:(UIWebView*)webView{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    int w = floorf(screenRect.size.width +0.5f);
    int h = floorf(screenRect.size.height +0.5f); //Ah the glorious 0.5f rounding trick
    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.mraid.util.setScreenSize(%i, %i);",w,h]];
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

- (void)dispatchNativeMRAIDURL:(NSURL *)mraidURL forWebView:(UIWebView *)webView
{
    NSString *mraidCommand = [mraidURL host];
    
    if ([mraidCommand isEqualToString:@"expand"])
    {
        NSString *hiddenState = [webView stringByEvaluatingJavaScriptFromString:@"window.mraid.getState()"];
    
        if ([hiddenState isEqualToString:@"hidden"])
        {
            [webView setIsViewable:(BOOL)!webView.hidden];
            [webView fireStateChangeEvent:ANMRAIDStateDefault];
        }
        
        NSString *query = [mraidURL query];
        NSDictionary *queryComponents = [query queryComponents];
        
        NSInteger expandedHeight = [[queryComponents objectForKey:@"h"] integerValue];
        NSInteger expandedWidth = [[queryComponents objectForKey:@"w"] integerValue];
        
		NSString *useCustomClose = [queryComponents objectForKey:@"useCustomClose"];
        if ([useCustomClose isEqualToString:@"false"])
        {
            // No custom close included, show our default one.
            [self.adFetcher.delegate adFetcher:self.adFetcher adShouldShowCloseButtonWithTarget:self action:@selector(closeAction:)];
        }
		
        self.defaultSize = webView.frame.size;
        [self.adFetcher.delegate adFetcher:self.adFetcher adShouldResizeToSize:CGSizeMake(expandedWidth, expandedHeight)];
		
        
        NSString *url = [queryComponents objectForKey:@"url"];
        if ([url length] > 0)
        {
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        }
        
        self.expanded = YES;
    }
    else if ([mraidCommand isEqualToString:@"close"])
    {
        [self closeAction:self];
    }else if([mraidCommand isEqualToString:@"createCalendarEvent"]){
        NSString* query = [mraidURL query];
        NSDictionary* queryComponents = [query queryComponents];
        NSString* w3cEventJson = [queryComponents objectForKey:@"p"];
        [self createCalendarEventFromW3CCompliantJSONObject:w3cEventJson];
    }else if([mraidCommand isEqualToString:@"playVideo"]){
        NSString *query = [mraidURL query];
        NSDictionary *queryComponents = [query queryComponents];
        NSString *uri = [queryComponents objectForKey:@"uri"];
        
        MPMoviePlayerController *moviePlayer = [MPMoviePlayerController alloc];
        moviePlayer.controlStyle = MPMovieControlStyleDefault;
        moviePlayer.shouldAutoplay = YES;
        [moviePlayer setContentURL:[NSURL URLWithString:uri]];
        
        [webView addSubview: moviePlayer.view];
        [moviePlayer setFullscreen:YES animated:YES];
    }else if([mraidCommand isEqualToString:@"resize"]){
        NSString *query = [mraidURL query];
        NSDictionary *queryComponents = [query queryComponents];
        int w = [[queryComponents objectForKey:@"w"] intValue];
        int h = [[queryComponents objectForKey:@"h"] intValue];
        int offset_x = [[queryComponents objectForKey:@"offset_x"] intValue];
        int offset_y = [[queryComponents objectForKey:@"offset_y"] intValue];
        NSString* custom_close_position = [queryComponents objectForKey:@"custom_close_position"];
        BOOL allow_offscreen = [[queryComponents objectForKey:@"allow_offscreen"] boolValue];
        
        NSString *currentState = [webView stringByEvaluatingJavaScriptFromString:@"window.mraid.getState()"];
        if([currentState isEqualToString:@"default"] || [currentState isEqualToString:@"resized"]){
            //TODO custom_close_position
            [self.adFetcher.delegate adFetcher:self.adFetcher adShouldShowCloseButtonWithTarget:self action:@selector(closeAction:)];
            if([currentState isEqualToString:@"default"]){
                self.defaultSize = webView.frame.size;
            }
            
            [self.adFetcher.delegate adFetcher:self.adFetcher adShouldResizeToSize:CGSizeMake(w, h)];
            
            self.expanded = YES;
            
        }
    }else if([mraidCommand isEqualToString:@"storePicture"]){
        NSString *query = [mraidURL query];
        NSDictionary *queryComponents = [query queryComponents];
        NSString *uri = [queryComponents objectForKey:@"uri"];
        [self storePicture:uri];
    }else if([mraidCommand isEqualToString:@"setOrientationProperties"]){
        NSString *query = [mraidURL query];
        NSDictionary *queryComponents = [query queryComponents];
        NSString *allow = [queryComponents objectForKey:@"allow_orientation_change"];
        NSString *forcedOrientation = [queryComponents objectForKey:@"force_orientation"];
        BOOL allowb = [allow boolValue];
        ANMRAIDOrientation forced = [forcedOrientation isEqualToString:@"none"]?ANMRAIDOrientationNone : [forcedOrientation isEqualToString:@"landscape"]? ANMRAIDOrientationLandscape : ANMRAIDOrientationPortrait;
        [self setOrientationProperties:allowb forcedOrientation:forced];
    }
}

- (IBAction)closeAction:(id)sender
{
    if ([self isExpanded])
    {
        self.expanded = NO;
        [self.adFetcher.delegate adShouldRemoveCloseButtonWithAdFetcher:self.adFetcher];
        
        [self.adFetcher.delegate adFetcher:self.adFetcher adShouldResizeToSize:self.defaultSize];
        
        [self.webView fireStateChangeEvent:ANMRAIDStateDefault];
    }
    else
    {
        // Clear the ad out
        [self.webView setHidden:YES animated:YES];
        self.webView = nil;
    }
}

- (void)setExpanded:(BOOL)expanded
{
    if (expanded != __expanded)
    {
        __expanded = expanded;
        if (__expanded)
        {
            [self.adFetcher stopAd];
        }
        else
        {
            [self.adFetcher setupAutorefreshTimerIfNecessary];
            [self.adFetcher startAutorefreshTimer];
        }
    }
}

- (void)createCalendarEventFromW3CCompliantJSONObject:(NSString*)json{
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
    //TODO repeat rule
    
    EKEventStore* store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityMaskEvent completion:^(BOOL granted, NSError *error){
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
        
                
                NSError* error = [[NSError alloc] init];
                [store saveEvent:event span:EKSpanThisEvent error:&error];

            });
        }
    }];
}



- (void)setOrientationProperties:(BOOL)allowChange forcedOrientation:(ANMRAIDOrientation) forcedOrientation
{
    if(!allowChange){
        switch(forcedOrientation)
        {
            case ANMRAIDOrientationNone:
                break;
            case ANMRAIDOrientationLandscape:
                break;
            case ANMRAIDOrientationPortrait:
                break;
        }
    }
    //TODO SAVE ME MARK
}

- (void)storePicture:(NSString*)uri
{
    //TODO check for URI scheme
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:uri];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if(data){
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES);
            NSString *downloadDir = [paths objectAtIndex:0];
            //Acquire Date-time to use as filename
            NSDateFormatter *formatter;
            NSString *dateTime;
            formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyyMMddHHmm"];
            
            dateTime = [formatter stringFromDate:[NSDate date]];
            
            NSString *extension = [[uri componentsSeparatedByString:@"."] lastObject];
            
            
            NSString *filePath = [NSString stringWithFormat:@"%@/%@.%@", downloadDir, dateTime, extension];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [data writeToFile:filePath atomically:YES];
            });
        }
    });
    
}
@end

@implementation UIWebView (MRAIDExtensions)

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    NSString* setCurrentPosition = [NSString stringWithFormat:@"window.mraid.util.setCurrentPosition(%i,%i,%i,%i);", (int)frame.origin.x, (int)frame.origin.y, (int)frame.size.width, (int)frame.size.height];
    [self stringByEvaluatingJavaScriptFromString:setCurrentPosition];
    NSString* setCurrentSize = [NSString stringWithFormat:@"window.mraid.util.sizeChangeEvent(%i,%i);", (int)frame.size.width, (int)frame.size.height];
    [self stringByEvaluatingJavaScriptFromString:setCurrentSize];
}

- (void)firePlacementType:(NSString *)placementType
{
    NSString* script = [NSString stringWithFormat:@"window.mraid.util.setPlacementType('%@');", placementType];
    [self stringByEvaluatingJavaScriptFromString:script];
}

- (void)fireReadyEvent
{
    NSString* script = [NSString stringWithFormat:@"window.mraid.util.readyEvent();"];
    [self stringByEvaluatingJavaScriptFromString:script];
}

- (void)setIsViewable:(BOOL)viewable
{
    NSString* script = [NSString stringWithFormat:@"window.mraid.util.setIsViewable(%@)", viewable ? @"true" : @"false"];
    [self stringByEvaluatingJavaScriptFromString:script];
}

- (void)fireStateChangeEvent:(ANMRAIDState)state
{
    NSString *stateString = @"";
    
    switch (state)
    {
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

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:kAppNexusAnimationDuration animations:^{
            self.alpha = hidden ? 0.0f : 1.0f;
        } completion:^(BOOL finished) {
            self.hidden = hidden;
            self.alpha = 1.0f;
        }];
    }
    else
    {
        self.hidden = hidden;
    }
}

@end
