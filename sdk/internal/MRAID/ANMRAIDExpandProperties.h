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

#import <UIKit/UIKit.h>

@interface ANMRAIDExpandProperties : NSObject

+ (ANMRAIDExpandProperties *)expandPropertiesFromQueryComponents:(NSDictionary *)queryComponents;

- (instancetype)initWithWidth:(CGFloat)width
                       height:(CGFloat)height
                          URL:(NSURL *)URL
               useCustomClose:(BOOL)useCustomClose;

@property (nonatomic, readonly, assign) CGFloat width;
@property (nonatomic, readonly, assign) CGFloat height;
@property (nonatomic, readonly, strong) NSURL *URL;
@property (nonatomic, readonly, assign) BOOL useCustomClose;

@end