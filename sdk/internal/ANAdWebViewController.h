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
#import <WebKit/WebKit.h>

#import "ANAdViewInternalDelegate.h"
#import "ANMRAIDUtil.h"




@class ANAdWebViewControllerConfiguration;
@class ANMRAIDExpandProperties;
@class ANMRAIDResizeProperties;
@class ANMRAIDOrientationProperties;

@protocol ANAdWebViewControllerANJAMDelegate;
@protocol ANAdWebViewControllerBrowserDelegate;
@protocol ANAdWebViewControllerLoadingDelegate;
@protocol ANAdWebViewControllerMRAIDDelegate;
@protocol ANAdWebViewControllerPitbullDelegate;
@protocol ANAdWebViewControllerVideoDelegate;



@interface ANAdWebViewController : NSObject

@property (nonatomic, readonly, assign)  BOOL         isMRAID;
@property (nonatomic, readonly, strong)  UIView      *contentView;
@property (nonatomic, readonly, assign)  BOOL         completedFirstLoad;

@property (nonatomic, readonly, strong)  ANAdWebViewControllerConfiguration  *configuration;

@property (nonatomic, readwrite, weak)  id<ANAdViewInternalDelegate>  adViewANJAMDelegate;
@property (nonatomic, readwrite, weak)  id<ANAdViewInternalDelegate>  adViewDelegate;

@property (nonatomic, readwrite, weak)  id<ANAdWebViewControllerANJAMDelegate>      anjamDelegate;
@property (nonatomic, readwrite, weak)  id<ANAdWebViewControllerBrowserDelegate>    browserDelegate;
@property (nonatomic, readwrite, weak)  id<ANAdWebViewControllerLoadingDelegate>    loadingDelegate;
@property (nonatomic, readwrite, weak)  id<ANAdWebViewControllerMRAIDDelegate>      mraidDelegate;
@property (nonatomic, readwrite, weak)  id<ANAdWebViewControllerPitbullDelegate>    pitbullDelegate;
@property (nonatomic, readwrite, weak)  id<ANAdWebViewControllerVideoDelegate>      videoDelegate;

@property (nonatomic, readwrite, assign)  NSTimeInterval  checkViewableTimeInterval;


- (instancetype)initWithSize:(CGSize)size
                         URL:(NSURL *)URL
              webViewBaseURL:(NSURL *)baseURL;

- (instancetype)initWithSize:(CGSize)size
                         URL:(NSURL *)URL
              webViewBaseURL:(NSURL *)baseURL
               configuration:(ANAdWebViewControllerConfiguration *)configuration;

- (instancetype)initWithSize:(CGSize)size
                        HTML:(NSString *)html
              webViewBaseURL:(NSURL *)baseURL;

- (instancetype)initWithSize:(CGSize)size
                        HTML:(NSString *)html
              webViewBaseURL:(NSURL *)baseURL
               configuration:(ANAdWebViewControllerConfiguration *)configuration;

- (instancetype) initWithSize: (CGSize)size
                     videoXML: (NSString *)videoXML;


- (void)adDidFinishExpand;
- (void)adDidFinishResize:(BOOL)success
              errorString:(NSString *)errorString
                isResized:(BOOL)isResized;
- (void)adDidResetToDefault;
- (void)adDidHide;
- (void)adDidFailCalendarEditWithErrorString:(NSString *)errorString;
- (void)adDidFailPhotoSaveWithErrorString:(NSString *)errorString;

- (void)fireJavaScript:(NSString *)javascript;


@end




@interface ANAdWebViewControllerConfiguration : NSObject <NSCopying>

@property (nonatomic, readwrite, assign)  BOOL          scrollingEnabled;
@property (nonatomic, readwrite, assign)  BOOL          navigationTriggersDefaultBrowser;
@property (nonatomic, readwrite, assign)  ANMRAIDState  initialMRAIDState;
@property (nonatomic, readwrite, assign)  BOOL          userSelectionEnabled;

@end



#pragma mark - Protocol definitions.

@protocol ANAdWebViewControllerANJAMDelegate <NSObject>

- (void)handleANJAMURL:(NSURL *)URL;

@end


@protocol ANAdWebViewControllerBrowserDelegate <NSObject>

- (void)openDefaultBrowserWithURL:(NSURL *)URL;
- (void)openInAppBrowserWithURL:(NSURL *)URL;

@end


// NB  This delegate is used unconventionally as a means to call back through two class compositions:
//     ANAdWebViewController calls ANMRAIDContainerView calls ANUniversalAdFetcher.
//
@protocol ANAdWebViewControllerLoadingDelegate <NSObject>

@required
- (void) didCompleteFirstLoadFromWebViewController:(ANAdWebViewController *)controller;

@optional
- (void) immediatelyRestartAutoRefreshTimerFromWebViewController:(ANAdWebViewController *)controller;
- (void) stopAutoRefreshTimerFromWebViewController:(ANAdWebViewController *)controller;

@end


@protocol ANAdWebViewControllerMRAIDDelegate <NSObject>

- (CGRect)defaultPosition;
- (CGRect)currentPosition;
- (BOOL)isViewable;
- (CGRect)visibleRect;
- (CGFloat)exposedPercent;

- (void)adShouldExpandWithExpandProperties:(ANMRAIDExpandProperties *)expandProperties;
- (void)adShouldAttemptResizeWithResizeProperties:(ANMRAIDResizeProperties *)resizeProperties;
- (void)adShouldSetOrientationProperties:(ANMRAIDOrientationProperties *)orientationProperties;
- (void)adShouldSetUseCustomClose:(BOOL)useCustomClose;
- (void)adShouldClose;

- (void)adShouldOpenCalendarWithCalendarDict:(NSDictionary *)calendarDict;
- (void)adShouldSavePictureWithUri:(NSString *)uri;
- (void)adShouldPlayVideoWithUri:(NSString *)uri;

@end


@protocol ANAdWebViewControllerPitbullDelegate <NSObject>

- (void)handlePitbullURL:(NSURL *)URL;

@end


@protocol ANAdWebViewControllerVideoDelegate <NSObject>

-(void) videoAdReady;
-(void) videoAdLoadFailed:(NSError *)error;
- (void) videoAdError:(NSError *)error;

- (void) videoAdPlayerFullScreenEntered: (ANAdWebViewController *)videoAd;
- (void) videoAdPlayerFullScreenExited: (ANAdWebViewController *)videoAd;


@end

