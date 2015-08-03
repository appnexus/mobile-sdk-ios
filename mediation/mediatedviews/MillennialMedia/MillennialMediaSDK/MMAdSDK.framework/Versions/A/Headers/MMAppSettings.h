//
//  MMAppSettings.h
//  MMAdSDK
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#ifndef MMAppSettings_Header_h
#define MMAppSettings_Header_h

@import Foundation;

/**
 * The object used to configure persistent app-wide settings which are integral for SDK operation.
 */
@interface MMAppSettings : NSObject

/** The siteId of this application. */
@property (nonatomic, copy, nullable) NSString *siteId;

/** The mediator initializing ad requests. Should only be set by mediation adapters. */
@property (nonatomic, copy, nullable) NSString *mediator;

/**
 * Returns the current state of COPPA (Children's Online Privacy Protection Act) for the SDK.
 *
 * Returns `nil` if this value has not been explicitly set, or `"true"` or `"false"` based on the
 * value set in `setCoppaCompliance:`.
 */
@property (nonatomic, readonly, nullable) NSString *coppa;

/**
 * Set to `YES` to enforce COPPA (Children's Online Privacy Protection Act) restrictions on ads returned by the ad server.
*/
- (void)setCoppaCompliance:(BOOL)compliance;

@end

#endif
