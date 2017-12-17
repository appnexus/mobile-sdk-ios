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
#import "WKWebView+ANCategory.h"

typedef NS_ENUM(NSUInteger, ANVideoAdPlayerTracker) {
    ANVideoAdPlayerTrackerFirstQuartile,
    ANVideoAdPlayerTrackerMidQuartile,
    ANVideoAdPlayerTrackerThirdQuartile,
    ANVideoAdPlayerTrackerFourthQuartile

};

typedef NS_ENUM(NSUInteger, ANVideoAdPlayerEvent) {
    ANVideoAdPlayerEventPlay,
    ANVideoAdPlayerEventClick,
    ANVideoAdPlayerEventSkip,
    ANVideoAdPlayerEventMuteOff,
    ANVideoAdPlayerEventMuteOn
};



@class  ANVideoAdPlayer;

@protocol ANVideoAdPlayerDelegate <NSObject>

-(void) videoAdReady;
-(void) videoAdLoadFailed:(NSError *)error;

@optional

- (void) videoAdError:(NSError *)error;
- (void) videoAdWillPresent: (ANVideoAdPlayer *)videoAd;
- (void) videoAdDidPresent:  (ANVideoAdPlayer *)videoAd;
- (void) videoAdWillClose:   (ANVideoAdPlayer *)videoAd;
- (void) videoAdDidClose:    (ANVideoAdPlayer *)videoAd;

- (void) videoAdWillLeaveApplication: (ANVideoAdPlayer *)videoAd;

- (void) videoAdImpressionListeners:(ANVideoAdPlayerTracker) tracker;
- (void) videoAdEventListeners:(ANVideoAdPlayerEvent) eventTrackers;

- (BOOL) videoAdPlayerLandingPageLoadsInBackground;
- (BOOL) videoAdPlayerOpensInNativeBrowser;

- (void) videoAdPlayerFullScreenEntered: (ANVideoAdPlayer *)videoAd;
- (void) videoAdPlayerFullScreenExited: (ANVideoAdPlayer *)videoAd;

@end




@interface ANVideoAdPlayer : UIView<WKScriptMessageHandler,WKNavigationDelegate, WKUIDelegate>

@property (strong, nonatomic) id <ANVideoAdPlayerDelegate> delegate;

-(void) loadAdWithVastContent:(NSString *) vastContent;
-(void) loadAdWithVastUrl:(NSString *) vastUrl;
-(void) loadAdWithJSONContent:(NSString *) jsonContent;

-(void)playAdWithContainer:(UIView *) containerView;

-(void) removePlayer;

- (NSUInteger) getAdDuration;
- (NSString *) getCreativeURL;
- (NSString *) getVASTURL;
- (NSString *) getVASTXML;

-(NSUInteger) getAdPlayElapsedTime;

@end

