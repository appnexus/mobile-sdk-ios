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



#pragma mark - Lifecycle.

- (instancetype)init {
    
    if (self = [super init]) {
        self.customKeywords = [[NSMutableDictionary alloc] init];
        
        [self setupSizeParametersAs1x1];
    }
    return self;
}

- (void) setupSizeParametersAs1x1
{
    self.allowedAdSizes     = [NSMutableSet setWithObject:[NSValue valueWithCGSize:kANAdSize1x1]];
    self.allowSmallerSizes  = NO;
    
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
            
            
            if(finalResponse.creativeId == nil){
                NSString *creativeId = (NSString *) [ANGlobal valueOfGetterProperty:@"creativeId" forObject:response.adObjectHandler];
                [self setCreativeId:creativeId onObject:finalResponse forKeyPath:@"creativeId"];
              }
            
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

- (NSArray<NSValue *> *)adAllowedMediaTypes
{
    return  @[ @(ANAllowedMediaTypeNative) ];
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

- (void)setCreativeId:(NSString *)creativeId
             onObject:(id)object forKeyPath:(NSString *)keyPath
{
    [object setValue:creativeId forKeyPath:keyPath];
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

