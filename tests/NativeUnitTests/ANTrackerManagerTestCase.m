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

#import "ANHTTPStubbingManager.h"
#import "ANTrackerManager+ANTest.h"
#import "NSTimer+ANCategory.h"

@interface ANTrackerManagerTestCase : XCTestCase

@property (nonatomic, readwrite, strong)  NSString  *urlString;
@property (nonatomic, readwrite, assign)  BOOL       urlWasFired;

@end

@implementation ANTrackerManagerTestCase

- (void)setUp {
    [ANHTTPStubbingManager sharedStubbingManager].ignoreUnstubbedRequests = YES;
}

- (void)tearDown {
    [super tearDown];
    [ANReachability toggleNonReachableNetworkStatusSimulationEnabled:NO];
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = NO;
}

- (void)testSimulateOffline {
    [ANHTTPStubbingManager sharedStubbingManager].broadcastRequests = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestLoaded:)
                                                 name:kANHTTPStubURLProtocolRequestDidLoadNotification
                                               object:nil];
    [ANReachability toggleNonReachableNetworkStatusSimulationEnabled:YES];

    self.urlString = @"https://acdn.adnxs.com/mobile/native_test/empty_response.json";
    [ANTrackerManager fireTrackerURL:self.urlString];
    [XCTestCase delayForTimeInterval:3.0];
    XCTAssertFalse(self.urlWasFired);
    
    NSTimer *fireTimer = [ANTrackerManager sharedManager].impressionTrackerRetryTimer;
    XCTAssertTrue(fireTimer.an_isScheduled);
    
    [ANReachability toggleNonReachableNetworkStatusSimulationEnabled:NO];
    fireTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];

    [XCTestCase delayForTimeInterval:1.5];
    XCTAssertTrue(self.urlWasFired);
}

- (void)requestLoaded:(NSNotification *)notification {
    NSURLRequest *request = notification.userInfo[kANHTTPStubURLProtocolRequest];
    if ([[request.URL absoluteString] isEqual:self.urlString]) {
        self.urlWasFired = YES;
    }
}

@end
