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
