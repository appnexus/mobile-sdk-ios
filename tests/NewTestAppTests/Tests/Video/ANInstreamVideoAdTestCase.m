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
#import "ANGlobal.h"
#import "ANInstreamVideoAd.h"
#import "ANVideoAdPlayer.h"
#import "ANInstreamVideoAd+Test.h"

@interface ANInstreamVideoAdTestCase : XCTestCase
    @property (nonatomic, readwrite, strong) ANInstreamVideoAd *instreamVideoAd;
    @property (nonatomic) BOOL callbackInvoked;
@end

@implementation ANInstreamVideoAdTestCase

- (void)setUp {
    [super setUp];
    
  
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.instreamVideoAd = nil;
}


- (void)testAdDuration {

    [self initializeInstreamVideoWithAllProperties];
    NSLog(@"reached here");
    XCTestExpectation   *expectation    = [self expectationWithDescription:@"Dummy expectation"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSUInteger duration = [self.instreamVideoAd getAdDuration];
        XCTAssertNotNil(self.instreamVideoAd);
        XCTAssertNotEqual(duration, 0);
        XCTAssertEqual(duration, 10);
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10 handler:nil];

}



-(void) testVastCreativeURL {
    
    [self initializeInstreamVideoWithAllProperties];
    NSLog(@"reached here");
    
    XCTestExpectation   *expectation    = [self expectationWithDescription:@"Dummy expectation"];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSString *vastcreativeTag = [self.instreamVideoAd getVastCreativeURL];
        XCTAssertNotNil(self.instreamVideoAd);
     
        XCTAssertNotNil(vastcreativeTag);
        XCTAssertNotEqual(vastcreativeTag, @"");
        XCTAssertNotNil(vastcreativeTag);
        XCTAssertEqual(vastcreativeTag, @"http://sampletag.com");
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10 handler:nil];
    
}

-(void) testCreativeTag {
    
    [self initializeInstreamVideoWithAllProperties];
    NSLog(@"reached here");
    
    XCTestExpectation   *expectation    = [self expectationWithDescription:@"Dummy expectation"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSString *creativeTag = [self.instreamVideoAd getCreativeTag];
        XCTAssertNotNil(self.instreamVideoAd);
        XCTAssertNotEqual(creativeTag, @"");
        XCTAssertNotNil(creativeTag);
        
        XCTAssertEqual(creativeTag, @"http://sampletag.com");
        
        [expectation fulfill];
    });
    [self waitForExpectationsWithTimeout:10 handler:nil];
  

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


-(void) initializeInstreamVideoWithAllProperties {
    self.instreamVideoAd = [[ANInstreamVideoAd alloc] init];
    self.instreamVideoAd.adPlayer = [[ANVideoAdPlayer alloc] init];
    self.instreamVideoAd.adPlayer.videoDuration = 10;
    self.instreamVideoAd.adPlayer.creativeTag = @"http://sampletag.com";
    self.instreamVideoAd.adPlayer.vastCreativeURL = @"http://sampletag.com";
}

-(void) initializeInstreamVideoWithNoProperties {
    self.instreamVideoAd = [[ANInstreamVideoAd alloc] init];
    self.instreamVideoAd.adPlayer = [[ANVideoAdPlayer alloc] init];
}


@end



