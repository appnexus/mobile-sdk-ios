//
//  SCSProdURL.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 18/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Represents an URL to an API that exists in both production and development environment.
 
 The class should be initialized with every URL available and will always returned the
 URL that is needed depending of the framework configuration.
 */
@interface SCSProdURL : NSObject

/// The URL that should be used for this API.
@property (nonatomic, readonly) NSURL *URL NS_SWIFT_NAME(url);

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize a prod URL object.
 
 Note: this initializer takes a debugFramework parameter that should be set with the value returned
 by SCSFrameworkInfo. To avoid issues, it's wiser to use the convenience initializer.
 
 @param prodURL The API URL in production.
 @param devURL The API URL in development.
 @param cacheBusterEnabled true to add a timestamp at the end of the URL, false otherwise.
 @param debugFramework true if the framework is built in DEBUG, false if the framework is built in RELEASE.
 @return The initialized instance.
 */
- (instancetype)initWithProdURL:(NSURL *)prodURL devURL:(nullable NSURL *)devURL cacheBusterEnabled:(BOOL)cacheBusterEnabled debugFramework:(BOOL)debugFramework NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
