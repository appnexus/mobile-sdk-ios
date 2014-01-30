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

- (void)removeDocumentPadding;
{
    [self stringByEvaluatingJavaScriptFromString:kANAdRemovePaddingJavascriptString];
}

- (void)setMediaProperties {
    if ([self respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
        [self setAllowsInlineMediaPlayback:YES];
    }
    if ([self respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)]) {
        [self setMediaPlaybackRequiresUserAction:NO];
    }
}

- (void)setScrollEnabled:(BOOL)scrollable
{
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0
    // If iOS 5.0 and up, we can turn off scrolling using the directly-accessible -scrollView of UIWebView
    if ([self respondsToSelector:@selector(scrollView)])
    {
        UIScrollView *scrollView = self.scrollView;
        scrollView.scrollEnabled = scrollable;
        scrollView.bounces = scrollable;
    } 
    else
    // If less than iOS 5.0, we need to get the UIScrollView by searching through the UIWebView's subviews
    #endif
    {
        UIScrollView *scrollView = nil;
        
        for (UIView *view in self.subviews)
        {
            if ([view isKindOfClass:[UIScrollView class]])
            {
                scrollView = (UIScrollView *)view;
                break;
            }
        }
        
        scrollView.scrollEnabled = scrollable;
        scrollView.bounces = scrollable;
    }
}

- (BOOL)isScrollEnabled
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0
    // If iOS 5.0 and up, we can turn off scrolling using the directly-accessible -scrollView of UIWebView
    if ([self respondsToSelector:@selector(scrollView)])
    {
        return self.scrollView.isScrollEnabled;
    }
    else
        // If less than iOS 5.0, we need to get the UIScrollView by searching through the UIWebView's subviews
#endif
    {
        UIScrollView *scrollView = nil;
        
        for (UIView *view in self.subviews)
        {
            if ([view isKindOfClass:[UIScrollView class]])
            {
                scrollView = (UIScrollView *)view;
                break;
            }
        }
        
        return scrollView.isScrollEnabled;
    }
}

@end
