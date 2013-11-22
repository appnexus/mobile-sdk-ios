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

@interface MediationCallbacksTests : ANBaseTestCase
@property (nonatomic, readwrite, assign) BOOL adLoadedMultiple;
@property (nonatomic, readwrite, assign) BOOL adFailedMultiple;
@end

@implementation MediationCallbacksTests

float const CALLBACKS_TIMEOUT = 5.0;

- (void)tearDown
{
    [super tearDown];
    _adLoadedMultiple = NO;
    _adFailedMultiple = NO;
}

- (void)runBasicTest:(BOOL)didLoadValue
            waitTime:(int)waitTime {
    [self loadBannerAd];
    [self waitForCompletion:waitTime];
    
    STAssertEquals(didLoadValue, self.adDidLoadCalled,
                   @"callback adDidLoad should be %d", didLoadValue);
    STAssertEquals((BOOL)!didLoadValue, self.adFailedToLoadCalled,
                   @"callback adFailedToLoad should be %d", (BOOL)!didLoadValue);
    STAssertFalse(self.adLoadedMultiple, @"adLoadedMultiple should never be true");
    STAssertFalse(self.adFailedMultiple, @"adFailedMultiple should never be true");
    
    [self clearTest];
}

#pragma mark MediationCallback tests

- (void)test18LoadedMultiple
{
    [self stubWithBody:[ANTestResponses createMediatedBanner:@"ANLoadedMultiple"]];
    [self stubResultCBResponses:@""];
    [self runBasicTest:YES waitTime:CALLBACKS_TIMEOUT];
}

- (void)test19Timeout
{
    [self stubWithBody:[ANTestResponses createMediatedBanner:@"ANTimeout"]];
    [self stubResultCBResponses:@""];
    [self runBasicTest:NO waitTime:kAppNexusMediationNetworkTimeoutInterval + CALLBACKS_TIMEOUT];
}

- (void)test20LoadThenFail
{
    [self stubWithBody:[ANTestResponses createMediatedBanner:@"ANLoadThenFail"]];
    [self stubResultCBResponses:@""];
    [self runBasicTest:YES waitTime:CALLBACKS_TIMEOUT];
}

- (void)test21FailThenLoad
{
    [self stubWithBody:[ANTestResponses createMediatedBanner:@"ANFailThenLoad"]];
    [self stubResultCBResponses:@""];
    [self runBasicTest:NO waitTime:CALLBACKS_TIMEOUT];
}

- (void)test24FailedMultiple
{
    [self stubWithBody:[ANTestResponses createMediatedBanner:@"ANFailedMultiple"]];
    [self stubResultCBResponses:@""];
    [self runBasicTest:NO waitTime:CALLBACKS_TIMEOUT];
}

#pragma mark ANBannerAdViewDelegate

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
    if (self.adDidLoadCalled) {
        self.adLoadedMultiple = YES;
    }
    [super adDidReceiveAd:ad];
}
- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error {
    if (self.adFailedToLoadCalled) {
        self.adFailedMultiple = YES;
    }
    [super ad:ad requestFailedWithError:error];
}

@end
