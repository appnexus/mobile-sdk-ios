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

#import "ANNativeRenderingViewController+ANTest.h"
#import "NSObject+Swizzling.h"
#import <objc/runtime.h>
#import <WebKit/WebKit.h>
#import "ANTimeTracker.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation ANNativeRenderingViewController (ANTest)

+ (void)load {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [[self class] exchangeInstanceSelector:@selector(initWithSize:BaseObject:)
                                  withSelector:@selector(test_initWithSize:BaseObject:)];
        [[self class] exchangeInstanceSelector:@selector(webView:didFinishNavigation:)
                                  withSelector:@selector(test_webView:didFinishNavigation:)];
    }];
    [operation start];
}

- (instancetype)test_initWithSize:(CGSize)size BaseObject:(id)baseObject{
    ANNativeRenderingViewController  *wkwebConfiguration = [self test_initWithSize:size BaseObject:baseObject];
       [ANTimeTracker sharedInstance].webViewInitLoadingAt = [NSDate date];
       return wkwebConfiguration;
}


- (void)test_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [ANTimeTracker sharedInstance].webViewFinishLoadingAt = [NSDate date];
    [self test_webView:webView didFinishNavigation:navigation];
}

@end
