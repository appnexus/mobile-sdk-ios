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
#import "ANVideoPlayerSettings+ANCategory.h"
#import "ANGlobal.h"
#import "ANOMIDImplementation.h"

@interface ANVideoPlayerSettingsTestCase : XCTestCase

@end

@implementation ANVideoPlayerSettingsTestCase

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInstreamVideoPlayerSettings{
    
    NSString *videoSettings = [[ANVideoPlayerSettings sharedInstance] fetchInStreamVideoSettings];
    
    NSData *data = [videoSettings dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    XCTAssertEqualObjects(json[@"entryPoint"], @"INSTREAM_VIDEO");
    
    NSDictionary *omidOptions = json[@"partner"];
    XCTAssertEqualObjects(omidOptions[@"name"], AN_OMIDSDK_PARTNER_NAME);
    XCTAssertEqualObjects(omidOptions[@"version"], AN_SDK_VERSION);
    
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
    XCTAssertTrue([learnMoreOptions[@"enabled"] boolValue]);
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

-(void) testVideoPlayerVolumeControlTrue {
    [[ANVideoPlayerSettings sharedInstance] setShowVolumeControl:YES];
    NSString *videoSettings = [[ANVideoPlayerSettings sharedInstance] fetchInStreamVideoSettings];
    NSData *data = [videoSettings dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    XCTAssertNil(json[@"videoOptions"][@"showMute"]);
    XCTAssertNil(json[@"videoOptions"][@"showVolume"]);
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

-(void) testInitialAudioSettings {
    [[ANVideoPlayerSettings sharedInstance] setInitalAudio:Default];
    NSString *videoSettings = [[ANVideoPlayerSettings sharedInstance] fetchBannerSettings];
    NSData *data = [videoSettings dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    XCTAssertNil(json[@"videoOptions"][@"initialAudio"]);
}

-(void) testInitialAudioOnSettings {
    [[ANVideoPlayerSettings sharedInstance] setInitalAudio:SoundOn];
    NSString *videoSettings = [[ANVideoPlayerSettings sharedInstance] fetchBannerSettings];
    NSData *data = [videoSettings dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    XCTAssertNotNil(json[@"videoOptions"][@"initialAudio"]);
    
    XCTAssertEqualObjects(json[@"videoOptions"][@"initialAudio"],@"on");
}

-(void) testInstreamSkipSettingsTrue {
    [[ANVideoPlayerSettings sharedInstance] setShowSkip:YES];
    [[ANVideoPlayerSettings sharedInstance] setSkipDescription:@"Video Skip Demo"];
    [[ANVideoPlayerSettings sharedInstance] setSkipLabelName:@"Test"];
    [[ANVideoPlayerSettings sharedInstance] setSkipOffset:2];
    NSString *videoSettings = [[ANVideoPlayerSettings sharedInstance] fetchInStreamVideoSettings];
    NSData *data = [videoSettings dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *skippableOptions = json[@"videoOptions"][@"skippable"];    
    XCTAssertTrue([skippableOptions[@"enabled"] boolValue]);
    XCTAssertEqualObjects(skippableOptions[@"skipText"],@"Video Skip Demo");
    XCTAssertEqualObjects(skippableOptions[@"skipButtonText"],@"Test");
    XCTAssertEqualObjects(skippableOptions[@"videoOffset"],[NSNumber numberWithInteger:2]);
    
}

-(void) testInstreamSkipSettingsFalse {
    [[ANVideoPlayerSettings sharedInstance] setShowSkip:NO];
    NSString *videoSettings = [[ANVideoPlayerSettings sharedInstance] fetchInStreamVideoSettings];
    NSData *data = [videoSettings dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *skippableOptions = json[@"videoOptions"][@"skippable"];
    XCTAssertFalse([skippableOptions[@"enabled"] boolValue]);
    
}


-(void) testOutstreamSkipSettings {
    [[ANVideoPlayerSettings sharedInstance] setShowSkip:NO];
    NSString *videoSettings = [[ANVideoPlayerSettings sharedInstance] fetchBannerSettings];
    NSData *data = [videoSettings dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    XCTAssertNil(json[@"videoOptions"][@"skippable"]);
    
}

@end
