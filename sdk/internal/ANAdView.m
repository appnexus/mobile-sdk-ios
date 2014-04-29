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

#import "ANAdFetcher.h"
#import "ANAdWebViewController.h"
#import "ANBrowserViewController.h"
#import "ANGlobal.h"
#import "ANInterstitialAd.h"
#import "ANLogging.h"
#import "ANMRAIDViewController.h"
#import "UIView+ANCategory.h"
#import "UIWebView+ANCategory.h"

#define DEFAULT_PSAS YES
#define CLOSE_BUTTON_OFFSET_X 4.0
#define CLOSE_BUTTON_OFFSET_Y 4.0

@interface ANAdView () <ANAdFetcherDelegate, ANAdViewDelegate,
ANBrowserViewControllerDelegate>

@property (nonatomic, readwrite, strong) UIView *contentView;
@property (nonatomic, readwrite, strong) UIButton *closeButton;
@property (nonatomic, readwrite, strong) ANAdFetcher *adFetcher;

@property (nonatomic, readwrite, weak) id<ANAdDelegate> delegate;
@property (nonatomic, readwrite, weak) id<ANAppEventDelegate> appEventDelegate;
@property (nonatomic, readwrite, assign) CGRect defaultFrame;
@property (nonatomic, readwrite, assign) CGRect defaultParentFrame;
@property (nonatomic, strong) ANMRAIDViewController *mraidController;
@property (nonatomic, readwrite, assign) BOOL isExpanded;
@property (nonatomic, readwrite) BOOL allowOrientationChange;
@property (nonatomic, readwrite) ANMRAIDOrientation forceOrientation;
@property (nonatomic, readwrite, strong) ANBrowserViewController *browserViewController;
@property (nonatomic, readwrite, assign) CGPoint resizeOffset;
@property (nonatomic, readwrite, assign) BOOL adjustFramesInResizeState;

@end

@implementation ANAdView
// ANAdProtocol properties
@synthesize placementId = __placementId;
@synthesize opensInNativeBrowser = __opensInNativeBrowser;
@synthesize clickShouldOpenInBrowser = __clickShouldOpenInBrowser;
@synthesize shouldServePublicServiceAnnouncements = __shouldServePublicServiceAnnouncements;
@synthesize location = __location;
@synthesize reserve = __reserve;
@synthesize age = __age;
@synthesize gender = __gender;
@synthesize customKeywords = __customKeywords;

// ANMRAIDEventReceiver
@synthesize mraidEventReceiverDelegate = __mraidEventReceiverDelegate;

#pragma mark Abstract methods
/***
 * Subclasses should implement these abstract methods
 ***/

// MRAIDAdViewDelegate methods
- (NSString *)adType { return nil; }
- (UIViewController *)displayController { return nil; }
- (void)adShouldResetToDefault {}
- (void)adShouldExpandToFrame:(CGRect)frame closeButton:(UIButton *)closeButton {}
- (void)adShouldResizeToFrame:(CGRect)frame allowOffscreen:(BOOL)allowOffscreen
                  closeButton:(UIButton *)closeButton
                closePosition:(ANMRAIDCustomClosePosition)closePosition {}

// AdFetcherDelegate methods
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
    self.adFetcher = [[ANAdFetcher alloc] init];
    self.adFetcher.delegate = self;
    self.defaultParentFrame = CGRectNull;
    self.defaultFrame = CGRectNull;
    self.allowOrientationChange = YES;
    self.forceOrientation = ANMRAIDOrientationNone;
    
    __shouldServePublicServiceAnnouncements = DEFAULT_PSAS;
    __location = nil;
    __reserve = 0.0f;
    __customKeywords = [[NSMutableDictionary alloc] init];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.adFetcher.delegate = nil;
    [self.adFetcher stopAd]; // MUST be called. stopAd invalidates the autoRefresh timer, which is retaining the adFetcher as well.
    
    if ([self.contentView respondsToSelector:@selector(setDelegate:)]) {
        // If our content is a UIWebview, we want to make sure to clear out the delegate if we're destroying it
        [self.contentView performSelector:@selector(setDelegate:) withObject:nil];
    }
}

- (void)loadAd {
    NSString *errorString;
    if ([self.placementId length] < 1) {
        errorString = ANErrorString(@"no_placement_id");
    }
    
    if (self.isExpanded) {
        errorString = ANErrorString(@"already_expanded");
    }
    
    if (errorString) {
        ANLogError(errorString);
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:errorString
                                                              forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:AN_ERROR_DOMAIN code:ANAdResponseInvalidRequest userInfo:errorInfo];
        [self adRequestFailedWithError:error];
        return;
    }
    
    [self.adFetcher stopAd];
    [self.adFetcher requestAd];
}


- (void)loadAdFromHtml:(NSString *)html
                 width:(int)width height:(int)height {
    ANAdResponse *response = [ANAdResponse new];
    response.content = html;
    response.width = [NSString stringWithFormat:@"%i", width];
    response.height = [NSString stringWithFormat:@"%i", height];
    response.isMraid = YES;
    response.containsAds = YES;
    
    [self.adFetcher processAdResponse:response];
}

- (void)allowOrientationChange:(BOOL)allowOrientationChange
         withForcedOrientation:(ANMRAIDOrientation)orientation {
    self.allowOrientationChange = allowOrientationChange;
    self.forceOrientation = orientation;
    [self updateOrientationPropertiesOnMRAIDViewController];
}

- (void)updateOrientationPropertiesOnMRAIDViewController {
    if (self.mraidController) {
        self.mraidController.allowOrientationChange = self.allowOrientationChange;
        self.mraidController.orientation = [[UIApplication sharedApplication] statusBarOrientation];

        if (!self.isExpanded) {
            switch(self.forceOrientation) {
                case ANMRAIDOrientationLandscape:
                    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
                        self.mraidController.orientation = UIInterfaceOrientationLandscapeRight;
                        break;
                    }
                    self.mraidController.orientation = UIInterfaceOrientationLandscapeLeft;
                    break;
                case ANMRAIDOrientationPortrait:
                    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) {
                        self.mraidController.orientation = UIInterfaceOrientationPortraitUpsideDown;
                        break;
                    }
                    self.mraidController.orientation = UIInterfaceOrientationPortrait;
                    break;
                default:
                    break;
            }
        }
    }
}

#pragma mark MRAID expand methods

- (void)mraidExpandAd:(CGSize)size
          contentView:(UIView *)contentView
    defaultParentView:(UIView *)defaultParentView
   rootViewController:(UIViewController *)rootViewController {
    
    [self adWillPresent];
    
    // set default frames for resetting later
    if (CGRectIsNull(self.defaultFrame)) {
        self.defaultParentFrame = defaultParentView.frame;
        self.defaultFrame = contentView.frame;
    }

    // expand to full screen
    if ((size.width == -1) && (size.height == -1)) {
        [contentView removeFromSuperview];
        
        self.mraidController = [ANMRAIDViewController new];
        [self updateOrientationPropertiesOnMRAIDViewController];
        
        self.mraidController.contentView = contentView;
        [self.mraidController.view addSubview:contentView];
        
        [rootViewController presentViewController:self.mraidController animated:NO completion:^{
            [self adDidPresent];
        }];
    } else {
        CGRect orientedScreenBounds = adjustAbsoluteRectInWindowCoordinatesForOrientationGivenRect([UIScreen mainScreen].bounds);
        if (size.width == -1) size.width = orientedScreenBounds.size.width;
        if (size.height == -1) size.height = orientedScreenBounds.size.height;
        
        // non-fullscreen expand
        CGRect expandedContentFrame = self.defaultFrame;
        expandedContentFrame.size = size;
        [contentView setFrame:expandedContentFrame];
        [contentView removeFromSuperview];
        
        CGRect expandedParentFrame = defaultParentView.frame;
        expandedParentFrame.size = size;
        [defaultParentView setFrame:expandedParentFrame];
        
        [defaultParentView addSubview:contentView];
        [self adDidPresent];
    }
    
    self.isExpanded = YES;
}

- (void)mraidExpandAddCloseButton:(UIButton *)closeButton
                    containerView:(UIView *)containerView {
    // remove any existing close button
    [self removeCloseButton];
    
    // place the close button in the top right
    CGFloat closeButtonOriginX = containerView.bounds.size.width
    - closeButton.frame.size.width - CLOSE_BUTTON_OFFSET_X;
    CGFloat closeButtonOriginY = CLOSE_BUTTON_OFFSET_Y;
    
    closeButton.frame = CGRectMake(closeButtonOriginX, closeButtonOriginY,
                                   closeButton.frame.size.width,
                                   closeButton.frame.size.height);
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    self.closeButton = closeButton;
    
    [containerView addSubview:closeButton];
}

#pragma mark MRAID resize methods

- (NSString *)mraidResizeAd:(CGRect)frame
                contentView:(UIView *)contentView
          defaultParentView:(UIView *)defaultParentView
         rootViewController:(UIViewController *)rootViewController
             allowOffscreen:(BOOL)allowOffscreen {
    NSString *mraidResizeErrorString = [self isResizeValid:contentView frameToResizeTo:frame];
    if ([mraidResizeErrorString length] > 0) return mraidResizeErrorString;
    
    // set default frames for resetting later
    if (CGRectIsNull(self.defaultFrame)) {
        self.defaultParentFrame = defaultParentView.frame;
        self.defaultFrame = contentView.frame;
    }
    
    self.adjustFramesInResizeState = NO;
    
    // resize contentView to new frame
    [contentView setFrame:CGRectMake(contentView.frame.origin.x, contentView.frame.origin.y, frame.size.width, frame.size.height)];

    /*
        Adjust the parent view to fit contentView.
        The parentView will realign the content view within its bounds.
    */
    [defaultParentView setFrame:CGRectMake(defaultParentView.frame.origin.x  + frame.origin.x,
                                           defaultParentView.frame.origin.y  + frame.origin.y,
                                           frame.size.width,
                                           frame.size.height)];
    
    self.adjustFramesInResizeState = YES;
    [self setResizeOffset:CGPointMake(frame.origin.x + self.resizeOffset.x, frame.origin.y + self.resizeOffset.y)];
    [self.mraidEventReceiverDelegate adDidChangeResizeOffset:self.resizeOffset];
    
    return nil;
}

- (NSString *)isResizeValid:(UIView *)contentView frameToResizeTo:(CGRect)frame {
    // for comparing to
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect orientedScreenBounds = adjustAbsoluteRectInWindowCoordinatesForOrientationGivenRect(screenBounds);
    
    // don't allow resizing to be larger than the screen in both directions
    if (frame.size.width > orientedScreenBounds.size.width && frame.size.height > orientedScreenBounds.size.height) {
        return @"Resize called with resizeProperties larger than the screen.";
    }
    
    CGRect contentAbsoluteFrame = [contentView convertRect:contentView.bounds toView:nil];
    CGRect adjustedContentAbsoluteFrame = adjustAbsoluteRectInWindowCoordinatesForOrientationGivenRect(contentAbsoluteFrame);
    
    // verify that at least 50x50 pixels of the creative are onscreen
    // by checking the intersection of the creative and the screen
    CGFloat allowedSize = 50.0f;
    CGRect contentFrame = contentView.frame;
    
    // the absolute x and y offset will only be changed
    // by the difference of the new frame and the old frame
    // the size will simply be the size given by resizeProperties
    CGRect resizedFrame = CGRectMake(adjustedContentAbsoluteFrame.origin.x + (frame.origin.x - contentFrame.origin.x),
                                     adjustedContentAbsoluteFrame.origin.y + (frame.origin.y - contentFrame.origin.y),
                                     frame.size.width,
                                     frame.size.height);
    
    // find the area of the resized creative that is on screen
    // if at least 50x50 is on the screen, then the resize is valid
    CGRect resizedIntersection = CGRectIntersection(orientedScreenBounds, resizedFrame);
    
    // if either the width or the height is smaller than the allowed size, then return an error.
    if (resizedIntersection.size.width < allowedSize || resizedIntersection.size.height < allowedSize) {
        return @"Resize call should keep at least 50x50 of the creative on screen";
    }
    
    // no errors
    return nil;
}

// returns true if position of closeEventRegion was valid, false if error
- (void)mraidResizeAddCloseEventRegion:(UIButton *)closeEventRegion
                         containerView:(UIView *)containerView
                           contentView:(UIView *)contentView
                              position:(ANMRAIDCustomClosePosition)position {
    // remove any existing close button
    [self removeCloseButton];
    
    CGFloat closeEventRegionSize = 50.0f;
    
    CGFloat contentWidth = contentView.frame.size.width;
    CGFloat contentHeight = contentView.frame.size.height;
    
    // different offset values for various possible closeEventRegion positions,
    // relative to the origin of the contentView
    CGFloat topY = 0.0f;
    CGFloat bottomY = contentHeight - closeEventRegionSize;
    CGFloat centerY = (contentHeight - closeEventRegionSize) / 2.0;
    CGFloat leftX = 0.0f;
    CGFloat rightX = contentWidth - closeEventRegionSize;
    CGFloat centerX = (contentWidth - closeEventRegionSize) / 2.0;
    
    // closeEventRegion will be a child of the container, so it needs to be
    // positioned based on contentView's origin
    CGFloat closeOriginX = contentView.frame.origin.x;
    CGFloat closeOriginY = contentView.frame.origin.y;
    
    switch (position) {
        case ANMRAIDTopLeft:
            closeOriginX += leftX;
            closeOriginY += topY;
            break;
        case ANMRAIDTopCenter:
            closeOriginX += centerX;
            closeOriginY += topY;
            break;
        case ANMRAIDTopRight:
            closeOriginX += rightX;
            closeOriginY += topY;
            break;
        case ANMRAIDCenter:
            closeOriginX += centerX;
            closeOriginY += centerY;
            break;
        case ANMRAIDBottomLeft:
            closeOriginX += leftX;
            closeOriginY += bottomY;
            break;
        case ANMRAIDBottomCenter:
            closeOriginX += centerX;
            closeOriginY += bottomY;
            break;
        case ANMRAIDBottomRight:
            closeOriginX += rightX;
            closeOriginY += bottomY;
            break;
            
        default:
            break;
    }
    
    // compute the absolute frame of the close event region
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGRect orientedScreenBounds = adjustAbsoluteRectInWindowCoordinatesForOrientationGivenRect(screenBounds);
    
    CGRect containerAbsoluteFrame = [containerView convertRect:containerView.bounds toView:nil];
    CGRect adjustedContainerAbsoluteFrame = adjustAbsoluteRectInWindowCoordinatesForOrientationGivenRect(containerAbsoluteFrame);
    
    CGFloat closeAbsoluteOriginX = adjustedContainerAbsoluteFrame.origin.x + closeOriginX;
    CGFloat closeAbsoluteOriginY = adjustedContainerAbsoluteFrame.origin.y + closeOriginY;
    CGRect closeAbsoluteFrame = CGRectMake(closeAbsoluteOriginX, closeAbsoluteOriginY,
                                           closeEventRegionSize, closeEventRegionSize);
    
    // verify that the requested close event region will be on the screen
    // container frame was adjusted for orientation, so we should compare the closeAbsoluteFrame with orientedScreenBounds
    BOOL isCloseEventRegionOnScreen = CGRectContainsRect(orientedScreenBounds, closeAbsoluteFrame);
    
    // if the requested close positioning is invalid,
    // put it in the top-left of the available space
    if (!isCloseEventRegionOnScreen) {
        CGRect contentAbsoluteFrame = [contentView convertRect:contentView.bounds toView:nil];
        CGRect adjustedContentAbsoluteFrame = adjustAbsoluteRectInWindowCoordinatesForOrientationGivenRect(contentAbsoluteFrame);
        
        CGRect contentIntersection = CGRectIntersection(orientedScreenBounds, adjustedContentAbsoluteFrame);
        closeOriginX = contentIntersection.origin.x - adjustedContainerAbsoluteFrame.origin.x;
        closeOriginY = contentIntersection.origin.y - adjustedContainerAbsoluteFrame.origin.y;
        
        // add image to the region since it will be in a different
        // place with no visual cue
        UIImage *closeButtonImage = [UIImage imageNamed:@"interstitial_closebox"];
        [closeEventRegion setImage:closeButtonImage forState:UIControlStateNormal];
        [closeEventRegion setImage:[UIImage imageNamed:@"interstitial_closebox_down"] forState:UIControlStateHighlighted];
    }
    closeEventRegion.frame = CGRectMake(closeOriginX, closeOriginY,
                                        closeEventRegionSize, closeEventRegionSize);
    closeEventRegion.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin;
    
    self.closeButton = closeEventRegion;
    
    [containerView addSubview:closeEventRegion];
}

- (void)removeCloseButton
{
    if (self.closeButton.superview) {
        [self.closeButton removeFromSuperview];
    }
    self.closeButton = nil;
}

#pragma mark Setter methods

- (void)setPlacementId:(NSString *)placementId {
    placementId = convertToNSString(placementId);
    if ([placementId length] < 1) {
        ANLogError(@"Could not set placementId to non-string value");
        return;
    }
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

- (void)setContentView:(UIView *)contentView {
    if (contentView != _contentView) {
        [self removeCloseButton];
		
        if ([_contentView isKindOfClass:[UIWebView class]]) {
            UIWebView *webView = (UIWebView *)_contentView;
            [webView stopLoading];
            [webView setDelegate:nil];
        }
		
        [_contentView removeSubviews];
		[_contentView removeFromSuperview];
        [self removeSubviews];
        
        if (contentView != nil) {
            if ([contentView isKindOfClass:[UIWebView class]]) {
                UIWebView *webView = (UIWebView *)contentView;
                [webView removeDocumentPadding];
                [webView setMediaProperties];
            }
            
            [self addSubview:contentView];
        }
        
        _contentView = contentView;
    }
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

// This property is deprecated, use "opensInNativeBrowser" instead
- (BOOL)clickShouldOpenInBrowser {
    return self.opensInNativeBrowser;
}

- (BOOL)opensInNativeBrowser {
    BOOL opensInNativeBrowser = (__opensInNativeBrowser || __clickShouldOpenInBrowser);
    ANLogDebug(@"opensInNativeBrowser returned %d", opensInNativeBrowser);
    return opensInNativeBrowser;
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

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldOpenInBrowserWithURL:(NSURL *)URL {
    [self adWasClicked];
    
    if (!self.opensInNativeBrowser && hasHttpPrefix([URL scheme])) {
        if (!self.browserViewController) {
            self.browserViewController = [[ANBrowserViewController alloc] initWithURL:URL];
            self.browserViewController.delegate = self;
        } else {
            ANLogDebug(@"%@ %@ | Attempt to instantiate ANBrowserViewController when one is already being instantiated.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
    }
    else if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [self adWillLeaveApplication];
        [[UIApplication sharedApplication] openURL:URL];
    } else {
        ANLogWarn([NSString stringWithFormat:ANErrorString(@"opening_url_failed"), URL]);
    }
}
#pragma mark ANMRAIDAdViewDelegate

- (void)adShouldResetToDefault:(UIView *)contentView
                    parentView:(UIView *)parentView {
    if (self.isExpanded) [self adWillClose];

    [self removeCloseButton];
    self.adjustFramesInResizeState = NO;
    
    [contentView setFrame:self.defaultFrame];
    [contentView removeFromSuperview];
    [parentView setFrame:self.defaultParentFrame];
    [parentView addSubview:contentView];
    
    self.defaultParentFrame = CGRectNull;
    self.defaultFrame = CGRectNull;
    [self setResizeOffset:CGPointZero];
    [self.mraidEventReceiverDelegate adDidChangeResizeOffset:self.resizeOffset];

    if (self.mraidController) {
        [self.mraidController dismissViewControllerAnimated:NO completion:^{
            if (self.isExpanded) [self adDidClose];
        }];
        self.mraidController = nil;
    } else if (self.isExpanded) [self adDidClose];
    self.isExpanded = NO;
    
    [self.mraidEventReceiverDelegate adDidResetToDefault];
}

#pragma mark ANBrowserViewControllerDelegate

- (void)browserViewControllerShouldDismiss:(ANBrowserViewController *)controller {
    UIViewController *presentingViewController = controller.presentingViewController;
    [presentingViewController dismissViewControllerAnimated:YES completion:^ {
        self.browserViewController = nil;
    }];
}

- (void)browserViewControllerWillLaunchExternalApplication {
    [self adWillLeaveApplication];
}

- (void)browserViewControllerShouldPresent:(ANBrowserViewController *)controller {
    if (self.mraidController.presentingViewController) {
        [self.mraidController presentViewController:controller animated:YES completion:nil];
    } else {
        [self openInBrowserWithController:controller];
    }
}

- (void)browserViewControllerWillNotPresent:(ANBrowserViewController *)controller {
    ANLogWarn(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.browserViewController = nil;
}

#pragma mark ANAdViewDelegate

- (void)adWasClicked {
    if ([self.delegate respondsToSelector:@selector(adWasClicked:)]) {
        [self.delegate adWasClicked:self];
    }
}

- (void)adWillPresent {
    if ([self.delegate respondsToSelector:@selector(adWillPresent:)]) {
        [self.delegate adWillPresent:self];
    }
}

- (void)adDidPresent {
    if ([self.delegate respondsToSelector:@selector(adDidPresent:)]) {
        [self.delegate adDidPresent:self];
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

- (void)adDidReceiveAppEvent:(NSString *)name withData:(NSString *)data {
    if ([self.appEventDelegate respondsToSelector:@selector(ad:didReceiveAppEvent:withData:)]) {
        [self.appEventDelegate ad:self didReceiveAppEvent:name withData:data];
    }
}

- (void)adFailedToDisplay {
    if ([self isMemberOfClass:[ANInterstitialAd class]]
        && [self.delegate conformsToProtocol:@protocol(ANInterstitialAdDelegate)]) {
        ANInterstitialAd *interstitialAd = (ANInterstitialAd *)self;
        id<ANInterstitialAdDelegate> interstitialDelegate = (id<ANInterstitialAdDelegate>) self.delegate;
        if ([interstitialDelegate respondsToSelector:@selector(adFailedToDisplay:)]) {
            [interstitialDelegate adFailedToDisplay:interstitialAd];
        }
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
