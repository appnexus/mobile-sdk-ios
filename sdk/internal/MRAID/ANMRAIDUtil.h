/*   Copyright 2014 APPNEXUS INC
 
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

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

typedef NS_ENUM(NSUInteger, ANMRAIDOrientation) {
    ANMRAIDOrientationPortrait,
    ANMRAIDOrientationLandscape,
    ANMRAIDOrientationNone
};

typedef NS_ENUM(NSUInteger, ANMRAIDCustomClosePosition) {
    ANMRAIDCustomClosePositionUnknown,
    ANMRAIDCustomClosePositionTopLeft,
    ANMRAIDCustomClosePositionTopCenter,
    ANMRAIDCustomClosePositionTopRight,
    ANMRAIDCustomClosePositionCenter,
    ANMRAIDCustomClosePositionBottomLeft,
    ANMRAIDCustomClosePositionBottomCenter,
    ANMRAIDCustomClosePositionBottomRight
};

typedef NS_ENUM(NSUInteger, ANMRAIDState) {
    ANMRAIDStateUnknown,
    ANMRAIDStateLoading,
    ANMRAIDStateDefault,
    ANMRAIDStateExpanded,
    ANMRAIDStateHidden,
    ANMRAIDStateResized
};

typedef NS_ENUM(NSUInteger, ANMRAIDAction) {
    ANMRAIDActionUnknown,
    ANMRAIDActionExpand,
    ANMRAIDActionClose,
    ANMRAIDActionResize,
    ANMRAIDActionCreateCalendarEvent,
    ANMRAIDActionPlayVideo,
    ANMRAIDActionStorePicture,
    ANMRAIDActionSetOrientationProperties,
    ANMRAIDActionSetUseCustomClose,
    ANMRAIDActionOpenURI,
    ANMRAIDActionEnable
};

@interface ANMRAIDUtil : NSObject

+ (BOOL)supportsSMS;
+ (BOOL)supportsTel;
+ (BOOL)supportsCalendar;
+ (BOOL)supportsInlineVideo;
+ (BOOL)supportsStorePicture;

+ (CGSize)maxSize;
+ (CGSize)screenSize;

+ (void)playVideoWithUri:(NSString *)uri
  fromRootViewController:(UIViewController *)rootViewController
    withCompletionTarget:(id)target
      completionSelector:(SEL)selector;
+ (void)storePictureWithUri:(NSString *)uri
       withCompletionTarget:(id)target
         completionSelector:(SEL)selector;

+ (ANMRAIDAction)actionForCommand:(NSString *)command;
+ (ANMRAIDCustomClosePosition)customClosePositionFromCustomClosePositionString:(NSString *)customClosePositionString;
+ (ANMRAIDOrientation)orientationFromForceOrientationString:(NSString *)orientationString;

+ (ANMRAIDState)stateFromString:(NSString *)string;
+ (NSString *)stateStringFromState:(ANMRAIDState)state;

@end
