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

#import "ANAdView.h"

@protocol ANBrowserViewControllerDelegate;
@protocol ANAdFetcherDelegate;

@class ANAdFetcher;

@interface ANAdView (PrivateMethods)

@property (nonatomic, readwrite, strong) ANAdFetcher *adFetcher;
@property (nonatomic, readwrite, strong) ANMRAIDViewController *mraidController;
@property (nonatomic, readwrite, strong) ANBrowserViewController *browserViewController;
@property (nonatomic, readwrite, strong) UIButton *closeButton;
@property (nonatomic, readwrite, assign) CGRect defaultParentFrame;
@property (nonatomic, readwrite, assign) CGRect defaultFrame;
@property (nonatomic, readwrite, assign) CGPoint resizeOffset;
@property (nonatomic, readwrite, assign) BOOL adjustFramesInResizeState;

- (void)initialize;
- (void)loadAd;
- (void)adDidReceiveAd;
- (void)adRequestFailedWithError:(NSError *)error;
- (void)mraidExpandAd:(CGSize)size
          contentView:(UIView *)contentView
    defaultParentView:(UIView *)defaultParentView
   rootViewController:(UIViewController *)rootViewController;
- (void)mraidExpandAddCloseButton:(UIButton *)closeButton
                    containerView:(UIView *)containerView;
- (NSString *)mraidResizeAd:(CGRect)frame
                contentView:(UIView *)contentView
          defaultParentView:(UIView *)defaultParentView
         rootViewController:(UIViewController *)rootViewController
             allowOffscreen:(BOOL)allowOffscreen;
- (void)mraidResizeAddCloseEventRegion:(UIButton *)closeEventRegion
                         containerView:(UIView *)containerView
                           contentView:(UIView *)contentView
                              position:(ANMRAIDCustomClosePosition)position;
- (void)adShouldResetToDefault:(UIView *)contentView
                    parentView:(UIView *)parentView;

- (void)loadAdFromHtml:(NSString *)html
                 width:(int)width height:(int)height;
- (void)removeCloseButton;

#pragma mark - ANMRAIDAdViewDelegate

@property (nonatomic, readwrite, weak) id<ANMRAIDEventReceiver> mraidEventReceiverDelegate;

#pragma mark - ANAdDelegate

- (void)adWasClicked;
- (void)adWillClose;
- (void)adDidClose;
- (void)adWillPresent;
- (void)adDidPresent;
- (void)adWillLeaveApplication;
- (void)adFailedToDisplay;

#pragma mark - ANBrowserViewControllerDelegate

- (UIViewController *)rootViewControllerForDisplayingBrowserViewController:(ANBrowserViewController *)controller;

- (void)didDismissBrowserViewController:(ANBrowserViewController *)controller;
- (void)willLeaveApplicationFromBrowserViewController:(ANBrowserViewController *)controller;
- (void)browserViewController:(ANBrowserViewController *)controller browserIsLoading:(BOOL)isLoading;

@end