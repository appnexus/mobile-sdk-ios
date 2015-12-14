/* Copyright 2015 APPNEXUS INC
 
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


#import "ANCircularAnimationView.h"
#import "ANGlobal.h"

@interface ANCircularAnimationView (){
    NSDate *startTime;
    BOOL isButtonClickable;
}

@property (nonatomic, strong) CAShapeLayer *circularProgressLayer;
@property (nonatomic, strong) UILabel *countdownlabel;

@end

@implementation ANCircularAnimationView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self createCircularAnimationView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createCircularAnimationView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createCircularAnimationView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void) createCircularAnimationView{
    _circularProgressLayer = [[CAShapeLayer alloc] init];
    self.circularProgressLayer.frame = self.bounds;
    self.circularProgressLayer.fillColor = [UIColor clearColor].CGColor;
    self.circularProgressLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.circularProgressLayer.lineCap = kCALineCapSquare;
    self.circularProgressLayer.lineWidth = 4.0;
    self.circularProgressLayer.strokeEnd = 0;
    [self.circularProgressLayer setAffineTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    [self.layer addSublayer:self.circularProgressLayer];
    self.circularProgressLayer.hidden = YES;
    
    [self createCountdownLabel];
    self.circularProgressLayer.path = [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;

    [self.layer setCornerRadius:20.0];
    
    [self setAlpha:0.7];
}

- (void) performCircularAnimationWithStartTime:(NSDate *)startDate{
    
    if (!startTime) {
        startTime = startDate;
        self.circularProgressLayer.hidden = NO;
    }
    
    NSDate *dateNow = [NSDate date];
    NSTimeInterval timeElapsed = [dateNow timeIntervalSinceDate:startTime];
    if (timeElapsed < self.skipOffset) {
        [self.countdownlabel setText:[NSString stringWithFormat:@"%ld", (long)ceil(self.skipOffset - timeElapsed)]];
    }
    [self updateProgress:timeElapsed/self.skipOffset];
    if (timeElapsed >= self.skipOffset && !self.countdownlabel.hidden) {
        self.countdownlabel.hidden = YES;
        if ([self.delegate respondsToSelector:@selector(stopTimerForHTMLInterstitial)]) {
            [self.delegate stopTimerForHTMLInterstitial];
        }
        [self drawCloseButton];
        isButtonClickable = YES;
    }
}

- (void) updateProgress :(CGFloat)progress{
    if (progress > 1) {
        self.circularProgressLayer.strokeEnd = 1.0;
    }else if(progress < 0){
        self.circularProgressLayer.strokeEnd = 0.0;
    }else{
        self.circularProgressLayer.strokeEnd = progress;
    }
}

- (void) createCountdownLabel{
    
    CGRect frame = self.bounds;
    
    _countdownlabel = [[UILabel alloc] initWithFrame:frame];
    self.countdownlabel.center = self.center;
    [self.countdownlabel setFont:[UIFont systemFontOfSize:20.0]];
    [self.countdownlabel setTextColor:[UIColor whiteColor]];
    [self.countdownlabel setTextAlignment:NSTextAlignmentCenter];
    
    UIView *countdownLabelView = self.countdownlabel;
    countdownLabelView.accessibilityLabel = @"countdown label";
    
    [self addSubview:countdownLabelView];
    [self bringSubviewToFront:countdownLabelView];

}

- (void) drawCloseButton{
    CGRect lineFrame = APPNEXUS_INTERSTITIAL_CLOSE_BUTTON_CROSS_RECT;
    CAShapeLayer *line1 = [[CAShapeLayer alloc] init];
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    
    CGPoint startPointForLine1 = CGPointMake(lineFrame.origin.x, lineFrame.origin.y);
    CGPoint endPointForLine1 = CGPointMake(lineFrame.size.width, lineFrame.size.height);
    
    [path1 moveToPoint:startPointForLine1];
    [path1 addLineToPoint:endPointForLine1];
    
    line1.path = path1.CGPath;
    line1.fillColor = [UIColor clearColor].CGColor;
    line1.strokeColor = [UIColor whiteColor].CGColor;

    CAShapeLayer *line2 = [[CAShapeLayer alloc] init];
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    
    CGPoint startPointForLine2 = CGPointMake(lineFrame.origin.x, lineFrame.size.height);
    CGPoint endPointForLine2 = CGPointMake(lineFrame.size.width, lineFrame.origin.y);
    
    [path2 moveToPoint:startPointForLine2];
    [path2 addLineToPoint:endPointForLine2];
    
    line2.path = path2.CGPath;
    line2.fillColor = [UIColor clearColor].CGColor;
    line2.strokeColor = [UIColor whiteColor].CGColor;
    
    line1.lineWidth = 3;
    line2.lineWidth = 3;
    
    [self.layer addSublayer:line1];
    [self.layer addSublayer:line2];
    
    self.accessibilityLabel = @"close button";
    
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!isButtonClickable) {
        return NO;
    }
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    CGFloat highlightedAlphaValue = 2.0/3.0;
    if (isButtonClickable) {
        self.alpha = highlighted ? highlightedAlphaValue : 1.0;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    self.highlighted = NO;
    if (isButtonClickable) {
        [self.delegate closeButtonClicked];
    }
}

@end
