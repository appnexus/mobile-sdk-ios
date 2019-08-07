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

#import "ANVerificationScriptResource.h"


@implementation ANVerificationScriptResource

static NSString *const RESPONSE_KEY_CONFIG = @"config";
static NSString *const PATTERN_SRC_VALUE = @"src=\"(.*?)\"";
static NSString *const PATTERN_VENDORKEY_VALUE = @"vk=(.*?);";
static NSString *const KEY_HASH = @"#";

@synthesize  url,vendorKey,params;

//Parsing Viewability dictionary from ad server response into url, vendorkey and params
- (void)anVerificationScriptResource:(NSDictionary *)jsonDic
{
    NSString *configString = jsonDic[RESPONSE_KEY_CONFIG];
    if (configString.length == 0) {
        return;
    }

    NSRegularExpression *regexSrc = [NSRegularExpression regularExpressionWithPattern:PATTERN_SRC_VALUE
                                                                           options:0 error:NULL];
    NSTextCheckingResult *srcStringMatcher = [regexSrc firstMatchInString:configString options:0 range:NSMakeRange(0, [configString length])];
    if (srcStringMatcher != nil) {
        NSString *src = [configString substringWithRange:[srcStringMatcher rangeAtIndex:1]];
        NSArray *arrVerificationScriptResource = [src componentsSeparatedByString:KEY_HASH];
        url = arrVerificationScriptResource[0];
        params = arrVerificationScriptResource[1];
        
        NSRegularExpression *regexVK = [NSRegularExpression regularExpressionWithPattern:PATTERN_VENDORKEY_VALUE
                                                                               options:0 error:NULL];
        NSTextCheckingResult *vkStringMatcher = [regexVK firstMatchInString:configString options:0 range:NSMakeRange(0, [configString length])];
         if (vkStringMatcher != nil) {
             vendorKey = [configString substringWithRange:[vkStringMatcher rangeAtIndex:1]];
         }
    }    
}

@end
