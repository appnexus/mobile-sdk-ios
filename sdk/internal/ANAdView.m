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

#import "ANAdView.h"

#import "ANAdFetcher.h"     //FIX -- deprecated TOSS
#import "ANUniversalAdFetcher.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANAdServerResponse.h"

#import "UIView+ANCategory.h"
#import "UIWebView+ANCategory.h"



#define  DEFAULT_PUBLIC_SERVICE_ANNOUNCEMENT  NO


static Boolean  useUniversalTags  = YES;    //FIX -- temporary for DEBUG
//static Boolean  useUniversalTags  = NO;    //FIX -- temporary for DEBUG




@interface ANAdView () <ANAdFetcherDelegate, ANUniversalAdFetcherDelegate, ANAdViewInternalDelegate>

@property (nonatomic, readwrite, strong) ANAdFetcher           *adFetcher;
@property (nonatomic, readwrite, strong) ANUniversalAdFetcher  *universalAdFetcher;

@property (nonatomic, readwrite, weak) id<ANAdDelegate> delegate;
@property (nonatomic, readwrite, weak) id<ANAppEventDelegate> appEventDelegate;
@property (nonatomic, readwrite, strong) NSMutableDictionary<NSString *, NSArray<NSString *> *> *customKeywordsMap;

@end



@implementation ANAdView

// ANAdProtocol properties.
//
@synthesize  placementId                            = __placementId;
@synthesize  memberId                               = __memberId;
@synthesize  inventoryCode                          = __invCode;
@synthesize  opensInNativeBrowser                   = __opensInNativeBrowser;
@synthesize  shouldServePublicServiceAnnouncements  = __shouldServePublicServiceAnnouncements;
@synthesize  location                               = __location;
@synthesize  reserve                                = __reserve;
@synthesize  age                                    = __age;
@synthesize  gender                                 = __gender;
@synthesize  customKeywords                         = __customKeywords;
@synthesize  customKeywordsMap                      = __customKeywordsMap;
@synthesize  landingPageLoadsInBackground           = __landingPageLoadsInBackground;
@synthesize  adSize                                 = __adSize;
@synthesize  allowedAdSizes                         = __allowedAdSizes;



#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    
    if (self != nil) {
        [self initialize];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize {
    self.clipsToBounds = YES;
    self.adFetcher = [[ANAdFetcher alloc] init];
    self.adFetcher.delegate = self;

    self.universalAdFetcher = [[ANUniversalAdFetcher alloc] initWithDelegate:self];

    __shouldServePublicServiceAnnouncements  = DEFAULT_PUBLIC_SERVICE_ANNOUNCEMENT;
    __location                               = nil;
    __reserve                                = 0.0f;
    __customKeywords                         = [[NSMutableDictionary alloc] init];
    __customKeywordsMap                      = [[NSMutableDictionary alloc] init];
    __landingPageLoadsInBackground           = YES;
}

- (void)dealloc
{
ANLogMark();
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if (!useUniversalTags) {
        self.adFetcher.delegate = nil;
        [self.adFetcher stopAd];
        // MUST be called. stopAd invalidates the autoRefresh timer, which is retaining the adFetcher as well.

    } else {
            //FIX  need stopAd for UT?  YES for url connection, NO for timer which should be encapsulated separately, perhaps in ANBannerPreviewViewController
        [self.universalAdFetcher stopAdLoad];
    }
}


- (void)loadAd
{
ANLogMark();
    BOOL  placementIdValid    = [self.placementId length] >= 1;
    BOOL  inventoryCodeValid  = ([self memberId] >=1 ) && [self inventoryCode];

    if (!placementIdValid && !inventoryCodeValid) {
        NSString      *errorString  = ANErrorString(@"no_placement_id");
        NSDictionary  *errorInfo    = @{NSLocalizedDescriptionKey: errorString};
        NSError       *error        = [NSError errorWithDomain:AN_ERROR_DOMAIN code:ANAdResponseInvalidRequest userInfo:errorInfo];

        ANLogError(@"%@", errorString);
        [self adRequestFailedWithError:error];
        return;
    }

    //
    if (!useUniversalTags)  {
        [self.adFetcher stopAd];
        [self.adFetcher requestAd];

    } else {
        [self.universalAdFetcher stopAdLoad];  //FIX --= yes?
//        self.universalAdFetcher = [[ANUniversalAdFetcher alloc] initWithDelegate:self];
                    //FIX -- request after init?  (need to) percolate up to the class that calls this format?  why?
        [self.universalAdFetcher requestAd];

        if (! self.universalAdFetcher)  {
            ANLogError(@"FAILED TO FETCH ad via UT.");
        }
    }
}

- (void)loadAdFromHtml:(NSString *)html
                 width:(int)width height:(int)height {
    ANAdServerResponse *response = [[ANAdServerResponse alloc] initWithContent:html
                                                                         width:width
                                                                        height:height];
    [self.adFetcher processAdResponse:response];
}



#pragma mark - Setter methods

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



#pragma mark - Getter methods

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

//FIX UT add zip



//---------------------------------------------------------- -o--
#pragma mark - ANUniversalAdFetcherDelegate.

//--------------------- -o-
- (void)       universalAdFetcher: (ANUniversalAdFetcher *)fetcher
     didFinishRequestWithResponse: (ANAdFetcherResponse *)response
{
ANLogMarkMessage(@"UNUSED.");

}




//---------------------------------------------------------- -o--
#pragma mark - ANAdViewInternalDelegate

- (void)adWasClicked {
    if ([self.delegate respondsToSelector:@selector(adWasClicked:)]) {
        [self.delegate adWasClicked:self];
    }
}

- (void)adWillPresent {
    if ([self.delegate respondsToSelector:@selector(adWillPresent:)]) {
        [self.delegate adWillPresent:self];
    }
}

- (void)adDidPresent {
    if ([self.delegate respondsToSelector:@selector(adDidPresent:)]) {
        [self.delegate adDidPresent:self];
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

- (void)adDidReceiveAppEvent:(NSString *)name withData:(NSString *)data {
    if ([self.appEventDelegate respondsToSelector:@selector(ad:didReceiveAppEvent:withData:)]) {
        [self.appEventDelegate ad:self didReceiveAppEvent:name withData:data];
    }
}

- (void)adDidReceiveAd
{
ANLogMark();
    if ([self.delegate respondsToSelector:@selector(adDidReceiveAd:)]) {
        [self.delegate adDidReceiveAd:self];
    }
}

- (void)adRequestFailedWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(ad: requestFailedWithError:)]) {
        [self.delegate ad:self requestFailedWithError:error];
    }
}

- (void)adInteractionDidBegin {
    ANLogDebug(@"%@", NSStringFromSelector(_cmd));
    [self.adFetcher stopAd];
}

- (void)adInteractionDidEnd {
    ANLogDebug(@"%@", NSStringFromSelector(_cmd));
    [self.adFetcher setupAutoRefreshTimerIfNecessary];
    [self.adFetcher startAutoRefreshTimer];
}

- (NSString *)adTypeForMRAID    {
            //FIX UT consolidate return values as a function of entryPointType?
    ANLogDebug(@"ABSTRACT METHOD.  MUST be implemented by subclass.");
    return @"";
}

- (UIViewController *)displayController {
    ANLogDebug(@"%@ is abstract, should be implemented by subclass", NSStringFromSelector(_cmd));
    return nil;
}

- (ANEntryPointType) entryPointType {
    ANLogDebug(@"ABSTRACT METHOD.  MUST be implemented by subclass.");
    return  ANEntryPointTypeUndefined;
}

- (CGSize) frameSize  {
    return self.frame.size;
}

@end
