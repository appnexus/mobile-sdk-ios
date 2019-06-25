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

#import <Foundation/Foundation.h>
#import "ANNativeAdResponse.h"
#import "ANAdFetcherResponse.h"
#import "ANAdProtocol.h"
#import "ANGlobal.h"
#import "ANUniversalTagAdServerResponse.h"

@interface ANAdFetcherBase : NSObject

@property (nonatomic, readwrite, strong)  NSMutableArray                    *ads;
@property (nonatomic, readwrite, strong)  NSString                          *noAdUrl;
@property (nonatomic, readwrite, weak)    id                              delegate;
@property (nonatomic, readwrite, getter=isLoading)  BOOL                    loading;
@property (nonatomic, readwrite, strong)  id                                adObjectHandler;

-(void)setup;
-(void)requestAd;
-(void)cancelRequest;

- (NSTimeInterval)getTotalLatency:(NSTimeInterval)stopTime;
- (void)fireResponseURL:(NSString *)responseURLString
                 reason:(ANAdResponseCode)reason
               adObject:(id)adObject;

- (void)processAdServerResponse:(ANUniversalTagAdServerResponse *)response;


@end
