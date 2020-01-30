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

#import "ANNativeAdRequest+ANTest.h"
#import "NSObject+Swizzling.h"
#import <objc/runtime.h>
#import "ANTestGlobal.h"



@implementation ANNativeAdRequest (ANTest)


static BOOL kDoNotResetAdUnitUUIDEnabled = NO;

+ (void)load {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [ANNativeAdRequest exchangeInstanceSelector:@selector(setImageInBackgroundForImageURL:onObject:forKeyPath:)
                                       withSelector:@selector(test_setImageInBackgroundForImageURL:onObject:forKeyPath:) ];
        [ANNativeAdRequest exchangeInstanceSelector:@selector(internalUTRequestUUIDStringReset)
                                         withSelector:@selector(swizzle_internalUTRequestUUIDStringReset)];
        
    }];
#pragma clang diagnostic pop
    [operation start];
}

- (dispatch_semaphore_t) test_setImageInBackgroundForImageURL: (NSURL *)imageURL
                                                     onObject: (id)object
                                                   forKeyPath: (NSString *)keyPath
{
TESTTRACE();

    if ([self getIncrementCountEnabledOrIfSet:NO thenValue:NO])
    {
        [NSThread sleepForTimeInterval:1];

        if (! [NSThread isMainThread]) {
            NSUInteger  incrementCount  = [self incrementCountOfMethodInvocationInBackgroundOrReset:NO];
            TESTTRACEM(@"incrementCount=%@", @(incrementCount));
        }
    }

    //
    return [self  test_setImageInBackgroundForImageURL: (NSURL *)imageURL
                                              onObject: (id)object
                                            forKeyPath: (NSString *)keyPath ];
}

- (NSUInteger) incrementCountOfMethodInvocationInBackgroundOrReset:(BOOL)reset
{
    static NSUInteger  invocationCount  = 0;

    if (reset) {
        invocationCount = 0;
    } else {
        invocationCount += 1;
    }

    return  invocationCount;
}

- (BOOL) getIncrementCountEnabledOrIfSet: (BOOL)setEnable
                               thenValue: (BOOL)enableValue
{
    static BOOL  invocationCountEnabled  = NO;

    if (setEnable) {
        invocationCountEnabled = enableValue;
    }

    return  invocationCountEnabled;
}

+ (void)setDoNotResetAdUnitUUID:(BOOL)simulationEnabled {
    kDoNotResetAdUnitUUIDEnabled = simulationEnabled;
}

- (void)swizzle_internalUTRequestUUIDStringReset {
    if(kDoNotResetAdUnitUUIDEnabled){
        NSLog(@"Do nothing");
    }else{
        [self swizzle_internalUTRequestUUIDStringReset];
    }
}


@end
