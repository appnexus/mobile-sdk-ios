/* Copyright 2015 APPNEXUS INC
 
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


#import "ANVideoPlayerViewController.h"
#import "ANAdConstants.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ANPlayerView.h"
#import "ANVolumeButtonView.h"
#import "ANLogging.h"
#import "ANGlobal.h"
#import <math.h>
#import "ANCircularAnimationView.h"


@interface ANVideoPlayerViewController ()<ANCircularAnimationViewDelegate, ANVolumeButtonViewDelegate>{
    float previousDuration;
    BOOL isStarted;
    BOOL isFirstQuartileDone;
    BOOL isMidPointQuartileDone;
    BOOL isThirdQuartileDone;
    BOOL isCompleteQuartileDone;
}

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) ANPlayerView *playerView;
@property (nonatomic, strong) ANVolumeButtonView *volumeView;
@property (nonatomic, strong) ANCircularAnimationView *circularAnimationView;

@end

@implementation ANVideoPlayerViewController

- (instancetype)initWithVastDataModel:(ANVast *)vastDataModel{
    
    self = [super init];
    
    if (self) {
        self.vastDataModel = vastDataModel;
        _fileURL = [self.vastDataModel getMediaFileURL];
    }

    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self play];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self pause];
}

- (void) setupVolumeView{
    _volumeView = [[ANVolumeButtonView alloc] initWithDelegate:self];
    [self.volumeView addVolumeViewWithContainer:self.playerView];
}

- (float) getSkipOffSetFromVastDataModel{
    ANInLine *inLine = (self.vastDataModel.anInLine)?self.vastDataModel.anInLine:self.vastDataModel.anWrapper;
    
    float skipOffSet = 0.0;

    for (ANCreative *creative in inLine.creatives) {
        if(creative.anLinear.skipOffSet.length > 0){
            NSArray *timeComponents = [creative.anLinear.skipOffSet componentsSeparatedByString:@":"];
            skipOffSet = [[timeComponents lastObject] floatValue];
        }
    }
    
    if (!skipOffSet) {
        if (self.skipOffSet) {
            int iDuration = (int)CMTimeGetSeconds(self.playerView.player.currentItem.asset.duration);
            if (self.skipOffSetType == ANCloseDelayTypeRelative) {
                int skipOffsetTime = MIN(100, MAX(0, (int)self.skipOffSet));
                float percent = (float)skipOffsetTime/100.0;
                float calculatedTime = iDuration*percent;
                skipOffSet = calculatedTime;
            }else if(self.skipOffSetType == ANCloseDelayTypeAbsolute){
                skipOffSet = MIN(MAX(0, (int)self.skipOffSet), iDuration);
            }
        }
    }
    
    return skipOffSet;
}

- (void) setupPlayer{
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.fileURL];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    
    self.playerView = [[ANPlayerView alloc] init];
    [self.playerView setPlayer:player];
    [self.playerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
    
    UIView *selfView = self.view;
    UIView *playerView = self.playerView;
    
    [playerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [selfView addSubview:self.playerView];
    
    [selfView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[playerView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(playerView)]];
    [selfView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[playerView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(playerView)]];
}

- (void) setupCircularView{
    _circularAnimationView = [[ANCircularAnimationView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.circularAnimationView.delegate = self;
    
    UIView *selfView = self.view;
    UIView *circularView = self.circularAnimationView;
    
    [circularView setTranslatesAutoresizingMaskIntoConstraints:NO];

    [selfView addSubview:circularView];
    
    [selfView bringSubviewToFront:circularView];
    
    [selfView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[circularView(==40)]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(circularView)]];
    [selfView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[circularView(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(circularView)]];
    
    float skipOffSet = [self getSkipOffSetFromVastDataModel];
    
    self.circularAnimationView.skipOffset = skipOffSet;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupPlayer];
    [self setupCircularView];
    [self setupVolumeView];

    __weak typeof(self) SELF = self;
    
    [self.playerView.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 100) queue:nil usingBlock:^(CMTime time) {
        [SELF updateEventsWithSeconds:CMTimeGetSeconds(time)]; //Fire every 0.01 seconds
    }];

}

- (void) updateEventsWithSeconds:(float) seconds{
    
    float totalDuration = CMTimeGetSeconds([self.playerView.player.currentItem.asset duration]);
    float currentDuration = seconds;
    
    float quartileDuration = totalDuration/4;

    if (self.playerView.player.rate > 0 && !self.playerView.player.error) {
        [self.circularAnimationView performCircularAnimationWithStartTime:[NSDate date]];
    }

    if (currentDuration > 0 && !isStarted) {
        isStarted = YES;
        ANLogDebug(@"Started");
        
        //send video start event tracking
    }else if(currentDuration > 0){
        if(currentDuration > previousDuration){
            previousDuration = currentDuration;
            if (currentDuration > quartileDuration && !isFirstQuartileDone) {
                isFirstQuartileDone = YES;
                ANLogDebug(@"First Quartile");
                
                //send first quartile event tracking
            }else if(currentDuration > quartileDuration*2 && !isMidPointQuartileDone){
                isMidPointQuartileDone = YES;
                ANLogDebug(@"Mid Point");
                
                //send mid quartile event tracking
            }else if(currentDuration > quartileDuration * 3 && !isThirdQuartileDone){
                isThirdQuartileDone = YES;
                ANLogDebug(@"Third Quartile");
                
                //send third quartile event tracking
            }
        }else if(currentDuration == totalDuration){
            isCompleteQuartileDone = YES;
            ANLogDebug(@"Complete Quartile");
            
            //send quartile complete event tracking
        }
    }
}

- (void)closeInterstitial{
    [self pause];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)play{
    [self.playerView.player play];
}

- (void)pause{
    [self.playerView.player pause];
}

- (void)mute:(BOOL)value{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = [[NSError alloc] init];
    
    float volume = 1.0;

    if ([session setActive:YES error:&error]) {
        volume = session.outputVolume;
    }else{
        ANLogInfo(@"Unable to get system volume.");
    }
    
    if (value) {
        [self.playerView.player setVolume:0];
        ANLogDebug(@"Volume Muted.");
        
        //send mute event tracking
    }else{
        [self.playerView.player setVolume:volume];
        ANLogDebug(@"Volume Unmuted.");
        
        //send unmute event tracking
    }
}

- (void)closeButtonClicked{
    [self closeInterstitial];
}

- (void)dealloc{
    
    _fileURL = nil;
    _volumeView = nil;
    _playerView = nil;
    _circularAnimationView = nil;
    
}


@end
