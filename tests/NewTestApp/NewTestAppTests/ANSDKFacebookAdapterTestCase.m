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
#import "ANHTTPStubbingManager.h"
#import "ANURLConnectionStub.h"
#import "ANBannerAdView.h"
#import "ANGlobal.h"
#import "ANLogManager.h"
#import "XCTestCase+ANCategory.h"
#import "ANInterstitialAd.h"
#import "ANBannerAdView+ANTest.h"
#import "ANMediationContainerView.h"
#import "ANAdAdapterBannerFacebook.h"
#import "ANAdAdapterInterstitialFacebook.h"
#import "ANMediationAdViewController.h"
#import "ANMediationAdViewController+ANTest.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "ANAdView+ANTest.h"
#import "ANInterstitialAd+ANTest.h"

@interface ANSDKFacebookAdapterTestCase : XCTestCase <ANBannerAdViewDelegate, ANInterstitialAdDelegate>
@property (nonatomic) XCTestExpectation *adProtocolCallbackExpectation;
@property (nonatomic) BOOL adDidLoad;
@end

@implementation ANSDKFacebookAdapterTestCase

- (void)setUp {
    [super setUp];
    [ANLogManager setANLogLevel:ANLogLevelAll];
    [self enableStubbing];
}

- (void)tearDown {
    [super tearDown];
    self.adProtocolCallbackExpectation = nil;
    self.adDidLoad = NO;
    [self disableStubbing];
}

- (void)enableStubbing {
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
}

- (void)disableStubbing {
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
}

- (void)testBanner {
    [self stubFacebookBanner];
    
    ANBannerAdView *bannerAdView = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)
                                                             placementId:@"2054679"
                                                                  adSize:CGSizeMake(320, 50)];
    bannerAdView.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    bannerAdView.delegate = self;
    [bannerAdView.rootViewController.view addSubview:bannerAdView];
    [bannerAdView loadAd];
    
    self.adProtocolCallbackExpectation = [self expectationWithDescription:@"ANAdProtocolCallback"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     XCTAssertTrue(self.adDidLoad);
                                 }];
    BOOL isMediatedContainerView = [bannerAdView.contentView isKindOfClass:[ANMediationContainerView class]];
    XCTAssertTrue(isMediatedContainerView);
    if (!isMediatedContainerView) return;
    
    ANMediationContainerView *mediatedContainerView = (ANMediationContainerView *)bannerAdView.contentView;
    BOOL isFacebookAdapter = [mediatedContainerView.controller.currentAdapter isKindOfClass:[ANAdAdapterBannerFacebook class]];
    XCTAssertTrue(isFacebookAdapter);
    if (!isFacebookAdapter) return;
    
    BOOL conformsToFBProtocol = [mediatedContainerView.controller.currentAdapter conformsToProtocol:@protocol(FBAdViewDelegate)];
    XCTAssertTrue(conformsToFBProtocol);
    if (!conformsToFBProtocol) return;
    
    ANAdAdapterBannerFacebook<FBAdViewDelegate> *facebookAdapter = (ANAdAdapterBannerFacebook *)mediatedContainerView.controller.currentAdapter;
    
    // [id<FBAdViewDelegate> adViewDidClick:view];
    [self expectationForNotification:kANAdViewAdWasClickedNotification
                              object:bannerAdView
                             handler:nil];
    [self expectationForNotification:kANAdViewAdWillPresentNotification
                              object:bannerAdView
                             handler:nil];
    [self expectationForNotification:kANAdViewAdDidPresentNotification
                              object:bannerAdView
                             handler:nil];
    [facebookAdapter adViewDidClick:nil];
    [self waitForExpectationsWithTimeout:1.0
                                 handler:nil];
    
    // [id<FBAdViewDelegate> adViewDidFinishHandlingClick:view];
    [self expectationForNotification:kANAdViewAdWillCloseNotification
                              object:bannerAdView
                             handler:nil];
    [self expectationForNotification:kANAdViewAdDidCloseNotification
                              object:bannerAdView
                             handler:nil];
    [facebookAdapter adViewDidFinishHandlingClick:nil];
    [self waitForExpectationsWithTimeout:1.0
                                 handler:nil];
    
    [bannerAdView removeFromSuperview];
}

- (void)testInterstitial {
    [self stubFacebookInterstitial];
    
    ANInterstitialAd *interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:@"2054679"];
    interstitialAd.delegate = self;
    [interstitialAd loadAd];
    
    self.adProtocolCallbackExpectation = [self expectationWithDescription:@"ANAdProtocolCallback"];
    [self waitForExpectationsWithTimeout:kAppNexusRequestTimeoutInterval
                                 handler:^(NSError *error) {
                                     XCTAssertTrue(self.adDidLoad);
                                     XCTAssertTrue(interstitialAd.isReady);
                                 }];
    
    id adapter = [interstitialAd.precachedAdObjects firstObject][@"kANInterstitialAdViewKey"];
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [interstitialAd displayAdFromViewController:rootViewController];
    XCTAssertFalse(interstitialAd.isReady);
    
    BOOL isFacebookAdapter = [adapter isKindOfClass:[ANAdAdapterInterstitialFacebook class]];
    XCTAssertTrue(isFacebookAdapter);
    if (!isFacebookAdapter) return;
    
    BOOL conformsToFBProtocol = [adapter conformsToProtocol:@protocol(FBInterstitialAdDelegate)];
    XCTAssertTrue(conformsToFBProtocol);
    if (!conformsToFBProtocol) return;

    [XCTestCase delayForTimeInterval:1.5];
    
    XCTAssertTrue(rootViewController.presentedViewController);

    // [id<FBInterstitialAdDelegate> interstitialAdDidClick:interstitial]
    ANAdAdapterInterstitialFacebook<FBInterstitialAdDelegate> *fbAdapter = (ANAdAdapterInterstitialFacebook *)adapter;
    [self expectationForNotification:kANAdViewAdWasClickedNotification
                              object:interstitialAd
                             handler:nil];
    [fbAdapter interstitialAdDidClick:nil];
    [self waitForExpectationsWithTimeout:1.0
                                 handler:nil];
    
    // [id<FBInterstitialAdDelegate> interstitialAdWillClose:interstitial]
    [self expectationForNotification:kANAdViewAdWillCloseNotification
                              object:interstitialAd
                             handler:nil];
    [fbAdapter interstitialAdWillClose:nil];
    [self waitForExpectationsWithTimeout:1.0
                                 handler:nil];
    
    [rootViewController dismissViewControllerAnimated:NO completion:nil];

    // [id<FBInterstitialAdDelegate> interstitialAdDidClose:interstitial]
    [self expectationForNotification:kANAdViewAdDidCloseNotification
                              object:interstitialAd
                             handler:nil];
    [fbAdapter interstitialAdDidClose:nil];
    [self waitForExpectationsWithTimeout:1.0
                                 handler:nil];
}

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
    self.adDidLoad = YES;
    [self.adProtocolCallbackExpectation fulfill];
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error {
    [self.adProtocolCallbackExpectation fulfill];
}

#pragma mark - Stubbing

- (void)stubFacebookBanner {
    ANURLConnectionStub *mediatedResponseStub = [ANURLConnectionStub stubForResource:@"FacebookBanner"
                                                                              ofType:@"json"
                                                    withRequestURLRegexPatternString:@"http://mediation.adnxs.com/mob\\?.*"
                                                                            inBundle:[NSBundle bundleForClass:[self class]]];
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:mediatedResponseStub];
    [self stubResultCBResponse];
}

- (void)stubFacebookInterstitial {
    ANURLConnectionStub *mediatedResponseStub = [ANURLConnectionStub stubForResource:@"FacebookInterstitial"
                                                                              ofType:@"json"
                                                    withRequestURLRegexPatternString:@"http://mediation.adnxs.com/mob\\?.*"
                                                                            inBundle:[NSBundle bundleForClass:[self class]]];
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:mediatedResponseStub];
    [self stubResultCBResponse];
}

- (void)stubResultCBResponse {
    ANURLConnectionStub *resultCBStub = [[ANURLConnectionStub alloc] init];
    resultCBStub.requestURLRegexPatternString = @"http://nym1.mobile.adnxs.com/mediation.*";
    resultCBStub.responseCode = 200;
    resultCBStub.responseBody = @"";
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:resultCBStub];
}

@end
