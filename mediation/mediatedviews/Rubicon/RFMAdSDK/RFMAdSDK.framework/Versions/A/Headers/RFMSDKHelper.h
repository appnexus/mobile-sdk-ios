//
//  RFMSDKHelper.h
//  RFMAdSDK
//
//  Created by Rubicon Project on 5/6/14.
//  Copyright © 2014 Rubicon Project. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RFMSDKHelper : NSObject

+(BOOL) isURLEncoded:(NSString *)URLString;
+ (BOOL)isURLEncodedWithString:(NSString *)URLString;

+(BOOL) isURLEncodedUsingAllowedCharacterSet:(NSString *)URLString;
+(BOOL) isURLEncodedUsingAmpersandAndForwardSlash:(NSString *)URLString;

+(BOOL) isURLSpecialAppLink:(NSString *)URLString;
+(BOOL) isURLInAppDLLink:(NSString *)URLString;

+(BOOL) isURLRFMJSLink:(NSString *)URLString;

+(NSRegularExpression *)regexWithString:(NSString *)string
                                options:(NSDictionary *)options;

+(NSString *)searchAndReplaceRegex:(NSString *)inString
                 replacementString:(NSString *)replacementString
                             regex:(NSRegularExpression *)regex;

@end
