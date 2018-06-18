/*   Copyright 2018 APPNEXUS INC
 
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


#import <objc/runtime.h>

#import "UIApplication+ANTest.h"
#import "ANTestGlobal.h"




#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
@implementation UIApplication (ANTest)
#pragma clang diagnostic pop


#pragma mark - Class methods.

+ (void)load 
{
TESTTRACE();
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock: 
        ^{
            [[self class] exchangeOriginalSelector:@selector(openURL:)
                                      withSelector:@selector(test_openURL:) ];
            [[self class] exchangeOriginalSelector:@selector(openURL:options:completionHandler:)
                                      withSelector:@selector(test_openURL:options:completionHandler:) ];
        } ];

    [operation start];
}

+ (void)exchangeOriginalSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector 
{
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}




#pragma mark - Instance methods for swizzling.

- (BOOL)test_openURL:(NSURL*)url 
{
    NSLog(@"%s -- Swizzled out for test: DOES NOTHING.", __PRETTY_FUNCTION__);
    return  NO;
}


- (void)test_openURL:(NSURL*)url options:(NSDictionary<NSString *, id> *)options completionHandler:(void (^ __nullable)(BOOL success))completion
{
    NSLog(@"%s -- Swizzled out for test: DOES NOTHING.", __PRETTY_FUNCTION__);
}


@end
