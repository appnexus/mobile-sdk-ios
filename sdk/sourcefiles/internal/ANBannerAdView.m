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




#pragma mark - Local constants.

static NSString *const kANAdType        = @"adType";
static NSString *const kANBannerWidth   = @"width";
static NSString *const kANBannerHeight  = @"height";
static NSString *const kANInline        = @"inline";




#pragma mark -

@interface ANBannerAdView () <ANBannerAdViewInternalDelegate>

@property (nonatomic, readwrite, strong)  UIView  *contentView;

@property (nonatomic, readwrite, strong)  NSNumber  *transitionInProgress;

@property (nonatomic, readwrite, strong)  NSArray<NSString *>  *impressionURLs;

@property (nonatomic, readwrite)          NSInteger  nativeAdRendererId;

@property (nonatomic, strong)             ANNativeAdResponse  *nativeAdResponse;

@property (nonatomic, readwrite)          BOOL  loadAdHasBeenInvoked;

@property (nonatomic, readwrite, assign)  ANVideoOrientation  videoAdOrientation;
@end




#pragma mark -

@implementation ANBannerAdView

@synthesize  autoRefreshInterval  = __autoRefreshInterval;
@synthesize  contentView          = _contentView;
@synthesize  adSize               = _adSize;
@synthesize  loadedAdSize         = _loadedAdSize;
@synthesize  shouldAllowVideoDemand   = _shouldAllowVideoDemand;
@synthesize  shouldAllowNativeDemand  = _shouldAllowNativeDemand;
@synthesize  nativeAdRendererId           = _nativeAdRendererId;
@synthesize  enableNativeRendering           = _enableNativeRendering;
@synthesize  adResponse           = _adResponse;
@synthesize  minDuration             = __minDuration;
@synthesize  maxDuration             = __maxDuration;

#pragma mark Lifecycle.

- (void)initialize {
    [super initialize];
    
    self.autoresizingMask = UIViewAutoresizingNone;
    
    // Defaults.
    //
    __autoRefreshInterval   = kANBannerDefaultAutoRefreshInterval;
    _transitionDuration     = kAppNexusBannerAdTransitionDefaultDuration;
    _loadedAdSize           = APPNEXUS_SIZE_UNDEFINED;
    _adSize                 = APPNEXUS_SIZE_UNDEFINED;
    _adSizes                = nil;
    _shouldAllowNativeDemand      = NO;
    _shouldAllowVideoDemand       = NO;
    _nativeAdRendererId          = 0;
    _videoAdOrientation     = ANUnknown;    
    self.allowSmallerSizes  = NO;
    self.loadAdHasBeenInvoked = NO;
    self.enableNativeRendering = NO;

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
    [super loadAd];
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




#pragma mark - Transitions

- (void)setContentView:(UIView *)newContentView
{
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

- (void)universalAdFetcher:(ANUniversalAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdFetcherResponse *)response
{
    NSError *error;
    
    if ([response isSuccessful]) 
    {
        self.loadAdHasBeenInvoked = YES;

        id  adObject         = response.adObject;
        id  adObjectHandler  = response.adObjectHandler;

        self.contentView = nil;
        self.impressionURLs = nil;
        
        _adResponse  = (ANAdResponse *) [ANGlobal valueOfGetterProperty:kANAdResponse forObject:adObjectHandler];
        if (_adResponse) {
            [self setAdResponse:_adResponse];
        }
        
        NSString  *creativeId  = (NSString *) [ANGlobal valueOfGetterProperty:kANCreativeId forObject:adObjectHandler];
        if (creativeId) {
             [self setCreativeId:creativeId];
        }

        NSString  *adTypeString  = (NSString *) [ANGlobal valueOfGetterProperty:kANAdType forObject:adObjectHandler];
        if (adTypeString) {
            [self setAdType:[ANGlobal adTypeStringToEnum:adTypeString]];
        }

        if ([adObject isKindOfClass:[UIView class]])
        {
          
            self.contentView = adObject;
            NSString *width = (NSString *) [ANGlobal valueOfGetterProperty:kANBannerWidth forObject:adObjectHandler];
            NSString *height = (NSString *) [ANGlobal valueOfGetterProperty:kANBannerHeight forObject:adObjectHandler];

            if(width && height){
                CGSize receivedSize = CGSizeMake([width floatValue], [height floatValue]);
                _loadedAdSize = receivedSize;
            }else {
                _loadedAdSize = self.adSize;
                }
            if([adObjectHandler isKindOfClass:[ANNativeStandardAdResponse class]]){
                NSError             *registerError;
                self.nativeAdResponse  = (ANNativeAdResponse *)response.adObjectHandler;
                [self.nativeAdResponse registerViewForTracking: self.contentView
                                        withRootViewController: self.displayController
                                                clickableViews: @[]
                                                         error: &registerError];
            }
            [self adDidReceiveAd:self];

            if (_adResponse.adType == ANAdTypeBanner && !([adObjectHandler isKindOfClass:[ANNativeStandardAdResponse class]]))
            {
                
                self.impressionURLs = (NSArray<NSString *> *) [ANGlobal valueOfGetterProperty:kANImpressionUrls forObject:adObjectHandler];
                if (self.window)  {
                    [ANTrackerManager fireTrackerURLArray:self.impressionURLs];
                    self.impressionURLs = nil;
                    
                    // Fire OMID - Impression event only for AppNexus WKWebview TRUE for RTB and SSM
                    if([self.contentView isKindOfClass:[ANMRAIDContainerView class]])
                    {
                        ANMRAIDContainerView *standardAdView = (ANMRAIDContainerView *)self.contentView;
                        if(standardAdView.webViewController.omidAdSession != nil){
                            [[ANOMIDImplementation sharedInstance] fireOMIDImpressionOccuredEvent:standardAdView.webViewController.omidAdSession];
                        }
                    }
                }
            }

        } else if ([adObject isKindOfClass:[ANNativeAdResponse class]]) {
            ANNativeAdResponse  *nativeAdResponse  = (ANNativeAdResponse *)response.adObject;
            
            self.creativeId  = nativeAdResponse.creativeId;
            self.adType      = ANAdTypeNative;

            nativeAdResponse.clickThroughAction           = self.clickThroughAction;
            nativeAdResponse.landingPageLoadsInBackground = self.landingPageLoadsInBackground;

            //
            [self ad:self didReceiveNativeAd:nativeAdResponse];

        } else {
            NSString  *unrecognizedResponseErrorMessage  = [NSString stringWithFormat:@"UNRECOGNIZED ad response.  (%@)", [adObject class]];

            NSDictionary  *errorInfo  = @{NSLocalizedDescriptionKey: NSLocalizedString(
                                                                         unrecognizedResponseErrorMessage,
                                                                         @"Error: UNKNOWN ad object returned as response to multi-format ad request."
                                                                       )
                                        };

            error = [NSError errorWithDomain:AN_ERROR_DOMAIN
                                        code:ANAdResponseNonViewResponse
                                    userInfo:errorInfo];
        }

    } else {
        error = response.error;
    }


    if (error) {
        self.contentView = nil;
        [self adRequestFailedWithError:error];
    }
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
    [mediaTypes addObject:@(ANAllowedMediaTypeBanner)];
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




#pragma mark - UIView observer methods.

- (void)didMoveToWindow
{
    if (self.contentView  && ( _adResponse.adType == ANAdTypeBanner)) {
        [ANTrackerManager fireTrackerURLArray:self.impressionURLs];
        self.impressionURLs = nil;
        
        // Fire OMID - Impression event only for AppNexus WKWebview TRUE for RTB and SSM
        if([self.contentView isKindOfClass:[ANMRAIDContainerView class]])
        {
            ANMRAIDContainerView *standardAdView = (ANMRAIDContainerView *)self.contentView;
            if(standardAdView.webViewController.omidAdSession != nil){
                [[ANOMIDImplementation sharedInstance] fireOMIDImpressionOccuredEvent:standardAdView.webViewController.omidAdSession];
            }
        }
    }
}


@end

