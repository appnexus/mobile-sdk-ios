//
//  SCSFrameworkInfo.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 23/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Retrieve some informations about the SCSCoreKit framework.
 */
@interface SCSFrameworkInfo : NSObject

/// The shared instance of the SCSFrameworkInfo object.
@property (class, nonatomic, readonly) SCSFrameworkInfo *sharedInstance NS_SWIFT_NAME(shared);

/// The framework's name.
@property (nonatomic, readonly) NSString *frameworkName;

/// The framework's bundle identifier.
@property (nonatomic, readonly) NSString *frameworkBundleIdentifier;

/// The framework's version string.
@property (nonatomic, readonly) NSString *frameworkVersionString;

/// true if the framework has been built in DEBUG, false if the framework has been built in RELEASE.
@property (nonatomic, readonly) BOOL frameworkBuiltInDebug;

/// The framework's revision string.
@property (nonatomic, readonly) NSString *frameworkRevisionString;

@end

NS_ASSUME_NONNULL_END
