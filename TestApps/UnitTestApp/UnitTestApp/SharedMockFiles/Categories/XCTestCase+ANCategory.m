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

#import "XCTestCase+ANCategory.h"

@implementation XCTestCase (ANCategory)

- (NSData *)dataWithJSONResource:(NSString *)JSONResource {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:JSONResource
                                                                      ofType:@"json"];
    return [NSData dataWithContentsOfFile:path];
    
}

- (UIImage *)imageForResource:(NSString *)resource
                       ofType:(NSString *)type {
    NSString *imagePath = [[NSBundle bundleForClass:[self class]] pathForResource:resource
                                                                           ofType:type];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

+ (NSData *)dataWithJSONObject:(id)jsonObject {
    return [NSJSONSerialization dataWithJSONObject:jsonObject
                                           options:0
                                             error:nil];
}

+ (NSString *)stringWithJSONObject:(id)jsonObject {
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                   options:0
                                                     error:nil];
    return [[NSString alloc] initWithData:data
                                 encoding:NSUTF8StringEncoding];
}

+ (void)delayForTimeInterval:(NSTimeInterval)seconds {
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:seconds]];
}

@end
