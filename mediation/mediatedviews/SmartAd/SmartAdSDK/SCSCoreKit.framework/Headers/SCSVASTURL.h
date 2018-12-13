//
//  SCSVASTURL.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 20/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCSVASTURL : NSObject

/// URL to be called for this pixel.
@property (nonatomic, readonly) NSURL *url;

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize the SCSVASTURL from a NSURL.
 
 @param url The url.
 */
- (instancetype)initWithURL:(nonnull NSURL *)url NS_DESIGNATED_INITIALIZER;

/**
 Convenience initializer from an NSString.
 
 @param urlString The string representing the url to be called for this pixel.
 */
- (nullable instancetype)initWithString:(nonnull NSString *)urlString NS_DESIGNATED_INITIALIZER;

/**
 Convenience initializer from an XML extracted object of unknown class.
 
 @param xml An object which can be a dictionary or a string.
 */
- (nullable instancetype)initFromXML:(nonnull id)xml;

@end

NS_ASSUME_NONNULL_END
