//
//  SCSNetworkInfo.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 22/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSEnums.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Class used to retrieve network informations.
 */
@interface SCSNetworkInfo : NSObject

/// The shared instance of the SCSNetworkInfo object.
@property (class, nonatomic, readonly) SCSNetworkInfo *sharedInstance NS_SWIFT_NAME(shared);

/// The current network status of the data connection.
@property (nonatomic, readonly) SCSNetworkInfoNetworkStatus networkStatus;

/// The type (wifi / data) of data connection currently in use.
@property (nonatomic, readonly) SCSNetworkInfoConnectionType networkType;

/// The type network access technology type.
@property (nonatomic, readonly) SCSNetworkInfoNetworkAccessType networkAccessType;

/// true if the network is reachable, false otherwise.
@property (nonatomic, readonly) BOOL isNetworkReachable;

/// true if the network is reachable using a wifi connection (or equivalent), false otherwise.
@property (nonatomic, readonly) BOOL isReachableOnWiFi;

/// The local IP address of the Wi-Fi network interface (aka 'en0') if available.
///
/// Note: this property will be nil if the Wi-Fi is disabled and will return the LOCAL IP ADDRESS
/// if the Wi-Fi is enabled, not the WAN address!
@property (nonatomic, readonly) NSString *wifiLocalIPAddress;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
