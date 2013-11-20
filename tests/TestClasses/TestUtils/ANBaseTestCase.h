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

#import <SenTestingKit/SenTestingKit.h>
#import "Nocilla.h"
#import "ANBannerAdView.h"
#import "ANInterstitialAd.h"
#import "ANTestResponses.h"

@interface ANBaseTestCase : SenTestCase <ANBannerAdViewDelegate, ANInterstitialAdDelegate>

@property (nonatomic, readwrite, strong) ANBannerAdView *banner;
@property (nonatomic, readwrite, strong) ANInterstitialAd *interstitial;
@property (nonatomic, assign) BOOL testComplete;
@property (nonatomic, assign) BOOL adDidLoad;
@property (nonatomic, assign) BOOL adFailedToLoad;

- (void)clearTest;
- (void)stubWithBody:(NSString *)body;
- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs;

@end
