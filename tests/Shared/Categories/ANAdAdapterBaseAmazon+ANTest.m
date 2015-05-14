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

#import "ANAdAdapterBaseAmazon+ANTest.h"
#import "NSObject+Swizzling.h"
#import "ANAdAdapterBaseAmazon+PrivateMethods.h"
#import <AmazonAd/AmazonAdOptions.h>

@implementation ANAdAdapterBaseAmazon (ANTest)

+ (void)load {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [self exchangeInstanceSelector:@selector(adOptionsForTargetingParameters:)
                          withSelector:@selector(test_adOptionsForTargetingParameters:)];
        [[self class] setAmazonAppKey:@"123"];
    }];
    [operation start];
}

- (AmazonAdOptions *)test_adOptionsForTargetingParameters:(ANTargetingParameters *)targetingParameters {
    AmazonAdOptions *options = [self test_adOptionsForTargetingParameters:targetingParameters];
    options.isTestRequest = YES;
    return options;
}

@end
