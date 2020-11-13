/*   Copyright 2020 APPNEXUS INC
 
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
#import "ANBannerAdView.h"
#import "ANInterstitialAd.h"
#import "ANInstreamVideoAd.h"
#import "ANNativeAdRequest.h"

@interface ANPublicAPITrafficSourceCodeAndExtInvCode : XCTestCase

@end

@implementation ANPublicAPITrafficSourceCodeAndExtInvCode

- (void)testTrafficSourceCodeForBanner {
    ANBannerAdView *  banner = [[ANBannerAdView alloc] initWithFrame: CGRectMake(0, 0, 320, 50)];
    [banner setTrafficSourceCode:@"Xandr-trafficSourceCode"];
    XCTAssertEqual(@"Xandr-trafficSourceCode", banner.trafficSourceCode);
    XCTAssertNil(banner.extInvCode);
    banner = nil;
}

- (void)testTrafficSourceCodeAndExtInvCodeSetForBanner {
    ANBannerAdView *  banner = [[ANBannerAdView alloc] initWithFrame: CGRectMake(0, 0, 320, 50)];
    [banner setExtInvCode:@"Xandr-extInvCode"];
    [banner setTrafficSourceCode:@"Xandr-trafficSourceCode"];
    XCTAssertEqual(@"Xandr-extInvCode", banner.extInvCode);
    XCTAssertEqual(@"Xandr-trafficSourceCode", banner.trafficSourceCode);
    banner = nil;
}
- (void)testExtInvCodeForBanner {
    ANBannerAdView *  banner = [[ANBannerAdView alloc] initWithFrame: CGRectMake(0, 0, 320, 50)];
    [banner setExtInvCode:@"Xandr-extInvCode"];
    XCTAssertEqual(@"Xandr-extInvCode", banner.extInvCode);
    XCTAssertNil(banner.trafficSourceCode);
    banner = nil;
}
- (void)testTrafficSourceCodeAndExtInvCodeNotSetForBanner {
    ANBannerAdView *  banner = [[ANBannerAdView alloc] initWithFrame: CGRectMake(0, 0, 320, 50)];
    XCTAssertNil(banner.trafficSourceCode);
    XCTAssertNil(banner.extInvCode);
    banner = nil;
}
- (void)testTrafficSourceCodeAndExtInvCodeSetEmptyForBanner {
    ANBannerAdView *  banner = [[ANBannerAdView alloc] initWithFrame: CGRectMake(0, 0, 320, 50)];
    [banner setExtInvCode:@""];
    [banner setTrafficSourceCode:@""];
    XCTAssertNil(banner.trafficSourceCode);
    XCTAssertNil(banner.extInvCode);
    banner = nil;
}

- (void)testTrafficSourceCodeAndExtInvCodeSetNullForBanner {
    ANBannerAdView *  banner = [[ANBannerAdView alloc] initWithFrame: CGRectMake(0, 0, 320, 50)];
    [banner setExtInvCode:NULL];
    [banner setTrafficSourceCode:NULL];
    XCTAssertNil(banner.trafficSourceCode);
    XCTAssertNil(banner.extInvCode);
    banner = nil;
}

- (void)testTrafficSourceCodeForNative {
    ANNativeAdRequest *  nativeAdRequest = [[ANNativeAdRequest alloc] init];
    [nativeAdRequest setTrafficSourceCode:@"Xandr-trafficSourceCode"];
    XCTAssertEqual(@"Xandr-trafficSourceCode", nativeAdRequest.trafficSourceCode);
    XCTAssertNil(nativeAdRequest.extInvCode);
    nativeAdRequest = nil;
}
- (void)testTrafficSourceCodeAndExtInvCodeSetForNative {
    ANNativeAdRequest *  nativeAdRequest = [[ANNativeAdRequest alloc] init];
    [nativeAdRequest setExtInvCode:@"Xandr-extInvCode"];
    [nativeAdRequest setTrafficSourceCode:@"Xandr-trafficSourceCode"];
    XCTAssertEqual(@"Xandr-extInvCode", nativeAdRequest.extInvCode);
    XCTAssertEqual(@"Xandr-trafficSourceCode", nativeAdRequest.trafficSourceCode);
    nativeAdRequest = nil;
}
- (void)testExtInvCodeForNative {
    ANNativeAdRequest *  nativeAdRequest = [[ANNativeAdRequest alloc] init];
    [nativeAdRequest setExtInvCode:@"Xandr-extInvCode"];
    XCTAssertEqual(@"Xandr-extInvCode", nativeAdRequest.extInvCode);
    XCTAssertNil(nativeAdRequest.trafficSourceCode);
    nativeAdRequest = nil;
}
- (void)testTrafficSourceCodeAndExtInvCodeNotSetForNative{
    ANNativeAdRequest *  nativeAdRequest = [[ANNativeAdRequest alloc] init];
    XCTAssertNil(nativeAdRequest.trafficSourceCode);
    XCTAssertNil(nativeAdRequest.extInvCode);
}

- (void)testTrafficSourceCodeAndExtInvCodeSetEmptyForNative {
    ANNativeAdRequest *  nativeAdRequest = [[ANNativeAdRequest alloc] init];
    [nativeAdRequest setExtInvCode:@""];
    [nativeAdRequest setTrafficSourceCode:@""];
    XCTAssertNil(nativeAdRequest.trafficSourceCode);
    XCTAssertNil(nativeAdRequest.extInvCode);
    nativeAdRequest = nil;
}

- (void)testTrafficSourceCodeAndExtInvCodeSetEmptyForVideo {
    ANInstreamVideoAd *  instreamVideoAd = [[ANInstreamVideoAd alloc] init];
    [instreamVideoAd setExtInvCode:@""];
    [instreamVideoAd setTrafficSourceCode:@""];
    XCTAssertNil(instreamVideoAd.trafficSourceCode);
    XCTAssertNil(instreamVideoAd.extInvCode);
    instreamVideoAd = nil;
}

- (void)testTrafficSourceCodeAndExtInvCodeSetNullForNative {
    ANNativeAdRequest *  nativeAdRequest = [[ANNativeAdRequest alloc] init];
    [nativeAdRequest setExtInvCode:NULL];
    [nativeAdRequest setTrafficSourceCode:NULL];
    XCTAssertNil(nativeAdRequest.trafficSourceCode);
    XCTAssertNil(nativeAdRequest.extInvCode);
    nativeAdRequest = nil;
}

- (void)testTrafficSourceCodeAndExtInvCodeSetNullForVideo {
    ANInstreamVideoAd *  instreamVideoAd = [[ANInstreamVideoAd alloc] init];
    [instreamVideoAd setExtInvCode:NULL];
    [instreamVideoAd setTrafficSourceCode:NULL];
    XCTAssertNil(instreamVideoAd.trafficSourceCode);
    XCTAssertNil(instreamVideoAd.extInvCode);
    instreamVideoAd = nil;
}

- (void)testTrafficSourceCodeForVideo {
    ANInstreamVideoAd *  instreamVideoAd = [[ANInstreamVideoAd alloc] init];
    [instreamVideoAd setTrafficSourceCode:@"Xandr-trafficSourceCode"];
    XCTAssertEqual(@"Xandr-trafficSourceCode", instreamVideoAd.trafficSourceCode);
    XCTAssertNil(instreamVideoAd.extInvCode);
    instreamVideoAd = nil;
}
- (void)testTrafficSourceCodeAndExtInvCodeSetForVideo {
    ANInstreamVideoAd *  instreamVideoAd = [[ANInstreamVideoAd alloc] init];
    [instreamVideoAd setExtInvCode:@"Xandr-extInvCode"];
    [instreamVideoAd setTrafficSourceCode:@"Xandr-trafficSourceCode"];
    XCTAssertEqual(@"Xandr-extInvCode", instreamVideoAd.extInvCode);
    XCTAssertEqual(@"Xandr-trafficSourceCode", instreamVideoAd.trafficSourceCode);
    instreamVideoAd = nil;
}
- (void)testExtInvCodeForVideo {
    ANInstreamVideoAd *  instreamVideoAd = [[ANInstreamVideoAd alloc] init];
    [instreamVideoAd setExtInvCode:@"Xandr-extInvCode"];
    XCTAssertEqual(@"Xandr-extInvCode", instreamVideoAd.extInvCode);
    XCTAssertNil(instreamVideoAd.trafficSourceCode);
    instreamVideoAd = nil;
}
- (void)testTrafficSourceCodeAndExtInvCodeNotSetForVideo{
    ANInstreamVideoAd *  instreamVideoAd = [[ANInstreamVideoAd alloc] init];
    XCTAssertNil(instreamVideoAd.trafficSourceCode);
    XCTAssertNil(instreamVideoAd.extInvCode);
    instreamVideoAd = nil;
}

- (void)testTrafficSourceCodeForInterstitial {
    ANInterstitialAd *  interstitialAd = [[ANInterstitialAd alloc] init];
    [interstitialAd setTrafficSourceCode:@"Xandr-trafficSourceCode"];
    XCTAssertEqual(@"Xandr-trafficSourceCode", interstitialAd.trafficSourceCode);
    XCTAssertNil(interstitialAd.extInvCode);
    interstitialAd = nil;
    
}
- (void)testTrafficSourceCodeAndExtInvCodeSetForInterstitial {
    ANInterstitialAd *  interstitialAd = [[ANInterstitialAd alloc] init];
    [interstitialAd setExtInvCode:@"Xandr-extInvCode"];
    [interstitialAd setTrafficSourceCode:@"Xandr-trafficSourceCode"];
    XCTAssertEqual(@"Xandr-extInvCode", interstitialAd.extInvCode);
    XCTAssertEqual(@"Xandr-trafficSourceCode", interstitialAd.trafficSourceCode);
    interstitialAd = nil;
}
- (void)testExtInvCodeForInterstitial {
    ANInterstitialAd *  interstitialAd = [[ANInterstitialAd alloc] init];
    [interstitialAd setExtInvCode:@"Xandr-extInvCode"];
    XCTAssertEqual(@"Xandr-extInvCode", interstitialAd.extInvCode);
    XCTAssertNil(interstitialAd.trafficSourceCode);
    interstitialAd = nil;
}
- (void)testTrafficSourceCodeAndExtInvCodeNotSetForInterstitial{
    ANInterstitialAd *  interstitialAd = [[ANInterstitialAd alloc] init];
    XCTAssertNil(interstitialAd.trafficSourceCode);
    XCTAssertNil(interstitialAd.extInvCode);
    interstitialAd = nil;
}
- (void)testTrafficSourceCodeAndExtInvCodeSetEmptyForInterstitial {
    ANInterstitialAd *  interstitialAd = [[ANInterstitialAd alloc] init];
    [interstitialAd setExtInvCode:@""];
    [interstitialAd setTrafficSourceCode:@""];
    XCTAssertNil(interstitialAd.trafficSourceCode);
    XCTAssertNil(interstitialAd.extInvCode);
    interstitialAd = nil;
}

- (void)testTrafficSourceCodeAndExtInvCodeSetNullForInterstitial {
    ANInterstitialAd *  interstitialAd = [[ANInterstitialAd alloc] init];
    [interstitialAd setExtInvCode:NULL];
    [interstitialAd setTrafficSourceCode:NULL];
    XCTAssertNil(interstitialAd.trafficSourceCode);
    XCTAssertNil(interstitialAd.extInvCode);
    interstitialAd = nil;
}





@end
