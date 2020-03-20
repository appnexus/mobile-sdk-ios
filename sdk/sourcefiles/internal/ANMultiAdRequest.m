/*   Copyright 2019 APPNEXUS INC

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

#import <Foundation/Foundation.h>

#import "ANMultiAdRequest.h"
#import "ANUniversalAdFetcher.h"

#import "ANAdView+PrivateMethods.h"
#import "ANNativeAdRequest+PrivateMethods.h"



#pragma mark - Private types.

//
typedef NS_ENUM(NSUInteger, MultiAdPropertyType)
{
    MultiAdPropertyTypeAutoRefreshInterval,
    MultiAdPropertyTypeManager,
    MultiAdPropertyTypeMemberID,
    MultiAdPropertyTypePublisherID,
    MultiAdPropertyTypeUUID
};

NSInteger const  kMARAdUnitIndexNotFound  = -1;



#pragma mark -

@interface  ANMultiAdRequest()  <ANAdDelegate, ANNativeAdRequestDelegate, ANUniversalRequestTagBuilderCore>

@property (nonatomic, readwrite, weak, nullable)  id<ANMultiAdRequestDelegate>  delegate;

// adUnits is an array of AdUnits managed by the MultiAdRequest.
// It is declared in a manner capable of storing weak pointers.  Pointers to deallocated AdUnits are automatically assigned to nil.
//
@property (nonatomic, readwrite, strong, nonnull)  NSPointerArray  *adUnits;

@property (nonatomic, readwrite, strong)  ANUniversalAdFetcher    *universalAdFetcher;

@end




#pragma mark -

@implementation  ANMultiAdRequest

#pragma mark Synthesized properties.

@synthesize  memberId            = __memberId;
@synthesize  publisherId         = __publisherId;
@synthesize  age                 = __age;
@synthesize  gender              = __gender;
@synthesize  location            = __location;
@synthesize  customKeywords      = __customKeywords;
@synthesize  externalUid         = __externalUid;



#pragma mark - Lifecycle.

/**
 * adUnits is a list of AdUnits ending with nil.
 */
- (nullable instancetype)initWithMemberId: (NSInteger)memberID
                                 delegate: (nullable id<ANMultiAdRequestDelegate>)delegate
                                  adUnits: (nonnull id<ANAdProtocolFoundationCore>) firstAdUnit, ...
{
    self = [super self];
    if (!self)  { return nil; }

    if (! [self setupWithMemberId:memberID publisherID:0 andDelegate:delegate]) {
        return  nil;
    }

    //
    id<ANAdProtocolFoundationCore>   adUnitArgument  = nil;

    if (! [self addAdUnit:(id<ANAdProtocolFoundationCore>)firstAdUnit])  { return nil; }

    va_list adUnitArgs;
    va_start(adUnitArgs, firstAdUnit);


    adUnitArgument = va_arg(adUnitArgs, id<ANAdProtocolFoundationCore>);

    while(adUnitArgument != nil) {
          if (! [self addAdUnit:(id<ANAdProtocolFoundationCore>)adUnitArgument])  { return nil; }
          adUnitArgument = va_arg(adUnitArgs, id<ANAdProtocolFoundationCore>);
    }

    va_end(adUnitArgs);

    //
    return  self;
}

/**
 * adUnits is a list of AdUnits ending with nil.
 */
- (nullable instancetype)initWithMemberId: (NSInteger)memberID
                              publisherId: (NSInteger)publisherID
                                 delegate: (nullable id<ANMultiAdRequestDelegate>)delegate
                                  adUnits: (nonnull id<ANAdProtocolFoundationCore>) firstAdUnit, ...
{
    self = [super self];
    if (!self)  { return nil; }

    if (! [self setupWithMemberId:memberID publisherID:publisherID andDelegate:delegate]) {
        return  nil;
    }

    //
    id<ANAdProtocolFoundationCore>   adUnitArgument  = nil;

    if (! [self addAdUnit:(id<ANAdProtocolFoundationCore>)firstAdUnit])  { return nil; }

    va_list adUnitArgs;
    va_start(adUnitArgs, firstAdUnit);


    adUnitArgument = va_arg(adUnitArgs, id<ANAdProtocolFoundationCore>);

    while(adUnitArgument != nil) {
          if (! [self addAdUnit:(id<ANAdProtocolFoundationCore>)adUnitArgument])  { return nil; }
          adUnitArgument = va_arg(adUnitArgs, id<ANAdProtocolFoundationCore>);
    }

    va_end(adUnitArgs);

    //
    return  self;
}

/**
 * adUnits is a list of AdUnits ending with nil.
 */
- (nullable instancetype)initAndLoadWithMemberId: (NSInteger)memberID
                                        delegate: (nullable id<ANMultiAdRequestDelegate>)delegate
                                         adUnits: (nonnull id<ANAdProtocolFoundationCore>) firstAdUnit, ...
{
    self = [super self];
    if (!self)  { return nil; }

    if (! [self setupWithMemberId:memberID publisherID:0 andDelegate:delegate]) {
        return  nil;
    }


    //
    id<ANAdProtocolFoundationCore>   adUnitArgument  = nil;

    if (! [self addAdUnit:(id<ANAdProtocolFoundationCore>)firstAdUnit])  { return nil; }

    va_list adUnitArgs;
    va_start(adUnitArgs, firstAdUnit);


    adUnitArgument = va_arg(adUnitArgs, id<ANAdProtocolFoundationCore>);

    while(adUnitArgument != nil) {
          if (! [self addAdUnit:(id<ANAdProtocolFoundationCore>)adUnitArgument])  { return nil; }
          adUnitArgument = va_arg(adUnitArgs, id<ANAdProtocolFoundationCore>);
    }

    va_end(adUnitArgs);


    //
    if (! [self load]) {
        return  nil;
    }

    return  self;
}

/**
 * adUnits is a list of AdUnits ending with nil.
 */
- (nullable instancetype)initAndLoadWithMemberId: (NSInteger)memberID
                                     publisherId: (NSInteger)publisherID
                                        delegate: (nullable id<ANMultiAdRequestDelegate>)delegate
                                         adUnits: (nonnull id<ANAdProtocolFoundationCore>) firstAdUnit, ...
{
    self = [super self];
    if (!self)  { return nil; }

    if (! [self setupWithMemberId:memberID publisherID:publisherID andDelegate:delegate]) {
        return  nil;
    }


    //
    id<ANAdProtocolFoundationCore>   adUnitArgument  = nil;

    if (! [self addAdUnit:(id<ANAdProtocolFoundationCore>)firstAdUnit])  { return nil; }

    va_list adUnitArgs;
    va_start(adUnitArgs, firstAdUnit);


    adUnitArgument = va_arg(adUnitArgs, id<ANAdProtocolFoundationCore>);

    while(adUnitArgument != nil) {
          if (! [self addAdUnit:(id<ANAdProtocolFoundationCore>)adUnitArgument])  { return nil; }
          adUnitArgument = va_arg(adUnitArgs, id<ANAdProtocolFoundationCore>);
    }

    va_end(adUnitArgs);


    //
    if (! [self load]) {
        return  nil;
    }

    return  self;
}

- (nullable instancetype)initWithMemberId:(NSInteger)memberID andDelegate:(nullable id<ANMultiAdRequestDelegate>)delegate
{
    self = [super self];
    if (!self)  { return nil; }

    if (! [self setupWithMemberId:memberID publisherID:0 andDelegate:delegate]) {
        return  nil;
    }

    return  self;
}

- (nullable instancetype)initWithMemberId: (NSInteger)memberID
                              publisherId: (NSInteger)publisherID
                              andDelegate: (nullable id<ANMultiAdRequestDelegate>)delegate
{
    self = [super self];
    if (!self)  { return nil; }

    if (! [self setupWithMemberId:memberID publisherID:publisherID andDelegate:delegate]) {
        return  nil;
    }

    return  self;
}


/*
 * Return: YES on success; otherwise, NO.
 */
- (BOOL)setupWithMemberId:(NSInteger)memberId publisherID:(NSInteger)publisherId andDelegate:(nullable id<ANMultiAdRequestDelegate>)delegate
{
    if (memberId <= 0) {
        ANLogError(@"memberId MUST BE GREATER THAN zero (0).");
        return  NO;
    }

    if (publisherId < 0) {
        ANLogError(@"publisherId MUST BE non-negative.");
        return  NO;
    }

    //
    _delegate            = delegate;

    _adUnits             = [NSPointerArray weakObjectsPointerArray];

    _universalAdFetcher  = [[ANUniversalAdFetcher alloc] initWithMultiAdRequestManager: self andCustomJavaScript:self.customJavaScript];

    //
    __memberId          = memberId;
    __publisherId       = publisherId;
    __age               = @"";
    __gender            = ANGenderUnknown;
    __location          = nil;
    __customKeywords    = [[NSMutableDictionary alloc] init];
    __externalUid       = nil;

    //
    return  YES;
}


/**
 * Add an ad unit to MultiAdRequest object.
 * Check that its fields do not conflict with MAR fields.  Set its MAR manager delegate.
 *
 * Returns: YES on success; otherwise, NO.
 */
- (BOOL)addAdUnit:(nonnull id<ANAdProtocolFoundationCore>)newAdUnit
{
    NSInteger   newMemberID     = -1;
    NSInteger   newPublisherId  = -1;
    NSString   *newUUIDKey      = @"";

    NSArray<id>  *getProperties  = nil;
    NSNull       *nullObj        = [NSNull null];


    // Capture memberID, UUID and delegate from newAdUnit.
    //
    getProperties = [self adUnit: newAdUnit
                   getProperties: @[ @(MultiAdPropertyTypeMemberID), @(MultiAdPropertyTypePublisherID), @(MultiAdPropertyTypeUUID), @(MultiAdPropertyTypeManager) ] ];

    if ([getProperties count] != 4) {
        ANLogError(@"FAILED to read newAdUnit properties.");
        return  NO;
    }

    if (@available(iOS 11, *))
    {
        [getProperties[0] getValue:&newMemberID    size:sizeof(NSUInteger)];
        [getProperties[1] getValue:&newPublisherId size:sizeof(NSUInteger)];
    } else {
        [getProperties[0] getValue:&newMemberID];
        [getProperties[1] getValue:&newPublisherId];
    }

    newUUIDKey = getProperties[2];


    // Check that newAdUnit is not already managed by this or another MultiAdRequest object.
    //
    if (getProperties[3] != nullObj)
    {
        if ([self indexOfAdUnitWithUUIDKey:newUUIDKey] != kMARAdUnitIndexNotFound) {
            ANLogError(@"IGNORING newAdUnit because it is already managed by this MultiAdRequest object.");
        } else {
            ANLogError(@"REJECTING newAdUnit because it is managed by another MultiAdRequest object.");
        }

        return  NO;
    }


    // If newAdUnit defines its memberID or publisherID, check against equivalent MultiAdRequest values.
    //
    if (newMemberID > 0) {
        if (self.memberId != newMemberID)  { return NO; }
    }

    if (newPublisherId > 0) {
        if (self.publisherId != newPublisherId)  { return NO; }
    }

    // Set the MultiAdRequest manager delegates in the ad unit.
    //
    [self adUnit:newAdUnit setManager:self];


    //
    [self.adUnits addPointer:(void *)newAdUnit];

    return  YES;
}

/**
 * Remove an ad unit from MultiAdRequest object.
 * Set its MAR manager delegate to nil.
 *
 * Returns: YES on success; otherwise, NO.
 */
- (BOOL)removeAdUnit:(nonnull id<ANAdProtocolFoundationCore>)adUnit
{
    NSString    *auUUIDKey  = nil;
    NSInteger    auIndex    = -1;

    NSArray<id>  *getProperties  = nil;

    //
    getProperties = [self adUnit: adUnit
                   getProperties: @[ @(MultiAdPropertyTypeUUID) ] ];

    if ([getProperties count] != 1) {
        ANLogError(@"FAILED to read adUnit property.");
        return  NO;
    }

    auUUIDKey = getProperties[0];

    auIndex = [self indexOfAdUnitWithUUIDKey:auUUIDKey];
    if (auIndex == kMARAdUnitIndexNotFound)
    {
        ANLogError(@"AdUnit is not managed by this Multi-Ad Request instance.  (%@)", auUUIDKey);
        return  NO;
    }


    //
    [self adUnit:adUnit setManager:nil];

    [self.adUnits removePointerAtIndex:auIndex];

    return  YES;
}


/**
 * RETURNS: YES if fetcher is started; otherwise, NO.
 */
- (BOOL)load
{
    NSString  *errorString  = nil;

    if ([self.adUnits count] <= 0)  {
        errorString = @"MultiAdRequest instance CONTAINS NO AdUnits.";
    }

    if (! self.universalAdFetcher)  {
        errorString = @"Fetcher is UNALLOCATED.  FAILED TO FETCH tags via UT.";
    }


    if (errorString)
    {
        NSError  *sessionError  = ANError(@"multi_ad_request_failed %@", ANAdResponseInvalidRequest, errorString);

        if ([self.delegate respondsToSelector:@selector(multiAdRequest:didFailWithError:)]) {
            [self.delegate multiAdRequest:self didFailWithError:sessionError];
        }

        return  NO;
    }

    
    //
    [self.universalAdFetcher stopAdLoad];

    [self.universalAdFetcher requestAd];

    return  YES;
}

- (void)dealloc
{
    [self.universalAdFetcher stopAdLoad];
}




#pragma mark - Getters/Setters.

- (NSUInteger)countOfAdUnits
{
    return  [self.adUnits count];
}

- (void)setPublisherId:(NSInteger)publisherId
{
    ANLogError(@"publisherId may only be SET WITH INITIALIZERS.");
}




#pragma mark - Private methods.

- (void)internalMultiAdRequestDidComplete
{
    if ([self.delegate respondsToSelector:@selector(multiAdRequestDidComplete:)]) {
        [self.delegate multiAdRequestDidComplete:self];
    }
}

- (void)internalMultiAdRequestDidFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(multiAdRequest:didFailWithError:)]) {
        [self.delegate multiAdRequest:self didFailWithError:error];
    }
}

/**
 * NB  Passes internal pointer back to calling environment.
 */
- (nonnull NSPointerArray *)internalGetAdUnits
{
    return  self.adUnits;
}

/**
 * NB  Passes internal pointer back to calling environment.
 */
- (nullable id<ANAdProtocolFoundationCore>)internalGetAdUnitByUUID:(nonnull NSString *)uuidKey
{
    NSInteger  adunitIndex  = [self indexOfAdUnitWithUUIDKey:uuidKey];

    if (kMARAdUnitIndexNotFound == adunitIndex) {
        return  nil;
    } else {
        return  [self.adUnits pointerAtIndex:adunitIndex];
    }
}



#pragma mark - Helper methods.

/**
 * Get an arbitrary number of properties from an arbitrary ad unit.
 *
 * RETURNS:
 *   An array of objects that represent the items getted, in the order in which they were accessed.
 *   Non-class values are passed via NSValue, nil is passed as NSNull.
 *   All properties in the list are considered, even if there are errs along the way.
 *   nil is returned instead of an array in the case of method fatal errors.
 */
- (nullable NSArray<id> *)adUnit: (nonnull id)adUnit
                   getProperties: (nonnull NSArray<NSNumber *> *)getTypes
{
    ANAdView           *adview      = nil;
    ANNativeAdRequest  *nativead    = nil;

    NSMutableArray<id>  *returnValuesArray  = [[NSMutableArray<id> alloc] init];
    NSNull              *nullObj            = [NSNull null];


    //
    if ([adUnit isKindOfClass:[ANAdView class]]) {
        adview = (ANAdView *)adUnit;
    } else if ([adUnit isKindOfClass:[ANNativeAdRequest class]]) {
        nativead = (ANNativeAdRequest *)adUnit;
    } else {
        ANLogError(@"(internal) UNRECOGNIZED ad unit class.  (%@)", [adUnit class]);
        return  nil;
    }


    // Get values.
    //
    for (NSNumber *gt in getTypes)
    {
        MultiAdPropertyType  getType  = (MultiAdPropertyType)[gt integerValue];

        switch (getType)
        {
            case MultiAdPropertyTypeManager:
            {
                id  marManager  = (adview ? (id)adview.marManager : (id)nativead.marManager);
                [returnValuesArray addObject:(marManager ? marManager : nullObj)];
                break;
            }

            case MultiAdPropertyTypeMemberID:
                [returnValuesArray addObject:(adview ? @(adview.memberId) : @(nativead.memberId))];
                break;

            case MultiAdPropertyTypePublisherID:
                [returnValuesArray addObject:(adview ? @(adview.publisherId) : @(nativead.publisherId) )];
                break;

            case MultiAdPropertyTypeUUID:
                [returnValuesArray addObject:(adview ? adview.utRequestUUIDString : nativead.utRequestUUIDString)];
                break;

            default:
                ANLogError(@"(internal) UNKNOWN MultiAdPropertyType getType.  (%@).", @(getType));
                [returnValuesArray addObject:nullObj];
        }
    }


    //
    return  returnValuesArray;
}

/**
 * Set the delegate of an arbitrary ad unit.
 *
 * Return: YES on success; NO otherwise.
 */
- (void)adUnit: (nonnull id)adUnit
    setManager: (nullable id)delegate
{
    ANAdView           *adview          = nil;
    ANNativeAdRequest  *nativead        = nil;

    //
    if ([adUnit isKindOfClass:[ANAdView class]])
    {
        adview = (ANAdView *)adUnit;
        adview.marManager = (ANMultiAdRequest *)delegate;

    } else if ([adUnit isKindOfClass:[ANNativeAdRequest class]])
    {
        nativead = (ANNativeAdRequest *)adUnit;
        nativead.marManager = (ANMultiAdRequest *)delegate;

    } else {
        ANLogError(@"(internal) UNRECOGNIZED ad unit class.  (%@)", [adUnit class]);
    }

    //
    return;
}

- (NSInteger)indexOfAdUnitWithUUIDKey:(nonnull NSString *)uuidKey
{
    NSInteger   adunitIndex  = kMARAdUnitIndexNotFound;
    NSString   *adunitUUID   = nil;

    for (id au in self.adUnits)
    {
        adunitIndex += 1;

        if (!au) {
            ANLogError(@"ELEMENT MISSING from array of AdUnits.");
            continue;
        }

        if ([au isKindOfClass:[ANAdView class]]) {
            adunitUUID = ((ANAdView *)au).utRequestUUIDString;
        } else if ([au isKindOfClass:[ANNativeAdRequest class]]) {
            adunitUUID = ((ANNativeAdRequest *)au).utRequestUUIDString;
        } else {
            ANLogError(@"(internal) UNRECOGNIZED ad unit class.  (%@)", [au class]);
            return  kMARAdUnitIndexNotFound;
        }

        if ([adunitUUID isEqualToString:uuidKey])
        {
            ANLogDebug(@"MATCHED uuidKey.  (%@)", uuidKey);   //DEBUG
            return  adunitIndex;
        }
    }

    //
    return  kMARAdUnitIndexNotFound;
}




#pragma mark - ANAdProtocol.

- (void)adDidReceiveAd:(nonnull id)ad
{
    //EMPTY
}

- (void)ad:(nonnull id)ad didReceiveNativeAd:(nonnull id)responseInstance
{
    //EMPTY
}


- (void)ad:(nonnull id)ad requestFailedWithError:(nonnull NSError *)error
{
    //EMPTY
}

- (void)adRequestFailedWithError:(NSError *)error
{
    //UNUSED
}


- (void)adRequest:(nonnull ANNativeAdRequest *)request didReceiveResponse:(nonnull ANNativeAdResponse *)response
{
    //EMPTY
}

- (void)adRequest:(nonnull ANNativeAdRequest *)request didFailToLoadWithError:(nonnull NSError *)error
{
    //EMPTY
}


- (void)addCustomKeywordWithKey:(nonnull NSString *)key
                          value:(nonnull NSString *)value
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

- (void)removeCustomKeywordWithKey:(nonnull NSString *)key
{
    if (([key length] < 1)) {
        return;
    }

    //check if the key exist before calling remove
    NSArray *keysArray = [self.customKeywords allKeys];

    if([keysArray containsObject:key]){
        [self.customKeywords removeObjectForKey:key];
    }

}

- (void)clearCustomKeywords
{
    [self.customKeywords removeAllObjects];
}


- (void)setLocationWithLatitude:(CGFloat)latitude
                      longitude:(CGFloat)longitude
                      timestamp:(nullable NSDate *)timestamp
             horizontalAccuracy:(CGFloat)horizontalAccuracy
{
    self.location = [ANLocation getLocationWithLatitude:latitude
                                              longitude:longitude
                                              timestamp:timestamp
                                     horizontalAccuracy:horizontalAccuracy];
}

- (void)setLocationWithLatitude:(CGFloat)latitude
                      longitude:(CGFloat)longitude
                      timestamp:(nullable NSDate *)timestamp
             horizontalAccuracy:(CGFloat)horizontalAccuracy
                      precision:(NSInteger)precision
{
    self.location = [ANLocation getLocationWithLatitude:latitude
                                              longitude:longitude
                                              timestamp:timestamp
                                     horizontalAccuracy:horizontalAccuracy
                                              precision:precision];
}


@end
