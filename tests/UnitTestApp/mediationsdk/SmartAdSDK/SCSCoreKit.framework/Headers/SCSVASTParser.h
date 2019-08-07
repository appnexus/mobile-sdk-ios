//
//  SCSVASTParser.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 22/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SCSVASTParserResponse;

/**
 This class transforms XML Datas into a VASTModel or return an error.
 */
@interface SCSVASTParser : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 Creates a VAST Model from XML datas.
 
 @param datas The XML datas to parse.
 
 @return An SCSVASTParserResponse containing a (nullable) model and a (nullable) set of errors.
 */
+ (SCSVASTParserResponse *)parseXMLAndGenerateVASTObjectModel:(nullable NSData *)datas;

@end

NS_ASSUME_NONNULL_END
