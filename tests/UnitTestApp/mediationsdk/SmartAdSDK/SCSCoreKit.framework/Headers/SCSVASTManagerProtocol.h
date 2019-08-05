//
//  SCSVASTManagerProtocol.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 04/05/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SCSVASTManagerResponse;

/**
 Public interface of the SCSCoreKit's VAST Manager.
 */
@protocol SCSVASTManagerProtocol <NSObject>

/**
 This method will be called by the AdManager to initiate the VAST Parsing process.
 
 In the end, we should get a rootModel or an error. The delegate (AdManager) will be warned about the outcome and will start to pull ads if possible.
 
 @param xml The XML data used to create the ads store.
 @param url The URL from where the the XML data can be retrived ONLY IF the xml parameter is nil.
 @param timeout The timeout to generate the ad store.
 */
- (void)createAdsStoreWithXML:(nullable NSData *)xml withURL:(nullable NSURL *)url timeout:(NSTimeInterval)timeout NS_SWIFT_NAME(createAdsStore(xml:url:timeout:));

/**
 Called by the AdManager to "pull" an ad when needed.
 
 @param timeout the timeout to get the VASTManager response.
 @param dueToAdFailure indicates whether or not the AdManager is requesting a new ad because it failed to play an ad. Will fetch a passback ad if true.
 
 @return A SCSVASTManagerResponse instance containing an optional object responding to the SCSVideoAdProtocol and an optional error.
 */
- (SCSVASTManagerResponse *)nextAdWithTimeout:(NSTimeInterval)timeout dueToAdFailure:(BOOL)dueToAdFailure NS_SWIFT_NAME(nextAd(timeout:failure:));

/**
 Should be called when communication must be stopped between the SCSVASTManager and its delegate, ie: the totalTimeout is hit.
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
