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

#import "ANVASTUtil.h"
#import "ANVAST+ANCategory.h"
#import "UIView+ANCategory.h"

static float const kANVideoPlayerViewControllerVolumeMuteOnValue = 0.0;
static float const kANVideoPlayerViewControllerVolumeMuteOffValue = 1.0;

static BOOL const kANVideoPlayerViewControllerDoMuteOnLoad = YES;

@interface ANVideoPlayerViewController ()<ANCircularAnimationViewDelegate, ANVolumeButtonViewDelegate,
UIGestureRecognizerDelegate, ANBrowserViewControllerDelegate> {
    float previousDuration;
    BOOL isSkipped;
    BOOL creativeView;
    BOOL isStarted;
    BOOL isFirstQuartileDone;
    BOOL isMidPointQuartileDone;
    BOOL isThirdQuartileDone;
    BOOL isCompleteQuartileDone;
    BOOL isImpressionFired;
}

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) ANPlayerView *playerView;
@property (nonatomic, strong) ANVolumeButtonView *volumeView;
@property (nonatomic, strong) ANCircularAnimationView *circularAnimationView;
@property (nonatomic, strong) ANBrowserViewController *browserController;
@property (nonatomic, strong) id observer;

@end

@implementation ANVideoPlayerViewController

- (instancetype)initWithVastDataModel:(ANVast *)vastDataModel{
    
    self = [super init];
    
    if (self) {
        _vastDataModel = vastDataModel;
        _fileURL = self.vastDataModel.mediaFileURL;
        ANLogDebug(@"Playing Media File URL %@", _fileURL);
        _publisherSkipOffset = 5.0;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];

    [self setupPlayer];
    [self setupCircularView];
    [self setupVolumeView];
    
    [self registerForApplicationNotifications];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!creativeView) {
        creativeView = YES;
        [self fireTrackingEventWithEvent:ANVideoEventCreativeView];
    }
    __weak typeof(self) weakSelf = self;
    
    self.observer = [self.playerView.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 100)
                                                                         queue:nil
                                                                    usingBlock:^(CMTime time) {
                                                        [weakSelf updateEventsWithSeconds:CMTimeGetSeconds(time)];
                                                    }];
    [self play];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.playerView.player removeTimeObserver:self.observer];
    if (!isSkipped) {
        [self pause];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Setup

- (void)setupPlayer {
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.fileURL];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    player.volume = kANVideoPlayerViewControllerDoMuteOnLoad ?
            kANVideoPlayerViewControllerVolumeMuteOnValue : kANVideoPlayerViewControllerVolumeMuteOffValue;
    
    self.playerView = [[ANPlayerView alloc] init];
    [self.playerView setPlayer:player];
    [self.playerView setVideoFillMode:AVLayerVideoGravityResizeAspect];
    self.playerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.playerView];
    [self.playerView an_constrainToSizeOfSuperview];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(handleSingleTapOnPlayerViewWithGestureRecognizer:)];
    singleFingerTap.delegate = self;
    [self.playerView addGestureRecognizer:singleFingerTap];
}

- (void)setupCircularView {
    CGSize closeButtonSize = APPNEXUS_INTERSTITIAL_CLOSE_BUTTON_VIEW_SIZE;
    self.circularAnimationView = [[ANCircularAnimationView alloc] initWithFrame:CGRectMake(0, 0, closeButtonSize.width, closeButtonSize.height)];
    self.circularAnimationView.delegate = self;
    self.circularAnimationView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.circularAnimationView];
    [self.view bringSubviewToFront:self.circularAnimationView];
    [self.circularAnimationView an_constrainWithSize:closeButtonSize];
    [self.circularAnimationView an_alignToSuperviewWithXAttribute:NSLayoutAttributeRight
                                                       yAttribute:NSLayoutAttributeTop
                                                          offsetX:-17.0
                                                          offsetY:17.0];
    float skipOffSet = [self skipOffset];
    self.circularAnimationView.skipOffset = skipOffSet;
}

- (void)setupVolumeView {
    self.volumeView = [[ANVolumeButtonView alloc] initWithDelegate:self];
    self.volumeView.isVolumeMuted = kANVideoPlayerViewControllerDoMuteOnLoad;
    self.volumeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.volumeView];
    [self.view bringSubviewToFront:self.volumeView];
    [self.volumeView an_constrainWithSize:CGSizeMake(44,44)];
    [self.volumeView an_alignToSuperviewWithXAttribute:NSLayoutAttributeRight
                                            yAttribute:NSLayoutAttributeBottom
                                               offsetX:-15.0
                                               offsetY:-15.0];
}

- (float)skipOffset {
    float skipOffset = [self.vastDataModel getSkipOffSetFromVastDataModel];
    
    if (!skipOffset && self.publisherSkipOffset) {
        int iDuration = (int)CMTimeGetSeconds(self.playerView.player.currentItem.asset.duration);
        skipOffset = MIN(MAX(0, (int)self.publisherSkipOffset), iDuration);
    }
    
    return skipOffset;
}

- (void)updateEventsWithSeconds:(float)seconds {
    
    float totalDuration = CMTimeGetSeconds([self.playerView.player.currentItem.asset duration]);
    float currentDuration = seconds;
    
    float quartileDuration = totalDuration/4;

    if (self.playerView.player.rate > 0 && !self.playerView.player.error) {
        if (!isImpressionFired) {
            isImpressionFired = YES;
            for (ANImpression *impression in self.vastDataModel.anInLine.impressions) {
            	ANLogDebug(@"(impression, %@)", impression.value);
                [self fireImpressionWithURL:impression.value];
            }
        }
        [self.circularAnimationView performCircularAnimationWithStartTime:[NSDate date]];
    }

    if (currentDuration > 0 && !isStarted) {
        isStarted = YES;
        ANLogDebug(@"Started");
        [self fireTrackingEventWithEvent:ANVideoEventStart];
    } else if(currentDuration > 0){
        if (currentDuration > previousDuration){
            previousDuration = currentDuration;
            if (currentDuration > quartileDuration && !isFirstQuartileDone) {
                isFirstQuartileDone = YES;
                ANLogDebug(@"First Quartile");
                [self fireTrackingEventWithEvent:ANVideoEventQuartileFirst];
            } else if(currentDuration > quartileDuration*2 && !isMidPointQuartileDone){
                isMidPointQuartileDone = YES;
                ANLogDebug(@"Mid Point");
                [self fireTrackingEventWithEvent:ANVideoEventQuartileMidPoint];
            } else if(currentDuration > quartileDuration * 3 && !isThirdQuartileDone){
                isThirdQuartileDone = YES;
                ANLogDebug(@"Third Quartile");
                [self fireTrackingEventWithEvent:ANVideoEventQuartileThird];
            }
        }
        
        if (currentDuration >= totalDuration && !isCompleteQuartileDone){
            isCompleteQuartileDone = YES;
            ANLogDebug(@"Complete Quartile");
            [self fireTrackingEventWithEvent:ANVideoEventQuartileComplete];
        }
    }
}

- (void)closeInterstitial {
    isSkipped = YES;
    if (!isCompleteQuartileDone) {
        [self.playerView.player pause];
        [self fireTrackingEventWithEvent:ANVideoEventSkip];
    }
    [self removeApplicationNotifications];
    [self dismissViewControllerAnimated:YES
                             completion:^{
        [self fireTrackingEventWithEvent:ANVideoEventCloseLinear];
    }];
}

#pragma mark - Player Controls

- (void)play {
    if (!isCompleteQuartileDone) {
        if (isStarted && CMTimeGetSeconds(self.playerView.player.currentTime) > 0) {
            [self fireTrackingEventWithEvent:ANVideoEventResume];
        }
        [self.playerView.player play];
    }
}

- (void)pause {
    if (!isCompleteQuartileDone) {
        [self.playerView.player pause];
        [self fireTrackingEventWithEvent:ANVideoEventPause];
    }
}

- (void)mutePlayer:(BOOL)value {
    if (value) {
        [self.playerView.player setVolume:kANVideoPlayerViewControllerVolumeMuteOnValue];
        ANLogDebug(@"Volume Muted.");
        [self fireTrackingEventWithEvent:ANVideoEventMute];
    } else{
        [self.playerView.player setVolume:kANVideoPlayerViewControllerVolumeMuteOffValue];
        ANLogDebug(@"Volume Unmuted.");
        [self fireTrackingEventWithEvent:ANVideoEventUnMute];
    }
}

- (void)closeButtonClicked {
    [self closeInterstitial];
}

#pragma mark - Tracking

- (void)fireTrackingEventWithEvent:(ANVideoEvent)event {
    NSArray *trackingArray = [self.vastDataModel trackingArrayForEvent:event];
    [trackingArray enumerateObjectsUsingBlock:^(ANTracking *tracking, NSUInteger idx, BOOL *stop) {
        ANLogDebug(@"(%@, %@)", [ANVASTUtil eventStringForVideoEvent:event], tracking.trackingURI);
        [self fireImpressionWithURL:tracking.trackingURI];
    }];
}

- (void)fireClickTracking {
    NSArray *trackingArray = self.vastDataModel.clickTrackingURL;
    [trackingArray enumerateObjectsUsingBlock:^(NSString *clickTrackingURL, NSUInteger idx, BOOL *stop) {
        ANLogDebug(@"(click, %@)", clickTrackingURL);
        [self fireImpressionWithURL:clickTrackingURL];
    }];
}

- (void)fireImpressionWithURL:(NSString *)urlString {
    NSURL *impressionURL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = ANBasicRequestWithURL(impressionURL);
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

    }];
}

#pragma mark - Observe

- (void)registerForApplicationNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)removeApplicationNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

- (void)dealloc {
    [self removeApplicationNotifications];
}

- (void) applicationWillEnterForeground{
    [self play];
}

#pragma mark - ANBrowserViewControllerDelegate

- (void)handleSingleTapOnPlayerViewWithGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer{
    NSURL *clickURL = [NSURL URLWithString:[self.vastDataModel getClickThroughURL]];
    if (clickURL) {
        [self openClickInBrowserWithURL:clickURL];
        [self fireClickTracking];
    }else{
        ANLogDebug(@"Click URL not found.");
    }
}

- (void)openClickInBrowserWithURL:(NSURL *)url {
    if (!self.openClicksInNativeBrowser) {
        _browserController = [[ANBrowserViewController alloc] initWithURL:url
                                                                 delegate:self
                                                 delayPresentationForLoad:NO];
        if (!self.browserController) {
            ANLogDebug(@"Failed to initialize the browser.");
        }
    } else{
        [self pause];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (UIViewController *)rootViewControllerForDisplayingBrowserViewController:(ANBrowserViewController *)controller {
    return self;
}

- (void)didDismissBrowserViewController:(ANBrowserViewController *)controller{
    [self play];
}

@end
