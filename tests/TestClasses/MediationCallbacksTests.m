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
#import <Foundation/Foundation.h>
#import "ANBannerAdView.h"
#import "ANGlobal.h"

@interface MediationCallbacksTests : SenTestCase
@property (nonatomic, readwrite, strong) ANBannerAdView *bannerAdView;
@end

@interface MediationCallbacksTests() <ANBannerAdViewDelegate>
{
    BOOL testDidComplete;
    BOOL didLoad, didFail;
    BOOL didLoadMultiple, didFailMultiple;
}
@end

@implementation MediationCallbacksTests


- (void)setUp
{
    [super setUp];
    didLoad = NO;
    didFail = NO;
    didLoadMultiple = NO;
    didFailMultiple = NO;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)runBasicTest:(int)placementId
        didLoadValue:(BOOL)didLoadValue
            waitTime:(int)waitTime {
    CGRect frame = CGRectMake(0, 0, 320, 50);
    self.bannerAdView = [ANBannerAdView adViewWithFrame:frame
                                            placementId:[NSString stringWithFormat:@"%d", placementId]];
    self.bannerAdView.adSize = CGSizeMake(320, 50);
    self.bannerAdView.delegate = self;
    self.bannerAdView.autorefreshInterval = 0;
    
    [self.bannerAdView loadAd];
    [self waitForCompletion:waitTime];
    
    STAssertEquals(didLoadValue, didLoad, @"");
    STAssertEquals((BOOL)!didLoadValue, didFail, @"");
    STAssertFalse(didLoadMultiple, @"");
    STAssertFalse(didFailMultiple, @"");
}

#pragma mark MediationCallback tests

- (void)test18LoadedMultiple
{
    [self runBasicTest:18 didLoadValue:YES waitTime:5];
}

- (void)test19Timeout
{
    [self runBasicTest:19 didLoadValue:NO waitTime:kAppNexusMediationNetworkTimeoutInterval + 5];
}

- (void)test20LoadThenFail
{
    [self runBasicTest:20 didLoadValue:YES waitTime:5];
}

- (void)test21FailThenLoad
{
    [self runBasicTest:21 didLoadValue:NO waitTime:5];
}

- (void)test24FailedMultiple
{
    [self runBasicTest:24 didLoadValue:NO waitTime:5];
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
	
    while (!testDidComplete);
    
    return testDidComplete;
}

#pragma mark ANBannerAdViewDelegate

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
    NSLog(@"Ad Loaded");
    if (didLoad)
        didLoadMultiple = YES;
    didLoad = YES;
//    testDidComplete = YES;
}
- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error {
    NSLog(@"Ad Failed");
    if (didFailMultiple)
        didFailMultiple = YES;
    didFail = YES;
//    testDidComplete = YES;
}

- (void) adWillPresent {};
- (void) adWillClose {}
- (void) adDidClose {};
- (void) adWillLeaveApplication {}

@end
