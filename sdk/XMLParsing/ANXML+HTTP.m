/*   Copyright 2015 APPNEXUS INC
 
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

// ================================================================================================
//  TBXML+HTTP.m
//  Fast processing of XML files
//
// ================================================================================================
//  Created by Tom Bradley on 21/10/2009.
//  Version 1.5
//
//  Copyright 2012 71Squared All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
// ================================================================================================

#import "ANXML+HTTP.h"

@implementation NSMutableURLRequest (ANXML_HTTP)


+ (NSMutableURLRequest*)an_tbxmlGetRequestWithURL:(NSURL*)url {
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:url];
	[request setHTTPMethod:@"GET"];
    
    
#ifndef ANXML_ARC_ENABLED
    return [request autorelease];
#else
    return request;
#endif
    
}

+ (NSMutableURLRequest*)an_tbxmlPostRequestWithURL:(NSURL*)url parameters:(NSDictionary*)parameters {
	
	NSMutableArray * params = [NSMutableArray new];
	
	for (NSString * key in [parameters allKeys]) {
		[params addObject:[NSString stringWithFormat:@"%@=%@", key, [parameters objectForKey:key]]];
	}
	
	NSData * postData = [[params componentsJoinedByString:@"&"] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:url];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:postData];

#ifndef ANXML_ARC_ENABLED
    [params release];
    return [request autorelease];
#else
    return request;
#endif
}

@end


@implementation NSURLConnection (ANXML_HTTP)

+ (void)an_tbxmlAsyncRequest:(NSURLRequest *)request success:(ANXMLAsyncRequestSuccessBlock)successBlock failure:(ANXMLAsyncRequestFailureBlock)failureBlock {
    
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
		@autoreleasepool {
			NSURLResponse *response = nil;
			NSError *error = nil;
			NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
			if (error) {
				failureBlock(data,error);
			} else {
				successBlock(data,response);
			}
		}		
	});
}

@end


@implementation ANXML (ANXML_HTTP)

+ (id)newANXMLWithURL:(NSURL*)aURL success:(ANXMLSuccessBlock)successBlock failure:(ANXMLFailureBlock)failureBlock {
	return [[ANXML alloc] initWithURL:aURL success:successBlock failure:failureBlock];
}

- (id)initWithURL:(NSURL*)aURL success:(ANXMLSuccessBlock)successBlock failure:(ANXMLFailureBlock)failureBlock {
	self = [self init];
	if (self != nil) {
        
        ANXMLAsyncRequestSuccessBlock requestSuccessBlock = ^(NSData *data, NSURLResponse *response) {

            NSError *error = nil;
            [self decodeData:data withError:&error];
            
            // If ANXML found a root node, process element and iterate all children
            if (!error) {
                successBlock(self);
            } else {
                failureBlock(self, error);
            }
        };
        
        ANXMLAsyncRequestFailureBlock requestFailureBlock = ^(NSData *data, NSError *error) {
            failureBlock(self, error);
        };
        
        
        [NSURLConnection an_tbxmlAsyncRequest:[NSMutableURLRequest an_tbxmlGetRequestWithURL:aURL]
                                      success:requestSuccessBlock
                                      failure:requestFailureBlock];
	}
	return self;
}

@end