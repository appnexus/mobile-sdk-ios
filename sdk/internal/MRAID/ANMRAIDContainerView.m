/*   Copyright 2014 APPNEXUS INC
 
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

#import "ANMRAIDContainerView.h"
#import "UIView+ANCategory.h"
#import "ANGlobal.h"
#import "ANMRAIDResizeViewManager.h"
#import "ANAdViewInternalDelegate.h"
#import "ANMRAIDCalendarManager.h"
#import "ANMRAIDExpandViewController.h"
#import "ANMRAIDExpandProperties.h"
#import "ANMRAIDOrientationProperties.h"
#import "ANLogging.h"
#import "ANBrowserViewController.h"
#import "ANClickOverlayView.h"
#import "ANPBBuffer.h"
#import "ANANJAMImplementation.h"
#import "ANInterstitialAdViewController.h"


typedef NS_OPTIONS(NSUInteger, ANMRAIDContainerViewAdInteraction)
{
    ANMRAIDContainerViewAdInteractionExpandedOrResized = 1 << 0,
    ANMRAIDContainerViewAdInteractionVideo = 1 << 1,
    ANMRAIDContainerViewAdInteractionBrowser = 1 << 2,
    ANMRAIDContainerViewAdInteractionCalendar = 1 << 3,
    ANMRAIDContainerViewAdInteractionPicture = 1 << 4
};




@interface ANMRAIDContainerView() <   ANBrowserViewControllerDelegate,

                                      ANAdWebViewControllerANJAMDelegate,
                                      ANAdWebViewControllerBrowserDelegate, 
                                      ANAdWebViewControllerLoadingDelegate,
                                      ANAdWebViewControllerMRAIDDelegate, 
                                      ANAdWebViewControllerPitbullDelegate,
                                      ANAdWebViewControllerVideoDelegate,
                                      ANMRAIDCalendarManagerDelegate, 
                                      ANMRAIDExpandViewControllerDelegate,
                                      ANMRAIDResizeViewManagerDelegate
                                  >

@property (nonatomic, readwrite, assign) CGSize size;
@property (nonatomic, readwrite, strong) NSURL *baseURL;

@property (nonatomic, readwrite, strong) ANAdWebViewController          *webViewController;
@property (nonatomic, readwrite, strong) ANBrowserViewController        *browserViewController;
@property (nonatomic, readwrite, strong) ANMRAIDCalendarManager         *calendarManager;
@property (nonatomic, readwrite, strong) ANMRAIDExpandViewController    *expandController;
@property (nonatomic, readwrite, strong) ANMRAIDOrientationProperties   *orientationProperties;
@property (nonatomic, readwrite, strong) ANMRAIDResizeViewManager       *resizeManager;

@property (nonatomic, readwrite, strong)  ANInterstitialAdViewController  *VASTVideofullScreenController;

@property (nonatomic, readwrite, assign) BOOL useCustomClose;
@property (nonatomic, readwrite, strong) UIButton *customCloseRegion;

@property (nonatomic, readwrite, strong) ANClickOverlayView *clickOverlay;

@property (nonatomic, readwrite, strong) NSMutableArray *pitbullCaptureURLQueue;
@property (nonatomic, readwrite, assign) BOOL isRegisteredForPitbullScreenCaptureNotifications;

@property (nonatomic, readwrite, assign) BOOL adInteractionInProgress;
@property (nonatomic, readwrite, assign) NSUInteger adInteractionValue;

@property (nonatomic, readwrite)                            BOOL  isBannerVideo;
@property (nonatomic, readonly, assign, getter=isExpanded)  BOOL  expanded;
@property (nonatomic, readonly, assign, getter=isResized)   BOOL  resized;
@property (nonatomic, readwrite)                            BOOL  isFullscreen;


@property (nonatomic, readwrite, assign) CGRect lastKnownDefaultPosition;
@property (nonatomic, readwrite, assign) CGRect lastKnownCurrentPosition;

@property (nonatomic, readwrite, strong)  ANAdWebViewController  *expandWebViewController;

@property (nonatomic, readwrite, assign) BOOL userInteractedWithContentView;

@property (nonatomic, readwrite, assign) BOOL responsiveAd;

@end




@implementation ANMRAIDContainerView

#pragma mark - Lifecycle.

- (instancetype) initWithSize:(CGSize)size
{
    CGSize   initialSize    = size;
    BOOL     responsiveAd   = NO;

    if (CGSizeEqualToSize(initialSize, CGSizeMake(1, 1))) {
        responsiveAd = YES;
        initialSize = ANPortraitScreenBounds().size;
    }

    CGRect  initialRect  = CGRectMake(0, 0, initialSize.width, initialSize.height);

    self = [super initWithFrame:initialRect];
    if (!self)  { return nil; }

    //
    _size = size;
    _responsiveAd = responsiveAd;

    _lastKnownCurrentPosition = initialRect;
    _lastKnownDefaultPosition = initialRect;

    _isBannerVideo = NO;

    self.backgroundColor = [UIColor clearColor];

    self.isFullscreen                       = NO;
    
    return self;
}

- (instancetype)initWithSize:(CGSize)size
                        HTML:(NSString *)html
              webViewBaseURL:(NSURL *)baseURL
{
    self = [self initWithSize:size];

    if (self) {
        _baseURL = baseURL;

        self.webViewController = [[ANAdWebViewController alloc] initWithSize: _lastKnownCurrentPosition.size
                                                                        HTML: html
                                                              webViewBaseURL: baseURL];

        self.webViewController.anjamDelegate    = self;
        self.webViewController.browserDelegate  = self;
        self.webViewController.loadingDelegate  = self;
        self.webViewController.mraidDelegate    = self;
        self.webViewController.pitbullDelegate  = self;
    }

    return self;
}

- (instancetype)initWithSize: (CGSize)size
                    videoXML: (NSString *)videoXML
{
    self = [self initWithSize:size];

    if (!self)  { return nil; }

    self.webViewController = [[ANAdWebViewController alloc] initWithSize: _lastKnownCurrentPosition.size
                                                                videoXML: videoXML ];

    self.webViewController.anjamDelegate    = self;
    self.webViewController.browserDelegate  = self;
    self.webViewController.loadingDelegate  = self;
    self.webViewController.mraidDelegate    = self;
    self.webViewController.pitbullDelegate  = self;

    self.webViewController.videoDelegate    = self;
    self.isBannerVideo = YES;

    return self;
}

#pragma mark - Getters/setters.

- (void)setAdViewDelegate:(id<ANAdViewInternalDelegate>)adViewDelegate
{
    _adViewDelegate                                     = adViewDelegate;
    self.webViewController.adViewDelegate               = adViewDelegate;
    self.webViewController.adViewANJAMDelegate          = adViewDelegate;
    self.expandWebViewController.adViewDelegate         = adViewDelegate;
    self.expandWebViewController.adViewANJAMDelegate    = adViewDelegate;

    if ([adViewDelegate conformsToProtocol:@protocol(ANInterstitialAdViewInternalDelegate)])
    {
        id<ANInterstitialAdViewInternalDelegate>  interstitialDelegate  = (id<ANInterstitialAdViewInternalDelegate>)adViewDelegate;

        [interstitialDelegate adShouldSetOrientationProperties:self.orientationProperties];
        [interstitialDelegate adShouldUseCustomClose:self.useCustomClose];

        if (self.useCustomClose) {
            [self addSupplementaryCustomCloseRegion];
        }
    }
}

- (void)setAdInteractionInProgress:(BOOL)adInteractionInProgress {
    BOOL oldValue = _adInteractionInProgress;
    _adInteractionInProgress = adInteractionInProgress;
    BOOL newValue = _adInteractionInProgress;
    if (oldValue != newValue) {
        if (_adInteractionInProgress) {
            [self.adViewDelegate adInteractionDidBegin];
        } else {
            [self.adViewDelegate adInteractionDidEnd];
        }
    }
}

#pragma mark - Helper methods.

- (UIViewController *)displayController {
    
    UIViewController *presentingVC = nil;
    
    if(self.isExpanded){
        presentingVC = self.expandController;
    } else if(self.isFullscreen){
        presentingVC = self.VASTVideofullScreenController;
    } else {
        presentingVC = [self.adViewDelegate displayController];
    }
    
    if (ANCanPresentFromViewController(presentingVC)) {
        return presentingVC;
    }
    return nil;
}

- (void)adInteractionBeganWithInteraction:(ANMRAIDContainerViewAdInteraction)interaction {
    self.adInteractionValue = self.adInteractionValue | interaction;
    self.adInteractionInProgress = self.adInteractionValue != 0;
}

- (void)adInteractionEndedForInteraction:(ANMRAIDContainerViewAdInteraction)interaction {
    self.adInteractionValue = self.adInteractionValue & ~interaction;
    self.adInteractionInProgress = self.adInteractionValue != 0;
}


#pragma mark - User Interaction Testing

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *viewThatWasHit = [super hitTest:point withEvent:event];
    if (!self.userInteractedWithContentView && [viewThatWasHit isDescendantOfView:self.webViewController.contentView]) {
        ANLogDebug(@"Detected user interaction with ad");
        self.userInteractedWithContentView = YES;
    }
    return viewThatWasHit;
}


#pragma mark - ANBrowserViewControllerDelegate

- (UIViewController *)rootViewControllerForDisplayingBrowserViewController:(ANBrowserViewController *)controller
{
    return [self displayController];
}

- (void) browserViewController: (ANBrowserViewController *)controller
              browserIsLoading: (BOOL)isLoading
{
    if ([self.adViewDelegate landingPageLoadsInBackground]) {
        if (!controller.completedInitialLoad) {
            isLoading ? [self showClickOverlay] : [self hideClickOverlay];
        } else {
            [self hideClickOverlay];
        }
    }
}

- (void) browserViewController: (ANBrowserViewController *)controller
      couldNotHandleInitialURL: (NSURL *)url
{
    [self adInteractionEndedForInteraction:ANMRAIDContainerViewAdInteractionBrowser];
}

- (void)handleBrowserLoadingForMRAIDStateChange
{
    [self.browserViewController stopLoading];
    [self adInteractionEndedForInteraction:ANMRAIDContainerViewAdInteractionBrowser];
}

- (void)willPresentBrowserViewController:(ANBrowserViewController *)controller
{
    if (!self.embeddedInModalView && !self.isExpanded) {
        [self.adViewDelegate adWillPresent];
    }
    self.resizeManager.resizeView.hidden = YES;
    [self adInteractionBeganWithInteraction:ANMRAIDContainerViewAdInteractionBrowser];
}

- (void)didPresentBrowserViewController:(ANBrowserViewController *)controller
{
    if (!self.embeddedInModalView && !self.isExpanded) {
        [self.adViewDelegate adDidPresent];

        
    }
}

- (void)willDismissBrowserViewController:(ANBrowserViewController *)controller
{
    if (!self.embeddedInModalView && !self.isExpanded)
    {
        [self.adViewDelegate adWillClose];
    }

    if (self.shouldDismissOnClick) {
        [controller dismissViewControllerAnimated:NO completion:nil];
    }

    self.resizeManager.resizeView.hidden = NO;
}

- (void)didDismissBrowserViewController:(ANBrowserViewController *)controller
{
    self.browserViewController = nil;

    if (!self.embeddedInModalView && !self.isExpanded) {
        [self.adViewDelegate adDidClose];
    }

    [self hideClickOverlay];
    [self adInteractionEndedForInteraction:ANMRAIDContainerViewAdInteractionBrowser];
}

- (void)willLeaveApplicationFromBrowserViewController:(ANBrowserViewController *)controller {
    [self.adViewDelegate adWillLeaveApplication];
}

# pragma mark - Click overlay

- (void)showClickOverlay {
    if (!self.clickOverlay.superview) {
        self.clickOverlay = [ANClickOverlayView addOverlayToView:[self viewToDisplayClickOverlay]];
        self.clickOverlay.alpha = 0.0;
    }

    if (!CGAffineTransformIsIdentity(self.transform)) {
        // In the case that ANMRAIDContainerView is magnified it is necessary to invert this magnification for the click overlay
        self.clickOverlay.transform = CGAffineTransformInvert(self.transform);
    }

    self.clickOverlay.hidden = NO;

    [UIView animateWithDuration:0.5
                     animations:^{
                         self.clickOverlay.alpha = 1.0;
                     }];
}

- (UIView *)viewToDisplayClickOverlay {
    if (self.isExpanded) {
        return self.expandController.view;
    } else if(self.isFullscreen){
        return self.VASTVideofullScreenController.view;
    }
    else if (self.isResized) {
        return self.resizeManager.resizeView;
    } else {
        return self;
    }
}

- (void)hideClickOverlay {
    if ([self.clickOverlay superview]) {
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.clickOverlay.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             self.clickOverlay.hidden = YES;
                         }];
    }
}




#pragma mark - ANWebViewControllerANJAMDelegate

- (void) handleANJAMURL:(NSURL *)URL
{
    [ANANJAMImplementation handleURL:URL withWebViewController:self.webViewController];
}




#pragma mark - ANWebViewControllerBrowserDelegate

- (void)openDefaultBrowserWithURL:(NSURL *)URL
{
    if (!self.adViewDelegate) {
        ANLogDebug(@"Ignoring attempt to trigger browser on ad while not attached to a view.");
        return;
    }
    if (!self.userInteractedWithContentView) {
        ANLogDebug(@"Ignoring attempt to trigger browser as no hit was registered on the ad");
        return;
    }

    [self.adViewDelegate adWasClicked];

    if (![self.adViewDelegate opensInNativeBrowser]) {
        [self openInAppBrowserWithURL:URL];
    }
    else if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [self.adViewDelegate adWillLeaveApplication];
        [ANGlobal openURL:[URL absoluteString]];
    } else {
        ANLogWarn(@"opening_url_failed %@", URL);
    }
}

- (void)openInAppBrowserWithURL:(NSURL *)URL {
    if (!self.userInteractedWithContentView) {
        ANLogDebug(@"Ignoring attempt to trigger browser as no hit was registered on the ad");
        return;
    }

    [self adInteractionBeganWithInteraction:ANMRAIDContainerViewAdInteractionBrowser];
    if (!self.browserViewController) {
        self.browserViewController = [[ANBrowserViewController alloc] initWithURL:URL
                                                                         delegate:self
                                                         delayPresentationForLoad:[self.adViewDelegate landingPageLoadsInBackground]];
        if (!self.browserViewController) {
            ANLogError(@"Browser controller did not instantiate correctly.");
            return;
        }
    } else {
        self.browserViewController.url = URL;
    }
}

#pragma mark - ANAdWebViewControllerLoadingDelegate

- (void)didCompleteFirstLoadFromWebViewController:(ANAdWebViewController *)controller
{
    if (controller == self.webViewController)
    {
        // Attaching WKWebView to screen for an instant to allow it to fully load in the background
        //   before the call to [ANAdDelegate adDidReceiveAd].
        //
        // NB  For banner video, this step has already occured in [ANAdViewWebController initWithSize:videoXML:].
        //
        if (! self.isBannerVideo) {
            self.webViewController.contentView.hidden = YES;
            [[UIApplication sharedApplication].keyWindow insertSubview:self.webViewController.contentView
                                                               atIndex:0];
        }

        __weak ANMRAIDContainerView  *weakSelf  = self;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.15 * NSEC_PER_SEC), dispatch_get_main_queue(),
        ^{
            __strong ANMRAIDContainerView  *strongSelf  = weakSelf;
            if (!strongSelf)  {
                ANLogError(@"COULD NOT ACQUIRE strongSelf.");
                return;
            }

            UIView  *contentView  = strongSelf.webViewController.contentView;

            contentView.translatesAutoresizingMaskIntoConstraints = NO;

            [strongSelf addSubview:contentView];
            strongSelf.webViewController.contentView.hidden = NO;

            [contentView an_constrainToSizeOfSuperview];
            [contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeLeft
                                                yAttribute:NSLayoutAttributeTop];

            [strongSelf.loadingDelegate didCompleteFirstLoadFromWebViewController:controller];
        });
    }
}

- (void) immediatelyRestartAutoRefreshTimerFromWebViewController:(ANAdWebViewController *)controller
{
    if ([self.loadingDelegate respondsToSelector:@selector(immediatelyRestartAutoRefreshTimerFromWebViewController:)]) {
        [self.loadingDelegate immediatelyRestartAutoRefreshTimerFromWebViewController:controller];
    }
}

- (void) stopAutoRefreshTimerFromWebViewController:(ANAdWebViewController *)controller
{
    if ([self.loadingDelegate respondsToSelector:@selector(stopAutoRefreshTimerFromWebViewController:)]) {
        [self.loadingDelegate stopAutoRefreshTimerFromWebViewController:controller];
    }
}




#pragma mark - ANAdWebViewControllerMRAIDDelegate

- (CGRect)defaultPosition {
    if (self.window) {
        CGRect absoluteContentViewFrame = [self convertRect:self.bounds toView:nil];
        CGRect position = ANAdjustAbsoluteRectInWindowCoordinatesForOrientationGivenRect(absoluteContentViewFrame);
        position.origin.y -= ([ANMRAIDUtil screenSize].height - [ANMRAIDUtil maxSize].height);
        if (!CGAffineTransformIsIdentity(self.transform)) {
            // In the case of a magnified webview, need to pass the non-magnified size to the webview
            position.size = [self an_originalFrame].size;
        }
        self.lastKnownDefaultPosition = position;
        return position;
    } else {
        return self.lastKnownDefaultPosition;
    }
}

- (CGRect)currentPosition {
    UIView *contentView = self.webViewController.contentView;
    if (self.expandWebViewController.contentView.window) {
        contentView = self.expandWebViewController.contentView;
    }
    
    if (contentView) {
        CGRect absoluteContentViewFrame = [contentView convertRect:contentView.bounds toView:nil];
        CGRect position = ANAdjustAbsoluteRectInWindowCoordinatesForOrientationGivenRect(absoluteContentViewFrame);
        position.origin.y -= ([ANMRAIDUtil screenSize].height - [ANMRAIDUtil maxSize].height);
        if (!CGAffineTransformIsIdentity(self.transform)) {
            // In the case of a magnified webview, need to pass the non-magnified size to the webview
            position.size = [contentView an_originalFrame].size;
        }
        self.lastKnownCurrentPosition = position;
        return position;
    } else {
        return self.lastKnownCurrentPosition;
    }
}

- (BOOL)isViewable {
    if (self.isBannerVideo) {
        return  [self.webViewController.contentView an_isAtLeastHalfViewable];

    } else {
        return  self.expandWebViewController    ? [self.expandWebViewController.contentView an_isViewable]
                                                : [self.webViewController.contentView an_isViewable];
    }
}

- (CGFloat)exposedPercent{
    return self.expandWebViewController    ? [self.expandWebViewController.contentView an_exposedPercentage]
                                           : [self.webViewController.contentView an_exposedPercentage];
    
}
- (CGRect)visibleRect{
    return self.expandWebViewController    ? [self.expandWebViewController.contentView an_visibleRectangle]
                                           : [self.webViewController.contentView an_visibleRectangle];
}

- (void)adShouldExpandWithExpandProperties:(ANMRAIDExpandProperties *)expandProperties {
    UIViewController *presentingController = [self displayController];
    if (!presentingController) {
        ANLogDebug(@"Ignoring call to mraid.expand() - no root view controller to present from");
        return;
    }
    if (!self.userInteractedWithContentView) {
        ANLogDebug(@"Ignoring attempt to expand ad as no hit was detected on ad");
        return;
    }
    
    [self handleBrowserLoadingForMRAIDStateChange];
    [self adInteractionBeganWithInteraction:ANMRAIDContainerViewAdInteractionExpandedOrResized];
    
    ANLogDebug(@"Expanding with expand properties: %@", [expandProperties description]);
    [self.adViewDelegate adWillPresent];
    if (self.isResized) {
        [self.resizeManager detachResizeView];
        self.resizeManager = nil;
    }
    
    UIView *expandContentView = self.webViewController.contentView;

    BOOL presentWithAnimation = NO;
    
    if (expandProperties.URL.absoluteString.length)
    {
        ANAdWebViewControllerConfiguration *customConfig = [[ANAdWebViewControllerConfiguration alloc] init];

        customConfig.scrollingEnabled = YES;
        customConfig.navigationTriggersDefaultBrowser = NO;
        customConfig.initialMRAIDState = ANMRAIDStateExpanded;
        customConfig.userSelectionEnabled = YES;

        self.expandWebViewController = [[ANAdWebViewController alloc] initWithSize: [ANMRAIDUtil screenSize]
                                                                               URL: expandProperties.URL
                                                                    webViewBaseURL: self.baseURL
                                                                     configuration: customConfig];
        self.expandWebViewController.mraidDelegate = self;
        self.expandWebViewController.browserDelegate = self;
        self.expandWebViewController.pitbullDelegate = self;
        self.expandWebViewController.anjamDelegate = self;
        self.expandWebViewController.adViewDelegate = self.adViewDelegate;

        expandContentView = self.expandWebViewController.contentView;
        presentWithAnimation = YES;
    }
    
    self.expandController = [[ANMRAIDExpandViewController alloc] initWithContentView:expandContentView
                                                                    expandProperties:expandProperties];
    if (self.orientationProperties) {
        [self adShouldSetOrientationProperties:self.orientationProperties];
    }
    self.expandController.delegate = self;

    [presentingController presentViewController: self.expandController
                                       animated: presentWithAnimation
                                     completion: ^{
                                             [self.adViewDelegate adDidPresent];
                                             [self.webViewController adDidFinishExpand];
                                         }
     ];
}

- (void)adShouldSetOrientationProperties:(ANMRAIDOrientationProperties *)orientationProperties {
    ANLogDebug(@"Setting orientation properties: %@", [orientationProperties description]);
    self.orientationProperties = orientationProperties;
    if (self.expandController) {
        self.expandController.orientationProperties = orientationProperties;
    } else if ([self.adViewDelegate conformsToProtocol:@protocol(ANInterstitialAdViewInternalDelegate)]) {
        id<ANInterstitialAdViewInternalDelegate> interstitialDelegate = (id<ANInterstitialAdViewInternalDelegate>)self.adViewDelegate;
        [interstitialDelegate adShouldSetOrientationProperties:orientationProperties];
    }
}

- (void)adShouldSetUseCustomClose:(BOOL)useCustomClose {
    ANLogDebug(@"Setting useCustomClose: %d", useCustomClose);
    self.useCustomClose = useCustomClose;
    if ([self.adViewDelegate conformsToProtocol:@protocol(ANInterstitialAdViewInternalDelegate)]) {
        id<ANInterstitialAdViewInternalDelegate> interstitialDelegate = (id<ANInterstitialAdViewInternalDelegate>)self.adViewDelegate;
        [interstitialDelegate adShouldUseCustomClose:useCustomClose];
        if (useCustomClose) {
            [self addSupplementaryCustomCloseRegion];
        }
    }
}

- (void)addSupplementaryCustomCloseRegion
{
    self.customCloseRegion = [UIButton buttonWithType:UIButtonTypeCustom];
    self.customCloseRegion.translatesAutoresizingMaskIntoConstraints = NO;

    [self insertSubview:self.customCloseRegion
           aboveSubview:self.webViewController.contentView];

    [self.customCloseRegion an_constrainWithSize:CGSizeMake(50.0, 50.0)];
    [self.customCloseRegion an_alignToSuperviewWithXAttribute:NSLayoutAttributeRight
                                                   yAttribute:NSLayoutAttributeTop];

    [self.customCloseRegion addTarget: self
                               action: @selector(closeInterstitial:)
                     forControlEvents: UIControlEventTouchUpInside];
}

- (void)closeInterstitial:(id)sender {
    if ([self.adViewDelegate conformsToProtocol:@protocol(ANInterstitialAdViewInternalDelegate)]) {
        id<ANInterstitialAdViewInternalDelegate> interstitialDelegate = (id<ANInterstitialAdViewInternalDelegate>)self.adViewDelegate;
        [interstitialDelegate adShouldClose];
    }
}

- (void)adShouldAttemptResizeWithResizeProperties:(ANMRAIDResizeProperties *)resizeProperties {
    if (!self.userInteractedWithContentView) {
        ANLogDebug(@"Ignoring attempt to resize ad as no hit was detected on ad");
        return;
    }

    ANLogDebug(@"Attempting resize with resize properties: %@", [resizeProperties description]);
    [self handleBrowserLoadingForMRAIDStateChange];
    [self adInteractionBeganWithInteraction:ANMRAIDContainerViewAdInteractionExpandedOrResized];
    
    if (!self.resizeManager) {
        self.resizeManager = [[ANMRAIDResizeViewManager alloc] initWithContentView:self.webViewController.contentView
                                                                        anchorView:self];
        self.resizeManager.delegate = self;
    }
    
    NSString *errorString;
    BOOL resizeHappened = [self.resizeManager attemptResizeWithResizeProperties:resizeProperties
                                                                    errorString:&errorString];
    [self.webViewController adDidFinishResize:resizeHappened
                                  errorString:errorString
                                    isResized:self.isResized];
    if (!self.isResized) {
        [self adInteractionEndedForInteraction:ANMRAIDContainerViewAdInteractionExpandedOrResized];
    }
}

- (void)adShouldClose {
    if (self.isResized || self.isExpanded) {
        [self adShouldResetToDefault];
    } else {
        [self adShouldHide];
    }
    
    [self adInteractionEndedForInteraction:ANMRAIDContainerViewAdInteractionExpandedOrResized];
}

- (void)adShouldResetToDefault {
    [self.resizeManager detachResizeView];
    self.resizeManager = nil;

    [self handleBrowserLoadingForMRAIDStateChange];
    
    if (self.isExpanded) {
        [self.adViewDelegate adWillClose];
        
        BOOL dismissWithAnimation = NO;
        UIView *detachedContentView = [self.expandController detachContentView];
        if (detachedContentView == self.expandWebViewController.contentView) {
            dismissWithAnimation = YES;
        }
        
        [self.expandController dismissViewControllerAnimated:dismissWithAnimation
                                                  completion:^{
                                                      [self.adViewDelegate adDidClose];
                                                  }];
        self.expandController = nil;
    }
    
    self.expandWebViewController = nil;

    UIView *contentView = self.webViewController.contentView;
    if (contentView.superview != self) {
        [self addSubview:contentView];
        [contentView removeConstraints:contentView.constraints];
        [contentView an_constrainToSizeOfSuperview];
        [contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeLeft
                                            yAttribute:NSLayoutAttributeTop];
    }

    [self.webViewController adDidResetToDefault];
    [self adInteractionEndedForInteraction:ANMRAIDContainerViewAdInteractionExpandedOrResized];
}

- (void)adShouldHide {
    [self handleBrowserLoadingForMRAIDStateChange];
    
    if (self.embeddedInModalView && [self.adViewDelegate conformsToProtocol:@protocol(ANInterstitialAdViewInternalDelegate)]) {
        id<ANInterstitialAdViewInternalDelegate> interstitialDelegate = (id<ANInterstitialAdViewInternalDelegate>)self.adViewDelegate;
        [interstitialDelegate adShouldClose];
        
    } else {
        [UIView animateWithDuration:kAppNexusAnimationDuration
                         animations:^{
                             self.webViewController.contentView.alpha = 0.0f;
                         } completion:^(BOOL finished) {
                             self.webViewController.contentView.hidden = YES;
                         }];
        [self.webViewController adDidHide];
    }
    [self adInteractionEndedForInteraction:ANMRAIDContainerViewAdInteractionExpandedOrResized];
}

- (void)adShouldOpenCalendarWithCalendarDict:(NSDictionary *)calendarDict {
    if (!self.userInteractedWithContentView) {
        ANLogDebug(@"Ignoring attempt to open calendar as no hit was detected on ad");
        return;
    }
    
    [self adInteractionBeganWithInteraction:ANMRAIDContainerViewAdInteractionCalendar];
    self.calendarManager = [[ANMRAIDCalendarManager alloc] initWithCalendarDictionary:calendarDict
                                                                        delegate:self];
}

- (void)adShouldSavePictureWithUri:(NSString *)uri {
    if (!self.userInteractedWithContentView) {
        ANLogDebug(@"Ignoring attempt to save picture as no hit was detected on ad");
        return;
    }
    
    [self adInteractionBeganWithInteraction:ANMRAIDContainerViewAdInteractionPicture];
    [ANMRAIDUtil storePictureWithUri:uri
                withCompletionTarget:self
                  completionSelector:@selector(image:didFinishSavingWithError:contextInfo:)];
}

- (void)                image: (UIImage *)image
     didFinishSavingWithError: (NSError *)error
                  contextInfo: (void *)contextInfo
{
    if (error) {
        [self.webViewController adDidFailPhotoSaveWithErrorString:error.localizedDescription];
        [self.expandWebViewController adDidFailPhotoSaveWithErrorString:error.localizedDescription];
    }
    [self adInteractionEndedForInteraction:ANMRAIDContainerViewAdInteractionPicture];
}

- (void)adShouldPlayVideoWithUri:(NSString *)uri {
    UIViewController *presentingViewController = [self displayController];
    if (!presentingViewController) {
        ANLogDebug(@"Ignoring call to mraid.playVideo() - no root view controller to present from");
        return;
    }
    if (!self.userInteractedWithContentView) {
        ANLogDebug(@"Ignoring attempt to play video as no hit was detected on ad");
        return;
    }
    
    [self adInteractionBeganWithInteraction:ANMRAIDContainerViewAdInteractionVideo];
    self.resizeManager.resizeView.hidden = YES;
    [ANMRAIDUtil playVideoWithUri:uri
           fromRootViewController:presentingViewController
             withCompletionTarget:self
               completionSelector:@selector(moviePlayerDidFinish:)];
}

- (void)moviePlayerDidFinish:(NSNotification *)notification {
    self.resizeManager.resizeView.hidden = NO;
    [self adInteractionEndedForInteraction:ANMRAIDContainerViewAdInteractionVideo];
}

- (BOOL)isExpanded {
    return self.expandController.presentingViewController ? YES : NO;
}

- (BOOL)isResized {
    return self.resizeManager.isResized;
}




#pragma mark - UIView observer methods.

- (void)didMoveToWindow {
    [self.resizeManager didMoveAnchorViewToWindow];
}


#pragma mark - ANWebViewControllerPitbullDelegate

- (void)handlePitbullURL:(NSURL *)URL {
    if ([URL.host isEqualToString:@"capture"]) {
        BOOL transitionInProgress = NO;
        if ([self.adViewDelegate conformsToProtocol:@protocol(ANBannerAdViewInternalDelegate)]) {
            id<ANBannerAdViewInternalDelegate> bannerDelegate = (id<ANBannerAdViewInternalDelegate>)self.adViewDelegate;
            transitionInProgress = [[bannerDelegate transitionInProgress] boolValue];
        }
        if (transitionInProgress) {
            if (![self.pitbullCaptureURLQueue count]) {
                [self registerForPitbullScreenCaptureNotifications];
            }
            [self.pitbullCaptureURLQueue addObject:URL];
            return;
        }
    } else if ([URL.host isEqualToString:@"web"]) {
        [self dispatchPitbullScreenCaptureCalls];
        [self unregisterFromPitbullScreenCaptureNotifications];
    }

    [ANPBBuffer handleUrl:URL forView:self.webViewController.contentView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.adViewDelegate) {
        NSNumber *transitionInProgress = change[NSKeyValueChangeNewKey];
        if ([transitionInProgress boolValue] == NO) {
            [self unregisterFromPitbullScreenCaptureNotifications];
            [self dispatchPitbullScreenCaptureCalls];
        }
    }
}

- (void)registerForPitbullScreenCaptureNotifications {
    if (!self.isRegisteredForPitbullScreenCaptureNotifications) {
        if ([self.adViewDelegate conformsToProtocol:@protocol(ANBannerAdViewInternalDelegate)]) {
            NSObject *object = (id<ANBannerAdViewInternalDelegate>)self.adViewDelegate;
            [object addObserver:self
                     forKeyPath:@"transitionInProgress"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
            self.isRegisteredForPitbullScreenCaptureNotifications = YES;
        } else {
            ANLogDebug(@"Attempt to register for pitbull screen capture notifications on an ad view which does not conform to ANBannerAdViewInternalDelegate");
        }
    }
}

- (void)unregisterFromPitbullScreenCaptureNotifications {
    NSObject *bannerObject = self.adViewDelegate;
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
        UIView *view = self.webViewController.contentView;
        [ANPBBuffer handleUrl:URL forView:view];
    }
    self.pitbullCaptureURLQueue = nil;
}

- (NSMutableArray *)pitbullCaptureURLQueue {
    if (!_pitbullCaptureURLQueue) _pitbullCaptureURLQueue = [[NSMutableArray alloc] initWithCapacity:5];
    return _pitbullCaptureURLQueue;
}




#pragma mark - ANMRAIDCalendarManagerDelegate

- (UIViewController *)rootViewControllerForPresentationForCalendarManager:(ANMRAIDCalendarManager *)calendarManager {
    return [self displayController];
}

- (void)willDismissCalendarEditForCalendarManager:(ANMRAIDCalendarManager *)calendarManager {
    if (!self.embeddedInModalView && !self.isExpanded) {
        [self.adViewDelegate adWillClose];
    }
    self.resizeManager.resizeView.hidden = NO;
}

- (void)didDismissCalendarEditForCalendarManager:(ANMRAIDCalendarManager *)calendarManager {
    if (!self.embeddedInModalView && !self.isExpanded) {
        [self.adViewDelegate adDidClose];
    }
    [self adInteractionEndedForInteraction:ANMRAIDContainerViewAdInteractionCalendar];
}

- (void)willPresentCalendarEditForCalendarManager:(ANMRAIDCalendarManager *)calendarManager {
    if (!self.embeddedInModalView && !self.isExpanded) {
        [self.adViewDelegate adWillPresent];
    }
    self.resizeManager.resizeView.hidden = YES;
}

- (void)didPresentCalendarEditForCalendarManager:(ANMRAIDCalendarManager *)calendarManager {
    if (!self.embeddedInModalView && !self.isExpanded) {
        [self.adViewDelegate adDidPresent];
    }
}

- (void)calendarManager:(ANMRAIDCalendarManager *)calendarManager calendarEditFailedWithErrorString:(NSString *)errorString {
    [self.webViewController adDidFailCalendarEditWithErrorString:errorString];
    [self.expandWebViewController adDidFailPhotoSaveWithErrorString:errorString];
    [self adInteractionEndedForInteraction:ANMRAIDContainerViewAdInteractionCalendar];
}




#pragma mark - ANMRAIDExpandViewControllerDelegate

- (void)closeButtonWasTappedOnExpandViewController:(ANMRAIDExpandViewController *)controller {
    [self adShouldResetToDefault];
}

- (void)dismissAndPresentAgainForPreferredInterfaceOrientationChange
{
    __weak ANMRAIDContainerView     *weakSelf                   = self;
    UIViewController                *presentingViewController   = self.expandController.presentingViewController;

    [presentingViewController dismissViewControllerAnimated: NO
                                                 completion: ^{
                                                     ANMRAIDContainerView  *strongSelf  = weakSelf;
                                                     if (!strongSelf)  {
                                                         ANLogError(@"COULD NOT ACQUIRE strongSelf.");
                                                         return;
                                                     }

                                                     [presentingViewController presentViewController: strongSelf.expandController
                                                                                            animated: NO
                                                                                          completion: nil];
                                                 } ];
}


#pragma mark - ANMRAIDResizeViewManagerDelegate

- (void)resizeViewClosedByResizeViewManager:(ANMRAIDResizeViewManager *)manager {
    [self adShouldResetToDefault];
}


#pragma mark - ANAdWebViewControllerVideoDelegate.

// NB  self.webViewController embeds its contentView into self.contentViewContainer.
//     VAST fullscreen option is implemented by changing the frame size of self.contentViewContainer.
//
- (void)videoAdReady
{
    [self didCompleteFirstLoadFromWebViewController:self.webViewController];
}

- (void)videoAdLoadFailed:(NSError *)error
{
    if ([self.adViewDelegate respondsToSelector:@selector(adRequestFailedWithError:)]) {
        [self.adViewDelegate adRequestFailedWithError:error];
    }
}

- (void) videoAdError:(NSError *)error
{
    NSString  *errorString  = [NSString stringWithFormat:@"NSError: code=%@ domain=%@ userInfo=%@", @(error.code), error.domain, error.userInfo];
    ANLogError(@"%@", errorString);
}

- (void) videoAdPlayerFullScreenEntered: (ANAdWebViewController *)videoAd
{
    UIViewController *presentingController = [self displayController];
    if (!presentingController) {
        ANLogDebug(@"Ignoring call to mraid.expand() - no root view controller to present from");
        return;
    }
    self.VASTVideofullScreenController           = [[ANInterstitialAdViewController alloc] init];
    self.VASTVideofullScreenController.needCloseButton = false;
    self.VASTVideofullScreenController.contentView = videoAd.contentView;
    if (self.backgroundColor) {
        self.VASTVideofullScreenController.backgroundColor = self.backgroundColor;
    }
    
    [presentingController presentViewController: self.VASTVideofullScreenController
                                       animated: NO
                                     completion:nil
     ];
    
    self.isFullscreen = YES;
    
}

- (void) videoAdPlayerFullScreenExited: (ANAdWebViewController *)videoAd
{
    UIView  *contentView  = videoAd.contentView;
                       
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
                       
    [self addSubview:contentView];
    
    [contentView an_constrainToSizeOfSuperview];
    [contentView an_alignToSuperviewWithXAttribute:NSLayoutAttributeLeft
                                                           yAttribute:NSLayoutAttributeTop];
    
    [self.VASTVideofullScreenController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
    self.VASTVideofullScreenController = nil;
    self.isFullscreen = NO;
}


@end
