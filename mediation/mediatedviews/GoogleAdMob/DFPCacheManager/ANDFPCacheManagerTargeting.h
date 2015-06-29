/*   Copyright 2015 APPNEXUS INC
 
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
#import "ANAdConstants.h"
#import "ANLocation.h"

/**
 Singleton object for setting global targeting values. The cache manager will pass these
 targeting values to DFP ad slots it loads in the background.
 
 @code
 #import "ANDFPCacheManagerTargeting.h"
 
 ANDFPCacheManagerTargeting *sharedTargeting = [ANDFPCacheManager sharedTargeting];
 sharedTargeting.age = @"25-35";
 sharedTargeting.gender = ANGenderMale;
 [sharedTargeting addCustomKeywordWithKey:@"mycustomkey"
                                    value:@"mycustomvalue"];
 @endcode

 @note The values passed into this object are not referenced when ad slots are loaded by 
 the DFP mediation adapter as part of a mediation waterfall. The values referenced by the 
 mediation adapter are the ones passed into ANBannerAdView.
 */
@interface ANDFPCacheManagerTargeting : NSObject

/**
 The singleton targeting object.
 */
+ (ANDFPCacheManagerTargeting *)sharedTargeting;

#pragma mark - Location

/**
 The user's location.  See ANLocation.h for details.
 */
@property (nonatomic, readwrite, strong) ANLocation *location;

/**
 Set the user's current location.  This allows ad buyers to do location
 targeting, which can increase spend.
 */
- (void)setLocationWithLatitude:(CGFloat)latitude
                      longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp
             horizontalAccuracy:(CGFloat)horizontalAccuracy;

/**
 Set the user's current location rounded to the number of decimal places specified in "precision".
 Valid values are between 0 and 6 inclusive. If the precision is -1, no rounding will occur.
 */
- (void)setLocationWithLatitude:(CGFloat)latitude
                      longitude:(CGFloat)longitude
                      timestamp:(NSDate *)timestamp
             horizontalAccuracy:(CGFloat)horizontalAccuracy
                      precision:(NSInteger)precision;

#pragma mark - Age & Gender

/**
 The user's age.  This can contain a numeric age, a birth year, or a
 hyphenated age range.  For example, "56", "1974", or "25-35".
 */
@property (nonatomic, readwrite, strong) NSString *age;

/**
 The user's gender.  See the ANGender enumeration in ANAdConstants.h for details.
 */
@property (nonatomic, readwrite, assign) ANGender gender;

#pragma mark - Custom Keywords

/**
 Used to pass custom keywords across different mobile ad server and
 SDK integrations.
 */
@property (nonatomic, readwrite, strong) NSMutableDictionary *customKeywords;

/**
 These methods add and remove custom keywords to and from the
 customKeywords dictionary.
 */
- (void)addCustomKeywordWithKey:(NSString *)key
                          value:(NSString *)value;
- (void)removeCustomKeywordWithKey:(NSString *)key;

@end