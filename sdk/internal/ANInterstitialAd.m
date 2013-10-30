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

@interface ANInterstitialAd () <ANAdFetcherDelegate, ANBrowserViewControllerDelegate, ANInterstitialAdViewControllerDelegate, ANAdViewDelegate>

@property (nonatomic, readwrite, strong) ANInterstitialAdViewController *controller;
@property (nonatomic, readwrite, strong) NSMutableArray *precachedAdObjects;
@property (nonatomic, readwrite, strong) NSMutableSet *allowedAdSizes;
@property (nonatomic, readwrite, strong) ANBrowserViewController *browserViewController;

@end

@implementation ANInterstitialAd
@synthesize placementId = __placementId;
@synthesize adSize = __adSize;
@synthesize clickShouldOpenInBrowser = __clickShouldOpenInBrowser;
@synthesize adFetcher = __adFetcher;
@synthesize delegate = __delegate;
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
		self.adFetcher = [[ANAdFetcher alloc] init];
		self.adFetcher.delegate = self;
		self.controller = [[ANInterstitialAdViewController alloc] init];
		self.controller.delegate = self;
		self.precachedAdObjects = [NSMutableArray array];
		self.adSize = CGSizeZero;
		self.shouldServePublicServiceAnnouncements = YES;
        self.location = nil;
        self.reserve = 0.0f;
        self.customKeywords = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (id)initWithPlacementId:(NSString *)placementId
{
	self = [self init];
	
	if (self != nil)
	{
		self.placementId = placementId;
	}
	
	return self;
}

- (void)loadAd
{
	// Refresh our list of allowed ad sizes
    [self refreshAllowedAdSizes];
	
    // Pick an ad size out of our list of allowed ad sizes to send with the request
    NSValue *randomAllowedSize = [self.allowedAdSizes anyObject];
    self.adSize = [randomAllowedSize CGSizeValue];
    
    [self.adFetcher requestAd];
}

- (void)displayAdFromViewController:(UIViewController *)controller
{
	self.controller.contentView = nil;
	
	id adToShow = nil;
    
    while ([self.precachedAdObjects count] > 0 && self.controller.contentView == nil)
    {
        // Pull the first ad off
        NSDictionary *adDict = [self.precachedAdObjects objectAtIndex:0];
        
        // Check to see if the date this was loaded is no more than 60 seconds ago
        NSDate *dateLoaded = [adDict objectForKey:kANInterstitialAdViewDateLoadedKey];
        
        if (([dateLoaded timeIntervalSinceNow] * -1) < AN_INTERSTITIAL_AD_TIMEOUT)
        {
            // If ad is still valid, save a reference to it. We'll use it later
			adToShow = [adDict objectForKey:kANInterstitialAdViewKey];
        }
        
        // This ad is now stale, so remove it from our cached ads.
        [self.precachedAdObjects removeObjectAtIndex:0];
    }
    
    if (adToShow != nil)
    {
		// Check to see what kind of ad it is.
		if ([adToShow isKindOfClass:[UIView class]])
		{
			// If it's a view, then just set our content view to it.
			self.controller.contentView = adToShow;
            
            // If there's a background color, pass that color to the controller which will modify the view
            if (self.backgroundColor) {
                self.controller.backgroundColor = self.backgroundColor;
            }
			
			if ([self.delegate respondsToSelector:@selector(adWillPresent:)]) {
				[self.delegate adWillPresent:self];
			}
			
            [UIApplication sharedApplication].delegate.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext; // Proper support for background transparency
			[controller presentViewController:self.controller animated:YES completion:NULL];
		}
		else if ([adToShow conformsToProtocol:@protocol(ANCustomAdapterInterstitial)]) {
			[adToShow presentFromViewController:controller];
		}
		else {
			ANLogFatal(@"Got a non-presentable object %@. Cannot display interstitial.");
            if ([self.delegate respondsToSelector:@selector(adNoAdToShow:)]) {
                [self.delegate adNoAdToShow:self];
            }
		}
    }
    else
    {
        ANLogError(@"Display ad called, but no valid ad to show. Please load another interstitial ad.");
        if ([self.delegate respondsToSelector:@selector(adNoAdToShow:)]) {
            [self.delegate adNoAdToShow:self];
        }
    }
}

- (void)refreshAllowedAdSizes
{
    self.allowedAdSizes = [NSMutableSet set];
    
    NSArray *possibleSizesArray = [NSArray arrayWithObjects:
								   [NSValue valueWithCGSize:kANInterstitialAdSize1024x1024],
                                   [NSValue valueWithCGSize:kANInterstitialAdSize900x500],
                                   [NSValue valueWithCGSize:kANInterstitialAdSize320x480],
                                   [NSValue valueWithCGSize:kANInterstitialAdSize300x250],
                                   nil];
    for (NSValue *sizeValue in possibleSizesArray)
    {
        if (CGSizeLargerThanSize(self.frame.size, [sizeValue CGSizeValue]))
        {
            [self.allowedAdSizes addObject:sizeValue];
        }
    }
}

- (CGRect)frame
{
    // By definition, interstitials can only ever have the entire screen's bounds as its frame
    return [[UIScreen mainScreen] bounds];
}

- (NSString *)maximumSizeParameter
{
    return [NSString stringWithFormat:@"&size=%dx%d", (NSInteger)self.frame.size.width, (NSInteger)self.frame.size.height];
}

- (NSString *)promoSizesParameter
{
    NSString *promoSizesParameter = @"&promo_sizes=";
    NSMutableArray *sizesStringsArray = [NSMutableArray arrayWithCapacity:[self.allowedAdSizes count]];
    
    for (NSValue *sizeValue in self.allowedAdSizes)
    {
        CGSize size = [sizeValue CGSizeValue];
        NSString *param = [NSString stringWithFormat:@"%dx%d", (NSInteger)size.width, (NSInteger)size.height];
        
        [sizesStringsArray addObject:param];
    }
    
    promoSizesParameter = [promoSizesParameter stringByAppendingString:[sizesStringsArray componentsJoinedByString:@","]];
    
    return promoSizesParameter;
}

- (NSString *)adType
{
	return @"interstitial";
}

#pragma mark ANAdFetcherDelegate

- (NSArray *)extraParametersForAdFetcher:(ANAdFetcher *)fetcher
{
    return [NSArray arrayWithObjects:
            [self maximumSizeParameter],
            [self promoSizesParameter],
            nil];
}

- (void)adFetcher:(ANAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdResponse *)response
{
    if ([response isSuccessful])
    {
        NSDictionary *adViewWithDateLoaded = [NSDictionary dictionaryWithObjectsAndKeys:
                                              response.adObject, kANInterstitialAdViewKey,
                                              [NSDate date], kANInterstitialAdViewDateLoadedKey,
                                              nil];
        [self.precachedAdObjects addObject:adViewWithDateLoaded];
        ANLogDebug(@"Stored ad %@ in precached ad views", adViewWithDateLoaded);
        
        if ([self.delegate respondsToSelector:@selector(adDidReceiveAd:)]) {
            [self.delegate adDidReceiveAd:self];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(ad: requestFailedWithError:)]) {
            [self.delegate ad:self requestFailedWithError:response.error];
        }
    }
}

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldOpenInBrowserWithURL:(NSURL *)URL
{
	// Stop the countdown and enable close button immediately
	[self.controller stopCountdownTimer];
	
	if (self.clickShouldOpenInBrowser)
	{
		if ([[UIApplication sharedApplication] canOpenURL:URL])
		{
			[[UIApplication sharedApplication] openURL:URL];
		}
	}
	else
	{
		// Interstitials require special handling of launching the in-app browser since they live on top of everything else
		self.browserViewController = [[ANBrowserViewController alloc] initWithURL:URL];
		self.browserViewController.delegate = self;
		[self.controller presentViewController:self.browserViewController animated:YES completion:NULL];
	}
}

- (NSTimeInterval)autorefreshIntervalForAdFetcher:(ANAdFetcher *)fetcher
{
    return 0.0;
}

- (NSString *)placementId
{
    ANLogDebug(@"placementId returned %@", __placementId);
    return __placementId;
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

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy
{
    self.location = [ANLocation getLocationWithLatitude:latitude
                                              longitude:longitude
                                              timestamp:timestamp
                                     horizontalAccuracy:horizontalAccuracy];
}

- (void)addCustomKeywordWithKey:(NSString *)key value:(NSString *)value {
    if (([key length] < 1) || !value)
        return;
    
    [self.customKeywords setValue:value forKey:key];
}

- (void)removeCustomKeywordWithKey:(NSString *)key {
    if (([key length] < 1))
        return;
    
    [self.customKeywords removeObjectForKey:key];
}

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldResizeToSize:(CGSize)size
{
	
}

- (void)adFetcher:(ANAdFetcher *)fetcher adShouldShowCloseButtonWithTarget:(id)target action:(SEL)action
{

}

- (void)adShouldRemoveCloseButtonWithAdFetcher:(ANAdFetcher *)fetcher
{

}

#pragma mark ANBrowserViewControllerDelegate

- (void)browserViewControllerShouldDismiss:(ANBrowserViewController *)controller
{
	[self.controller dismissViewControllerAnimated:YES completion:^{
		self.browserViewController = nil;
	}];
}

#pragma mark ANInterstitialAdViewControllerDelegate

- (void)interstitialAdViewControllerShouldDismiss:(ANInterstitialAdViewController *)controller
{
	if ([self.delegate respondsToSelector:@selector(adWillClose:)]) {
		[self.delegate adWillClose:self];
	}
	
	[self.controller.presentingViewController dismissViewControllerAnimated:YES completion:^{
		if ([self.delegate respondsToSelector:@selector(adDidClose:)]) {
			[self.delegate adDidClose:self];
		}
	}];
}

- (NSTimeInterval)interstitialAdViewControllerTimeToDismiss
{
	if (self.autoDismissTimeInterval > 0.0)
	{
		return self.autoDismissTimeInterval;
	}

	return kAppNexusDefaultInterstitialTimeoutInterval;
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

@end
