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

#import <UIKit/UIKit.h>

@interface UIView (ANCategory)

- (void)an_presentView:(UIView *)view animated:(BOOL)animated;
- (void)an_presentView:(UIView *)view animated:(BOOL)animated completion:(void (^)(BOOL))completion;

- (void)an_dismissFromPresentingViewAnimated:(BOOL)animated;

- (void)an_removeSubviews;
- (void)an_removeSubviewsWithException:(UIView *)exception;

- (BOOL)an_isViewable;
- (BOOL)an_isAtLeastHalfViewable;

- (UIViewController *)an_parentViewController;

- (CGRect)an_originalFrame;

#pragma mark - Autolayout

- (void)an_constrainWithSize:(CGSize)size;
- (void)an_constrainWithFrameSize;
- (void)an_removeSizeConstraint;
- (void)an_extractWidthConstraint:(NSLayoutConstraint **)widthConstraint
                 heightConstraint:(NSLayoutConstraint **)heightConstraint;

- (void)an_constrainToSizeOfSuperview;
- (void)an_removeSizeConstraintToSuperview;

- (void)an_alignToSuperviewWithXAttribute:(NSLayoutAttribute)xAttribute
                               yAttribute:(NSLayoutAttribute)yAttribute;
- (void)an_alignToSuperviewWithXAttribute:(NSLayoutAttribute)xAttribute
                               yAttribute:(NSLayoutAttribute)yAttribute
                                  offsetX:(CGFloat)offsetX
                                  offsetY:(CGFloat)offsetY;
- (void)an_removeAlignmentConstraintsToSuperview;

@end
