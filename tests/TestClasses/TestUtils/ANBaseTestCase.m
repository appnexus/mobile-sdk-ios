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

@interface ANBaseTestCase () 

@end

@implementation ANBaseTestCase

- (void)setUp {
    [super setUp];
    [[LSNocilla sharedInstance] start];
}

- (void)tearDown {
    [super tearDown];
    [[LSNocilla sharedInstance] stop];
}

- (void)clearTest {
    [[LSNocilla sharedInstance] clearStubs];
    _banner = nil;
    _interstitial = nil;
    _testComplete = NO;
    _adDidLoad = NO;
    _adFailedToLoad = NO;
}

- (void)stubWithBody:(NSString *)body {
    stubRequest(@"GET", @"http://*".regex)
    .andReturn(200)
    .withBody(body)
    ;
}

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0) {
            break;
        }
    }
    while (!_testComplete);
    return _testComplete;
}

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
    _adDidLoad = YES;
    _testComplete = YES;
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error {
    _adFailedToLoad = YES;
    _testComplete = YES;
}

- (void)adFailedToDisplay:(ANInterstitialAd *)ad {
    
}

@end
