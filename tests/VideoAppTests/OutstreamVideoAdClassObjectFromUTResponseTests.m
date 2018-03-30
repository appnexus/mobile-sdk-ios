/*   Copyright 2017 APPNEXUS INC
 
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

#import <XCTest/XCTest.h>

#import "ANTestGlobal.h"
#import "ANUniversalAdFetcher.h"
#import "ANUniversalTagRequestBuilder.h"
#import "ANRTBVideoAd.h"
#import "ANAdView+PrivateMethods.h"


static NSString         *outstreamVideoPlacementID  = @"12534678";
static NSTimeInterval    waitTimeInSeconds          = 30.0; //10.0;




@interface OutstreamVideoAdClassObjectFromUTResponseTests : XCTestCase<ANUniversalRequestTagBuilderDelegate, ANVideoAdPlayerDelegate>

@property (nonatomic, strong)  ANUniversalAdFetcher  *universalAdFetcher;
@property (nonatomic)          BOOL                   waitHasEnded;

@property (nonatomic, strong)  NSMutableSet<NSValue *>  *allowedAdSizes;
@property (nonatomic)          BOOL                      allowSmallerSizes;

@end



@implementation OutstreamVideoAdClassObjectFromUTResponseTests

#pragma mark - Test lifecycle.

- (void)setUp
{
    [super setUp];
    [ANLogManager setANLogLevel:ANLogLevelAll];
}

- (void)tearDown {
    [super tearDown];
}


- (void) setupSizeParametersAs1x1
{
    self.allowedAdSizes     = [NSMutableSet setWithObject:[NSValue valueWithCGSize:kANAdSize1x1]];
    self.allowSmallerSizes  = NO;
}



#pragma mark - Test methods.

- (void)testValidateOutstreamUTResponseFields
{
    TESTTRACE();

    [self setupSizeParametersAs1x1];
    self.placementId = outstreamVideoPlacementID;

    self.universalAdFetcher = [[ANUniversalAdFetcher alloc] initWithDelegate:self];
    [self.universalAdFetcher requestAd];


    self.waitHasEnded = NO;
    BOOL  isRequestCompleted  = [self waitForCompletion:waitTimeInSeconds];
    XCTAssert(isRequestCompleted, @"WAITING for [ANUniversalAdFetcher requestAd] to complete...");
}

- (void)verifyRTBVideoAdObject:(id)adObject
{
    XCTAssert([adObject isKindOfClass:[ANRTBVideoAd class]]);

    ANRTBVideoAd  *rtbVideoAd  = (ANRTBVideoAd *)adObject;

    XCTAssertNotNil(rtbVideoAd.content);
    XCTAssertNotNil(rtbVideoAd.notifyUrlString);
}



#pragma mark - Test helpers.

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs
{
    NSDate  *timeoutDate  = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];

    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0)  { break; }
    } while (!self.waitHasEnded);

    return  self.waitHasEnded;
}



#pragma mark - ANVideoAdPlayerDelegate.

- (void)videoAdLoadFailed:(NSError *)error {
    TESTTRACE();
}

- (void)videoAdReady {
    TESTTRACE();
}



#pragma mark - ANUniversalRequestTagBuilderDelegate.

- (void)       universalAdFetcher: (ANUniversalAdFetcher *)fetcher
     didFinishRequestWithResponse: (ANAdFetcherResponse *)response
{
    TESTTRACE();

    self.waitHasEnded = YES;

    [self verifyRTBVideoAdObject:response.adObjectHandler];
}


- (NSArray<NSValue *> *)adAllowedMediaTypes {
    return  @[ @(ANAllowedMediaTypeVideo) ];
}

- (NSDictionary *) internalDelegateUniversalTagSizeParameters
{
    NSMutableDictionary  *delegateReturnDictionary  = [[NSMutableDictionary alloc] init];
    [delegateReturnDictionary setObject:[NSValue valueWithCGSize:kANAdSize1x1]  forKey:ANInternalDelgateTagKeyPrimarySize];
    [delegateReturnDictionary setObject:self.allowedAdSizes                     forKey:ANInternalDelegateTagKeySizes];
    [delegateReturnDictionary setObject:@(self.allowSmallerSizes)               forKey:ANInternalDelegateTagKeyAllowSmallerSizes];

    return  delegateReturnDictionary;
}


- (void)addCustomKeywordWithKey:(NSString *)key value:(NSString *)value {
    //EMPTY
}

- (void)clearCustomKeywords {
    //EMPTY
}

- (void)removeCustomKeywordWithKey:(NSString *)key {
    //EMPTY
}

- (void)setInventoryCode:(NSString *)inventoryCode memberId:(NSInteger)memberID {
    //EMPTY
}

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy {
    //EMPTY
}

- (void)setLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude timestamp:(NSDate *)timestamp horizontalAccuracy:(CGFloat)horizontalAccuracy precision:(NSInteger)precision {
    //EMPTY
}

- (void)adDidClose {
    //EMPTY
}

- (void)adDidPresent {
    //EMPTY
}

- (void)adDidReceiveAd {
    //EMPTY
}

- (void)adDidReceiveAppEvent:(NSString *)name withData:(NSString *)data {
    //EMPTY
}

- (void)adInteractionDidBegin {
    //EMPTY
}

- (void)adInteractionDidEnd {
    //EMPTY
}

- (void)adRequestFailedWithError:(NSError *)error {
    //EMPTY
}

- (NSString *)adTypeForMRAID {
    return  nil;
}

- (void)adWasClicked {
    //EMPTY
}

- (void)adWillClose {
    //EMPTY
}

- (void)adWillLeaveApplication {
    //EMPTY
}

- (void)adWillPresent {
    //EMPTY
}

- (UIViewController *)displayController {
    return  nil;
}

- (BOOL)landingPageLoadsInBackground {
    return  NO;
}

- (BOOL)opensInNativeBrowser {
    return  NO;
}


@synthesize age;
@synthesize placementId;
@synthesize memberId;
@synthesize maxDuration;
@synthesize customKeywords;
@synthesize gender;
@synthesize opensInNativeBrowser;
@synthesize location;
@synthesize reserve;
@synthesize shouldServePublicServiceAnnouncements;
@synthesize inventoryCode;
@synthesize minDuration;
@synthesize landingPageLoadsInBackground;


@end
