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

typedef enum _ANMRAIDState
{
    ANMRAIDStateLoading,
    ANMRAIDStateDefault,
    ANMRAIDStateExpanded,
    ANMRAIDStateHidden
} ANMRAIDState;

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
@end

@implementation ANMRAIDAdWebViewController
@synthesize expanded = __expanded;
@synthesize defaultSize = __defaultSize;

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!self.completedFirstLoad)
    {
        [webView firePlacementType:[self.adFetcher.delegate placementTypeForAdFetcher:self.adFetcher]];
        [webView setIsViewable:YES];
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

- (void)dispatchNativeMRAIDURL:(NSURL *)mraidURL forWebView:(UIWebView *)webView
{
    NSString *mraidCommand = [mraidURL host];
    
    if ([mraidCommand isEqualToString:@"expand"])
    {
        NSString *hiddenState = [webView stringByEvaluatingJavaScriptFromString:@"window.mraid.getState()"];
    
        if ([hiddenState isEqualToString:@"hidden"])
        {
            [webView setIsViewable:YES];
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

@end

@implementation UIWebView (MRAIDExtensions)

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
