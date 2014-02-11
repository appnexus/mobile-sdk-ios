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

#import <Foundation/Foundation.h>

#define DEFAULT_AD_TYPE AD_TYPE_BANNER
#define DEFAULT_BANNER_WIDTH 320
#define DEFAULT_BANNER_HEIGHT 480
#define DEFAULT_ALLOW_PSA YES
#define DEFAULT_BROWSER_TYPE BROWSER_TYPE_IN_APP
#define DEFAULT_PLACEMENT_ID 1326299
#define DEFAULT_REFRESH_RATE 30
#define DEFAULT_BACKGROUD_COLOR @"FF000000"
#define DEFAULT_MEMBER_ID 0
#define DEFAULT_DONGLE @""
#define DEFAULT_AGE @""
#define DEFAULT_GENDER UNKNOWN
#define DEFAULT_RESERVE 0.0
#define DEFAULT_CUSTOM_KEYWORDS [[NSDictionary alloc] init]

@interface AdSettings : NSObject

/*
    General Properties
 */

typedef NS_ENUM(int, AdType) {
    AD_TYPE_BANNER = 1,
    AD_TYPE_INTERSTITIAL = 2
};

@property (nonatomic) AdType adType;
@property (nonatomic) BOOL allowPSA;

typedef NS_ENUM(int, BrowserType) {
    BROWSER_TYPE_IN_APP = 1,
    BROWSER_TYPE_DEVICE = 2
};

@property (nonatomic) BrowserType browserType;
@property (nonatomic) int placementID;

@property (nonatomic) NSString *age;
@property (nonatomic) double reserve;
@property (nonatomic) int gender;

@property (nonatomic) NSDictionary *customKeywords;

/*
    Banner Properties
 */

@property (nonatomic) int bannerWidth;
@property (nonatomic) int bannerHeight;
@property (nonatomic) int refreshRate;


/*
    Interstitial Properties
 */

@property (strong, nonatomic) NSString *backgroundColor;

+ (BOOL)backgroundColorIsValid:(NSString *)backgroundColor;

/*
    Debug Properties
 */

@property (nonatomic) int memberID;
@property (strong, nonatomic) NSString *dongle;

@end
