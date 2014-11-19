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

#import "ANAdConstants.h"
#import "ANTargetingParameters.h"
#import "ANNativeMediatedAdResponse.h"

@protocol ANNativeCustomAdapterRequestDelegate;
@protocol ANNativeCustomAdapterAdDelegate;

/*!
 * Defines a protocol by which an external native ad SDK can be mediated by AppNexus.
 */
@protocol ANNativeCustomAdapter <NSObject>

@required
/*!
 * Allows the AppNexus SDK to be notified of a successful or failed request load.
 */
@property (nonatomic, readwrite, weak) id<ANNativeCustomAdapterRequestDelegate> requestDelegate;
/*!
 * Allows the AppNexus SDK to be notified of actions performed on the native view.
 */
@property (nonatomic, readwrite, weak) id<ANNativeCustomAdapterAdDelegate> nativeAdDelegate;

/*!
 * @return YES if the response is no longer valid, for example, if too much time has elapsed
 * since receiving it. NO if the response is still valid.
 */
@property (nonatomic, readwrite, assign, getter=hasExpired) BOOL expired;

/*! 
 * Will be called by the AppNexus SDK when a mediated native ad request should be initiated.
 */
- (void)requestNativeAdWithServerParameter:(NSString *)parameterString
                                  adUnitId:(NSString *)adUnitId
                       targetingParameters:(ANTargetingParameters *)targetingParameters;

@optional
/*!
 * Should be implemented if the mediated SDK handles both impression tracking and click tracking automatically.
 */
- (void)registerViewForImpressionTrackingAndClickHandling:(UIView *)view
                                   withRootViewController:(UIViewController *)rvc
                                           clickableViews:(NSArray *)clickableViews;

/*!
 * Should be implemented if the mediated SDK handles only impression tracking automatically, and needs to
 * be manually notified that a user click has been detected.
 *
 * @note handleClickFromRootViewController: should be implemented as well.
 */
- (void)registerViewForImpressionTracking:(UIView *)view;

/*!
 * Should notify the mediated SDK that a click was registered, and that a click-through should be
 * action should be performed.
 */
- (void)handleClickFromRootViewController:(UIViewController *)rvc;

/*!
 * Should notify the mediated SDK that the native view should no longer be tracked.
 */
- (void)unregisterViewFromTracking;

@end

/*!
 * Callbacks for when the native ad assets are being loaded.
 */
@protocol ANNativeCustomAdapterRequestDelegate <NSObject>

@required
- (void)didLoadNativeAd:(ANNativeMediatedAdResponse *)response;
- (void)didFailToLoadNativeAd:(ANAdResponseCode)errorCode;

@end

/*!
 * Callbacks for when the native view has been registered and is being tracked.
 */
@protocol ANNativeCustomAdapterAdDelegate <NSObject>

@required
- (void)adWasClicked;
- (void)willPresentAd;
- (void)didPresentAd;
- (void)willCloseAd;
- (void)didCloseAd;
- (void)willLeaveApplication;

@end