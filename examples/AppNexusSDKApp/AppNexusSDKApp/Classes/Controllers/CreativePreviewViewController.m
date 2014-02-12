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

#import "CreativePreviewViewController.h"

#import "ANAdView.h"
#import "ANBannerAdView.h"
#import "ANGlobal.h"
#import "ANInterstitialAd.h"
#import "ANLogging.h"
#import "NSString+ANCategory.h"

NSString *const kErrorAlertTitle = @"Error Loading Creative";
NSString *const kErrorAlertCancel = @"OK";

@interface CreativePreviewViewController () <ANBannerAdViewDelegate, ANInterstitialAdDelegate>

@property NSURL *dataUrl;
@property NSString *adType;
@property int width;
@property int height;
@property NSString *url;

@property ANBannerAdView *bannerAdView;
@property ANInterstitialAd *interstitialAd;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;

@property NSURLConnection *connection;
@property NSMutableData *data;

@end

@interface ANAdView ()
- (void)loadAdFromHtml:(NSString *)html
                 width:(int)width height:(int)height;
@end

NSString *const kBanner = @"banner";
NSString *const kInterstitial = @"interstitial";

@implementation CreativePreviewViewController

- (id)initWithDataUrl:(NSURL *)dataUrl {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                             bundle:nil];
    self = [mainStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    if (self) {
        self.dataUrl = dataUrl;
    }
    return self;
}

// returns true if failed
- (BOOL)parseDataUrl:(NSURL *)dataUrl {
    BOOL failed = NO;
    NSString *errorMessage = @"";
    
    ANLogDebug(@"Received custom URL: %@", [dataUrl absoluteString]);
    
    self.adType = [dataUrl host];
    
    NSDictionary *queryComponents = [[dataUrl query] queryComponents];
    self.width = [[queryComponents objectForKey:@"w"] integerValue];
    self.height = [[queryComponents objectForKey:@"h"] integerValue];
    self.url = [queryComponents objectForKey:@"url"];
    
    if (![[dataUrl scheme] isEqualToString:@"appnexuscr"]) {
        errorMessage = [errorMessage stringByAppendingString
                        :[NSString stringWithFormat:@"Scheme should be 'appnexuscr'\n"]];
        failed = YES;
    }
    
    if (![self.adType isEqualToString:kBanner] && ![self.adType isEqualToString:kInterstitial]) {
        // just a warning - default to banner
        errorMessage = [errorMessage stringByAppendingString
                        :[NSString stringWithFormat:@"Host should be either 'banner' or 'interstitial'\n"]];
    }
    
    if (self.width < 1) {
        errorMessage = [errorMessage stringByAppendingString:
                        [NSString stringWithFormat:@"Error parsing required 'w' width parameter (or 0)\n"]];
        failed = YES;
    }

    if (self.height < 1) {
        errorMessage = [errorMessage stringByAppendingString
                        :[NSString stringWithFormat:@"Error parsing required 'h' height parameter (or 0)\n"]];
        failed = YES;
    }
    if (!self.url) {
        errorMessage = [errorMessage stringByAppendingString
                        :[NSString stringWithFormat:@"Error parsing required 'url' parameter\n"]];
        failed = YES;
    }
    
    if (failed) [self showErrorAlert:errorMessage];
    return failed;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self parseDataUrl:self.dataUrl]) return;
    
    if ([self.adType isEqualToString:kInterstitial]) {
        self.interstitialAd = [ANInterstitialAd new];
        self.interstitialAd.delegate = self;
    } else {
        self.bannerAdView = [[ANBannerAdView alloc]
                             initWithFrame:CGRectMake(0, 100, self.width, self.height)];
        self.bannerAdView.delegate = self;
        self.bannerAdView.rootViewController = self;
        [self.view addSubview:self.bannerAdView];
    }
    
    [self runGetAdContent];
}

- (IBAction)doneAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)reloadAction:(id)sender {
    [self runGetAdContent];
}

- (void)runGetAdContent {
    if (!self.url) {
        [self showErrorAlert:@"Required parameter 'url' was not found"];
        return;
    }
    
    NSMutableURLRequest *request =
    [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]
                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                             timeoutInterval:kAppNexusRequestTimeoutInterval];
    [request setValue:ANUserAgent() forHTTPHeaderField:@"User-Agent"];
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

# pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == self.connection) {
        self.data = [NSMutableData data];
        ANLogDebug(@"Received response: %@", response);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == self.connection) {
        [self.data appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == self.connection) {
        NSString *responseString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        if (self.bannerAdView) {
            [self.bannerAdView loadAdFromHtml:responseString width:self.width height:self.height];
        } else if (self.interstitialAd) {
            [self.interstitialAd loadAdFromHtml:responseString width:self.width height:self.height];
        }
        self.connection = nil;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == self.connection) {
        NSString *errorString = [NSString stringWithFormat:@"Connection failed with error %@",
                                 error.localizedDescription];
        [self showErrorAlert:errorString];
        self.connection = nil;
    }
}

- (void)adDidReceiveAd:(id<ANAdProtocol>)ad {
    if ([ad isKindOfClass:[ANInterstitialAd class]]) {
        [((ANInterstitialAd *) ad) displayAdFromViewController:self];
    }
}

- (void)showErrorAlert:(NSString *)errorMessage {
    ANLogError(errorMessage);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kErrorAlertTitle
                                                    message:errorMessage
                                                   delegate:nil
                                          cancelButtonTitle:kErrorAlertCancel
                                          otherButtonTitles:nil];
    [alert show];
}

@end
