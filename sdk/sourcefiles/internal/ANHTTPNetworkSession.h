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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ANHTTPNetworkSession : NSObject

+ (instancetype)sharedInstance;

/**
 Initializes a HTTP network request and immediately sends it.
 @param request Request to send.
 */
+ (void)startTaskWithHttpRequest:(NSURLRequest *)request;

/**
 Initializes a HTTP network request and immediately sends it.
 @param request Request to send.
 @param responseHandler Optional response handler that will be invoked on the main thread.
 @param errorHandler Optional error handler that will be invoked on the main thread.
 */
+ (void)startTaskWithHttpRequest:(NSURLRequest *)request
                               responseHandler:(void (^ _Nullable)(NSData * data, NSHTTPURLResponse * response))responseHandler
                                  errorHandler:(void (^ _Nullable)(NSError * error))errorHandler;

@end

NS_ASSUME_NONNULL_END
