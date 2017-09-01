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
#import "ANNativeAdFetcher.h"
#import "ANNativeAdImageCache.h"
#import "ANGlobal.h"
#import "ANLogging.h"

@interface ANNativeAdRequest () <ANNativeAdFetcherDelegate>

@property (nonatomic, readwrite, strong) NSMutableArray *adFetchers;

@end




@implementation ANNativeAdRequest

@synthesize  customKeywordsMap                      = __customKeywordsMap;
@synthesize  customKeywordsMapToStrings             = __customKeywordsMapToStrings;


- (instancetype)init {
    if (self = [super init]) {
        self.customKeywordsMap           = [[NSMutableDictionary alloc] init];
        self.customKeywordsMapToStrings  = [[NSMutableDictionary alloc] init];
    }
    return self;
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
    ANNativeAdFetcher *adFetcher = [[ANNativeAdFetcher alloc] initWithDelegate:self];
    [self.adFetchers addObject:adFetcher];
}

- (void)createAdFetcherWithBaseUrlString:(NSString *)baseUrlString {
    ANNativeAdFetcher *adFetcher = [[ANNativeAdFetcher alloc] initWithDelegate:self
                                                                 baseUrlString:baseUrlString];
    [self.adFetchers addObject:adFetcher];
}

- (void)adFetcher:(ANNativeAdFetcher *)fetcher didFinishRequestWithResponse:(ANAdFetcherResponse *)response {
    NSError *error;
    
    if (response.isSuccessful) {
        if ([response.adObject isKindOfClass:[ANNativeAdResponse class]]) {
            ANNativeAdResponse *finalResponse = (ANNativeAdResponse *)response.adObject;
            
            __weak ANNativeAdRequest *weakSelf = self;
            NSOperation *finish = [NSBlockOperation blockOperationWithBlock:^{
                ANNativeAdRequest *strongSelf = weakSelf;
                [strongSelf.delegate adRequest:strongSelf didReceiveResponse:finalResponse];
                [strongSelf.adFetchers removeObjectIdenticalTo:fetcher];
            }];
            
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

#pragma mark - ANNativeAdTargetingProtocol

@synthesize placementId = _placementId;
@synthesize memberId = _memberId;
@synthesize inventoryCode = _inventoryCode;
@synthesize gender = _gender;
@synthesize location = _location;
@synthesize reserve = _reserve;
@synthesize age = _age;



- (void)setLocationWithLatitude:(CGFloat)latitude
                      longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp
             horizontalAccuracy:(CGFloat)horizontalAccuracy {
    self.location = [ANLocation getLocationWithLatitude:latitude
                                              longitude:longitude
                                              timestamp:timestamp
                                     horizontalAccuracy:horizontalAccuracy];
}

- (void)setLocationWithLatitude:(CGFloat)latitude
                      longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp
             horizontalAccuracy:(CGFloat)horizontalAccuracy
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

    if(self.customKeywordsMap[key] != nil){
        NSMutableArray *valueArray = (NSMutableArray *)[self.customKeywordsMap[key] mutableCopy];
        if (![valueArray containsObject:value]) {
            [valueArray addObject:value];
        }
        self.customKeywordsMap[key] = [valueArray copy];
    } else {
        self.customKeywordsMap[key] = @[value];
    }

    [self updateCustomKeywordsMapToStringsForKey:key];
}

- (void) updateCustomKeywordsMapToStringsForKey:(NSString *)key
{
    NSArray   *mapValuesArray  = self.customKeywordsMap[key];
    NSString  *mapValueString  = [mapValuesArray componentsJoinedByString:@" "];

    self.customKeywordsMapToStrings[key] = mapValueString;
}

- (void)removeCustomKeywordWithKey:(NSString *)key
{
    if (([key length] < 1)) {
        return;
    }

    [self.customKeywordsMap          removeObjectForKey:key];
    [self.customKeywordsMapToStrings removeObjectForKey:key];
}

- (void)clearCustomKeywords
{
    [self.customKeywordsMap          removeAllObjects];
    [self.customKeywordsMapToStrings removeAllObjects];
}


- (void)setInventoryCode:(NSString *)inventoryCode memberId:(NSInteger)memberId{
    inventoryCode = ANConvertToNSString(inventoryCode);
    if (inventoryCode && inventoryCode != _inventoryCode) {
        ANLogDebug(@"Setting inventory code to %@", inventoryCode);
        _inventoryCode = inventoryCode;
    }
    if (memberId > 0 && memberId != _memberId) {
        ANLogDebug(@"Setting member id to %d", (int) memberId);
        _memberId = memberId;
    }
}

@end
