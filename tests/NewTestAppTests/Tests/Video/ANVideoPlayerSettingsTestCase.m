/*
 *
 *    Copyright 2019 APPNEXUS INC
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
#import "ANVideoPlayerSettings.h"

@interface ANVideoPlayerSettingsTestCase : XCTestCase

@end

@implementation ANVideoPlayerSettingsTestCase

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testInstreamVideoPlayerSettings{
    
    NSString *videoSettings = [[ANVideoPlayerSettings sharedInstance] fetchInStreamVideoSettings];
    
    NSData *data = [videoSettings dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    XCTAssertEqualObjects(json[@"entryPoint"], @"INSTREAM_VIDEO");
    
    NSDictionary *omidOptions = json[@"partner"];
    XCTAssertEqualObjects(omidOptions[@"name"], @"appnexus.com-omios");
    XCTAssertEqualObjects(omidOptions[@"version"], @"5.2");
    
}

- (void)testBannerVideoSettings{
    
    NSString *videoSettings = [[ANVideoPlayerSettings sharedInstance] fetchBannerSettings];
    
    NSData *data = [videoSettings dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    XCTAssertEqualObjects(json[@"entryPoint"], @"BANNER");

}

-(void) testVideoPlayerClickThruSettings{
    [[ANVideoPlayerSettings sharedInstance] setClickThruText:@"SampleText"];
    [[ANVideoPlayerSettings sharedInstance] setShowClickThruControl:YES];
    
    NSString *videoSettings = [[ANVideoPlayerSettings sharedInstance] fetchInStreamVideoSettings];
    NSData *data = [videoSettings dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSDictionary *learnMoreOptions = json[@"videoOptions"][@"learnMore"];
    
    XCTAssertTrue(learnMoreOptions[@"enabled"]);
    XCTAssertEqualObjects(learnMoreOptions[@"text"],@"SampleText");
    
}

-(void) testVideoPlayerVolumeSettings {
    [[ANVideoPlayerSettings sharedInstance] setShowVolumeControl:NO];
    NSString *videoSettings = [[ANVideoPlayerSettings sharedInstance] fetchInStreamVideoSettings];
    NSData *data = [videoSettings dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    BOOL isMuted = [json[@"videoOptions"][@"showMute"] boolValue];
    BOOL isVolume = [json[@"videoOptions"][@"showVolume"] boolValue];
    XCTAssertFalse(isMuted);
    XCTAssertFalse(isVolume);
    
}

-(void) testInstreamFullScreenSettings {
    [[ANVideoPlayerSettings sharedInstance] setShowFullScreenControl:NO];
    NSString *videoSettings = [[ANVideoPlayerSettings sharedInstance] fetchInStreamVideoSettings];
    NSData *data = [videoSettings dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    XCTAssertNil(json[@"videoOptions"][@"allowFullscreen"]);
    
}

-(void) testOutstreamFullScreenSettings {
    [[ANVideoPlayerSettings sharedInstance] setShowFullScreenControl:NO];
    NSString *videoSettings = [[ANVideoPlayerSettings sharedInstance] fetchBannerSettings];
    NSData *data = [videoSettings dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    XCTAssertNotNil(json[@"videoOptions"][@"allowFullscreen"]);
    
    BOOL isFullScreen = [json[@"videoOptions"][@"allowFullscreen"] boolValue];
    
    XCTAssertFalse(isFullScreen);
}

@end
