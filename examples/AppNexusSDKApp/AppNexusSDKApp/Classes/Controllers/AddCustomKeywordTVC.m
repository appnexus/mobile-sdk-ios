//
//  AddCustomKeywordViewController.m
//  AppNexusSDKApp
//
//  Created by Jose Cabal-Ugaz on 2/10/14.
//  Copyright (c) 2014 AppNexus. All rights reserved.
//

#import "AddCustomKeywordTVC.h"

@interface AddCustomKeywordTVC ()
@property (weak, nonatomic) IBOutlet UITextField *keyTextField;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;

@end

@implementation AddCustomKeywordTVC

- (void)viewDidLoad {
    if (self.existingKey && self.existingValue) {
        self.keyTextField.text = self.existingKey;
        self.valueTextField.text = self.existingValue;
    }
}

- (IBAction)saveCustomKeyword:(UIBarButtonItem *)sender {
    NSString *keyText = self.keyTextField.text;
    NSString *valueText = self.valueTextField.text;
    if ([keyText length] > 0 && [valueText length] > 0) {
        if (self.existingKey && ![self.existingKey isEqualToString:(keyText)]) {
            [self.delegate deleteCustomKeywordWithKey:self.existingKey];
        }
        [self.delegate addCustomKeywordWithKey:keyText andValue:valueText];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelCustomKeyword:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)makeKeyboardDisappear:(id)sender {
    [sender resignFirstResponder];
}

@end
