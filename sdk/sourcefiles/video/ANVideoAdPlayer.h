/*   Copyright 2016 APPNEXUS INC
 
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

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#import "ANAdConstants.h"
@import OMSDK_Microsoft;

#import "ANAdResponseInfo.h"



typedef NS_ENUM(NSUInteger, ANVideoAdPlayerTracker) {
    ANVideoAdPlayerTrackerFirstQuartile,
    ANVideoAdPlayerTrackerMidQuartile,
    ANVideoAdPlayerTrackerThirdQuartile,
    ANVideoAdPlayerTrackerFourthQuartile

};

typedef NS_ENUM(NSUInteger, ANVideoAdPlayerEvent) {
    ANVideoAdPlayerEventPlay,
    ANVideoAdPlayerEventSkip,
    ANVideoAdPlayerEventMuteOff,
    ANVideoAdPlayerEventMuteOn
};



@class  ANVideoAdPlayer;


@protocol ANVideoAdPlayerDelegate <NSObject>

-(void) videoAdReady;
-(void) videoAdLoadFailed:(nonnull NSError *)error withAdResponseInfo:(nullable ANAdResponseInfo *)adResponseInfo;

@optional

- (void) videoAdError:(nonnull NSError *)error;
- (void) videoAdWillPresent: (nonnull ANVideoAdPlayer *)videoAd;
- (void) videoAdDidPresent:  (nonnull ANVideoAdPlayer *)videoAd;
- (void) videoAdWillClose:   (nonnull ANVideoAdPlayer *)videoAd;
- (void) videoAdDidClose:    (nonnull ANVideoAdPlayer *)videoAd;

- (void) videoAdWillLeaveApplication: (nonnull ANVideoAdPlayer *)videoAd;

- (void) videoAdImpressionListeners:(ANVideoAdPlayerTracker) tracker;
- (void) videoAdEventListeners:(ANVideoAdPlayerEvent) eventTrackers;
- (void) videoAdWasClicked;
- (void) videoAdWasClickedWithURL:(nonnull NSString *)urlString;

- (ANClickThroughAction) videoAdPlayerClickThroughAction;
- (BOOL) videoAdPlayerLandingPageLoadsInBackground;

- (void) videoAdPlayerFullScreenEntered: (nonnull ANVideoAdPlayer *)videoAd;
- (void) videoAdPlayerFullScreenExited: (nonnull ANVideoAdPlayer *)videoAd;


@end




@interface ANVideoAdPlayer : UIView<WKScriptMessageHandler,WKNavigationDelegate, WKUIDelegate>

@property (strong, nonatomic, nullable) id <ANVideoAdPlayerDelegate> delegate;
@property (nonatomic, readwrite, strong, nullable) OMIDMicrosoftAdSession * omidAdSession;

-(void) loadAdWithVastContent:(nonnull NSString *) vastContent;
-(void) loadAdWithVastUrl:(nonnull NSString *) vastUrl;
-(void) loadAdWithJSONContent:(nonnull NSString *) jsonContent;

-(void)playAdWithContainer:(nonnull UIView *) containerView;
-(void) pauseAdVideo;
-(void) resumeAdVideo;
-(void) removePlayer;

- (NSUInteger) getAdDuration;
- (nullable NSString *) getCreativeURL;
- (nullable NSString *) getVASTURL;
- (nullable NSString *) getVASTXML;
- (NSUInteger) getAdPlayElapsedTime;
/**
 * Get the Orientation of the Video rendered using the BannerAdView
 *
 * @return Default VideoOrientation value ANUnknown, which indicates that aspectRatio can't be retrieved for the video.
 */
- (ANVideoOrientation) getVideoOrientation;

- (NSInteger) getVideoWidth;

- (NSInteger) getVideoHeight;

@end

