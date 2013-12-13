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
#import <EventKitUI/EventKitUI.h>
#import <UIKit/UIKit.h>

@class ANAdFetcher;

typedef enum _ANMRAIDCustomClosePosition
{
    ANMRAIDTopLeft,
    ANMRAIDTopCenter,
    ANMRAIDTopRight,
    ANMRAIDCenter,
    ANMRAIDBottomLeft,
    ANMRAIDBottomCenter,
    ANMRAIDBottomRight,
} ANMRAIDCustomClosePosition;

@protocol ANMRAIDAdViewDelegate <NSObject>

- (NSString *)adType;
- (void)adShouldResetToDefault;
- (void)adShouldExpandToFrame:(CGRect)frame;
- (void)adShouldResizeToFrame:(CGRect)frame;
- (void)adShouldShowCloseButtonWithTarget:(id)target action:(SEL)action
                                 position:(ANMRAIDCustomClosePosition)position;
- (void)adShouldRemoveCloseButton;

@end

@interface ANAdWebViewController : NSObject <UIWebViewDelegate>

@property (nonatomic, readwrite, weak) ANAdFetcher *adFetcher;
@property (nonatomic, readwrite, strong) UIWebView *webView;

@end

@interface ANMRAIDAdWebViewController : ANAdWebViewController

@property (nonatomic, readwrite, assign) BOOL expanded;
@property (nonatomic, readwrite, strong) id<ANMRAIDAdViewDelegate> mraidDelegate;
@property (nonatomic, readwrite, strong) UIViewController *controller;
@end
