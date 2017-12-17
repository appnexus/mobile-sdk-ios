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
 }



-(void) testVastCreativeURL {
    
        [self initializeInstreamVideoWithAllProperties];
        NSLog(@"reached here");
        XCTAssertNotNil(self.instreamVideoAd);
        NSString *vastcreativeTag = [self.instreamVideoAd getVastURL];
        XCTAssertNotNil(vastcreativeTag);
        XCTAssertNotEqual(vastcreativeTag.length, 0);
        XCTAssertNotNil(vastcreativeTag);
        XCTAssertEqual(vastcreativeTag, @"http://sampletag.com");
}


-(void) testVastCreativeXML {
    
    [self initializeInstreamVideoWithAllProperties];
    NSLog(@"reached here");
    XCTAssertNotNil(self.instreamVideoAd);
    NSString *vastcreativeXMLTag = [self.instreamVideoAd getVastXML];
    XCTAssertNotNil(vastcreativeXMLTag);
    XCTAssertNotEqual(vastcreativeXMLTag.length, 0);
    XCTAssertNotNil(vastcreativeXMLTag);
    XCTAssertEqual(vastcreativeXMLTag, @"http://sampletag.com");
}


-(void) testCreativeTag {
        [self initializeInstreamVideoWithAllProperties];
        NSLog(@"reached here");
        XCTAssertNotNil(self.instreamVideoAd);
        NSString *creativeTag = [self.instreamVideoAd getCreativeURL];
        XCTAssertNotEqual(creativeTag.length, 0);
        XCTAssertNotNil(creativeTag);
        XCTAssertEqual(creativeTag, @"http://sampletag.com");
}


-(void) testAdDurationNotSet {
        [self initializeInstreamVideoWithNoProperties];
        XCTAssertNotNil(self.instreamVideoAd);
        NSUInteger duration = [self.instreamVideoAd getAdDuration];
        XCTAssertEqual(duration, 0);
}

-(void) testVastCreativeValuesNotSet {
        [self initializeInstreamVideoWithNoProperties];
        XCTAssertNotNil(self.instreamVideoAd);
        NSString *vastcreativeTag = [self.instreamVideoAd getVastURL];
        XCTAssertEqual(vastcreativeTag.length, 0);
}


-(void) testCreativeValuesNotSet {
    
        [self initializeInstreamVideoWithNoProperties];
        XCTAssertNotNil(self.instreamVideoAd);
        NSString *creativeTag = [self.instreamVideoAd getCreativeURL];
        XCTAssertEqual(creativeTag.length, 0);
}

-(void) testVastCreativeXMLValuesNotSet {
    [self initializeInstreamVideoWithNoProperties];
    XCTAssertNotNil(self.instreamVideoAd);
    NSString *vastcreativeXMLTag = [self.instreamVideoAd getVastXML];
    XCTAssertEqual(vastcreativeXMLTag.length, 0);
}


-(void) testPlayHeadTimeForVideoSet {
    [self initializeInstreamVideoWithNoProperties];
    XCTAssertNotNil(self.instreamVideoAd);
    NSUInteger duration = [self.instreamVideoAd getAdPlayElapsedTime];
    XCTAssertNotEqual(duration, 0);
}



-(void) initializeInstreamVideoWithAllProperties {
    self.instreamVideoAd = [[ANInstreamVideoAd alloc] init];
    self.instreamVideoAd.adPlayer = [[ANVideoAdPlayer alloc] init];
    self.instreamVideoAd.adPlayer.videoDuration = 10;
    self.instreamVideoAd.adPlayer.creativeURL = @"http://sampletag.com";
    self.instreamVideoAd.adPlayer.vastURLContent = @"http://sampletag.com";
    self.instreamVideoAd.adPlayer.vastXMLContent = @"http://sampletag.com";
    
}

-(void) initializeInstreamVideoWithNoProperties {
    self.instreamVideoAd = [[ANInstreamVideoAd alloc] init];
    self.instreamVideoAd.adPlayer = [[ANVideoAdPlayer alloc] init];
}


@end



