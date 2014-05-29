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
#import "ANAdProtocol.h"
#import "AppNexusSDKAppSectionHeaderView.h"
#import "AppNexusSDKAppModalViewController.h"
#import "CustomKeywordsTVC.h"
#import "BackgroundColorView.h"
#import "AppNexusSDKAppGlobal.h"
#import "ANGlobal.h"

#define CLASS_NAME @"AdSettingsTVC"

#define INVALID_HEX_ALERT_TITLE @""
#define INVALID_HEX_ALERT_MESSAGE @"Invalid Hex Color. Please specify color in ARGB format."
#define INVALID_HEX_ALERT_CANCEL @"OK"

#pragma mark Section Header Constants

static NSString *const AdSettingsSectionHeaderViewIdentifier = @"AdSettingsSectionHeaderViewIdentifier";

static NSInteger const AdSettingsSectionHeaderGeneralIndex = 0;
static NSInteger const AdSettingsSectionHeaderTargetingIndex = 1;
static NSInteger const AdSettingsSectionHeaderAdvancedIndex = 2;
static NSInteger const AdSettingsSectionHeaderDebugAuctionIndex = 3;

static BOOL AdSettingsSectionGeneralIsOpen = YES;
static BOOL AdSettingsSectionTargetingIsOpen = NO;
static BOOL AdSettingsSectionAdvancedIsOpen = NO;
static BOOL AdSettingsSectionDebugAuctionIsOpen = NO;

static NSString *const AdSettingsSectionHeaderTitleLabelGeneral = @"General";
static NSString *const AdSettingsSectionHeaderTitleLabelTargeting = @"Targeting";
static NSString *const AdSettingsSectionHeaderTitleLabelAdvanced = @"Advanced";
static NSString *const AdSettingsSectionHeaderTitleLabelDebugAuction = @"Diagnostics";

static NSInteger const AdSettingsSizePickerIndex = 2;
static NSInteger const AdSettingsRefreshRatePickerIndex = 3;

static NSInteger const AdSettingsSizePickerSection = 0;
static NSInteger const AdSettingsRefreshRatePickerSection = 2;

#pragma end

@interface AdSettingsTVC () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource,
AppNexusSDKAppSectionHeaderViewDelegate, AppNexusSDKAppModalViewControllerDelegate>

@property (strong, nonatomic) AdSettings *persistentSettings;

#pragma mark General
@property (weak, nonatomic) IBOutlet UISegmentedControl *adTypeToggle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *allowPSAToggle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *browserTypeToggle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *environmentToggle;

@property (weak, nonatomic) IBOutlet UITextField *placementIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderToggle;
@property (weak, nonatomic) IBOutlet UITextField *reserveTextField;
@property (weak, nonatomic) IBOutlet UITextField *zipcodeTextField;

# pragma mark Banner
@property (weak, nonatomic) IBOutlet NoCaretUITextField *sizeTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *sizePickerView;

@property (weak, nonatomic) IBOutlet NoCaretUITextField *refreshRateTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *refreshRatePickerView;

#pragma mark Interstitial
@property (weak, nonatomic) IBOutlet UITextField *backgroundColorTextField;
@property (weak, nonatomic) IBOutlet BackgroundColorView *colorView;

#pragma mark Debug
@property (weak, nonatomic) IBOutlet UITextField *memberIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *dongleTextField;

@property (nonatomic, assign) BOOL sizePickerViewIsVisible;
@property (nonatomic, assign) BOOL refreshRatePickerViewIsVisible;

@end

@implementation AdSettingsTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self currentSettingsSetup];
    
    UINib *sectionHeaderNib = [UINib nibWithNibName:@"AppNexusSDKAppSectionHeaderView" bundle:nil];
    [self.tableView registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:AdSettingsSectionHeaderViewIdentifier];
}

- (IBAction)makeKeyboardDisappear:(id)sender {
    [sender resignFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self hidePickerViews];
}

#pragma mark Current Settings Setup

- (void)currentSettingsSetup {
    DataDisplayHelper *helper = [[DataDisplayHelper alloc] init];
    self.sizeDelegate = helper;
    self.refreshRateDelegate = helper;
    self.reservePriceDelegate = helper;
    
    [self pickerViewSetup];
    [self segmentedControlsSetup];
    [self textFieldsSetup];
}

#pragma mark Picker Views - Initial Setup

- (void)pickerViewSetup {
    [self.sizePickerView selectRow:[[self.sizeDelegate class]
                                    indexForBannerSizeWithWidth:self.persistentSettings.bannerWidth
                                    height:self.persistentSettings.bannerHeight]
                       inComponent:0
                          animated:NO];
    [self.refreshRatePickerView selectRow:[[self.refreshRateDelegate class] indexForRefreshRate:self.persistentSettings.refreshRate]
                              inComponent:0
                                 animated:NO];
    self.sizePickerViewIsVisible = NO;
    self.refreshRatePickerViewIsVisible = NO;
    [self.sizePickerView setHidden:YES];
    [self.refreshRatePickerView setHidden:YES];
}

#pragma mark Picker Views - Delegate Methods

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

#pragma mark Picker Views - On Tap

- (IBAction)refreshRateTap:(UITapGestureRecognizer *)sender {
    if (self.persistentSettings.adType == AD_TYPE_BANNER) {
        self.refreshRatePickerViewIsVisible = !self.refreshRatePickerViewIsVisible;
        if (self.refreshRatePickerViewIsVisible) [self.tableView endEditing:YES];
        self.sizePickerViewIsVisible = NO;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [self pickerView:self.refreshRatePickerView setHidden:!self.refreshRatePickerViewIsVisible];
    }
}

- (IBAction)sizeTap:(UITapGestureRecognizer *)sender {
    if (self.persistentSettings.adType == AD_TYPE_BANNER) {
        self.sizePickerViewIsVisible = !self.sizePickerViewIsVisible;
        if (self.sizePickerViewIsVisible) [self.tableView endEditing:YES];
        self.refreshRatePickerViewIsVisible = NO;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [self pickerView:self.sizePickerView setHidden:!self.sizePickerViewIsVisible];
    }
}

- (void)pickerView:(UIPickerView *)pickerView setHidden:(BOOL)hidden {
    [pickerView setHidden:hidden];
}

- (void)hidePickerViews {
    if (self.sizePickerViewIsVisible) {
        self.sizePickerViewIsVisible = NO;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [self pickerView:self.sizePickerView setHidden:!self.sizePickerViewIsVisible];
    }
    
    if (self.refreshRatePickerViewIsVisible) {
        self.refreshRatePickerViewIsVisible = NO;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [self pickerView:self.refreshRatePickerView setHidden:!self.refreshRatePickerViewIsVisible];
    }
}

#pragma mark Persistent Settings

- (AdSettings *)persistentSettings {
    if (!_persistentSettings) _persistentSettings = [[AdSettings alloc] init];
    return _persistentSettings;
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

- (void)saveReserve:(double)reserve {
    self.persistentSettings.reserve = reserve;
}

- (void)saveAge:(NSString *)age {
    self.persistentSettings.age = age;
}

- (void)saveGender:(NSInteger)gender {
    self.persistentSettings.gender = gender;
}

- (void)saveZipcode:(NSString *)zipcode {
    self.persistentSettings.zipcode = zipcode;
}

- (void)saveEnvironment:(ANMobileEndpoint)environment {
    self.persistentSettings.environment = environment;
}

- (BOOL)saveBackgroundColor:(NSString *)backgroundColor {
    if ([AdSettings backgroundColorIsValid:backgroundColor]) {
        self.persistentSettings.backgroundColor = backgroundColor;
        return YES;
    }
    
    return NO;
}

#pragma mark Text Fields - Initial Setup

- (void)textFieldsSetup {
    self.refreshRateTextField.text = [[self.refreshRateDelegate class] refreshRateStringFromInteger:self.persistentSettings.refreshRate];
    self.sizeTextField.text = [[self.sizeDelegate class] bannerSizeWithWidth:self.persistentSettings.bannerWidth
                                                                      height:self.persistentSettings.bannerHeight];
    
    self.memberIDTextField.text = [NSString stringWithFormat:@"%d", self.persistentSettings.memberID];
    self.dongleTextField.text = self.persistentSettings.dongle;
    self.placementIDTextField.text = [NSString stringWithFormat:@"%d", self.persistentSettings.placementID];
    self.backgroundColorTextField.text = self.persistentSettings.backgroundColor;
    [self.colorView setColor:[AppNexusSDKAppGlobal colorFromString:self.persistentSettings.backgroundColor]];
    self.ageTextField.text = self.persistentSettings.age;
    self.reserveTextField.text = [[self.reservePriceDelegate class] stringFromReservePrice:self.persistentSettings.reserve];
    self.zipcodeTextField.text = self.persistentSettings.zipcode;
    
    [self.sizeTextField setEnabled:NO];
    [self.refreshRateTextField setEnabled:NO];
}

#pragma mark Text Fields - On Tap

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

- (IBAction)ageTap:(UITapGestureRecognizer *)sender {
    if ([self.ageTextField isEditing]) {
        [self.ageTextField resignFirstResponder];
    } else {
        [self saveTextFieldSettings];
        [self.ageTextField becomeFirstResponder];
    }
}

- (IBAction)reserveTap:(UITapGestureRecognizer *)sender {
    if ([self.reserveTextField isEditing]) {
        [self.reserveTextField resignFirstResponder];
    } else {
        [self saveTextFieldSettings];
        [self.reserveTextField becomeFirstResponder];
    }
}

- (IBAction)zipcodeTap:(UITapGestureRecognizer *)sender {
    if ([self.zipcodeTextField isEditing]) {
        [self.zipcodeTextField resignFirstResponder];
    } else {
        [self saveTextFieldSettings];
        [self.zipcodeTextField becomeFirstResponder];
    }
}

#pragma mark Text Fields - Did End

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

- (IBAction)ageEditingDidEnd:(UITextField *)sender {
    [self saveAge:self.ageTextField.text];
}

- (IBAction)reserveEditingDidEnd:(UITextField *)sender {
    [self saveReserve:[self.reserveTextField.text doubleValue]];
}

- (IBAction)zipcodeEditingDidEnd:(UITextField *)sender {
    [self saveZipcode:self.zipcodeTextField.text];
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
    if ([self.ageTextField isEditing]) {
        [self saveAge:self.ageTextField.text];
    }
    if ([self.reserveTextField isEditing]) {
        [self saveReserve:[self.reserveTextField.text doubleValue]];
    }
    if ([self.zipcodeTextField isEditing]) {
        [self saveZipcode:self.zipcodeTextField.text];
    }
}

- (void)handleBackgroundColorChange {
    BOOL isValid = [self saveBackgroundColor:self.backgroundColorTextField.text];
    self.backgroundColorTextField.text = self.persistentSettings.backgroundColor;
    [self.colorView setColor:[AppNexusSDKAppGlobal colorFromString:self.persistentSettings.backgroundColor]];

    if (!isValid) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:INVALID_HEX_ALERT_TITLE
                                                        message:INVALID_HEX_ALERT_MESSAGE
                                                       delegate:self
                                              cancelButtonTitle:INVALID_HEX_ALERT_CANCEL
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark Segmented Controls - Initial Setup 

- (void)segmentedControlsSetup {
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
    
    self.genderToggle.selectedSegmentIndex = self.persistentSettings.gender;
 
    if (self.persistentSettings.environment == ANMobileEndpointProduction) {
        self.environmentToggle.selectedSegmentIndex = 0;
    } else if (self.persistentSettings.environment == ANMobileEndpointClientTesting) {
        self.environmentToggle.selectedSegmentIndex = 1;
    }
}

#pragma mark Segmented Controls - On Change

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

- (IBAction)setEnvrionmentSegmentedControl:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self saveEnvironment:ANMobileEndpointProduction];
            break;
        case 1:
            [self saveEnvironment:ANMobileEndpointClientTesting];
            break;
        default:
            break;
    }
}

- (IBAction)setGenderSegmentedControl:(UISegmentedControl *)sender {
    [self saveGender:sender.selectedSegmentIndex];
}

- (void)toggleAdType:(BOOL)isBanner {
    UIColor *bannerColors = isBanner ? [UIColor orangeColor] : [UIColor grayColor];
    UIColor *interstitialColors = !isBanner ? [UIColor orangeColor] : [UIColor grayColor];
    
    self.sizeTextField.textColor = bannerColors;
    self.refreshRateTextField.textColor = bannerColors;
    
    [self.sizePickerView setUserInteractionEnabled:isBanner];
    [self.refreshRatePickerView setUserInteractionEnabled:isBanner];
    
    [self hidePickerViews];

    [self.backgroundColorTextField setUserInteractionEnabled:!isBanner];
    self.backgroundColorTextField.textColor = interstitialColors;
    
    self.colorView.hidden = isBanner;
}

#pragma mark Section Headers

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    AppNexusSDKAppSectionHeaderView *sectionHeaderView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:AdSettingsSectionHeaderViewIdentifier];
    switch (section) {
        case (AdSettingsSectionHeaderGeneralIndex):
            sectionHeaderView.titleLabel.text = AdSettingsSectionHeaderTitleLabelGeneral;
            sectionHeaderView.disclosureButton.selected = AdSettingsSectionGeneralIsOpen;
            break;
        case (AdSettingsSectionHeaderAdvancedIndex):
            sectionHeaderView.titleLabel.text = AdSettingsSectionHeaderTitleLabelAdvanced;
            sectionHeaderView.disclosureButton.selected = AdSettingsSectionAdvancedIsOpen;
            break;
        case (AdSettingsSectionHeaderDebugAuctionIndex):
            sectionHeaderView.titleLabel.text = AdSettingsSectionHeaderTitleLabelDebugAuction;
            sectionHeaderView.disclosureButton.selected = AdSettingsSectionDebugAuctionIsOpen;
            break;
        case (AdSettingsSectionHeaderTargetingIndex):
            sectionHeaderView.titleLabel.text = AdSettingsSectionHeaderTitleLabelTargeting;
            sectionHeaderView.disclosureButton.selected = AdSettingsSectionTargetingIsOpen;
            break;
        default:
            sectionHeaderView.titleLabel.text = @"";
            sectionHeaderView.disclosureButton.selected = NO;
            break;
    }
    sectionHeaderView.section = section;
    sectionHeaderView.delegate = self;
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35.0f;
}

- (void)sectionHeaderView:(AppNexusSDKAppSectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)section {
    switch (section) {
        case (AdSettingsSectionHeaderGeneralIndex):
            if (AdSettingsSectionGeneralIsOpen) return;
            AdSettingsSectionGeneralIsOpen = YES;
            break;
        case (AdSettingsSectionHeaderAdvancedIndex):
            if (AdSettingsSectionAdvancedIsOpen) return;
            AdSettingsSectionAdvancedIsOpen = YES;
            break;
        case (AdSettingsSectionHeaderDebugAuctionIndex):
            if (AdSettingsSectionDebugAuctionIsOpen) return;
            AdSettingsSectionDebugAuctionIsOpen = YES;
            break;
        case (AdSettingsSectionHeaderTargetingIndex):
            if (AdSettingsSectionTargetingIsOpen) return;
            AdSettingsSectionTargetingIsOpen = YES;
            break;
        default:
            return;
    }
    NSMutableArray *indexPathsToAdd = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i < [super tableView:self.tableView numberOfRowsInSection:section]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
        [indexPathsToAdd addObject:indexPath];
    }
    [self.tableView insertRowsAtIndexPaths:indexPathsToAdd withRowAnimation:UITableViewRowAnimationFade];
}

- (void)sectionHeaderView:(AppNexusSDKAppSectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)section {
    switch (section) {
        case (AdSettingsSectionHeaderGeneralIndex):
            if (!AdSettingsSectionGeneralIsOpen) return;
            AdSettingsSectionGeneralIsOpen = NO;
            break;
        case (AdSettingsSectionHeaderAdvancedIndex):
            if (!AdSettingsSectionAdvancedIsOpen) return;
            AdSettingsSectionAdvancedIsOpen = NO;
            break;
        case (AdSettingsSectionHeaderDebugAuctionIndex):
            if (!AdSettingsSectionDebugAuctionIsOpen) return;
            AdSettingsSectionDebugAuctionIsOpen = NO;
            break;
        case (AdSettingsSectionHeaderTargetingIndex):
            if (!AdSettingsSectionTargetingIsOpen) return;
            AdSettingsSectionTargetingIsOpen = NO;
            break;
        default:
            return;
    }
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i < [super tableView:self.tableView numberOfRowsInSection:section]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
        [indexPathsToDelete addObject:indexPath];
    }
    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationFade];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case AdSettingsSectionHeaderGeneralIndex:
            if (!AdSettingsSectionGeneralIsOpen) return 0;
            break;
        case AdSettingsSectionHeaderAdvancedIndex:
            if (!AdSettingsSectionAdvancedIsOpen) return 0;
            break;
        case AdSettingsSectionHeaderDebugAuctionIndex:
            if (!AdSettingsSectionDebugAuctionIsOpen) return 0;
            break;
        case AdSettingsSectionHeaderTargetingIndex:
            if (!AdSettingsSectionTargetingIsOpen) return 0;
            break;
        default:
            break;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

#pragma mark Custom Keywords Modal View Controller

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[AppNexusSDKAppModalViewController class]]) {
        AppNexusSDKAppModalViewController *help = (AppNexusSDKAppModalViewController *)[segue destinationViewController];
        help.orientation = [UIApplication sharedApplication].statusBarOrientation;
        [UIApplication sharedApplication].keyWindow.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        help.delegate = self;
    }
}

- (void)sdkAppModalViewControllerShouldDismiss:(AppNexusSDKAppModalViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^{
        [UIApplication sharedApplication].keyWindow.rootViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        self.persistentSettings = nil;
    }];
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isSizePickerCell = indexPath.section == AdSettingsSizePickerSection && indexPath.item == AdSettingsSizePickerIndex;
    BOOL isRefreshRatePickerCell = indexPath.section == AdSettingsRefreshRatePickerSection && indexPath.item == AdSettingsRefreshRatePickerIndex;
    if ((isSizePickerCell && !self.sizePickerViewIsVisible) || (isRefreshRatePickerCell && !self.refreshRatePickerViewIsVisible)) {
        return 0.0f;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self hidePickerViews];
}

@end
