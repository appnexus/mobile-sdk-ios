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

@protocol ANNativeCustomAdapter;

/*!
 * Represents a response which should be created, populated, and returned
 * by a custom adapter.
 * @see ANNativeAdResponse for descriptions of all the properties.
 */
@interface ANNativeMediatedAdResponse : ANNativeAdResponse

/*!
 * Designated initializer.
 *
 * @param adapter The mediation adapter which provided the native assets for this response.
 * @param networkCode The network code for the mediated adapter.
 */
- (instancetype)initWithCustomAdapter:(id<ANNativeCustomAdapter>)adapter
                          networkCode:(ANNativeAdNetworkCode)networkCode;

@property (nonatomic, readwrite, strong) NSString *title;
@property (nonatomic, readwrite, strong) NSString *body;
@property (nonatomic, readwrite, strong) NSString *callToAction;
@property (nonatomic, readwrite, strong) ANNativeAdStarRating *rating;
@property (nonatomic, readwrite, strong) UIImage *mainImage;
@property (nonatomic, readwrite, strong) NSURL *mainImageURL;
@property (nonatomic, readwrite, strong) UIImage *iconImage;
@property (nonatomic, readwrite, strong) NSURL *iconImageURL;
@property (nonatomic, readwrite, strong) NSString *socialContext;
@property (nonatomic, readwrite, strong) NSDictionary *customElements;

/*!
 * The mediation adapter which provided the native assets for this response.
 */
@property (nonatomic, readonly, strong) id<ANNativeCustomAdapter> adapter;

@end