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

#import "DebugOutputViewController.h"
#import "AdSettings.h"
#import "ANLogging.h"

#define BASE_DEBUG @"http://mobile.adnxs.com/mob?id=%d&debug_member=%d&dongle=%@&size=%dx%d&psa=%d"
#define CLASS_NAME @"DebugOutputViewController"

#define NOEMAIL_ALERT_MESSAGE @"Please enable Mail on your device in order to use this feature"
#define NOEMAIL_ALERT_TITLE @""
#define NOEMAIL_ALERT_CANCEL @"OK"

@interface DebugOutputViewController () <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *debugOutputDisplay;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@end

@implementation DebugOutputViewController

/*
  
 TODO: Make fully searchable, kind of like Leff's debug auction tool
 
 */

- (IBAction)popDebugAuction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)emailResults:(UIButton *)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        NSString *debugHTML = [self.debugOutputDisplay stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
        
        [picker setSubject:@"Debug Auction Results"];
        [picker setMessageBody:debugHTML isHTML:YES];
        
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

- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) _refreshControl = [[UIRefreshControl alloc] init];
    return _refreshControl;
}

- (void)refreshControlSetup {
    [self.refreshControl addTarget:self action:@selector(loadDebug) forControlEvents:UIControlEventValueChanged];
    [self.debugOutputDisplay.scrollView addSubview:self.refreshControl];
}

- (IBAction)refreshDebug:(UIButton *)sender {
    [self loadDebug];
}

- (void)loadDebug {
    AdSettings *settings = [[AdSettings alloc] init];
    NSString *urlString = [[NSString alloc] initWithFormat:BASE_DEBUG,
                           settings.placementID,
                           settings.memberID,
                           settings.dongle,
                           settings.bannerWidth,
                           settings.bannerHeight,
                           settings.allowPSA];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    ANLogDebug(@"Running Debug: %@", urlString);
    
    dispatch_queue_t debugQueue = dispatch_queue_create("debug downloader", NULL);
    dispatch_async(debugQueue, ^{
        UIApplication *myApplication = [UIApplication sharedApplication]; // get shared application context
        myApplication.networkActivityIndicatorVisible = YES; // set network activity indicator on
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [self.debugOutputDisplay loadRequest:request];
        myApplication.networkActivityIndicatorVisible = NO; // set network activity indicator off
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.refreshControl.isRefreshing) {
                [self.refreshControl endRefreshing];
            }
        });
    });
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshControlSetup];
    [self loadDebug];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{}];
}


@end
