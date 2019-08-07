//
//  SCSVASTManager.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 22/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSVASTManagerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SCSVASTManagerDelegate, SCSVASTAdAdapterProtocol;
@class SCSURLSession, SCSPixelManager, SCSVASTManagerResponse;

/**
 Default implementation of the SCSCoreKit's VAST Manager.
 */
@interface SCSVASTManager : NSObject <SCSVASTManagerProtocol>

/// The delegate of the VASTManager instance
@property (nullable, nonatomic, weak) id <SCSVASTManagerDelegate> delegate;

/// The adapter used to transform VASTAds into consumable ads.
@property (nullable, nonatomic, weak) id <SCSVASTAdAdapterProtocol> adapter;

- (instancetype)init NS_UNAVAILABLE;

/**
 Public initializer
 
 @param delegate The Manager's delegate.
 @param adapter The adapter to transform VAST Ads in the relevant video ad for the given SDK.
 @param sessionManager The Session manager for distant calls. Used only for Unit testing.
 @param pixelManager The pixel manager instance to call error pixels.
 @param requestTimeout The timeout for requests (wrapper resolution).
 @param maximumWrappers The maximum number of wrappers that can be resolved in a wrapper chain.
 @param handleWrappersAdpods Indicates whether or not the manager should "insert" wrapper adpods in the ad store.
 */
- (instancetype)initWithDelegate:(nullable id <SCSVASTManagerDelegate>)delegate
                         adapter:(nullable id <SCSVASTAdAdapterProtocol>)adapter
                  sessionManager:(nullable SCSURLSession *)sessionManager //The session manager is only passed for unit tests...
                    pixelManager:(nullable SCSPixelManager *)pixelManager //The pixel manager is only passed for unit tests...
                  requestTimeout:(NSTimeInterval)requestTimeout
                 maximumWrappers:(NSInteger)maximumWrappers
            handleWrappersAdpods:(BOOL)handleWrappersAdpods NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
