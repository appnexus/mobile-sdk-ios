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

#import "ANAdView+ANTest.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
@implementation ANAdView (ANTest)
#pragma clang diagnostic pop

+ (void)load {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [[self class] exchangeOriginalSelector:@selector(adWasClicked)
                                  withSelector:@selector(test_adWasClicked)];
        [[self class] exchangeOriginalSelector:@selector(adWillPresent)
                                  withSelector:@selector(test_adWillPresent)];
        [[self class] exchangeOriginalSelector:@selector(adDidPresent)
                                  withSelector:@selector(test_adDidPresent)];
        [[self class] exchangeOriginalSelector:@selector(adWillClose)
                                  withSelector:@selector(test_adWillClose)];
        [[self class] exchangeOriginalSelector:@selector(adDidClose)
                                  withSelector:@selector(test_adDidClose)];
        [[self class] exchangeOriginalSelector:@selector(adWillLeaveApplication)
                                  withSelector:@selector(test_adWillLeaveApplication)];
        [[self class] exchangeOriginalSelector:@selector(adDidReceiveAppEvent:withData:)
                                  withSelector:@selector(test_adDidReceiveAppEvent:withData:)];
        [[self class] exchangeOriginalSelector:@selector(adFailedToDisplay)
                                  withSelector:@selector(test_adFailedToDisplay)];
    }];
    [operation start];
}

+ (void)exchangeOriginalSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector {
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

- (void)test_adWasClicked {
    [self postNotificationWithName:kANAdViewAdWasClickedNotification];
    [self test_adWasClicked];
}

- (void)test_adWillPresent {
    [self postNotificationWithName:kANAdViewAdWillPresentNotification];
    [self test_adWillPresent];
}

- (void)test_adDidPresent {
    [self postNotificationWithName:kANAdViewAdDidPresentNotification];
    [self test_adDidPresent];
}

- (void)test_adWillClose {
    [self postNotificationWithName:kANAdViewAdWillCloseNotification];
    [self test_adWillClose];
}

- (void)test_adDidClose {
    [self postNotificationWithName:kANAdViewAdDidCloseNotification];
    [self test_adDidClose];
}

- (void)test_adWillLeaveApplication {
    [self postNotificationWithName:kANAdViewAdWillLeaveApplicationNotification];
    [self test_adWillLeaveApplication];
}

- (void)test_adDidReceiveAppEvent:(NSString *)name withData:(NSString *)data {
    [self postNotificationWithName:kANAdViewAdDidReceiveAppEventNotification];
    [self test_adDidReceiveAppEvent:name withData:data];
}

- (void)test_adFailedToDisplay {
    [self postNotificationWithName:kANAdViewAdFailedToDisplayNotification];
    [self test_adFailedToDisplay];
}

- (void)postNotificationWithName:(NSString *)name {
    [[NSNotificationCenter defaultCenter] postNotificationName:name
                                                        object:self
                                                      userInfo:nil];
}

@end
