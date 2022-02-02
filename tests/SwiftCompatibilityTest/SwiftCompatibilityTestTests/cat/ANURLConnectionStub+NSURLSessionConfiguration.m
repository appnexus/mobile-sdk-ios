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

#import <Foundation/Foundation.h>

#import "ANURLConnectionStub.h"
#import "NSObject+Swizzling.h"
#import "ANHTTPNetworkSession+ANTest.h"
#import "ANGlobal+ANTest.h"



/**
 *  This helper is used to swizzle NSURLSessionConfiguration constructor methods
 *  defaultSessionConfiguration and ephemeralSessionConfiguration to insert the private
 *  OHHTTPStubsProtocol into their protocolClasses array so that OHHTTPStubs is automagically
 *  supported when you create a new NSURLSession based on one of there configurations.
 */

typedef NSURLSessionConfiguration*(*SessionConfigConstructor)(id,SEL);
static SessionConfigConstructor orig_defaultSessionConfiguration;
static SessionConfigConstructor orig_ephemeralSessionConfiguration;

static NSURLSessionConfiguration* ANHTTPStubs_defaultSessionConfiguration(id self, SEL _cmd)
{
    NSURLSessionConfiguration* config = orig_defaultSessionConfiguration(self,_cmd); // call original method
    [ANURLConnectionStub setEnabled:YES forSessionConfiguration:config]; //
    return config;
}

static NSURLSessionConfiguration* ANHTTPStubs_ephemeralSessionConfiguration(id self, SEL _cmd)
{
    NSURLSessionConfiguration* config = orig_ephemeralSessionConfiguration(self,_cmd); // call original method
    [ANURLConnectionStub setEnabled:YES forSessionConfiguration:config]; //
    return config;
}

@interface NSURLSessionConfiguration(ANHTTPStubsSupport) @end

@implementation NSURLSessionConfiguration(ANHTTPStubsSupport)

+(void)load
{
    
    orig_defaultSessionConfiguration = (SessionConfigConstructor)ANHTTPStubsReplaceMethod(@selector(defaultSessionConfiguration),
                                                                                          (IMP)ANHTTPStubs_defaultSessionConfiguration,
                                                                                          [NSURLSessionConfiguration class],
                                                                                          YES);
    orig_ephemeralSessionConfiguration = (SessionConfigConstructor)ANHTTPStubsReplaceMethod(@selector(ephemeralSessionConfiguration),
                                                                                            (IMP)ANHTTPStubs_ephemeralSessionConfiguration,
                                                                                            [NSURLSessionConfiguration class],
                                                                                            YES);
    
    // Recreated network session and mutable request after http stubbing is enabled.
    [[ANHTTPNetworkSession sharedInstance]setAdServerSession:[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:[ANHTTPNetworkSession sharedInstance] delegateQueue:nil]];
    [ANGlobal constructAdServerRequestURLAndWarmup];
}

@end
