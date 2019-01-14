//
//  SCSVASTAdAdapterProtocol.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 20/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import "SCSVideoAdProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class SCSVASTAd;
@protocol SCSVideoAdProtocol;

@protocol SCSVASTAdAdapterProtocol <NSObject>

/**
 Called when a VAST Ad needs to be converted to a consumable video ad
 
 returns An object compliant with the SCSVideoAdProtocol or nil if conversion fails.
 */
- (nullable id <SCSVideoAdProtocol>)convertVASTAdToConsumableVideoAd:(SCSVASTAd *)ad NS_SWIFT_NAME(convertVASTAdToConsumableVideoAd(_:));

@end

NS_ASSUME_NONNULL_END
