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

@interface ANNativeStandardAdResponse : ANNativeAdResponse

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

@property (nonatomic, readwrite, strong) NSString *mediaType;
@property (nonatomic, readwrite, strong) NSString *fullText;

@property (nonatomic, readwrite, strong) NSArray *clickTrackers; // Array of NSURL
@property (nonatomic, readwrite, strong) NSArray *impTrackers; // Array of NSURL
@property (nonatomic, readwrite, strong) NSURL *clickURL;
@property (nonatomic, readwrite, strong) NSURL *clickFallbackURL;

@end