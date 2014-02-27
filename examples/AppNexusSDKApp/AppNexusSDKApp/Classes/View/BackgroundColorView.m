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

#import "BackgroundColorView.h"

@implementation BackgroundColorView

@synthesize color = _color;

- (UIColor *)color {
    if (!_color) _color = [UIColor clearColor];
    return _color;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self setNeedsDisplay];
}

#define APPNEXUSSDKAPP_ADJUSTED_RECT_SIZE 5.0f

- (void)drawRect:(CGRect)rect
{
    CGRect subRect = CGRectMake(rect.origin.x+APPNEXUSSDKAPP_ADJUSTED_RECT_SIZE,
                                rect.origin.y+APPNEXUSSDKAPP_ADJUSTED_RECT_SIZE,
                                rect.size.width-(2*APPNEXUSSDKAPP_ADJUSTED_RECT_SIZE),
                                rect.size.height-(2*APPNEXUSSDKAPP_ADJUSTED_RECT_SIZE));
    UIBezierPath *rectangle = [UIBezierPath bezierPathWithOvalInRect:subRect];
    
    [self.color setFill];
    [rectangle fill];
    
    [[UIColor blackColor] setFill];
    [rectangle stroke];
}

@end