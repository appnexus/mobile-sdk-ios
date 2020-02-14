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
#import "ANAdView+PrivateMethods.h"

#import "ANUniversalAdFetcher.h"
#import "ANGlobal.h"
#import "ANInterstitialAdViewController.h"
#import "ANLogging.h"
#import "ANAdView+PrivateMethods.h"
#import "ANMRAIDContainerView.h"
#import "ANTrackerManager.h"
#import "ANCustomAdapter.h"
#import "ANOMIDImplementation.h"



static NSTimeInterval const kANInterstitialAdTimeout = 270.0;

// List of allowed ad sizes for interstitials.  These must fit in the
// maximum size of the view, which in this case, will be the size of
// the window.
#define kANInterstitialAdSize300x250 CGSizeMake(300,250)
#define kANInterstitialAdSize320x480 CGSizeMake(320,480)
#define kANInterstitialAdSize900x500 CGSizeMake(900,500)
#define kANInterstitialAdSize1024x1024 CGSizeMake(1024,1024)

NSString *const  kANInterstitialAdViewKey             = @"kANInterstitialAdViewKey";
NSString *const  kANInterstitialAdObjectHandlerKey    = @"kANInterstitialAdObjectHandlerKey";
NSString *const  kANInterstitialAdViewDateLoadedKey   = @"kANInterstitialAdViewDateLoadedKey";
NSString *const  kANInterstitialAdViewAuctionInfoKey  = @"kANInterstitialAdViewAuctionInfoKey";





@interface ANInterstitialAd () <ANInterstitialAdViewControllerDelegate, ANInterstitialAdViewInternalDelegate>

@property (nonatomic, readwrite, strong)  ANInterstitialAdViewController  *controller;
@property (nonatomic, readwrite, strong)  NSMutableArray                  *precachedAdObjects;
@property (nonatomic, readwrite, assign)  CGRect                           frame;
@property (nonatomic)  CGSize  containerSize;

@end




@implementation ANInterstitialAd
@synthesize frame;

#pragma mark - Initialization

- (void)initialize
{
    [super initialize];
    
    _controller           = [[ANInterstitialAdViewController alloc] init];
    _controller.delegate  = self;
    _precachedAdObjects   = [NSMutableArray array];
    _closeDelay           = kANInterstitialDefaultCloseButtonDelay;
    _opaque               = YES;
    self.containerSize      = APPNEXUS_SIZE_UNDEFINED;
    self.allowedAdSizes     = [self getDefaultAllowedAdSizes];
    self.allowSmallerSizes  = NO;
    [[ANOMIDImplementation sharedInstance] activateOMIDandCreatePartner];
}

- (nonnull instancetype)initWithPlacementId:(nonnull NSString *)placementId {
    self = [super init];
    
    if (self != nil) {
        self.placementId = placementId;
    }
    
    return self;
}

- (nonnull instancetype)initWithMemberId:(NSInteger)memberId inventoryCode:(nonnull NSString *)inventoryCode {
    self = [super init];
    
    if (self != nil) {
        [self setInventoryCode:inventoryCode memberId:memberId];
    }
    
    return self;
}

- (void)dealloc {
    self.controller.delegate = nil;
}

- (NSMutableSet *) getDefaultAllowedAdSizes
{
    NSMutableSet *defaultAllowedSizes = [NSMutableSet set];
    
    NSArray *possibleSizesArray = @[[NSValue valueWithCGSize:kANInterstitialAdSize1024x1024],
                                    [NSValue valueWithCGSize:kANInterstitialAdSize900x500],
                                    [NSValue valueWithCGSize:kANInterstitialAdSize320x480],
                                    [NSValue valueWithCGSize:kANInterstitialAdSize300x250]];
    
    for (NSValue *sizeValue in possibleSizesArray)
    {
        CGSize possibleSize = [sizeValue CGSizeValue];
        CGRect possibleSizeRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, possibleSize.width, possibleSize.height);
        if (CGRectContainsRect(self.frame, possibleSizeRect)) {
            [defaultAllowedSizes addObject:sizeValue];
        }
    }
    
    return defaultAllowedSizes;
}




#pragma mark - Setters and getters.

- (void)setAllowedAdSizes:(NSMutableSet<NSValue *> *)allowedAdSizes
{
    if (!allowedAdSizes || ([allowedAdSizes count] <= 0)) {
        ANLogError(@"adSizes array IS EMPTY.");
        return;
    }
    
    for (NSValue *valueElement in allowedAdSizes)
    {
        CGSize  sizeElement  = [valueElement CGSizeValue];
        
        if ((sizeElement.width <= 0) || (sizeElement.height <= 0)) {
            ANLogError(@"One or more elements assigned to allowedAdSizes have a width or height LESS THAN ZERO. (%@)", allowedAdSizes);
            return;
        }
    }
    
    _allowedAdSizes = [[[NSSet alloc] initWithSet:allowedAdSizes copyItems:YES] mutableCopy];
}

- (void)setCloseDelay:(NSTimeInterval)closeDelay {
    if (closeDelay > kANInterstitialMaximumCloseButtonDelay) {
        ANLogWarn(@"Maximum allowed value for closeDelay is %.1f", kANInterstitialMaximumCloseButtonDelay);
        closeDelay = kANInterstitialMaximumCloseButtonDelay;
    }
    
    _closeDelay = closeDelay;
}




#pragma mark - EntryPoint ad serving lifecycle.

- (void)loadAd {
    [super loadAd];
}

- (BOOL)isReady {
    // check the cache for a valid ad
    while ([self.precachedAdObjects count] > 0) {
        NSDictionary *adDict = self.precachedAdObjects[0];
        
        // Check to see if the ad has expired
        NSDate *dateLoaded = adDict[kANInterstitialAdViewDateLoadedKey];
        NSTimeInterval timeIntervalSinceDateLoaded = [dateLoaded timeIntervalSinceNow] * -1;
        if (timeIntervalSinceDateLoaded >= 0 && timeIntervalSinceDateLoaded < kANInterstitialAdTimeout) {
            // Found a valid ad
            id readyAd = adDict[kANInterstitialAdViewKey];
            if ([readyAd conformsToProtocol:@protocol(ANCustomAdapterInterstitial)]) {
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

- (void)displayAdFromViewController:(nonnull UIViewController *)controller autoDismissDelay:(NSTimeInterval)delay{
    
    id         adToShow         = nil;
    id         adObjectHandler  = nil;
    
    NSArray<NSString *>  *impressionURLs  = nil;
    
    
    self.controller.orientationProperties = nil;
    self.controller.useCustomClose = NO;
    
    if ([self.controller.contentView isKindOfClass:[ANMRAIDContainerView class]]) {
        ANMRAIDContainerView *mraidContainerView = (ANMRAIDContainerView *)self.controller.contentView;
        mraidContainerView.adViewDelegate = nil;
    }
    
    
    // Find first valid pre-cached ad and meta data.
    // Pull out impression URL trackers.
    //
    while ([self.precachedAdObjects count] > 0) {
        // Pull the first ad off
        NSDictionary *adDict = self.precachedAdObjects[0];
        
        // Check to see if ad has expired
        NSDate *dateLoaded = adDict[kANInterstitialAdViewDateLoadedKey];
        NSTimeInterval timeIntervalSinceDateLoaded = [dateLoaded timeIntervalSinceNow] * -1;
        if (timeIntervalSinceDateLoaded >= 0 && timeIntervalSinceDateLoaded < kANInterstitialAdTimeout) {
            // If ad is still valid, save a reference to it. We'll use it later
            adToShow         = adDict[kANInterstitialAdViewKey];
            adObjectHandler  = adDict[kANInterstitialAdObjectHandlerKey];
            
            [self.precachedAdObjects removeObjectAtIndex:0];
            break;
        }
        
        // This ad is now stale, so remove it from our cached ads.
        [self.precachedAdObjects removeObjectAtIndex:0];
    }
    
    impressionURLs = (NSArray<NSString *> *) [ANGlobal valueOfGetterProperty:kANImpressionUrls forObject:adObjectHandler];
    
    
    
    // Display the ad.
    //
    if ([adToShow isKindOfClass:[UIView class]]) {
        if (!self.controller) {
            ANLogError(@"Could not present interstitial because of a nil interstitial controller. This happens because of ANSDK resources missing from the app bundle.");
            [self adFailedToDisplay];
            return;
        }
        if ([adToShow isKindOfClass:[ANMRAIDContainerView class]]) {
            ANMRAIDContainerView *mraidContainerView = (ANMRAIDContainerView *)adToShow;
            mraidContainerView.adViewDelegate = self;
            mraidContainerView.embeddedInModalView = YES;
            mraidContainerView.shouldDismissOnClick = self.dismissOnClick;
        }
        
        self.controller.contentView = adToShow;
        self.controller.autoDismissAdDelay = delay;
        
        if (self.backgroundColor) {
            self.controller.backgroundColor = self.backgroundColor;
        }
        self.controller.modalPresentationStyle = UIModalPresentationFullScreen;
        if ([self.controller respondsToSelector:@selector(modalPresentationCapturesStatusBarAppearance)]) {
            self.controller.modalPresentationCapturesStatusBarAppearance = YES;
        }
        if (!self.opaque && [self.controller respondsToSelector:@selector(viewWillTransitionToSize:withTransitionCoordinator:)]) {
            self.controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
        }

        [ANTrackerManager fireTrackerURLArray:impressionURLs];
        impressionURLs = nil;
        
        // Fire OMID - Impression event only for AppNexus WKWebview TRUE for RTB and SSM
        if([adToShow isKindOfClass:[ANMRAIDContainerView class]])
        {
            ANMRAIDContainerView *standardAdView = (ANMRAIDContainerView *)adToShow;
            if(standardAdView.webViewController.omidAdSession){
                [[ANOMIDImplementation sharedInstance] fireOMIDImpressionOccuredEvent:standardAdView.webViewController.omidAdSession];
            }
        }

        [controller presentViewController:self.controller
                                 animated:YES
                               completion:nil];
        
        
        
    } else if ([adToShow conformsToProtocol:@protocol(ANCustomAdapterInterstitial)])
    {
        [ANTrackerManager fireTrackerURLArray:impressionURLs];
        impressionURLs = nil;
        [adToShow presentFromViewController:controller];
        
    } else {
        ANLogError(@"Display ad called, but no valid ad to show. Please load another interstitial ad.");
        [self adFailedToDisplay];
        return;
    }
    
}

- (void)displayAdFromViewController:(nonnull UIViewController *)controller{
    [self displayAdFromViewController:controller autoDismissDelay:-1];
}


#pragma mark - ANUniversalAdFetcherDelegate

- (void)universalAdFetcher:(ANUniversalAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdFetcherResponse *)response
{
    if (!response.isSuccessful) {
        [self adRequestFailedWithError:response.error andAdResponseInfo:response.adResponseInfo];
        return;
    }
    ANAdResponseInfo *adResponseInfo  = (ANAdResponseInfo *) [ANGlobal valueOfGetterProperty:kANAdResponseInfo forObject:response.adObjectHandler];
    if (adResponseInfo) {
        [self setAdResponseInfo:adResponseInfo];
    }
    NSString *creativeId = (NSString *) [ANGlobal valueOfGetterProperty:kANCreativeId forObject:response.adObjectHandler];
    if(creativeId){
        [self setCreativeId:creativeId];
    }
    
    NSMutableDictionary *adViewWithDateLoaded = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 response.adObject,        kANInterstitialAdViewKey,
                                                 response.adObjectHandler, kANInterstitialAdObjectHandlerKey,
                                                 [NSDate date],            kANInterstitialAdViewDateLoadedKey,
                                                 nil
                                                 ];

    [self.precachedAdObjects addObject:adViewWithDateLoaded];
    ANLogDebug(@"Stored ad %@ in precached ad views", adViewWithDateLoaded);
    
    [self adDidReceiveAd:self];
    
}

- (CGSize)requestedSizeForAdFetcher:(ANUniversalAdFetcher *)fetcher {
    return self.frame.size;
}

#pragma mark - ANInterstitialAdViewControllerDelegate

- (void)interstitialAdViewControllerShouldDismiss:(ANInterstitialAdViewController *)controller
{
    [self adWillClose];
    
    __weak ANInterstitialAd *weakSelf = self;
    
    [self.controller.presentingViewController dismissViewControllerAnimated:YES completion:
     ^{
         __strong ANInterstitialAd  *strongSelf  = weakSelf;
         if (!strongSelf)  { return; }
         
         strongSelf.controller = nil;
         [strongSelf adDidClose];
     }];
}

- (NSTimeInterval)closeDelayForController {
    return self.closeDelay;
}

- (void)dismissAndPresentAgainForPreferredInterfaceOrientationChange
{
    __weak ANInterstitialAd *weakSelf = self;
    
    [self.controller.presentingViewController
     dismissViewControllerAnimated: NO
     completion: ^{
         __strong ANInterstitialAd *strongSelf = weakSelf;
         if (!strongSelf)  { return; }
         
         [strongSelf.controller.presentingViewController presentViewController: strongSelf.controller
                                                                      animated: NO
                                                                    completion: nil];
     }
     ];
}




#pragma mark - ANAdViewInternalDelegate

- (NSString *)adTypeForMRAID {
    return @"interstitial";
}

- (UIViewController *)displayController {
    return self.controller;
}

- (NSDictionary *) internalDelegateUniversalTagSizeParameters
{
    self.containerSize  = self.frame.size;
    
    NSMutableSet<NSValue *>  *allowedAdSizesForSDK  = [[[NSSet alloc] initWithSet:self.allowedAdSizes copyItems:YES] mutableCopy];
    [allowedAdSizesForSDK addObject:[NSValue valueWithCGSize:kANAdSize1x1]];
    [allowedAdSizesForSDK addObject:[NSValue valueWithCGSize:self.containerSize]];
    
    self.allowSmallerSizes = NO;
    
    //
    NSMutableDictionary  *delegateReturnDictionary  = [[NSMutableDictionary alloc] init];
    [delegateReturnDictionary setObject:[NSValue valueWithCGSize:self.containerSize]  forKey:ANInternalDelgateTagKeyPrimarySize];
    [delegateReturnDictionary setObject:allowedAdSizesForSDK                          forKey:ANInternalDelegateTagKeySizes];
    [delegateReturnDictionary setObject:@(self.allowSmallerSizes)                     forKey:ANInternalDelegateTagKeyAllowSmallerSizes];
    
    return  delegateReturnDictionary;
}




#pragma mark - ANInterstitialAdViewInternalDelegate

- (void)adFailedToDisplay {
    if ([self.delegate respondsToSelector:@selector(adFailedToDisplay:)]) {
        [self.delegate adFailedToDisplay:self];
    }
}

- (void)adShouldClose {
    [self.controller closeAction:nil];
}

- (void)adShouldSetOrientationProperties:(ANMRAIDOrientationProperties *)orientationProperties {
    self.controller.orientationProperties = orientationProperties;
}

- (void)adShouldUseCustomClose:(BOOL)useCustomClose {
    self.controller.useCustomClose = useCustomClose;
}

- (NSArray<NSValue *> *)adAllowedMediaTypes
{
    return  @[ @(ANAllowedMediaTypeBanner), @(ANAllowedMediaTypeInterstitial) ];
}




#pragma mark - Helper methods.

- (CGRect)frame {
    // By definition, interstitials can only ever have the entire screen's bounds as its frame
    CGRect screenBounds = ANPortraitScreenBounds();
    if (UIInterfaceOrientationIsLandscape(self.controller.orientation)) {
        return CGRectMake(screenBounds.origin.y, screenBounds.origin.x, screenBounds.size.height, screenBounds.size.width);
    }
    return screenBounds;
}


@end

