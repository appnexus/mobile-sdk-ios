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

#import "ANBasicConfig.h"
#import ANINTERSTITIALADHEADER

#import "ANAdFetcher.h"
#import "ANBrowserViewController.h"
#import "ANGlobal.h"
#import "ANInterstitialAdViewController.h"
#import "ANLogging.h"
#import "ANMRAIDViewController.h"
#import "ANPBBuffer.h"
#import "ANPBContainerView.h"

#define AN_INTERSTITIAL_AD_TIMEOUT 60.0

// List of allowed ad sizes for interstitials.  These must fit in the
// maximum size of the view, which in this case, will be the size of
// the window.
#define kANInterstitialAdSize300x250 CGSizeMake(300,250)
#define kANInterstitialAdSize320x480 CGSizeMake(320,480)
#define kANInterstitialAdSize900x500 CGSizeMake(900,500)
#define kANInterstitialAdSize1024x1024 CGSizeMake(1024,1024)

NSString *const kANInterstitialAdViewKey = @"kANInterstitialAdViewKey";
NSString *const kANInterstitialAdViewDateLoadedKey = @"kANInterstitialAdViewDateLoadedKey";
NSString *const kANInterstitialAdViewAuctionInfoKey = @"kANInterstitialAdViewAuctionInfoKey";

@interface ANADVIEW (ANINTERSTITIALAD) <ANAdFetcherDelegate>
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
                           contentView:contentView
                              position:(ANMRAIDCustomClosePosition)position;
- (void)adShouldResetToDefault:(UIView *)contentView
                    parentView:(UIView *)parentView;

@property (nonatomic, readwrite, strong) ANAdFetcher *adFetcher;
@property (nonatomic, readwrite, strong) ANMRAIDViewController *mraidController;
@property (nonatomic, readwrite, strong) ANBrowserViewController *browserViewController;

@end

@interface ANINTERSTITIALAD () <ANInterstitialAdViewControllerDelegate>

@property (nonatomic, readwrite, strong) ANInterstitialAdViewController *controller;
@property (nonatomic, readwrite, strong) NSMutableArray *precachedAdObjects;
@property (nonatomic, readwrite, assign) CGRect frame;

@end

@implementation ANINTERSTITIALAD
@synthesize controller = __controller;
@synthesize precachedAdObjects = __precachedAdObjects;
@synthesize delegate = __delegate;
@synthesize frame = __frame;
@synthesize allowedAdSizes = __allowedAdSizes;

#pragma mark Initialization

- (void)initialize {
    [super initialize];
    __controller = [[ANInterstitialAdViewController alloc] init];
    __controller.delegate = self;
    __precachedAdObjects = [NSMutableArray array];
    __allowedAdSizes = [self getDefaultAllowedAdSizes];
    _closeDelay = kANInterstitialDefaultCloseButtonDelay;
}

- (instancetype)initWithPlacementId:(NSString *)placementId {
	self = [super init];
	
	if (self != nil) {
		self.placementId = placementId;
	}
	
	return self;
}

- (void)dealloc {
    self.controller.delegate = nil;
}

- (void)loadAd {
    [super loadAd];
}

- (void)displayAdFromViewController:(UIViewController *)controller {
	self.controller.contentView = nil;
	id adToShow = nil;
    NSString *auctionID = nil;
    NSString *errorString = nil;
    
    while ([self.precachedAdObjects count] > 0
           && self.controller.contentView == nil) {
        // Pull the first ad off
        NSDictionary *adDict = self.precachedAdObjects[0];
        
        // Check to see if the date this was loaded is no more than 60 seconds ago
        NSDate *dateLoaded = adDict[kANInterstitialAdViewDateLoadedKey];
        
        if (([dateLoaded timeIntervalSinceNow] * -1) < AN_INTERSTITIAL_AD_TIMEOUT) {
            // If ad is still valid, save a reference to it. We'll use it later
			adToShow = adDict[kANInterstitialAdViewKey];
            auctionID = adDict[kANInterstitialAdViewAuctionInfoKey];
        }
        
        // This ad is now stale, so remove it from our cached ads.
        [self.precachedAdObjects removeObjectAtIndex:0];
    }
    
    if (adToShow != nil) {
		// Check to see what kind of ad it is.
		if ([adToShow isKindOfClass:[UIView class]]) {
			// If it's a view, then just set our content view to it.
			self.controller.contentView = adToShow;
            
            // If there's a background color, pass that color to the controller which will modify the view
            if (self.backgroundColor) {
                self.controller.backgroundColor = self.backgroundColor;
            }
            
            UIModalPresentationStyle rootViewControllerDesiredPresentationStyle = controller.modalPresentationStyle;
            controller.modalPresentationStyle = UIModalPresentationCurrentContext;
			[controller presentViewController:self.controller animated:YES completion:^{
                controller.modalPresentationStyle = rootViewControllerDesiredPresentationStyle;
            }];
		}
		else if ([adToShow conformsToProtocol:@protocol(ANCUSTOMADAPTERINTERSTITIAL)]) {
			[adToShow presentFromViewController:controller];
            if (auctionID) {
                ANPBContainerView *logoView = [[ANPBContainerView alloc] initWithLogo];
                [controller.presentedViewController.view addSubview:logoView];
                [ANPBBuffer addAdditionalInfo:@{kANPBBufferAdWidthKey: @(CGRectGetWidth(controller.presentedViewController.view.frame)),
                                                kANPBBufferAdHeightKey: @(CGRectGetHeight(controller.presentedViewController.view.frame))}
                                 forAuctionID:auctionID];
                // capture mediated interstitials after show event
                [ANPBBuffer captureDelayedImage:controller.presentedViewController.view
                                   forAuctionID:auctionID];
            }
		}
		else {
            errorString = @"Got a non-presentable object %@. Cannot display interstitial.";
		}
    }
    else {
        errorString = @"Display ad called, but no valid ad to show. Please load another interstitial ad.";
    }
    
    if (errorString) {
        ANLogError(errorString);
        [self adFailedToDisplay];
    }
}

- (NSMutableSet *)getDefaultAllowedAdSizes {
    NSMutableSet *defaultAllowedSizes = [NSMutableSet set];
    
    NSArray *possibleSizesArray = @[[NSValue valueWithCGSize:kANInterstitialAdSize1024x1024],
                                   [NSValue valueWithCGSize:kANInterstitialAdSize900x500],
                                   [NSValue valueWithCGSize:kANInterstitialAdSize320x480],
                                   [NSValue valueWithCGSize:kANInterstitialAdSize300x250]];
    for (NSValue *sizeValue in possibleSizesArray) {
        CGSize possibleSize = [sizeValue CGSizeValue];
        CGRect possibleSizeRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, possibleSize.width, possibleSize.height);
        if (CGRectContainsRect(self.frame, possibleSizeRect)) {
            [defaultAllowedSizes addObject:sizeValue];
        }
    }
    return defaultAllowedSizes;
}

- (BOOL)isReady {
    // check the cache for a valid ad
    while ([self.precachedAdObjects count] > 0) {
        NSDictionary *adDict = self.precachedAdObjects[0];
        
        // Check to see if the ad has expired
        NSDate *dateLoaded = adDict[kANInterstitialAdViewDateLoadedKey];
        NSTimeInterval timeIntervalSinceDateLoaded = [dateLoaded timeIntervalSinceNow] * -1;
        if (timeIntervalSinceDateLoaded > 0 && timeIntervalSinceDateLoaded < AN_INTERSTITIAL_AD_TIMEOUT) {
            // Found a valid ad
            id readyAd = adDict[kANInterstitialAdViewKey];
            if ([readyAd conformsToProtocol:@protocol(ANCUSTOMADAPTERINTERSTITIAL)]) {
                // if it's a mediated ad, check if it is ready
                if ([readyAd respondsToSelector:@selector(isReady)]) {
                    return [readyAd isReady];
                } else {
                    ANLogWarn(@"CustomInterstitialAdapter should implement isReady function");
                    return true;
                }
            } else {
                // if it's a standard ad, we are ready to display
                return true;
            }
        } else {
            // Ad is stale, remove it
            [self.precachedAdObjects removeObjectAtIndex:0];
        }
    }
    
    return false;
}

- (CGRect)frame {
    // By definition, interstitials can only ever have the entire screen's bounds as its frame
    CGRect screenBounds = ANPortraitScreenBounds();
    if (UIInterfaceOrientationIsLandscape(self.controller.orientation)) {
        return CGRectMake(screenBounds.origin.y, screenBounds.origin.x, screenBounds.size.height, screenBounds.size.width);
    }
    return screenBounds;
}

- (void)setCloseDelay:(NSTimeInterval)closeDelay {
    if (closeDelay > kANInterstitialMaximumCloseButtonDelay) {
        ANLogWarn(@"Maximum allowed value for closeDelay is %.1f", kANInterstitialMaximumCloseButtonDelay);
        closeDelay = kANInterstitialMaximumCloseButtonDelay;
    }
    
    _closeDelay = closeDelay;
}

#pragma mark Implementation of Abstract methods from ANAdView

- (void)openInBrowserWithController:(ANBrowserViewController *)browserViewController {
	// Stop the countdown and enable close button immediately
	[self.controller stopCountdownTimer];
    if (self.controller.presentingViewController) {
        // don't open the browser if the interstitial has been closed already
        [self.controller presentViewController:self.browserViewController animated:YES completion:nil];
    }
}

#pragma mark extraParameters methods

- (NSString *)sizeParameter {
    return [NSString stringWithFormat:@"&size=%ldx%ld",
            (long)self.frame.size.width,
            (long)self.frame.size.height];
}

- (NSString *)promoSizesParameter {
    NSString *promoSizesParameter = @"&promo_sizes=";
    NSMutableArray *sizesStringsArray = [NSMutableArray arrayWithCapacity:[self.allowedAdSizes count]];
    
    for (id sizeValue in self.allowedAdSizes) {
        if ([sizeValue isKindOfClass:[NSValue class]]) {
            CGSize size = [sizeValue CGSizeValue];
            NSString *param = [NSString stringWithFormat:@"%ldx%ld", (long)size.width, (long)size.height];
            
            [sizesStringsArray addObject:param];
        }
    }
    
    promoSizesParameter = [promoSizesParameter stringByAppendingString:[sizesStringsArray componentsJoinedByString:@","]];
    
    return promoSizesParameter;
}

- (NSString *)orientationParameter {
    NSString *orientation = UIInterfaceOrientationIsLandscape(self.controller.orientation) ? @"h" : @"v";
    return [NSString stringWithFormat:@"&orientation=%@", orientation];
}

#pragma mark ANAdFetcherDelegate

- (NSArray *)extraParameters {
    return @[[self sizeParameter],
            [self promoSizesParameter],
            [self orientationParameter]];
}

- (void)adFetcher:(ANAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdResponse *)response {
    if ([response isSuccessful]) {
        NSMutableDictionary *adViewWithDateLoaded = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     response.adObject, kANInterstitialAdViewKey,
                                                     [NSDate date], kANInterstitialAdViewDateLoadedKey,
                                                     nil];
        // cannot insert nil objects
        if (response.auctionID) {
            adViewWithDateLoaded[kANInterstitialAdViewAuctionInfoKey] = response.auctionID;
        }
        [self.precachedAdObjects addObject:adViewWithDateLoaded];
        ANLogDebug(@"Stored ad %@ in precached ad views", adViewWithDateLoaded);
        
        [self adDidReceiveAd];
    }
    else {
        [self adRequestFailedWithError:response.error];
    }
}

- (CGSize)requestedSizeForAdFetcher:(ANAdFetcher *)fetcher {
    return self.frame.size;
}

- (UIView *)containerView {
    return self.controller.view;
}

#pragma mark ANMRAIDAdViewDelegate

- (NSString *)adType {
	return @"interstitial";
}

- (UIViewController *)displayController {
    return self.mraidController ? self.mraidController : self.controller;
}

- (void)adShouldExpandToFrame:(CGRect)frame
                  closeButton:(UIButton *)closeButton {
    [super mraidExpandAd:frame.size
             contentView:self.controller.contentView
       defaultParentView:self.controller.containerView
      rootViewController:self.controller];
    
    UIView *containerView = self.mraidController ? self.mraidController.view : self.controller.contentView;
    [super mraidExpandAddCloseButton:closeButton containerView:containerView];
    
    [self.mraidEventReceiverDelegate adDidFinishExpand];
}

- (void)adShouldResizeToFrame:(CGRect)frame allowOffscreen:(BOOL)allowOffscreen
                  closeButton:(UIButton *)closeButton
                closePosition:(ANMRAIDCustomClosePosition)closePosition {
    // resized ads are never modal
    UIView *contentView = self.controller.contentView;
    UIView *containerView = self.controller.containerView;

    NSString *mraidResizeErrorString = [super mraidResizeAd:frame
                                                contentView:contentView
                                          defaultParentView:containerView
                                         rootViewController:self.controller
                                             allowOffscreen:allowOffscreen];
    
    if ([mraidResizeErrorString length] > 0) {
        [self.mraidEventReceiverDelegate adDidFinishResize:NO errorString:mraidResizeErrorString];
        return;
    }
    
	[super mraidResizeAddCloseEventRegion:closeButton
                            containerView:containerView
                              contentView:contentView
                                 position:closePosition];
    
    // send mraid events
    [self.mraidEventReceiverDelegate adDidFinishResize:YES errorString:nil];
}

- (void)adShouldResetToDefault {
    [super adShouldResetToDefault:self.controller.contentView parentView:self.controller.containerView];
}

#pragma mark ANBrowserViewControllerDelegate

- (void)browserViewControllerShouldDismiss:(ANBrowserViewController *)controller {
	[controller dismissViewControllerAnimated:YES completion:^{
		self.browserViewController = nil;
	}];
}

- (UIView *)viewToDisplayClickOverlay {
    return self.controller.contentView;
}

#pragma mark ANInterstitialAdViewControllerDelegate

- (void)interstitialAdViewControllerShouldDismiss:(ANInterstitialAdViewController *)controller {
    __weak ANINTERSTITIALAD *weakAd = self;
    
    [self.browserViewController dismissViewControllerAnimated:YES completion:^{
        ANINTERSTITIALAD *ad = weakAd;
        ad.browserViewController = nil;
    }];

    [self.controller dismissViewControllerAnimated:YES completion:^{
        ANINTERSTITIALAD *ad = weakAd;
        ad.controller = nil;
    }];
}

- (NSTimeInterval)closeDelayForController {
    return self.closeDelay;
}

@end
