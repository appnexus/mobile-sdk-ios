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

#import <XCTest/XCTest.h>

#import "ANBannerAdView.h"
#import "ANInterstitialAd.h"

#import "ANCustomAdapter.h"
#import "ANAdResponseInfo.h"

#import "ANTestResponses.h"
#import "ANGlobal.h"
#import "ANTestGlobal.h"

#import "ANSDKSettings+PrivateMethods.h"



@interface ANBaseTestCase : XCTestCase <ANBannerAdViewDelegate, ANInterstitialAdDelegate>

@property (nonatomic, readwrite, strong) ANBannerAdView *banner;
@property (nonatomic, readwrite, strong) ANInterstitialAd *interstitial;

@property (nonatomic, assign) BOOL testComplete;

@property (nonatomic, assign) BOOL adDidLoadCalled;
@property (nonatomic, assign) BOOL adFailedToLoadCalled;
@property (nonatomic, assign) BOOL adWasClickedCalled;
@property (nonatomic, assign) BOOL adWillPresentCalled;
@property (nonatomic, assign) BOOL adDidPresentCalled;
@property (nonatomic, assign) BOOL adWillCloseCalled;
@property (nonatomic, assign) BOOL adDidCloseCalled;
@property (nonatomic, assign) BOOL adWillLeaveApplicationCalled;
@property (nonatomic, assign) BOOL adFailedToDisplayCalled;



- (void)clearTest;
- (void)stubWithInitialMockResponse:(NSString *)body;

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs;
- (void)delay:(NSTimeInterval)seconds;

- (void)loadBannerAd;
- (void)fetchInterstitialAd;
- (void)showInterstitialAd;

- (void) dumpTestStats;

@end
