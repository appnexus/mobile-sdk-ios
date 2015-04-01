/*   Copyright 2013 APPNEXUS INC
 
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

#import "NSString+ANCategory.h"

@implementation NSString (ANCategory)

- (NSDictionary *)an_queryComponents
{
    NSMutableDictionary *parameters = nil;
    
    if ([self length] > 0)
    {
        parameters = [NSMutableDictionary dictionary];
        
        for(NSString *parameter in [self componentsSeparatedByString:@"&"])
        {
            NSRange range = [parameter rangeOfString:@"="];
            
            if(range.location != NSNotFound)
            {
                [parameters setValue:[[parameter substringFromIndex:range.location+range.length] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding] forKey:[[parameter substringToIndex:range.location] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
            }
            else [parameters setValue:@"" forKey:[parameter stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        }
    }
    
    return parameters;
}

- (NSString*)an_encodeAsURIComponent
{
	const char* p = [self UTF8String];
	NSMutableString* result = [NSMutableString string];
	
	for (;*p ;p++) {
		unsigned char c = *p;
		if (('0' <= c && c <= '9') || ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z') || (c == '-' || c == '_')||c=='.') {
			[result appendFormat:@"%c", c];
		} else {
			[result appendFormat:@"%%%02X", c];
		}
	}
	return result;
}

- (NSString *)an_stringByAppendingUrlParameter:(NSString *)name
                                         value:(NSString *)value {
    // don't append anything if either field is empty
    if (([name length] < 1) || ([value length] < 1)) {
        return self;
    }
    
    NSMutableString *parameter = [NSMutableString stringWithFormat:@"%@=%@",
                           name, [value an_encodeAsURIComponent]];
    
    // add the proper prefix depending on the current string
    if ([self rangeOfString:@"="].length != 0) {
        [parameter insertString:@"&" atIndex:0];
    } else if ([self rangeOfString:@"?"].location != ([self length] - 1)) {
        [parameter insertString:@"?" atIndex:0];
    } // otherwise, keep the string as it is
	
    return [self stringByAppendingString:parameter];
}

@end
