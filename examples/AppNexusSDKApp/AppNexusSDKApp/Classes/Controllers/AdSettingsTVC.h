/*   Copyright 2013 APPNEXUS INC
 
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

@protocol SizeSettingDelegate <NSObject>

+ (NSInteger)sizeCount;
+ (NSString *)sizeStringAtIndex:(NSInteger)index;
+ (NSString *)bannerSizeWithWidth:(NSInteger)width height:(NSInteger)height;
+ (NSInteger)bannerWidthAtIndex:(NSInteger)index;
+ (NSInteger)bannerHeightAtIndex:(NSInteger)index;
+ (NSInteger)indexForBannerSizeWithWidth:(NSInteger)width height:(NSInteger)height;

@end

@protocol RefreshRateSettingDelegate <NSObject>

+ (NSInteger)refreshRateCount;
+ (NSString *)refreshRateStringAtIndex:(NSInteger)index;
+ (NSString *)refreshRateStringFromInteger:(NSInteger)refreshRate;
+ (NSInteger)refreshRateAtIndex:(NSInteger)index;
+ (NSInteger)indexForRefreshRate:(NSInteger)refreshRate;

@end

@protocol ReservePriceSettingDelegate <NSObject>

+ (NSString *)stringFromReservePrice:(double)price;

@end

@interface AdSettingsTVC : UITableViewController

@property (strong, nonatomic) id <SizeSettingDelegate> sizeDelegate;
@property (strong, nonatomic) id <RefreshRateSettingDelegate> refreshRateDelegate;
@property (strong, nonatomic) id <ReservePriceSettingDelegate> reservePriceDelegate;

@end