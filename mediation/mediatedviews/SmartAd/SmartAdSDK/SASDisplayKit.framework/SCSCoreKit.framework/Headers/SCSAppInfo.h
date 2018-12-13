//
//  SCSAppInfo.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 23/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Retrieve some informations about the current application.
 */
@interface SCSAppInfo : NSObject

/// The shared instance of the SCSAppInfo object.
@property (class, nonatomic, readonly) SCSAppInfo *sharedInstance NS_SWIFT_NAME(shared);

/// The application name.
@property (nonatomic, readonly) NSString *appName;

/// The application bundle identifier.
@property (nonatomic, readonly) NSString *appBundleIdentifier;

@end

NS_ASSUME_NONNULL_END
