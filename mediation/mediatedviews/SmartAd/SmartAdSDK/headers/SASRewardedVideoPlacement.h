//
//  SASRewardedVideoPlacement.h
//  SmartAdServer
//
//  Created by Thomas Geley on 13/06/2017.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SASRewardedVideoPlacement : NSObject

/// An integer representing the page id (if page name is not set) that should be passed to Smart AdServer to receive advertising.
@property (nonatomic, readonly) NSInteger pageId;

/// A String representing the page name (if page id is not set) that should be passed to Smart AdServer to receive advertising.
@property (nonatomic, readonly, nullable) NSString *pageName;

/// An integer representing the format id that should be passed to Smart AdServer to receive instream advertising format.
@property (nonatomic, readonly) NSInteger formatId;

/**
 * A string representing a set of keywords that will be passed to Smart AdServer to receive more relevant advertising.
 *
 * Target strings are typically used to target ad campaign insertions at specific user segments. They should be
 * formatted as comma-separated key-value pairs (e.g. "gender=female,age=27").
 *
 * On the Smart AdServer manage interface, keyword targeting options can be found under the Targeting / Keywords
 * section when managing campaign insertions.
 *
 */
@property (nonatomic, readonly, nullable) NSString *target;

/**
 Initialize a new instance of SASRewardedVideoPlacement.
 
 @param pageId The pageId created on the Smart AdServer manage interface. It is recommanded to create a new page id for every unique screen in your application.
 @param formatId The formatId created on the Smart AdServer manage interface. It is recommanded to create a new format Id for every type of ad you will integrate in your application.
 @param target A string representing a set of keywords for specific targeting.
 
 @return An initialized instance of SASRewardedVideoPlacement.
 */
- (instancetype)initWithPageId:(NSInteger)pageId formatId:(NSInteger)formatId target:(nullable NSString *)target;

/**
 Initialize a new instance of SASRewardedVideoPlacement.
 
 @param pageName The pageName created on the Smart AdServer manage interface. It is recommanded to create a new page name for every unique screen in your application.
 @param formatId The formatId created on the Smart AdServer manage interface. It is recommanded to create a new format Id for every type of ad you will integrate in your application.
 @param target A string representing a set of keywords for specific targeting.
 
 @return An initialized instance of SASRewardedVideoPlacement.
 */
- (instancetype)initWithPageName:(NSString *)pageName formatId:(NSInteger)formatId target:(nullable NSString *)target;

/**
 Returns an initialized SASRewardedVideoPlacement object.
 
 @param pageId The pageId created on the Smart AdServer manage interface. It is recommanded to create a new page id for every unique screen in your application.
 @param formatId The formatId created on the Smart AdServer manage interface. It is recommanded to create a new format Id for every type of ad you will integrate in your application.
  @param target A string representing a set of keywords for specific targeting.
 
 @return An initialized instance of SASRewardedVideoPlacement.
 */
+ (instancetype)rewardedVideoPlacementWithPageId:(NSInteger)pageId formatId:(NSInteger)formatId target:(nullable NSString *)target;

/**
 Returns an initialized SASRewardedVideoPlacement object.
 
 @param pageName The pageName created on the Smart AdServer manage interface. It is recommanded to create a new page name for every unique screen in your application.
 @param formatId The formatId created on the Smart AdServer manage interface. It is recommanded to create a new format Id for every type of ad you will integrate in your application.
 @param target A string representing a set of keywords for specific targeting.
 
 @return An initialized instance of SASRewardedVideoPlacement.
 */
+ (instancetype)rewardedVideoPlacementWithPageName:(NSString *)pageName formatId:(NSInteger)formatId target:(nullable NSString *)target;


- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
