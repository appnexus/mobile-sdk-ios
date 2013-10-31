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
#import "ANBannerAdView.h"

@interface ANDemoAdsViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, readwrite, weak) IBOutlet UITextField *sizeTextField;
@property (nonatomic, readwrite, weak) IBOutlet UITextField *refreshTextField;
@property (nonatomic, readwrite, weak) IBOutlet UITextField *tagTextField;
@property (nonatomic, readwrite, strong) IBOutlet UIView *pickerInputView;
@property (nonatomic, readwrite, weak) IBOutlet UIPickerView *pickerView;
@property (nonatomic, readwrite, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, readwrite, strong) IBOutlet ANBannerAdView *bannerAdView;
@property (nonatomic, readwrite, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, readwrite, weak) IBOutlet UIView *containerView;
@property (nonatomic, readwrite, weak) IBOutlet UIView *controlsView;

- (IBAction)pickerInputViewDone:(id)sender;
- (IBAction)loadAd:(id)sender;
- (IBAction)segementedControlDidChange:(id)sender;

@end
