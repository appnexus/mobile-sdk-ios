//
//  SCSVASTModelGenerator.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 22/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SCSURLSession, SCSVASTParserResponse;

@interface SCSVASTModelGenerator : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 Initializer with a session manager. Only used for Unit tests. No documentation needed you curious monkey.
 */
- (instancetype)initWithSessionManager:(nullable SCSURLSession *)sessionManager NS_DESIGNATED_INITIALIZER;

/**
 Generate a VAST Model from XML datas or after downloading content of an URL.
 
 @param datas The inputed XML datas if any.
 @param url The URL from where the XML Datas should be downloaded.
 @param timeout The amount of time to perform the (download +) transformation of the XML datas into a VAST Model.
 @return A SCSVASTParserResponse.
 */
- (SCSVASTParserResponse *)generateVASTModelFromXML:(nullable NSData *)datas url:(nullable NSURL *)url timeout:(NSTimeInterval)timeout;

@end

NS_ASSUME_NONNULL_END
