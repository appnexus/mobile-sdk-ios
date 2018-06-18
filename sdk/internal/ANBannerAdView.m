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
#import "UIWebView+ANCategory.h"
#import "ANBannerAdView+ANContentViewTransitions.h"
#import "ANAdView+PrivateMethods.h"

#import "ANStandardAd.h"
#import "ANRTBVideoAd.h"
#import "ANMediationContainerView.h"
#import "ANMediatedAd.h"

#import "ANNativeAdRequest.h"
#import "ANNativeStandardAdResponse.h"
#import "ANNativeAdImageCache.h"




@interface ANBannerAdView () <ANBannerAdViewInternalDelegate>

@property (nonatomic, readwrite, strong)  UIView  *contentView;

@property (nonatomic, readwrite, strong)  NSNumber  *transitionInProgress;

@property (nonatomic, readwrite, strong)  NSArray<NSString *>  *impressionURLs;

@end



@implementation ANBannerAdView

@synthesize  autoRefreshInterval  = __autoRefreshInterval;
@synthesize  contentView          = _contentView;
@synthesize  adSize               = _adSize;




#pragma mark - Lifecycle.

- (void)initialize {
    [super initialize];
    
    self.autoresizingMask = UIViewAutoresizingNone;
    
    // Defaults.
    //
    __autoRefreshInterval   = kANBannerDefaultAutoRefreshInterval;
    _transitionDuration     = kAppNexusBannerAdTransitionDefaultDuration;

    _adSize                 = APPNEXUS_SIZE_UNDEFINED;
    _adSizes                = nil;
    self.allowSmallerSizes  = NO;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.adSize = self.frame.size;
}

+ (ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(NSString *)placementId {
    return [[[self class] alloc] initWithFrame:frame placementId:placementId adSize:frame.size];
}

+ (ANBannerAdView *)adViewWithFrame:(CGRect)frame placementId:(NSString *)placementId adSize:(CGSize)size {
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

- (instancetype)initWithFrame:(CGRect)frame placementId:(NSString *)placementId {
    self = [self initWithFrame:frame];
    
    if (self != nil) {
        self.placementId = placementId;
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame placementId:(NSString *)placementId adSize:(CGSize)size {
    self = [self initWithFrame:frame placementId:placementId];
    
    if (self != nil) {
        self.adSize = size;
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame memberId:(NSInteger)memberId inventoryCode:(NSString *)inventoryCode {
    self = [self initWithFrame:frame];
    if (self != nil) {
        [self setInventoryCode:inventoryCode memberId:memberId];
    }
    
    return self;
    
}

- (instancetype)initWithFrame:(CGRect)frame memberId:(NSInteger)memberId inventoryCode:(NSString *)inventoryCode adSize:(CGSize)size{
    self = [self initWithFrame:frame memberId:memberId inventoryCode:inventoryCode];
    if (self != nil) {
        self.adSize = size;
    }
    return self;
}

- (void) loadAd
{
    [super loadAd];
}




#pragma mark - Getter and Setter methods

- (CGSize)adSize {
    ANLogDebug(@"adSize returned %@", NSStringFromCGSize(_adSize));
    return  _adSize;
}

// adSize represents /ut/v2 "primary_size".
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


// adSizes represents /ut/v2 "sizes".
//
- (void)setAdSizes:(NSArray<NSValue *> *)adSizes
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


// if auto refresh is above the threshold (0), turn auto refresh on
// minimum allowed value for auto refresh is (15).
//
- (void)setAutoRefreshInterval:(NSTimeInterval)autoRefreshInterval
{
    if (autoRefreshInterval > kANBannerAutoRefreshThreshold)
    {
        if (autoRefreshInterval < kANBannerMinimumAutoRefreshInterval)
        {
            __autoRefreshInterval = kANBannerMinimumAutoRefreshInterval;
            ANLogWarn(@"setAutoRefreshInterval called with value %f, AutoRefresh interval set to minimum allowed value %f", autoRefreshInterval, kANBannerMinimumAutoRefreshInterval);
        } else {
            __autoRefreshInterval = autoRefreshInterval;
            ANLogDebug(@"AutoRefresh interval set to %f seconds", __autoRefreshInterval);
        }
        
        [self.universalAdFetcher stopAdLoad];
        
        ANLogDebug(@"New autoRefresh interval set. Making ad request.");
        [self.universalAdFetcher requestAd];

    } else {
        ANLogDebug(@"Turning auto refresh off");
        __autoRefreshInterval = autoRefreshInterval;
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
        if ([newContentView isKindOfClass:[UIWebView class]]) {
            UIWebView *webView = (UIWebView *)newContentView;
            [webView an_removeDocumentPadding];
            [webView an_setMediaProperties];
        }
        
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
        
        [self performTransitionFromContentView:oldContentView
                                 toContentView:newContentView];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.shouldResizeAdToFitContainer && [self.contentView isKindOfClass:[ANMRAIDContainerView class]])
    {
        ANMRAIDContainerView *standardAdView = (ANMRAIDContainerView *)self.contentView;

        CGFloat  horizontalScaleFactor   = self.frame.size.width / [standardAdView an_originalFrame].size.width;
        CGFloat  verticalScaleFactor     = self.frame.size.height / [standardAdView an_originalFrame].size.height;
        CGFloat  scaleFactor             = horizontalScaleFactor < verticalScaleFactor ? horizontalScaleFactor : verticalScaleFactor;

        CGAffineTransform transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
        standardAdView.transform = transform;
    }
}

- (NSNumber *)transitionInProgress {
    if (!_transitionInProgress) _transitionInProgress = @(NO);
    return _transitionInProgress;
}




#pragma mark - Implementation of abstract methods from ANAdView

- (void)loadAdFromHtml: (NSString *)html
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
        id  adObject         = response.adObject;
        id  adObjectHandler  = response.adObjectHandler;

        self.contentView = nil;
        self.impressionURLs = nil;
        
        
        NSString  *creativeId  = (NSString *) [ANGlobal valueOfGetterProperty:@"creativeId" forObject:adObjectHandler];
        if (creativeId) {
             [self setCreativeId:creativeId];
        }

        NSString  *adTypeString  = (NSString *) [ANGlobal valueOfGetterProperty:@"adType" forObject:adObjectHandler];
        if (adTypeString) {
            [self setAdType:[ANGlobal adTypeStringToEnum:adTypeString]];
        }


        if ([adObject isKindOfClass:[UIView class]])
        {
            self.contentView = adObject;
            [self adDidReceiveAd];
            
            if (! [adObjectHandler isKindOfClass:[ANRTBVideoAd class]])
            {
                self.impressionURLs = (NSArray<NSString *> *) [ANGlobal valueOfGetterProperty:@"impressionUrls" forObject:adObjectHandler];

                @synchronized (self)
                {
                    if (self.window)  {
                        [ANTrackerManager fireTrackerURLArray:self.impressionURLs];
                        self.impressionURLs = nil;
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
            __weak ANBannerAdView  *weakSelf  = self;
            NSOperation *finish = [NSBlockOperation blockOperationWithBlock:
                                   ^{
                                       __strong ANBannerAdView  *strongSelf  = weakSelf;

                                       if (!strongSelf) {
                                           ANLogError(@"FAILED to access strongSelf.");
                                           return;
                                       }

                                       [strongSelf adDidReceiveAd:nativeAdResponse];
                                   } ];



            if ([nativeAdResponse respondsToSelector:@selector(setIconImage:)])
            {
                [self setImageForImageURL: nativeAdResponse.iconImageURL
                                 onObject: nativeAdResponse
                               forKeyPath: @"iconImage"
                  withCompletionOperation: finish];
            }

            if ([nativeAdResponse respondsToSelector:@selector(setMainImage:)])
            {
                [self setImageForImageURL: nativeAdResponse.mainImageURL
                                 onObject: nativeAdResponse
                               forKeyPath: @"mainImage"
                  withCompletionOperation: finish];
            }

            [[NSOperationQueue mainQueue] addOperation:finish];

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




#pragma mark - ANUniversalAdFetcherFoundationDelegate helper methods.

- (void)setImageForImageURL:(NSURL *)imageURL
                   onObject:(id)object
                 forKeyPath:(NSString *)keyPath
    withCompletionOperation:(NSOperation *)operation {

    NSOperation *dependentOperation = [self setImageForImageURL:imageURL
                                                       onObject:object
                                                     forKeyPath:keyPath];
    if (dependentOperation) {
        [operation addDependency:dependentOperation];
    }
}


- (NSOperation *)setImageForImageURL: (NSURL *)imageURL
                            onObject: (id)object
                          forKeyPath: (NSString *)keyPath
{
    if (!imageURL) {
        return nil;
    }

    UIImage *cachedImage = [ANNativeAdImageCache imageForKey:imageURL];

    if (cachedImage) {
        [object setValue:cachedImage forKeyPath:keyPath];
        return nil;

    } else {
        NSOperation *loadImageData = [NSBlockOperation blockOperationWithBlock:^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            NSURLRequest *request = [NSURLRequest requestWithURL:imageURL
                                                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                 timeoutInterval:kAppNexusNativeAdImageDownloadTimeoutInterval];

            NSURLSessionDataTask *task = [[NSURLSession sharedSession]
                                          dataTaskWithRequest:request
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              NSInteger statusCode = -1;
                                              if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                  statusCode = [httpResponse statusCode];

                                              }

                                              if (statusCode >= 400 || statusCode == -1)  {
                                                  ANLogError(@"Error downloading image: %@", error);

                                              }else{
                                                  UIImage *image = [UIImage imageWithData:data];
                                                  if (image) {
                                                      [ANNativeAdImageCache setImage:image
                                                                              forKey:imageURL];
                                                      [object setValue:image
                                                            forKeyPath:keyPath];
                                                  }
                                              }
                                              dispatch_semaphore_signal(semaphore);

                                          }];

            [task resume];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

        }];

        [[NSOperationQueue mainQueue] addOperation:loadImageData];
        return loadImageData;
    }
}




#pragma mark - ANAdViewInternalDelegate

- (NSString *) adTypeForMRAID  {
    return @"inline";
}

- (NSArray<NSValue *> *)adAllowedMediaTypes
{
    return  @[ @(ANAllowedMediaTypeBanner), @(ANAllowedMediaTypeVideo), @(ANAllowedMediaTypeNative) ];
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
    @synchronized (self)
    {
        if (self.contentView) {
            [ANTrackerManager fireTrackerURLArray:self.impressionURLs];
            self.impressionURLs = nil;
        }
    }
}


@end

