//
//  SCSVASTClickEvent.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 20/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCSVASTClickEvent : NSObject

/// Event Type: can be ClickThrough, ClickTracking or Custom
@property (nonatomic, readonly) NSString *type;

/// URL to be called for this click.
@property (nonatomic, readonly) NSURL *url;

- (instancetype)init NS_UNAVAILABLE;

/**
 Initialize the SCSVASTClickEvent from a type (NSString) and an url (NSURL).
 
 @param type The click type.
 @param url The url.
 */
- (instancetype)initWithType:(NSString *)type url:(NSURL *)url NS_DESIGNATED_INITIALIZER;

/**
 Initialize the SCSVASTClickEvent from a type and an url string.
 
 @param type The click type.
 @param urlString A string representing the url to be called for this impression.
 */
- (nullable instancetype)initWithType:(NSString *)type urlString:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
