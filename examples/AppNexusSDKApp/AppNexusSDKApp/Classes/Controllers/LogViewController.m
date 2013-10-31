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

#import "LogViewController.h"
#import "LogCoreDataTVC.h"

#define NOEMAIL_ALERT_MESSAGE @"Please enable Mail on your device in order to use this feature"
#define NOEMAIL_ALERT_TITLE @""
#define NOEMAIL_ALERT_CANCEL @"OK"
#define MESSAGE_BODY @"%@"
#define MESSAGE_SUBJECT @"AppNexus SDK Logs"

@interface LogViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) LogCoreDataTVC *lcdtvc;


@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[LogCoreDataTVC class]]) {
        self.lcdtvc = (LogCoreDataTVC *)[segue destinationViewController];
        self.lcdtvc.managedObjectContext = self.managedObjectContext;
    }
}

- (IBAction)emailResults:(UIButton *)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        NSString *messageBody = [NSString stringWithFormat: MESSAGE_BODY,
                                 self.lcdtvc.fullTextToEmail];
        [picker setSubject:MESSAGE_SUBJECT];
        [picker setMessageBody:messageBody isHTML:NO];
        
        [self presentViewController:picker animated:YES completion:^{}];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NOEMAIL_ALERT_TITLE
                                                        message:NOEMAIL_ALERT_MESSAGE
                                                       delegate:self
                                              cancelButtonTitle:NOEMAIL_ALERT_CANCEL
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
