//
//  ANSingleUnifiedObject.m
//  AppNexusSDK
//
//  Created by Akash Verma on 13/09/19.
//  Copyright © 2019 AppNexus. All rights reserved.
//

#import "ANSingleUnifiedObject.h"
#import "ANLogging.h"
#import "ANGlobal.h"

@implementation ANSingleUnifiedObject

@synthesize  creativeId                             = __creativeId;


//Parsing Response
- (void)anParseResponse:(NSDictionary *)jsonDic
{
    
}

//#pragma mark - ANAdProtocol: Getter methods
//
//- (nullable NSString *)creativeId {
//    ANLogDebug(@"Creative Id returned %@", __creativeId);
//    return __creativeId;
//}
//
//#pragma mark - ANAdProtocol: Setter methods
//
//- (void)setCreativeId:(NSString *)creativeId {
//    creativeId = ANConvertToNSString(creativeId);
//    if ([creativeId length] < 1) {
//        ANLogError(@"Could not set creativeId to non-string value");
//        return;
//    }
//    if (creativeId != __creativeId) {
//        ANLogDebug(@"Setting creativeId to %@", creativeId);
//        __creativeId = creativeId;
//    }
//}

@end
