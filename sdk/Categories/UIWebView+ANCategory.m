/*   Copyright 2013 APPNEXUS INC
 
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

#import "UIWebView+ANCategory.h"

#import "ANLogging.h"

NSString *const kANAdRemovePaddingJavascriptString = @"document.body.style.margin='0';document.body.style.padding = '0'";

@implementation UIWebView (ANCategory)

- (void)an_removeDocumentPadding {
    [self stringByEvaluatingJavaScriptFromString:kANAdRemovePaddingJavascriptString];
}

- (void)an_setMediaProperties {
    [self setAllowsInlineMediaPlayback:YES];
    [self setMediaPlaybackRequiresUserAction:NO];
}

- (void)setAn_scrollEnabled:(BOOL)scrollable {
    self.scrollView.scrollEnabled = scrollable;
    self.scrollView.bounces = scrollable;
}

- (BOOL)isAn_scrollEnabled{
    return self.scrollView.isScrollEnabled;
}

@end