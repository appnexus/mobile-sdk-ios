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
#import "ANMediationAdapterViewController.h"
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

@interface FacebookAdapter : XCTestCase <ANBannerAdViewDelegate, ANInterstitialAdDelegate>
@property (nonatomic) XCTestExpectation *adProtocolCallbackExpectation;
@property (nonatomic) BOOL adDidLoad;
@end

@implementation FacebookAdapter

- (void)tearDown {
    [super tearDown];
    self.adProtocolCallbackExpectation = nil;
    self.adDidLoad = NO;
}

- (void)testBanner {
    ANMediationAdapterViewController *rootVC = (ANMediationAdapterViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    ANBannerAdView *bannerAdView = [rootVC loadFacebookBannerWithDelegate:self];
    
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
    ANMediationAdapterViewController *rootVC = (ANMediationAdapterViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    ANInterstitialAd *interstitialAd = [rootVC loadFacebookInterstitialWithDelegate:self];

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

@end
