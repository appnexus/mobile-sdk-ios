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
#import "ANLocation.h"

/*!
 * Defines all the targeting parameters available on a native ad request.
 */
@protocol ANNativeAdTargetingProtocol <NSObject>

/*!
 * An AppNexus placement ID, also known as an ad unit id.
 * @note A valid ID is required to show ads.
 */
@property (nonatomic, readwrite, strong) NSString *placementId;

/*!
 * An AppNexus member ID. A member ID is a numeric ID that's associated
 * with the member that this app belongs to.
 */

@property (nonatomic, readonly, assign) NSInteger memberId;

/*!
 * An inventory code for a placement to represent a place where ads can
 * be shown. In the presence of both placement and inventory code, AppNexus
 * SDK favors inventory code over placement id. A member ID is required to request
 * an ad using inventory code.
 */

@property (nonatomic, readonly, strong) NSString *inventoryCode;

/*!
 * The user's location. Setting the user's location allows ad buyers to do
 * location targeting, which may increase spend.
 * @see ANLocation in ANLocation.h
 */
@property (nonatomic, readwrite, strong) ANLocation *location;

/*!
 * The minimum bid amount you will accept to show an ad. Use with caution, 
 * as it can drastically reduce fill rates.
 */
@property (nonatomic, readwrite, assign) CGFloat reserve;

/*!
 * The user's age. This can contain a numeric age, a birth year, or a
 * hyphenated age range.  For example, "56", "1974", or "25-35".
 */
@property (nonatomic, readwrite, strong) NSString *age;

/*!
 * The user's gender.  
 * @see ANGender in ANAdConstants.h
 */
@property (nonatomic, readwrite, assign) ANGender gender;

/*!
 * Used to pass custom keywords across different mobile ad server and
 * SDK integrations.
 */
@property (nonatomic, readwrite, strong) NSMutableDictionary *customKeywords __attribute((deprecated));

/*!
 * Convenience method to set the user's current location.
 * @see location
 */
- (void)setLocationWithLatitude:(CGFloat)latitude
                      longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp
             horizontalAccuracy:(CGFloat)hAccuracy;

/*!
 * Convenience method to set the user's current location, rounded to the number of
 * decimal places specified in "precision." Valid values are between 0 and 6 inclusive.
 * If the precision is -1, no rounding will occur.
 * @see location
 */
- (void)setLocationWithLatitude:(CGFloat)latitude
                      longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp
             horizontalAccuracy:(CGFloat)hAccuracy
                      precision:(NSInteger)precision;

/*!
 * Convenience method to add a custom keyword key, value pair to customKeywords.
 * @see customKeywords
 */
- (void)addCustomKeywordWithKey:(NSString *)key
                          value:(NSString *)value;

/*!
 * Convenience method to remove a custom keyword from customKeywords.
 * @see customKeywords
 */
- (void)removeCustomKeywordWithKey:(NSString *)key;

/*!
 * Convenience method to remove all the keywords from customKeywords.
 * @see customKeywords
 */
- (void)clearCustomKeywords;

/*!
 * Set the inventory code and member id for the place that ads will be shown.
 */

- (void)setInventoryCode:(NSString *)inventoryCode memberId:(NSInteger)memberId;

@end
