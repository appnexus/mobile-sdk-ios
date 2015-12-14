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

#import "ANVolumeButtonView.h"
#import "ANGlobal.h"
#import "ANVASTUtil.h"
#import "UIView+ANCategory.h"

@interface ANVolumeButtonView() 

@property (nonatomic, strong) UIButton *volumeButton;

@end

@implementation ANVolumeButtonView

- (instancetype)initWithDelegate:(id<ANVolumeButtonViewDelegate>)delegate {
    self = [super init];
    
    if (self){
        self.delegate = delegate;
        [self addVolumeButton];
    }
    
    return self;
}

- (void)addVolumeButton {
    self.volumeButton = [[UIButton alloc] init];
    self.volumeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.volumeButton addTarget:self
                          action:@selector(handleVolumeButton)
                forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.volumeButton];
    [self.volumeButton an_alignToSuperviewWithXAttribute:NSLayoutAttributeLeft
                                              yAttribute:NSLayoutAttributeTop];
    [self.volumeButton an_constrainToSizeOfSuperview];
    
    [self.volumeButton setAlpha:0.7];
    [self setBackgroundColor:[UIColor clearColor]];
    self.volumeButton.accessibilityLabel = @"volume button";
}

- (void)handleVolumeButton {
    self.isVolumeMuted = !self.isVolumeMuted;
    [self.delegate mutePlayer:self.isVolumeMuted];
}

- (void)setIsVolumeMuted:(BOOL)isVolumeMuted {
    _isVolumeMuted = isVolumeMuted;
    UIImage *volumeImage;
    
    if (_isVolumeMuted) {
        volumeImage = [UIImage imageWithContentsOfFile:ANPathForANResource(@"mute-on", @"png")];
    } else {
        volumeImage = [UIImage imageWithContentsOfFile:ANPathForANResource(@"mute-off",@"png")];
    }
    
    [self.volumeButton setBackgroundImage:volumeImage forState:UIControlStateNormal];
}

@end