//
//  SCSDeviceInfoProviderProtocol.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 23/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SCSLocationProviderDelegate;

/**
 Protocol that must be implemented by all classes capable of retrieving informations for SCSDeviceInfo class.
 */
@protocol SCSDeviceInfoProviderProtocol <NSObject>

/**
 Returns the device platform/modelName.
 
 @return The device platform/modelName.
 */
- (NSString *)currentPlatform;

/**
 Returns the device system version.
 
 @return the device system version.
 */
- (NSString *)currentSystem;

/**
 Returns whether or not the device can play 360° videos.
 
 @return whether or not the device can play 360° videos.
 */
- (BOOL)deviceCanPlay360Videos;

/**
 Return the user agent of the phone webview.
 
 @return the user agent of the webview.
 */
- (NSString *)webviewUserAgent;

@end

NS_ASSUME_NONNULL_END
