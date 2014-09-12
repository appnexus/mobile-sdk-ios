/*   Copyright 2014 APPNEXUS INC
 
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

#import "ANHTTPStubURLProtocol.h"

static NSString *const kANTestHTTPStubURLProtocolExceptionKey = @"ANTestHTTPStubURLProtocolException";

@implementation ANHTTPStubURLProtocol

+ (void)load {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [NSURLProtocol registerClass:[ANHTTPStubURLProtocol class]];
    }];
    [operation start];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    BOOL isTrue = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"];
    return isTrue;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return NO;
}

- (void)startLoading {
    id<NSURLProtocolClient> client = self.client;
        ANURLConnectionStub *stub = [self stubForRequest];
    if (stub) {
        NSURLResponse *response = [self buildResponseForRequestUsingStub:stub];
        [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        NSData *responseData = [self buildDataForRequestUsingStub:stub];
        [client URLProtocol:self didLoadData:responseData];
        [client URLProtocolDidFinishLoading:self];
        NSLog(@"Successfully loaded request: %@", [self request]);
    } else {
        NSLog(@"Could not load request successfully: %@", [self request]);
        NSLog(@"This can happen if the request was not stubbed, or if the stubs were removed before this request was completed (due to asynchronous request loading).");
        [client URLProtocol:self didFailWithError:[NSError errorWithDomain:kANTestHTTPStubURLProtocolExceptionKey
                                                                      code:1
                                                                  userInfo:nil]];
    }
}

- (void)stopLoading {
    // Do nothing, but method is required.
}

#pragma mark - Stubbing

+ (NSMutableArray *)sharedStubArray {
    @synchronized(self) {
        static dispatch_once_t sharedStubDictionaryToken;
        static NSMutableArray *array;
        dispatch_once(&sharedStubDictionaryToken, ^{
            array = [[NSMutableArray alloc] init];
        });
        return array;
    }
}

+ (void)addStub:(ANURLConnectionStub *)stub {
    if (stub) {
        [[[self class] sharedStubArray] addObject:stub];
    }
}

+ (void)removeStub:(ANURLConnectionStub *)stub {
    if (stub) {
        [[[self class] sharedStubArray] removeObject:stub];
    }
}

+ (void)removeAllStubs {
    [[[self class] sharedStubArray] removeAllObjects];
}

- (ANURLConnectionStub *)stubForRequest {
    return [[self class] stubForURLString:[[[self request] URL] absoluteString]];
}

+ (ANURLConnectionStub *)stubForURLString:(NSString *)URLString {
    NSString *requestURLString = URLString;
    NSArray *stubArray = [[self class] sharedStubArray];
    __block ANURLConnectionStub *stubMatch = nil;
    [stubArray enumerateObjectsUsingBlock:^(ANURLConnectionStub *stub, NSUInteger idx, BOOL *stop) {
        NSString *stubRequestURLString = stub.requestURLRegexPatternString;
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:stubRequestURLString
                                                                               options:NSRegularExpressionDotMatchesLineSeparators
                                                                                 error:&error];
        if ([regex numberOfMatchesInString:requestURLString
                                   options:0
                                     range:NSMakeRange(0, [requestURLString length])]) {
            stubMatch = stub;
            *stop = YES;
        }
    }];
    return stubMatch;
}

- (NSURLResponse *)buildResponseForRequestUsingStub:(ANURLConnectionStub *)stub {
    NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:[[self request] URL]
                                                                  statusCode:stub.responseCode
                                                                 HTTPVersion:@"HTTP/1.1"
                                                                headerFields:@{}];
    return httpResponse;
}

- (NSData *)buildDataForRequestUsingStub:(ANURLConnectionStub *)stub {
    return [stub.responseBody dataUsingEncoding:NSUTF8StringEncoding];
}

@end
