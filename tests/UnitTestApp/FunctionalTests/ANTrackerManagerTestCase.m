/*   Copyright 2015 APPNEXUS INC
 
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
#import "ANTrackerManager.h"
#import "ANReachability+ANTest.h"
#import "XCTestCase+ANCategory.h"
#import "ANGlobal.h"
#import "ANHTTPStubbingManager.h"
#import "ANTrackerManager+ANTest.h"
#import "NSTimer+ANCategory.h"

@interface ANTrackerManagerTestCase : XCTestCase

@property (nonatomic, readwrite, strong)  NSString  *urlString;
@property (nonatomic, readwrite, assign)  BOOL       urlWasFired;
@property (nonatomic, strong) XCTestExpectation *firedImpressionTrackerExpectation;
@property (nonatomic, strong) XCTestExpectation *firedImpressionTrackerExpectationOffline;

@end

@implementation ANTrackerManagerTestCase

- (void)setUp {
    [super setUp];
    [[ANHTTPStubbingManager sharedStubbingManager] enable];
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestLoaded:)
                                                 name:kANHTTPStubURLProtocolRequestDidLoadNotification
                                               object:nil];
}

- (void)tearDown {
    [super tearDown];
    self.urlString = nil;
    self.urlWasFired = NO;
    self.firedImpressionTrackerExpectation = nil;
    self.firedImpressionTrackerExpectationOffline = nil;
    [ANReachability toggleNonReachableNetworkStatusSimulationEnabled:NO];
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
     [[ANHTTPStubbingManager sharedStubbingManager] disable];
    for (UIView *additionalView in [[ANGlobal getKeyWindow].rootViewController.view subviews]){
          [additionalView removeFromSuperview];
      }
}

- (void)testSimulateOffline {
    [ANReachability toggleNonReachableNetworkStatusSimulationEnabled:YES];

    self.urlString = @"https://acdn.adnxs.com/mobile/native_test/empty_response.json";
    [ANTrackerManager fireTrackerURL:self.urlString];
    [XCTestCase delayForTimeInterval:3.0];
    XCTAssertFalse(self.urlWasFired);
    
    NSTimer *fireTimer = [ANTrackerManager sharedManager].trackerRetryTimer;
    XCTAssertTrue(fireTimer.an_isScheduled);

    [ANReachability toggleNonReachableNetworkStatusSimulationEnabled:NO];
    fireTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];

    [XCTestCase delayForTimeInterval:3.0];
    XCTAssertTrue(self.urlWasFired);
}

- (void)testFireTrackerURLArrayWithBlocks {
    self.firedImpressionTrackerExpectation = [self expectationWithDescription:@"Didn't receive Impression Tracker event"];
    NSString *url = @"https://acdn.adnxs.com/mobile/native_test/empty_response.json";
    [ANTrackerManager fireTrackerURLArray:@[url] withBlock:^(BOOL isTrackerURLFired) {
        XCTAssertTrue(isTrackerURLFired);
        [self.firedImpressionTrackerExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval  handler:nil];
}

- (void)testSimulateOfflineFireTrackerURLArrayWithBlocks {
    self.firedImpressionTrackerExpectationOffline = [self expectationWithDescription:@"Didn't receive Impression Tracker event offline"];
    [ANReachability toggleNonReachableNetworkStatusSimulationEnabled:YES];
    NSString *url = @"https://acdn.adnxs.com/mobile/native_test/empty_response.json";
    [ANTrackerManager fireTrackerURLArray:@[url] withBlock:^(BOOL isTrackerURLFired) {
        XCTAssertTrue(isTrackerURLFired);
        [self.firedImpressionTrackerExpectationOffline fulfill];
    }];
    [XCTestCase delayForTimeInterval:3.0];

    NSTimer *fireTimer = [ANTrackerManager sharedManager].trackerRetryTimer;

    [ANReachability toggleNonReachableNetworkStatusSimulationEnabled:NO];
    fireTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];

    [self waitForExpectationsWithTimeout:2 * kAppNexusRequestTimeoutInterval handler:nil];
}

- (void)requestLoaded:(NSNotification *)notification {
    NSURLRequest *request = notification.userInfo[kANHTTPStubURLProtocolRequest];
    if (self.urlString && [[request.URL absoluteString] isEqual:self.urlString]) {
        self.urlWasFired = YES;
    }
}

@end
