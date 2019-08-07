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

#import "ANAdAdapterBannerAdMob+ANTest.h"
#import "NSObject+Swizzling.h"

@implementation ANAdAdapterBannerAdMob (ANTest)

+ (void)load {
//    1
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self exchangeInstanceSelector:@selector(createRequestFromTargetingParameters:)
                          withSelector:@selector(test_createRequestFromTargetingParameters:)];
    }];
#pragma clang diagnostic pop
    [operation start];
}

- (GADRequest *)test_createRequestFromTargetingParameters:(ANTargetingParameters *)targetingParameters {
    GADRequest *request = [self test_createRequestFromTargetingParameters:targetingParameters];
    //request.testDevices = @[ GAD_SIMULATOR_ID ]; //(Automatic in Google SDK Version 7.0.0)
    return request;
}

@end

@implementation ANAdAdapterBannerDFP (ANTest)

+ (void)load {
//    2
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [self exchangeInstanceSelector:@selector(createRequestFromTargetingParameters:)
                          withSelector:@selector(test_createRequestFromTargetingParameters:)];
    }];
#pragma clang diagnostic pop
    [operation start];
}

- (GADRequest *)test_createRequestFromTargetingParameters:(ANTargetingParameters *)targetingParameters {
    GADRequest *request = [self test_createRequestFromTargetingParameters:targetingParameters];
    request.testDevices = @[ kDFPSimulatorID ];
    return request;
}

@end
