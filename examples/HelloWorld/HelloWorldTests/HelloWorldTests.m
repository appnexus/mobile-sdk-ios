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

#import "HelloWorldTests.h"
#import "ANBannerAdView.h"
#import <CoreLocation/CoreLocation.h>
#import "ANGlobal.h"
#import "ANReachability.h"

@interface HelloWorldTests ()

@property (nonatomic, readwrite, strong) ANBannerAdView *bannerAdView;
@property (nonatomic, readwrite, strong) ANInterstitialAdView *interstitialAdView;

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs;

@end

@implementation HelloWorldTests
@synthesize interstitialAdView = __interstitialAdView;

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    self.interstitialAdView = nil;
    self.bannerAdView = nil;
    
    [super tearDown];
}

- (void)testLoadInterstitial
{
    self.interstitialAdView = [[ANInterstitialAdView alloc] initWithPlacementId:@"656561"];
    self.interstitialAdView.delegate = self;
    
    [self.interstitialAdView loadAd];
    
    __testComplete = NO;
    
    // Begin a run loop terminated when __testComplete is set to true
    STAssertTrue([self waitForCompletion:10.0], @"Ad view failed to successfully load an interstitial ad.");
}

- (void)testLoadBannerSuccessful
{
    self.bannerAdView = [[ANBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 300, 50) placementId:@"656561"];
    [self.bannerAdView loadAd];
}

- (void)testCarrierInfoParameter
{
    ANAdFetcher *adFetcher = [ANAdFetcher new];
    
    ANReachability *reachability = [ANReachability reachabilityForInternetConnection];
    ANNetworkStatus status = [reachability currentReachabilityStatus];
    NSString *carrierParameter = [adFetcher performSelector:@selector(carrierParameter)];

    if (status == ANNetworkStatusNotReachable)
    {
        STAssertTrue([carrierParameter length] == 0, @"No network available. Carrier parameter should be an empty string.");

    }
    else
    {
        STAssertTrue([carrierParameter length] > 0, @"Network available. Carrier parameter should be a string with nonzero length.");
    }
}

- (void)testFirstLaunchParameter
{
    ANAdFetcher *adFetcher = [ANAdFetcher new];
    NSString *firstLaunchParameter = [adFetcher performSelector:@selector(firstLaunchParameter)];
    
    if (isFirstLaunch())
    {
        STAssertTrue([firstLaunchParameter length] > 0, @"This is the application's first launch. Parameter should be a string with nonzero length.");
    }
    else
    {
        STAssertTrue([firstLaunchParameter length] == 0, @"This is not the application's first launch. This parameter should be an empty string.");
    }
}

- (void)testBadURL
{
    self.interstitialAdView = [[ANInterstitialAdView alloc] initWithPlacementId:@"656561"];
    self.interstitialAdView.delegate = self;

    [self.interstitialAdView performSelector:@selector(refreshAllowedAdSizes)];
    NSValue *randomAllowedSize = [[self.interstitialAdView performSelector:@selector(allowedAdSizes)] anyObject];
    [self.interstitialAdView setAdSize:[randomAllowedSize CGSizeValue]];
    
    __testComplete = NO;

    [self.interstitialAdView.adFetcher requestAdWithURL:[NSURL URLWithString:@"http://127.0.0.1"]];
    // Begin a run loop terminated when __testComplete is set to true
    STAssertTrue([self waitForCompletion:10.0], @"Ad view failed to respond successfully to a bad URL.");
}

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0)
        {
            break;
        }
    }
    while (!__testComplete);
    
    return __testComplete;
}

#pragma mark ANInterstitialAdViewDelegate

- (void)adViewLoaded:(ANInterstitialAdView *)adView
{
    __testComplete = YES;
    STAssertTrue(YES, @"Ad view loaded as expected");
}

- (void)adView:(ANInterstitialAdView *)adView requestFailedWithError:(NSError *)error
{
    __testComplete = YES;
    STAssertTrue(YES, @"Ad view request failed as expected");
}

- (void)adViewNoAdToShow:(ANInterstitialAdView *)adView
{
    __testComplete = YES;
    STAssertTrue(YES, @"Ad view loaded with no ad as expected");
}

@end
