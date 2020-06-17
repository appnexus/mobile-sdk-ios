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

#import <XCTest/XCTest.h>

#import "MARHelper.h"



#pragma mark -

@interface MARHelper()
    //EMPTY
@end


@implementation MARHelper

#pragma mark Class methods.

+ (nonnull NSString *)adunitDescription:(nonnull id)ad
{
    NSString  *adinfo  = @"";


    if ([ad isKindOfClass:[ANAdView class]])
    {
        if ([ad isKindOfClass:[ANBannerAdView class]])
        {
            adinfo = @"banner";

            ANBannerAdView  *banner  = (ANBannerAdView *)ad;
            if (banner.shouldAllowVideoDemand) {
                adinfo = [NSString stringWithFormat:@"%@ +video", adinfo];
            }
            if (banner.shouldAllowNativeDemand) {
                adinfo = [NSString stringWithFormat:@"%@ +native", adinfo];
            }

        } else {
            adinfo = @"interstitial";
        }

        //
        ANAdView  *adview  = (ANAdView *)ad;

        if (adview.placementId.length > 0) {
            adinfo = [NSString stringWithFormat:@"%@  placementID:%@", adinfo, adview.placementId];

        } else if ((adview.memberId > 0) && (adview.inventoryCode.length > 0)) {
            adinfo = [NSString stringWithFormat:@"%@  memberID:%@  inventoryCode:%@", adinfo, @(adview.memberId), adview.inventoryCode];

        } else {
            ANLogError(@"FAILED to find placementID or memberID/inventoryCode.");
            return  nil;
        }


    } else if ([ad isKindOfClass:[ANInstreamVideoAd class]]) {
        adinfo = @"video TBD";
        //...

    } else if ([ad isKindOfClass:[ANNativeAdResponse class]]) {
        adinfo = @"native TBD";
        //...

    } else {
        ANLogError(@"UNRECOGNIZED adunit instance.");
        return  nil;
    }


    //
    return  adinfo;
}

+ (nonnull NSString *)createDictionaryKeyFromPlacementID: (nullable NSString *)placementID
                                              orMemberID: (NSInteger)memberID
                                        andInventoryCode: (nullable NSString *)inventoryCode
                                            uniqueSuffix: (nullable NSString *)uniqueSuffix
{
    NSString  *key  = @"";

    if (placementID.length > 0) {
        key = placementID;

    } else if ((memberID > 0) && (inventoryCode.length > 0)) {
        key = [NSString stringWithFormat:@"%@/%@", @(memberID), inventoryCode];

    } else {
        ANLogError(@"FAILED to generate dictionary key.");
        return  nil;
    }

    if (uniqueSuffix.length > 0) {
        key = [NSString stringWithFormat:@"%@--%@", key, uniqueSuffix];
    }

    return  key;
}

+ (nonnull ANBannerAdView *)createBannerInstanceWithType: (MultiTagType)                        multiTagType
                                             placementID: (nullable NSString *)                 placementID
                                              orMemberID: (NSInteger)                           memberID
                                        andInventoryCode: (nullable NSString *)                 inventoryCode
                                            withDelegate: (nonnull id<ANBannerAdViewDelegate>)  delegate
                                   andRootViewController: (nullable UIViewController *)         rootViewController
                                                   width: (NSInteger)                           width
                                                  height: (NSInteger)                           height
                                            labelDetails: (nullable NSString *)                 labelDetails
                                     dictionaryKeySuffix: (nullable NSString *)                 keySuffix
{
TMARK();
    ANBannerAdView  *banner;

    CGRect  frame  = CGRectMake(0, 0, width, height);
    CGSize  size   = CGSizeMake(width, height);


    if (placementID.length > 0) {
        banner = [ANBannerAdView adViewWithFrame:frame placementId:placementID adSize:size];

    } else if ((memberID > 0) && (inventoryCode.length > 0)) {
        banner = [[ANBannerAdView alloc] initWithFrame:frame memberId:memberID inventoryCode:inventoryCode adSize:size];

    } else {
        TERROR(@"FAILED to allocate banner instance.");
        return  nil;
    }

    banner.rootViewController   = rootViewController;
    banner.delegate             = delegate;

    banner.clickThroughAction                       = ANClickThroughActionReturnURL;
    banner.shouldServePublicServiceAnnouncements    = NO;
    banner.autoRefreshInterval                      = 0;


    // Configuration and display per multi-type status.
    //
    NSString  *adunitLabel  = @"";   //TBD -- Return this to caller or use in global container to clarify display of multiple AdUnits.

    banner.shouldAllowNativeDemand  = NO;
    banner.shouldAllowVideoDemand   = NO;

    switch (multiTagType) {
        case MultiTagTypeBannerBannerOnly:
            adunitLabel = @"banner banner";
            break;

        case MultiTagTypeBannerVideoOnly:
            adunitLabel = @"banner video";
            banner.shouldAllowVideoDemand = YES;
            TERROR(@"MultiTagType NOT SUPPORTED YET.");
            return  nil;
            break;

        case MultiTagTypeBannerPlusVideo:
            adunitLabel = @"banner plus video";
            banner.shouldAllowVideoDemand = YES;
            break;

        case MultiTagTypeBannerNativeOnly:
            adunitLabel = @"banner native";
            banner.shouldAllowNativeDemand = YES;
            break;

        case MultiTagTypeBannerPlusNative:
            adunitLabel = @"banner plus native";
            banner.shouldAllowNativeDemand = YES;
            break;
    }

    if (labelDetails) {
        adunitLabel = [NSString stringWithFormat:@"%@ (%@)", adunitLabel, labelDetails];
    }


    //
    return  banner;
}

+ (nullable NSDictionary *)getJSONBodyFromMultiAdRequestInstance:(nonnull ANMultiAdRequest *)marInstance
{
    NSURLRequest  *request     = [ANUniversalTagRequestBuilder buildRequestWithMultiAdRequestManager:marInstance];
    NSError       *error       = nil;
    NSDictionary  *jsonBody    = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: request.HTTPBody
                                                                                 options: kNilOptions
                                                                                   error: &error];
    if (error)  {
        TNSERROR(error);
        return  nil;
    }

    return  jsonBody;
}

+ (nullable NSDictionary *)getJSONBodyFromAdUnit: (nonnull ANAdView *)adunit
                              withMultiAdRequest: (nonnull ANMultiAdRequest *)marInstance
{
    NSURLRequest  *request     = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adunit adunitMultiAdRequestManager:marInstance];
    NSError       *error       = nil;
    NSDictionary  *jsonBody    = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: request.HTTPBody
                                                                                 options: kNilOptions
                                                                                   error: &error];
    if (error)  {
        TNSERROR(error);
        return  nil;
    }

    return  jsonBody;
}

+ (nullable NSDictionary *)getJSONBodyFromAdUnit:(nonnull ANAdView *)adunit
{
    NSURLRequest  *request     = [ANUniversalTagRequestBuilder buildRequestWithAdFetcherDelegate:adunit];
    NSError       *error       = nil;
    NSDictionary  *jsonBody    = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: request.HTTPBody
                                                                                 options: kNilOptions
                                                                                   error: &error];
    if (error)  {
        TNSERROR(error);
        return  nil;
    }

    return  jsonBody;
}

@end  //MARHelper




#pragma mark -

@interface  MARAdUnitParameters()
    //EMPTY
@end


@implementation MARAdUnitParameters : NSObject

- (instancetype)init
{
    self = [super init];
    if (!self)  { return nil; }

    return  self;
}

@end  //MARAdUnitParameters



#pragma mark -

@interface  MARAdUnits()
    //EMPTY
@end


@implementation MARAdUnits : NSObject

- (instancetype)initWithDelegate:(nullable id)delegate
{
    self = [super init];
    if (!self)  { return nil; }

    self.delegate = delegate;
    [self setup];

    return  self;
}

- (void)setup
{
TMARK();
    self.memberIDDefault            = 958;
    self.memberIDMobileEngineering  = 10094;

    self.memberIDGood               = self.memberIDMobileEngineering;


    self.inventoryCodeNotredame     = @"notredame";
    self.inventoryCodeRutabega      = @"rutabega";

    [self configureAdUnitParameters];
    [self createAdUnits];
}

- (void)configureAdUnitParameters
{
TMARK();
//    NSString  *supermanPlacement1  = @"16392991";
    NSString  *supermanPlacement1  = @"14790206";


    // Placements used in the first MAR instance.
    //
    self.pBannerBanner = [[MARAdUnitParameters alloc] init];

    self.pBannerBanner.placementID          = supermanPlacement1;          //RTB
    self.pBannerBanner.width                = 320;
    self.pBannerBanner.height               = 50;
    self.pBannerBanner.detailSuffix         = @"bannerOnly";

    //
    self.pBannerPlusNative = [[MARAdUnitParameters alloc] init];

    self.pBannerPlusNative.placementID          = supermanPlacement1;      //RTB
    self.pBannerPlusNative.width                = 300;
    self.pBannerPlusNative.height               = 250;
    self.pBannerPlusNative.detailSuffix         = @"plusNative";

    //
    self.pBannerPlusVideo = [[MARAdUnitParameters alloc] init];

    self.pBannerPlusVideo.placementID           = supermanPlacement1;      //RTB
    self.pBannerPlusVideo.width                 = 300;
    self.pBannerPlusVideo.height                = 250;
    self.pBannerPlusVideo.detailSuffix          = @"plusVideo";


    // Placements used in the second MAR instance.
    //
    // The following live AdUnits are used in a second MAR instance, and MUST ALL BE DIFFERENT from the live placements used above.
    // Some of these tests DO NOT use mocking and require live placements.
    //
    self.pBanner = [[MARAdUnitParameters alloc] init];

    self.pBanner.placementID    = supermanPlacement1;
    self.pBanner.width          = 300;
    self.pBanner.height         = 250;
    self.pBanner.detailSuffix   = @"bannerOnly";

    //
    self.pInterstitial = [[MARAdUnitParameters alloc] init];
//    self.pInterstitial.placementID = @"18108597";
    self.pInterstitial.placementID = supermanPlacement1;

    //
    self.pInstreamVideo = [[MARAdUnitParameters alloc] init];
    self.pInstreamVideo.placementID = @"18144602";          //CSM
//    self.pInstreamVideo.placementID = @"14790206";   

    //
    self.pNative = [[MARAdUnitParameters alloc] init];
    self.pNative.placementID  = supermanPlacement1;
}

- (void)createAdUnits
{
    self.bannerBanner  = [MARHelper createBannerInstanceWithType: MultiTagTypeBannerBannerOnly
                                                     placementID: self.pBannerBanner.placementID
                                                      orMemberID: 0
                                                andInventoryCode: nil
                                                    withDelegate: (id<ANBannerAdViewDelegate>)self.delegate
                                           andRootViewController: nil
                                                           width: self.pBannerBanner.width
                                                          height: self.pBannerBanner.height
                                                    labelDetails: nil
                                             dictionaryKeySuffix: self.pBannerBanner.detailSuffix ];

    self.bannerPlusNative  = [MARHelper createBannerInstanceWithType: MultiTagTypeBannerPlusNative
                                                         placementID: self.pBannerPlusNative.placementID
                                                          orMemberID: 0
                                                    andInventoryCode: nil
                                                        withDelegate: (id<ANBannerAdViewDelegate>)self.delegate
                                               andRootViewController: nil
                                                               width: self.pBannerPlusNative.width
                                                              height: self.pBannerPlusNative.height
                                                        labelDetails: nil
                                                 dictionaryKeySuffix: self.pBannerPlusNative.detailSuffix ];

    self.bannerPlusVideo  = [MARHelper createBannerInstanceWithType: MultiTagTypeBannerPlusVideo
                                                        placementID: self.pBannerPlusVideo.placementID
                                                         orMemberID: 0
                                                   andInventoryCode: nil
                                                       withDelegate: (id<ANBannerAdViewDelegate>)self.delegate
                                              andRootViewController: nil
                                                              width: self.pBannerPlusVideo.width
                                                             height: self.pBannerPlusVideo.height
                                                       labelDetails: nil
                                                dictionaryKeySuffix: self.pBannerPlusVideo.detailSuffix ];

    //
    self.banner  = [MARHelper createBannerInstanceWithType: MultiTagTypeBannerBannerOnly
                                               placementID: self.pBanner.placementID
                                                orMemberID: 0
                                          andInventoryCode: nil
                                              withDelegate: (id<ANBannerAdViewDelegate>)self.delegate
                                     andRootViewController: nil
                                                     width: self.pBanner.width
                                                    height: self.pBanner.height
                                              labelDetails: nil
                                       dictionaryKeySuffix: self.pBanner.detailSuffix ];

    //
    self.interstitial = [[ANInterstitialAd alloc] initWithPlacementId:self.pInterstitial.placementID];
    self.interstitial.delegate = self.delegate;

    //
    self.instreamVideo = [[ANInstreamVideoAd alloc] initWithPlacementId:self.pInstreamVideo.placementID];
    self.instreamVideo.loadDelegate = self.delegate;

    //
    self.native = [[ANNativeAdRequest alloc] init];
    self.native.placementId = self.pNative.placementID;
    self.native.delegate = self.delegate;
}

@end  //MARAdUnitParameters


