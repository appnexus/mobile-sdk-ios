//
//  SASNativeAdPlacement.h
//  SmartAdServer
//
//  Created by Loïc GIRON DIT METAZ on 01/09/2015.
//
//

#import <Foundation/Foundation.h>


/**
 Enum that reference all type of ads you can get using the test mode.
 
 See the nativeAdPlacementForTestAd: method documentation for more infos.
 */
typedef NS_ENUM(NSInteger, SASNativeAdPlacementTestAdType) {
    SASNativeAdPlacementTestAdTypeIconAndTextAssets,
    SASNativeAdPlacementTestAdTypeCoverAndTextAssets,
    SASNativeAdPlacementTestAdTypeIconAndCoverAndTextAssets,
    SASNativeAdPlacementTestAdTypeTextAssets,
    SASNativeAdPlacementTestAdTypeVideo
};



/**
 Class representing a configuration of a native ad call.
 */
@interface SASNativeAdPlacement : NSObject

/**
 The baseURL that will be used for ad calls (mandatory).
 */
@property (nonatomic, readonly, nonnull, strong) NSURL *baseURL;

/**
 The siteID that will be used for ad calls (mandatory).
 */
@property (nonatomic, readonly) NSInteger siteID;

/**
 The pageID that will be used for ad calls (mandatory).
 */
@property (nonatomic, readonly, nonnull, strong) NSString *pageID;

/**
 The formatID that will be used for ad calls (mandatory).
 */
@property (nonatomic, readonly) NSInteger formatID;

/**
 The target that will be used for ad calls (optional).
 */
@property (nonatomic, readonly, nullable, strong) NSString *target;

/**
 The value of the timeout for the ad calls (optional).
 */
@property (nonatomic, readonly) NSTimeInterval timeout;


/**
 Initializes a SASNativeAdPlacement object.
 
 @param baseURL The baseURL that will be used for ad calls (mandatory).
 @param siteID The siteID that will be used for ad calls (mandatory).
 @param pageID The pageID that will be used for ad calls (mandatory).
 @param formatID The formatID that will be used for ad calls (mandatory).
 @param target The target that will be used for ad calls (optional).
 @param timeout The value of the timeout for the ad calls (optional).
 
 @return An initialized instance of SASNativeAdPlacement.
 */
- (nonnull instancetype)initWithBaseURL:(nonnull NSURL *)baseURL siteID:(NSInteger)siteID pageID:(nonnull NSString *)pageID formatID:(NSInteger)formatID target:(nullable NSString *)target timeout:(NSTimeInterval)timeout;

/**
 Returns an initialized SASNativeAdPlacement object.
 
 @param baseURL The baseURL that will be used for ad calls (mandatory).
 @param siteID The siteID that will be used for ad calls (mandatory).
 @param pageID The pageID that will be used for ad calls (mandatory).
 @param formatID The formatID that will be used for ad calls (mandatory).
 @param target The target that will be used for ad calls (optional).
 
 @return An initialized instance of SASNativeAdPlacement.
 */
+ (nonnull instancetype)nativeAdPlacementWithBaseURL:(nonnull NSURL *)baseURL siteID:(NSInteger)siteID pageID:(nonnull NSString *)pageID formatID:(NSInteger)formatID target:(nullable NSString *)target;

/**
 Returns an initialized SASNativeAdPlacement object.
 
 @param baseURL The baseURL that will be used for ad calls (mandatory).
 @param siteID The siteID that will be used for ad calls (mandatory).
 @param pageID The pageID that will be used for ad calls (mandatory).
 @param formatID The formatID that will be used for ad calls (mandatory).
 @param target The target that will be used for ad calls (optional).
 @param timeout The value of the timeout for the ad calls (optional).
 
 @return An initialized instance of SASNativeAdPlacement.
 */
+ (nonnull instancetype)nativeAdPlacementWithBaseURL:(nonnull NSURL *)baseURL siteID:(NSInteger)siteID pageID:(nonnull NSString *)pageID formatID:(NSInteger)formatID target:(nullable NSString* )target timeout:(NSTimeInterval)timeout;

/**
 Returns an initialized SASNativeAdPlacement object corresponding to a test insertion.
 
 A test insertion is an insertion that will always deliver and will always be from a specific type.
 You can use these test insertions to verify that your implementation of the native ad will work properly with all types of ads.
 
 Available test insertions are listed in the SASNativeAdPlacementTestAdType object.
 
 @param type The type of insertion you want to get for ad calls.
 
 @return An initialized instance of SASNativeAdPlacement corresponding to a test insertion.
 */
+ (nonnull instancetype)nativeAdPlacementForTestAd:(SASNativeAdPlacementTestAdType)type;

@end
