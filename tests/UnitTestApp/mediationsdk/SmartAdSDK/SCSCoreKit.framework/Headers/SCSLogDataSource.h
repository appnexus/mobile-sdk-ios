//
//  SCSLogDataSource.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 04/04/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSLog.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol that must be implemented by objects that want to act as data source for a SCSLog instance.
 */
@protocol SCSLogDataSource <NSObject>

@required

/**
 Choose if a message should be logged.
 
 @param log The SCSLog instance that is attempting to log a message.
 @param level The log level of the message.
 @returns true if the message must be logged, false otherwise.
 */
- (BOOL)log:(SCSLog *)log shouldLogMessageWithLevel:(SCSLogLevel)level;

@end

NS_ASSUME_NONNULL_END
