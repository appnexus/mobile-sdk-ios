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

#import "ANBannerAdView+ANContentViewTransitions.h"

static NSString *const kANContentViewTransitionsOldContentViewTransitionKey = @"AppNexusOldContentViewTransition";
static NSString *const kANContentViewTransitionsNewContentViewTransitionKey = @"AppNexusNewContentViewTransition";

@implementation ANBannerAdView (ANContentViewTransitions)

// Properties are synthesized in ANBannerAdView
@dynamic transitionInProgress;
@dynamic contentView;

- (void)performTransitionFromContentView:(UIView *)oldContentView
                           toContentView:(UIView *)newContentView {
    [self removeDelegateFromTransitionOnContentView:oldContentView];
    
    if (self.transitionType == ANBannerViewAdTransitionTypeNone) {
        if (newContentView) {
            [self addSubview:newContentView];
            [self removeSubviewsWithException:newContentView];
        } else {
            [self removeSubviews];
        }
        return;
    }
    
    ANBannerViewAdTransitionType transitionType = self.transitionType;
    if ((oldContentView && !newContentView) || (newContentView && !oldContentView)) {
        transitionType = ANBannerViewAdTransitionTypeFade;
    }
    
    ANBannerViewAdTransitionDirection transitionDirection = self.transitionDirection;
    if (transitionDirection == ANBannerViewAdTransitionDirectionRandom) {
        transitionDirection = arc4random_uniform(4);
    }
    
    if (transitionType != ANBannerViewAdTransitionTypeFlip) {
        newContentView.hidden = YES;
    }
    
    if (newContentView) {
        [self addSubview:newContentView];
    }
    
    self.transitionInProgress = @(YES);
    
    [UIView animateWithDuration:self.transitionDuration
                     animations:^{
                         if (transitionType == ANBannerViewAdTransitionTypeFlip) {
                             CAKeyframeAnimation *oldContentViewAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
                             oldContentViewAnimation.values = [self keyFrameValuesForOldContentViewFlipAnimationWithDirection:transitionDirection];
                             oldContentViewAnimation.duration = self.transitionDuration;
                             [oldContentView.layer addAnimation:oldContentViewAnimation
                                                         forKey:kANContentViewTransitionsOldContentViewTransitionKey];
                             
                             CAKeyframeAnimation *newContentViewAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
                             newContentViewAnimation.values = [self keyFrameValuesForNewContentViewFlipAnimationWithDirection:transitionDirection];
                             newContentViewAnimation.duration = self.transitionDuration;
                             newContentViewAnimation.delegate = self;
                             [newContentView.layer addAnimation:newContentViewAnimation
                                                         forKey:kANContentViewTransitionsNewContentViewTransitionKey];
                         } else {
                             CATransition *transition = [CATransition animation];
                             transition.startProgress = 0;
                             transition.endProgress = 1.0;
                             transition.type = [[self class] CATransitionTypeFromANTransitionType:transitionType];
                             transition.subtype = [[self class] CATransitionSubtypeFromANTransitionDirection:transitionDirection
                                                                                        withANTransitionType:transitionType];
                             transition.duration = self.transitionDuration;
                             transition.delegate = self;
                             
                             [oldContentView.layer addAnimation:transition
                                                         forKey:kANContentViewTransitionsOldContentViewTransitionKey];
                             [newContentView.layer addAnimation:transition
                                                         forKey:kANContentViewTransitionsNewContentViewTransitionKey];
                             
                             newContentView.hidden = NO;
                             oldContentView.hidden = YES;
                         }
                     }];
}

- (void)removeDelegateFromTransitionOnContentView:(UIView *)contentView {
    CAAnimation *animation = [contentView.layer animationForKey:kANContentViewTransitionsNewContentViewTransitionKey];
    animation.delegate = nil;
}

+ (NSString *)CATransitionSubtypeFromANTransitionDirection:(ANBannerViewAdTransitionDirection)transitionDirection
                                      withANTransitionType:(ANBannerViewAdTransitionType)transitionType {
    if (transitionType == ANBannerViewAdTransitionTypeFade) {
        return kCATransitionFade;
    }
    
    switch (transitionDirection) {
        case ANBannerViewAdTransitionDirectionUp:
            return kCATransitionFromTop;
        case ANBannerViewAdTransitionDirectionDown:
            return kCATransitionFromBottom;
        case ANBannerViewAdTransitionDirectionLeft:
            return kCATransitionFromRight;
        case ANBannerViewAdTransitionDirectionRight:
            return kCATransitionFromLeft;
        default:
            return kCATransitionFade;
    }
}

+ (NSString *)CATransitionTypeFromANTransitionType:(ANBannerViewAdTransitionType)transitionType {
    switch (transitionType) {
        case ANBannerViewAdTransitionTypeFade:
            return kCATransitionPush;
        case ANBannerViewAdTransitionTypePush:
            return kCATransitionPush;
        case ANBannerViewAdTransitionTypeMoveIn:
            return kCATransitionMoveIn;
        case ANBannerViewAdTransitionTypeReveal:
            return kCATransitionReveal;
        default:
            return kCATransitionPush;
    }
}

static NSInteger const kANBannerAdViewNumberOfKeyframeValuesToGenerate = 35;
static CGFloat kANBannerAdViewPerspectiveValue = -1.0 / 750.0;

- (NSArray *)keyFrameValuesForContentViewFlipAnimationWithDirection:(ANBannerViewAdTransitionDirection)direction
                                                  forOldContentView:(BOOL)isOldContentView {
    CGFloat angle = 0.0f;
    CGFloat x;
    CGFloat y;
    CGFloat frameFlipDimensionLength = 0.0f;
    
    switch (direction) {
        case ANBannerViewAdTransitionDirectionUp:
            x = 1;
            y = 0;
            angle = isOldContentView ? M_PI_2 : -M_PI_2;
            frameFlipDimensionLength = CGRectGetHeight(self.frame);
            break;
        case ANBannerViewAdTransitionDirectionDown:
            x = 1;
            y = 0;
            angle = isOldContentView ? -M_PI_2: M_PI_2;
            frameFlipDimensionLength = CGRectGetHeight(self.frame);
            break;
        case ANBannerViewAdTransitionDirectionLeft:
            x = 0;
            y = 1;
            angle = isOldContentView ? -M_PI_2 : M_PI_2;
            frameFlipDimensionLength = CGRectGetWidth(self.frame);
            break;
        case ANBannerViewAdTransitionDirectionRight:
            x = 0;
            y = 1;
            angle = isOldContentView ? M_PI_2 : -M_PI_2;
            frameFlipDimensionLength = CGRectGetWidth(self.frame);
            break;
        default:
            x = 1;
            y = 0;
            angle = isOldContentView ? M_PI_2 : -M_PI_2;
            frameFlipDimensionLength = CGRectGetHeight(self.frame);
            break;
    }
    
    NSMutableArray *keyframeValues = [[NSMutableArray alloc] init];
    for (NSInteger valueNumber=0; valueNumber <= kANBannerAdViewNumberOfKeyframeValuesToGenerate; valueNumber++) {
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = kANBannerAdViewPerspectiveValue;
        transform = CATransform3DTranslate(transform, 0, 0, -frameFlipDimensionLength / 2.0);
        transform = CATransform3DRotate(transform, angle * valueNumber / kANBannerAdViewNumberOfKeyframeValuesToGenerate, x, y, 0);
        transform = CATransform3DTranslate(transform, 0, 0, frameFlipDimensionLength / 2.0);
        [keyframeValues addObject:[NSValue valueWithCATransform3D:transform]];
    }
    return isOldContentView ? keyframeValues : [[keyframeValues reverseObjectEnumerator] allObjects];
}

- (NSArray *)keyFrameValuesForOldContentViewFlipAnimationWithDirection:(ANBannerViewAdTransitionDirection)direction {
    return [self keyFrameValuesForContentViewFlipAnimationWithDirection:direction
                                                      forOldContentView:YES];
}

- (NSArray *)keyFrameValuesForNewContentViewFlipAnimationWithDirection:(ANBannerViewAdTransitionDirection)direction {
    return [self keyFrameValuesForContentViewFlipAnimationWithDirection:direction
                                                      forOldContentView:NO];
}

- (void)animationDidStop:(CAAnimation *)anim
                finished:(BOOL)flag {
    [self removeSubviewsWithException:self.contentView];
    self.transitionInProgress = @(NO);
}

@end
