/*   Copyright 2020 Xandr INC

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

#import "ANWarmupSDKObjects.h"
#import <WebKit/WebKit.h>
#import "ANGlobal.h"
#import "ANHTTPNetworkSession.h"
#import "ANSDKSettings+PrivateMethods.h"

NSMutableURLRequest  *utMutableRequest = nil;

@implementation ANWarmupSDKObjects

+ (void)load {
    
    // No need for "dispatch once" since `load` is called only once during app launch.
    [self constructAdServerRequestURL];
    
}

+(NSMutableURLRequest *) adServerRequestURL {
    return utMutableRequest;
}

+ (void) constructAdServerRequestURL {
    NSString      *urlString  = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    NSURL                *URL             = [NSURL URLWithString:urlString];
    
    utMutableRequest  = [[NSMutableURLRequest alloc] initWithURL: URL
                                                                         cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
                                                                     timeoutInterval: kAppNexusRequestTimeoutInterval];

    // Set header fields for HTTP request.
    // NB  Content-Type needs to be set explicity else will default to "application/x-www-form-urlencoded".
    //
    [utMutableRequest setValue:[ANGlobal getUserAgent] forHTTPHeaderField:@"User-Agent"];
    [utMutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [utMutableRequest setHTTPMethod:@"POST"];
    
    [ANHTTPNetworkSession taskWithHttpRequest:utMutableRequest];
}

@end
