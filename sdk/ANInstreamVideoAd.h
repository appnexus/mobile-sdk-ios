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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "ANAdView.h"
#import "ANAdProtocol.h"




//---------------------------------------------------------- -o--
typedef NS_ENUM(NSInteger, ANInstreamVideoPlaybackStateType)
{
    ANInstreamVideoPlaybackStateError           = -1,
    ANInstreamVideoPlaybackStateCompleted       = 0,
    ANInstreamVideoPlaybackStateSkipped         = 1
};


//---------------------------------------------------------- -o--
@class  ANInstreamVideoAd;


@protocol  ANInstreamVideoAdLoadDelegate <NSObject>

    @required
    - (void)adDidReceiveAd:(id<ANAdProtocol>)ad;

    @optional
    - (void)ad:(id<ANAdProtocol>)ad requestFailedWithError:(NSError *)error;

@end


@protocol  ANInstreamVideoAdPlayDelegate <NSObject>

    @required

    - (void) adDidComplete:  (id<ANAdProtocol>)ad
                 withState:  (ANInstreamVideoPlaybackStateType)state;

    @optional
    - (void) adCompletedFirstQuartile:  (id<ANAdProtocol>)ad;
    - (void) adCompletedMidQuartile:    (id<ANAdProtocol>)ad;
    - (void) adCompletedThirdQuartile:  (id<ANAdProtocol>)ad;


    - (void) adMute: (id<ANAdProtocol>)ad
         withStatus: (BOOL)muteStatus;

    - (void)adWasClicked:(id<ANAdProtocol>)ad;


    - (void)adWillClose:(id<ANAdProtocol>)ad;
    - (void)adDidClose:(id<ANAdProtocol>)ad;

    - (void)adWillPresent:(id<ANAdProtocol>)ad;
    - (void)adDidPresent:(id<ANAdProtocol>)ad;

    - (void)adWillLeaveApplication:(id<ANAdProtocol>)ad;

    - (void) adPlayStarted : (id<ANAdProtocol>)ad;

@end




//---------------------------------------------------------- -o--
@interface ANInstreamVideoAd : ANAdView <ANVideoAdProtocol>

    // Public properties.
    //
    @property  (weak, nonatomic, readonly)  id<ANInstreamVideoAdLoadDelegate>  loadDelegate;
    @property  (weak, nonatomic, readonly)  id<ANInstreamVideoAdPlayDelegate>  playDelegate;

    //
    @property (strong, nonatomic, readonly)  NSString  *descriptionOfFailure;
    @property (strong, nonatomic, readonly)  NSError   *failureNSError;

    @property (nonatomic, readonly)  BOOL  didUserSkipAd;
    @property (nonatomic, readonly)  BOOL  didUserClickAd;
    @property (nonatomic, readonly)  BOOL  isAdMuted;
    @property (nonatomic, readonly)  BOOL  isVideoTagReady;
    @property (nonatomic, readonly)  BOOL  didVideoTagFail;


    // Lifecycle methods.
    //
    - (instancetype) initWithPlacementId: (NSString *)placementId;

    - (BOOL) loadAdWithDelegate: (id<ANInstreamVideoAdLoadDelegate>)loadDelegate;

    - (void) playAdWithContainer: (UIView *)adContainer
                    withDelegate: (id<ANInstreamVideoAdPlayDelegate>)playDelegate;

    - (void) removeAd;

    - (NSUInteger) getAdDuration;
    - (NSString *) getCreativeURL;
    - (NSString *) getVastURL;
    - (NSString *) getVastXML;

    - (NSUInteger) getAdPlayElapsedTime;

@end


