//
//  SCSLog.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 20/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SCSLogDataSource;

/// Tell the severity of the logs. Debug level logs are a special case, see SCSLogLevelDebug for details.
typedef NS_ENUM(NSUInteger, SCSLogLevel) {
    /// Debug logs are for debugging purpose only. They are always displayed when debug logging
    /// is enabled no matter what is set for isLoggingEnabled and are always hidden otherwise.
    SCSLogLevelDebug,
    
    /// Info logs display useful information to the user.
    SCSLogLevelInfo,
    
    /// Error logs warn the user about errors inside the SDK or about a bad usage of an API.
    SCSLogLevelError,
};

/**
 Log informations into _Xcode_ console.
 
 Each SDK based on SCSCoreKit should have an unique instance of this class to allow users
 to enable/disable logging easily.
 
 To do that, the SDK should creates its own _SDKLog_ class that inherits from SCSLog, then override
 the method ```+(SCSLog *)sharedInstance``` to customize the logger parameters.
 
 The new logger can than be used normally:
 
     [[SDKLog sharedInstance] logMessage:@"Message"];
 */
@interface SCSLog : NSObject

/// The shared instance of the SCSLog object.
@property (class, nonatomic, readonly) SCSLog *sharedInstance NS_SWIFT_NAME(shared);

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize a new Log object.
 
 @param tag The tag that will be displayed before each log message.
 @param dataSource the object that will be used to decide whether to log the message or not.
 @param debugLoggingEnabled true if debug level logs should be displayed.
 */
- (instancetype)initWithTag:(NSString *)tag dataSource:(id <SCSLogDataSource>)dataSource debugLoggingEnabled:(BOOL)debugLoggingEnabled NS_DESIGNATED_INITIALIZER;

/**
 Log a message with the SCSLogLevelDebug level in Xcode console if possible.
 
 Note: Messages with log level debug will always be displayed when the framework is in DEBUG
 and never displayed in RELEASE. Messages with other log level will be displayed if the dataSource
 allows it.
 
 @param message The message that should be logged.
 */
- (void)logMessage:(NSString *)message;

/**
 Log a message in Xcode console if possible.
 
 Note: Messages with log level debug will always be displayed when the framework is in DEBUG
 and never displayed in RELEASE. Messages with other log level will be displayed if the dataSource
 allows it.
 
 @param level The level of the message.
 @param message The message that should be logged.
 */
- (void)logMessage:(NSString *)message level:(SCSLogLevel)level;

/**
 Displays a stack trace with the SCSLogLevelDebug level into the Xcode console if possible.
 */
- (void)logStackTrack;

/**
 Display a stack trace into the Xcode console if possible.
 
 @param level The level of the stack trace message.
 */
- (void)logStackTrackWithLevel:(SCSLogLevel)level;

@end

NS_ASSUME_NONNULL_END
