//
//  SCSDeviceInfo.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 23/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SCS_SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SCS_SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SCS_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SCS_SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SCS_SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@protocol SCSDeviceInfoProviderProtocol;

NS_ASSUME_NONNULL_BEGIN

/**
 Retrieve some informations about the current device.
 */
@interface SCSDeviceInfo : NSObject

/// The shared instance of the SCSDeviceInfo object.
@property (class, nonatomic, readonly) SCSDeviceInfo *sharedInstance NS_SWIFT_NAME(shared);

/// The platform (model name) of the device.
@property (nonatomic, readonly) NSString *platform;

/// The operating system running on the device.
@property (nonatomic, readonly) NSString *systemVersion;

/// true if the device is considered to have low performances.
@property (nonatomic, readonly) BOOL hasLowPerformances;

/// true if the device can play 360° videos.
@property (nonatomic, readonly) BOOL canPlay360Videos;

/// The user agent of the web view.
@property (nonatomic, readonly) NSString *userAgent;

/**
 Retrieves device informations from the device info provider passed in parameters.

 @param infoProvider the device informations provider used to retrieve platform, system version and other capabilities.
 */
- (instancetype)initWithInfoProvider:(id <SCSDeviceInfoProviderProtocol>)infoProvider NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
