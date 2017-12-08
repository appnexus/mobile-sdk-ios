/*
 *
 *    Copyright 2017 APPNEXUS INC
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */


#import <XCTest/XCTest.h>
#import "ANVideoAdPlayer.h"
#import "ANGlobal.h"

@interface ANInstreamVideoAdTestCase : XCTestCase <ANVideoAdPlayerDelegate>
    @property (nonatomic, readwrite, strong) ANVideoAdPlayer *videoPlayer;
    @property (nonatomic, strong) NSString *vastContent;
    @property (nonatomic) BOOL callbackInvoked;
@end

@implementation ANInstreamVideoAdTestCase

- (void)setUp {
    [super setUp];
    self.callbackInvoked = NO;
    self.videoPlayer = [[ANVideoAdPlayer alloc] init];
    self.videoPlayer.delegate = self;
    
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    
    self.vastContent = [NSString stringWithContentsOfFile: [currentBundle pathForResource:@"vast_content" ofType:@"txt"]
                                                       encoding: NSUTF8StringEncoding
                                                          error: nil ];
    
    [self.videoPlayer loadAdWithVastContent:self.vastContent];
    
    NSLog(@"%@", self.vastContent);
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAdDuration {
    XCTAssert([self waitForCompletion:10.0], @"Testing to see what happens here...");
    if(self.callbackInvoked){
        NSLog(@"reached here");
        
        
        /*XCTestExpectation   *expectation    = [self expectationWithDescription:@"Dummy expectation"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                       ^{
                           NSUInteger duration = [self.videoPlayer getAdDuration];
                           XCTAssertNotEqual(duration, 0);
                           [expectation fulfill];
                       });
        [self waitForExpectationsWithTimeout:20.0 handler:nil];*/
    }
    
    
    
}

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if([timeoutDate timeIntervalSinceNow] < 0.0)
            break;
    } while (!self.callbackInvoked);
    
    return self.callbackInvoked;
}

- (void)videoAdLoadFailed:(NSError *)error {
    NSLog(@"video adfailed delegate returned");
}

- (void)videoAdReady {
    self.callbackInvoked = YES;
    NSLog(@"delegate returned");
}

@end
