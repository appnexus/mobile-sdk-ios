/*   Copyright 2019 APPNEXUS INC
 
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

#import "ANVideoPlayerSettings.h"
#import "ANGlobal.h"
#import "ANOMIDImplementation.h"
#import "ANVideoPlayerSettings+ANCategory.h"

NSString * const  ANName = @"name";
NSString * const  ANVersion = @"version";
NSString * const  ANPartner = @"partner";
NSString * const  ANEntry = @"entryPoint";

NSString * const  ANInstreamVideo = @"INSTREAM_VIDEO";
NSString * const  ANBanner = @"BANNER";

NSString * const  ANAdText = @"adText";
NSString * const  ANSeparator = @"separator";
NSString * const  ANEnabled = @"enabled";
NSString * const  ANText = @"text";
NSString * const  ANLearnMore = @"learnMore";
NSString * const  ANMute = @"showMute";
NSString * const  ANVolume = @"showVolume";
NSString * const  ANAllowFullScreen = @"allowFullscreen";
NSString * const  ANShowFullScreen = @"showFullScreenButton";
NSString * const  ANDisableTopBar = @"disableTopBar";
NSString * const  ANVideoOptions = @"videoOptions";
NSString * const  ANInitialAudio = @"initialAudio";
NSString * const  ANOn = @"on";
NSString * const  ANOff = @"off";
NSString * const  ANSkip = @"skippable";
NSString * const  ANSkipDescription = @"skipText";
NSString * const  ANSkipLabelName = @"skipButtonText";
NSString * const  ANSkipOffset = @"videoOffset";

@interface ANVideoPlayerSettings()

@property (nonatomic,strong) NSMutableDictionary *optionsDictionary;

@end

@implementation ANVideoPlayerSettings

+ (instancetype)sharedInstance {
    static dispatch_once_t sdkSettingsToken;
    static ANVideoPlayerSettings *videoSettings;
    dispatch_once(&sdkSettingsToken, ^{
        videoSettings = [[ANVideoPlayerSettings alloc] init];
        videoSettings.showClickThruControl = YES;
        videoSettings.showFullScreenControl = YES;
        videoSettings.initalAudio = Default;
        videoSettings.optionsDictionary = [[NSMutableDictionary alloc] init];
        NSDictionary *partner = @{ ANName : AN_OMIDSDK_PARTNER_NAME , ANVersion : AN_SDK_VERSION};
        [videoSettings.optionsDictionary setObject:partner forKey:ANPartner];
        [videoSettings.optionsDictionary setObject:ANInstreamVideo forKey:ANEntry];
        videoSettings.showAdText = YES;
        videoSettings.showVolumeControl = YES;
        videoSettings.showTopBar = YES;
        videoSettings.showSkip = YES;
        videoSettings.skipOffset = 5;
        
    });
    return videoSettings;
}

-(NSString *) videoPlayerOptions {
    
    NSMutableDictionary *publisherOptions = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *clickthruOptions = [[NSMutableDictionary alloc] init];
    if(self.showAdText && self.adText != nil){
        publisherOptions[ANAdText] = self.adText;
    }else if(!self.showAdText){
        publisherOptions[ANAdText] = @"";
        clickthruOptions[ANSeparator] = @"";
    }
    clickthruOptions[ANEnabled] =  [NSNumber numberWithBool:self.showClickThruControl];
    
    if(self.clickThruText != nil && self.showClickThruControl){
        clickthruOptions[ANText] =  self.clickThruText;
    }
    
    
    if(clickthruOptions.count > 0){
        publisherOptions[ANLearnMore] = clickthruOptions;
    }

    if([self.optionsDictionary[ANEntry] isEqualToString:ANInstreamVideo]){
         NSMutableDictionary *skipOptions = [[NSMutableDictionary alloc] init];
        if(self.showSkip){
            skipOptions[ANSkipDescription] = self.skipDescription;
            skipOptions[ANSkipLabelName] = self.skipLabelName;
            skipOptions[ANSkipOffset] = [NSNumber numberWithInteger:self.skipOffset];
        }
        skipOptions[ANEnabled] = [NSNumber numberWithBool:self.showSkip];
        publisherOptions[ANSkip] = skipOptions;
    }
    
    if(!self.showVolumeControl){
        publisherOptions[ANMute] = [NSNumber numberWithBool:self.showVolumeControl];
        publisherOptions[ANVolume] = [NSNumber numberWithBool:self.showVolumeControl];
    }
    
    if([self.optionsDictionary[ANEntry] isEqualToString:ANBanner]){
        publisherOptions[ANAllowFullScreen] = [NSNumber numberWithBool:self.showFullScreenControl];
        publisherOptions[ANShowFullScreen] = [NSNumber numberWithBool:self.showFullScreenControl];
    }
    
    if(self.initalAudio != Default){
        if(self.initalAudio == SoundOn){
            publisherOptions[ANInitialAudio] = ANOn;
        }else {
            publisherOptions[ANInitialAudio] = ANOff;
        }
    }else {
        if(publisherOptions[ANInitialAudio]){
            publisherOptions[ANInitialAudio] = nil;
        }
    }
    
    if(!self.showTopBar){
        publisherOptions[ANDisableTopBar] = [NSNumber numberWithBool:YES];
    }
    
    if(publisherOptions.count > 0){
        [self.optionsDictionary setObject:publisherOptions forKey:ANVideoOptions];
    }
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self.optionsDictionary options:0 error:&err];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}


-(NSString *) fetchInStreamVideoSettings{
    [self.optionsDictionary setValue:ANInstreamVideo forKey:ANEntry];
    return [self videoPlayerOptions];
}

-(NSString *) fetchBannerSettings{
    [self.optionsDictionary setValue:ANBanner forKey:ANEntry];
    
    return [self videoPlayerOptions];
}

@end
