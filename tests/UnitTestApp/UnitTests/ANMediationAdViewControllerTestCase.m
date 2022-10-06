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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ANBannerAdView+ANTest.h"
#import "ANLogManager.h"
#import "XCTestCase+ANMediatedAd.h"
#import "ANMediationAdViewController.h"
#import "ANGlobal.h"
#import "ANTestGlobal.h"
#import "XCTestCase+ANCategory.h"
#import "ANAdFetcher+ANTest.h"
#import "ANBannerAdView+ANTest.h"



@interface ANMediationAdViewControllerTestCase : XCTestCase

@property (nonatomic, readwrite, strong)  ANBannerAdView        *adView;

@end



@implementation ANMediationAdViewControllerTestCase

- (void)setUp {
    [super setUp];
  //  self.adFetcher = [[ANUniversalAdFetcher alloc] init];
    self.adView = [[ANBannerAdView alloc] init];
    [ANLogManager setANLogLevel:ANLogLevelAll];
}
-(void)tearDown{
    self.adView = nil;
   // self.adFetcher = nil;
    [super tearDown];    
}


#pragma mark - Invalid Adapters

- (void)testNilMediatedAd {
    ANMediationAdViewController *controller = [ANMediationAdViewController initMediatedAd:nil
                                                                              withFetcher:self.adView.adFetcher
                                                                           adViewDelegate:self.adView];
    XCTAssertNil(controller, @"Did not expect a controller passing in a nil mediated ad");
}

- (void)testMediatedAdWithFakeClass {
    ANMediationAdViewController *controller = [ANMediationAdViewController initMediatedAd:[self mediatedAdWithFakeClass]
                                                                              withFetcher:self.adView.adFetcher
                                                                           adViewDelegate:self.adView];
    XCTAssertNil(controller, @"Did not expect a controller for an invalid class");
}

- (void)testInterstitialMediatedAdWithBannerAdViewDelegate {
    ANMediationAdViewController *controller = [ANMediationAdViewController initMediatedAd:[self facebookInterstitialMediatedAd]
                                                                              withFetcher:self.adView.adFetcher
                                                                           adViewDelegate:self.adView];
    XCTAssertNil(controller, @"Did not expect a controller for a class of the wrong adapter type");
}

- (void)testMediatedAdWithNoDelegate {
    ANMediationAdViewController *controller = [ANMediationAdViewController initMediatedAd:[self mediatedAdWithNoDelegateInClass]
                                                                              withFetcher:self.adView.adFetcher
                                                                           adViewDelegate:self.adView];
    XCTAssertNil(controller);
}

- (void)testMediatedAdWithNoRequestMethod {
    ANMediationAdViewController *controller = [ANMediationAdViewController initMediatedAd:[self mediatedAdWithNoRequestMethodInClass]
                                                                              withFetcher:self.adView.adFetcher
                                                                           adViewDelegate:self.adView];
    XCTAssertNil(controller);
}




# pragma mark - Valid Adapters

- (void)testMediatedAdUnableToFill {
    ANMediationAdViewController *controller = [ANMediationAdViewController initMediatedAd:[self mediatedAdUnableToFill]
                                                                              withFetcher:self.adView.adFetcher
                                                                           adViewDelegate:self.adView];
    XCTAssertNotNil(controller);
    [self expectAdFetcherCallbackWithResponseCode:ANAdResponseCode.UNABLE_TO_FILL];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:nil];
}

- (void)testMediatedAdNetworkError {
    ANMediationAdViewController *controller = [ANMediationAdViewController initMediatedAd:[self mediatedAdNetworkError]
                                                                              withFetcher:self.adView.adFetcher
                                                                           adViewDelegate:self.adView];
    XCTAssertNotNil(controller);
    [self expectAdFetcherCallbackWithResponseCode:ANAdResponseCode.NETWORK_ERROR];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:nil];
}

- (void)testMediatedAdSuccessful {
    ANMediationAdViewController *controller = [ANMediationAdViewController initMediatedAd:[self mediatedAdSuccessful]
                                                                              withFetcher:self.adView.adFetcher
                                                                           adViewDelegate:self.adView];
    XCTAssertNotNil(controller);
    [self expectAdFetcherCallbackWithResponseCode:ANAdResponseCode.SUCCESS];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:nil];
}

- (void)testMediatedAdTimeoutThenSuccessful {
    ANMediationAdViewController *controller = [ANMediationAdViewController initMediatedAd:[self mediatedAdTimeout]
                                                                              withFetcher:self.adView.adFetcher
                                                                           adViewDelegate:self.adView];
    XCTAssertNotNil(controller);
    [self validateAdFetcherCallbackWithResponseCode:ANAdResponseCode.INTERNAL_ERROR
                                            timeout:kAppNexusRequestTimeoutInterval];
}

- (void)testMediatedAdUnableToFillThenSuccessful {
    ANMediationAdViewController *controller = [ANMediationAdViewController initMediatedAd:[self mediatedAdUnableToFillThenSuccessful]
                                                                              withFetcher:self.adView.adFetcher
                                                                           adViewDelegate:self.adView];
    XCTAssertNotNil(controller);
    [self validateAdFetcherCallbackWithResponseCode:ANAdResponseCode.UNABLE_TO_FILL
                                            timeout:0.5];
}

- (void)testMediatedAdSuccessfulThenUnableToFill {
    ANMediationAdViewController *controller = [ANMediationAdViewController initMediatedAd:[self mediatedAdSuccessfulThenUnableToFill]
                                                                              withFetcher:self.adView.adFetcher
                                                                           adViewDelegate:self.adView];
    XCTAssertNotNil(controller);
    [self validateAdFetcherCallbackWithResponseCode:ANAdResponseCode.SUCCESS
                                            timeout:0.5];
}

- (void)testMediatedAdMultipleSuccessCallbacks {
    ANMediationAdViewController *controller = [ANMediationAdViewController initMediatedAd:[self mediatedAdMultipleSuccessCallbacks]
                                                                              withFetcher:self.adView.adFetcher
                                                                           adViewDelegate:self.adView];
    XCTAssertNotNil(controller);
    [self validateAdFetcherCallbackWithResponseCode:ANAdResponseCode.SUCCESS
                                            timeout:0.5];
}

- (void)testMediatedAdMultipleFailureCallbacks {
    ANMediationAdViewController *controller = [ANMediationAdViewController initMediatedAd:[self mediatedAdMultipleFailureCallbacks]
                                                                              withFetcher:self.adView.adFetcher
                                                                           adViewDelegate:self.adView];
    XCTAssertNotNil(controller);
    [self validateAdFetcherCallbackWithResponseCode:ANAdResponseCode.NETWORK_ERROR
                                            timeout:0.5];
}




#pragma mark - Helper Methods

- (void)expectAdFetcherCallbackWithResponseCode:(ANAdResponseCode *)code
{
TESTTRACE();
    [self expectationForNotification: kANUniversalAdFetcherFireResponseURLRequestedNotification
                              object: self.adView.adFetcher
                             handler: ^BOOL(NSNotification *notification)
                                 {
                                     NSDictionary   *userInfo   = notification.userInfo;
                                     NSNumber       *reason     = userInfo[kANUniversalAdFetcherFireResponseURLRequestedReason];

        if (reason && ([reason integerValue] == code.code))  { return YES; }
                                     return NO;
                                 } ];
}

// Assert that AdFetcher receives ANAdResponse code exactly once, and that no other code is ever received.
//
- (void)validateAdFetcherCallbackWithResponseCode: (ANAdResponseCode *)code
                                          timeout: (NSTimeInterval)timeout
{
TESTTRACE();
    __block BOOL  receivedDesiredCallback  = NO;

    id  observer  = [[NSNotificationCenter defaultCenter] addObserverForName: kANUniversalAdFetcherFireResponseURLRequestedNotification
                                                                      object: self.adView.adFetcher
                                                                       queue: [NSOperationQueue mainQueue]
                                                                  usingBlock: ^(NSNotification *notification)
                                                                     {
                                                                        BOOL        validCallback  = NO;
                                                                        NSNumber   *reason;

                                                                         if (!receivedDesiredCallback) {
                                                                            NSDictionary  *userInfo  = notification.userInfo;

                                                                            reason                      = userInfo[kANUniversalAdFetcherFireResponseURLRequestedReason];
                                                                             validCallback               = reason && ([reason integerValue] == code.code);
                                                                            receivedDesiredCallback     = validCallback;
                                                                        }

                                                                        XCTAssert(validCallback, @"Received invalid ad fetcher callback with reason: %@", reason);
                                                                    } ];
    [XCTestCase delayForTimeInterval:timeout];
    XCTAssert(receivedDesiredCallback);

    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

@end
