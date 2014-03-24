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

#import "DebugSettingsViewController.h"
#import "DebugSettingsTVC.h"
#import "DebugOutputViewController.h"

#define NOEMAIL_ALERT_MESSAGE @"Please enable Mail on your device in order to use this feature"
#define NOEMAIL_ALERT_TITLE @""
#define NOEMAIL_ALERT_CANCEL @"OK"
#define MESSAGE_BODY @"Request URL:\n\n%@\n\nResponse from server:\n\n%@"
#define MESSAGE_SUBJECT @"Ad Request/Response"

@interface DebugSettingsViewController () <MFMailComposeViewControllerDelegate, RequestResponseDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSString *requestURL;
@property (strong, nonatomic) NSString *serverResponse;

@end

@implementation DebugSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[DebugSettingsTVC class]]) {
        DebugSettingsTVC *dstvc = (DebugSettingsTVC *)[segue destinationViewController];
        dstvc.update = self;
        dstvc.managedObjectContext = self.managedObjectContext;
    }
    if ([[segue destinationViewController] isKindOfClass:[DebugOutputViewController class]]) {
        DebugOutputViewController *dovc = (DebugOutputViewController *)[segue destinationViewController];
        dovc.lastRequestString = self.requestURL;
    }
}

- (IBAction)emailResults:(UIBarButtonItem *)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        NSString *messageBody = [NSString stringWithFormat: MESSAGE_BODY,
                                 self.requestURL, self.serverResponse];
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

- (void)setRequestURL:(NSString *)requestURL withServerResponse:(NSString *)serverResponse {
    self.requestURL = requestURL;
    self.serverResponse = serverResponse;
}

@end
