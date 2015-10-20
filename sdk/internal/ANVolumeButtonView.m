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

@interface ANVolumeButtonView(){
    BOOL isVolumeMuted;
}

@property (nonatomic, strong) UIButton *volumeButton;

@end

@implementation ANVolumeButtonView

- (instancetype) initWithDelegate:(id<ANVolumeButtonViewDelegate>)delegate{
    self = [super init];
    
    if(self){
        self.delegate = delegate;
    }
    
    return self;
}

//ContainerView is AVPlayerView that is passed from the parent class.The volume button is displayed on this view.
- (void) addVolumeViewWithContainer:(UIView *)containerView{
    
    _volumeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    UIImage *volumeImage = [UIImage imageWithContentsOfFile:ANPathForANResource(@"mute-off",@"png")];
    [self.volumeButton setBackgroundImage:volumeImage forState:UIControlStateNormal];
    
    [self.volumeButton addTarget:self action:@selector(handleVolumeButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self.volumeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [containerView addSubview:self.volumeButton];
    [containerView bringSubviewToFront:self.volumeButton];
    
    UIView *volumeView = self.volumeButton;
    
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[volumeView(==50)]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(volumeView)]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[volumeView(==50)]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(volumeView)]];
    

    [volumeView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.1]];
    [volumeView setAlpha:0.7];
}


- (void) handleVolumeButton{
    isVolumeMuted = !isVolumeMuted;
    
    UIImage *volumeImage;
    
    if (isVolumeMuted) {
        volumeImage = [UIImage imageWithContentsOfFile:ANPathForANResource(@"mute-on", @"png")];
        [self mute:YES];
    }else{
        volumeImage = [UIImage imageWithContentsOfFile:ANPathForANResource(@"mute-off",@"png")];
        [self mute:NO];
    }

    [self.volumeButton setBackgroundImage:volumeImage forState:UIControlStateNormal];

}

- (void) mute:(BOOL)value{
    [self.delegate mute:value];
}

- (void)dealloc{    
    _volumeButton = nil;
}

@end
