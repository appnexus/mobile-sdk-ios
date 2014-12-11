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

#import "ANNativeAdResponse.h"

@interface ANNativeAdResponse (PrivateMethods)

@property (nonatomic, readonly, weak) UIViewController *rootViewController;
@property (nonatomic, readonly, strong) UIView *viewForTracking;

#pragma mark - Registration

- (BOOL)registerResponseInstanceWithNativeView:(UIView *)view
                            rootViewController:(UIViewController *)controller
                                clickableViews:(NSArray *)clickableViews
                                         error:(NSError *__autoreleasing*)error;

#pragma mark - Unregistration

- (void)unregisterViewFromTracking;

#pragma mark - Click handling

- (void)attachGestureRecognizersToNativeView:(UIView *)nativeView
                          withClickableViews:(NSArray *)clickableViews;
- (void)handleClick;

#pragma mark - ANNativeAdDelegate / ANNativeCustomAdapterAdDelegate

- (void)adWasClicked;
- (void)willPresentAd;
- (void)didPresentAd;
- (void)willCloseAd;
- (void)didCloseAd;
- (void)willLeaveApplication;

@end