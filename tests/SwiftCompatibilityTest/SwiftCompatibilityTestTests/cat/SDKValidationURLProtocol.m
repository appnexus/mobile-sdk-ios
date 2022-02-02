/*   Copyright 2019 APPNEXUS INC
 
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

#import "SDKValidationURLProtocol.h"
@interface SDKValidationURLProtocol() <NSURLConnectionDelegate>
@property (nonatomic, strong) NSURLConnection *connection;
@property NSMutableData *data;
@end

@implementation SDKValidationURLProtocol
static id<SDKValidationURLProtocolDelegate> classDelegate = nil;

+ (void)setDelegate:(id<SDKValidationURLProtocolDelegate>)delegate
{
    classDelegate = delegate;
}

+ (id<SDKValidationURLProtocolDelegate>)delegate
{
    return classDelegate;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([NSURLProtocol propertyForKey:@"AppNexusURLProtocolHandledKey" inRequest:request]) {
        return NO;
    }
    if ([SDKValidationURLProtocol supportedPBSHost:request.URL.absoluteString]) {
        if (classDelegate != nil) {
            [classDelegate didReceiveIABResponse:request.URL.absoluteString];
        }
        return YES;
    }
    return NO;
}

+ (BOOL) supportedPBSHost:(NSString *) hostURL {
    if (hostURL != nil) {
        if ([hostURL containsString:@"iabtechlab.com"]) {
            return YES;
        }
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
    self.data = [[NSMutableData alloc] init];
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"AppNexusURLProtocolHandledKey" inRequest:newRequest];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
#pragma clang diagnostic pop
}

- (void)stopLoading
{
    [self.connection cancel];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}


@end
