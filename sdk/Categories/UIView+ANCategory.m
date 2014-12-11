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

- (BOOL)an_isViewable {
    BOOL isHidden = self.hidden;
    if (isHidden) return NO;
    
    BOOL isAttachedToWindow = self.window ? YES : NO;
    if (!isAttachedToWindow) return NO;
    
    BOOL isInHiddenSuperview = NO;
    UIView *ancestorView = self.superview;
    while (ancestorView) {
        if (ancestorView.hidden) {
            isInHiddenSuperview = YES;
            break;
        }
        ancestorView = ancestorView.superview;
    }
    if (isInHiddenSuperview) return NO;
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect normalizedSelfRect = [self convertRect:self.bounds toView:nil];
    CGRect intersection = CGRectIntersection(screenRect, normalizedSelfRect);
    if (CGRectEqualToRect(intersection, CGRectNull)) {
        return NO;
    }
    
    CGFloat intersectionArea = CGRectGetWidth(intersection) * CGRectGetHeight(intersection);
    CGFloat selfArea = CGRectGetWidth(normalizedSelfRect) * CGRectGetHeight(normalizedSelfRect);
    return intersectionArea >= 0.5 * selfArea;
}

#pragma mark - Autolayout

- (void)constrainWithFrameSize {
    [self constrainWithSize:self.frame.size];
}

- (void)constrainWithSize:(CGSize)size {
    [self removeSizeConstraintToSuperview];
    
    NSLayoutConstraint *widthConstraint;
    NSLayoutConstraint *heightConstraint;
    
    [self extractWidthConstraint:&widthConstraint
                heightConstraint:&heightConstraint];

    if (!widthConstraint) {
        widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:1
                                                        constant:size.width];
        [self addConstraint:widthConstraint];
    } else {
        widthConstraint.constant = size.width;
    }
    if (!heightConstraint) {
        heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1
                                                         constant:size.height];
        [self addConstraint:heightConstraint];
    } else {
        heightConstraint.constant = size.height;
    }
}

- (void)constrainToSizeOfSuperview {
    [self removeSizeConstraintToSuperview];
    [self removeSizeConstraint];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.superview
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1
                                                                        constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.superview
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1
                                                                         constant:0];
    [self.superview addConstraints:@[widthConstraint, heightConstraint]];
}

- (void)alignToSuperviewWithXAttribute:(NSLayoutAttribute)xAttribute
                            yAttribute:(NSLayoutAttribute)yAttribute {
    [self alignToSuperviewWithXAttribute:xAttribute
                              yAttribute:yAttribute
                                 offsetX:0
                                 offsetY:0];
}

- (void)alignToSuperviewWithXAttribute:(NSLayoutAttribute)xAttribute
                            yAttribute:(NSLayoutAttribute)yAttribute
                               offsetX:(CGFloat)offsetX
                               offsetY:(CGFloat)offsetY {
    [self removeAlignmentConstraintsToSuperview];
    
    NSLayoutConstraint *xConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                   attribute:xAttribute
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.superview
                                                                   attribute:xAttribute
                                                                  multiplier:1
                                                                    constant:offsetX];
    NSLayoutConstraint *yConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                   attribute:yAttribute
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.superview
                                                                   attribute:yAttribute
                                                                  multiplier:1
                                                                    constant:offsetY];
    [self.superview addConstraints:@[xConstraint, yConstraint]];
}

- (void)removeSizeConstraintToSuperview {
    NSArray *superviewConstraintsCopy = [self.superview.constraints copy];
    [superviewConstraintsCopy enumerateObjectsUsingBlock:^(NSLayoutConstraint *existingConstraint, NSUInteger idx, BOOL *stop) {
        BOOL firstItemSelfSecondItemSuperview = existingConstraint.firstItem == self && existingConstraint.secondItem == self.superview;
        BOOL firstItemSuperviewSecondItemSelf = existingConstraint.firstItem == self.superview && existingConstraint.secondItem == self;
        BOOL attributesEqual = existingConstraint.firstAttribute == existingConstraint.secondAttribute;
        BOOL isWidthOrHeightConstraint = existingConstraint.firstAttribute == NSLayoutAttributeWidth || existingConstraint.firstAttribute == NSLayoutAttributeHeight;
        BOOL invalidConstraint = (firstItemSelfSecondItemSuperview || firstItemSuperviewSecondItemSelf) && attributesEqual && isWidthOrHeightConstraint;
        if (invalidConstraint) {
            [self.superview removeConstraint:existingConstraint];
        }
    }];
}

- (void)removeAlignmentConstraintsToSuperview {
    NSArray *superviewConstraintsCopy = [self.superview.constraints copy];
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
}

- (void)removeSizeConstraint {
    NSLayoutConstraint *widthConstraint;
    NSLayoutConstraint *heightConstraint;
    [self extractWidthConstraint:&widthConstraint
                heightConstraint:&heightConstraint];
    
    if (widthConstraint) {
        [self removeConstraint:widthConstraint];
    }
    if (heightConstraint) {
        [self removeConstraint:heightConstraint];
    }
}

- (void)extractWidthConstraint:(NSLayoutConstraint **)widthConstraint
              heightConstraint:(NSLayoutConstraint **)heightConstraint {
    [self.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *existingConstraint, NSUInteger idx, BOOL *stop) {
        BOOL constraintOnlyOnSelf = existingConstraint.firstItem == self && existingConstraint.secondAttribute == NSLayoutAttributeNotAnAttribute && existingConstraint.secondItem == nil;
        BOOL constraintIsWidthConstraint = existingConstraint.firstAttribute == NSLayoutAttributeWidth && constraintOnlyOnSelf;
        BOOL constraintIsHeightConstraint = existingConstraint.firstAttribute == NSLayoutAttributeHeight && constraintOnlyOnSelf;
        if (constraintIsWidthConstraint) {
            *widthConstraint = existingConstraint;
        }
        if (constraintIsHeightConstraint) {
            *heightConstraint = existingConstraint;
        }
    }];
}

@end
