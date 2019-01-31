//
//  SCSTrackingEventManagerDelegate.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 07/12/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SCSTrackingEventManager;

@protocol SCSTrackingEventManagerDelegate <NSObject>
- (void)trackingEventManager:(SCSTrackingEventManager *)trackingEventManager didTrackEventWithName:(NSString *)name count:(NSInteger)count;
@end

NS_ASSUME_NONNULL_END
