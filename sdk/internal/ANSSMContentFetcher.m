/*   Copyright 2016 APPNEXUS INC
 
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

#import "ANSSMContentFetcher.h"
#import "ANGlobal.h"
#import "ANLogging.h"
#import "ANAdConstants.h"

@interface ANSSMContentFetcher ()

@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableData *data;

@property (nonatomic, readwrite, weak) id<ANSSMContentFetcherDelegate> delegate;

@end

@implementation ANSSMContentFetcher

- (instancetype)initWithUrlString:(NSString *)urlString
                         delegate:(id<ANSSMContentFetcherDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        [self requestContentWithUrlString:urlString];
    }
    return self;
}

- (void)requestContentWithUrlString:(NSString *)urlString {
    NSURLRequest *request = ANBasicRequestWithURL([NSURL URLWithString:urlString]);
    self.connection = [NSURLConnection connectionWithRequest:request
                                                    delegate:self];
    if (!self.connection) {
        ANLogDebug(@"Invalid connection for server-side mediation request");
        [self.delegate contentFetcherFailedToLoadContent:self];
    } else {
        ANLogDebug(@"Starting server-side mediation request: %@", request);
    }
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == self.connection) {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSInteger status = [httpResponse statusCode];
            
            if (status >= 400) {
                [connection cancel];
                NSError *statusError = ANError(@"connection_failed %ld", ANAdResponseNetworkError, (long)status);
                [self connection:connection didFailWithError:statusError];
                return;
            }
        }
        
        self.data = [NSMutableData data];
        ANLogDebug(@"Received server-side mediation response: %@", response);
    } else {
        ANLogDebug(@"Received server-side mediation response from unknown");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
    if (connection == self.connection) {
        [self.data appendData:d];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == self.connection) {
        NSString *content = [[NSString alloc] initWithData:self.data
                                                  encoding:NSUTF8StringEncoding];
        if (content.length > 0) {
            ANLogDebug(@"Received server-side mediation content: %@", content);
            [self.delegate contentFetcher:self didLoadContent:content];
        } else {
            ANLogDebug(@"Failed to receive server-side mediation content");
            [self.delegate contentFetcherFailedToLoadContent:self];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == self.connection) {
        ANLogDebug(@"Failed to receive server-side mediation content");
        [self.delegate contentFetcherFailedToLoadContent:self];
    }
}


@end