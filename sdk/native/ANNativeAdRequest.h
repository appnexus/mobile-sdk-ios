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

#import "ANLocation.h"
#import "ANNativeAdTargetingProtocol.h"
#import "ANNativeAdResponse.h"

@protocol ANNativeAdRequestDelegate;

/*!
 * An ANNativeAdRequest facilitates the loading of native ad assets from the server. Here is a sample workflow:
 *
 * @code
 * ANNativeAdRequest *request = [[ANNativeAdRequest alloc] init];
 * request.gender = MALE;
 * request.shouldLoadIconImage = YES;
 * request.delegate = self;
 * [request loadAd];
 * @endcode
 *
 * The response is received as part of the ANNativeAdRequestDelegate callbacks. See ANNativeAdResponse for more information.
 *
 * @code
 * - (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response {
 *      // Handle response
 * }
 *
 * - (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error {
 *      // Handle failure
 * }
 * @endcode
 *
 */
@interface ANNativeAdRequest : NSObject <ANNativeAdTargetingProtocol>

/*!
 * If YES, an icon image will automatically be downloaded and included in the response.
 */
@property (nonatomic, readwrite, assign) BOOL shouldLoadIconImage;

/*!
 * If YES, a main image will automatically be downloaded and included in the response.
 */
@property (nonatomic, readwrite, assign) BOOL shouldLoadMainImage;

/*!
 * The delegate which is notified of a successful or failed request. This should be set before calling [ANNativeAdRequest loadAd].
 */
@property (nonatomic, readwrite, weak) id<ANNativeAdRequestDelegate> delegate;

/*!
 * Requests a set of native ad assets. This method may be called multiple times simultaneously. The delegate will
 * be notified once for each call to this method.
 */
- (void)loadAd;

@end

/*!
 * Defines the callbacks for each load of a ANNativeAdRequest instance.
 */
@protocol ANNativeAdRequestDelegate <NSObject>

/*!
 * Called when a native ad request was successful. If [ANNativeAdRequest shouldLoadIconImage]
 * or [ANNativeAdRequest shouldLoadMainImage] were set to YES, this method will be called only
 * after the image resources have been retrieved.
 *
 * @param response Contains the native ad assets.
 *
 * @note If errors are encountered in resource retrieval, this method will still be called. However, the
 * [ANNativeAdResponse iconImage] or [ANNativeAdResponse mainImage] properties may be nil.
 */
- (void)adRequest:(ANNativeAdRequest *)request didReceiveResponse:(ANNativeAdResponse *)response;

/*!
 * Called when a native ad request was unsuccessful.
 * @see ANAdResponseCode in ANAdConstants.h for possible error code values.
 */
- (void)adRequest:(ANNativeAdRequest *)request didFailToLoadWithError:(NSError *)error;

@end