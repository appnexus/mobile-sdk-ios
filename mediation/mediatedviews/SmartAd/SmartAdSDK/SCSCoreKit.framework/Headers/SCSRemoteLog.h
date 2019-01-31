//
//  SCSRemoteLog.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 18/09/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// The level for the Log object
typedef NS_ENUM(NSInteger, SCSRemoteLogLevel) {
    SCSRemoteLogLevelNone = 0,
    SCSRemoteLogLevelDebug = 1,
    SCSRemoteLogLevelInfo = 2,
    SCSRemoteLogLevelWarning = 3,
    SCSRemoteLogLevelError = 4,
};

/**
 Represent an object to be posted by the SCSRemoteLogger.
 Logic processing and enrichment occurs in SCSRemoteLogger subclasses from clients SDKs.
 */
@interface SCSRemoteLog : NSObject

/// The timestamp of the Log - Timezone UTC. Format:"YYYY-MM-DD'T'HH:MM:ss.SSS'ZZZ".
@property (nonatomic, readonly) NSString *timestamp;

/// The message associated with the Log.
@property (nullable, nonatomic, readonly) NSString *message;

/// The category (source) of the Log.
@property (nonatomic, readonly) NSString *category;

/// The level of the Log.
@property (nonatomic, readonly) SCSRemoteLogLevel level;

/// The sampling rate of the Log.
@property (nonatomic, readonly) NSUInteger samplingRate;

/// The type of the Log.
@property (nullable, nonatomic, readonly) NSString *type;

/// The metric type associated with the Log.
@property (nullable, nonatomic, readonly) NSString *metricType;

/// The metric value associated with the Log.
@property (nullable, nonatomic, readonly) NSString *metricValue;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
