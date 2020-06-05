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

#import <XCTest/XCTest.h>

#import "MARHelper.h"
#import "ANHTTPStubbingManager.h"

#import "ANMultiAdRequest.h"
#import "ANMultiAdRequest+PrivateMethods.h"
#import "ANBannerAdView.h"
#import "ANAdView+PrivateMethods.h"
#import "ANAdView+ANTest.h"




#pragma mark -

@interface PrivateAPI : XCTestCase<ANMultiAdRequestDelegate, ANBannerAdViewDelegate>



@property (nonatomic, readwrite, strong, nullable)  MARAdUnits          *adUnitsForTest;
@property (nonatomic, readwrite, strong)            ANMultiAdRequest    *mar;


//
@property (nonatomic, readwrite)  NSUInteger  MAR_countOfCompletions;
@property (nonatomic, readwrite)  NSUInteger  MAR_countOfCompletionFailures;
@property (nonatomic, readwrite)  NSUInteger  AdUnit_countOfReceives;
@property (nonatomic, readwrite)  NSUInteger  AdUnit_countOfReceiveFailures;

@property (nonatomic, strong, readwrite, nullable)  XCTestExpectation  *expectationMARLoadCompletionOrFailure;
@property (nonatomic, strong, readwrite, nullable)  XCTestExpectation  *expectationAdUnitLoadResponseOrFailure;
@property (nonatomic, strong, readwrite, nullable)  XCTestExpectation  *expectationBackgroundBlockIsComplete;


//
@property (nonatomic, strong, readwrite, nullable)  ANHTTPStubbingManager  *httpStubManager;

@end


#pragma mark -

@implementation PrivateAPI

#pragma mark Test lifecycle.

- (void)setUp
{
TMARK();
    self.adUnitsForTest = [[MARAdUnits alloc] initWithDelegate:self];


    //
    self.mar = nil;

    [self clearCountsAndExpectations];

    
    //
    self.httpStubManager = [ANHTTPStubbingManager sharedStubbingManager];
    [self.httpStubManager enable];
}

- (void)clearCountsAndExpectations
{
    self.MAR_countOfCompletions         = 0;
    self.MAR_countOfCompletionFailures  = 0;
    self.AdUnit_countOfReceives         = 0;
    self.AdUnit_countOfReceiveFailures  = 0;

    self.expectationMARLoadCompletionOrFailure = nil;
    self.expectationAdUnitLoadResponseOrFailure = nil;
}

- (void)tearDown
{
    [self.httpStubManager disable];
    [self.httpStubManager removeAllStubs];
}




#pragma mark - Tests.

- (void)testGenerateStandardAdUnitFromHTMLContent
{
TMARK();
    NSString  *htmlExample            = @"SuccessfulStandardAdFromRTBObjectResponse";
    NSBundle  *currentBundle          = [NSBundle bundleForClass:[self class]];
    NSString  *exampleResposeString   = [NSString stringWithContentsOfFile: [currentBundle pathForResource:htmlExample ofType:@"json"]
                                                                  encoding: NSUTF8StringEncoding
                                                                     error: nil ];

    NSData   *exampleResposeData  = [exampleResposeString dataUsingEncoding:NSUTF8StringEncoding];
    NSError  *error               = nil;

    NSDictionary  *jsonBody    = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: exampleResposeData
                                                                                 options: kNilOptions
                                                                                   error: &error];
    XCTAssertNil(error);


    //
    NSDictionary  *bannerObject  = jsonBody[@"tags"][0][@"ads"][0][@"rtb"][@"banner"];

    NSString    *content  = bannerObject[@"content"];
    NSUInteger   width    = [bannerObject[@"width"] integerValue];
    NSUInteger   height   = [bannerObject[@"height"] integerValue];

    XCTAssertNotNil(content);


    ANStandardAd  *standardAd  = [ANUniversalTagAdServerResponse generateStandardAdUnitFromHTMLContent:content width:width height:height];
    XCTAssertNotNil(standardAd);
}

- (void)testGenerateRTBVideoAdUnitFromVASTObject
{
TMARK();
    NSString  *xmlExample             = @"SuccessfulInstreamVideoAdResponse";
    NSBundle  *currentBundle          = [NSBundle bundleForClass:[self class]];
    NSString  *exampleResposeString   = [NSString stringWithContentsOfFile: [currentBundle pathForResource:xmlExample ofType:@"json"]
                                                                  encoding: NSUTF8StringEncoding
                                                                     error: nil ];

    NSData   *exampleResposeData  = [exampleResposeString dataUsingEncoding:NSUTF8StringEncoding];
    NSError  *error               = nil;

    NSDictionary  *jsonBody    = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: exampleResposeData
                                                                                 options: kNilOptions
                                                                                   error: &error];
    XCTAssertNil(error);


    //
    NSDictionary  *bannerObject  = jsonBody[@"tags"][0][@"ads"][0][@"rtb"][@"video"];

    NSString    *content  = bannerObject[@"content"];
    NSUInteger   width    = 250;
    NSUInteger   height   = 300;

    XCTAssertNotNil(content);


    ANRTBVideoAd  *videoAd  = [ANUniversalTagAdServerResponse generateRTBVideoAdUnitFromVASTObject:content width:width height:height];
    XCTAssertNotNil(videoAd);
}




#pragma mark - ANMultiAdRequestDelegate.

- (void)multiAdRequestDidComplete:(ANMultiAdRequest *)mar
{
TMARK();
    [self.expectationMARLoadCompletionOrFailure fulfill];
    self.MAR_countOfCompletions += 1;
}

- (void)multiAdRequest:(nonnull ANMultiAdRequest *)mar didFailWithError:(NSError *)error
{
TMARKMESSAGE(@"%@", error.userInfo);
    [self.expectationMARLoadCompletionOrFailure fulfill];
    self.MAR_countOfCompletionFailures += 1;
}




#pragma mark - ANAdProtocol.

- (void)adDidReceiveAd:(nonnull id)ad
{
TINFO(@"%@", [MARHelper adunitDescription:ad]);
    [self.expectationAdUnitLoadResponseOrFailure fulfill];
    self.AdUnit_countOfReceives += 1;
}

- (void)            ad: (nonnull id)loadInstance
    didReceiveNativeAd: (nonnull id)responseInstance
{
TINFO(@"%@", [MARHelper adunitDescription:loadInstance]);
    [self.expectationAdUnitLoadResponseOrFailure fulfill];
    self.AdUnit_countOfReceives += 1;
}

- (void)ad:(nonnull id)ad requestFailedWithError:(NSError *)error
{
TERROR(@"%@ -- %@", [MARHelper adunitDescription:ad], error.userInfo);
    [self.expectationAdUnitLoadResponseOrFailure fulfill];
    self.AdUnit_countOfReceiveFailures += 1;
}


- (void)adWasClicked:(nonnull id)ad
{
    TINFO(@"%@", [MARHelper adunitDescription:ad]);
}

- (void)adWasClicked:(nonnull id)ad withURLString:(NSString *)urlString
{
    TINFO(@"%@ -- \"%@\"", [MARHelper adunitDescription:ad], urlString);
}


- (void)adWillClose:(nonnull id)ad
{
    TINFO(@"%@", [MARHelper adunitDescription:ad]);
}

- (void)adDidClose:(nonnull id)ad
{
    TINFO(@"%@", [MARHelper adunitDescription:ad]);
}


- (void)adWillPresent:(nonnull id)ad
{
    TINFO(@"%@", [MARHelper adunitDescription:ad]);
}

- (void)adDidPresent:(nonnull id)ad
{
    TINFO(@"%@", [MARHelper adunitDescription:ad]);
}


- (void)adWillLeaveApplication:(nonnull id)ad
{
    TINFO(@"%@", [MARHelper adunitDescription:ad]);
}




#pragma mark - ANNativeAdRequestDelegate.

- (void)adRequest:(nonnull ANNativeAdRequest *)request didReceiveResponse:(nonnull ANNativeAdResponse *)response
{
TINFO(@"%@", [MARHelper adunitDescription:request]);

}

- (void)adRequest:(nonnull ANNativeAdRequest *)request didFailToLoadWithError:(nonnull NSError *)error
{
TERROR(@"%@ -- %@", [MARHelper adunitDescription:request], error.userInfo);
}


@end
