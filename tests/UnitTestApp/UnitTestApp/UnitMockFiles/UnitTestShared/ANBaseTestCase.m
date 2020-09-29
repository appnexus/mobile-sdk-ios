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

#import "ANBaseTestCase.h"
#import "ANLogManager.h"
#import "ANURLConnectionStub.h"
#import "ANHTTPStubURLProtocol.h"
#import "ANHTTPStubbingManager.h"



#define  ROOT_VIEW_CONTROLLER  [ANGlobal getKeyWindow].rootViewController;



@interface ANBaseTestCase () 

@end




@implementation ANBaseTestCase

+ (void)load {
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
}

- (void)setUp {
    [super setUp];
    [ANLogManager setANLogLevel:ANLogLevelAll];
}

- (void)clearTest 
{
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];

    _banner = nil;
    _interstitial = nil;

    _testComplete = NO;

    _adDidLoadCalled = NO;
    _adFailedToLoadCalled = NO;
    _adWasClickedCalled = NO;
    _adWillPresentCalled = NO;
    _adDidPresentCalled = NO;
    _adWillCloseCalled = NO;
    _adDidCloseCalled = NO;
    _adWillLeaveApplicationCalled = NO;
    _adFailedToDisplayCalled = NO;

    UIViewController *presentingVC = ROOT_VIEW_CONTROLLER;

    if (presentingVC) {
        [self delay:1.0];
        [presentingVC dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)stubWithInitialMockResponse:(NSString *)body
{
    ANURLConnectionStub *testURLStub = [[ANURLConnectionStub alloc] init];

    testURLStub.requestURL   = [[[ANSDKSettings sharedInstance].baseUrlConfig utAdRequestBaseUrl] stringByAppendingString:@".*"];
    testURLStub.responseCode = 200;
    testURLStub.responseBody = body;
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:testURLStub];
    
    ANURLConnectionStub *anBaseURLStub = [[ANURLConnectionStub alloc] init];
    anBaseURLStub.requestURL   = [[[ANSDKSettings sharedInstance].baseUrlConfig webViewBaseUrl] stringByAppendingString:@".*"];
    anBaseURLStub.responseCode = 200;
    anBaseURLStub.responseBody = @"";

TESTTRACEM(@"testURLStub.requestURLRegexPatternString=%@", testURLStub.requestURL);
TESTTRACEM(@"anBaseURLStub.requestURLRegexPatternString=%@", anBaseURLStub.requestURL);
    [[ANHTTPStubbingManager sharedStubbingManager] addStub:anBaseURLStub];
}

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0) {
            break;
        }
    } while (!_testComplete);
    return _testComplete;
}

- (void)delay:(NSTimeInterval)seconds {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:seconds];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0) {
            break;
        }
    } while (true);
}

- (void)loadBannerAd {
    self.banner = [[ANBannerAdView alloc]
                   initWithFrame:CGRectMake(0, 0, 320, 50)
                   placementId:@"1"
                   adSize:CGSizeMake(320, 50)];
    self.banner.rootViewController = ROOT_VIEW_CONTROLLER;
    self.banner.autoRefreshInterval = 0.0;
    self.banner.delegate = self;
    [self.banner loadAd];
}

- (void)fetchInterstitialAd {
    self.interstitial = [[ANInterstitialAd alloc] initWithPlacementId:@"1"];
    self.interstitial.delegate = self;
    [self.interstitial loadAd];
}

- (void)showInterstitialAd {
    UIViewController *controller = ROOT_VIEW_CONTROLLER;
    [self.interstitial displayAdFromViewController:controller];
}

- (void) dumpTestStats
{
    TESTTRACEM(@""
        "\n\t\t banner        = %@"
        "\n\t\t interstitial  = %@"
        "\n\t\t testComplete  = %@"
        "\n"

        "\n\t\t adDidLoadCalled               = %@"
        "\n\t\t adFailedToLoadCalled          = %@"
        "\n\t\t adWasClickedCalled            = %@"
        "\n\t\t adWillPresentCalled           = %@"
        "\n\t\t adDidPresentCalled            = %@"
        "\n\t\t adWillCloseCalled             = %@"
        "\n\t\t adDidCloseCalled              = %@"
        "\n\t\t adWillLeaveApplicationCalled  = %@"
        "\n\t\t adFailedToDisplayCalled       = %@"
        "\n"
        "\n"
        ,

        self.banner, self.interstitial, 
        @(self.testComplete),

        @(self.adDidLoadCalled), @(self.adFailedToLoadCalled),
        @(self.adWasClickedCalled),
        @(self.adWillPresentCalled), @(self.adDidPresentCalled),
        @(self.adWillCloseCalled), @(self.adDidCloseCalled),
        @(self.adWillLeaveApplicationCalled),
        @(self.adFailedToDisplayCalled)
    );
}



#pragma mark - ANAdDelegate

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
    NSLog(@"adDidReceiveAd callback called");
    _adDidLoadCalled = YES;
    _testComplete = YES;
}


- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    NSLog(@"ad:requestFailedWithError callback called");
    _adFailedToLoadCalled = YES;
    _testComplete = YES;
}

- (void)adFailedToDisplay:(ANInterstitialAd *)ad {
    NSLog(@"adFailedToDisplay callback called");
    _adFailedToDisplayCalled = YES;
}


- (void)adWasClicked:(id<ANAdProtocol>)ad {
    NSLog(@"adWasClicked callback called");
    _adWasClickedCalled = YES;
}

- (void)adWillPresent:(id<ANAdProtocol>)ad {
    NSLog(@"adWillPresent callback called");
    _adWillPresentCalled = YES;
}

- (void)adDidPresent:(id<ANAdProtocol>)ad {
    NSLog(@"adDidPresent callback called");
    _adDidPresentCalled = YES;
}

- (void)adWillClose:(id<ANAdProtocol>)ad {
    NSLog(@"adWillClose callback called");
    _adWillCloseCalled = YES;
}

- (void)adDidClose:(id<ANAdProtocol>)ad {
    NSLog(@"adDidClose callback called");
    _adDidCloseCalled = YES;
}

- (void)adWillLeaveApplication:(id<ANAdProtocol>)ad {
    NSLog(@"adWillLeaveApplication callback called");
    _adWillLeaveApplicationCalled = YES;
}


@end
