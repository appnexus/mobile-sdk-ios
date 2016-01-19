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
//  TBXML+HTTP.h
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

#import "ANXML.h"

typedef void (^ANXMLAsyncRequestSuccessBlock)(NSData *,NSURLResponse *);
typedef void (^ANXMLAsyncRequestFailureBlock)(NSData *,NSError *);

@interface NSMutableURLRequest (ANXML_HTTP)

+ (NSMutableURLRequest*)an_tbxmlGetRequestWithURL:(NSURL*)url;
+ (NSMutableURLRequest*)an_tbxmlPostRequestWithURL:(NSURL*)url parameters:(NSDictionary*)parameters;

@end


@interface NSURLConnection (ANXML_HTTP)

+ (void)an_tbxmlAsyncRequest:(NSURLRequest *)request success:(ANXMLAsyncRequestSuccessBlock)successBlock failure:(ANXMLAsyncRequestFailureBlock)failureBlock;

@end


@interface ANXML (ANXML_HTTP)

+ (id)newANXMLWithURL:(NSURL*)aURL success:(ANXMLSuccessBlock)successBlock failure:(ANXMLFailureBlock)failureBlock;
- (id)initWithURL:(NSURL*)aURL success:(ANXMLSuccessBlock)successBlock failure:(ANXMLFailureBlock)failureBlock;

@end


