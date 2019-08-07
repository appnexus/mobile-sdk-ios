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

#import "ANClickOverlayView.h"

#import "UIView+ANCategory.h"

#define OVERLAY_LARGE CGSizeMake(100.0, 70.0)
#define OVERLAY_MEDIUM CGSizeMake(50.0, 35.0)

@interface ANClickOverlayView ()

@end

@implementation ANClickOverlayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self addIndicatorView];
    }
    return self;
}

+ (ANClickOverlayView *)addOverlayToView:(UIView *)view {
    ANClickOverlayView *overlay = [[ANClickOverlayView alloc] init];
    [view addSubview:overlay];
    overlay.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *heightSuperviewRelation = [NSLayoutConstraint constraintWithItem:overlay
                                                                               attribute:NSLayoutAttributeHeight
                                                                               relatedBy:NSLayoutRelationLessThanOrEqual
                                                                                  toItem:view
                                                                               attribute:NSLayoutAttributeHeight
                                                                              multiplier:1.0
                                                                                constant:0.0];
    NSLayoutConstraint *maxHeight = [NSLayoutConstraint constraintWithItem:overlay
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationLessThanOrEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:OVERLAY_LARGE.height];
    NSLayoutConstraint *minHeight = [NSLayoutConstraint constraintWithItem:overlay
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:OVERLAY_MEDIUM.height];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:overlay
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:view
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.9
                                                               constant:0.0];
    height.priority = UILayoutPriorityDefaultLow;
    NSLayoutConstraint *aspectRatio = [NSLayoutConstraint constraintWithItem:overlay
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:overlay
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1.5
                                                                    constant:0.0];
    [view addConstraints:@[heightSuperviewRelation, maxHeight, minHeight, aspectRatio,height]];
    [overlay an_alignToSuperviewWithXAttribute:NSLayoutAttributeCenterX
                                    yAttribute:NSLayoutAttributeCenterY];
    return overlay;
}

- (void)addIndicatorView {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicator startAnimating];
    [self addSubview:indicator];
    indicator.translatesAutoresizingMaskIntoConstraints = NO;
    [indicator an_alignToSuperviewWithXAttribute:NSLayoutAttributeCenterX
                                      yAttribute:NSLayoutAttributeCenterY];
}

- (UIColor *)colorForColorOption:(ANClickOverlayColorOption)option withAlpha:(CGFloat)alpha {
    switch (option) {
        case ANClickOverlayColorOptionRed:
            return [UIColor colorWithRed:163.0/255.0
                                   green:48.0/255.0
                                    blue:53.0/255.0
                                   alpha:alpha];
        case ANClickOverlayColorOptionTeal:
            return [UIColor colorWithRed:0.0/255.0
                                   green:197.0/255.0
                                    blue:181.0/255.0
                                   alpha:alpha];
        default: // case ANClickOverlayColorOptionGrey
            return [UIColor colorWithRed:77.0/255.0
                                   green:78.0/255.0
                                    blue:83.0/255.0
                                   alpha:alpha];
    }
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                           cornerRadius:2.0];
    UIColor *bkColor = [self colorForColorOption:ANCLICKOVERLAYCOLOROPTION
                                       withAlpha:0.8];
    [bkColor setFill];
    [roundedRect fillWithBlendMode:kCGBlendModeNormal
                             alpha:1.0];
}

@end