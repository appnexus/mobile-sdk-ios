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

#import "ANReachability+ANTest.h"
#import "NSObject+Swizzling.h"
#import <objc/runtime.h>

static BOOL kANReachabilityNonReachableNetworkStatusSimulationEnabled = NO;

@implementation ANReachability (ANTest)

+ (void)toggleNonReachableNetworkStatusSimulationEnabled:(BOOL)simulationEnabled {
    kANReachabilityNonReachableNetworkStatusSimulationEnabled = simulationEnabled;
}

+ (void)load {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [[self class] exchangeInstanceSelector:@selector(currentReachabilityStatus)
                                  withSelector:@selector(test_currentReachabilityStatus)];
    }];
    [operation start];
}

- (ANNetworkStatus)test_currentReachabilityStatus {
    if (kANReachabilityNonReachableNetworkStatusSimulationEnabled) {
        return ANNetworkStatusNotReachable;
    } else {
        return [self test_currentReachabilityStatus];
    }
}

@end
