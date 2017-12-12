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
    
    
    
       
        XCTAssertNotNil(self.instreamVideoAd);
        NSUInteger duration = [self.instreamVideoAd getAdDuration];
        XCTAssertNotEqual(duration, 0);
        XCTAssertEqual(duration, 10);
        
    

}



-(void) testVastCreativeURL {
    
    [self initializeInstreamVideoWithAllProperties];
    NSLog(@"reached here");
    
    
    
    
    
        
        XCTAssertNotNil(self.instreamVideoAd);
        NSString *vastcreativeTag = [self.instreamVideoAd getVastCreativeURL];
        XCTAssertNotNil(vastcreativeTag);
        XCTAssertNotEqual(vastcreativeTag.length, 0);
        XCTAssertNotNil(vastcreativeTag);
        XCTAssertEqual(vastcreativeTag, @"http://sampletag.com");
        
    
    
}

-(void) testCreativeTag {
    
    [self initializeInstreamVideoWithAllProperties];
    NSLog(@"reached here");
    
    
    
    
        
        XCTAssertNotNil(self.instreamVideoAd);
        NSString *creativeTag = [self.instreamVideoAd getCreativeTag];
        XCTAssertNotEqual(creativeTag.length, 0);
        XCTAssertNotNil(creativeTag);
        XCTAssertEqual(creativeTag, @"http://sampletag.com");
        
        
    
  

}


-(void) testAdDurationNotSet {
    
    [self initializeInstreamVideoWithNoProperties];
    
    
    
    
        
        NSUInteger duration = [self.instreamVideoAd getAdDuration];
        XCTAssertNotNil(self.instreamVideoAd);
        XCTAssertEqual(duration, 0);
        
        
    
    
}

-(void) testVastCreativeValuesNotSet {
    
    [self initializeInstreamVideoWithNoProperties];
    
    
    
    
        
        NSString *vastcreativeTag = [self.instreamVideoAd getVastCreativeURL];
       
        XCTAssertNotNil(self.instreamVideoAd);
        XCTAssertEqual(vastcreativeTag.length, 0);
        
        
    
   
    
    
}

-(void) testCreativeValuesNotSet {
    
    [self initializeInstreamVideoWithNoProperties];
    
    
    
    
        
        NSString *creativeTag = [self.instreamVideoAd getCreativeTag];
        XCTAssertNotNil(self.instreamVideoAd);
        XCTAssertEqual(creativeTag.length, 0);
        
    
   
    
    
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



