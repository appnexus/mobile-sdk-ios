//
//  SCSVideoAdProtocol.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 21/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@class SCSVASTAd;

/**
 A protocol for VideoAd objects created from a VAST compliant Ad.
 This video ad objects can be consumed by the client SDKs (VideoKit / DisplayKit)
 */
@protocol SCSVideoAdProtocol <NSObject>

/// An identifier for the video ad object.
@property (nonatomic, readonly, strong) NSString *adID;

/**
 Initializer from a valid SCSVASTAd object.
 
 @param ad The SCSVASTAd used to instantiate the SCSVideoAdProtocol compliant object.
 
 @return an initialized instance of a SCSVideoAdProtocol compliant object.
 */
- (nullable instancetype)initWithVASTAd:(SCSVASTAd *)ad;

/**
 Indicates if the Ad is valid for consumption by the client SDK. This allow to define per SDK validation rules.
 
 @return An error is the Ad is not valid for consumption by other SDKs. Nil otherwise.
 */
- (nullable NSError *)isValid;

@end

NS_ASSUME_NONNULL_END
