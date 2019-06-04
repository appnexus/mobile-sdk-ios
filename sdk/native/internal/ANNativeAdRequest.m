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

#import "ANNativeAdRequest.h"
#import "ANNativeMediatedAdResponse.h"
#import "ANUniversalAdFetcher.h"
#import "ANNativeAdImageCache.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANOMIDImplementation.h"


@interface ANNativeAdRequest() <ANUniversalNativeAdFetcherDelegate>

@property (nonatomic, readwrite, strong) NSMutableArray *adFetchers;

@property (nonatomic, strong)  NSMutableSet<NSValue *>  *allowedAdSizes;

@property (nonatomic, readwrite)  BOOL  allowSmallerSizes;

@end




@implementation ANNativeAdRequest

#pragma mark - ANNativeAdRequestProtocol properties.

// ANNativeAdRequestProtocol properties.
//
@synthesize  placementId     = __placementId;
@synthesize  memberId        = __memberId;
@synthesize  inventoryCode   = __invCode;
@synthesize  location        = __location;
@synthesize  reserve         = __reserve;
@synthesize  age             = __age;
@synthesize  gender          = __gender;
@synthesize  customKeywords  = __customKeywords;
@synthesize  externalUid     = __externalUid;

@synthesize  adType          = __adType;
@synthesize  rendererId      = _rendererId;




#pragma mark - Lifecycle.

- (instancetype)init {
    
    if (self = [super init]) {
        self.customKeywords = [[NSMutableDictionary alloc] init];
        
        [self setupSizeParametersAs1x1];
        [[ANOMIDImplementation sharedInstance] activateOMIDandCreatePartner];
    }
    return self;
}

- (void) setupSizeParametersAs1x1
{
    self.allowedAdSizes     = [NSMutableSet setWithObject:[NSValue valueWithCGSize:kANAdSize1x1]];
    self.allowSmallerSizes  = NO;
    _rendererId             = 0;

    
}

- (void)loadAd {
    
    if (self.delegate) {
        [self createAdFetcher];
    } else {
        ANLogError(@"ANNativeAdRequestDelegate must be set on ANNativeAdRequest in order for an ad to begin loading");
    }
}

- (NSMutableArray *)adFetchers {
    
    if (!_adFetchers) _adFetchers = [[NSMutableArray alloc] init];
    return _adFetchers;
}

- (void)createAdFetcher {
    
    ANUniversalAdFetcher  *adFetcher  = [[ANUniversalAdFetcher alloc] initWithDelegate:self];
    [self.adFetchers addObject:adFetcher];
    [adFetcher requestAd];
}





#pragma mark - ANUniversalNativeAdFetcherDelegate.

- (void)      universalAdFetcher: (ANUniversalAdFetcher *)fetcher
    didFinishRequestWithResponse: (ANAdFetcherResponse *)response
{
    NSError  *error  = nil;

    if (!response.isSuccessful) {
        error = response.error;

    } else if (! [response.adObject isKindOfClass:[ANNativeAdResponse class]]) {
        error = ANError(@"native_request_invalid_response", ANAdResponseBadFormat);
    }

    if (error) {
        [self.delegate adRequest:self didFailToLoadWithError:error];
        [self.adFetchers removeObjectIdenticalTo:fetcher];
        return;
    }


    //
    __weak ANNativeAdRequest  *weakSelf        = self;
    ANNativeAdResponse        *nativeResponse  = (ANNativeAdResponse *)response.adObject;

    //
    if (nativeResponse.creativeId == nil) {
        NSString  *creativeId  = (NSString *) [ANGlobal valueOfGetterProperty:kANCreativeId forObject:response.adObjectHandler];
        [self setCreativeId:creativeId onObject:nativeResponse forKeyPath:kANCreativeId];
    }

    //
    dispatch_queue_t  backgroundQueue  = dispatch_queue_create(__PRETTY_FUNCTION__, DISPATCH_QUEUE_SERIAL);

    dispatch_async(backgroundQueue,
    ^{
        __strong ANNativeAdRequest  *strongSelf  = weakSelf;

        if (!strongSelf) {
           ANLogError(@"FAILED to access strongSelf.");
           return;
        }

        //
        dispatch_semaphore_t  semaphoreMainImage  = nil;
        dispatch_semaphore_t  semaphoreIconImage  = nil;

        if (self.shouldLoadMainImage && [nativeResponse respondsToSelector:@selector(setMainImage:)])
        {
            semaphoreMainImage = [self setImageInBackgroundForImageURL: nativeResponse.mainImageURL
                                                              onObject: nativeResponse
                                                            forKeyPath: @"mainImage" ];
        }

        if (self.shouldLoadIconImage && [nativeResponse respondsToSelector:@selector(setIconImage:)])
        {
            semaphoreIconImage = [self setImageInBackgroundForImageURL: nativeResponse.iconImageURL
                                                              onObject: nativeResponse
                                                            forKeyPath: @"iconImage" ];
        }


        if (semaphoreMainImage)  {
            dispatch_semaphore_wait(semaphoreMainImage, DISPATCH_TIME_FOREVER);
        }

        if (semaphoreIconImage)  {
            dispatch_semaphore_wait(semaphoreIconImage, DISPATCH_TIME_FOREVER);
        }


        dispatch_async(dispatch_get_main_queue(), ^{
            ANLogDebug(@"...END NSURL sessions.");

            [strongSelf.delegate adRequest:strongSelf didReceiveResponse:nativeResponse];
            [strongSelf.adFetchers removeObjectIdenticalTo:fetcher];
        });
    });
}

- (NSArray<NSValue *> *)adAllowedMediaTypes
{
    return  @[ @(ANAllowedMediaTypeNative) ];
}

-(NSInteger) nativeAdRendererId{
    return _rendererId;
}

- (NSDictionary *) internalDelegateUniversalTagSizeParameters
{
    NSMutableDictionary  *delegateReturnDictionary  = [[NSMutableDictionary alloc] init];
    [delegateReturnDictionary setObject:[NSValue valueWithCGSize:kANAdSize1x1]  forKey:ANInternalDelgateTagKeyPrimarySize];
    [delegateReturnDictionary setObject:self.allowedAdSizes                     forKey:ANInternalDelegateTagKeySizes];
    [delegateReturnDictionary setObject:@(self.allowSmallerSizes)               forKey:ANInternalDelegateTagKeyAllowSmallerSizes];
    
    return  delegateReturnDictionary;
}




// NB  Some duplication between ANNativeAd* and the other entry points is inevitable because ANNativeAd* does not inherit from ANAdView.
//
#pragma mark - ANUniversalAdFetcherFoundationDelegate helper methods.

- (void)setCreativeId:(NSString *)creativeId
             onObject:(id)object forKeyPath:(NSString *)keyPath
{
    [object setValue:creativeId forKeyPath:keyPath];
}


// RETURN:  dispatch_semaphore_t    For first time image requests.
//          nil                     When image is cached  -OR-  if imageURL is undefined.
//
// If semaphore is defined, call dispatch_semaphore_wait(semaphor, DISPATCH_TIME_FOREVER) to wait for this background task
//   before continuing in the calling method.
// Wait period is limited by NSURLRequest with timeoutInterval of kAppNexusNativeAdImageDownloadTimeoutInterval.
//
- (dispatch_semaphore_t) setImageInBackgroundForImageURL: (NSURL *)imageURL
                                                onObject: (id)object
                                              forKeyPath: (NSString *)keyPath
{
    if (!imageURL)  { return nil; }

    UIImage *cachedImage = [ANNativeAdImageCache imageForKey:imageURL];

    if (cachedImage) {
        [object setValue:cachedImage forKeyPath:keyPath];
        return  nil;
    }

    //
    dispatch_semaphore_t  semaphore  = dispatch_semaphore_create(0);

    NSURLRequest  *request  = [NSURLRequest requestWithURL: imageURL
                                               cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
                                           timeoutInterval: kAppNexusNativeAdImageDownloadTimeoutInterval];

    NSURLSessionDataTask  *task  =
        [[NSURLSession sharedSession] dataTaskWithRequest: request
                                        completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error)
                                        {
                                              ANLogDebug(@"BEGIN NSURL session...");

                                              NSInteger  statusCode  = -1;

                                              if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                  NSHTTPURLResponse  *httpResponse  = (NSHTTPURLResponse *)response;
                                                  statusCode = [httpResponse statusCode];
                                              }

                                              if ((statusCode >= 400) || (statusCode == -1))  {
                                                  ANLogError(@"Error downloading image: %@", error);

                                              } else {
                                                  UIImage  *image  = [UIImage imageWithData:data];

                                                  if (image) {
                                                      [ANNativeAdImageCache setImage:image forKey:imageURL];
                                                      [object setValue:image forKeyPath:keyPath];
                                                  }
                                              }

                                              dispatch_semaphore_signal(semaphore);
                                          }
         ];
    [task resume];

    //
    return  semaphore;
}




#pragma mark - ANNativeAdRequestProtocol methods.

- (void)setPlacementId:(NSString *)placementId {
    placementId = ANConvertToNSString(placementId);
    if ([placementId length] < 1) {
        ANLogError(@"Could not set placementId to non-string value");
        return;
    }
    if (placementId != __placementId) {
        ANLogDebug(@"Setting placementId to %@", placementId);
        __placementId = placementId;
    }
}

- (void)setInventoryCode:(NSString *)invCode memberId:(NSInteger) memberId{
    invCode = ANConvertToNSString(invCode);
    if (invCode && invCode != __invCode) {
        ANLogDebug(@"Setting inventory code to %@", invCode);
        __invCode = invCode;
    }
    if (memberId > 0 && memberId != __memberId) {
        ANLogDebug(@"Setting member id to %d", (int) memberId);
        __memberId = memberId;
    }
}

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy {
    self.location = [ANLocation getLocationWithLatitude:latitude
                                              longitude:longitude
                                              timestamp:timestamp
                                     horizontalAccuracy:horizontalAccuracy];
}

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy
                      precision:(NSInteger)precision {
    self.location = [ANLocation getLocationWithLatitude:latitude
                                              longitude:longitude
                                              timestamp:timestamp
                                     horizontalAccuracy:horizontalAccuracy
                                              precision:precision];
}


- (void)addCustomKeywordWithKey:(NSString *)key
                          value:(NSString *)value
{
    if (([key length] < 1) || !value) {
        return;
    }
    
    if(self.customKeywords[key] != nil){
        NSMutableArray *valueArray = (NSMutableArray *)[self.customKeywords[key] mutableCopy];
        if (![valueArray containsObject:value]) {
            [valueArray addObject:value];
        }
        self.customKeywords[key] = [valueArray copy];
    } else {
        self.customKeywords[key] = @[value];
    }
}

- (void)removeCustomKeywordWithKey:(NSString *)key
{
    if (([key length] < 1)) {
        return;
    }
    
    [self.customKeywords removeObjectForKey:key];
}

- (void)clearCustomKeywords
{
    [self.customKeywords removeAllObjects];
}


@end

