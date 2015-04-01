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

#import "ANMRAIDResizeViewManager.h"
#import "ANLogging.h"
#import "UIView+ANCategory.h"
#import "ANMRAIDResizeView.h"

@interface ANMRAIDResizeViewManager () <ANMRAIDResizeViewDelegate>

@property (nonatomic, readwrite, strong) NSLayoutConstraint *rootViewLeftConstraint;
@property (nonatomic, readwrite, strong) NSLayoutConstraint *rootViewTopConstraint;

@property (nonatomic, readwrite, strong) ANMRAIDResizeProperties *lastResizeProperties;

@property (nonatomic, readwrite, strong) ANMRAIDResizeView *resizeView;
@property (nonatomic, readwrite, weak) UIView *anchorView;
@property (nonatomic, readwrite, weak) UIView *contentView;
@property (nonatomic, readwrite, assign, getter=isResized) BOOL resized;

@end

@implementation ANMRAIDResizeViewManager

#pragma mark - MRAID Resize Validation

+ (BOOL)validateMRAIDResizeFromView:(UIView *)view
               withResizeProperties:(ANMRAIDResizeProperties *)properties
                        errorString:(NSString *__autoreleasing *)errorString {
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGRect resizedBounds;
    resizedBounds.origin.x = view.bounds.origin.x + properties.offsetX;
    resizedBounds.origin.y = view.bounds.origin.y + properties.offsetY;
    resizedBounds.size.width = properties.width;
    resizedBounds.size.height = properties.height;
    
    CGRect resizedBoundsInWindowCoordinates = [view convertRect:resizedBounds
                                                         toView:nil];
    CGRect resizedIntersection = CGRectIntersection(screenBounds, resizedBoundsInWindowCoordinates);
    
    if (resizedIntersection.size.width < kANResizeViewCloseRegionWidth
        || resizedIntersection.size.height < kANResizeViewCloseRegionHeight) {
        *errorString = [NSString stringWithFormat:@"Resize call should keep at least %fx%f of the creative on screen", kANResizeViewCloseRegionWidth, kANResizeViewCloseRegionHeight];
        return NO;
    } else if (resizedIntersection.size.width > screenBounds.size.width
               && resizedIntersection.size.height > screenBounds.size.height) {
        *errorString = @"Resize called with resizeProperties larger than the screen.";
        return NO;
    }
    
    return YES;
}

#pragma mark - ANResizeViewManager Implementation

- (instancetype)initWithContentView:(UIView *)contentView
                         anchorView:(UIView *)anchorView {
    if (contentView == anchorView) {
        ANLogError(@"%@ Anchor view cannot be the same as the content view", NSStringFromClass([self class]));
        return nil;
    }
    if (!contentView || !anchorView) {
        ANLogError(@"%@ Content view, anchor view, and root view have to be defined", NSStringFromClass([self class]));
        return nil;
    }
    
    if (self = [super init]) {
        _contentView = contentView;
        _anchorView = anchorView;
        _resizeView = [[ANMRAIDResizeView alloc] init];
        _resizeView.delegate = self;
        _resizeView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (BOOL)attemptResizeWithResizeProperties:(ANMRAIDResizeProperties *)properties
                              errorString:(NSString *__autoreleasing*)errorString {

    BOOL allowResize = [ANMRAIDResizeViewManager validateMRAIDResizeFromView:self.anchorView
                                                        withResizeProperties:properties
                                                            errorString:errorString];
    
    if (allowResize) {
        self.lastResizeProperties = properties;
        [self resizeWithResizeProperties:properties];
        self.resized = YES;
    }
    
    return allowResize;
}

- (void)resizeWithResizeProperties:(ANMRAIDResizeProperties *)properties {
    self.resizeView.closePosition = properties.customClosePosition;
    [self.resizeView an_constrainWithSize:CGSizeMake(properties.width, properties.height)];
    
    if (!self.resizeView.superview) {
        [self.anchorView.window addSubview:self.resizeView];
    }

    if (!self.resizeView.contentView) {
        [self.resizeView attachContentView:self.contentView];
    }
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(coordinateSpace)]) {
        if (self.rootViewLeftConstraint) {
            self.rootViewLeftConstraint.constant = properties.offsetX;
        } else {
            self.rootViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.resizeView
                                                                       attribute:NSLayoutAttributeLeft
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.anchorView
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1.0
                                                                        constant:properties.offsetX];
            [self.anchorView.window addConstraint:self.rootViewLeftConstraint];
        }
        
        if (self.rootViewTopConstraint) {
            self.rootViewTopConstraint.constant = properties.offsetY;
        } else {
            self.rootViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.resizeView
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.anchorView
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0
                                                                       constant:properties.offsetY];
            [self.anchorView.window addConstraint:self.rootViewTopConstraint];
        }
    } else {
        CGRect boundsToResizeTo = self.anchorView.bounds;
        boundsToResizeTo.origin.x += properties.offsetX;
        boundsToResizeTo.origin.y += properties.offsetY;
        boundsToResizeTo.size = CGSizeMake(properties.width, properties.height);
        CGRect frameToResizeToInWindowCoordinates = [self.anchorView convertRect:boundsToResizeTo
                                                                          toView:nil];
        self.resizeView.frame = frameToResizeToInWindowCoordinates;
        self.resizeView.transform = [self transformForOrientation];
        
        [self setupRotationListener];
    }
}

- (void)detachResizeView {
    if (self.resized) {
        [self.resizeView removeFromSuperview];
        self.resized = NO;
        [self removeRootViewConstraints];
        self.resizeView = nil;
        self.lastResizeProperties = nil;
        [self unregisterFromDeviceOrientationNotification];
    }
}

- (void)removeRootViewConstraints {
    [self.anchorView.window removeConstraint:self.rootViewLeftConstraint];
    [self.anchorView.window removeConstraint:self.rootViewTopConstraint];
    self.rootViewLeftConstraint = nil;
    self.rootViewTopConstraint = nil;
}

- (void)didMoveAnchorViewToWindow {
    if (self.resized) {
        if (self.anchorView.window) {
            [self resizeWithResizeProperties:self.lastResizeProperties];
        } else {
            [self.resizeView removeFromSuperview];
            [self removeRootViewConstraints];
        }
    }
}

# pragma mark - Pre-iOS 8 resize

- (CGAffineTransform)transformForOrientation {
    CGFloat radians = 0;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            radians = -(CGFloat)M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            radians = (CGFloat)M_PI_2;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            radians = (CGFloat)M_PI;
            break;
        default:
            radians = 0.0f;
            break;
    }
    
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(radians);
    return rotationTransform;
}

- (void)setupRotationListener {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)handleDeviceOrientationDidChangeNotification:(NSNotification *)notification {
    [self resizeWithResizeProperties:self.lastResizeProperties];
}

- (void)unregisterFromDeviceOrientationNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

#pragma mark - ANResizeViewManagerDelegate

- (void)closeRegionSelectedOnResizeView:(ANMRAIDResizeView *)resizeView {
    [self detachResizeView];
    [self.delegate resizeViewClosedByResizeViewManager:self];
}

- (void)dealloc {
    [self detachResizeView];
}

@end