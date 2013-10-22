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

#import "ANAdView.h"
#import "UIWebView+ANCategory.h"
#import "ANAdResponse.h"
#import "ANBrowserViewController.h"
#import "ANLocation.h"

@interface ANAdView () <ANBrowserViewControllerDelegate>
@end

@implementation ANAdView
@synthesize adSize = __adSize;
@synthesize clickShouldOpenInBrowser = __clickShouldOpenInBrowser;
@synthesize placementId = __placementId;
@synthesize adFetcher = __adFetcher;
@synthesize shouldServePublicServiceAnnouncements = __shouldServePublicServiceAnnouncements;
@synthesize location = __location;
@synthesize reserve = __reserve;
@synthesize age = __age;
@synthesize gender = __gender;
@synthesize customKeywords = __customKeywords;

- (id)init
{
	self = [super init];
	
	if (self != nil)
	{
		[self initialize];
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self != nil)
	{
		[self initialize];
	}
	
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self initialize];
}

- (void)initialize
{
	self.clipsToBounds = YES;
	self.adFetcher = [[ANAdFetcher alloc] init];
	self.adFetcher.delegate = self;
	self.adSize = CGSizeZero;
	self.shouldServePublicServiceAnnouncements = YES;
    self.location = nil;
    self.reserve = 0.0f;
    self.customKeywords = [[NSMutableDictionary alloc] init];
}

- (id)initWithFrame:(CGRect)frame placementId:(NSString *)placementId
{
    self = [self initWithFrame:frame];
    
    if (self != nil)
    {
        NSAssert([placementId intValue] > 0, @"Placement ID must be a number greater than 0.");
        self.placementId = placementId;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame placementId:(NSString *)placementId adSize:(CGSize)size
{
    self = [self initWithFrame:frame placementId:placementId];
    
    if (self != nil)
    {
        self.adSize = size;
    }
    
    return self;
}

- (void)setAdSize:(CGSize)adSize
{
	// Remove our existing ad if we change the ad size, since it's no longer valid
	self.contentView = nil;
	__adSize = adSize;
}

- (void)dealloc
{    
	[[NSNotificationCenter defaultCenter] removeObserver:self];	
	
	__adFetcher.delegate = nil;
    [__adFetcher stopAd]; // MUST be called. stopAd invalidates the autorefresh timer, which is retaining the adFetcher as well.
    
    if ([__contentView respondsToSelector:@selector(setDelegate:)])
    {
        // If our content is a UIWebview, we want to make sure to clear out the delegate if we're destroying it
		[__contentView performSelector:@selector(setDelegate:) withObject:nil];
    }
	
	[__contentView removeFromSuperview];
    [__closeButton removeFromSuperview];
}

- (NSString *)placementId
{
    ANLogDebug(@"placementId returned %@", __placementId);
    return __placementId;
}

- (NSString *)adType
{
	return nil;
}

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy
{
    self.location = [ANLocation getLocationWithLatitude:latitude
                                              longitude:longitude
                                              timestamp:timestamp
                                     horizontalAccuracy:horizontalAccuracy];
}

- (void)addCustomKeywordsWithKey:(NSString *)key value:(NSString *)value {
    if (([key length] < 1) || !value)
        return;
    
    [self.customKeywords setValue:value forKey:key];
}

- (void)removeCustomKeywordsWithKey:(NSString *)key {
    if (([key length] < 1))
        return;
    
    [self.customKeywords removeObjectForKey:key];
}

- (void)setPlacementId:(NSString *)placementId
{
    if (placementId != __placementId)
    {
        ANLogDebug(@"Setting placementId to %@", placementId);
        __placementId = placementId;
    }
}

#pragma mark ANAdFetcherDelegate

- (void)adFetcher:(ANAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdResponse *)response
{
    if ([response isSuccessful])
    {
        UIView *contentView = response.adObject;
		
		if ([contentView isKindOfClass:[UIView class]])
		{
			self.contentView = contentView;
		}
		else
		{
			ANLogFatal(@"Received non view object %@ for response %@", contentView, response);
		}
    }
}

- (NSTimeInterval)autorefreshIntervalForAdFetcher:(ANAdFetcher *)fetcher
{
    return 0.0;
}

- (NSString *)placementIdForAdFetcher:(ANAdFetcher *)fetcher
{
    return self.placementId;
}

- (CGSize)requestedSizeForAdFetcher:(ANAdFetcher *)fetcher
{
    return self.adSize;
}

- (NSString *)placementTypeForAdFetcher:(ANAdFetcher *)fetcher
{
    return self.adType;
}

- (ANLocation *)location {
    ANLogDebug(@"location returned %@", __location);
    return __location;
}

- (BOOL)shouldServePublicServiceAnnouncements {
    ANLogDebug(@"shouldServePublicServeAnnouncements returned %d", __shouldServePublicServiceAnnouncements);
    return __shouldServePublicServiceAnnouncements;
}

- (CGFloat)reserve {
    ANLogDebug(@"reserve returned %f", __reserve);
    return __reserve;
}

- (NSString *)age {
    ANLogDebug(@"age returned %@", __age);
    return __age;
}

- (ANGender)gender {
    ANLogDebug(@"gender returned %d", __gender);
    return __gender;
}

- (NSMutableDictionary *)customKeywords {
    ANLogDebug(@"customKeywords returned %@", __customKeywords);
    return __customKeywords;
}

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldResizeToSize:(CGSize)size
{
	
}

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldShowCloseButtonWithTarget:(id)target action:(SEL)action
{
	[self showCloseButtonWithTarget:target action:action];
}

- (void)adShouldRemoveCloseButtonWithAdFetcher:(ANAdFetcher *)fetcher
{
    [self removeCloseButton];
}

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldOpenInBrowserWithURL:(NSURL *)URL
{	
	if (self.clickShouldOpenInBrowser)
	{
		if ([[UIApplication sharedApplication] canOpenURL:URL])
		{
			[[UIApplication sharedApplication] openURL:URL];
		}
	}
	else
	{
		ANBrowserViewController *browserViewController = [[ANBrowserViewController alloc] initWithURL:URL];
		browserViewController.delegate = self;
		UIViewController *rootViewController = AppRootViewController();
		
		[rootViewController presentViewController:browserViewController animated:YES completion:nil];
	}
}

#pragma mark ANBrowserViewControllerDelegate

- (void)browserViewControllerShouldDismiss:(ANBrowserViewController *)controller
{
	UIViewController *presentingViewController = controller.presentingViewController;
	[presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation ANAdView (ANAdFetcher)

- (void)setContentView:(UIView *)contentView
{
    if (contentView != __contentView)
    {
        if (contentView != nil)
        {
            if ([contentView isKindOfClass:[UIWebView class]])
            {
                [(UIWebView *)contentView removeDocumentPadding];
            }
            
            [self addSubview:contentView];
        }
        
        [self removeCloseButton];
		
		[__contentView removeFromSuperview];

        if ([__contentView isKindOfClass:[UIWebView class]])
        {
            UIWebView *webView = (UIWebView *)__contentView;
            [webView setDelegate:nil];
            [webView stopLoading];
        }
		
        __contentView = contentView;
    }
}

- (UIView *)contentView
{
    return __contentView;
}

- (void)showCloseButtonWithTarget:(id)target action:(SEL)selector
{
    if ([self.closeButton superview] == nil)
    {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton addTarget:target
                        action:selector
              forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *closeButtonImage = [UIImage imageNamed:@"interstitial_closebox"];
        [closeButton setImage:closeButtonImage forState:UIControlStateNormal];
        [closeButton setImage:[UIImage imageNamed:@"interstitial_closebox_down"] forState:UIControlStateHighlighted];
        closeButton.frame = CGRectMake(self.bounds.size.width - closeButtonImage.size.width / 2 - 20.0, 4.0, closeButtonImage.size.width, closeButtonImage.size.height);
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        
        self.closeButton = closeButton;
        
        [self addSubview:closeButton];
    }
    else
    {
        ANLogError(@"Attempted to add a close button to ad view %@ with one already showing!", self);
    }
}

- (void)removeCloseButton
{
    [self.closeButton removeFromSuperview];
    self.closeButton = nil;
}

- (void)setCloseButton:(UIButton *)closeButton
{
    __closeButton = closeButton;
}

- (UIButton *)closeButton
{
    return __closeButton;
}

@end