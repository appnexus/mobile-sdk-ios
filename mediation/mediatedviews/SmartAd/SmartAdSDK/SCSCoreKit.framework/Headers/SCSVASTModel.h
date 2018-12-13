//
//  SCSVASTModel.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 21/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SCSVASTAd, SCSVASTURL;

@interface SCSVASTModel : NSObject

/// The version of the model.
@property (nonatomic, readonly) NSString *version;

/// The ads contained in this model.
@property (nonatomic, readonly) NSArray <SCSVASTAd *> *ads;

/// The error pixels to be called if the model is not valid for any reason.
@property (nonatomic, readonly) NSArray <SCSVASTURL *> *errorPixels;

- (instancetype)init NS_UNAVAILABLE;

/**
 Initializer from a NSDictionary generated from XML.
 
 @param dictionary A dictionary representation of the XML.
 
 @return An initialized instance of SCSVASTModel.
 */
- (nullable instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 Returns the number of sequenced ads in the model (which is the size of the adpod).
 
 @return the number of sequenced ads in the model.
 */
- (NSInteger)sequencedAdsCount;

/**
 Returns the number of wrapper ads in the model.
 
 @return the number of wrapper ads in the model.
 */
- (NSInteger)wrapperCount;

/**
 Indicates whether or not the model main ads are an adpod.
 
 @return true if the model contains an AdPod.
 */
- (BOOL)isAdPod;

/**
 Returns the model's first ad.
 
 @return the model's first ad.
 */
- (nullable SCSVASTAd *)firstAd;

@end

NS_ASSUME_NONNULL_END
