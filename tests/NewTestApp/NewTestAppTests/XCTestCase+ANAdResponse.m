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

#import "XCTestCase+ANAdResponse.h"

@implementation XCTestCase (ANAdResponse)

- (ANAdResponse *)responseWithJSONResource:(NSString *)JSONResource {
    ANAdResponse *response = [[ANAdResponse alloc] init];
    [response processResponseData:[self dataWithJSONResource:JSONResource]];
    return response;
}

@end