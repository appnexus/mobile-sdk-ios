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

#import "UIView+ANCategory.h"

#import "ANGlobal.h"

@implementation UIView (ANCategory)

- (void)presentView:(UIView *)view animated:(BOOL)animated
{
	[self presentView:view animated:animated completion:NULL];
}

- (void)presentView:(UIView *)view animated:(BOOL)animated completion:(void (^)(BOOL))completion
{
	view.transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
	
	NSTimeInterval animationDuration = animated ? kAppNexusAnimationDuration : 0.0;
	
	[UIView animateWithDuration:animationDuration
					 animations:^{
						 [self addSubview:view];
						 view.transform = CGAffineTransformMakeTranslation(0, 0);
					 }
					 completion:completion];
}

- (void)dismissFromPresentingViewAnimated:(BOOL)animated
{
	NSTimeInterval animationDuration = animated ? kAppNexusAnimationDuration : 0.0;

	[UIView animateWithDuration:animationDuration
                     animations:^{
                         self.transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void)removeSubviews {
    for (UIView *view in [self subviews]) {
        if ([view respondsToSelector:@selector(removeFromSuperview)]) {
            [view performSelector:@selector(removeFromSuperview)];
        }
    }
}

- (void)removeSubviewsWithException:(UIView *)exception {
    for (UIView *view in self.subviews) {
        if (view != exception) {
            if ([view isKindOfClass:[UIWebView class]]) {
                UIWebView *webView = (UIWebView *)view;
                [webView stopLoading];
                [webView setDelegate:nil];
            }
            
            [view removeSubviews];
            [view removeFromSuperview];
        }
    }

}

@end
