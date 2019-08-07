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

#import <UIKit/UIKit.h>
#import "ANMRAIDUtil.h"

@class ANMRAIDExpandProperties;
@class ANMRAIDOrientationProperties;
@protocol ANMRAIDExpandViewControllerDelegate;

static CGFloat const kANMRAIDExpandViewControllerCloseRegionWidth = 50.0;
static CGFloat const kANMRAIDExpandViewControllerCloseRegionHeight = 50.0;

@interface ANMRAIDExpandViewController : UIViewController

- (instancetype)initWithContentView:(UIView *)contentView
                   expandProperties:(ANMRAIDExpandProperties *)expandProperties;
- (UIView *)detachContentView;

@property (nonatomic, readwrite, weak) id<ANMRAIDExpandViewControllerDelegate> delegate;
@property (nonatomic, readwrite, strong) ANMRAIDOrientationProperties *orientationProperties;

@end

@protocol ANMRAIDExpandViewControllerDelegate <NSObject>

- (void)closeButtonWasTappedOnExpandViewController:(ANMRAIDExpandViewController *)controller;
- (void)dismissAndPresentAgainForPreferredInterfaceOrientationChange;

@end