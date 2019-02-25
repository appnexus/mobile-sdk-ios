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

#import "ANGlobal+Test.h"
#import "ANSDKSettings.h"

@implementation ANGlobal(Test)

+ (NSString *)getUserAgent
{
    static NSString  *userAgent   = @"Mozilla/5.0 (iPhone; CPU iPhone OS 8_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12B411 Appended User Agent";
    
    // Return customUserAgent if provided
    NSString *customUserAgent = ANSDKSettings.sharedInstance.customUserAgent;
    if (customUserAgent.length != 0) {
        return customUserAgent;
    }

    return userAgent;
}


@end
