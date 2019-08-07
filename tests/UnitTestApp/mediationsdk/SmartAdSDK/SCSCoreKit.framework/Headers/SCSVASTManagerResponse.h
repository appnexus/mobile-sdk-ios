//
//  SCSVASTManagerResponse.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 23/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SCSVideoAdProtocol;

/**
 Response of a SCSVASTManagerResponse for a [nextAd] pull.
 */
@interface SCSVASTManagerResponse : NSObject

/// The video ad (conforms to SCSVideoAdProtocol) returned by the SCSVASTManager.
@property (nonatomic, strong, nullable) id <SCSVideoAdProtocol> ad;

/// An error associated to the [nextAd] request.
@property (nonatomic, strong, nullable) NSError *error;

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize a new SCSVASTManagerResponse.
 
 @param ad The Ad returned by the manager if available.
 @param error An error associated with ad request if available.
 */
- (instancetype)initWithAd:(nullable id <SCSVideoAdProtocol>)ad error:(nullable NSError *)error NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
