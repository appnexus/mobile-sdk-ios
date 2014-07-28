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

#define OVERLAY_LARGE CGSizeMake(100.0, 70.0)
#define OVERLAY_MEDIUM CGSizeMake(50.0, 35.0)

@interface ANClickOverlayView ()

@end

@implementation ANClickOverlayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

+ (ANClickOverlayView *)overlayForView:(UIView *)view {
    CGSize overlaySize = OVERLAY_LARGE;
    if (CGRectGetHeight(view.bounds) <= OVERLAY_LARGE.height) {
        overlaySize = OVERLAY_MEDIUM;
    }
    CGFloat originX = CGRectGetMidX(view.bounds) - 0.5 * overlaySize.width;
    CGFloat originY = CGRectGetMidY(view.bounds) - 0.5 * overlaySize.height;
    ANClickOverlayView *overlay = [[ANClickOverlayView alloc] initWithFrame:CGRectMake(originX, originY, overlaySize.width, overlaySize.height)];
    return overlay;
}

- (void)addIndicatorView {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    CGFloat originX = CGRectGetMidX(self.bounds) - 0.5 * CGRectGetWidth(indicator.bounds);
    CGFloat originY = CGRectGetMidY(self.bounds) - 0.5 * CGRectGetHeight(indicator.bounds);
    indicator.frame = CGRectMake(originX, originY, CGRectGetWidth(indicator.bounds), CGRectGetHeight(indicator.bounds));
    [indicator startAnimating];
    [self addSubview:indicator];
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
    
    [self addIndicatorView];
}

@end