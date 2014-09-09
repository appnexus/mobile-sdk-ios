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

#import "ANURLConnectionStub.h"

@implementation ANURLConnectionStub

- (id)copyWithZone:(NSZone *)zone {
    ANURLConnectionStub *newStub = [[ANURLConnectionStub alloc] init];
    newStub.requestURLRegexPatternString = self.requestURLRegexPatternString;
    newStub.responseCode = self.responseCode;
    newStub.responseBody = self.responseBody;
    return newStub;
}

- (BOOL)isEqual:(ANURLConnectionStub *)object {
    BOOL sameRequestURLString = [self.requestURLRegexPatternString isEqualToString:object.requestURLRegexPatternString];
    BOOL sameResponseCode = self.responseCode = object.responseCode;
    BOOL sameResponseBody = [self.responseBody isEqualToString:object.responseBody];
    return sameRequestURLString && sameResponseBody && sameResponseCode;
}

- (NSUInteger)hash {
    NSMutableString *description = [[NSMutableString alloc] init];
    [description appendString:self.requestURLRegexPatternString];
    [description appendString:[NSString stringWithFormat:@"%ld", (long)self.responseCode]];
    [description appendString:self.responseBody];
    return [description hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"NSURLConnectionStub: \n\
    Request URL Pattern: %@,\n\
    Response Code: %ld,\n\
    Response Body: %@",self.requestURLRegexPatternString, (long)self.responseCode, self.responseBody];

}

@end