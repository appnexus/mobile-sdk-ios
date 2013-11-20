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

#import "ANInterstitialAd.h"
#import "ANGlobal.h"
#import "ANInterstitialAdViewController.h"
#import "ANBrowserViewController.h"
#import "ANAdFetcher.h"
#import "ANLogging.h"
#import "ANAdResponse.h"
#import "ANCustomAdapter.h"
#import "ANLocation.h"
#import "ANAdViewDelegate.h"

#define AN_INTERSTITIAL_AD_TIMEOUT 60.0

NSString *const kANInterstitialAdViewKey = @"kANInterstitialAdViewKey";
NSString *const kANInterstitialAdViewDateLoadedKey = @"kANInterstitialAdViewDateLoadedKey";

@interface ANAdView (ANInterstitialAd)
- (void)initialize;
- (void)adDidReceiveAd;
- (void)adRequestFailedWithError:(NSError *)error;
- (void)showCloseButtonWithTarget:(id)target
                           action:(SEL)selector
                    containerView:(UIView *)containerView;
- (void)mraidResizeAd:(CGSize)size
          contentView:(UIView *)contentView
    defaultParentView:(UIView *)defaultParentView
   rootViewController:(UIViewController *)rootViewController
             isBanner:(BOOL)isBanner;
@end

@interface ANInterstitialAd () <ANInterstitialAdViewControllerDelegate>

@property (nonatomic, readwrite, strong) ANInterstitialAdViewController *controller;
@property (nonatomic, readwrite, strong) NSMutableArray *precachedAdObjects;
@property (nonatomic, readwrite, strong) NSMutableSet *allowedAdSizes;
@property (nonatomic, readwrite, strong) ANBrowserViewController *browserViewController;
@property (nonatomic, readwrite, assign) CGRect frame;

@end

@implementation ANInterstitialAd
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
    __adSize = self.frame.size;
    __allowedAdSizes = [self getDefaultAllowedAdSizes];
}

- (id)initWithPlacementId:(NSString *)placementId {
	self = [super init];
	
	if (self != nil) {
		self.placementId = placementId;
	}
	
	return self;
}

- (void)dealloc {
    self.adFetcher.delegate = nil;
    self.adFetcher = nil;
    self.controller.delegate = nil;
    self.controller = nil;
    self.closeButton = nil;
}

- (void)loadAd {
    [self.adFetcher requestAd];
}

- (void)displayAdFromViewController:(UIViewController *)controller {
	self.controller.contentView = nil;
	id adToShow = nil;
    NSString *errorString = nil;
    
    while ([self.precachedAdObjects count] > 0
           && self.controller.contentView == nil) {
        // Pull the first ad off
        NSDictionary *adDict = [self.precachedAdObjects objectAtIndex:0];
        
        // Check to see if the date this was loaded is no more than 60 seconds ago
        NSDate *dateLoaded = [adDict objectForKey:kANInterstitialAdViewDateLoadedKey];
        
        if (([dateLoaded timeIntervalSinceNow] * -1) < AN_INTERSTITIAL_AD_TIMEOUT) {
            // If ad is still valid, save a reference to it. We'll use it later
			adToShow = [adDict objectForKey:kANInterstitialAdViewKey];
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
            
            [UIApplication sharedApplication].delegate.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext; // Proper support for background transparency
            
			[self adWillPresent];
			
			[controller presentViewController:self.controller animated:YES completion:^{
                [self adDidPresent];
            }];
		}
		else if ([adToShow conformsToProtocol:@protocol(ANCustomAdapterInterstitial)]) {
			[adToShow presentFromViewController:controller];
		}
		else {
            errorString = @"Got a non-presentable object %@. Cannot display interstitial.";
		}
    }
    else {
        errorString = @"Display ad called, but no valid ad to show. Please load another interstitial ad.";
    }
    
    if (errorString) {
        ANLogFatal(errorString);
        [self adFailedToDisplay];
    }
}

- (NSMutableSet *)getDefaultAllowedAdSizes {
    NSMutableSet *defaultAllowedSizes = [NSMutableSet set];
    
    NSArray *possibleSizesArray = [NSArray arrayWithObjects:
								   [NSValue valueWithCGSize:kANInterstitialAdSize1024x1024],
                                   [NSValue valueWithCGSize:kANInterstitialAdSize900x500],
                                   [NSValue valueWithCGSize:kANInterstitialAdSize320x480],
                                   [NSValue valueWithCGSize:kANInterstitialAdSize300x250],
                                   nil];
    for (NSValue *sizeValue in possibleSizesArray) {
        if (CGSizeLargerThanSize(self.frame.size, [sizeValue CGSizeValue])) {
            [defaultAllowedSizes addObject:sizeValue];
        }
    }
    return defaultAllowedSizes;
}

- (BOOL)isReady {
    // check the cache for a valid ad
    while ([self.precachedAdObjects count] > 0) {
        NSDictionary *adDict = [self.precachedAdObjects objectAtIndex:0];
        
        // Check to see if the ad has expired
        NSDate *dateLoaded = [adDict objectForKey:kANInterstitialAdViewDateLoadedKey];
        if (([dateLoaded timeIntervalSinceNow] * -1) < AN_INTERSTITIAL_AD_TIMEOUT) {
            // Found a valid ad
            id readyAd = [adDict objectForKey:kANInterstitialAdViewKey];
            if ([readyAd conformsToProtocol:@protocol(ANCustomAdapterInterstitial)]) {
                // if it's a mediated ad, check if it is ready
                return [readyAd isReady];
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
    return [[UIScreen mainScreen] bounds];
}

#pragma mark Implementation of Abstract methods from ANAdView

- (NSString *)adType {
	return @"interstitial";
}

- (void)openInBrowserWithController:(ANBrowserViewController *)browserViewController {
    // Interstitials require special handling of launching the in-app browser since they live on top of everything else
    self.browserViewController = browserViewController;
    [self.controller presentViewController:self.browserViewController animated:YES completion:nil];
}

#pragma mark extraParameters methods

- (NSString *)sizeParameter {
    return [NSString stringWithFormat:@"&size=%dx%d",
            (NSInteger)self.frame.size.width,
            (NSInteger)self.frame.size.height];
}

- (NSString *)promoSizesParameter {
    NSString *promoSizesParameter = @"&promo_sizes=";
    NSMutableArray *sizesStringsArray = [NSMutableArray arrayWithCapacity:[self.allowedAdSizes count]];
    
    for (NSValue *sizeValue in self.allowedAdSizes) {
        CGSize size = [sizeValue CGSizeValue];
        NSString *param = [NSString stringWithFormat:@"%dx%d", (NSInteger)size.width, (NSInteger)size.height];
        
        [sizesStringsArray addObject:param];
    }
    
    promoSizesParameter = [promoSizesParameter stringByAppendingString:[sizesStringsArray componentsJoinedByString:@","]];
    
    return promoSizesParameter;
}

#pragma mark ANAdFetcherDelegate

- (NSArray *)extraParametersForAdFetcher:(ANAdFetcher *)fetcher {
    return [NSArray arrayWithObjects:
            [self sizeParameter],
            [self promoSizesParameter],
            nil];
}

- (void)adFetcher:(ANAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdResponse *)response {
    if ([response isSuccessful]) {
        NSDictionary *adViewWithDateLoaded = [NSDictionary dictionaryWithObjectsAndKeys:
                                              response.adObject, kANInterstitialAdViewKey,
                                              [NSDate date], kANInterstitialAdViewDateLoadedKey,
                                              nil];
        [self.precachedAdObjects addObject:adViewWithDateLoaded];
        ANLogDebug(@"Stored ad %@ in precached ad views", adViewWithDateLoaded);
        
        [self adDidReceiveAd];
    }
    else {
        [self adRequestFailedWithError:response.error];
    }
}

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldOpenInBrowserWithURL:(NSURL *)URL {
	// Stop the countdown and enable close button immediately
	[self.controller stopCountdownTimer];
    [super adFetcher:fetcher adShouldOpenInBrowserWithURL:URL];
}

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldResizeToSize:(CGSize)size {
    [super mraidResizeAd:size
             contentView:self.controller.contentView
       defaultParentView:self.controller.view
      rootViewController:self.controller
                isBanner:NO];
}

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldShowCloseButtonWithTarget:(id)target action:(SEL)action {
	[super showCloseButtonWithTarget:target action:action containerView:self.controller.contentView];
}

#pragma mark ANBrowserViewControllerDelegate

- (void)browserViewControllerShouldDismiss:(ANBrowserViewController *)controller {
	[self.controller dismissViewControllerAnimated:YES completion:^{
		self.browserViewController = nil;
	}];
}

#pragma mark ANInterstitialAdViewControllerDelegate

- (void)interstitialAdViewControllerShouldDismiss:(ANInterstitialAdViewController *)controller {
    [self adWillClose];

	[self.controller.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self adDidClose];
	}];
}

@end
