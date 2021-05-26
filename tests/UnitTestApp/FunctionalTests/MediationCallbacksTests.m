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
#import "ANMockMediationAdapterTimeout.h"
#import "ANHTTPStubbingManager.h"
#import "ANAdResponseInfo.h"


float const  MEDIATION_CALLBACKS_TESTS_TIMEOUT  = 20.0;   // seconds



@interface MediationCallbacksTests : ANBaseTestCase

@property (nonatomic, readwrite, assign) BOOL adLoadedMultiple;
@property (nonatomic, readwrite, assign) BOOL adFailedMultiple;

@end




@implementation MediationCallbacksTests

#pragma mark - Test lifecycle.

- (void)setUp {
    [super setUp];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[ANHTTPStubbingManager sharedStubbingManager] disable];
    [[ANHTTPStubbingManager sharedStubbingManager] removeAllStubs];
    self.banner.delegate = nil;
    self.banner.appEventDelegate = nil;
    [self.banner removeFromSuperview];
    self.banner = nil;
    
    _adLoadedMultiple = NO;
    _adFailedMultiple = NO;
    self.adDidLoadCalled = NO;
    self.adFailedToLoadCalled = NO;
    [self clearTest];
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}


#pragma mark - MediationCallback tests

- (void)test17
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ kFauxMediationAdapterClassDoesNotExist, @"ANMockMediationAdapterTimeout" ]] ];
    [ANMockMediationAdapterTimeout setTimeout:kAppNexusMediationNetworkTimeoutInterval - 2];

    [self runBasicTest:YES waitTime:MEDIATION_CALLBACKS_TESTS_TIMEOUT];
    [self clearTest];
}

- (void)test18LoadedMultiple
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ @"ANMockMediationAdapterLoadedMultiple" ]]];

    [self runBasicTest:YES waitTime:MEDIATION_CALLBACKS_TESTS_TIMEOUT];
    [self clearTest];
}

- (void)test19Timeout
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ @"ANMockMediationAdapterTimeout" ]]];
    [ANMockMediationAdapterTimeout setTimeout:kAppNexusMediationNetworkTimeoutInterval * 2];

    [self runBasicTest:NO waitTime:kAppNexusMediationNetworkTimeoutInterval + MEDIATION_CALLBACKS_TESTS_TIMEOUT];
    [self clearTest];
}

- (void)test20LoadThenFail
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ @"ANMockMediationAdapterLoadThenFail" ]]];

    [self runBasicTest:YES waitTime:MEDIATION_CALLBACKS_TESTS_TIMEOUT];
    [self clearTest];
}

- (void)test21FailThenLoad
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ @"ANMockMediationAdapterFailThenLoad" ]]];

    [self runBasicTest:NO waitTime:MEDIATION_CALLBACKS_TESTS_TIMEOUT];
    [self clearTest];
}

- (void)test22LoadAndHitOtherCallbacks
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ @"ANMockMediationAdapterLoadAndHitOtherCallbacks" ]]];

    [self runBasicTest:YES waitTime:MEDIATION_CALLBACKS_TESTS_TIMEOUT];
    [self checkCallbacks:YES];
    [self clearTest];
}

- (void)test23FailAndHitOtherCallbacks
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ @"ANMockMediationAdapterFailAndHitOtherCallbacks" ]]];

    [self runBasicTest:NO waitTime:MEDIATION_CALLBACKS_TESTS_TIMEOUT];
    [self checkCallbacks:NO];
    [self clearTest];
}

- (void)test24FailedMultiple
{
    [self stubWithInitialMockResponse:[ANTestResponses mediationWaterfallWithMockClassNames:@[ @"ANMockMediationAdapterFailedMultiple" ]]];

    [self runBasicTest:NO waitTime:MEDIATION_CALLBACKS_TESTS_TIMEOUT];
    [self clearTest];
}




#pragma mark - Test helper methods.

- (void)runBasicTest:(BOOL)didLoadValue
            waitTime:(int)waitTime
{
    [self loadBannerAd];
    [self waitForCompletion:waitTime];

    XCTAssertEqual(didLoadValue, self.adDidLoadCalled, @"callback adDidLoad should be %d", didLoadValue);
    XCTAssertEqual((BOOL)!didLoadValue, self.adFailedToLoadCalled, @"callback adFailedToLoad should be %d", (BOOL)!didLoadValue);
    
    XCTAssertFalse(self.adLoadedMultiple, @"adLoadedMultiple should never be true");
    XCTAssertFalse(self.adFailedMultiple, @"adFailedMultiple should never be true");
}

- (void)checkCallbacks:(BOOL)called
{
    XCTAssertEqual(self.adWasClickedCalled,             called, @"callback adWasClickCalled should be %d", called);
    XCTAssertEqual(self.adWillPresentCalled,            called, @"callback adWillPresentCalled should be %d", called);
    XCTAssertEqual(self.adDidPresentCalled,             called, @"callback adDidPresentCalled should be %d", called);
    XCTAssertEqual(self.adWillCloseCalled,              called, @"callback adWillCloseCalled should be %d", called);
    XCTAssertEqual(self.adDidCloseCalled,               called, @"callback adDidCloseCalled should be %d", called);
    XCTAssertEqual(self.adWillLeaveApplicationCalled,   called, @"callback adWillLeaveApplicationCalled should be %d", called);
}




#pragma mark - ANBannerAdViewDelegate

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
    if (self.adDidLoadCalled) {
        self.adLoadedMultiple = YES;
    }
    [super adDidReceiveAd:ad];
}

- (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error
{
    if (self.adFailedToLoadCalled) {
        self.adFailedMultiple = YES;
    }
    [super ad:ad requestFailedWithError:error];
}


@end

