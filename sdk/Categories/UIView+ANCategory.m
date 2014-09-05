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

- (void)constrainWithFrameSize {
    __block NSLayoutConstraint *widthConstraint = nil;
    __block NSLayoutConstraint *heightConstraint = nil;
    // Reusing identically formatted constraints so that the debugger doesn't complain of conflicting constraints
    [self.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *existingConstraint, NSUInteger idx, BOOL *stop) {
        BOOL constraintOnlyOnSelf = existingConstraint.firstItem == self && existingConstraint.secondAttribute == NSLayoutAttributeNotAnAttribute && existingConstraint.secondItem == nil;
        BOOL constraintIsWidthConstraint = existingConstraint.firstAttribute == NSLayoutAttributeWidth && constraintOnlyOnSelf;
        BOOL constraintIsHeightConstraint = existingConstraint.firstAttribute == NSLayoutAttributeHeight && constraintOnlyOnSelf;

        if (constraintIsWidthConstraint) {
            widthConstraint = existingConstraint;
        }
        if (constraintIsHeightConstraint) {
            heightConstraint = existingConstraint;
        }
    }];
    
    if (!widthConstraint) {
        widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1.0
                                                        constant:CGRectGetWidth(self.frame)];
        [self addConstraint:widthConstraint];
    } else {
        widthConstraint.constant = CGRectGetWidth(self.frame);
    }
    if (!heightConstraint) {
        heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1.0
                                                         constant:CGRectGetHeight(self.frame)];
        [self addConstraint:heightConstraint];
    } else {
        heightConstraint.constant = CGRectGetHeight(self.frame);
    }
}

- (void)constrainToSuperviewWithXAttribute:(NSLayoutAttribute)xAttribute
                                yAttribute:(NSLayoutAttribute)yAttribute {
    NSArray *superviewConstraintsCopy = [self.superview.constraints copy];
    // Removing identically formatted constraints so that the debugger doesn't complain of conflicting constraints
    [superviewConstraintsCopy enumerateObjectsUsingBlock:^(NSLayoutConstraint *existingConstraint, NSUInteger idx, BOOL *stop) {
        BOOL firstItemSelfSecondItemSuperview = existingConstraint.firstItem == self && existingConstraint.secondItem == self.superview;
        BOOL firstItemSuperviewSecondItemSelf = existingConstraint.firstItem == self.superview && existingConstraint.secondItem == self;
        BOOL attributesEqual = existingConstraint.firstAttribute == existingConstraint.secondAttribute;
        BOOL isWidthOrHeightConstraint = existingConstraint.firstAttribute == NSLayoutAttributeWidth || existingConstraint.firstAttribute == NSLayoutAttributeHeight;
        BOOL invalidConstraint = (firstItemSelfSecondItemSuperview || firstItemSuperviewSecondItemSelf) && attributesEqual && !isWidthOrHeightConstraint;
        if (invalidConstraint) {
            [self.superview removeConstraint:existingConstraint];
        }
    }];
    
    NSLayoutConstraint *xConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                   attribute:xAttribute
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.superview
                                                                   attribute:xAttribute
                                                                  multiplier:1.0
                                                                    constant:0.0];
    NSLayoutConstraint *yConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                   attribute:yAttribute
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.superview
                                                                   attribute:yAttribute
                                                                  multiplier:1.0
                                                                    constant:0.0];
    [self.superview addConstraints:@[xConstraint, yConstraint]];
}

@end
