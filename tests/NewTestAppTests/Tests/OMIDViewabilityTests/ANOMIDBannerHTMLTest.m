/*
 *
 *    Copyright 2018 APPNEXUS INC
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import <XCTest/XCTest.h>
#import "ANBannerAdView.h"
#import "ANInterstitialAd.h"
#import "ANInterstitialAd+ANTest.h"
#import "ANHTTPStubbingManager.h"
#import "ANSDKSettings+PrivateMethods.h"
#import "XCTestCase+ANAdResponse.h"

#define  ROOT_VIEW_CONTROLLER  [UIApplication sharedApplication].keyWindow.rootViewController;
#define kAppNexusRequestTimeoutInterval 30.0

// The Test cases are based on this https://corpwiki.appnexus.com/display/CT/OM-+IOS+Test+Cases+for+MS-3289
// And also depend on https://acdn.adnxs.com/mobile/omsdk/test/omid-validation-verification-script.js to send ANJAM events back to it. This is configured via the Stubbed response setup

@interface ANOMIDBannerHTMLTest : XCTestCase <ANBannerAdViewDelegate, ANAppEventDelegate, ANInterstitialAdDelegate>
@property (nonatomic, readwrite, strong)   ANBannerAdView     *bannerAdView;
@property (nonatomic, readwrite, strong)  ANInterstitialAd      *interstitial;


//Expectations for OMID
@property (nonatomic, strong) XCTestExpectation *OMIDSupportedExpecation;
@property (nonatomic, strong) XCTestExpectation *OMIDAdSessionStartedExpectation;
@property (nonatomic, strong) XCTestExpectation *OMIDGeomentryChangeExpectation;
@property (nonatomic, strong) XCTestExpectation *OMID100PercentViewableExpectation;
@property (nonatomic, strong) XCTestExpectation *OMIDImpressionEventExpectation;
@property (nonatomic, strong) XCTestExpectation *OMIDAdSessionIDUpdateExpectaion;
//"adSessionId":"BC05657C-9D2F-419C-B776-2AFDF79AF70B"
//"adSessionId":"29B4BAC9-3237-4406-9FC1-5E3A2DF6A7E5" This should be different from first one.

@property (nonatomic) BOOL geometryFulfilled;
@property (nonatomic) BOOL oneHundredPercentViewableFulfilled;
@property (nonatomic) NSString *adSessionIdForFirstAd;
@property (nonatomic) NSString *adSessionIdForSecondAd;

@end

@implementation ANOMIDBannerHTMLTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    
    self.bannerAdView = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)
                                                  placementId:@"13457285"
                                                       adSize:CGSizeMake(300, 250)];
    self.bannerAdView.accessibilityLabel = @"AdView";
    self.bannerAdView.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.bannerAdView.delegate = self;
    self.bannerAdView.appEventDelegate = self;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.bannerAdView];
    
    self.interstitial = [[ANInterstitialAd alloc] initWithPlacementId:@"13457285"];
    self.interstitial.delegate = self;
    self.interstitial.appEventDelegate = self;
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [self.bannerAdView removeFromSuperview];
    self.bannerAdView.delegate = nil;
    self.bannerAdView.appEventDelegate = nil;
    self.bannerAdView = nil;
    [[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController dismissViewControllerAnimated:NO
                                                                                                               completion:nil];
    
    // Clear all expectations for next test
    self.OMIDSupportedExpecation = nil;
    self.OMIDAdSessionStartedExpectation = nil;
    self.OMIDGeomentryChangeExpectation = nil;
    self.OMID100PercentViewableExpectation = nil;
    self.OMIDImpressionEventExpectation = nil;
    self.OMIDAdSessionIDUpdateExpectaion = nil;
    self.adSessionIdForFirstAd = @"";
    self.adSessionIdForSecondAd = @"";
    self.interstitial = nil;
}


- (void)testOMIDInitSuccess
{
    [self stubRequestWithResponse:@"OMID_TestResponse"];
    
    self.OMIDSupportedExpecation = [self expectationWithDescription:@"Didn't receive OmidSupported[true]"];
    
    self.OMIDAdSessionStartedExpectation = [self expectationWithDescription:@"Didn't receive OMID sessionStart event"];
    
    [self.bannerAdView loadAd];
    
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    
}




// NOTE: if this test case is failing, then probably some popup(like location permission) is obstructing the BannerAd. Close the pop-up(Hit Allow) and re-run the test again.
// as a possible improvement we need to do the above step programatically.
- (void)testOMIDGeometry
{
    [self stubRequestWithResponse:@"OMID_TestResponse"];
    
    self.OMIDGeomentryChangeExpectation = [self expectationWithDescription:@"Didn't receive OMID geometryChange event"];
    self.geometryFulfilled = NO;
    
    self.OMID100PercentViewableExpectation = [self expectationWithDescription:@"Didn't receive OMID view 100% event"];
    self.oneHundredPercentViewableFulfilled = NO;
    
    [self.bannerAdView loadAd];
    
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    
}



- (void)testOMIDImpression
{
    [self stubRequestWithResponse:@"OMID_TestResponse"];
    
    self.OMIDImpressionEventExpectation = [self expectationWithDescription:@"Didn't receive OMID Impression event"];
    
    [self.bannerAdView loadAd];
    
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    
}



- (void)testOMIDImpressionInterstitial
{

    [self stubRequestWithResponse:@"OMID_TestResponse"];
     self.OMIDImpressionEventExpectation = [self expectationWithDescription:@"Didn't receive OMID Impression event"];
    [self.interstitial loadAd];
    
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
}





- (void)testOMIDADSessionIDUpdate
{
    self.adSessionIdForFirstAd = @"";
    self.adSessionIdForSecondAd = @"";
    
    [self stubRequestWithResponse:@"OMID_TestResponse"];
    [self stubRequestWithResponse:@"OMID_TestResponse"]; //Stubbing two responses for AutoRefresh
    
    
    self.OMIDAdSessionIDUpdateExpectaion = [self expectationWithDescription:@"AdSessionID is same for TwoBanners its worng Fix it"];
    self.bannerAdView.autoRefreshInterval = 10; // We need autoRefresh for testing if AdSession ID is getting updated or not.
    [self.bannerAdView loadAd];
    
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     
                                 }];
    
}


// Takes an input string like
// 6/18/2018, 6:05:12 PM::{"adSessionId":"29B4BAC9-3237-4406-9FC1-5E3A2DF6A7E5","timestamp":1529359512078,"type":"impression","data":{"mediaType":"display"}}
// and Returns adSessionId value from that
- (NSString *) adSessionIDFromString:(NSString *)message {
    
    NSRange range = [message rangeOfString:@"{"]; // finds the first occurance of {
    NSString *impressionString = [message substringFromIndex:range.location];
    
    // Extract the adSessionId using JSON and NSDictionary Combo.
    NSData* jsonData = [impressionString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:kNilOptions
                                                           error:&error];
    return [json objectForKey:@"adSessionId"];
    
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

#pragma mark - ANAdDelegate

- (void)adDidReceiveAd:(id)ad {
    if([ad isKindOfClass:[ANInterstitialAd class]]){
         UIViewController *controller = ROOT_VIEW_CONTROLLER;
        [self.interstitial displayAdFromViewController:controller];
    }
    
}


- (void)ad:(id)ad requestFailedWithError:(NSError *)error {
    
}

#pragma mark - ANAppEventDelegate.
- (void)            ad: (id<ANAdProtocol>)ad
    didReceiveAppEvent: (NSString *)name
              withData: (NSString *)data
{
    if ([name isEqualToString:@"OMIDEvent"]) {
        // Decode and confim various OMID EVENT Datas here.
        // the cases are made as if block so that all expectations are fulfilled. This block will be called more that once during test exection once atleast for each expectation case.
        
        if (self.OMIDSupportedExpecation && [data containsString:@"OmidSupported[true]"]) {
            // Only assert if it has been setup to assert.
            [self.OMIDSupportedExpecation fulfill];
        }
        
        if (self.OMIDAdSessionStartedExpectation && [data containsString:@"\"type\":\"sessionStart\""]) {
            // Only assert if it has been setup to assert.
            [self.OMIDAdSessionStartedExpectation fulfill];
        }
        
        if ( self.OMIDGeomentryChangeExpectation && [data containsString:@"\"type\":\"geometryChange\""] && !self.geometryFulfilled) {
            self.geometryFulfilled = YES;
            // Only assert if it has been setup to assert.
            [self.OMIDGeomentryChangeExpectation fulfill];
            
        }
        
        if ( self.OMID100PercentViewableExpectation && [data containsString:@"\"percentageInView\":100"] && !self.oneHundredPercentViewableFulfilled) {
            self.oneHundredPercentViewableFulfilled = YES;
            // Only assert if it has been setup to assert.
            [self.OMID100PercentViewableExpectation fulfill];
            
        }
        
        if ( self.OMIDImpressionEventExpectation && [data containsString:@"\"type\":\"impression\""]) {
            // Only assert if it has been setup to assert.
            [self.OMIDImpressionEventExpectation fulfill];
        }
        
        
        // We will test for AdSessionId change only for Impression Event
        if ( self.OMIDAdSessionIDUpdateExpectaion && [data containsString:@"\"type\":\"impression\""]) {
            
            if([self.adSessionIdForFirstAd isEqualToString:@""]){
                self.adSessionIdForFirstAd = [self adSessionIDFromString:data];
            }else if([self.adSessionIdForSecondAd isEqualToString:@""]){
                self.adSessionIdForSecondAd = [self adSessionIDFromString:data];
                
                if(![self.adSessionIdForFirstAd isEqualToString:self.adSessionIdForSecondAd]){
                    // Only  if the two adSessionIDs donot match then the expectation is fulfulled
                    [self.OMIDAdSessionIDUpdateExpectaion fulfill];
                }
                
            }
            
        }
        
        
        
    }
}


@end

