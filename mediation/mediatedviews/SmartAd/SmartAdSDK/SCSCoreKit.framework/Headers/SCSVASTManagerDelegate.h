//
//  Header.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 22/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@class SCSVASTAd;

@protocol SCSVASTManagerProtocol;

@protocol SCSVASTManagerDelegate <NSObject>

/**
 Called when the manager has properly parsed a VAST XML into a valid SCSVASTModel object.
 */
- (void)vastManagerIsReadyToProvideAds;

/**
 Called when the manager fails to parse a VAST XML into a valid SCSVASTModel.
 
 @param error The encountered error as an NSError.
 */
- (void)vastManagerDidFailWithError:(nullable NSError *)error;

/**
 Called when the manager starts to resolve a Wrapper Ad from the root VAST Model. (Wrapper Pixa)
 
 @param manager An object conforming to the SCSVASTManagerProtocol.
 @param ad The SCSVASTAd instance being resolved.
 */
- (void)vastManager:(id <SCSVASTManagerProtocol>)manager didStartToResolveWrapperAd:(SCSVASTAd *)ad;

/**
 Called when the manager resolving a wrapper finds no valid ad in the response. (VNoAd Pixa)
 
 @param manager An object conforming to the SCSVASTManagerProtocol.
 @param ad The SCSVASTAd instance being resolved.
 */
- (void)vastManager:(id <SCSVASTManagerProtocol>)manager didFailToResolveWrapperAd:(SCSVASTAd *)ad;

@end

NS_ASSUME_NONNULL_END
