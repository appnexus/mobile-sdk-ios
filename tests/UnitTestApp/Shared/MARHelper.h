/*   Copyright 2019 APPNEXUS INC

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

#import "ANLogManager.h"
#import "ANLogging.h"

#import "TestGlobal.h"

#import "ANMultiAdRequest.h"
#import "ANAdView.h"
#import "ANBannerAdView.h"
#import "ANInterstitialAd.h"
#import "ANInstreamVideoAd.h"
#import "ANNativeAdView.h"



#pragma mark - Type definitions.

typedef NS_ENUM(NSInteger, MultiTagType)
{
    MultiTagTypeBannerBannerOnly,

    MultiTagTypeBannerVideoOnly,
    MultiTagTypeBannerPlusVideo,

    MultiTagTypeBannerNativeOnly,
    MultiTagTypeBannerPlusNative,
};



#pragma mark -

@class ANBannerAdView;
@protocol ANBannerAdViewDelegate;

@interface MARHelper : XCTestCase

+ (nonnull NSString *)adunitDescription:(nonnull id)ad;

+ (nonnull NSString *)createDictionaryKeyFromPlacementID: (nullable NSString *)placementID
                                              orMemberID: (NSInteger)memberID
                                        andInventoryCode: (nullable NSString *)inventoryCode
                                            uniqueSuffix: (nullable NSString *)uniqueSuffix;

+ (nonnull ANBannerAdView *)createBannerInstanceWithType: (MultiTagType)                        multiTagType
                                             placementID: (nullable NSString *)                 placementID
                                              orMemberID: (NSInteger)                           memberID
                                        andInventoryCode: (nullable NSString *)                 inventoryCode
                                            withDelegate: (nonnull id<ANBannerAdViewDelegate>)  delegate
                                   andRootViewController: (nullable UIViewController *)         rootViewController
                                                   width: (NSInteger)                           width
                                                  height: (NSInteger)                           height
                                            labelDetails: (nullable NSString *)                 labelDetails
                                     dictionaryKeySuffix: (nullable NSString *)                 keySuffix;

+ (nullable NSDictionary *)getJSONBodyFromMultiAdRequestInstance:(nonnull ANMultiAdRequest *)marInstance;
+ (nullable NSDictionary *)getJSONBodyFromAdUnit:(nonnull ANAdView *)adunit withMultiAdRequest:(nonnull ANMultiAdRequest *)marInstance;
+ (nullable NSDictionary *)getJSONBodyFromAdUnit:(nonnull ANAdView *)adunit;

@end




#pragma mark -

@interface MARAdUnitParameters : NSObject

@property (strong, readwrite, nonatomic, nullable)  NSString  *placementID;

@property (readwrite, nonatomic)                    NSInteger  memberID;
@property (strong, readwrite, nonatomic, nullable)  NSString  *inventoryCode;

@property (readwrite, nonatomic)                    NSInteger  height;
@property (readwrite, nonatomic)                    NSInteger  width;

@property (strong, readwrite, nonatomic, nullable)  NSString  *detail;
@property (strong, readwrite, nonatomic, nullable)  NSString  *detailSuffix;

@end



#pragma mark -

@interface MARAdUnits : NSObject

@property (strong, nonatomic, readwrite, nullable)  id  delegate;


@property (strong, nonatomic, readwrite, nullable)  MARAdUnitParameters  *pBannerBanner;
@property (strong, nonatomic, readwrite, nullable)  MARAdUnitParameters  *pBannerPlusNative;
@property (strong, nonatomic, readwrite, nullable)  MARAdUnitParameters  *pBannerPlusVideo;

@property (strong, nonatomic, readwrite, nullable)  MARAdUnitParameters  *pBanner;
@property (strong, nonatomic, readwrite, nullable)  MARAdUnitParameters  *pInterstitial;
@property (strong, nonatomic, readwrite, nullable)  MARAdUnitParameters  *pInstreamVideo;
@property (strong, nonatomic, readwrite, nullable)  MARAdUnitParameters  *pNative;


@property (strong, nonatomic, readwrite, nullable)  ANBannerAdView  *bannerBanner;
@property (strong, nonatomic, readwrite, nullable)  ANBannerAdView  *bannerPlusNative;
@property (strong, nonatomic, readwrite, nullable)  ANBannerAdView  *bannerPlusVideo;

@property (strong, nonatomic, readwrite, nullable)  ANBannerAdView      *banner;
@property (strong, nonatomic, readwrite, nullable)  ANInterstitialAd    *interstitial;
@property (strong, nonatomic, readwrite, nullable)  ANInstreamVideoAd   *instreamVideo;
@property (strong, nonatomic, readwrite, nullable)  ANNativeAdRequest   *native;


@property (nonatomic, readwrite)  NSInteger  memberIDGood;
@property (nonatomic, readwrite)  NSInteger  memberIDDefault;
@property (nonatomic, readwrite)  NSInteger  memberIDMobileEngineering;


@property (strong, nonatomic, readwrite, nonnull)  NSString  *inventoryCodeNotredame;
@property (strong, nonatomic, readwrite, nonnull)  NSString  *inventoryCodeRutabega;


//
- (nullable instancetype)initWithDelegate:(nullable id)delegate;

- (void)configureAdUnitParameters;
- (void)createAdUnits;

@end
