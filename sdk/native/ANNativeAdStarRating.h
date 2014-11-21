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

/*!
 * Defines an app store rating
 */
@interface ANNativeAdStarRating : NSObject

/*!
 * @param value The absolute value of the rating.
 * @param scale What the value is out, for example, 5 on a 5 star rating scale.
 */
- (instancetype)initWithValue:(CGFloat)value
                        scale:(NSInteger)scale;

/*!
 * The absolute value of the rating.
 */
@property (nonatomic, readonly, assign) CGFloat value;

/*!
 * The scale that the value is out of, for example, 5 for a 5 star rating scale.
 */
@property (nonatomic, readonly, assign) NSInteger scale;

@end