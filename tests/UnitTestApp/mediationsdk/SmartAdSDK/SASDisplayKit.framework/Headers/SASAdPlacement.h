//
//  SASAdPlacement.h
//  SmartAdServer
//
//  Created by Julien Gomez on 25/07/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Enum that reference all type of ads you can get to test your Smart Display SDK integration.
 
 See the adPlacementForTestAd: method documentation for more infos.
 */
typedef NS_ENUM(NSInteger, SASAdPlacementTest) {
    
#pragma mark - Banner ads
    
    /// A placement that will return a MRAID banner ad.
    SASAdPlacementTestBannerMRAID,
    
    /// A placement that will return a Video Read banner ad.
    SASAdPlacementTestBannerVideoRead,
    
    /// A placement that will return a Video Read 360° banner ad.
    SASAdPlacementTestBannerVideoRead360,
    
    /// A placement that will return a parallax banner ad.
    SASAdPlacementTestBannerParallax,
    
#pragma mark - Interstitial ads
    
    /// A placement that will return a MRAID interstitial ad.
    SASAdPlacementTestInterstitialMRAID,
    
    /// A placement that will return a video interstitial ad.
    SASAdPlacementTestInterstitialVideo,
    
    /// A placement that will return a video 360° interstitial ad.
    SASAdPlacementTestInterstitialVideo360,
    
#pragma mark - Rewarded video ads
    
    /// A placement that will return a rewarded video interstitial ad with an end card.
    SASAdPlacementTestRewardedVideoWithEndCard,
    
#pragma mark - Native ads
    
    /// A placement that will return a native ad with an icon and some text assets.
    SASAdPlacementTestNativeAdIconAndTextAssets,
    
    /// A placement that will return a native ad with a cover image and some text assets.
    SASAdPlacementTestNativeAdCoverAndTextAssets,
    
    /// A placement that will return a native ad with an icon, a cover image and some text assets.
    SASAdPlacementTestNativeAdIconAndCoverAndTextAssets,
    
    /// A placement that will return a native ad with some text assets.
    SASAdPlacementTestNativeAdTextAssets,
    
    /// A placement that will return a native ad with a video creative.
    SASAdPlacementTestNativeAdVideo
    
};


/**
 Represents an ad placement.
 
 An ad placement aggregates several information like the site id, page id and format id that
 will be used when loading an ad.
 
 You can use some optional parameters to forward a keyword targeting string or to create exclusion
 using the master flag.
 */
@interface SASAdPlacement : NSObject <NSCoding, NSCopying>

#pragma mark - Placement properties

/// The site id that should be used when loading an ad.
@property (nonatomic, readonly) NSInteger siteId;

/// The page id (if the page name is not set) that should be used when loading an ad.
@property (nonatomic, readonly) NSInteger pageId;

/// The page name (if the page id is not set) that should be used when loading an ad.
@property (nonatomic, readonly, nullable) NSString *pageName;

/// The format id that should be used when loading an ad.
@property (nonatomic, readonly) NSInteger formatId;

/// YES if the master flag that should be used when loading an ad, NO otherwise.
@property (nonatomic, readonly) BOOL master;

/// A set of keywords that will be used when loading an ad to receive more relevant advertising.
///
/// Keywords are typically used to target ad campaign insertions at specific user segments. They should be
/// formatted as comma-separated key-value pairs (e.g. "gender=female,age=27").
///
/// On the Smart manage interface, keyword targeting options can be found under the Targeting / Keywords
/// section when managing campaign insertions.
@property (nonatomic, readonly, nullable) NSString *keywordTargeting;

#pragma mark - Initializers

/**
 Initialize a new instance of SASAdPlacement.
 
 @param siteId The siteId created on the Smart manage interface. Create a new site id for every unique application on your network.
 @param pageId The pageId created on the Smart manage interface. It is recommanded to create a new page id for every unique screen in your application.
 @param formatId The formatId created on the Smart manage interface. It is recommanded to create a new format id for every type of ad you will integrate in your application.
 
 @return An initialized instance of SASAdPlacement.
 */
- (instancetype)initWithSiteId:(NSInteger)siteId pageId:(NSInteger)pageId formatId:(NSInteger)formatId;

/**
 Initialize a new instance of SASAdPlacement.
 
 @param siteId The siteId created on the Smart manage interface. Create a new site id for every unique application on your network.
 @param pageId The pageId created on the Smart manage interface. It is recommanded to create a new page id for every unique screen in your application.
 @param formatId The formatId created on the Smart manage interface. It is recommanded to create a new format id for every type of ad you will integrate in your application.
 @param  master The master flag. If this is YES, the a Page view will be counted. This should have the YES value for the first ad on the page, and NO for the others (if you have more than one ad on the same page).
 
 @return An initialized instance of SASAdPlacement.
 */
- (instancetype)initWithSiteId:(NSInteger)siteId pageId:(NSInteger)pageId formatId:(NSInteger)formatId master:(BOOL)master;

/**
 Initialize a new instance of SASAdPlacement.
 
 @param siteId The siteId created on the Smart manage interface. Create a new site id for every unique application on your network.
 @param pageName The pageName created on the Smart manage interface. It is recommanded to create a new page name for every unique screen in your application.
 @param formatId The formatId created on the Smart manage interface. It is recommanded to create a new format id for every type of ad you will integrate in your application.
 
 @return An initialized instance of SASAdPlacement.
 */
- (instancetype)initWithSiteId:(NSInteger)siteId pageName:(nonnull NSString *)pageName formatId:(NSInteger)formatId;

/**
 Initialize a new instance of SASAdPlacement.
 
 @param siteId The siteId created on the Smart manage interface. Create a new site id for every unique application on your network.
 @param pageName The pageName created on the Smart manage interface. It is recommanded to create a new page name for every unique screen in your application.
 @param formatId The formatId created on the Smart manage interface. It is recommanded to create a new format id for every type of ad you will integrate in your application.
 @param  master The master flag. If this is YES, the a Page view will be counted. This should have the YES value for the first ad on the page, and NO for the others (if you have more than one ad on the same page).
 
 @return An initialized instance of SASAdPlacement.
 */
- (instancetype)initWithSiteId:(NSInteger)siteId pageName:(nonnull NSString *)pageName formatId:(NSInteger)formatId master:(BOOL)master;

/**
 Initialize a new instance of SASAdPlacement.
 
 @param siteId The siteId created on the Smart manage interface. Create a new site id for every unique application on your network.
 @param pageId The pageId created on the Smart manage interface. It is recommanded to create a new page id for every unique screen in your application.
 @param formatId The formatId created on the Smart manage interface. It is recommanded to create a new format id for every type of ad you will integrate in your application.
 @param keywordTargeting A string representing a set of keywords that will be passed to Smart to receive more relevant advertising.
 
 @return An initialized instance of SASAdPlacement.
 */
- (instancetype)initWithSiteId:(NSInteger)siteId pageId:(NSInteger)pageId formatId:(NSInteger)formatId keywordTargeting:(nullable NSString *)keywordTargeting;

/**
 Initialize a new instance of SASAdPlacement.
 
 @param siteId The siteId created on the Smart manage interface. Create a new site id for every unique application on your network.
 @param pageId The pageId created on the Smart manage interface. It is recommanded to create a new page id for every unique screen in your application.
 @param formatId The formatId created on the Smart manage interface. It is recommanded to create a new format id for every type of ad you will integrate in your application.
 @param keywordTargeting A string representing a set of keywords that will be passed to Smart to receive more relevant advertising.
 @param master The master flag. If this is YES, the a Page view will be counted. This should have the YES value for the first ad on the page, and NO for the others (if you have more than one ad on the same page).
 
 @return An initialized instance of SASAdPlacement.
 */
- (instancetype)initWithSiteId:(NSInteger)siteId pageId:(NSInteger)pageId formatId:(NSInteger)formatId keywordTargeting:(nullable NSString *)keywordTargeting master:(BOOL)master;

/**
 Initialize a new instance of SASAdPlacement.
 
 @param siteId The siteId created on the Smart manage interface. Create a new site id for every unique application on your network.
 @param pageName The pageName created on the Smart manage interface. It is recommanded to create a new page name for every unique screen in your application.
 @param formatId The formatId created on the Smart manage interface. It is recommanded to create a new format id for every type of ad you will integrate in your application.
 @param keywordTargeting A string representing a set of keywords that will be passed to Smart to receive more relevant advertising.
 
 @return An initialized instance of SASAdPlacement.
 */
- (instancetype)initWithSiteId:(NSInteger)siteId pageName:(nonnull NSString *)pageName formatId:(NSInteger)formatId keywordTargeting:(nullable NSString *)keywordTargeting;

/**
 Initialize a new instance of SASAdPlacement.
 
 @param siteId The siteId created on the Smart manage interface. Create a new site id for every unique application on your network.
 @param pageName The pageName created on the Smart manage interface. It is recommanded to create a new page name for every unique screen in your application.
 @param formatId The formatId created on the Smart manage interface. It is recommanded to create a new format id for every type of ad you will integrate in your application.
 @param keywordTargeting A string representing a set of keywords that will be passed to Smart to receive more relevant advertising.
 @param master The master flag. If this is YES, the a Page view will be counted. This should have the YES value for the first ad on the page, and NO for the others (if you have more than one ad on the same page).
 
 @return An initialized instance of SASAdPlacement.
 */
- (instancetype)initWithSiteId:(NSInteger)siteId pageName:(nonnull NSString *)pageName formatId:(NSInteger)formatId keywordTargeting:(nullable NSString *)keywordTargeting master:(BOOL)master;

/**
 Initialize a new instance of SASAdPlacement corresponding to a test ad.
 
 A test ad will always deliver and will always be from a specific type.
 You can use these tests to verify that your integration will work properly with all types of ads.
 
 Available test ads are listed in the SASAdPlacementTest object.
 
 @warning If you set a test placement, make sure to remove it before
 submitting your application to the App Store.
 
 @param type The type of ad you want to get for ad calls.
 
 @return An initialized instance of SASAdPlacement corresponding to a test ad.
 */
- (instancetype)initWithTestAd:(SASAdPlacementTest)type;

#pragma mark - Convenience initializers

/**
 Returns an initialized SASAdPlacement object.
 
 @param siteId The siteId created on the Smart manage interface. Create a new site id for every unique application on your network.
 @param pageId The pageId created on the Smart manage interface. It is recommanded to create a new page id for every unique screen in your application.
 @param formatId The formatId created on the Smart manage interface. It is recommanded to create a new format id for every type of ad you will integrate in your application.
 
 @return An initialized instance of SASAdPlacement.
 */
+ (instancetype)adPlacementWithSiteId:(NSInteger)siteId pageId:(NSInteger)pageId formatId:(NSInteger)formatId;

/**
 Returns an initialized SASAdPlacement object.
 
 @param siteId The siteId created on the Smart manage interface. Create a new site id for every unique application on your network.
 @param pageId The pageId created on the Smart manage interface. It is recommanded to create a new page id for every unique screen in your application.
 @param formatId The formatId created on the Smart manage interface. It is recommanded to create a new format id for every type of ad you will integrate in your application.
 @param master The master flag. If this is YES, the a Page view will be counted. This should have the YES value for the first ad on the page, and NO for the others (if you have more than one ad on the same page).
 
 @return An initialized instance of SASAdPlacement.
 */
+ (instancetype)adPlacementWithSiteId:(NSInteger)siteId pageId:(NSInteger)pageId formatId:(NSInteger)formatId master:(BOOL)master;

/**
 Returns an initialized SASAdPlacement object.
 
 @param siteId The siteId created on the Smart manage interface. Create a new site id for every unique application on your network.
 @param pageName The pageName created on the Smart manage interface. It is recommanded to create a new page name for every screen in your application.
 @param formatId The formatId created on the Smart manage interface. It is recommanded to create a new format id for every type of ad you will integrate in your application.
 
 @return An initialized instance of SASAdPlacement.
 */
+ (instancetype)adPlacementWithSiteId:(NSInteger)siteId pageName:(nonnull NSString *)pageName formatId:(NSInteger)formatId;

/**
 Returns an initialized SASAdPlacement object.
 
 @param siteId The siteId created on the Smart manage interface. Create a new site id for every unique application on your network.
 @param pageName The pageName created on the Smart manage interface. It is recommanded to create a new page name for every screen in your application.
 @param formatId The formatId created on the Smart manage interface. It is recommanded to create a new format id for every type of ad you will integrate in your application.
 @param master The master flag. If this is YES, the a Page view will be counted. This should have the YES value for the first ad on the page, and NO for the others (if you have more than one ad on the same page).
 
 @return An initialized instance of SASAdPlacement.
 */
+ (instancetype)adPlacementWithSiteId:(NSInteger)siteId pageName:(nonnull NSString *)pageName formatId:(NSInteger)formatId master:(BOOL)master;

/**
 Returns an initialized SASAdPlacement object.
 
 @param siteId The siteId created on the Smart manage interface. Create a new site id for every unique application on your network.
 @param pageId The pageId created on the Smart manage interface. It is recommanded to create a new page id for every unique screen in your application.
 @param formatId The formatId created on the Smart manage interface. It is recommanded to create a new format id for every type of ad you will integrate in your application.
 @param keywordTargeting A string representing a set of keywords that will be passed to Smart to receive more relevant advertising.
 
 @return An initialized instance of SASAdPlacement.
 */
+ (instancetype)adPlacementWithSiteId:(NSInteger)siteId pageId:(NSInteger)pageId formatId:(NSInteger)formatId keywordTargeting:(nullable NSString *)keywordTargeting;

/**
 Returns an initialized SASAdPlacement object.
 
 @param siteId The siteId created on the Smart manage interface. Create a new site id for every unique application on your network.
 @param pageId The pageId created on the Smart manage interface. It is recommanded to create a new page id for every unique screen in your application.
 @param formatId The formatId created on the Smart manage interface. It is recommanded to create a new format id for every type of ad you will integrate in your application.
 @param keywordTargeting A string representing a set of keywords that will be passed to Smart to receive more relevant advertising.
 @param master The master flag. If this is YES, the a Page view will be counted. This should have the YES value for the first ad on the page, and NO for the others (if you have more than one ad on the same page).
 
 @return An initialized instance of SASAdPlacement.
 */
+ (instancetype)adPlacementWithSiteId:(NSInteger)siteId pageId:(NSInteger)pageId formatId:(NSInteger)formatId keywordTargeting:(nullable NSString *)keywordTargeting master:(BOOL)master;

/**
 Returns an initialized SASAdPlacement object.
 
 @param siteId The siteId created on the Smart manage interface. Create a new site id for every unique application on your network.
 @param pageName The pageName created on the Smart manage interface. It is recommanded to create a new page name for every screen in your application.
 @param formatId The formatId created on the Smart manage interface. It is recommanded to create a new format id for every type of ad you will integrate in your application.
 @param keywordTargeting A string representing a set of keywords that will be passed to Smart to receive more relevant advertising.
 
 @return An initialized instance of SASAdPlacement.
 */
+ (instancetype)adPlacementWithSiteId:(NSInteger)siteId pageName:(nonnull NSString *)pageName formatId:(NSInteger)formatId keywordTargeting:(nullable NSString *)keywordTargeting;

/**
 Returns an initialized SASAdPlacement object.
 
 @param siteId The siteId created on the Smart manage interface. Create a new site id for every unique application on your network.
 @param pageName The pageName created on the Smart manage interface. It is recommanded to create a new page name for every screen in your application.
 @param formatId The formatId created on the Smart manage interface. It is recommanded to create a new format id for every type of ad you will integrate in your application.
 @param keywordTargeting A string representing a set of keywords that will be passed to Smart to receive more relevant advertising.
 @param master The master flag. If this is YES, the a Page view will be counted. This should have the YES value for the first ad on the page, and NO for the others (if you have more than one ad on the same page).
 
 @return An initialized instance of SASAdPlacement.
 */
+ (instancetype)adPlacementWithSiteId:(NSInteger)siteId pageName:(nonnull NSString *)pageName formatId:(NSInteger)formatId keywordTargeting:(nullable NSString *)keywordTargeting master:(BOOL)master;

/**
 Returns an initialized SASAdPlacement object corresponding to a test ad.
 
 A test ad will always deliver and will always be from a specific type.
 You can use these tests to verify that your integration will work properly with all types of ads.
 
 Available test ads are listed in the SASAdPlacementTest object.
 
 @warning If you set a test placement, make sure to remove it before
 submitting your application to the App Store.
 
 @param type The type of ad you want to get when loading ads.
 
 @return An initialized instance of SASAdPlacement corresponding to a test ad.
 */
+ (instancetype)adPlacementWithTestAd:(SASAdPlacementTest)type;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

