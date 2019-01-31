//
//  SCSIdentityProviderProtocol.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 23/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCSTransientID;

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol that must be implemented by all classes capable of retrieving ID for the SCSIdentity class.
 */
@protocol SCSIdentityProviderProtocol <NSObject>

/**
 Returns the advertising ID (the result can be empty or invalid depending of the OS version and whether
 the user has disabled the tracking in the Settings).
 
 @return the advertising ID or an invalid /empty ID.
 */
- (NSString *)advertisingID;

/**
 Retrieve the current transient ID and the last generation date (they can be nil if generateNewTransientID
 has never been called on the device).
 
 @return a SCSTransientID containing the transient ID and the last generation date if available, nil otherwise.
 */
- (nullable SCSTransientID *)retrieveTransientID;

/**
 Generate a new transient ID and returns it immediately. The transient ID generated is also saved in user settings and
 can be retrieved by calling retrieveTransientID later.
 
 @return the newly generated transient ID.
 */
- (NSString *)generateNewTransientID;

/**
 Returns the base64url encoded GDPR consent string stored in NSUserDefaults by any IAB certified CMP.
 
 @return the base64url encoded consent string.
 */
- (nullable NSString *)gdprConsentString;


@end

NS_ASSUME_NONNULL_END
