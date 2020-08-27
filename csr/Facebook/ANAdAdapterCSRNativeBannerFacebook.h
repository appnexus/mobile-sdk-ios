/*   Copyright 2020 APPNEXUS INC

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
#if __has_include(<AppNexusNativeSDK/AppNexusNativeSDK.h>)
#import <AppNexusNativeSDK/AppNexusNativeSDK.h>
#elif __has_include(<AppNexusSDK/AppNexusSDK.h>)
#import <AppNexusSDK/AppNexusSDK.h>
#else
#import "ANNativeCustomAdapter.h"
#import "ANLogging.h"
#import "ANCSRNativeAdResponse.h"
#endif
#import <FBAudienceNetwork/FBAudienceNetwork.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANAdAdapterCSRNativeBannerFacebook : NSObject

/*!
 * Should be called when the CSRNativeBannerAd view has been populated with the ad elements and will be displayed.
 * Clicks will be handled automatically. If the view is already registered with another ANNativeAdResponse,
 * it will be automatically detached from that response before being attached to this response.
 *
 */

/*
 * @param view The view which is populated with the native ad elements. Must not be nil.
 * @param controller The root view controller which contains the view. Must not be nil.
 * @param iconView The FBMediaView you created to render the icon.
 * @param clickableViews Specifies view subviews which should be clickable, instead of the whole view (the default). May be nil.
 * @note The response holds a strong reference to the registered view.
 */

- (void)registerViewForTracking:(nonnull UIView *)view
         withRootViewController:(nonnull UIViewController *)controller
                       iconView:(FBMediaView *_Nonnull)iconView
                 clickableViews:(nullable NSArray *)clickableViews;


/*!
 * @param view The view which is populated with the native ad elements. Must not be nil.
 * @param controller The root view controller which contains the view. Must not be nil.
 * @param iconImageView The UIImageView you created to render the icon.
 * @param clickableViews Specifies view subviews which should be clickable, instead of the whole view (the default). May be nil.
 * @note The response holds a strong reference to the registered view.
 */

- (void)registerViewForTracking:(nonnull UIView *)view
         withRootViewController:(nonnull UIViewController *)controller
                  iconImageView:(UIImageView *_Nonnull)iconImageView
                 clickableViews:(nullable NSArray *)clickableViews;


/*
* @param view The view which is populated with the native ad elements. Must not be nil.
* @param controller The root view controller which contains the view. Must not be nil.
* @param iconView The FBMediaView you created to render the icon.
* @note The response holds a strong reference to the registered view.
*/
- (void)registerViewForTracking:(nonnull UIView *)view
         withRootViewController:(nonnull UIViewController *)controller
                       iconView:(FBMediaView *_Nonnull)iconView;



/*!
* @param view The view which is populated with the native ad elements. Must not be nil.
* @param controller The root view controller which contains the view. Must not be nil.
* @param iconImageView The UIImageView you created to render the icon.
* @note The response holds a strong reference to the registered view.
*/

- (void)registerViewForTracking:(nonnull UIView *)view
         withRootViewController:(nonnull UIViewController *)controller
                  iconImageView:(UIImageView *_Nonnull)iconImageView;


@end

NS_ASSUME_NONNULL_END
