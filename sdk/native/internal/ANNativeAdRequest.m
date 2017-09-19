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



@interface ANNativeAdRequest() <ANUniversalAdFetcherDelegate>

@property (nonatomic, readwrite, strong) NSMutableArray *adFetchers;
@property (nonatomic, readwrite, strong) NSMutableDictionary<NSString *, NSArray<NSString *> *> *customKeywordsMap;

//
@property (nonatomic)          CGSize                    size1x1;
@property (nonatomic, strong)  NSMutableSet<NSValue *>  *allowedAdSizes;

@end



@implementation ANNativeAdRequest

#pragma mark - ANAdProtocolPublicAndPrivate properties.

// ANAdProtocol properties.
//
@synthesize  placementId                            = __placementId;
@synthesize  memberId                               = __memberId;
@synthesize  inventoryCode                          = __invCode;
@synthesize  location                               = __location;
@synthesize  reserve                                = __reserve;
@synthesize  age                                    = __age;
@synthesize  gender                                 = __gender;
@synthesize  customKeywords                         = __customKeywords;
@synthesize  customKeywordsMap                      = __customKeywordsMap;

@synthesize  opensInNativeBrowser                   = __opensInNativeBrowser;         
@synthesize  landingPageLoadsInBackground           = __landingPageLoadsInBackground;

@synthesize  shouldServePublicServiceAnnouncements  = __shouldServePublicServiceAnnouncements;

// ANAdProtocolPrivate properties.
//
@synthesize  allowSmallerSizes                      = __allowSmallerSizes;




#pragma mark - Lifecycle.

- (instancetype)init {
ANLogMark();
    if (self = [super init]) {
        __customKeywords = [[NSMutableDictionary alloc] init];
        __customKeywordsMap = [[NSMutableDictionary alloc] init];

        [self setupSizeParametersAs1x1];
    }
    return self;
}

- (void) setupSizeParametersAs1x1
{
    self.size1x1 = CGSizeMake(1, 1);

    self.allowedAdSizes     = [NSMutableSet setWithObject:[NSValue valueWithCGSize:self.size1x1]];
    self.allowSmallerSizes  = NO;
}

- (void)loadAd {
ANLogMark();
    if (self.delegate) {
        [self createAdFetcher];
    } else {
        ANLogError(@"ANNativeAdRequestDelegate must be set on ANNativeAdRequest in order for an ad to begin loading");
    }
}

- (NSMutableArray *)adFetchers {
ANLogMark();
    if (!_adFetchers) _adFetchers = [[NSMutableArray alloc] init];
    return _adFetchers;
}

- (void)createAdFetcher {
ANLogMark();
    ANUniversalAdFetcher  *adFetcher  = [[ANUniversalAdFetcher alloc] initWithDelegate:self];
    [self.adFetchers addObject:adFetcher];
    [adFetcher requestAd];
}




#pragma mark - ANUniversalAdFetcherDelegate.

- (void)      universalAdFetcher: (ANUniversalAdFetcher *)fetcher
    didFinishRequestWithResponse: (ANAdFetcherResponse *)response
{
ANLogMark();
    NSError *error;
    
    if (response.isSuccessful) {
        if ([response.adObject isKindOfClass:[ANNativeAdResponse class]]) {
            ANNativeAdResponse *finalResponse = (ANNativeAdResponse *)response.adObject;
            
            __weak ANNativeAdRequest *weakSelf = self;
            NSOperation *finish = [NSBlockOperation blockOperationWithBlock:
                                    ^{
                                        __strong ANNativeAdRequest *strongSelf = weakSelf;

                                        if (!strongSelf) {
                                            ANLogError(@"FAILED to access strongSelf.");
                                            return;
                                        }

                                        [strongSelf.delegate adRequest:strongSelf didReceiveResponse:finalResponse];
                                        [strongSelf.adFetchers removeObjectIdenticalTo:fetcher];
                                    } ];

            if (self.shouldLoadIconImage && [finalResponse respondsToSelector:@selector(setIconImage:)]) {
                [self setImageForImageURL:finalResponse.iconImageURL
                                 onObject:finalResponse
                               forKeyPath:@"iconImage"
                  withCompletionOperation:finish];
            }
            if (self.shouldLoadMainImage && [finalResponse respondsToSelector:@selector(setMainImage:)]) {
                [self setImageForImageURL:finalResponse.mainImageURL
                                 onObject:finalResponse
                               forKeyPath:@"mainImage"
                  withCompletionOperation:finish];
            }
            
            [[NSOperationQueue mainQueue] addOperation:finish];
        } else {
            error = ANError(@"native_request_invalid_response", ANAdResponseBadFormat);
        }
    } else {
        error = response.error;
    }
    
    if (error) {
        [self.delegate adRequest:self didFailToLoadWithError:error];
        [self.adFetchers removeObjectIdenticalTo:fetcher];
    }
}

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

- (NSOperation *)setImageForImageURL:(NSURL *)imageURL
                            onObject:(id)object
                          forKeyPath:(NSString *)keyPath {
    if (!imageURL) {
        return nil;
    }
    UIImage *cachedImage = [ANNativeAdImageCache imageForKey:imageURL];
    if (cachedImage) {
        [object setValue:cachedImage
              forKeyPath:keyPath];
        return nil;
    } else {
        __block NSData *imageData;
        NSOperation *loadImageData = [NSBlockOperation blockOperationWithBlock:^{
            NSURLRequest *request = [NSURLRequest requestWithURL:imageURL 
                                                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                 timeoutInterval:kAppNexusNativeAdImageDownloadTimeoutInterval];
            NSError *error;
            imageData = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:nil
                                                          error:&error];
            if (error) {
                ANLogError(@"Error downloading image: %@", error);
            }
        }];
        NSOperation *makeImage = [NSBlockOperation blockOperationWithBlock:^{
            UIImage *image = [UIImage imageWithData:imageData];
            if (image) {
                [ANNativeAdImageCache setImage:image
                                        forKey:imageURL];
                [object setValue:image
                      forKeyPath:keyPath];
            }
        }];
        [makeImage addDependency:loadImageData];
        [[NSOperationQueue mainQueue] addOperation:makeImage];
        NSOperationQueue *loadImageDataQueue = [[NSOperationQueue alloc] init];
        [loadImageDataQueue addOperation:loadImageData];
        return makeImage;
    }
}




#pragma mark - ANAdPropertiesPublicAndPrivate methods.

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
                          value:(NSString *)value {
    if (([key length] < 1) || !value) {
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    // ANTargetingParameters still depends on this value
    [self.customKeywords setValue:value forKey:key];
#pragma clang diagnostic pop
    if(self.customKeywordsMap[key] != nil){
        NSMutableArray *valueArray = (NSMutableArray *)[self.customKeywordsMap[key] mutableCopy];
        if (![valueArray containsObject:value]) {
            [valueArray addObject:value];
        }
        self.customKeywordsMap[key] = [valueArray copy];
    } else {
        self.customKeywordsMap[key] = @[value];
    }
}

- (void)removeCustomKeywordWithKey:(NSString *)key {
    if (([key length] < 1)) {
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    // ANTargetingParameters still depends on this value
    [self.customKeywords removeObjectForKey:key];
#pragma clang diagnostic pop
    [self.customKeywordsMap removeObjectForKey:key];
}

- (void)clearCustomKeywords {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self.customKeywords removeAllObjects];
#pragma clang diagnostic pop
    [self.customKeywordsMap removeAllObjects];
}



#pragma mark - Getter methods.

- (NSString *)placementId {
    ANLogDebug(@"placementId returned %@", __placementId);
    return __placementId;
}

- (NSInteger )memberId {
    ANLogDebug(@"memberId returned %d", (int)__memberId);
    return __memberId;
}

- (NSString *)inventoryCode {
    ANLogDebug(@"inventoryCode returned %@", __invCode);
    return __invCode;
}

- (ANLocation *)location {
    ANLogDebug(@"location returned %@", __location);
    return __location;
}

- (BOOL)shouldServePublicServiceAnnouncements {
    ANLogDebug(@"shouldServePublicServeAnnouncements returned %d", __shouldServePublicServiceAnnouncements);
    return __shouldServePublicServiceAnnouncements;
}

- (BOOL)opensInNativeBrowser {
    ANLogDebug(@"opensInNativeBrowser returned %d", __opensInNativeBrowser);
    return __opensInNativeBrowser;
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
    ANLogDebug(@"gender returned %lu", (long unsigned)__gender);
    return __gender;
}

- (NSMutableDictionary *)customKeywords {
    ANLogDebug(@"customKeywords returned %@", __customKeywords);
    return __customKeywords;
}



#pragma mark - ANAdViewInternalDelegate.

- (NSArray<NSValue *> *)adAllowedMediaTypes
{
    return  @[ @(ANAllowedMediaTypeNative) ];
}

- (NSDictionary *) internalDelegateUniversalTagSizeParameters
{
    NSMutableDictionary  *delegateReturnDictionary  = [[NSMutableDictionary alloc] init];
    [delegateReturnDictionary setObject:[NSValue valueWithCGSize:self.size1x1]  forKey:ANInternalDelgateTagKeyPrimarySize];
    [delegateReturnDictionary setObject:self.allowedAdSizes                     forKey:ANInternalDelegateTagKeySizes];
    [delegateReturnDictionary setObject:@(self.allowSmallerSizes)               forKey:ANInternalDelegateTagKeyAllowSmallerSizes];

    return  delegateReturnDictionary;
}


@end
