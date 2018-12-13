//
//  SCSEnums.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 23/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Enum that defines all the possible policies for video skipping policy.
typedef NS_ENUM(NSInteger, SCSVideoSkipPolicy) {
    /// The video is skippable.
    SCSVideoSkipPolicySkippable                     = 0,
    
    /// The video is not skippable.
    SCSVideoSkipPolicyNotSkippable                  = 1,
    
    /// The video is skippable if defined in VAST.
    SCSVideoSkipPolicyVASTControl                   = 2,
};

/// Enum that defines all the predefined call to action.
typedef NS_ENUM(NSInteger, SCSCallToActionType) {
    /// The user will be redirected to a website.
    SCSCallToActionTypeWebsite                      = 0,
    
    /// The user will be redirected to a video.
    SCSCallToActionTypeVideo                        = 1,
    
    /// The user will be redirected to the AppStore.
    SCSCallToActionTypeStore                        = 2,
    
    /// Custom call to action.
    SCSCallToActionTypeCustom                       = 3,
    
    /// No call to action..
    SCSCallToActionTypeNone                         = 4,
};

/// Type of connection that is being used by the device (if applicable).
typedef NS_ENUM(NSUInteger, SCSNetworkInfoConnectionType) {
    /// No connection is used (or connection type unknown).
    SCSNetworkInfoConnectionTypeNotReachableOrUnknown,
    
    /// A WiFi connection is being used.
    SCSNetworkInfoConnectionTypeWiFi,
    
    /// A non WiFi connection is being used (probably a data connection).
    SCSNetworkInfoConnectionTypeOther,
};

/// Current status of the network connection.
typedef NS_ENUM(NSUInteger, SCSNetworkInfoNetworkStatus) {
    /// Network status unknown.
    SCSNetworkInfoNetworkStatusUnknown,
    
    /// The network is reachable.
    SCSNetworkInfoNetworkStatusNotReachable,
    
    /// The network is not reachable.
    SCSNetworkInfoNetworkStatusReachable,
};


/// Current radio technology used by the device
typedef NS_ENUM(NSUInteger, SCSNetworkInfoNetworkAccessType) {
    /// Radio Technology is unknown.
    SCSNetworkInfoNetworkAccessTypeUnknown,
    
    /// Radio Technology is Edge or equivalent.
    SCSNetworkInfoNetworkAccessTypeEdge,
    
    /// Radio Technology is 3G or equivalent.
    SCSNetworkInfoNetworkAccessType3G,
    
    /// Radio Technology is 3G+ or equivalent.
    SCSNetworkInfoNetworkAccessType3GPlus,
    
    /// Radio Technology is H+ or equivalent.
    SCSNetworkInfoNetworkAccessTypeHPlus,
    
    /// Radio Technology is 4G or equivalent.
    SCSNetworkInfoNetworkAccessType4G,
    
    /// Radio Technology is WIFI or equivalent.
    SCSNetworkInfoNetworkAccessTypeWIFI,
};
