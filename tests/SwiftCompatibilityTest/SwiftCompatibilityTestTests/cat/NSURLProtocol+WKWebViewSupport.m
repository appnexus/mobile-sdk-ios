/*   Copyright 2019 APPNEXUS INC

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


#import "NSURLProtocol+WKWebViewSupport.h"
#import <WebKit/WebKit.h>

Class WK_ContextControllerClass() {
  static Class cls;
  if (!cls) {
    cls = [[[WKWebView new] valueForKey:@"browsingContextController"] class];
  }
  return cls;
}

SEL WK_RegisterSchemeSelector() {
  return NSSelectorFromString(@"registerSchemeForCustomProtocol:");
}

SEL WK_UnregisterSchemeSelector() {
  return NSSelectorFromString(@"unregisterSchemeForCustomProtocol:");
}

@implementation NSURLProtocol (WKWebViewSupport)

+ (void)wk_registerScheme:(NSString *)scheme {
  Class cls = WK_ContextControllerClass();
  SEL sel = WK_RegisterSchemeSelector();
  if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [(id)cls performSelector:sel withObject:scheme];
#pragma clang diagnostic pop
  }
}

+ (void)wk_unregisterScheme:(NSString *)scheme {
  Class cls = WK_ContextControllerClass();
  SEL sel = WK_UnregisterSchemeSelector();
  if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [(id)cls performSelector:sel withObject:scheme];
#pragma clang diagnostic pop
  }
}

@end
