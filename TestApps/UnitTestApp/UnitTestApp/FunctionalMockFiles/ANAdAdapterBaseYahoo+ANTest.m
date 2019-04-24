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

#import "ANAdAdapterBaseYahoo+ANTest.h"
#import "NSObject+Swizzling.h"
#import "ANAdAdapterBaseYahoo+PrivateMethods.h"

@implementation ANAdAdapterBaseYahoo (ANTest)

+ (void)load {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [self exchangeClassSelector:@selector(adTargetingWithTargetingParameters:)
                       withSelector:@selector(test_adTargetingWithTargetingParameters:)];
    }];
    [operation start];
}

+ (FlurryAdTargeting *)test_adTargetingWithTargetingParameters:(ANTargetingParameters *)targetingParameters {
    FlurryAdTargeting *targeting = [ANAdAdapterBaseYahoo test_adTargetingWithTargetingParameters:targetingParameters];
    targeting.testAdsEnabled = YES;
    return targeting;
}

@end