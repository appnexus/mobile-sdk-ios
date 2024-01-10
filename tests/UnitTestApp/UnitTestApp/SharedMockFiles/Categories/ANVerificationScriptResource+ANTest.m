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

#import "ANVerificationScriptResource+ANTest.h"

@implementation ANVerificationScriptResource (ANTest)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)anVerificationScriptResource:(NSDictionary *)jsonDic
{
    self.url = @"https://acdn.adnxs.com/mobile/omsdk/validation-verification-scripts-fortesting/omsdk-js-1.4.9/Validation-Script/omid-validation-verification-script-v1.js";
    self.vendorKey = @"dummyVendor";
    self.params = @"http://dummy-domain/m?msg=";
}
#pragma clang diagnostic pop

@end
