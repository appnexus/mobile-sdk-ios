/*
 *
 *    Copyright 2017 APPNEXUS INC
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */


#import "ANInstreamVideoAd+Test.h"
#import "NSObject+Swizzling.h"
#import <objc/runtime.h>

@implementation ANInstreamVideoAd(Test)

static BOOL kDoNotResetAdUnitUUIDEnabled = NO;

-(void)createInstreamVideoAdPlayer{
    
    self.adPlayer = [[ANVideoAdPlayer alloc] init];
}


+ (void)setDoNotResetAdUnitUUID:(BOOL)simulationEnabled {
    kDoNotResetAdUnitUUIDEnabled = simulationEnabled;
}

+ (void)load {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [[self class] exchangeInstanceSelector:@selector(internalUTRequestUUIDStringReset)
                                  withSelector:@selector(swizzle_internalUTRequestUUIDStringReset)];
    }];
    [operation start];
}

- (void)swizzle_internalUTRequestUUIDStringReset {
    if(kDoNotResetAdUnitUUIDEnabled){
        NSLog(@"Do nothing");
    }else{
        [self swizzle_internalUTRequestUUIDStringReset];
    }
}
@end
