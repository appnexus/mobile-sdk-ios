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

#import "ANAdWebViewController+ANTest.h"
#import "NSObject+Swizzling.h"
#import <objc/runtime.h>
#import <WebKit/WebKit.h>
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation ANAdWebViewController (ANTest)

@dynamic completedFirstLoad, lastKnownVisibleRect, lastKnownExposedPercentage;

+ (void)load {
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [[self class] exchangeInstanceSelector:@selector(initWithConfiguration:)
                                  withSelector:@selector(test_initWithConfiguration:)];
        [[self class] exchangeInstanceSelector:@selector(webView:didFinishNavigation:)
                                  withSelector:@selector(test_webView:didFinishNavigation:)];
    }];
    [operation start];
}


- (ANAdWebViewControllerConfiguration *)test_initWithConfiguration:(ANAdWebViewControllerConfiguration *)configuration{
    ANAdWebViewControllerConfiguration  *wkwebConfiguration = [self test_initWithConfiguration:configuration];
    return wkwebConfiguration;
     
}

- (void)test_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self test_webView:webView didFinishNavigation:navigation];
}

@end
