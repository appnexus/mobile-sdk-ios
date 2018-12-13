//
//  SCSRemoteConfigManagerDelegate.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 27/09/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SCSRemoteConfigManager;

@protocol SCSRemoteConfigManagerDelegate <NSObject>
- (void)remoteConfigManager:(nullable SCSRemoteConfigManager *)remoteConfigManager didSucceedToFetchConfigWithSmartDictionary:(NSDictionary *)smartDict additionnalDictionaries:(nullable NSArray <NSDictionary *> *)dictionaries;
- (void)remoteConfigManager:(nullable SCSRemoteConfigManager *)remoteConfigManager didFailToFetchConfigWithError:(nullable NSError *)error;
@end

NS_ASSUME_NONNULL_END
