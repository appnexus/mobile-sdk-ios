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
#import "ANNativeAdDelegate.h"
#import "ANNativeAdStarRating.h"
#import "ANAdConstants.h"

/*!
 * Contains native ad assets as well as defines the process by which a native view can be registered for impression
 * tracking and click handling.
 *
 * After the response is received as part of the [ANNativeAdRequest delegate] callback, a native view can
 * be created and the native ad elements populated. When the view is ready for display, it should be
 * registered with the response, and a delegate can optionally be attached to the response for callbacks
 * related to actions on the native view. Here is a sample workflow:
 *
 * @code
 * - (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response {
 *      (code which loads the view)
 *      MyDummyView *view;
 *      view.title.text = response.title;
 *      view.text.text = response.body;
 *      view.iconImageView.image = response.iconImage;
 *      view.mainImageView.image = response.mainImage;
 *      [view.callToActionButton setTitle:response.callToAction forState:UIControlStateNormal];
 *
 *      response.delegate = self;
 *
 *      [response registerViewForTracking:view
 *                 withRootViewController:self
 *                         clickableViews:@[view.callToActionButton, view.mainImageView]
 *                                  error:nil];
 * }
 *
 */
@interface ANNativeAdResponse : NSObject

#pragma mark - Native Ad Elements

/*!
 * The ad title.
 */
@property (nonatomic, readonly, strong) NSString *title;

/*!
 * The ad body, also known as the ad text or description.
 */
@property (nonatomic, readonly, strong) NSString *body;

/*!
 * The call to action text, for example, "Install Now!"
 */
@property (nonatomic, readonly, strong) NSString *callToAction;

/*!
 * The star rating of the ad, generally reserved for an app install ad.
 */
@property (nonatomic, readonly, strong) ANNativeAdStarRating *rating;

/*!
 * The social context of the ad, for example, "Available on the AppStore".
 */
@property (nonatomic, readonly, strong) NSString *socialContext;

/*!
 * The ad icon image.
 */
@property (nonatomic, readonly, strong) UIImage *iconImage;

/*!
 * The ad main image, also known as a cover image.
 */
@property (nonatomic, readonly, strong) UIImage *mainImage;

/*!
 * A URL which loads the ad main image.
 */
@property (nonatomic, readonly, strong) NSURL *mainImageURL;

/*!
 * A URL which loads the ad icon image.
 */
@property (nonatomic, readonly, strong) NSURL *iconImageURL;

/*!
 * Contains any non-standard elements. This would include any custom assets requested from 
 * third-party networks as specified in the third-party system.
 */
@property (nonatomic, readonly, strong) NSDictionary *customElements;

/*!
 * The network which supplied this native ad response.
 * @see ANNativeAdNetworkCode in ANAdConstants.h
 */
@property (nonatomic, readonly, assign) ANNativeAdNetworkCode networkCode;

/*!
 * @return YES if the response is no longer valid, for example, if too much time has elapsed
 * since receiving it. NO if the response is still valid.
 */
@property (nonatomic, readonly, assign, getter=hasExpired) BOOL expired;


#pragma mark - Native View Registration

/*!
 * Delegate object that receives callbacks for a native view which has been registered.
 * @see ANNativeAdDelegate
 */
@property (nonatomic, readwrite, weak) id<ANNativeAdDelegate> delegate;

/*!
 * Determines whether the ad, when clicked, will open the device's native browser. 
 * @note This setting only affects responses with the network code AppNexus.
 */
@property (nonatomic, readwrite, assign) BOOL opensInNativeBrowser;

/*!
 * Whether the landing page should load in the background or in the foreground when an ad is clicked.
 * If set to YES, when an ad is clicked the user is presented with an activity indicator view, and the in-app
 * browser displays only after the landing page content has finished loading. If set to NO, the in-app
 * browser displays immediately. The default is YES.
 *
 * Has no effect if opensInNativeBrowser is set to YES. 
 * @note This setting only affects responses with the network code AppNexus.
 */
@property (nonatomic, readwrite, assign) BOOL landingPageLoadsInBackground;

/*!
 * Should be called when the native view has been populated with the ad elements and will be displayed.
 * Clicks will be handled automatically. If the view is already registered with another ANNativeAdResponse, 
 * it will be automatically detached from that response before being attached to this response.
 *
 * @param view The view which is populated with the native ad elements. Must not be nil.
 * @param rvc The root view controller which contains the view. Must not be nil.
 * @param views Specifies view subviews which should be clickable, instead of the whole view (the default). May be nil.
 * @note The response holds a strong reference to the registered view.
 * @see ANNativeAdRegisterErrorCode in ANAdConstants.h for possible error code values.
 */
- (BOOL)registerViewForTracking:(UIView *)view
         withRootViewController:(UIViewController *)rvc
                 clickableViews:(NSArray *)views
                          error:(NSError **)error;

@end