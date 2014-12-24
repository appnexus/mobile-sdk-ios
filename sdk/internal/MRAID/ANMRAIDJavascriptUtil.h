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

#import "ANMRAIDUtil.h"

@interface ANMRAIDJavascriptUtil : NSObject

+ (NSString *)readyEvent;
+ (NSString *)stateChange:(ANMRAIDState)state;
+ (NSString *)error:(NSString *)errorString
        forFunction:(NSString *)function;
+ (NSString *)placementType:(NSString *)placementType;
+ (NSString *)isViewable:(BOOL)isViewable;
+ (NSString *)currentSize:(CGSize)size;
+ (NSString *)currentPosition:(CGRect)position;
+ (NSString *)defaultPosition:(CGRect)position;
+ (NSString *)screenSize:(CGSize)size;
+ (NSString *)maxSize:(CGSize)size;
+ (NSString *)feature:(NSString *)feature
          isSupported:(BOOL)supported;

+ (NSString *)getState;

@end