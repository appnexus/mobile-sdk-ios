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

@protocol ANInterstitialAdViewControllerDelegate;
@class ANMRAIDOrientationProperties;

@interface ANInterstitialAdViewController : UIViewController

@property (nonatomic, readwrite, weak) id<ANInterstitialAdViewControllerDelegate> delegate;
@property (nonatomic, readwrite, strong) UIView *contentView;
@property (nonatomic, readwrite, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, readwrite, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, readwrite, strong) UIColor *backgroundColor;
@property (nonatomic, readonly, assign) UIInterfaceOrientation orientation;
@property (nonatomic, readwrite, weak) IBOutlet NSLayoutConstraint *buttonTopToSuperviewConstraint;

@property (nonatomic, readwrite, strong) ANMRAIDOrientationProperties *orientationProperties;
@property (nonatomic, readwrite, assign) BOOL useCustomClose;

- (IBAction)closeAction:(id)sender;
- (void)stopCountdownTimer;

@end

@protocol ANInterstitialAdViewControllerDelegate <NSObject>

- (void)interstitialAdViewControllerShouldDismiss:(ANInterstitialAdViewController *)controller;
- (NSTimeInterval)closeDelayForController;
- (void)dismissAndPresentAgainForPreferredInterfaceOrientationChange;

@end