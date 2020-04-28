/*   Copyright 2020 APPNEXUS INC
 
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

#import "InterstitialAdViewController.h"
#import <AppNexusSDK/AppNexusSDK.h>

@interface InterstitialAdViewController () <ANInterstitialAdDelegate>{
    UIActivityIndicatorView *indicator;
}

@property (strong, nonatomic) ANInterstitialAd *interstitialAd;

@end

@implementation InterstitialAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Interstitial Ad";
    self.interstitialAd = [[ANInterstitialAd alloc] initWithPlacementId:@"1281482"];
    self.interstitialAd.delegate = self;
    self.interstitialAd.clickThroughAction = ANClickThroughActionReturnURL;
    [self.interstitialAd loadAd];
}

#pragma mark - ANInterstitialAdDelegate

- (void)adDidReceiveAd:(id)ad {
    NSLog(@"adDidReceiveAd");
    [self.interstitialAd displayAdFromViewController:self];
}

-(void)ad:(id)ad requestFailedWithError:(NSError *)error{
    NSLog(@"Ad request Failed With Error");
}
@end
