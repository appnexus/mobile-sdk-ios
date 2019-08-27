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

#import "ANMRAIDResizeProperties.h"

@implementation ANMRAIDResizeProperties

+ (ANMRAIDResizeProperties *)resizePropertiesFromQueryComponents:(NSDictionary *)queryComponents {
    CGFloat w = [queryComponents[@"w"] floatValue];
    CGFloat h = [queryComponents[@"h"] floatValue];
    CGFloat offsetX = [queryComponents[@"offset_x"] floatValue];
    CGFloat offsetY = [queryComponents[@"offset_y"] floatValue];
    
    NSString* customClosePositionString = [queryComponents[@"custom_close_position"] description];
    ANMRAIDCustomClosePosition closePosition = [ANMRAIDUtil customClosePositionFromCustomClosePositionString:customClosePositionString];
    
    BOOL allowOffscreen;
    if (queryComponents[@"allow_offscreen"]) {
        allowOffscreen = [queryComponents[@"allow_offscreen"] boolValue];
    } else {
        allowOffscreen = YES;
    }
    
    return [[ANMRAIDResizeProperties alloc] initWithWidth:w
                                                   height:h
                                                  offsetX:offsetX
                                                  offsetY:offsetY
                                      customClosePosition:closePosition
                                           allowOffscreen:allowOffscreen];
}

- (instancetype)initWithWidth:(CGFloat)width
                       height:(CGFloat)height
                      offsetX:(CGFloat)offsetX
                      offsetY:(CGFloat)offsetY
          customClosePosition:(ANMRAIDCustomClosePosition)customClosePosition
               allowOffscreen:(BOOL)allowOffscreen {
    if (self = [super init]) {
        _width = width;
        _height = height;
        _offsetX = offsetX;
        _offsetY = offsetY;
        _customClosePosition = customClosePosition;
        _allowOffscreen = allowOffscreen;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(width %f, height %f, offsetX %f, offsetY %f, customClosePosition %lu, allowOffscreen %d)", self.width, self.height, self.offsetX, self.offsetY, (long unsigned)self.customClosePosition, self.allowOffscreen];
}

@end