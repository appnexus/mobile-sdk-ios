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

#import "ANPBContainerView.h"
#import "ANPBBuffer.h"
#import "ANLogging.h"

static CGFloat const kANPBContainerViewLogoWidth = 50.0f;
static CGFloat const kANPBContainerViewLogoAlpha = 0.6f;
static NSString *const kANPBContainerViewIconName = @"appnexus_logo_icon";

@implementation ANPBContainerView

- (instancetype)initWithContentView:(UIView *)contentView {
    self = [super initWithFrame:contentView.frame];
    if (self) {
        [self addSubview:contentView];
        [self setupButton];
    }
    return self;
}

- (instancetype)initWithLogo {
    self = [super initWithFrame:CGRectMake(0, 0, kANPBContainerViewLogoWidth, kANPBContainerViewLogoWidth)];
    if (self) {
        [self setupButton];
    }
    return self;
}

- (void)launchPitbullApp {
    [ANPBBuffer launchPitbullApp];
}

- (void)setupButton {
    NSString *iconPath = ANPathForANResource(kANPBContainerViewIconName, @"png");
    if (!iconPath) {
        ANLogError(@"Could not add native AdTrace logo to ad");
        return;
    }
    UIImage *icon = [UIImage imageWithContentsOfFile:iconPath];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kANPBContainerViewLogoWidth, kANPBContainerViewLogoWidth)];
    [button setImage:icon
            forState:UIControlStateNormal];
    [button setAlpha:kANPBContainerViewLogoAlpha];
    [self addSubview:button];
    [button addTarget:self
               action:@selector(launchPitbullApp)
     forControlEvents:UIControlEventTouchUpInside];
}

@end