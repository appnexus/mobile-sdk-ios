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

#import <XCTest/XCTest.h>

#import "ANLogManager.h"
#import "ANLogging.h"

#import "ANHTTPStubbingManager.h"

#import "ANUniversalTagRequestBuilder.h"
#import "ANSDKSettings+PrivateMethods.h"




#pragma mark - Global public constants.

extern  NSTimeInterval  kWaitOneSecond;
extern  NSTimeInterval  kWaitTwoSeconds;
extern  NSTimeInterval  kWaitShort;
extern  NSTimeInterval  kWaitLong;
extern  NSTimeInterval  kWaitVeryLong;



#pragma mark - Defines.

#define  TMARK()            NSLog(@" TEST MARK  %s",       __PRETTY_FUNCTION__);
#define  TMARKMESSAGE(...)  NSLog(@" TEST MARK  %s -- %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__]);

#define  TINFO(...)   NSLog(@" TEST INFO  %s -- %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__]);
#define  TDEBUG(...)  NSLog(@" TEST DEBUG  %s -- %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__]);
#define  TERROR(...)  NSLog(@" TEST ERROR  %s -- %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__]);

#define  TNSERROR(e)  NSLog(@" TEST NSERROR  code:%@ domain:%@ -- %@", @(e.code), e.domain, e.userInfo);




#pragma mark -

@interface TestGlobal : XCTestCase

+ (void)waitForSeconds:(NSTimeInterval)seconds thenExecuteBlock:(nullable void (^)(void))block;

+ (void)stubRequestWithResponse:(nonnull NSString *)filenameContainingJSONResponse;

+ (nullable NSMutableArray<id> *)adsArrayFromFirstTagInReponseData:(nonnull NSData *)data;

@end

