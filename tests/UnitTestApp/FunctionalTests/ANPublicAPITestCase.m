/*   Copyright 2015 APPNEXUS INC
 
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ANBannerAdView.h"
#import "ANInterstitialAd.h"
#import "ANGlobal.h"
#import "ANTestGlobal.h"
#import "ANURLConnectionStub.h"
#import "ANHTTPStubbingManager.h"
#import "XCTestCase+ANCategory.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "NSURLRequest+HTTPBodyTesting.h"
#import "ANInstreamVideoAd.h"

@interface ANPublicAPITestCase : XCTestCase <ANInstreamVideoAdLoadDelegate>

@property (nonatomic, readwrite, strong)  XCTestExpectation     *requestExpectation;
@property (nonatomic)                     NSURLRequest          *request;

@end


@implementation ANPublicAPITestCase

#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    [[ANSDKSettings sharedInstance] optionalSDKInitialization:nil];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [self setupRequestTracker];
}

- (void)tearDown {
    [super tearDown];
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    self.request = nil;
    self.requestExpectation = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
        [additionalView removeFromSuperview];
    }
}



#pragma mark - Test helper methods.

- (void)setupRequestTracker {
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestLoaded:)
                                                 name:kANHTTPStubURLProtocolRequestDidLoadNotification
                                               object:nil];
}

- (void)requestLoaded:(NSNotification *)notification
{
TESTTRACE();
    if (self.requestExpectation) {
        self.request = notification.userInfo[kANHTTPStubURLProtocolRequest];
        if([self.request.URL.absoluteString compare:@"https://mediation.adnxs.com/ut/v3" ] == NSOrderedSame){
            [self.requestExpectation fulfill];
            self.requestExpectation = nil;
            [[ANHTTPStubbingManager sharedStubbingManager] disable];
        }
    }
}


- (NSDictionary *) getJSONBodyOfURLRequestAsDictionary: (NSURLRequest *)urlRequest
{
    NSString      *bodyAsString  = [[NSString alloc] initWithData:[urlRequest ANHTTPStubs_HTTPBody] encoding:NSUTF8StringEncoding];
    NSData        *objectData    = [bodyAsString dataUsingEncoding:NSUTF8StringEncoding];
    NSError       *error         = nil;

    NSDictionary  *json          = [NSJSONSerialization JSONObjectWithData: objectData
                                                                   options: NSJSONReadingMutableContainers
                                                                     error: &error];
    if (error)  {
        return nil;
        
    }

    return  json;
}


#pragma mark - Test methods.

- (void)testSetPlacementOnlyOnBanner
{
    self.requestExpectation = [self expectationWithDescription:@"request"];

    ANBannerAdView *banner = [[ANBannerAdView alloc]
                   initWithFrame:CGRectMake(0, 0, 320, 50)
                   placementId:@"1"
                   adSize:CGSizeMake(320, 50)];

    [banner loadAd];
    [self waitForExpectationsWithTimeout: 2 * kAppNexusRequestTimeoutInterval
                                 handler: ^(NSError * _Nullable error) { /*EMPTY*/ }
             ];
    self.requestExpectation = nil;

    //
    XCTAssertEqual(@"1", [banner placementId]);

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    XCTAssertEqual([jsonBody[@"tags"][0][@"id"] integerValue], 1);
}

-(void) testSetDurationOnVideo {
    self.requestExpectation = [self expectationWithDescription:@"request"];
    ANInstreamVideoAd *video = [[ANInstreamVideoAd alloc] initWithPlacementId:@"12345"];
    [video setMinDuration:10];
    [video setMaxDuration:100];
    
    [video loadAdWithDelegate:self];
    
    [self waitForExpectationsWithTimeout: 5 * kAppNexusRequestTimeoutInterval
                                 handler: ^(NSError * _Nullable error) { /*EMPTY*/ }
     ];
    self.requestExpectation = nil;
    
    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    XCTAssertNotNil(jsonBody[@"tags"][0][@"video"]);
    
}

-(void) testSetNoDurationForVideo {
    self.requestExpectation = [self expectationWithDescription:@"request"];
    ANInstreamVideoAd *video = [[ANInstreamVideoAd alloc] initWithPlacementId:@"12345"];
    
    [video loadAdWithDelegate:self];
    
    [self waitForExpectationsWithTimeout: 5 * kAppNexusRequestTimeoutInterval
                                 handler: ^(NSError * _Nullable error) { /*EMPTY*/ }
     ];
    self.requestExpectation = nil;
    
    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    XCTAssertNil(jsonBody[@"tags"][0][@"video"]);
    
}

-(void) testSetMaxOnlyDurationForVideo {
    self.requestExpectation = [self expectationWithDescription:@"request"];
    ANInstreamVideoAd *video = [[ANInstreamVideoAd alloc] initWithPlacementId:@"12345"];
    [video setMaxDuration:100];
    [video loadAdWithDelegate:self];
    
    [self waitForExpectationsWithTimeout: 5 * kAppNexusRequestTimeoutInterval
                                 handler: ^(NSError * _Nullable error) { /*EMPTY*/ }
     ];
    self.requestExpectation = nil;
    
    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    XCTAssertNotNil(jsonBody[@"tags"][0][@"video"]);
    XCTAssertEqual([jsonBody[@"tags"][0][@"video"][@"maxduration"] intValue], 100);
    
}

-(void) testSetMinOnlyDurationForVideo {
    self.requestExpectation = [self expectationWithDescription:@"request"];
    ANInstreamVideoAd *video = [[ANInstreamVideoAd alloc] initWithPlacementId:@"12345"];
    [video setMinDuration:10];
    [video loadAdWithDelegate:self];
    
    [self waitForExpectationsWithTimeout: 5 * kAppNexusRequestTimeoutInterval
                                 handler: ^(NSError * _Nullable error) { /*EMPTY*/ }
     ];
    self.requestExpectation = nil;
    
    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    XCTAssertNotNil(jsonBody[@"tags"][0][@"video"]);
    XCTAssertEqual([jsonBody[@"tags"][0][@"video"][@"minduration"] intValue], 10);
    
}

- (void)testSetInventoryCodeAndMemberIDOnBanner
{
    self.requestExpectation = [self expectationWithDescription:@"request"];

    ANBannerAdView *banner = [[ANBannerAdView alloc]
                   initWithFrame:CGRectMake(0, 0, 320, 50)
                   memberId:1
                   inventoryCode:@"test"
                   adSize:CGSizeMake(320, 50)];

    [banner loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
    self.requestExpectation = nil;

    //
    XCTAssertEqual(@"test", [banner inventoryCode]);
    XCTAssertEqual(1, [banner memberId]);

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];

    XCTAssertEqual([jsonBody[@"member_id"] integerValue], 1);

    NSString  *codeValue  = jsonBody[@"tags"][0][@"code"];   //XXX  @"code" value is of type NSTaggedPointerString.
    XCTAssertEqual([codeValue isEqualToString:@"test"], YES);
}

//NB  Both placementID and (inventoryCode, memberID) tuple exist in the class,
//    but (inventoryCode, memberID) tuple take precedence over placementID in the UT Request.
//
- (void)testSetInventoryCodeAndPlacementIdOnBanner
{
    self.requestExpectation = [self expectationWithDescription:@"request"];

    ANBannerAdView *banner = [[ANBannerAdView alloc]
                   initWithFrame:CGRectMake(0, 0, 320, 50)
                   placementId:@"1"
                   adSize:CGSizeMake(320, 50)];
    [banner setInventoryCode:@"test" memberId:2];
    [banner loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
    self.requestExpectation = nil;

    //
    XCTAssertEqual(@"1",        [banner placementId]);
    XCTAssertEqual(@"test",     [banner inventoryCode]);
    XCTAssertEqual(2,           [banner memberId]);

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];

    XCTAssertNil(jsonBody[@"tags"][0][@"id"]);

    XCTAssertEqual([jsonBody[@"member_id"] integerValue], 2);

    NSString  *codeValue  = jsonBody[@"tags"][0][@"code"];   //XXX  @"code" value is of type NSTaggedPointerString.
    XCTAssertEqual([codeValue isEqualToString:@"test"], YES);
}

- (void)testSetForceCreativeIdOnlyOnBanner
{
    self.requestExpectation = [self expectationWithDescription:@"request"];

    ANBannerAdView *banner = [[ANBannerAdView alloc]
                   initWithFrame:CGRectMake(0, 0, 320, 50)
                   placementId:@"1"
                   adSize:CGSizeMake(320, 50)];
    banner.forceCreativeId = 135482485;

    [banner loadAd];
    [self waitForExpectationsWithTimeout: 2 * kAppNexusRequestTimeoutInterval
                                 handler: ^(NSError * _Nullable error) { /*EMPTY*/ }
             ];
    self.requestExpectation = nil;

    //
    XCTAssertEqual(135482485, banner.forceCreativeId);

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    XCTAssertEqual([jsonBody[@"tags"][0][@"force_creative_id"] integerValue], 135482485);
}

- (void)testSetForceCreativeIdWithNegativeValues
{
    self.requestExpectation = [self expectationWithDescription:@"request"];

    ANBannerAdView *banner = [[ANBannerAdView alloc]
                   initWithFrame:CGRectMake(0, 0, 320, 50)
                   placementId:@"1"
                   adSize:CGSizeMake(320, 50)];
    banner.forceCreativeId = -135482485;

    [banner loadAd];
    [self waitForExpectationsWithTimeout: 2 * kAppNexusRequestTimeoutInterval
                                 handler: ^(NSError * _Nullable error) { /*EMPTY*/ }
             ];
    self.requestExpectation = nil;

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    XCTAssertNil(jsonBody[@"tags"][0][@"force_creative_id"]);

}

- (void)testSetForceCreativeIdWithZero
{
    self.requestExpectation = [self expectationWithDescription:@"request"];

    ANBannerAdView *banner = [[ANBannerAdView alloc]
                   initWithFrame:CGRectMake(0, 0, 320, 50)
                   placementId:@"1"
                   adSize:CGSizeMake(320, 50)];
    banner.forceCreativeId = 0;

    [banner loadAd];
    [self waitForExpectationsWithTimeout: 2 * kAppNexusRequestTimeoutInterval
                                 handler: ^(NSError * _Nullable error) { /*EMPTY*/ }
             ];
    self.requestExpectation = nil;

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    XCTAssertNil(jsonBody[@"tags"][0][@"force_creative_id"]);

}

- (void)testSetPlacementOnlyOnInterstitial
{
    self.requestExpectation = [self expectationWithDescription:@"request"];

    ANInterstitialAd *interstitial = [[ANInterstitialAd alloc] initWithPlacementId:@"1"];
    [interstitial loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
    self.requestExpectation = nil;

    //
    XCTAssertEqual(@"1", [interstitial placementId]);

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    XCTAssertEqual([jsonBody[@"tags"][0][@"id"] integerValue], 1);
}

- (void)testSetInventoryCodeAndMemberIDOnInterstitial
{
    self.requestExpectation = [self expectationWithDescription:@"request"];

    ANInterstitialAd *interstitial = [[ANInterstitialAd alloc] initWithMemberId:2
                                                     inventoryCode:@"test"];
    [interstitial loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
    self.requestExpectation = nil;

    //
    XCTAssertEqual(@"test", [interstitial inventoryCode]);
    XCTAssertEqual(2, [interstitial memberId]);

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];

    XCTAssertEqual([jsonBody[@"member_id"] integerValue], 2);

    NSString  *codeValue  = jsonBody[@"tags"][0][@"code"];   //XXX  @"code" value is of type NSTaggedPointerString.
    XCTAssertEqual([codeValue isEqualToString:@"test"], YES);
}

//NB  Both placementID and (inventoryCode, memberID) tuple exist in the class,
//    but (inventoryCode, memberID) tuple take precedence over placementID in the UT Request.
//
- (void)testSetBothInventoryCodeAndPlacementIdOnInterstitial
{
    self.requestExpectation = [self expectationWithDescription:@"request"];

    ANInterstitialAd *interstitial = [[ANInterstitialAd alloc] initWithPlacementId:@"1"];
    [interstitial setInventoryCode:@"test" memberId:2];
    [interstitial loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
    self.requestExpectation = nil;

    //
    XCTAssertEqual(@"1", [interstitial placementId]);
    XCTAssertEqual(@"test", [interstitial inventoryCode]);
    XCTAssertEqual(2, [interstitial memberId]);

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];

    XCTAssertNil(jsonBody[@"tags"][0][@"id"]);

    XCTAssertEqual([jsonBody[@"member_id"] integerValue], 2);

    NSString  *codeValue  = jsonBody[@"tags"][0][@"code"];   //XXX  @"code" value is of type NSTaggedPointerString.
    XCTAssertEqual([codeValue isEqualToString:@"test"], YES);
}

- (void)testSetForceCreativeIdOnlyOnInterstitial
{
    self.requestExpectation = [self expectationWithDescription:@"request"];

    ANInterstitialAd *interstitial = [[ANInterstitialAd alloc] initWithPlacementId:@"1"];
    interstitial.forceCreativeId = 135482485;
    [interstitial loadAd];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError * _Nullable error) {
                                     
                                 }];
    self.requestExpectation = nil;

    //
    XCTAssertEqual(135482485, interstitial.forceCreativeId);

    NSDictionary  *jsonBody  = [self getJSONBodyOfURLRequestAsDictionary:self.request];
    XCTAssertEqual([jsonBody[@"tags"][0][@"force_creative_id"] integerValue], 135482485);
}



#pragma mark - ANInstreamVideoAdLoadDelegate

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
    /*EMPTY*/
}

@end
