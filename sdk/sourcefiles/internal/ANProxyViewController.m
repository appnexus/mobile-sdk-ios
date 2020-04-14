/*   Copyright 2016 APPNEXUS INC
 
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

#import "ANProxyViewController.h"
#import "UIView+ANCategory.h"

@implementation ANProxyViewController

- (instancetype)init {
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.rootViewController methodSignatureForSelector:sel];
}

- (UIViewController *)rootViewController {
    if (_rootViewController) {
        return _rootViewController;
    } else if ([self.adView an_parentViewController]) {
        return [self.adView an_parentViewController];
    } else {
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        return topController;
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.rootViewController];
}

@end