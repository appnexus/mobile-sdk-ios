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
    - (void)adDidReceiveAd:(nonnull id)ad;

    @optional
    - (void)ad:(nonnull id)ad requestFailedWithError:(nonnull NSError *)error;

@end


@protocol  ANInstreamVideoAdPlayDelegate <NSObject>

    @required

    - (void) adDidComplete:  (nonnull id<ANAdProtocol>)ad
                 withState:  (ANInstreamVideoPlaybackStateType)state;

    @optional
    - (void) adCompletedFirstQuartile:  (nonnull id<ANAdProtocol>)ad;
    - (void) adCompletedMidQuartile:    (nonnull id<ANAdProtocol>)ad;
    - (void) adCompletedThirdQuartile:  (nonnull id<ANAdProtocol>)ad;


    - (void) adMute: (nonnull id<ANAdProtocol>)ad
         withStatus: (BOOL)muteStatus;

    - (void)adWasClicked:(nonnull id<ANAdProtocol>)ad;
    - (void)adWasClicked:(nonnull id<ANAdProtocol>)ad withURL:(nonnull NSString *)urlString;

    - (void)adWillClose:(nonnull id<ANAdProtocol>)ad;
    - (void)adDidClose:(nonnull id<ANAdProtocol>)ad;

    - (void)adWillPresent:(nonnull id<ANAdProtocol>)ad;
    - (void)adDidPresent:(nonnull id<ANAdProtocol>)ad;

    - (void)adWillLeaveApplication:(nonnull id<ANAdProtocol>)ad;

    - (void) adPlayStarted:(nonnull id<ANAdProtocol>)ad;

@end




//---------------------------------------------------------- -o--
@interface ANInstreamVideoAd : ANAdView <ANVideoAdProtocol>

    // Public properties.
    //
    @property  (weak, nonatomic, readwrite, nullable)  id<ANInstreamVideoAdLoadDelegate>  loadDelegate;
    @property  (weak, nonatomic, readonly, nullable)  id<ANInstreamVideoAdPlayDelegate>  playDelegate;

    //
    @property (strong, nonatomic, readonly, nullable)  NSString  *descriptionOfFailure;
    @property (strong, nonatomic, readonly, nullable)  NSError   *failureNSError;

    @property (nonatomic, readonly)  BOOL  didUserSkipAd;
    @property (nonatomic, readonly)  BOOL  didUserClickAd;
    @property (nonatomic, readonly)  BOOL  isAdMuted;
    @property (nonatomic, readonly)  BOOL  isVideoTagReady;
    @property (nonatomic, readonly)  BOOL  didVideoTagFail;


    // Lifecycle methods.
    //
    - (nonnull instancetype) initWithPlacementId: (nonnull NSString *)placementId;
    - (nonnull instancetype) initWithMemberId:(NSInteger)memberId inventoryCode:(nonnull NSString *)inventoryCode;

    - (BOOL) loadAdWithDelegate: (nullable id<ANInstreamVideoAdLoadDelegate>)loadDelegate;

    - (void) playAdWithContainer: (nonnull UIView *)adContainer
                    withDelegate: (nullable id<ANInstreamVideoAdPlayDelegate>)playDelegate;
    
    - (void) pauseAd;
    
    - (void) resumeAd;

    - (void) removeAd;

    - (NSUInteger) getAdDuration;
    - (nullable NSString *) getCreativeURL;
    - (nullable NSString *) getVastURL;
    - (nullable NSString *) getVastXML;

    - (NSUInteger) getAdPlayElapsedTime;

@end


