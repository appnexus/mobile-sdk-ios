/*   Copyright 2013 APPNEXUS INC
 
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

typedef NS_ENUM(NSUInteger, ANMRAIDOrientation) {
    ANMRAIDOrientationPortrait,
    ANMRAIDOrientationLandscape,
    ANMRAIDOrientationNone
};

typedef NS_ENUM(NSUInteger, ANMRAIDCustomClosePosition) {
    ANMRAIDTopLeft,
    ANMRAIDTopCenter,
    ANMRAIDTopRight,
    ANMRAIDCenter,
    ANMRAIDBottomLeft,
    ANMRAIDBottomCenter,
    ANMRAIDBottomRight
};

typedef NS_ENUM(NSUInteger, ANMRAIDState) {
    ANMRAIDStateLoading,
    ANMRAIDStateDefault,
    ANMRAIDStateExpanded,
    ANMRAIDStateHidden,
    ANMRAIDStateResized
};

@protocol ANMRAIDEventReceiver <NSObject>

- (void)adDidFinishExpand;
- (void)adDidFinishResize:(BOOL)success errorString:(NSString *)errorString;
- (void)adDidChangeResizeOffset:(CGPoint)offset;
- (void)adDidResetToDefault;

@end

@protocol ANMRAIDAdViewDelegate <NSObject>

@property (nonatomic, readwrite, weak) id<ANMRAIDEventReceiver> mraidEventReceiverDelegate;

- (NSString *)adType;
- (UIViewController *)displayController;
- (void)adShouldResetToDefault;
- (void)adShouldExpandToFrame:(CGRect)frame closeButton:(UIButton *)closeButton;
- (void)adShouldResizeToFrame:(CGRect)frame allowOffscreen:(BOOL)allowOffscreen
                  closeButton:(UIButton *)closeButton
                closePosition:(ANMRAIDCustomClosePosition)closePosition;
- (void)allowOrientationChange:(BOOL)allowOrientationChange
         withForcedOrientation:(ANMRAIDOrientation)orientation;

@end

