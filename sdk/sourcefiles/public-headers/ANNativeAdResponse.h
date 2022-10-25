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
#import <Foundation/Foundation.h>
#import "ANAdConstants.h"

#if !APPNEXUS_NATIVE_MACOS_SDK
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#import "XandrNativeAdView.h"
#endif

#import "ANNativeAdStarRating.h"
#import "ANNativeAdDelegate.h"
#import "ANAdProtocol.h"

extern NSString * __nonnull const  kANNativeElementObject;
extern NSString * __nonnull const  kANNativeCSRObject;


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
@interface ANNativeAdResponse : NSObject  <ANNativeAdResponseProtocol>

#pragma mark - Native Ad Elements

/*!
 * The ad title.
 */
@property (nonatomic, readonly, strong, nullable) NSString *title;

/*!
 * The ad body, also known as the ad text or description.
 */
@property (nonatomic, readonly, strong, nullable) NSString *body;

/*!
 * The call to action text, for example, "Install Now!"
 */
@property (nonatomic, readonly, strong, nullable) NSString *callToAction;


/*!
 * The icon image size
 */
@property (nonatomic, readonly, assign) CGSize iconImageSize;

/*!
 * The star rating of the ad, generally reserved for an app install ad.
 */
@property (nonatomic, readonly, strong, nullable) ANNativeAdStarRating *rating;

#if !APPNEXUS_NATIVE_MACOS_SDK

/*!
 * The ad icon image.
 */
@property (nonatomic, readonly, strong, nullable) UIImage *iconImage;


/*!
 * The ad main image, also known as a cover image.
 */
@property (nonatomic, readonly, strong, nullable) UIImage *mainImage;
#else

/*!
 * The ad icon image.
 */
@property (nonatomic, readonly, strong, nullable) NSImage *iconImage;


/*!
 * The ad main image, also known as a cover image.
 */
@property (nonatomic, readonly, strong, nullable) NSImage *mainImage;
#endif

/*!
 * A URL which loads the ad main image.
 */
@property (nonatomic, readonly, strong, nullable) NSURL *mainImageURL;

/*!
 * The main image size
 */
@property (nonatomic, readonly, assign) CGSize mainImageSize;

/*!
 * A URL which loads the ad icon image.
 */
@property (nonatomic, readonly, strong, nullable) NSURL *iconImageURL;


/*!
 * Contains any non-standard elements. This would include any custom assets requested from
 * third-party networks as specified in the third-party system.
 */
@property (nonatomic, readonly, strong, nullable) NSDictionary *customElements;


/*!
 * The sponspored By text
 */
@property (nonatomic, readonly, strong, nullable) NSString *sponsoredBy;


/**
 An AppNexus Single Unified object that will contain all the common fields of all the ads types
 */
@property (nonatomic, readonly, strong, nullable) ANAdResponseInfo *adResponseInfo;


/*!
 * Additional description of the ad
 */
@property (nonatomic, readwrite, strong, nullable) NSString *additionalDescription;

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

/*!
 * vastXML can be used to play Video.
 */
@property (nonatomic, readwrite, strong, nullable) NSString *vastXML;

/*!
 * privacy Link of the ad
 */
@property (nonatomic, readwrite, strong, nullable) NSString *privacyLink;



#pragma mark - Native View Registration

/*!
 * Delegate object that receives callbacks for a native view which has been registered.
 * @see ANNativeAdDelegate
 */
@property (nonatomic, readwrite, weak, nullable) id<ANNativeAdDelegate> delegate;

#if !APPNEXUS_NATIVE_MACOS_SDK

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
- (BOOL)registerViewForTracking:(nonnull UIView *)view
         withRootViewController:(nonnull UIViewController *)rvc
                 clickableViews:(nullable NSArray *)views
                          error:(NSError *__nullable*__nullable)error;


/*!
 * Should be called when the native view has been populated with the ad elements and will be displayed.
 * Clicks will be handled automatically. If the view is already registered with another ANNativeAdResponse,
 * it will be automatically detached from that response before being attached to this response.
 *
 * @param view The view which is populated with the native ad elements. Must not be nil.
 * @param rvc The root view controller which contains the view. Must not be nil.
 * @param views Specifies view subviews which should be clickable, instead of the whole view (the default). May be nil.
 * @param obstructionViews Specifies views  which should be FriendlyObstructions for OpenMeasurement.
 * @note The response holds a strong reference to the registered view.
 * @see ANNativeAdRegisterErrorCode in ANAdConstants.h for possible error code values.
 */
- (BOOL)registerViewForTracking:(nonnull UIView *)view
         withRootViewController:(nonnull UIViewController *)rvc
                 clickableViews:(nullable NSArray<UIView *> *)views
                 openMeasurementFriendlyObstructions:(nonnull NSArray<UIView *> *)obstructionViews
                          error:(NSError *__nullable*__nullable)error;

#else

/*!
 * Should be called when the native view has been populated with the ad elements and will be displayed.
 * it will be automatically detached from that response before being attached to this response.
 *
 * @param view The view which is populated with the native ad elements. Must not be nil and type NSTableRowView.
 * @param rvc The root view controller which contains the view. Must not be nil.
 * @param views Specifies XandrNativeAdView subviews which should be clickable, instead of the whole view (the default). May be nil.
 * @note The response holds a strong reference to the registered view.
 * @see ANNativeAdRegisterErrorCode in ANAdConstants.h for possible error code values.
 */
- (BOOL)registerViewForTracking:(nonnull NSTableRowView *)view
         withRootViewController:(nonnull NSViewController *)rvc
                 clickableXandrNativeAdView:(nullable NSArray<XandrNativeAdView *> *)views
                          error:(NSError *__nullable*__nullable)error;


/*!
 * Should be called when the native view has been populated with the ad elements and will be displayed.
 * it will be automatically detached from that response before being attached to this response.
 *
 * @param view The view which is populated with the native ad elements. Must not be nil and type NSView.
 * @param rvc The root view controller which contains the view. Must not be nil.
 * @param views Specifies XandrNativeAdView subviews which should be clickable, instead of the whole view (the default). May be nil.
 * @note The response holds a strong reference to the registered view.
 * @see ANNativeAdRegisterErrorCode in ANAdConstants.h for possible error code values.
 */
- (BOOL)registerViewTracking:(nonnull NSView *)view
         withRootViewController:(nonnull NSViewController *)rvc
                 clickableXandrNativeAdView:(nullable NSArray<XandrNativeAdView *> *)views
                          error:(NSError *__nullable*__nullable)error;


#endif




@end

