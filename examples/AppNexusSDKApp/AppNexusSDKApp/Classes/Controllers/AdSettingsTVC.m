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

#import "AdSettingsTVC.h"
#import "AdSettings.h"
#import "DataDisplayHelper.h"
#import "NoCaretUITextField.h"
#import "ANLogging.h"

#define CLASS_NAME @"AdSettingsTVC"

#define INVALID_HEX_ALERT_TITLE @""
#define INVALID_HEX_ALERT_MESSAGE @"Invalid Hex Color. Please specify color in ARGB format."
#define INVALID_HEX_ALERT_CANCEL @"OK"

@interface AdSettingsTVC () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) AdSettings *persistentSettings;

// General Settings
@property (weak, nonatomic) IBOutlet UISegmentedControl *adTypeToggle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *allowPSAToggle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *browserTypeToggle;
@property (weak, nonatomic) IBOutlet UITextField *placementIDTextField;


// Banner Settings
@property (weak, nonatomic) IBOutlet NoCaretUITextField *sizeTextField;
@property (strong, nonatomic) UIPickerView *sizePickerView;

@property (weak, nonatomic) IBOutlet NoCaretUITextField *refreshRateTextField;
@property (strong, nonatomic) UIPickerView *refreshRatePickerView;


// Interstitial Settings
@property (weak, nonatomic) IBOutlet UITextField *backgroundColorTextField;

// Debug Settings
@property (weak, nonatomic) IBOutlet UITextField *memberIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *dongleTextField;

@property (weak, nonatomic) IBOutlet UIView *colorView;
@end

@implementation AdSettingsTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self pickerViewSetup];
    [self currentSettingsSetup];
}

/*
    PickerView Data Source / Delegate Methods
 */

- (UIPickerView *)generatePickerView {
    return [[UIPickerView alloc] initWithFrame:CGRectMake(0.0,0.0,self.view.frame.size.width,162.0)];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // Update persistent ad settings on change
    if (pickerView == self.sizePickerView) {
        [self saveAdWidth:[[self.sizeDelegate class] bannerWidthAtIndex:row]
             andAdHeight:[[self.sizeDelegate class] bannerHeightAtIndex:row]];
        [self.sizeTextField sendActionsForControlEvents:UIControlEventEditingChanged];
    } else if (pickerView == self.refreshRatePickerView) {
        [self saveRefreshRate:[[self.refreshRateDelegate class] refreshRateAtIndex:row]];
        [self.refreshRateTextField sendActionsForControlEvents:UIControlEventEditingChanged];
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.sizePickerView) {
        return [[self.sizeDelegate class] sizeCount]; // return number of sizes
    } else if (pickerView == self.refreshRatePickerView) {
        return [[self.refreshRateDelegate class] refreshRateCount]; // return number of refresh rates
    }
    return 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1; // This picker view only has one column
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.sizePickerView) {
        return [[self.sizeDelegate class] sizeStringAtIndex:row]; // return size at array index
    } else if (pickerView == self.refreshRatePickerView) {
        return [[self.refreshRateDelegate class] refreshRateStringAtIndex:row]; // return refresh rate at array index
    }
    return @"";
}

- (void)pickerViewSetup {
    DataDisplayHelper *helper = [[DataDisplayHelper alloc] init];
    
    self.sizePickerView = [self generatePickerView];
    self.sizeTextField.inputView = self.sizePickerView;
    self.sizePickerView.delegate = self;
    self.sizeDelegate = helper;
    [self.sizePickerView selectRow:[[self.sizeDelegate class]
                                    indexForBannerSizeWithWidth:self.persistentSettings.bannerWidth
                                    height:self.persistentSettings.bannerHeight]
                       inComponent:0
                          animated:NO];
    
    self.refreshRatePickerView = [self generatePickerView];
    self.refreshRateTextField.inputView = self.refreshRatePickerView;
    self.refreshRatePickerView.delegate = self;
    self.refreshRateDelegate = helper;
    [self.refreshRatePickerView selectRow:[[self.refreshRateDelegate class] indexForRefreshRate:self.persistentSettings.refreshRate]
                              inComponent:0
                                 animated:NO];
}

/*
    Persistent Settings
 */

- (AdSettings *)persistentSettings {
    if (!_persistentSettings) _persistentSettings = [[AdSettings alloc] init];
    return _persistentSettings;
}

- (void)currentSettingsSetup {
    if (self.persistentSettings.adType == AD_TYPE_BANNER) {
        self.adTypeToggle.selectedSegmentIndex = 0;
        [self toggleAdType:YES];
    } else if (self.persistentSettings.adType == AD_TYPE_INTERSTITIAL) {
        self.adTypeToggle.selectedSegmentIndex = 1;
        [self toggleAdType:NO];
    }
    
    self.allowPSAToggle.selectedSegmentIndex = (self.persistentSettings.allowPSA) ? 0 : 1;
    
    if (self.persistentSettings.browserType == BROWSER_TYPE_IN_APP) {
        self.browserTypeToggle.selectedSegmentIndex = 0;
    } else if (self.persistentSettings.browserType == BROWSER_TYPE_DEVICE) {
        self.browserTypeToggle.selectedSegmentIndex = 1;
    }
    
    self.refreshRateTextField.text = [[self.refreshRateDelegate class] refreshRateStringFromInteger:self.persistentSettings.refreshRate];
    self.sizeTextField.text = [[self.sizeDelegate class] bannerSizeWithWidth:self.persistentSettings.bannerWidth
                                                                      height:self.persistentSettings.bannerHeight];
    
    self.memberIDTextField.text = [NSString stringWithFormat:@"%d", self.persistentSettings.memberID];
    self.dongleTextField.text = self.persistentSettings.dongle;
    self.placementIDTextField.text = [NSString stringWithFormat:@"%d", self.persistentSettings.placementID];
    self.backgroundColorTextField.text = self.persistentSettings.backgroundColor;
}

- (void)saveAdWidth:(NSInteger)width andAdHeight:(NSInteger)height {
    self.persistentSettings.bannerWidth = width;
    self.persistentSettings.bannerHeight = height;
    self.sizeTextField.text = [[self.sizeDelegate class] bannerSizeWithWidth:self.persistentSettings.bannerWidth
                                                                      height:self.persistentSettings.bannerHeight];
}

- (void)saveRefreshRate:(NSInteger)refreshRate {
    self.persistentSettings.refreshRate = refreshRate;
    self.refreshRateTextField.text = [[self.refreshRateDelegate class] refreshRateStringFromInteger:self.persistentSettings.refreshRate];
}

- (void)saveMemberID:(NSInteger)memberID {
    self.persistentSettings.memberID = memberID;
}

- (void)savePlacementID:(NSInteger)placementID {
    self.persistentSettings.placementID = placementID;
}

- (void)saveDongle:(NSString *)dongle {
    self.persistentSettings.dongle = dongle;
}

- (void)saveAdType:(NSInteger)adType {
    self.persistentSettings.adType = adType;
}

- (void)saveBrowser:(NSInteger)browserType {
    self.persistentSettings.browserType = browserType;
}

- (void)saveAllowPSA:(BOOL)allowPSA {
    self.persistentSettings.allowPSA = allowPSA;
}

- (BOOL)saveBackgroundColor:(NSString *)backgroundColor {
    if ([AdSettings backgroundColorIsValid:backgroundColor]) {
        self.persistentSettings.backgroundColor = backgroundColor; // Save as is, regardless of case
        // change color of UIView
        return YES;
    }
    
    return NO;
}

/*
    View Actions
 */

- (IBAction)makeKeyboardDisappear:(id)sender {
    [sender resignFirstResponder];
}

// Text Fields

- (IBAction)memberIDTap:(UITapGestureRecognizer *)sender {
    if ([self.memberIDTextField isEditing]) {
        [self.memberIDTextField resignFirstResponder];
    } else {
        [self saveTextFieldSettings];
        [self.memberIDTextField becomeFirstResponder];
    }
}

- (IBAction)placementIDTap:(UITapGestureRecognizer *)sender {
    if ([self.placementIDTextField isEditing]) {
        [self.placementIDTextField resignFirstResponder];
    } else {
        [self saveTextFieldSettings];
        [self.placementIDTextField becomeFirstResponder];
    }
}

- (IBAction)dongleTap:(UITapGestureRecognizer *)sender {
    if ([self.dongleTextField isEditing]) {
        [self.dongleTextField resignFirstResponder];
    } else {
        [self saveTextFieldSettings];
        [self.dongleTextField becomeFirstResponder];
    }
}
- (IBAction)backgroundColorTap:(UITapGestureRecognizer *)sender {
    if ([self.backgroundColorTextField isEditing]) {
        [self.backgroundColorTextField resignFirstResponder];
    } else {
        [self saveTextFieldSettings];
        [self.backgroundColorTextField becomeFirstResponder];
    }
}

- (void)handleBackgroundColorChange {
    BOOL isValid = [self saveBackgroundColor:self.backgroundColorTextField.text];
    if (!isValid) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:INVALID_HEX_ALERT_TITLE
                                                        message:INVALID_HEX_ALERT_MESSAGE
                                                       delegate:self
                                              cancelButtonTitle:INVALID_HEX_ALERT_CANCEL
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        self.backgroundColorTextField.text = self.persistentSettings.backgroundColor;
    }
}

- (IBAction)placementEditDidEnd:(UITextField *)sender {
    [self savePlacementID:[self.placementIDTextField.text intValue]];
}

- (IBAction)backgroundColorEditDidEnd:(UITextField *)sender {
    [self handleBackgroundColorChange];
}

- (IBAction)memberIDEditDidEnd:(UITextField *)sender {
    [self saveMemberID:[self.memberIDTextField.text intValue]];
}

- (IBAction)dongleEditDidEnd:(UITextField *)sender {
    [self saveDongle:self.dongleTextField.text];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView { // on scroll, save text field settings and resign any first responder
    [scrollView endEditing:YES];
}

- (void)saveTextFieldSettings {
    if ([self.memberIDTextField isEditing]) {
        [self saveMemberID:[self.memberIDTextField.text intValue]];
    }
    if ([self.dongleTextField isEditing]) {
        [self saveDongle:self.dongleTextField.text];
    }
    if ([self.placementIDTextField isEditing]) {
        [self savePlacementID:[self.placementIDTextField.text intValue]];
    }
    if ([self.backgroundColorTextField isEditing]) {
        [self handleBackgroundColorChange];
    }
}

// Picker views

- (IBAction)refreshRateTap:(UITapGestureRecognizer *)sender {
    if ([self.refreshRateTextField isEditing]) {
        [self.refreshRateTextField resignFirstResponder];
    } else {
        [self.refreshRateTextField becomeFirstResponder];
    }
}

- (IBAction)sizeTap:(UITapGestureRecognizer *)sender {
    if ([self.sizeTextField isEditing]) {
        [self.sizeTextField resignFirstResponder];
    } else {
        [self.sizeTextField becomeFirstResponder];
    }
}

// Segmented Controls

- (IBAction)setAdTypeSegmentedControl:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex) {
        [self saveAdType:AD_TYPE_INTERSTITIAL];
        [self toggleAdType:NO];
    } else {
        [self saveAdType:AD_TYPE_BANNER];
        [self toggleAdType:YES];
    }
}

- (IBAction)setAllowPSASegmentedControl:(UISegmentedControl *)sender {
    sender.selectedSegmentIndex ? [self saveAllowPSA:NO] : [self saveAllowPSA:YES];
}

- (IBAction)setBrowserSegmentedControl:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex) {
        [self saveBrowser:BROWSER_TYPE_DEVICE];
    } else {
        [self saveBrowser:BROWSER_TYPE_IN_APP];
    }
}

- (void)toggleAdType:(BOOL)isBanner {
    UIColor *bannerColors = isBanner ? [UIColor orangeColor] : [UIColor grayColor];
    UIColor *interstitialColors = !isBanner ? [UIColor orangeColor] : [UIColor grayColor];
    [self.sizeTextField setUserInteractionEnabled:isBanner];
    self.sizeTextField.textColor = bannerColors;
    [self.sizePickerView setUserInteractionEnabled:isBanner];
    [self.refreshRateTextField setUserInteractionEnabled:isBanner];
    self.refreshRateTextField.textColor = bannerColors;
    [self.refreshRatePickerView setUserInteractionEnabled:isBanner];

    [self.backgroundColorTextField setUserInteractionEnabled:!isBanner];
    self.backgroundColorTextField.textColor = interstitialColors;
}

@end
