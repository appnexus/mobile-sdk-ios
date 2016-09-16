//
//  MMSDK.h
//  MMAdSDK
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#ifndef MMSDK_Header_h
#define MMSDK_Header_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_OPTIONS(NSUInteger, MMLogFlag) {
    MMLogFlagError  = (1 << 0),
    MMLogFlagWarn   = (1 << 1),
    MMLogFlagInfo   = (1 << 2),
    MMLogFlagDebug  = (1 << 3)
};

/** 
 * Log levels for the SDK. `Error` is the least verbose level, `Debug` the most verbose.
 * Using these values rather than the `MMLogFlag` enum is recommended.
 */
typedef NS_ENUM(NSUInteger, MMLogLevel) {
    MMLogLevelError = MMLogFlagError,
    MMLogLevelWarn  = (MMLogLevelError|MMLogFlagWarn),
    MMLogLevelInfo  = (MMLogLevelWarn|MMLogFlagInfo),
    MMLogLevelDebug = (MMLogLevelInfo|MMLogFlagDebug)
};

@class MMAppSettings;
@class MMUserSettings;

/**
 * The MMSDK class is the global singleton used to initialize the SDK state, and manage shared
 * settings.
 *
 * ## Initializing the MMSDK.
 *
 * The appSettings object is optional for MMSDK initialization.
 * This is a readonly object, however, its properties may be changed after initialization.
 *
 * The userSettings object is also optional.
 * This is a readwrite object, so it may be changed after initialization.
 *
 * Usage example:
 * <pre><code>
 *    MMAppSettings *appSettings = [[MMAppSettings alloc] init];
 *    appSettings.siteId = @"<siteId>";
 *    appSettings.mediator = @"<mediator>";
 *    [appSettings setCoppaCompliance:<BOOL>];
 *
 *    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
 *    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
 *    NSDate *dateOfBirth = [dateFormatter dateFromString:@"12/25/1985"];
 *
 *    MMUserSettings *userSettings = [[MMUserSettings alloc] init];
 *    userSettings.age = @(30);
 *    userSettings.children = @(3);
 *    userSettings.education = MMEducationBachelors;
 *    userSettings.dob = dateOfBirth;
 *
 *    [[MMSDK sharedInstance] initializeWithSettings:appSettings withUserSettings:userSettings];
 * </pre></code>
 */
@interface MMSDK : NSObject

/**
 * The shared instance of the Millennial Media SDK.
 *
 * @return The MMSDK singleton.
 */
+(nonnull instancetype)sharedInstance;

/**
 * Sets the console log level for the SDK.
 *
 * @param level The log level to be set.
 */
+(void)setLogLevel:(MMLogLevel)level;

/**
 * Initializes the SDK as a whole. This must be called before any ads are requested.
 *
 * @param appSettings  The appSettings object. Optional.
 * @param userSettings The userSettings object. Optional.
 */
-(void)initializeWithSettings:(nullable MMAppSettings *)appSettings withUserSettings:(nullable MMUserSettings *)userSettings;

/**
 * The version of the Millennial Ad SDK.
 *
 * @return The semantic version of the SDK.
 */
-(nonnull NSString*)version;

/**
 * Whether or not to send geolocation information along with each ad request.
 *
 * When set to YES, location information is sent with ad requests ONLY if location permissions are granted for the app.
 * Enabling this will NOT prompt the user for location authorization. Providing location data will help to serve more
 * relevant ads to your users.
 *
 * Set to NO to explicitly disable sending location information with ad requests. Default is YES.
 */
@property (nonatomic, assign) BOOL sendLocationIfAvailable;

/**
 * The CLLocationManager initialized and started by the Millennial Media SDK when location permission is granted by the
 * user and sendLocationIfAvailable is set to YES.
 *
 * This is a readonly property and will be nil when sending location information is explicitly disabled.
 */
@property (nonatomic, readonly, nullable) CLLocationManager* locationManager;

/**
 * Whether or not the SDK has been initialized. The SDK must be initialized before any ads are requested.
 */
@property (nonatomic, assign, readonly) BOOL isInitialized;

/**
 * The SDK's global settings for the application. This object must be set when initializing the SDK.
 *
 * Although this is a read-only property, the returned `MMAppSettings` object may be modified in-place to update
 * any relevant values.
 */
@property (nonatomic, readonly, nullable) MMAppSettings* appSettings;

/**
 * The SDK's user settings object. This can be reset during normal app operations and does not have to be provided
 * at the time of initialization.
 */
@property (nonatomic, readwrite, nullable) MMUserSettings* userSettings;

@end

#endif
