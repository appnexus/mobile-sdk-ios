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

#import "DataDisplayHelper.h"
#define TIME_DELAY_OFF @"Off"
#define SIZE_SEPARATOR @"x"
#define DEFAULT_REFRESH_RATES @[@"0",@"30",@"60",@"120"]
#define DEFAULT_BANNER_SIZES @[@"320|50", @"300|250", @"480|320",\
@"728|90", @"320|480", @"168|28", @"216|36", @"1024|768", @"300|50"]

@interface DataDisplayHelper ()

@end

@implementation DataDisplayHelper

+ (NSInteger)sizeCount {
    return [DEFAULT_BANNER_SIZES count];
}

+ (NSInteger)refreshRateCount {
    return [DEFAULT_REFRESH_RATES count];
}

+ (NSString *)refreshRateStringAtIndex:(NSInteger)index {
    int refreshRate = [[DEFAULT_REFRESH_RATES objectAtIndex:index] intValue];
    if (!refreshRate) {
        return TIME_DELAY_OFF;
    } else {
        return [NSString stringWithFormat:@"%d Seconds",refreshRate];
    }
}

+ (NSString *)sizeStringAtIndex:(NSInteger)index {
    NSArray *split = [[DEFAULT_BANNER_SIZES objectAtIndex:index] componentsSeparatedByString:@"|"];
    return [NSString stringWithFormat:@"%@%@%@",[split objectAtIndex:0], SIZE_SEPARATOR, [split objectAtIndex:1]];
}

+ (NSString *)refreshRateStringFromInteger:(NSInteger)refreshRate {
    if(refreshRate) {
        return [NSString stringWithFormat:@"%ld Seconds",(long)refreshRate];
    } else {
        return TIME_DELAY_OFF;
    }
}

+ (NSString *)bannerSizeWithWidth:(NSInteger)width height:(NSInteger)height {
    return [NSString stringWithFormat:@"%ld%@%ld",(long)width, SIZE_SEPARATOR, (long)height];
}

+ (NSInteger)bannerWidthAtIndex:(NSInteger)index {
    NSArray *split = [[DEFAULT_BANNER_SIZES objectAtIndex:index] componentsSeparatedByString:@"|"];
    return [[split objectAtIndex:0] intValue];
}

+ (NSInteger)bannerHeightAtIndex:(NSInteger)index {
    NSArray *split = [[DEFAULT_BANNER_SIZES objectAtIndex:index] componentsSeparatedByString:@"|"];
    return [[split objectAtIndex:1] intValue];
}

+ (NSInteger)refreshRateAtIndex:(NSInteger)index {
    return [[DEFAULT_REFRESH_RATES objectAtIndex:index] intValue];
}

+ (NSInteger)indexForBannerSizeWithWidth:(NSInteger)width height:(NSInteger)height {
    for (int index=0; index < [DEFAULT_BANNER_SIZES count]; index++) {
        if ([self bannerWidthAtIndex:index] == width && [self bannerHeightAtIndex:index] == height) {
            return index;
        }
    }
    return 0;
}

+ (NSInteger)indexForRefreshRate:(NSInteger)refreshRate {
    for (int index=0; index < [DEFAULT_REFRESH_RATES count]; index++) {
        if ([self refreshRateAtIndex:index] == refreshRate) {
            return index;
        }
    }
    return 0;
}

@end