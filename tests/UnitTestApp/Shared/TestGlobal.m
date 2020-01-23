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

#import "TestGlobal.h"



#pragma mark - Global public constants.

NSTimeInterval  kWaitOneSecond    = 1;
NSTimeInterval  kWaitTwoSeconds   = 2;
NSTimeInterval  kWaitShort        = 5;
NSTimeInterval  kWaitLong         = 10;
NSTimeInterval  kWaitVeryLong     = 15;




#pragma mark -

@interface TestGlobal()
    //EMPTY
@end


@implementation TestGlobal

#pragma mark Class methods.

/**
 * Run NSBlockOperation with qualityOfService=NSQualityOfServiceBackground.
 * Wait for seconds then run block on main queue.
 */
+ (void)waitForSeconds:(NSTimeInterval)seconds thenExecuteBlock:(nullable void (^)(void))block
{
TMARK();
    NSBlockOperation  *blockOperation  = [[NSBlockOperation alloc] init];
    blockOperation.qualityOfService = NSQualityOfServiceBackground;

    [blockOperation addExecutionBlock:^{
                        TINFO(@"SLEEPING for %@ seconds...", @(seconds));
                        [NSThread sleepForTimeInterval:seconds];

                        dispatch_async(dispatch_get_main_queue(), block);
                    } ];

    [blockOperation start];
}

+ (void) stubRequestWithResponse:(nonnull NSString *)filenameContainingJSONResponse
{
TMARK();
    NSBundle  *currentBundle  = [NSBundle bundleForClass:[self class]];
    NSString  *baseResponse   = [NSString stringWithContentsOfFile: [currentBundle pathForResource:filenameContainingJSONResponse ofType:@"json"]
                                                          encoding: NSUTF8StringEncoding
                                                             error: nil ];

    ANURLConnectionStub  *requestStub  = [[ANURLConnectionStub alloc] init];

    requestStub.requestURL    = [[[ANSDKSettings sharedInstance] baseUrlConfig] utAdRequestBaseUrl];
    requestStub.responseCode  = 200;
    requestStub.responseBody  = baseResponse;

    [[ANHTTPStubbingManager sharedStubbingManager] addStub:requestStub];
}

+ (nullable NSMutableArray<id> *)adsArrayFromFirstTagInReponseData:(nonnull NSData *)data
{
    NSArray<NSDictionary<NSString *, id> *>  *tagsArray  = [ANUniversalTagAdServerResponse generateTagsFromResponseData:data];

    if ([tagsArray count] <= 0)
    {
        ANLogError(@"FAILED to generate tags array.");
        return nil;
    }

    NSMutableArray<id>   *adsArrayFromFirstTag  = [ANUniversalTagAdServerResponse generateAdObjectInstanceFromJSONAdServerResponseTag:tagsArray[0]];

    return  adsArrayFromFirstTag;
}


@end  //TestGlobal

