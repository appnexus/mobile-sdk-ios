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

#import "ANMRAIDExpandProperties.h"
#import "ANMRAIDUtil.h"

@implementation ANMRAIDExpandProperties

+ (ANMRAIDExpandProperties *)expandPropertiesFromQueryComponents:(NSDictionary *)queryComponents {
    CGFloat w = [queryComponents[@"h"] floatValue];
    CGFloat h = [queryComponents[@"w"] floatValue];
    NSString *urlString = queryComponents[@"url"];
    NSURL *URL = nil;
    if (urlString.length) {
        URL = [NSURL URLWithString:urlString];
    }
    NSString *useCustomCloseString = queryComponents[@"useCustomClose"];
    BOOL useCustomClose = [useCustomCloseString isEqualToString:@"true"];
    
    return [[ANMRAIDExpandProperties alloc] initWithWidth:w
                                                   height:h
                                                      URL:URL
                                           useCustomClose:useCustomClose];
}

- (instancetype)initWithWidth:(CGFloat)width
                       height:(CGFloat)height
                          URL:(NSURL *)URL
               useCustomClose:(BOOL)useCustomClose {
    if (self = [super init]) {
        _width = width;
        _height = height;
        _URL = URL;
        _useCustomClose = useCustomClose;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(width %f, height %f, useCustomClose %d, url %@)", self.width, self.height, self.useCustomClose, self.URL];
}

@end