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

#define DEFAULT_ADSIZE CGSizeZero
#define DEFAULT_PSAS YES

@interface ANAdView () <ANBrowserViewControllerDelegate, ANAdViewDelegate>
@property (nonatomic, readwrite, weak) id<ANAdDelegate> delegate;
@end

@implementation ANAdView
@synthesize adFetcher = __adFetcher;
@synthesize placementId = __placementId;
@synthesize adSize = __adSize;
@synthesize clickShouldOpenInBrowser = __clickShouldOpenInBrowser;
@synthesize shouldServePublicServiceAnnouncements = __shouldServePublicServiceAnnouncements;
@synthesize location = __location;
@synthesize reserve = __reserve;
@synthesize age = __age;
@synthesize gender = __gender;
@synthesize customKeywords = __customKeywords;

#pragma mark Abstract methods
/***
 * Subclasses should implement these methods
 ***/
- (NSString *)adType {
    return nil;
}

- (UIView *)adContentView {
    return nil;
}

- (UIView *)mraidDefaultParentView {
    return nil;
}

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldShowCloseButtonWithTarget:(id)target action:(SEL)action {}
- (void)openInBrowserWithController:(ANBrowserViewController *)browserViewController {}


#pragma mark Initialization

- (id)init {
    self = [super init];

    if (self != nil) {
        [self initialize];
    }

    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize {
    self.clipsToBounds = YES;
    __adFetcher = [[ANAdFetcher alloc] init];
    __adFetcher.delegate = self;
    __adSize = DEFAULT_ADSIZE;
    __shouldServePublicServiceAnnouncements = DEFAULT_PSAS;
    __location = nil;
    __reserve = 0.0f;
    __customKeywords = [[NSMutableDictionary alloc] init];
    __isFullscreen = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    __adFetcher.delegate = nil;
    [__adFetcher stopAd]; // MUST be called. stopAd invalidates the autorefresh timer, which is retaining the adFetcher as well.
    
    if ([__contentView respondsToSelector:@selector(setDelegate:)]) {
        // If our content is a UIWebview, we want to make sure to clear out the delegate if we're destroying it
        [__contentView performSelector:@selector(setDelegate:) withObject:nil];
    }

    __contentView = nil;
    __closeButton = nil;
}

- (void)mraidResizeAd:(CGSize)size
          contentView:(UIView *)contentView
    defaultParentView:(UIView *)defaultParentView
   rootViewController:(UIViewController *)rootViewController
             isBanner:(BOOL)isBanner {
    // expand to full screen
    if ((size.width == -1) || (size.height == -1)) {

        CGRect fullscreenFrame = [[UIScreen mainScreen] applicationFrame];
        fullscreenFrame.origin.x = 0;
        fullscreenFrame.origin.y = 20; // status bar offset
        contentView.frame = fullscreenFrame;
        [contentView removeFromSuperview];
        [rootViewController.view addSubview:self];
        self.isFullscreen = YES;
    } else {
        // otherwise, resize in the original container
        CGRect resizedFrame;
        if (isBanner) {
            resizedFrame = CGRectMake((self.frame.size.width - size.width) / 2,
                                         0,
                                         size.width, size.height);
        } else {
            resizedFrame = CGRectMake((defaultParentView.bounds.size.width - size.width) / 2,
                                             (defaultParentView.bounds.size.height - size.height) / 2,
                                             size.width, size.height);
        }
        if (self.isFullscreen) {
            [self removeFromSuperview];
            [defaultParentView addSubview:contentView];
            self.isFullscreen = NO;
        }
        [contentView setFrame:resizedFrame];
    }
}

#pragma mark Setter methods

- (void)setPlacementId:(NSString *)placementId {
    if (placementId != __placementId) {
        ANLogDebug(@"Setting placementId to %@", placementId);
        __placementId = placementId;
    }
}

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy {
    self.location = [ANLocation getLocationWithLatitude:latitude
                                              longitude:longitude
                                              timestamp:timestamp
                                     horizontalAccuracy:horizontalAccuracy];
}

- (void)addCustomKeywordWithKey:(NSString *)key value:(NSString *)value {
    if (([key length] < 1) || !value) {
        return;
    }
    
    [self.customKeywords setValue:value forKey:key];
}

- (void)removeCustomKeywordWithKey:(NSString *)key {
    if (([key length] < 1)) {
        return;
    }
    
    [self.customKeywords removeObjectForKey:key];
}

#pragma mark Getter methods

- (NSString *)placementId {
    ANLogDebug(@"placementId returned %@", __placementId);
    return __placementId;
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

#pragma mark ANAdFetcherDelegate

- (void)adFetcher:(ANAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdResponse *)response {
    if ([response isSuccessful]) {
        UIView *contentView = response.adObject;
		
		if ([contentView isKindOfClass:[UIView class]]) {
			self.contentView = contentView;
		}
		else {
			ANLogFatal(@"Received non view object %@ for response %@", contentView, response);
		}
    }
}

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldResizeToSize:(CGSize)size {}

- (NSTimeInterval)autorefreshIntervalForAdFetcher:(ANAdFetcher *)fetcher {
    return 0.0;
}

- (CGSize)requestedSizeForAdFetcher:(ANAdFetcher *)fetcher {
    return self.adSize;
}

- (NSString *)placementTypeForAdFetcher:(ANAdFetcher *)fetcher {
    return self.adType;
}

- (void)adShouldRemoveCloseButtonWithAdFetcher:(ANAdFetcher *)fetcher {
    [self removeCloseButton];
}

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldOpenInBrowserWithURL:(NSURL *)URL {
    NSString *scheme = [URL scheme];
    BOOL schemeIsHttp = ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]);
    
    if (!self.clickShouldOpenInBrowser && schemeIsHttp) {
        ANBrowserViewController *browserViewController = [[ANBrowserViewController alloc] initWithURL:URL];
        browserViewController.delegate = self;
        [self openInBrowserWithController:browserViewController];
    }
    else if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL];
    } else {
        ANLogWarn([NSString stringWithFormat:ANErrorString(@"opening_url_failed"), URL]);
    }
}

#pragma mark ANBrowserViewControllerDelegate

- (void)browserViewControllerShouldDismiss:(ANBrowserViewController *)controller
{
    UIViewController *presentingViewController = controller.presentingViewController;
    [presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ANAdViewDelegate

- (void)adWillPresent {
    if ([self.delegate respondsToSelector:@selector(adWillPresent:)]) {
        [self.delegate adWillPresent:self];
    }
}

- (void)adWillClose {
    if ([self.delegate respondsToSelector:@selector(adWillClose:)]) {
        [self.delegate adWillClose:self];
    }
}

- (void)adDidClose {
    if ([self.delegate respondsToSelector:@selector(adDidClose:)]) {
        [self.delegate adDidClose:self];
    }
}

- (void)adWillLeaveApplication {
    if ([self.delegate respondsToSelector:@selector(adWillLeaveApplication:)]) {
        [self.delegate adWillLeaveApplication:self];
    }
}

// also helper methods for calling other selectors
- (void)adDidReceiveAd {
    if ([self.delegate respondsToSelector:@selector(adDidReceiveAd:)]) {
        [self.delegate adDidReceiveAd:self];
    }
}

- (void)adRequestFailedWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(ad: requestFailedWithError:)]) {
        [self.delegate ad:self requestFailedWithError:error];
    }
}

@end

#pragma mark ANAdView (ANAdFetcher)

@implementation ANAdView (ANAdFetcher)

- (void)setContentView:(UIView *)contentView {
    if (contentView != __contentView) {
        if (contentView != nil) {
            if ([contentView isKindOfClass:[UIWebView class]]) {
                [(UIWebView *)contentView removeDocumentPadding];
            }
            
            [self addSubview:contentView];
        }
        
        [self removeCloseButton];
		
		[__contentView removeFromSuperview];
        
        if ([__contentView isKindOfClass:[UIWebView class]]) {
            UIWebView *webView = (UIWebView *)__contentView;
            [webView setDelegate:nil];
            [webView stopLoading];
        }
		
        __contentView = contentView;
    }
}

- (UIView *)contentView {
    return __contentView;
}

- (void)setIsFullscreen:(BOOL)isFullscreen {
    __isFullscreen = isFullscreen;
}

- (BOOL)isFullscreen {
    return __isFullscreen;
}

- (void)setCloseButton:(UIButton *)closeButton
{
    __closeButton = closeButton;
}

- (UIButton *)closeButton
{
    return __closeButton;
}

- (void)showCloseButtonWithTarget:(id)target action:(SEL)selector
                      contentView:(UIView *)contentView; {
    if ([self.closeButton superview] == nil) {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton addTarget:target
                        action:selector
              forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *closeButtonImage = [UIImage imageNamed:@"interstitial_closebox"];
        [closeButton setImage:closeButtonImage forState:UIControlStateNormal];
        [closeButton setImage:[UIImage imageNamed:@"interstitial_closebox_down"] forState:UIControlStateHighlighted];
        closeButton.frame = CGRectMake(contentView.bounds.size.width
                                       - closeButtonImage.size.width
                                       / 2 - 20.0, 4.0,
                                       closeButtonImage.size.width,
                                       closeButtonImage.size.height);
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        
        self.closeButton = closeButton;
        
        [contentView addSubview:closeButton];
    }
    else {
        ANLogError(@"Attempted to add a close button to ad view %@ with one already showing!", self);
    }
}

- (void)removeCloseButton
{
    [self.closeButton removeFromSuperview];
    self.closeButton = nil;
}

@end