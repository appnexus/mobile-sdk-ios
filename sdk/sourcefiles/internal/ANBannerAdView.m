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
#import "ANAdView+PrivateMethods.h"
#import "ANMRAIDContainerView.h"

#import "ANUniversalAdFetcher.h"
#import "ANLogging.h"
#import "ANTrackerManager.h"

#import "UIView+ANCategory.h"
#import "ANBannerAdView+ANContentViewTransitions.h"
#import "ANAdView+PrivateMethods.h"

#import "ANStandardAd.h"
#import "ANRTBVideoAd.h"
#import "ANMediationContainerView.h"
#import "ANMediatedAd.h"

#import "ANNativeAdRequest.h"
#import "ANNativeStandardAdResponse.h"
#import "ANNativeAdImageCache.h"
#import "ANOMIDImplementation.h"
#import "ANNativeAdResponse+PrivateMethods.h"
#import "ANNativeRenderingViewController.h"

#import "ANMRAIDContainerView.h"
#import "ANWebView.h"




#pragma mark - Local constants.

static NSString *const kANAdType        = @"adType";
static NSString *const kANBannerWidth   = @"width";
static NSString *const kANBannerHeight  = @"height";
static NSString *const kANInline        = @"inline";




#pragma mark -

@interface ANBannerAdView() <ANBannerAdViewInternalDelegate>

@property (nonatomic, readwrite, strong)  UIView  *contentView;

@property (nonatomic, readwrite, strong)  NSNumber  *transitionInProgress;

@property (nonatomic, readwrite, strong)  NSArray<NSString *>  *impressionURLs;

@property (nonatomic, readwrite)          NSInteger  nativeAdRendererId;

@property (nonatomic, strong)             ANNativeAdResponse  *nativeAdResponse;

@property (nonatomic, readwrite)          BOOL  loadAdHasBeenInvoked;

@property (nonatomic, readwrite, assign)  ANVideoOrientation  videoAdOrientation;

/**
 * This flag remembers whether the initial return of the ad object from UT Response processing
 *   indicated that the AdUnit was lazy loaded.
 *
 * NOTE: Because ANBannerAdView is a multi-format AdUnit, it may return an ad object that is NOT lazy loaded
 *       even if the feature flag is set for lazy loading (enableLazyLoad).
 *       For example when video or native ad is returnd to ANBannerAdView with enableLazyLoad=YES.
 */
@property (nonatomic, readwrite)  BOOL  didBecomeLazyAdUnit;

/**
 * This flag is set by loadLazyAd before loading the webview.  It allows the fetcher to distinguish
 *   whether the ad object is returned from UT Response processing (first pass), or is being handled
 *   only to load the webview of a lazy loaded AdUnit (second pass).
 */
@property (nonatomic, readwrite)  BOOL  isLazySecondPassThroughAdUnit;

@end




#pragma mark -

@implementation ANBannerAdView

@synthesize  autoRefreshInterval            = __autoRefreshInterval;
@synthesize  contentView                    = _contentView;
@synthesize  adSize                         = _adSize;
@synthesize  loadedAdSize                   = _loadedAdSize;
@synthesize  shouldAllowBannerDemand        = _shouldAllowBannerDemand;
@synthesize  shouldAllowVideoDemand         = _shouldAllowVideoDemand;
@synthesize  shouldAllowNativeDemand        = _shouldAllowNativeDemand;
@synthesize  nativeAdRendererId             = _nativeAdRendererId;
@synthesize  enableNativeRendering          = _enableNativeRendering;
@synthesize  adResponseInfo                 = _adResponseInfo;
@synthesize  minDuration                    = __minDuration;
@synthesize  maxDuration                    = __maxDuration;

@synthesize  countImpressionOnAdReceived    = _countImpressionOnAdReceived;
@synthesize  enableLazyLoad                 = _enableLazyLoad;


#pragma mark - Lifecycle.

- (void)initialize {
    [super initialize];
    
    self.autoresizingMask = UIViewAutoresizingNone;
    
    // Defaults.
    //
    __autoRefreshInterval         = kANBannerDefaultAutoRefreshInterval;
    _transitionDuration           = kAppNexusBannerAdTransitionDefaultDuration;
    _loadedAdSize                 = APPNEXUS_SIZE_UNDEFINED;
    _adSize                       = APPNEXUS_SIZE_UNDEFINED;
    _adSizes                      = nil;

    _shouldAllowBannerDemand      = YES;
    _shouldAllowVideoDemand       = NO;
    _shouldAllowNativeDemand      = NO;

    _nativeAdRendererId           = 0;
    _videoAdOrientation           = ANUnknown;

    self.allowSmallerSizes        = NO;
    self.loadAdHasBeenInvoked     = NO;
    self.enableNativeRendering    = NO;

    _countImpressionOnAdReceived  = NO;

    _enableLazyLoad                 = NO;
    _didBecomeLazyAdUnit            = NO;
    _isLazySecondPassThroughAdUnit  = NO;

    //
    [[ANOMIDImplementation sharedInstance] activateOMIDandCreatePartner];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.adSize = self.frame.size;
}

+ (nonnull ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(nonnull NSString *)placementId {
    return [[[self class] alloc] initWithFrame:frame placementId:placementId adSize:frame.size];
}

+ (nonnull ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(nonnull NSString *)placementId adSize:(CGSize)size{
    return [[[self class] alloc] initWithFrame:frame placementId:placementId adSize:size];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        [self initialize];

        self.backgroundColor  = [UIColor clearColor];
    }
    
    return self;
}

- (nonnull instancetype)initWithFrame:(CGRect)frame placementId:(nonnull NSString *)placementId {
    self = [self initWithFrame:frame];
    
    if (self != nil) {
        self.placementId = placementId;
    }
    
    return self;
}

- (nonnull instancetype)initWithFrame:(CGRect)frame placementId:(nonnull NSString *)placementId adSize:(CGSize)size {
    self = [self initWithFrame:frame placementId:placementId];
    
    if (self != nil) {
        self.adSize = size;
    }
    
    return self;
}

- (nonnull instancetype)initWithFrame:(CGRect)frame memberId:(NSInteger)memberId inventoryCode:(nonnull NSString *)inventoryCode {
    self = [self initWithFrame:frame];
    if (self != nil) {
        [self setInventoryCode:inventoryCode memberId:memberId];
    }
    
    return self;
    
}

- (nonnull instancetype)initWithFrame:(CGRect)frame memberId:(NSInteger)memberId inventoryCode:(nonnull NSString *)inventoryCode adSize:(CGSize)size{
    self = [self initWithFrame:frame memberId:memberId inventoryCode:inventoryCode];
    if (self != nil) {
        self.adSize = size;
    }
    return self;
}

- (void) loadAd
{
    self.loadAdHasBeenInvoked = YES;

    self.didBecomeLazyAdUnit            = NO;
    self.isLazySecondPassThroughAdUnit  = NO;

    [super loadAd];
}


- (BOOL)loadLazyAd
{
    if (!self.didBecomeLazyAdUnit) {
        ANLogWarn(@"AdUnit is NOT A CANDIDATE FOR LAZY LOADING.");
        return  NO;
    }

    if (self.contentView) {
        ANLogWarn(@"AdUnit LAZY LOAD IS ALREADY COMPLETED.");
        return  NO;
    }


    //
    self.isLazySecondPassThroughAdUnit = YES;

    BOOL  returnValue  = [self.universalAdFetcher allocateAndSetWebviewFromCachedAdObjectHandler];

    if (!returnValue)
    {
        NSError  *error  = ANError(@"lazy_ad_load_failed", ANAdResponseCode.INTERNAL_ERROR.code);
        ANLogError(@"%@", error);
        return  NO;
    }


    return  returnValue;
}




#pragma mark - Getter and Setter methods

-(void)setVideoAdOrientation:(ANVideoOrientation)videoOrientation{
    _videoAdOrientation = videoOrientation;
}

- (ANVideoOrientation) getVideoOrientation {
    return _videoAdOrientation;
}

- (CGSize)adSize {
    ANLogDebug(@"adSize returned %@", NSStringFromCGSize(_adSize));
    return  _adSize;
}

// adSize represents Universal Tag "primary_size".
//
- (void)setAdSize:(CGSize)adSize
{
    if (CGSizeEqualToSize(adSize, _adSize)) { return; }
    
    if ((adSize.width <= 0) || (adSize.height <= 0))  {
        ANLogError(@"Width and height of adSize must both be GREATER THAN ZERO.  (%@)", NSStringFromCGSize(adSize));
        return;
    }
    
    //
    self.adSizes = @[ [NSValue valueWithCGSize:adSize] ];
    
    ANLogDebug(@"Setting adSize to %@, NO smaller sizes.", NSStringFromCGSize(adSize));
}


// adSizes represents Universal Tag "sizes".
//
- (void)setAdSizes:(nonnull NSArray<NSValue *> *)adSizes
{
    NSValue  *adSizeAsValue  = [adSizes firstObject];
    if (!adSizeAsValue) {
        ANLogError(@"adSizes array IS EMPTY.");
        return;
    }
    
    for (NSValue *valueElement in adSizes)
    {
        CGSize  sizeElement  = [valueElement CGSizeValue];
        
        if ((sizeElement.width <= 0) || (sizeElement.height <= 0)) {
            ANLogError(@"One or more elements of adSizes have a width or height LESS THAN ONE (1). (%@)", adSizes);
            return;
        }
    }
    
    //
    _adSize                 = [adSizeAsValue CGSizeValue];
    _adSizes                = [[NSArray alloc] initWithArray:adSizes copyItems:YES];
    self.allowSmallerSizes  = NO;
}


// If auto refresh interval is above zero (0), enable auto refresh,
// though never with a refresh interval value below kANBannerMinimumAutoRefreshInterval.
//
- (void)setAutoRefreshInterval:(NSTimeInterval)autoRefreshInterval
{
    if (autoRefreshInterval <= kANBannerAutoRefreshThreshold) {
        __autoRefreshInterval = kANBannerAutoRefreshThreshold;
        ANLogDebug(@"Turning auto refresh off");

        return;
    }

    if (autoRefreshInterval < kANBannerMinimumAutoRefreshInterval)
    {
        __autoRefreshInterval = kANBannerMinimumAutoRefreshInterval;
        ANLogWarn(@"setAutoRefreshInterval called with value %f, autoRefreshInterval set to minimum allowed value %f.",
                      autoRefreshInterval, kANBannerMinimumAutoRefreshInterval );
    } else {
        __autoRefreshInterval = autoRefreshInterval;
        ANLogDebug(@"AutoRefresh interval set to %f seconds", __autoRefreshInterval);
    }


    //
    if (self.loadAdHasBeenInvoked) {
        [self loadAd];
    }
}

- (NSTimeInterval)autoRefreshInterval {
    ANLogDebug(@"autoRefreshInterval returned %f seconds", __autoRefreshInterval);
    return __autoRefreshInterval;
}

- (void)setEnableLazyLoad:(BOOL)booleanValue
{
    if (YES == _enableLazyLoad) {
        ANLogWarn(@"enableLazyLoad is already ENABLED.");
        return;
    }

    if (NO == booleanValue) {
        ANLogWarn(@"CANNOT DISABLE enableLazyLoad once it is set.");
        return;
    }

    // NB  Best effort to set critical section around fetcher for enableLazyLoad property.
    //
    if (self.loadAdHasBeenInvoked && (YES == self.universalAdFetcher.isFetcherLoading)) {
        ANLogWarn(@"CANNOT ENABLE enableLazyLoad while fetcher is loading.");
        return;
    }

    //
    _enableLazyLoad = YES;
}




#pragma mark - Helper methods.

- (void)fireTrackerAndOMID
{
    [ANTrackerManager fireTrackerURLArray:self.impressionURLs withBlock:nil];
    self.impressionURLs = nil;

    // Fire OMID - Impression event only for AppNexus WKWebview TRUE for RTB and SSM
    //
    if ([self.contentView isKindOfClass:[ANMRAIDContainerView class]])
    {
        ANMRAIDContainerView  *standardAdView  = (ANMRAIDContainerView *)self.contentView;

        if (standardAdView.webViewController.omidAdSession != nil)
        {
            [[ANOMIDImplementation sharedInstance] fireOMIDImpressionOccuredEvent:standardAdView.webViewController.omidAdSession];
        }
    }

}



#pragma mark - Transitions

- (void)setContentView:(UIView *)newContentView
{
    // Do not update lazy loaded webview unless the new webview candidate is defined.
    //
    //if (!newContentView && self.isLazySecondPassThroughAdUnit)  { return; }

    //
    if (newContentView != _contentView)
    {
        UIView *oldContentView = _contentView;
        _contentView = newContentView;
        
        if ([newContentView isKindOfClass:[ANMRAIDContainerView class]]) {
            ANMRAIDContainerView *adView = (ANMRAIDContainerView *)newContentView;
            adView.adViewDelegate = self;
        }
        
        if ([oldContentView isKindOfClass:[ANMRAIDContainerView class]]) {
            ANMRAIDContainerView *adView = (ANMRAIDContainerView *)oldContentView;
            adView.adViewDelegate = nil;
        }
        
        if ([newContentView isKindOfClass:[ANNativeRenderingViewController class]]) {
            ANNativeRenderingViewController *adView = (ANNativeRenderingViewController *)newContentView;
            adView.adViewDelegate = self;
        }
        
        if ([oldContentView isKindOfClass:[ANNativeRenderingViewController class]]) {
            ANNativeRenderingViewController *adView = (ANNativeRenderingViewController *)oldContentView;
            adView.adViewDelegate = nil;
        }
        
        [self performTransitionFromContentView:oldContentView
                                 toContentView:newContentView];
    }
}

- (void)addOpenMeasurementFriendlyObstruction:(nonnull UIView *)obstructionView{
    [super addOpenMeasurementFriendlyObstruction:obstructionView];
    [self setFriendlyObstruction];
}

- (void)setFriendlyObstruction
{
    if ([self.contentView isKindOfClass:[ANMRAIDContainerView class]]) {
        ANMRAIDContainerView *adView = (ANMRAIDContainerView *)self.contentView;
        if(adView.webViewController != nil && adView.webViewController.omidAdSession != nil){
            for (UIView *obstructionView in self.obstructionViews){
                [[ANOMIDImplementation sharedInstance] addFriendlyObstruction:obstructionView toOMIDAdSession:adView.webViewController.omidAdSession];
            }
        }
    }
}

- (void)removeOpenMeasurementFriendlyObstruction:(UIView *)obstructionView{
    [super removeOpenMeasurementFriendlyObstruction:obstructionView];
    if([self.contentView isKindOfClass:[ANMRAIDContainerView class]]){
        ANMRAIDContainerView *adView = (ANMRAIDContainerView *)self.contentView;
        if(adView.webViewController != nil && adView.webViewController.omidAdSession != nil){
            [[ANOMIDImplementation sharedInstance] removeFriendlyObstruction:obstructionView toOMIDAdSession:adView.webViewController.omidAdSession];
        }
    }
}

- (void)removeAllOpenMeasurementFriendlyObstructions{
    [super removeAllOpenMeasurementFriendlyObstructions];
    if ([self.contentView isKindOfClass:[ANMRAIDContainerView class]]) {
        ANMRAIDContainerView *adView = (ANMRAIDContainerView *)self.contentView;
        if(adView.webViewController != nil && adView.webViewController.omidAdSession != nil){
            [[ANOMIDImplementation sharedInstance] removeAllFriendlyObstructions:adView.webViewController.omidAdSession];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.shouldResizeAdToFitContainer)
    {
        CGFloat  horizontalScaleFactor   = self.frame.size.width / [self.contentView an_originalFrame].size.width;
        CGFloat  verticalScaleFactor     = self.frame.size.height / [self.contentView an_originalFrame].size.height;
        CGFloat  scaleFactor             = horizontalScaleFactor < verticalScaleFactor ? horizontalScaleFactor : verticalScaleFactor;
        CGAffineTransform transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
        self.contentView.transform = transform;
    }
}

- (NSNumber *)transitionInProgress {
    if (!_transitionInProgress) _transitionInProgress = @(NO);
    return _transitionInProgress;
}



#pragma mark - Implementation of abstract methods from ANAdView

- (void)loadAdFromHtml: (nonnull NSString *)html
                 width: (int)width
                height: (int)height
{
    self.adSize = CGSizeMake(width, height);
    [super loadAdFromHtml:html width:width height:height];
}




#pragma mark - ANUniversalAdFetcherDelegate

/**
 * NOTE:  How are flags used to distinguish lazy loading from regular loading of AdUnits?
 *        With the introduction of lazy loading, there are three different cases that call universalAdFetcher:didfinishRequestWithResponse:.
 *
 *        AdUnit is lazy loaded -- first return to AdUnit from UT Response processing.
 *              response.isLazy==YES
 *        Lazy AdUnit is loading webview -- second return to AdUnit, initiated by the AdUnit itself (loadLazyAd)
 *              response.isLazy==NO  &&  AdUnit.isLazySecondPassThroughAdUnit==YES
 *        AdUnit is NOT lazy loaded
 *              response.isLazy==NO  &&  AdUnit.isLazySecondPassThroughAdUnit==NO
 */
- (void)universalAdFetcher:(ANUniversalAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdFetcherResponse *)response
{
    id  adObject         = response.adObject;
    id  adObjectHandler  = response.adObjectHandler;

    BOOL  trackersShouldBeFired  = NO;

    NSError  *error  = nil;


    // Try to get ANAdResponseInfo from anything that comes through.
    //
    if (self.enableLazyLoad && adObjectHandler) {
        _adResponseInfo = (ANAdResponseInfo *) [ANGlobal valueOfGetterProperty:kANAdResponseInfo forObject:adObjectHandler];
        if (_adResponseInfo) {
            [self setAdResponseInfo:_adResponseInfo];
        }
    }


    //
    if (!response.isSuccessful)
    {
        [self finishRequest:response withReponseError:response.error];

        if (self.enableLazyLoad) {
            [self.universalAdFetcher restartAutoRefreshTimer];
            [self.universalAdFetcher startAutoRefreshTimer];
        }

        return;
    }


    // Capture state for all AdUnits.  UNLESS this is the second pass of lazy AdUnit.
    //
    if ( (!response.isLazy && !self.isLazySecondPassThroughAdUnit) || response.isLazy )
    {
        self.loadAdHasBeenInvoked = YES;

        self.contentView = nil;
        self.impressionURLs = nil;

        _adResponseInfo = (ANAdResponseInfo *) [ANGlobal valueOfGetterProperty:kANAdResponseInfo forObject:adObjectHandler];
        if (_adResponseInfo) {
            [self setAdResponseInfo:_adResponseInfo];
        }

        NSString  *creativeId  = (NSString *) [ANGlobal valueOfGetterProperty:kANCreativeId forObject:adObjectHandler];
        if (creativeId) {
             [self setCreativeId:creativeId];
        }

        NSString  *adTypeString  = (NSString *) [ANGlobal valueOfGetterProperty:kANAdType forObject:adObjectHandler];
        if (adTypeString) {
            [self setAdType:[ANGlobal adTypeStringToEnum:adTypeString]];
        }
    }

    // Process AdUnit according to class type of UIView.
    //
    if ([adObject isKindOfClass:[UIView class]] || response.isLazy)
    {
        if ( (!response.isLazy && !self.isLazySecondPassThroughAdUnit) || response.isLazy )
        {
            NSString  *width   = (NSString *) [ANGlobal valueOfGetterProperty:kANBannerWidth  forObject:adObjectHandler];
            NSString  *height  = (NSString *) [ANGlobal valueOfGetterProperty:kANBannerHeight forObject:adObjectHandler];


            if (width && height)
            {
                CGSize receivedSize = CGSizeMake([width floatValue], [height floatValue]);
                _loadedAdSize = receivedSize;
            } else {
                _loadedAdSize = self.adSize;
            }

            if (_adResponseInfo.adType == ANAdTypeBanner && !([adObjectHandler isKindOfClass:[ANNativeStandardAdResponse class]]))
            {
                self.impressionURLs = (NSArray<NSString *> *) [ANGlobal valueOfGetterProperty:kANImpressionUrls forObject:adObjectHandler];

                // Fire trackers and OMID upon attaching to UIView hierarchy or if countImpressionOnAdReceived is enabled,
                //   but only when the AdUnit is not lazy.
                //
                if (!response.isLazy  &&  (self.window || self.countImpressionOnAdReceived)) {
                    trackersShouldBeFired = YES;
                }
            }
        }


        // Return early if AdUnit is lazy loaded.
        //
        if (response.isLazy)
        {
            self.didBecomeLazyAdUnit = YES;
            self.isLazySecondPassThroughAdUnit = NO;

            [self.universalAdFetcher stopAutoRefreshTimer];

            [self lazyAdDidReceiveAd:self];
            return;

        } else {
            trackersShouldBeFired = YES;
        }


        // Handle AdUnit that is NOT lazy loaded.
        //
        self.contentView = adObject;

        if ((_adResponseInfo.adType == ANAdTypeBanner) || (_adResponseInfo.adType == ANAdTypeVideo))
        {
          [self setFriendlyObstruction];
        }

        if ([adObjectHandler isKindOfClass:[ANNativeStandardAdResponse class]])
        {
            NSError  *registerError  = nil;

            self.nativeAdResponse  = (ANNativeAdResponse *)response.adObjectHandler;

            if ((self.obstructionViews != nil) && (self.obstructionViews.count > 0))
            {
                [self.nativeAdResponse registerViewForTracking: self.contentView
                                        withRootViewController: self.displayController
                                                clickableViews: @[]
                           openMeasurementFriendlyObstructions: self.obstructionViews
                                                         error: &registerError];
            } else {
                [self.nativeAdResponse registerViewForTracking: self.contentView
                                        withRootViewController: self.displayController
                                                clickableViews: @[]
                                                         error: &registerError];
            }
        }

        if (trackersShouldBeFired) {
            [self fireTrackerAndOMID];
        }

        [self adDidReceiveAd:self];


    // Process AdUnit according to class type of ANNativeAdResponse.
    //
    } else if ([adObject isKindOfClass:[ANNativeAdResponse class]]) {
        ANNativeAdResponse  *nativeAdResponse  = (ANNativeAdResponse *)response.adObject;

        self.creativeId  = nativeAdResponse.creativeId;
        self.adType      = ANAdTypeNative;

        nativeAdResponse.clickThroughAction           = self.clickThroughAction;
        nativeAdResponse.landingPageLoadsInBackground = self.landingPageLoadsInBackground;

        //
        [self ad:self didReceiveNativeAd:nativeAdResponse];


    // AdUnit class type is UNRECOGNIZED.
    //
    } else {
        NSString  *unrecognizedResponseErrorMessage  = [NSString stringWithFormat:@"UNRECOGNIZED ad response.  (%@)", [adObject class]];

        NSDictionary  *errorInfo  = @{NSLocalizedDescriptionKey: NSLocalizedString(
                                                                     unrecognizedResponseErrorMessage,
                                                                     @"Error: UNKNOWN ad object returned as response to multi-format ad request."
                                                                   )
                                    };

        error = [NSError errorWithDomain:AN_ERROR_DOMAIN
                                    code:ANAdResponseCode.NON_VIEW_RESPONSE.code
                                userInfo:errorInfo];

        [self finishRequest:response withReponseError:error];
    }
}

- (void)finishRequest:(ANAdFetcherResponse *)response withReponseError:(NSError *)error
{
    self.contentView          = nil;
    self.didBecomeLazyAdUnit  = NO;

    // Preserve existing ANAdResponseInfo whan AdUnit is lazy loaded.
    //
    if (self.enableLazyLoad && self.isLazySecondPassThroughAdUnit) {
        response.adResponseInfo = self.adResponseInfo;
    }

    [self adRequestFailedWithError:error andAdResponseInfo:response.adResponseInfo];
}


- (NSTimeInterval)autoRefreshIntervalForAdFetcher:(ANUniversalAdFetcher *)fetcher {
    return self.autoRefreshInterval;
}

- (CGSize)requestedSizeForAdFetcher:(ANUniversalAdFetcher *)fetcher {
    return self.adSize;
}

- (ANVideoAdSubtype) videoAdTypeForAdFetcher:(ANUniversalAdFetcher *)fetcher {
    return  ANVideoAdSubtypeBannerVideo;
}

- (NSDictionary *) internalDelegateUniversalTagSizeParameters
{
    CGSize  containerSize  = self.adSize;
    
    if (CGSizeEqualToSize(self.adSize, APPNEXUS_SIZE_UNDEFINED))
    {
        containerSize           = self.frame.size;
        self.adSizes            = @[ [NSValue valueWithCGSize:containerSize] ];
        self.allowSmallerSizes  = YES;
    }
    
    //
    NSMutableDictionary  *delegateReturnDictionary  = [[NSMutableDictionary alloc] init];
    [delegateReturnDictionary setObject:[NSValue valueWithCGSize:containerSize]  forKey:ANInternalDelgateTagKeyPrimarySize];
    [delegateReturnDictionary setObject:self.adSizes                             forKey:ANInternalDelegateTagKeySizes];
    [delegateReturnDictionary setObject:@(self.allowSmallerSizes)                forKey:ANInternalDelegateTagKeyAllowSmallerSizes];
    
    return  delegateReturnDictionary;
}




#pragma mark - ANAdViewInternalDelegate

- (NSString *) adTypeForMRAID  {
    return kANInline;
}

- (void)setAllowNativeDemand: (BOOL)nativeDemand
              withRendererId: (NSInteger)rendererId
{
    _nativeAdRendererId = rendererId;
    _shouldAllowNativeDemand = nativeDemand;
}

- (NSArray<NSValue *> *)adAllowedMediaTypes
{
    NSMutableArray *mediaTypes  = [[NSMutableArray alloc] init];
    if(_shouldAllowBannerDemand){
        [mediaTypes addObject:@(ANAllowedMediaTypeBanner)];
    }
    if(_shouldAllowNativeDemand){
        [mediaTypes addObject:@(ANAllowedMediaTypeNative)];
    }
    if(_shouldAllowVideoDemand){
        [mediaTypes addObject:@(ANAllowedMediaTypeVideo)];
    }
    return  [mediaTypes copy];
}

-(NSInteger) nativeAdRendererId{
    return _nativeAdRendererId;
}

-(BOOL) enableNativeRendering{
    return _enableNativeRendering;
}

- (UIViewController *)displayController
{
    UIViewController *displayController = self.rootViewController;

    if (!displayController) {
        displayController = [self an_parentViewController];
    }

    return displayController;
}

- (BOOL)valueOfEnableLazyLoad
{
    return  self.enableLazyLoad;
}

- (BOOL)valueOfIsLazySecondPassThroughAdUnit
{
    return  self.isLazySecondPassThroughAdUnit;
}




#pragma mark - UIView observer methods.

- (void)didMoveToWindow
{
    if (self.contentView && (_adResponseInfo.adType == ANAdTypeBanner))
    {
        [self fireTrackerAndOMID];
    }
}


@end

