/*   Copyright 2017 APPNEXUS INC
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "NSURLRequest+HTTPBodyTesting.h"

#import "NSObject+Swizzling.h"

#pragma mark - NSURLRequest+CustomHTTPBody

NSString * const ANHTTPStubs_HTTPBodyKey = @"HTTPBody";

@implementation NSURLRequest (HTTPBodyTesting)

- (NSData*)ANHTTPStubs_HTTPBody
{
    return [NSURLProtocol propertyForKey:ANHTTPStubs_HTTPBodyKey inRequest:self];
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSMutableURLRequest+HTTPBodyTesting

typedef void(*ANHHTTPStubsSetterIMP)(id, SEL, id);
static ANHHTTPStubsSetterIMP orig_setHTTPBody;

static void ANHTTPStubs_setHTTPBody(id self, SEL _cmd, NSData* HTTPBody)
{
    // store the http body via NSURLProtocol
    if (HTTPBody) {
        [NSURLProtocol setProperty:HTTPBody forKey:ANHTTPStubs_HTTPBodyKey inRequest:self];
    } else {
        // unfortunately resetting does not work properly as the NSURLSession also uses this to reset the property
    }
    
    orig_setHTTPBody(self, _cmd, HTTPBody);
}

/**
 *   Swizzles setHTTPBody: in order to maintain a copy of the http body for later
 *   reference and calls the original implementation.
 *
 *   @warning Should not be used in production, testing only.
 */
@interface NSMutableURLRequest (HTTPBodyTesting) @end

@implementation NSMutableURLRequest (HTTPBodyTesting)

+ (void)load
{
    orig_setHTTPBody = (ANHHTTPStubsSetterIMP)ANHTTPStubsReplaceMethod(@selector(setHTTPBody:),
                                                                       (IMP)ANHTTPStubs_setHTTPBody,
                                                                       [NSMutableURLRequest class],
                                                                       NO);
}


@end
