//
//  SCSConfiguration.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 22/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SCSRemoteConfigManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class SCSIdentity;

/**
 Hold the configuration of an ad SDK.
 */
@interface SCSConfiguration : NSObject

/// true if the SDK needs to display debug informations in the Xcode console, false otherwise.
@property (nonatomic, assign) BOOL loggingEnabled;

/// true if location information can be used automatically by the SDK (if available), false otherwise.
@property (nonatomic, assign) BOOL allowAutomaticLocationDetection;

/// Coordinate that will be used instead of the actual device location (for testing purpose for instance), kCLLocationCoordinate2DInvalid otherwise (default value).
@property (nonatomic, assign) CLLocationCoordinate2D manualLocation;

/// true if a temporary transient ID can be used if the advertising ID is not available, false otherwise.
@property (nonatomic, assign) BOOL transientIDEnabled;

/// true if the device identifier should be hashed, false otherwise.
@property (nonatomic, assign) BOOL identifierHashing;

/// Last timestamp used in ad call.
@property (nonatomic, assign) UInt32 masterTimestamp;

/// The custom identifier for this device. Setting this property will override the IDFA or DNTID of this device when requesting an Ad.
@property (nullable, nonatomic, strong) NSString *customIdentifier;

/// The baseURL for ad calls.
@property (nonatomic, readonly) NSURL *baseURL;

/// The siteID associated with this configuration.
@property (nonatomic, readonly) NSUInteger siteID;

/// The networkID associated with this configuration.
@property (nonatomic, readonly) NSUInteger networkID;

/**
 Public Initializer
 
 @param loggingEnabled Enables the Logging functionality.
 @param transientIDEnabled Enables the Transient ID functionality.
 @param allowAutomaticLocationDetection Enables the Automatic Location Detection functionality.
 @param manualLocation The location of the user.
 @param identifierHashing Enables the Identifier hashing functionality.
 @param customIdentifier The custom identifier for the device.
 */
- (instancetype)initWithLoggingEnabled:(BOOL)loggingEnabled
                    transientIDEnabled:(BOOL)transientIDEnabled
       allowAutomaticLocationDetection:(BOOL)allowAutomaticLocationDetection
                        manualLocation:(CLLocationCoordinate2D)manualLocation
                     identifierHashing:(BOOL)identifierHashing
                      customIdentifier:(nullable NSString *)customIdentifier NS_DESIGNATED_INITIALIZER;

/**
 Return the current device identity.
 @return the current device identity.
 */
- (SCSIdentity *)deviceIdentity;

/**
 Configure the SDK for a given siteID. This will customize the SDK behavior for your site ID: for example retrieving automatically your baseURL for faster ad requests, enable specific logging, etc...
 
 This method MUST be called before performing any Ad request and *only once per Application's lifecycle*.
 Make sure you call this method in the - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions method of your Application's delegate.
 
 @param siteID The siteID for your application in Manage interface. Contact your account manager if you have trouble finding this ID.
 @param remoteConfigManager An instance of remote config manager used by the SDK to fetch the configuration, this reference is needed because SCSConfiguration will sometimes triggers a fetch.
 
 @return an NSError if something went wrong when trying to configure the SDK. Nil if everything went OK.
 */
- (nullable NSError *)configureWithSiteID:(NSUInteger)siteID remoteConfigManager:(SCSRemoteConfigManager *)remoteConfigManager;

/**
 Return if the SDK has been properly configured by calling.
 @return whether or not the SDK has been properly configured.
 */
- (BOOL)isConfigured;

/**
 Ask the SCSRemoteConfigManager to fetch the configuration for the given siteID.
 
 @param forced Whether or not the SCSRemoteConfigManager should take the expiration into account. YES to ignore expiration.
 */
- (void)fetchRemoteConfiguration:(BOOL)forced;

/**
 Configure the SCSConfiguration instance using dictionary fetched from the remote config manager.
 
 @param smartDict The Smart AdServer config dictionary.
 */
- (void)configureWithSmartDictionary:(NSDictionary *)smartDict;

/**
 Schedule a remote configuration fetching retry if necessary (depending on the provided error if any).
 
 @param error The error from the previous fetch.
 */
- (void)retryRemoteConfigurationAfterError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
