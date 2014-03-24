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

#import "ANBannerAdView.h"

#import "ANAdFetcher.h"
#import "ANBrowserViewController.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANMRAIDViewController.h"

#define DEFAULT_ADSIZE CGSizeZero

@interface ANAdView (ANBannerAdView) <ANAdFetcherDelegate>
- (void)initialize;
- (void)loadAd;
- (void)adDidReceiveAd;
- (void)adRequestFailedWithError:(NSError *)error;
- (void)mraidExpandAd:(CGSize)size
          contentView:(UIView *)contentView
    defaultParentView:(UIView *)defaultParentView
   rootViewController:(UIViewController *)rootViewController;
- (void)mraidExpandAddCloseButton:(UIButton *)closeButton
                    containerView:(UIView *)containerView;
- (NSString *)mraidResizeAd:(CGRect)frame
                contentView:(UIView *)contentView
          defaultParentView:(UIView *)defaultParentView
         rootViewController:(UIViewController *)rootViewController
             allowOffscreen:(BOOL)allowOffscreen;
- (void)mraidResizeAddCloseEventRegion:(UIButton *)closeEventRegion
                         containerView:(UIView *)containerView
                           contentView:(UIView *)contentView
                              position:(ANMRAIDCustomClosePosition)position;
- (void)adShouldResetToDefault:(UIView *)contentView
                    parentView:(UIView *)parentView;

- (void)loadAdFromHtml:(NSString *)html
                 width:(int)width height:(int)height;

@property (nonatomic, readwrite, strong) ANAdFetcher *adFetcher;
@property (nonatomic, readwrite, strong) ANMRAIDViewController *mraidController;
@property (nonatomic, readwrite, strong) UIView *contentView;
@property (nonatomic, readwrite, strong) UIButton *closeButton;
@property (nonatomic, readwrite, strong) ANBrowserViewController *browserViewController;
@property (nonatomic, readwrite, assign) CGRect defaultParentFrame;
@property (nonatomic, readwrite, assign) CGRect defaultFrame;
@property (nonatomic, readwrite, assign) CGPoint resizeOffset;
@property (nonatomic, readwrite, assign) BOOL adjustFramesInResizeState;
@end

@implementation ANBannerAdView
@synthesize autoRefreshInterval = __autoRefreshInterval;
@synthesize adSize = __adSize;

#pragma mark Initialization

- (void)initialize {
    [super initialize];
	
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingNone;
    
    // Set default autoRefreshInterval
    __autoRefreshInterval = kANBannerDefaultAutoRefreshInterval;
    __adSize = CGSizeZero;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	__adSize = self.frame.size;
}

+ (ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(NSString *)placementId {
    return [[[self class] alloc] initWithFrame:frame placementId:placementId adSize:frame.size];
}

+ (ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(NSString *)placementId adSize:(CGSize)size {
    return [[[self class] alloc] initWithFrame:frame placementId:placementId adSize:size];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        [self initialize];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame placementId:(NSString *)placementId {
    self = [self initWithFrame:frame];
    
    if (self != nil) {
        self.placementId = placementId;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame placementId:(NSString *)placementId adSize:(CGSize)size {
    self = [self initWithFrame:frame placementId:placementId];
    
    if (self != nil) {
        self.adSize = size;
    }
    
    return self;
}

- (void)loadAd {
    if (!self.rootViewController) {
        ANLogWarn(@"BannerAdView's rootViewController was not set. This may cause the ad to behave incorrectly");
    }
    
    [super loadAd];
}

#pragma mark Getter and Setter methods

- (CGSize)adSize {
    ANLogDebug(@"adSize returned %@", NSStringFromCGSize(__adSize));
    return __adSize;
}

- (void)setAdSize:(CGSize)adSize {
    if (!CGSizeEqualToSize(adSize, __adSize)) {
        ANLogDebug(@"Setting adSize to %@", NSStringFromCGSize(adSize));
        __adSize = adSize;
    }
}

- (void)setAutoRefreshInterval:(NSTimeInterval)autoRefreshInterval {
    // if auto refresh is above the threshold (0), turn auto refresh on
    if (autoRefreshInterval > kANBannerAutoRefreshThreshold) {
        // minimum allowed value for auto refresh is (15).
        if (autoRefreshInterval < kANBannerMinimumAutoRefreshInterval) {
            __autoRefreshInterval = kANBannerMinimumAutoRefreshInterval;
            ANLogWarn(@"setAutoRefreshInterval called with value %f, but cannot be less than %f", autoRefreshInterval, kANBannerMinimumAutoRefreshInterval);
        }
        
		ANLogDebug(@"AutoRefresh interval set to %f seconds", autoRefreshInterval);
		__autoRefreshInterval = autoRefreshInterval;
        
        [self.adFetcher stopAd];
        
        ANLogDebug(@"New autoRefresh interval set. Making ad request.");
        [self.adFetcher requestAd];
    } else {
		ANLogDebug(@"Turning auto refresh off");
		__autoRefreshInterval = autoRefreshInterval;
    }
}

- (NSTimeInterval)autoRefreshInterval {
    ANLogDebug(@"autoRefreshInterval returned %f seconds", __autoRefreshInterval);
    return __autoRefreshInterval;
}

- (void)setFrame:(CGRect)frame {
    if (self.adjustFramesInResizeState) {
        CGRect adjustedFrame = CGRectMake(frame.origin.x + self.resizeOffset.x, frame.origin.y + self.resizeOffset.y, frame.size.width, frame.size.height);
        [super setFrame:adjustedFrame];
        self.defaultParentFrame = CGRectMake(frame.origin.x, frame.origin.y, self.defaultParentFrame.size.width, self.defaultParentFrame.size.height);
        CGFloat defaultContentWidth = self.defaultFrame.size.width;
        CGFloat defaultContentHeight = self.defaultFrame.size.height;
        CGFloat defaultCenterX = (self.defaultParentFrame.size.width - defaultContentWidth) / 2;
        CGFloat defaultCenterY = (self.defaultParentFrame.size.height - defaultContentHeight) / 2;
        self.defaultFrame = CGRectMake(defaultCenterX, defaultCenterY, defaultContentWidth, defaultContentHeight);
    } else {
        [super setFrame:frame];
    }
    // center the contentview
    CGFloat contentWidth = self.contentView.frame.size.width;
    CGFloat contentHeight = self.contentView.frame.size.height;
    CGFloat centerX = (self.frame.size.width - contentWidth) / 2;
    CGFloat centerY = (self.frame.size.height - contentHeight) / 2;
    [self.contentView setFrame:
     CGRectMake(centerX, centerY, contentWidth, contentHeight)];
}

- (void)setFrame:(CGRect)frame animated:(BOOL)animated {
    if (animated) {
        [self willResizeToFrame:frame];
        [UIView animateWithDuration:kAppNexusAnimationDuration animations:^{
            [self setFrame:frame];
        } completion:^(BOOL finished) {
            [self bannerAdViewDidResize];
		}];
    }
    else {
        [self willResizeToFrame:frame];
        [self setFrame:frame];
        [self bannerAdViewDidResize];
    }
}

#pragma mark Implementation of abstract methods from ANAdView

- (void)openInBrowserWithController:(ANBrowserViewController *)browserViewController {
    [self adWillPresent];
    if (self.rootViewController.presentingViewController) { // RVC is modal view
        [self.rootViewController presentViewController:browserViewController animated:YES completion:^{
            [self adDidPresent];
        }];
    } else {
        UIViewController *presentingController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [presentingController presentViewController:browserViewController animated:YES completion:^{
            [self adDidPresent];
        }];
    }
}

- (void)loadAdFromHtml:(NSString *)html
                 width:(int)width height:(int)height {
    self.adSize = CGSizeMake(width, height);
    [super loadAdFromHtml:html width:width height:height];
}

#pragma mark extraParameters methods

- (NSString *)sizeParameter {
    NSString *sizeParameterString = [NSString stringWithFormat:@"&size=%ldx%ld",
                                     (long)__adSize.width,
                                     (long)__adSize.height];
    NSString *maxSizeParameterString = [NSString stringWithFormat:@"&max_size=%ldx%ld",
                                        (long)self.frame.size.width,
                                        (long)self.frame.size.height];
    
    return CGSizeEqualToSize(__adSize, DEFAULT_ADSIZE) ? maxSizeParameterString : sizeParameterString;
    ;
}

- (NSString *)orientationParameter {
    NSString *orientation = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? @"h" : @"v";
    return [NSString stringWithFormat:@"&orientation=%@", orientation];
}

#pragma mark ANAdFetcherDelegate

- (NSArray *)extraParameters {
    return [NSArray arrayWithObjects:
            [self sizeParameter],
            [self orientationParameter],
            nil];
}

- (void)adFetcher:(ANAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdResponse *)response {
    NSError *error;
    
    if ([response isSuccessful]) {
        UIView *contentView = response.adObject;
        
        if ([contentView isKindOfClass:[UIView class]]) {
            // center the contentview
            CGFloat centerX = (self.frame.size.width - contentView.frame.size.width) / 2;
            CGFloat centerY = (self.frame.size.height - contentView.frame.size.height) / 2;
            [contentView setFrame:
             CGRectMake(centerX, centerY,
                        contentView.frame.size.width,
                        contentView.frame.size.height)];
            self.contentView = contentView;
            
            [self adDidReceiveAd];
        }
        else {
            NSDictionary *errorInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Requested a banner ad but received a non-view object as response.", @"Error: We did not get a viewable object as a response for a banner ad request.")
                                                                  forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:AN_ERROR_DOMAIN
                                        code:ANAdResponseNonViewResponse
                                    userInfo:errorInfo];
        }
    }
    else {
        error = response.error;
    }
    
    if (error) {
        [self adRequestFailedWithError:error];
    }
}

- (NSTimeInterval)autoRefreshIntervalForAdFetcher:(ANAdFetcher *)fetcher {
    return self.autoRefreshInterval;
}

- (CGSize)requestedSizeForAdFetcher:(ANAdFetcher *)fetcher {
    return self.adSize;
}

#pragma mark ANMRAIDAdViewDelegate

- (NSString *)adType {
    return @"inline";
}

- (UIViewController *)displayController {
    return self.mraidController ? self.mraidController : self.rootViewController;
}

- (void)adShouldExpandToFrame:(CGRect)frame
                  closeButton:(UIButton *)closeButton {
    [super mraidExpandAd:frame.size
             contentView:self.contentView
       defaultParentView:self
      rootViewController:self.rootViewController];
    
    UIView *containerView = self.mraidController ? self.mraidController.view : self;
    [super mraidExpandAddCloseButton:closeButton containerView:containerView];
    
    [self.mraidEventReceiverDelegate adDidFinishExpand];
}

- (void)adShouldResizeToFrame:(CGRect)frame allowOffscreen:(BOOL)allowOffscreen
                  closeButton:(UIButton *)closeButton
                closePosition:(ANMRAIDCustomClosePosition)closePosition {
    // resized ads are never modal
    UIView *contentView = self.contentView;
    
    NSString *mraidResizeErrorString = [super mraidResizeAd:frame
                                                contentView:contentView
                                          defaultParentView:self
                                         rootViewController:self.rootViewController
                                             allowOffscreen:allowOffscreen];
    
    if ([mraidResizeErrorString length] > 0) {
        [self.mraidEventReceiverDelegate adDidFinishResize:NO errorString:mraidResizeErrorString];
        return;
    }
    
	[super mraidResizeAddCloseEventRegion:closeButton
                            containerView:self
                              contentView:contentView
                                 position:closePosition];
    
    self.adjustFramesInResizeState = YES;
    
    // send mraid events
    [self.mraidEventReceiverDelegate adDidFinishResize:YES errorString:nil];
}

- (void)adShouldResetToDefault {
    self.adjustFramesInResizeState = NO;
    [super adShouldResetToDefault:self.contentView parentView:self];
}

#pragma mark delegate selector helper method

- (void)willResizeToFrame:(CGRect)frame {
    if ([self.delegate respondsToSelector:@selector(bannerAdView:willResizeToFrame:)]) {
        [self.delegate bannerAdView:self willResizeToFrame:frame];
    }
}

- (void)bannerAdViewDidResize {
    if ([self.delegate respondsToSelector:@selector(bannerAdViewDidResize:)]) {
        [self.delegate bannerAdViewDidResize:self];
    }
}

#pragma mark ANBrowserViewControllerDelegate

- (void)browserViewControllerShouldDismiss:(ANBrowserViewController *)controller
{
    [self adWillClose];
	UIViewController *presentingViewController = controller.presentingViewController;
	[presentingViewController dismissViewControllerAnimated:YES completion:^{
        self.browserViewController = nil;
        [self adDidClose];
    }];
}

@end
