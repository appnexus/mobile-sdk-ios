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
#import "ANAdFetcher.h"
#import "ANUniversalTagRequestBuilder.h"
#import "ANRTBVideoAd.h"
#import "ANAdView+PrivateMethods.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "XandrAd.h"
#import "ANLogManager.h"

static NSString         *outstreamVideoPlacementID  = @"12534678";

@interface OutstreamVideoAdClassObjectFromUTResponseTests : XCTestCase< ANAdFetcherFoundationDelegate,
                                                                         ANAdProtocolVideo,
                                                                        ANAdProtocolBrowser, ANAdProtocolPublicServiceAnnouncement
                                                                      >

@property (nonatomic, strong)  ANAdFetcher  *adFetcher;
@property (nonatomic, strong)  NSMutableSet<NSValue *>  *allowedAdSizes;
@property (nonatomic)          BOOL                      allowSmallerSizes;
@property (nonatomic, strong) XCTestExpectation *loadAdSuccesfulException;
@property (nonatomic, readwrite, strong, nonnull)   NSString  *utRequestUUIDString;

@end



@implementation OutstreamVideoAdClassObjectFromUTResponseTests

@synthesize  publisherId;



#pragma mark - Test lifecycle.

- (void)setUp
{
    [super setUp];
    [ANLogManager setANLogLevel:ANLogLevelAll];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [[XandrAd sharedInstance] initWithMemberID:1 preCacheRequestObjects:true completionHandler:nil];

}

- (void)tearDown {
    [super tearDown];
    self.loadAdSuccesfulException = nil;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}


- (void) setupSizeParametersAs1x1
{
    self.allowedAdSizes     = [NSMutableSet setWithObject:[NSValue valueWithCGSize:kANAdSize1x1]];
    self.allowSmallerSizes  = NO;
}


- (nonnull NSString *)internalGetUTRequestUUIDString
{
    return  self.utRequestUUIDString;
}

- (void)internalUTRequestUUIDStringReset
{
     self.utRequestUUIDString = ANUUID();
}

#pragma mark - Test methods.

- (void)testValidateOutstreamUTResponseFields
{
    TESTTRACE();

    [self setupSizeParametersAs1x1];
    self.placementId = outstreamVideoPlacementID;
    [self stubRequestWithResponse:@"SuccessfulOutstreamVideoResponse"];
    self.adFetcher = [[ANAdFetcher alloc] initWithDelegate:self];
    [self.adFetcher requestAd];

    self.loadAdSuccesfulException = [self expectationWithDescription:@"Waiting for didFinishRequestWithResponse to be received"];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:nil];
}

- (void)verifyRTBVideoAdObject:(id)adObject
{
    XCTAssert([adObject isKindOfClass:[ANRTBVideoAd class]]);
    ANRTBVideoAd  *rtbVideoAd  = (ANRTBVideoAd *)adObject;
    XCTAssertNotNil(rtbVideoAd.content);
    XCTAssertNotNil(rtbVideoAd.notifyUrlString);
}

#pragma mark - Stubbing

- (void) stubRequestWithResponse:(NSString *)responseName {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *baseResponse = [NSString stringWithContentsOfFile: [currentBundle pathForResource:responseName
                                                                                         ofType:@"json" ]
                                                       encoding: NSUTF8StringEncoding
                                                          error: nil ];
    
    ANURLConnectionStub  *requestStub  = [[ANURLConnectionStub alloc] init];
    
    requestStub.requestURL    = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    requestStub.responseCode  = 200;
    requestStub.responseBody  = baseResponse;
    
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:requestStub];
}

#pragma mark - ANVideoAdPlayerDelegate.

- (void)videoAdLoadFailed:(NSError *)error withAdResponseInfo:(ANAdResponseInfo *)adResponseInfo
{
    TESTTRACE();
}

- (void)videoAdReady {
    TESTTRACE();
}



#pragma mark - ANUniversalRequestTagBuilderDelegate.

- (void)adFetcher:(ANAdFetcherBase *)fetcher didFinishRequestWithResponse:(ANAdFetcherResponse *)response{
    TESTTRACE();

    [self.loadAdSuccesfulException fulfill];
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

- (void)adRequestFailedWithError:(NSError *)error
{
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

@synthesize age;
@synthesize placementId;
@synthesize memberId;
@synthesize maxDuration;
@synthesize customKeywords;
@synthesize gender;
@synthesize location;
@synthesize reserve;
@synthesize shouldServePublicServiceAnnouncements;
@synthesize inventoryCode;
@synthesize minDuration;
@synthesize landingPageLoadsInBackground;
@synthesize extInvCode;
@synthesize trafficSourceCode;
@synthesize clickThroughAction;
@synthesize forceCreativeId;

@end
