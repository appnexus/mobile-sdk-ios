//
//  RFMAdSession.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 2/28/17.
//  Copyright © 2017 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFMAVPlayerProgressObserver.h"
#import "RFMAdProtocols.h"

extern BOOL RFMVideoAdSessionAutomaticImpressionTrackingEnabled;

/**
 * Protocol that defines common methods that should be adopted by
 * the delegate.  Currently, there are no methods defined so this is
 * reserved for future use.
 */
@protocol RFMAdSessionDelegate <NSObject>

@end

/**
 * Class that stores and manages a list of ads.  Also allows for the configuration of
 * automatic impression tracking.
 */
@interface RFMAdSession : NSObject

@property (nonatomic, weak) id <RFMAdSessionDelegate> delegate;

/**
 * Turn automatic impression tracking on or off
 * @param enabled BOOL value where enabled turns on / off automatic impression tracking, default is YES
 */
+ (void)enableAutomaticImpressionTracking:(BOOL)enabled;
/**
 * Returns all the ads associated with this session.
 * @return ads NSArray instance containing all the ads related to the current session
 */
- (NSArray <RFMAd>*)ads;

@end
