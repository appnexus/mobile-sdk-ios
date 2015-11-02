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
#import "ANBrowserViewController.h"


@interface ANVideoPlayerViewController ()<ANCircularAnimationViewDelegate, ANVolumeButtonViewDelegate, UIGestureRecognizerDelegate, ANBrowserViewControllerDelegate>{
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
@property (nonatomic, strong) ANBrowserViewController *browserController;
@end

@implementation ANVideoPlayerViewController

- (instancetype)initWithVastDataModel:(ANVast *)vastDataModel{
    
    self = [super init];
    
    if (self) {
        self.vastDataModel = vastDataModel;
        _fileURL = self.vastDataModel.mediaFileURL;
        ANLogDebug(@"Playing Media File URL %@", _fileURL);
        _openClicksInNativeBrowser = NO;
        _skipOffSet = 10.0;
        _skipOffSetType = ANCloseDelayTypeAbsolute;
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

- (NSString *) getClickThroughURL{
    ANInLine *inLine = (self.vastDataModel.anInLine)?self.vastDataModel.anInLine:self.vastDataModel.anWrapper;
    if (inLine) {
        for (ANCreative *creative in inLine.creatives) {
            if (creative) {
                if (creative.anLinear.anVideoClicks) {
                    if (creative.anLinear.anVideoClicks.clickThrough) {
                        return creative.anLinear.anVideoClicks.clickThrough;
                    }
                }
            }
        }
    }
    
    return nil;
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
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapOnPlayerViewWithGestureRecognizer:)];
    singleFingerTap.delegate = self;
    [playerView addGestureRecognizer:singleFingerTap];
}

- (void) handleSingleTapOnPlayerViewWithGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer{
    NSURL *clickURL = [NSURL URLWithString:[self getClickThroughURL]];
    if (clickURL) {
        [self openClickInBrowserWithURL:clickURL];
        [self fireClickTracking];
    }else{
        ANLogDebug(@"Click URL not found. Ensure clickthrough URL is available in the Vast Tag");
    }
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
    
    [self registerForApplicaitonNotifications];

}

- (void)viewDidUnload{
    [self removeApplicationNotifications];
}

- (void) registerForApplicaitonNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void) removeApplicationNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void) applicationWillEnterForeground{
    [self play];
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
        [self fireTrackingEventWithEvent:ANVideoEventStart];
        
        //send video start event tracking
    }else if(currentDuration > 0){
        if(currentDuration > previousDuration){
            previousDuration = currentDuration;
            if (currentDuration > quartileDuration && !isFirstQuartileDone) {
                isFirstQuartileDone = YES;
                ANLogDebug(@"First Quartile");
                [self fireTrackingEventWithEvent:ANVideoEventQuartileFirst];
                
                //send first quartile event tracking
            }else if(currentDuration > quartileDuration*2 && !isMidPointQuartileDone){
                isMidPointQuartileDone = YES;
                ANLogDebug(@"Mid Point");
                [self fireTrackingEventWithEvent:ANVideoEventQuartileMidPoint];
                
                //send mid quartile event tracking
            }else if(currentDuration > quartileDuration * 3 && !isThirdQuartileDone){
                isThirdQuartileDone = YES;
                ANLogDebug(@"Third Quartile");
                [self fireTrackingEventWithEvent:ANVideoEventQuartileThird];
                
                //send third quartile event tracking
            }
        }
        
        if(currentDuration == totalDuration){
            isCompleteQuartileDone = YES;
            ANLogDebug(@"Complete Quartile");
            [self fireTrackingEventWithEvent:ANVideoEventQuartileComplete];
            
            //send quartile complete event tracking
        }
    }
}

- (void)closeInterstitial{
    [self pause];
    [self dismissViewControllerAnimated:YES completion:^{
        [self fireTrackingEventWithEvent:ANVideoEventClose];
        [self fireTrackingEventWithEvent:ANVideoEventCloseLinear];
        [self removeApplicationNotifications];
    }];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)play{
    [self.playerView.player play];
    
    if (CMTimeGetSeconds(self.playerView.player.currentTime) > 0) {
        [self fireTrackingEventWithEvent:ANVideoEventResume];
    }
}

- (void)pause{
    [self.playerView.player pause];
    
    [self fireTrackingEventWithEvent:ANVideoEventPause];
}

- (void)mute:(BOOL)value{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    
    float volume = 1.0;

    if ([session setActive:YES error:&error]) {
        volume = session.outputVolume;
    }else{
        ANLogInfo(@"Unable to get system volume.");
    }
    
    if (value) {
        [self.playerView.player setVolume:0];
        ANLogDebug(@"Volume Muted.");
        [self fireTrackingEventWithEvent:ANVideoEventMute];
        
        //send mute event tracking
    }else{
        [self.playerView.player setVolume:volume];
        ANLogDebug(@"Volume Unmuted.");
        [self fireTrackingEventWithEvent:ANVideoEventUnMute];
        
        //send unmute event tracking
    }
}

- (void)closeButtonClicked{
    [self closeInterstitial];
    [self fireTrackingEventWithEvent:ANVideoEventSkip];
}

- (void) fireTrackingEventWithEvent:(ANVideoEvent)event{
    NSString *eventString = [NSString string];
    switch (event) {
        case ANVideoEventStart:
            eventString = @"start";
            break;
        case ANVideoEventQuartileFirst:
            eventString = @"firstQuartile";
            break;
        case ANVideoEventQuartileMidPoint:
            eventString = @"midpoint";
            break;
        case ANVideoEventQuartileThird:
            eventString = @"thirdQuartile";
            break;
        case ANVideoEventQuartileComplete:
            eventString = @"complete";
            break;
        case ANVideoEventSkip:
            eventString = @"skip";
            break;
        case ANVideoEventMute:
            eventString = @"mute";
            break;
        case ANVideoEventUnMute:
            eventString = @"unmute";
            break;
        case ANVideoEventPause:
            eventString = @"pause";
            break;
        case ANVideoEventResume:
            eventString = @"resume";
            break;
        case ANVideoEventClose:
            eventString = @"close";
            break;
        case ANVideoEventCloseLinear:
            eventString = @"closeLinear";
            break;
        default:
            break;
    }
    
    NSArray *trackingArray = [NSArray array];
    ANInLine *anInline = self.vastDataModel.anInLine?self.vastDataModel.anInLine:self.vastDataModel.anWrapper;
    for (ANCreative *creative in anInline.creatives) {
        if (creative) {
            if (creative.anLinear) {
                if (creative.anLinear.trackingEvents.count > 0) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vastEvent == %@", eventString];
                    trackingArray = [creative.anLinear.trackingEvents filteredArrayUsingPredicate:predicate];
                    
                    for (ANTracking *tracking in trackingArray) {
                        [self fireImpressionWithURL:tracking.trackingURI forEvent:eventString];
                    }
                }
            }
        }
    }
}

- (void) fireClickTracking{
    ANInLine *anInline = self.vastDataModel.anInLine?self.vastDataModel.anInLine:self.vastDataModel.anWrapper;
    if (anInline) {
        for (ANCreative *creative in anInline.creatives) {
            if (creative) {
                if (creative.anLinear.anVideoClicks) {
                    NSString *clickTrackingURL = creative.anLinear.anVideoClicks.clickTracking;
                    [self fireImpressionWithURL:clickTrackingURL forEvent:@"click"];
                }
            }
        }
    }
}

- (void) fireImpressionWithURL:(NSString *)urlString forEvent:(NSString *)eventString{
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [NSURLConnection sendAsynchronousRequest:requestURL queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        ANLogDebug(@"Impression Fired: Event=%@, URL: %@", eventString, [[requestURL URL] absoluteString]);
    }];
}

- (void)dealloc{
    
    _fileURL = nil;
    _volumeView = nil;
    _playerView = nil;
    _circularAnimationView = nil;
    _browserController = nil;
    
}

- (void)openClickInBrowserWithURL:(NSURL *)url{
    
    if (!self.openClicksInNativeBrowser) {
        _browserController = [[ANBrowserViewController alloc] initWithURL:url delegate:self delayPresentationForLoad:NO];
        
        if (!self.browserController) {
            NSLog(@"Failed to initialize the browser.");
        }
    }else{
        [self pause];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - ANBrowserViewControllerDelegate

- (UIViewController *)rootViewControllerForDisplayingBrowserViewController:(ANBrowserViewController *)controller{
    UIViewController *rootViewController = [[self presentationController] presentedViewController];
    
    return rootViewController;
}

- (void)didDismissBrowserViewController:(ANBrowserViewController *)controller{
    //play the video
    [self play];
}

@end
