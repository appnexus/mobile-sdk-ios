//
//  SCSRemoteConfigManager.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 27/09/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SCSRemoteConfigManagerDelegate;

@interface SCSRemoteConfigManager : NSObject

/**
 Public initializer.
 
 @param delegate The delegate to be informed about requests results.
 @param baseURL The remote config URL's base URL.
 @param path The remote config URL's path.
 @param queryStringParameters A dictionary of query string parameters that must be used to call the remote config URL.
 
 returns An initialized instance of SCSRemoteConfigManager
 */
- (instancetype)initWithDelegate:(id <SCSRemoteConfigManagerDelegate>)delegate baseURL:(NSString *)baseURL path:(NSString *)path queryStringParameters:(NSDictionary *)queryStringParameters;

/**
 Ask the SCSRemoteConfigManager to fetch the configuration for the given siteID.
 
 @param forced Whether or not the SCSRemoteConfigManager should take the expiration into account. YES to ignore expiration.
 */
- (void)fetchRemoteConfiguration:(BOOL)forced;


- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
